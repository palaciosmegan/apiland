import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Verde para el estado "slowest" (no está en la paleta base).
  static const Color _green = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Jesus Ascama's Dashboard",
              style: TextStyle(
                fontSize: AppTextSizes.base,
                color: AppColors.gray50,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.account_circle,
              size: 32,
              color: AppColors.gray200,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fila de métricas ─────────────────────────────────────────
            Row(
              children: const [
                Expanded(
                  child: _StatCard(value: '9', label: 'online'),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _StatCard(value: '1', label: 'down'),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _StatCard(value: '0', label: 'slow'),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _StatCard(value: '91.9%', label: 'uptime 7d'),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const _SectionHeader('ACTIVE INCIDENTS'),
            const SizedBox(height: 8),

            const _IncidentCard(
              title: 'Prosembra API is down',
              badge: 'downtime: 4h 32m',
              description: 'lorem ipsum blabla',
              actions: ['More info', 'Force refresh'],
              lastRefresh: 'last refresh 4m 32s ago',
            ),
            const SizedBox(height: 16),
            const _IncidentCard(
              title: 'Client X API is slow',
              badge: 'latencia: 4h 32m',
              description: 'lorem ipsum blabla',
              actions: ['More info'],
              lastRefresh: 'last refresh 4m 32s ago',
            ),

            const SizedBox(height: 24),
            const _SectionHeader('STATS'),
            const SizedBox(height: 8),

            _ResponseTimeCard(green: _green),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
      // ── FAB de navegación (abre el drawer inferior) ──────────────────────
      floatingActionButton: const FloatingNavFab(currentRoute: '/dashboard'),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Tarjeta de métrica: número grande + etiqueta pequeña, sobre fondo claro.
class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppTextSizes.xl2, // 24
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTextSizes.sm,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Encabezado de sección en mayúsculas, gris tenue.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: AppTextSizes.xs,
        color: AppColors.gray400,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}

/// Tarjeta de incidente: icono + título + badge, descripción, acciones y refresh.
class _IncidentCard extends StatelessWidget {
  const _IncidentCard({
    required this.title,
    required this.badge,
    required this.description,
    required this.actions,
    required this.lastRefresh,
  });

  final String title;
  final String badge;
  final String description;
  final List<String> actions;
  final String lastRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray200,
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
                color: AppColors.gray900,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppTextSizes.lg, // 18
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
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
                  color: AppColors.gray700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: AppTextSizes.xs,
                    color: AppColors.gray100,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: AppTextSizes.base,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: actions
                .map((label) => _ActionButton(label: label))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            lastRefresh,
            style: const TextStyle(
              fontSize: AppTextSizes.sm,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón morado compacto usado dentro de los incidentes.
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {},
      color: AppColors.primary,
      textColor: AppColors.gray50,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: AppTextSizes.sm,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Tarjeta "RESPONSE TIME" con las columnas FASTEST y SLOWEST.
class _ResponseTimeCard extends StatelessWidget {
  const _ResponseTimeCard({required this.green});

  final Color green;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESPONSE TIME',
            style: TextStyle(
              fontSize: AppTextSizes.xs,
              color: AppColors.gray600,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ResponseStat(
                  label: 'FASTEST',
                  icon: Icons.eco,
                  iconColor: AppColors.primary,
                  client: 'API de cliente 1',
                ),
              ),
              Expanded(
                child: _ResponseStat(
                  label: 'SLOWEST',
                  icon: Icons.bolt,
                  iconColor: green,
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
            color: AppColors.gray500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                fontSize: AppTextSizes.xl2, // 24
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'text',
              style: TextStyle(
                fontSize: AppTextSizes.sm,
                color: AppColors.gray600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          client,
          style: const TextStyle(
            fontSize: AppTextSizes.sm,
            color: AppColors.gray700,
          ),
        ),
      ],
    );
  }
}
