import 'features/monitored_apis/new_api_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/features/login/login_screen.dart';
import 'package:apiland/features/dashboard/dashboard_screen.dart';
import 'package:apiland/features/companies/companies_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carga el .env (token de auth, config) antes de arrancar la app.
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apilandia',
      theme: AppTheme.dark,
      home: const LoginScreen(title: '[a] Apilandia'),
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        // TODO: reemplazar por ServicesScreen cuando exista.
        '/services': (context) => const NewApiScreen(title: 'New API'),
        '/companies': (context) => const CompaniesScreen(),
      },
    );
  }
}
