import 'package:apiland/features/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Al tocar fuera de un input, se quita el foco y se cierra el teclado.
      onTap: () => FocusScope.of(context).unfocus(),
      // opaque: registra el toque también en zonas "vacías" del fondo.
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.secondarySurface,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          // Scrolls when content exceeds the viewport (small screens / keyboard open),
          // which avoids the bottom-overflow stripe.
          child: Column(
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
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          );
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