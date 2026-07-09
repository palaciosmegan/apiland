import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/widgets/error_state.dart';
import 'package:apiland/features/login/data/user.dart';
import 'package:apiland/features/profile/data/me_service.dart';
import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/auth/auth_manager.dart';
import 'package:apiland/core/auth/session.dart';
import 'package:apiland/core/widgets/app_button.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
import 'package:apiland/core/widgets/role_badge.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MeService _service = MeService();

  User? _me;
  Object? _error;
  bool _loading = true;

  String get _initials {
    final parts = Session.name.trim().split(RegExp(r'\s+'));
    final letters = parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return letters.isEmpty ? '?' : letters;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final me = await _service.getMe();
      if (!mounted) return;
      setState(() {
        _me = me;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ErrorState(
        title: 'No se pudieron traer los usuarios',
        message: apiErrorMessage(_error!),
        onRetry: _load,
      );
    }
    if (_me == null) {
      return const Center(child: Text('un error locazo'));
    }
    final me = _me;
    return RefreshIndicator(
      onRefresh: _load,
      child: Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              // Avatar con iniciales.
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary400.withValues(alpha: 0.25),
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: AppTextSizes.xl2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${me!.username} ${me.lastName}',
                style: const TextStyle(
                  fontSize: AppTextSizes.xl2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textStandout,
                ),
              ),
              const SizedBox(height: 8),
              RoleBadge(role: me.role),

              const SizedBox(height: 32),

              // Card con datos (solo lectura, según el diseño).
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.secondarySurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Email'),
                    Text(
                      me.email,
                      style: const TextStyle(
                        fontSize: AppTextSizes.base,
                        color: AppColors.textStandout,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _FieldLabel('Contraseña'),
                    const Text(
                      '••••••••',
                      style: TextStyle(
                        fontSize: AppTextSizes.base,
                        color: AppColors.textStandout,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cerrar sesión.
              DangerButton(
                label: 'Cerrar sesión',
                onPressed: () => AuthManager.logout(),
              ),
            ],
          ),
        ),
        floatingActionButton: const FloatingNavFab(currentRoute: '/profile'),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppTextSizes.sm,
          color: AppColors.gray400,
        ),
      ),
    );
  }
}
