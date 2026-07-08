import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/auth/user_role.dart';

/// Chip con el rol del usuario. El color depende del rol.
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      UserRole.root => AppColors.primary600,
      UserRole.admin => AppColors.info300,
      UserRole.editor => AppColors.green300,
      UserRole.viewer => AppColors.orange300,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        role.wire,
        style: TextStyle(fontSize: AppTextSizes.xs, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
