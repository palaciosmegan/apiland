import 'package:flutter/material.dart';
import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/widgets/error_state.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
import 'package:apiland/core/widgets/swipe_to_edit.dart';
import 'package:apiland/features/companies/data/company.dart';
import 'package:apiland/features/companies/data/company_service.dart';
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

  final CompanyService _companyService = CompanyService();
  List<Company> _companies = [];
  bool _loadingCompanies = true;

  @override
  void initState() {
    super.initState();
    _load();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _loadingCompanies = true;
    });
    try {
      final list = await _companyService.getCompanies();
      if (!mounted) return;
      setState(() {
        _companies = list;
        _loadingCompanies = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCompanies = false;
      });
    }
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

  Future<void> _editApi(MonitoredApi api) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewApiScreen(title: 'Editar API', existingApi: api),
      ),
    );
    await _load(); // refresca al volver (por si se actualizó)
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
        itemBuilder: (context, i) {
          final api = _apis[i];
          String? companyName;
          if (!_loadingCompanies) {
            final matches = _companies.where((c) => c.id == api.companyId);
            companyName = matches.isEmpty ? null : matches.first.name;
          }
          return SwipeToEdit(
            itemKey: api.id ?? api.name,
            onEdit: () => _editApi(api),
            child: ApiCard(api: api, companyName: companyName),
          );
        },
      ),
    );
  }
}
