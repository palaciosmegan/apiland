import 'package:flutter/material.dart';
import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/widgets/error_state.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
import 'package:apiland/features/monitored_apis/data/monitored_api.dart';
import 'package:apiland/features/monitored_apis/data/monitored_api_service.dart';
import 'package:apiland/features/monitored_apis/new_api_screen.dart';
import 'package:apiland/features/monitored_apis/widgets/api_card.dart';

class ApisScreen extends StatefulWidget {
  const ApisScreen({super.key});

  @override
  State<ApisScreen> createState() => _ApisScreenState();
}

class _ApisScreenState extends State<ApisScreen> {
  final MonitoredApiService _service = MonitoredApiService();

  List<MonitoredApi> _apis = const [];
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
      final list = await _service.getMonitoredApis();
      if (!mounted) return;
      setState(() {
        _apis = list;
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

  Future<void> _addApi() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewApiScreen(title: 'Nueva API')),
    );
    await _load(); // refresca al volver (por si se creó una)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('APIs')),
      body: _buildBody(),
      floatingActionButton: FloatingNavFab(
        currentRoute: '/services',
        actions: [
          NavFabAction(
            icon: Icons.add,
            onPressed: _addApi,
            enabled: _error == null,
            tooltip: 'Nueva API',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ErrorState(
        title: 'No se pudieron traer las APIs',
        message: apiErrorMessage(_error!),
        onRetry: _load,
      );
    }
    if (_apis.isEmpty) {
      return const Center(child: Text('No hay APIs todavía'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _apis.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, i) => ApiCard(api: _apis[i]),
      ),
    );
  }
}
