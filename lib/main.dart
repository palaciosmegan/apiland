import 'features/new_api/new_api_screen.dart';
import 'features/new_company/new_company_screen.dart';
import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/features/login/login_screen.dart';
import 'package:apiland/features/dashboard/dashboard_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apilandia',
      theme: AppTheme.dark,
      home: const LoginScreen(title: '[logo here] Apilandia'),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        // TODO: reemplazar por ServicesScreen cuando exista.
        '/services': (context) => const NewApiScreen(title: 'New API'),
        '/companies': (context) => const NewCompanyScreen(title: 'New Company'),
      },
    );
  }
}