import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
import 'package:apiland/features/dashboard/incident.dart';
import 'package:apiland/features/dashboard/widgets/incident_card.dart';
import 'package:apiland/features/dashboard/widgets/response_time_card.dart';
import 'package:apiland/features/dashboard/widgets/section_header.dart';
import 'package:apiland/features/dashboard/widgets/stat_card.dart';
import 'package:apiland/features/profile/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Data de ejemplo (luego vendrá de la API).
  static const List<Incident> _incidents = [
    Incident(
      title: 'Prosembra API is down',
      badge: 'downtime: 4h 32m',
      description: 'lorem ipsum blabla',
      actions: ['More info', 'Force refresh'],
      lastRefresh: 'last refresh 4m 32s ago',
    ),
    Incident(
      title: 'Client X API is slow',
      badge: 'latencia: 4h 32m',
      description: 'lorem ipsum blabla',
      actions: ['More info'],
      lastRefresh: 'last refresh 4m 32s ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text("Jesus Ascama's Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32),
            tooltip: 'Perfil',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Métricas ─────────────────────────────────────────────────
            Row(
              children: const [
                Expanded(child: StatCard(value: '9', label: 'online')),
                SizedBox(width: 8),
                Expanded(child: StatCard(value: '1', label: 'down')),
                SizedBox(width: 8),
                Expanded(child: StatCard(value: '0', label: 'slow')),
                SizedBox(width: 8),
                Expanded(child: StatCard(value: '91.9%', label: 'uptime 7d')),
              ],
            ),

            const SizedBox(height: 24),
            const SectionHeader('ACTIVE INCIDENTS'),
            const SizedBox(height: 8),

            for (int i = 0; i < _incidents.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              IncidentCard(incident: _incidents[i]),
            ],

            const SizedBox(height: 24),
            const SectionHeader('STATS'),
            const SizedBox(height: 8),

            const ResponseTimeCard(),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
      floatingActionButton: const FloatingNavFab(currentRoute: '/dashboard'),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
