import 'package:apiland/features/audit_log/audit_log_screen.dart';

import 'features/monitored_apis/apis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/app_keys.dart';
import 'package:apiland/core/auth/auth_manager.dart';
import 'package:apiland/core/network/token_store.dart';
import 'package:apiland/features/login/login_screen.dart';
import 'package:apiland/features/dashboard/dashboard_screen.dart';
import 'package:apiland/features/companies/companies_screen.dart';
import 'package:apiland/features/users/users_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Carga el .env (config) y los tokens persistidos antes de arrancar.
  await dotenv.load(fileName: '.env');
  await TokenStore.load();

  final loggedIn = AuthManager.hasValidSession;
  if (loggedIn) AuthManager.restore(); // rol/nombre + agenda refresh

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.loggedIn});

  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apilandia',
      theme: AppTheme.dark,
      navigatorKey: appNavigatorKey,
      scaffoldMessengerKey: appMessengerKey,
      // Auth gate: sesión válida → dashboard; si no → login.
      home: loggedIn
          ? const DashboardScreen()
          : const LoginScreen(title: '[a] Apilandia'),
      routes: {
        '/login': (context) => const LoginScreen(title: '[a] Apilandia'),
        '/dashboard': (context) => const DashboardScreen(),
        '/logs': (context) => const AuditLogScreen(),
        '/services': (context) => const ApisScreen(),
        '/companies': (context) => const CompaniesScreen(),
        '/users': (context) => const UsersScreen(),
      },
    );
  }
}
