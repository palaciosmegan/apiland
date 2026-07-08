import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/widgets/error_state.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
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
  late Future<List<Company>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getCompanies();
  }

  Future<void> _reload() async {
    final f = _service.getCompanies();
    setState(() {
      _future = f;
    });
    await f;
  }

  Future<void> _addCompany() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NewCompanyScreen(title: 'Nueva compañía'),
      ),
    );
    // Al volver del form, refresca la lista (por si se creó una).
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compañías'),
        actions: [
          IconButton(
            onPressed: _addCompany,
            icon: const Icon(Icons.add),
            tooltip: 'Nueva compañía',
          ),
        ],
      ),
      body: FutureBuilder<List<Company>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(
              title: 'No se pudieron cargar las compañías',
              message: apiErrorMessage(snapshot.error!),
              onRetry: _reload,
            );
          }
          final companies = snapshot.data ?? const <Company>[];
          if (companies.isEmpty) {
            return const Center(child: Text('No hay compañías todavía'));
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: companies.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = companies[i];
                return Card(
                  color: AppColors.secondarySurface,
                  child: ListTile(
                    leading: const Icon(
                      Icons.corporate_fare,
                      color: AppColors.textPrimary,
                    ),
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
        },
      ),
      floatingActionButton: const FloatingNavFab(currentRoute: '/companies'),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
