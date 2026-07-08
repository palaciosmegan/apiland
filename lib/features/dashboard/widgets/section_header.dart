import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';

/// Encabezado de sección en mayúsculas, tenue, sobre superficie oscura.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: AppTextSizes.xs,
        color: AppColors.textMuted,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}
