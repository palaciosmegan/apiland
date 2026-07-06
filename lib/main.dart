import 'package:flutter/material.dart';
import 'package:apiland/core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apilandia',
      theme: AppTheme.dark,
      home: const MyHomePage(title: '[logo here] Apilandia'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return GestureDetector(
      // Al tocar fuera de un input, se quita el foco y se cierra el teclado.
      onTap: () => FocusScope.of(context).unfocus(),
      // opaque: registra el toque también en zonas "vacías" del fondo.
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        // Scrolls when content exceeds the viewport (small screens / keyboard open),
        // which avoids the bottom-overflow stripe.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          // mainAxisAlignment: .center,
          children: [
            SizedBox(height: 64),
            Text(
              'Iniciar sesión',
              style: TextStyle(
                fontSize: AppTextSizes.xl4, // 24 — top of the type scale
                fontWeight: FontWeight.w600,
                color: AppColors.gray50,
              ),
            ),

            SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontSize: AppTextSizes.base), // 16 value text
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "nombre@correo.com",
                        prefixIcon: Icon(Icons.email),
                      ),
                      onChanged: (String value) {},
                      validator: (value) {
                        return value!.isEmpty ? 'Ingresa tu correo' : null;
                      },
                    ),

                    SizedBox(height: 16),

                    TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      style: const TextStyle(fontSize: AppTextSizes.base), // 16 value text
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        return value!.isEmpty ? 'Ingresa tu contraseña' : null;
                      },
                    ),

                    SizedBox(height: 24),

                    MaterialButton(
                      onPressed: () {

                      },
                      color: Theme.of(context).colorScheme.primary,
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      disabledColor: AppColors.gray700,
                      disabledTextColor: AppColors.gray400,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ingresar',
                        style: TextStyle(fontSize: AppTextSizes.base), // 16
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
