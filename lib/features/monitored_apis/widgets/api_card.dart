import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/features/monitored_apis/data/monitored_api.dart';

class ApiCard extends StatelessWidget {
  const ApiCard({super.key, required this.api, this.companyName});

  final MonitoredApi api;

  final String? companyName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary400.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.api,
                  color: AppColors.primary200,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      api.name,
                      style: const TextStyle(
                        fontSize: AppTextSizes.base,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textStandout,
                      ),
                    ),
                    _Muted(companyName ?? '...'),
                  ],
                ),
              ),
              const _Pill('status'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const _Muted('25 incidentes / 30 días'),
              const SizedBox(height: 8),
              const _Pill('1 endpoint caído, 6 activos'),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }
}

/// Texto secundario tenue.
class _Muted extends StatelessWidget {
  const _Muted(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppTextSizes.sm,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Pill / badge gris.
class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.badgeSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppTextSizes.xs,
          color: AppColors.onBadge,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
