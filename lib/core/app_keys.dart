import 'package:flutter/material.dart';

/// Keys globales para navegar y mostrar SnackBars desde fuera del árbol de
/// widgets (ej. desde el AuthManager cuando expira la sesión).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
