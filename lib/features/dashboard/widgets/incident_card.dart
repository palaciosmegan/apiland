import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/features/dashboard/incident.dart';

/// Tarjeta de incidente: icono + título + badge, descripción, acciones y refresh.
class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.onCard,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  incident.title,
                  style: const TextStyle(
                    fontSize: AppTextSizes.lg,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onCard,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.badgeSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  incident.badge,
                  style: const TextStyle(
                    fontSize: AppTextSizes.xs,
                    color: AppColors.onBadge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            incident.description,
            style: const TextStyle(
              fontSize: AppTextSizes.base,
              color: AppColors.onCardMuted,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: incident.actions
                .map((label) => _IncidentAction(label: label))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            incident.lastRefresh,
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

/// Botón compacto de acción dentro del incidente. Hereda color del tema
/// (FilledButton), solo achica el padding.
class _IncidentAction extends StatelessWidget {
  const _IncidentAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {},
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
