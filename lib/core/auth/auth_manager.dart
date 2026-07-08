import 'dart:async';

import 'package:flutter/material.dart';
import 'package:apiland/core/app_keys.dart';
import 'package:apiland/core/auth/session.dart';
import 'package:apiland/core/network/token_store.dart';
import 'package:apiland/core/utils/jwt.dart';
import 'package:apiland/features/login/data/auth_result.dart';
import 'package:apiland/features/login/data/auth_service.dart';

/// Orquesta la sesión: persiste tokens, refresca proactivamente antes de que
/// expire el JWT, y redirige al login si la sesión realmente terminó.
class AuthManager {
  AuthManager._();

  static final AuthService _authService = AuthService();
  static Timer? _refreshTimer;

  /// Cuánto antes del `exp` intentamos refrescar (margen prudente).
  static const Duration _refreshBuffer = Duration(minutes: 1);

  /// ¿Hay una sesión guardada aún no expirada? (para el auth gate al arrancar)
  static bool get hasValidSession {
    if (!TokenStore.hasToken) return false;
    final expiry = jwtExpiry(TokenStore.accessToken!);
    if (expiry == null) return true; // sin exp legible → asumimos válido
    return expiry.isAfter(DateTime.now().toUtc());
  }

  /// Restaura la sesión persistida al iniciar la app (rol/nombre + agenda refresh).
  static void restore() {
    if (!TokenStore.hasToken) return;
    Session.setFromToken(TokenStore.accessToken!);
    _scheduleRefresh();
  }

  /// Tras un login exitoso: persiste tokens, arma la sesión y agenda el refresh.
  static Future<void> onAuthenticated(AuthResult result, {String? email}) async {
    await TokenStore.save(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      userId: result.userId,
    );
    Session.setFromToken(result.accessToken);
    if (email != null) Session.setEmail(email);
    _scheduleRefresh();
  }

  /// Logout manual (botón "Cerrar sesión").
  static Future<void> logout() async {
    _refreshTimer?.cancel();
    await TokenStore.clear();
    Session.clear();
    _goToLogin();
  }

  // ── interno ────────────────────────────────────────────────────────────

  static void _scheduleRefresh() {
    _refreshTimer?.cancel();
    final token = TokenStore.accessToken;
    if (token == null) return;
    final expiry = jwtExpiry(token);
    if (expiry == null) return; // sin exp → no podemos agendar

    var delay = expiry.difference(DateTime.now().toUtc()) - _refreshBuffer;
    if (delay.isNegative) delay = Duration.zero; // ya está por expirar → ya mismo
    _refreshTimer = Timer(delay, _refresh);
  }

  static Future<void> _refresh() async {
    final refreshToken = TokenStore.refreshToken;
    final userId = TokenStore.userId;
    if (refreshToken == null || userId == null) {
      await _expireSession();
      return;
    }
    try {
      final result = await _authService.refresh(
        userId: userId,
        refreshToken: refreshToken,
      );
      await TokenStore.save(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        userId: result.userId.isEmpty ? userId : result.userId,
      );
      Session.setFromToken(result.accessToken);
      _scheduleRefresh(); // reagenda con el nuevo exp
    } catch (_) {
      // Refresh falló o el refresh token ya no vale → sesión terminada.
      await _expireSession();
    }
  }

  static Future<void> _expireSession() async {
    _refreshTimer?.cancel();
    await TokenStore.clear();
    Session.clear();
    _goToLogin(message: 'Tu sesión ha expirado. Ingresa de nuevo.');
  }

  static void _goToLogin({String? message}) {
    appNavigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
    if (message != null) {
      appMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
