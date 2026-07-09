import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';

/// Tarjeta de métrica: número grande + etiqueta pequeña, sobre card clara.
class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppTextSizes.xl2,
                fontWeight: FontWeight.w600,
                color: AppColors.onCard,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTextSizes.sm,
              color: AppColors.onCardMuted,
            ),
          ),
        ],
      ),
    );
  }
}
