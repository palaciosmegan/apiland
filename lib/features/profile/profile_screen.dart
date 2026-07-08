import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/auth/auth_manager.dart';
import 'package:apiland/core/auth/session.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            // Avatar con iniciales.
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primary.withValues(alpha: 0.25),
              child: Text(
                _initials,
                style: const TextStyle(
                  fontSize: AppTextSizes.xl2,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryLight,
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
            _RoleBadge(role: Session.role.wire),

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
            SizedBox(
              width: double.infinity,
              child: MaterialButton(
                onPressed: () => AuthManager.logout(),
                color: AppColors.error.withValues(alpha: 0.12),
                textColor: AppColors.error,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontSize: AppTextSizes.base),
                ),
              ),
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        role,
        style: const TextStyle(
          fontSize: AppTextSizes.xs,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}
