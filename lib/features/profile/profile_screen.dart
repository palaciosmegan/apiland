import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/auth/auth_manager.dart';
import 'package:apiland/core/auth/session.dart';
import 'package:apiland/core/widgets/app_button.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
import 'package:apiland/core/widgets/role_badge.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
  Widget build(BuildContext context) {
    return Scaffold(
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
              Session.name.isEmpty ? 'Usuario' : Session.name,
              style: const TextStyle(
                fontSize: AppTextSizes.xl2,
                fontWeight: FontWeight.w600,
                color: AppColors.textStandout,
              ),
            ),
            const SizedBox(height: 8),
            RoleBadge(role: Session.role),

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
                    Session.email.isEmpty ? '—' : Session.email,
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

