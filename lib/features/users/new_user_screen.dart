import 'package:apiland/core/widgets/app_dropdown.dart';
import 'package:apiland/features/companies/data/company.dart';
import 'package:apiland/features/companies/data/company_service.dart';
import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/utils/validators.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
import 'package:apiland/features/login/data/user.dart';
import 'package:apiland/features/users/data/user_service.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key, this.existingUser});

  /// Si viene seteado, la pantalla edita este usuario en vez de crear uno.
  final User? existingUser;

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _positionController = TextEditingController();
  final CompanyService _companyService = CompanyService();
  final _passwordController = TextEditingController();
  final UserService _service = UserService();

  List<Company> _companies = [];
  Company? _selectedCompany;
  bool _loadingCompanies = true;
  bool _companiesError = false;

  bool get _isEditing => widget.existingUser != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingUser;
    if (existing != null) {
      _usernameController.text = existing.username;
      _lastNameController.text = existing.lastName;
      _emailController.text = existing.email;
      _positionController.text = existing.position;
      _role = existing.role;
    }
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    setState(() {
      _loadingCompanies = true;
      _companiesError = false;
    });
    try {
      final list = await _companyService.getCompanies();
      if (!mounted) return;
      setState(() {
        _companies = list;
        _loadingCompanies = false;
        final existing = widget.existingUser;
        if (existing != null) {
          final matches = _companies.where((c) => c.id == existing.companyId);
          _selectedCompany = matches.isEmpty ? null : matches.first;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCompanies = false;
        _companiesError = true;
      });
    }
  }

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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los campos marcados en rojo')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final user = User(
        id: widget.existingUser?.id,
        username: _usernameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        position: _positionController.text.trim(),
        companyId: _selectedCompany!.id!,
        role: _role,
        password: _passwordController.text,
      );
      if (_isEditing) {
        await _service.updateUser(user);
      } else {
        await _service.createUser(user);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Usuario actualizado' : 'Usuario creado'),
        ),
      );
      Navigator.of(context).pop(true); // vuelve a la lista y refresca
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
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
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar usuario' : 'Nuevo usuario'),
        ),
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

                  AppDropdown<Company>(
                    value: _selectedCompany,
                    items: _companies,
                    itemLabel: (item) => item.name,
                    onChanged: _loadingCompanies
                        ? null
                        : (company) =>
                              setState(() => _selectedCompany = company),
                    label: "Compañía",
                    prefixIcon: Icons.corporate_fare,
                    validator: (value) =>
                        value == null ? 'Selecciona un cliente' : null,
                    hint: _loadingCompanies
                        ? "Cargando clientes…"
                        : _companiesError
                        ? "Error al cargar"
                        : "Selecciona un cliente",
                  ),

                  if (!_isEditing)
                    const SizedBox(height: 16),

                  if (!_isEditing)
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(fontSize: AppTextSizes.base),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      validator: _isEditing
                          ? null
                          : (v) => Validators.required(
                              v,
                              message: 'Ingresa la contraseña',
                            ),
                    ),

                  const SizedBox(height: 16),

                  AppDropdown<UserRole>(
                    value: _role,
                    items: UserRole.values
                        .toList(),
                    itemLabel: (item) => item.wire,
                    onChanged: (r) =>
                        setState(() => _role = r ?? UserRole.viewer),
                    label: 'Rol',
                    prefixIcon: Icons.shield_outlined,
                  ),

                ],
              ),
            ),
          ),
        ),
        // Guardar como check FAB (sin menú en pantallas de crear).
        floatingActionButton: FloatingNavFab(
          showMenu: false,
          actions: [
            NavFabAction(
              icon: Icons.check,
              onPressed: _save,
              loading: _saving,
              tooltip: _isEditing ? 'Guardar cambios' : 'Guardar usuario',
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
