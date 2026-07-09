import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/widgets/error_state.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
import 'package:apiland/core/widgets/initials_avatar.dart';
import 'package:apiland/features/companies/data/company.dart';
import 'package:apiland/features/companies/data/company_service.dart';
import 'package:apiland/features/companies/new_company_screen.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final CompanyService _service = CompanyService();

  List<Company> _companies = const [];
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
      final list = await _service.getCompanies();
      if (!mounted) return;
      setState(() {
        _companies = list;
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

  Future<void> _addCompany() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NewCompanyScreen(title: 'Nueva compañía'),
      ),
    );
    await _load(); // refresca al volver (por si se creó una)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: _buildBody(),
      // Sin conexión al GET → el add queda desactivado (tampoco habría POST).
      floatingActionButton: FloatingNavFab(
        currentRoute: '/companies',
        onAdd: _addCompany,
        addEnabled: _error == null,
        addTooltip: 'Nuevo cliente',
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
        title: 'No se pudieron traer los clientes',
        message: apiErrorMessage(_error!),
        onRetry: _load,
      );
    }
    if (_companies.isEmpty) {
      return const Center(child: Text('No hay clientes todavía'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: _companies.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final c = _companies[i];
          return Card(
            color: AppColors.secondarySurface,
            child: ListTile(
              leading: InitialsAvatar(name: c.name),
              title: Text(
                c.name,
                style: const TextStyle(
                  color: AppColors.textStandout,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                c.tipoCliente,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          );
        },
      ),
    );
  }
}
