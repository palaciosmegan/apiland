// Smoke test básico: la app arranca en el login cuando no hay sesión.

import 'package:flutter_test/flutter_test.dart';

import 'package:apiland/main.dart';

void main() {
  testWidgets('Arranca en el login sin sesión', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(loggedIn: false));

    // La pantalla de login muestra su encabezado.
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
