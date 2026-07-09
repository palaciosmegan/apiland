import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';

/// Tarjeta "RESPONSE TIME" con las columnas FASTEST y SLOWEST.
class ResponseTimeCard extends StatelessWidget {
  const ResponseTimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESPONSE TIME',
            style: TextStyle(
              fontSize: AppTextSizes.xs,
              color: AppColors.onCardMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _ResponseStat(
                  label: 'FASTEST',
                  icon: Icons.eco,
                  iconColor: AppColors.primary400,
                  client: 'API de cliente 1',
                ),
              ),
              Expanded(
                child: _ResponseStat(
                  label: 'SLOWEST',
                  icon: Icons.bolt,
                  iconColor: AppColors.green400,
                  client: 'API de cliente 2',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResponseStat extends StatelessWidget {
  const _ResponseStat({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.client,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final String client;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTextSizes.xs,
            color: AppColors.onCardMuted,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 8),
            const Text(
              '9',
              style: TextStyle(
                fontSize: AppTextSizes.xl2,
                fontWeight: FontWeight.w600,
                color: AppColors.onCard,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'text',
              style: TextStyle(
                fontSize: AppTextSizes.sm,
                color: AppColors.onCardMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          client,
          style: const TextStyle(
            fontSize: AppTextSizes.sm,
            color: AppColors.onCardMuted,
          ),
        ),
      ],
    );
  }
}
