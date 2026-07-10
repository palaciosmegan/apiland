import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/widgets/error_state.dart';
import 'package:apiland/features/audit_log/data/audit_log_entry.dart';
import 'package:apiland/features/audit_log/data/audit_log_service.dart';
import 'package:flutter/material.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final AuditLogService _service = AuditLogService();

  List<AuditLogEntry> _logEntries = const [];
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.getAuditLogs();
      if (!mounted) return;
      setState(() {
        _logEntries = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit log')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ErrorState(
        title: 'No se pudieron traer los logs',
        message: apiErrorMessage(_error!),
        onRetry: _load,
      );
    }
    if (_logEntries.isEmpty) {
      return const Center(child: Text('No hay logs'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _logEntries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final l = _logEntries[i];
          return Card(
            color: AppColors.secondarySurface,
            child: ListTile(
              title: Text(
                'Acción: ${l.action} en la tabla "${l.entityName}"',
                style: const TextStyle(
                  color: AppColors.textStandout,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Por: ${l.username} el ${l.timestamp}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        },
      ),
    );
  }
}