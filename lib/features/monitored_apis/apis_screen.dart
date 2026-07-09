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
  late Future<List<MonitoredApi>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getMonitoredApis();
  }

  Future<void> _reload() async {
    final f = _service.getMonitoredApis();
    setState(() {
      _future = f;
    });
    await f;
  }

  Future<void> _addApi() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NewApiScreen(title: 'Nueva API'),
      ),
    );
    // Al volver del form, refresca la lista (por si se creó una).
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('APIs')),
      body: FutureBuilder<List<MonitoredApi>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(
              title: 'No se pudieron cargar las APIs',
              message: apiErrorMessage(snapshot.error!),
              onRetry: _reload,
            );
          }
          final apis = snapshot.data ?? const <MonitoredApi>[];
          if (apis.isEmpty) {
            return const Center(child: Text('No hay APIs todavía'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: apis.length,
              itemBuilder: (context, i) => ApiCard(api: apis[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingNavFab(
        currentRoute: '/services',
        onAdd: _addApi,
        addTooltip: 'Nueva API',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
