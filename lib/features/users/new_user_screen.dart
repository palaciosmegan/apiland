import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/utils/validators.dart';
import 'package:apiland/core/widgets/app_button.dart';
import 'package:apiland/features/login/data/user.dart';
import 'package:apiland/features/users/data/user_service.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _positionController = TextEditingController();
  final _passwordController = TextEditingController();
  final UserService _service = UserService();

  UserRole _role = UserRole.viewer;
  bool _saving = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await _service.createUser(
        User(
          username: _usernameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          position: _positionController.text.trim(),
          role: _role,
          password: _passwordController.text,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado')),
      );
      Navigator.of(context).pop(true); // vuelve a la lista y refresca
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(apiErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(title: const Text('Nuevo usuario')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(fontSize: AppTextSizes.base),
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        Validators.required(v, message: 'Ingresa el usuario'),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _lastNameController,
                    style: const TextStyle(fontSize: AppTextSizes.base),
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) =>
                        Validators.required(v, message: 'Ingresa el apellido'),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: AppTextSizes.base),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'nombre@correo.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: Validators.email,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _positionController,
                    style: const TextStyle(fontSize: AppTextSizes.base),
                    decoration: const InputDecoration(
                      labelText: 'Cargo',
                      prefixIcon: Icon(Icons.work_outline),
                    ),
                    validator: (v) =>
                        Validators.required(v, message: 'Ingresa el cargo'),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(fontSize: AppTextSizes.base),
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (v) =>
                        Validators.required(v, message: 'Ingresa la contraseña'),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<UserRole>(
                    initialValue: _role,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      prefixIcon: Icon(Icons.shield_outlined),
                    ),
                    // El backend solo permite crear 'admin' o 'user' (root no).
                    items: UserRole.values
                        .where((r) => r != UserRole.root)
                        .map(
                          (r) => DropdownMenuItem<UserRole>(
                            value: r,
                            child: Text(r.wire),
                          ),
                        )
                        .toList(),
                    onChanged: (r) => setState(() => _role = r ?? UserRole.viewer),
                  ),

                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: 'Guardar usuario',
                    loading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
