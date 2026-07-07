import 'package:apiland/features/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/auth/session.dart';
import 'package:apiland/core/network/token_store.dart';
import 'package:apiland/core/utils/validators.dart';
import 'package:apiland/features/login/data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // Keys por campo para validar cada uno de forma independiente al perder foco.
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;
  // Un campo se marca "touched" al perder el foco por primera vez. A partir de
  // ahí revalida en vivo, para que el error desaparezca apenas se corrige.
  bool _emailTouched = false;
  bool _passwordTouched = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      // Guarda el token (para el interceptor) y lee el rol del JWT.
      TokenStore.setToken(result.accessToken);
      Session.setFromToken(result.accessToken);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar sesión: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Al tocar fuera de un input, se quita el foco y se cierra el teclado.
      onTap: () => FocusScope.of(context).unfocus(),
      // opaque: registra el toque también en zonas "vacías" del fondo.
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
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
                  key: _formKey,
                  child: Column(
                    children: [
                      // Error solo al perder el foco; luego se limpia en vivo
                      // apenas el campo queda válido.
                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            _emailTouched = true;
                            _emailFieldKey.currentState?.validate();
                          }
                        },
                        child: TextFormField(
                          key: _emailFieldKey,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: AppTextSizes.base),
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "nombre@correo.com",
                            prefixIcon: Icon(Icons.email),
                          ),
                          onChanged: (_) {
                            if (_emailTouched) {
                              _emailFieldKey.currentState?.validate();
                            }
                          },
                          validator: Validators.email,
                        ),
                      ),

                      SizedBox(height: 16),

                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            _passwordTouched = true;
                            _passwordFieldKey.currentState?.validate();
                          }
                        },
                        child: TextFormField(
                          key: _passwordFieldKey,
                          controller: _passwordController,
                          obscureText: true,
                          keyboardType: TextInputType.visiblePassword,
                          style: const TextStyle(fontSize: AppTextSizes.base),
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: Icon(Icons.lock),
                          ),
                          onChanged: (_) {
                            if (_passwordTouched) {
                              _passwordFieldKey.currentState?.validate();
                            }
                          },
                          validator: (value) => Validators.required(
                            value,
                            message: 'Ingresa tu contraseña',
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      MaterialButton(
                        onPressed: _loading ? null : _login,
                        color: Theme.of(context).colorScheme.primary,
                        textColor: Theme.of(context).colorScheme.onPrimary,
                        disabledColor: AppColors.gray700,
                        disabledTextColor: AppColors.gray400,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.gray400,
                                ),
                              )
                            : Text(
                                'Ingresar',
                                style: TextStyle(fontSize: AppTextSizes.base),
                              ),
                      ),
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
