import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/utils/validators.dart';
import 'package:apiland/core/widgets/app_dropdown.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
import 'package:apiland/features/monitored_apis/data/api_credentials_service.dart';
import 'package:apiland/features/monitored_apis/data/auth_type.dart';
import 'package:apiland/features/monitored_apis/data/monitored_api.dart';
import 'package:apiland/features/monitored_apis/data/monitored_api_service.dart';
import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/features/companies/data/company.dart';
import 'package:apiland/features/companies/data/company_service.dart';

class NewApiScreen extends StatefulWidget {
  const NewApiScreen({super.key, required this.title, this.existingApi});

  final String title;

  /// Si viene seteado, la pantalla edita esta API en vez de crear una nueva.
  final MonitoredApi? existingApi;

  @override
  State<NewApiScreen> createState() => _NewApiScreenState();
}

// const List<String> refreshApiIntervalOptions = <String>[
//   '1 hora',
//   '2 horas',
//   '3 horas',
// ];

class _NewApiScreenState extends State<NewApiScreen> {
  /// Placeholder visual para secretos ya guardados (el backend nunca los
  /// devuelve). Mientras se muestre esto, el campo está bloqueado.
  static const _secretPlaceholder = '••••••••';

  final _formKey = GlobalKey<FormState>();
  final CompanyService _companyService = CompanyService();
  final MonitoredApiService _monitoredApiService = MonitoredApiService();
  final ApiCredentialsService _credentialService = ApiCredentialsService();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();

  // AuthType.staticBearer
  final _bearerTokenController = TextEditingController();
  // AuthType.credentialsLogin
  final _tokenEndpointController = TextEditingController();
  final _credUsernameController = TextEditingController();
  final _credPasswordController = TextEditingController();

  // String _intervalDropdownValue = refreshApiIntervalOptions.first;
  AuthType _authType = AuthType.none;
  bool _saving = false;

  // Qué secretos ya existían al cargar la pantalla (para saber qué campo
  // mostrar bloqueado con el placeholder).
  bool _hasBearerToken = false;
  bool _hasUsername = false;
  bool _hasPassword = false;

  /// Si el usuario tocó algo de la sección de autorización desde que se
  /// cargó (cambió el tab, o desbloqueó/editó un secreto). Mientras esto sea
  /// false en modo edición, no se manda el PUT a apicredentials.
  bool _authTouched = false;

  List<Company> _companies = [];
  Company? _selectedCompany;
  bool _loadingCompanies = true;
  bool _companiesError = false;

  bool get _isEditing => widget.existingApi != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingApi;
    if (existing != null) {
      _nameController.text = existing.name;
      _descriptionController.text = existing.description;
      _urlController.text = existing.url;
      _loadExistingCredentials(existing.id!);
    }
    _loadCompanies();
  }

  Future<void> _loadExistingCredentials(int monitoredApiId) async {
    try {
      final credential = await _credentialService.getByMonitoredApiId(
        monitoredApiId,
      );
      if (!mounted || credential == null) return;
      setState(() {
        _authType = credential.authType;
        _tokenEndpointController.text = credential.tokenEndpoint ?? '';
        _hasBearerToken = credential.hasBearerToken;
        _hasUsername = credential.hasUsername;
        _hasPassword = credential.hasPassword;
        if (_hasBearerToken) _bearerTokenController.text = _secretPlaceholder;
        if (_hasUsername) _credUsernameController.text = _secretPlaceholder;
        if (_hasPassword) _credPasswordController.text = _secretPlaceholder;
      });
    } catch (_) {
      // Si falla, se queda en "Ninguna" — el usuario puede reconfigurarla.
    }
  }

  /// Un campo está bloqueado (dots + readOnly) si estamos editando, el
  /// usuario no ha tocado la sección todavía, y ese secreto ya existía.
  bool _fieldLocked(bool hasValue) => _isEditing && !_authTouched && hasValue;

  /// Si hay que mandar el PUT a apicredentials: al crear, cuando se eligió
  /// algo distinto de "Ninguna"; al editar, solo si se tocó la sección.
  bool get _mustSubmitAuth =>
      _isEditing ? _authTouched : _authType != AuthType.none;

  /// Desbloquea toda la sección de credenciales (son un solo DTO en el
  /// backend, no se puede actualizar un campo sin resubir los demás).
  void _unlockCredentials() {
    setState(() {
      _authTouched = true;
      _bearerTokenController.clear();
      _credUsernameController.clear();
      _credPasswordController.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _bearerTokenController.dispose();
    _tokenEndpointController.dispose();
    _credUsernameController.dispose();
    _credPasswordController.dispose();
    super.dispose();
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
        final existing = widget.existingApi;
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

  Future<void> _save() async {
    // Valida el form antes de mandar nada al backend.
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisa los campos marcados en rojo')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final existing = widget.existingApi;
      final api = MonitoredApi(
        id: existing?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        companyId: _selectedCompany!.id!,
        url: _urlController.text.trim(),
        // refreshInterval: _intervalDropdownValue,
      );
      final created = _isEditing
          ? await _monitoredApiService.updateMonitoredApi(api)
          : await _monitoredApiService.createMonitoredApi(api);

      // Las credenciales van a un endpoint aparte, porque necesitan el id
      // del monitoredApi ya creado. Al editar sin tocar esta sección, no se
      // manda nada — así se puede cambiar solo el nombre sin reingresarlas.
      if (_mustSubmitAuth) {
        await _credentialService.setCredentials(
          monitoredApiId: created.id!,
          authType: _authType,
          bearerToken: _authType == AuthType.staticBearer
              ? _bearerTokenController.text.trim()
              : null,
          tokenEndpoint: _authType == AuthType.credentialsLogin
              ? _tokenEndpointController.text.trim()
              : null,
          username: _authType == AuthType.credentialsLogin
              ? _credUsernameController.text.trim()
              : null,
          password: _authType == AuthType.credentialsLogin
              ? _credPasswordController.text
              : null,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'API actualizada' : 'API creada')),
      );
      Navigator.of(context).pop(true); // vuelve a la lista y la refresca
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // void intervalDropdownCallback(String? selectedValue) {
  //   setState(() {
  //     _intervalDropdownValue = selectedValue!;
  //   });
  // }

  /// Contenido de la ventana de auth según el tipo elegido.
  Widget _buildAuthTypeFields() {
    switch (_authType) {
      case AuthType.none:
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
          child: const Text('No requiere más configuración', style: TextStyle(fontSize: AppTextSizes.sm),),
        );
      case AuthType.staticBearer:
        final locked = _fieldLocked(_hasBearerToken);
        return _SecretField(
          controller: _bearerTokenController,
          locked: locked,
          onUnlock: _unlockCredentials,
          decoration: InputDecoration(
            labelText: "Bearer token",
            hintText: "token estático",
            prefixIcon: const Icon(Icons.key),
          ),
          validator: (value) {
            if (_isEditing && !_authTouched) return null;
            return value == null || value.trim().isEmpty
                ? 'Ingresa el bearer token'
                : null;
          },
        );
      case AuthType.credentialsLogin:
        return Column(
          children: [
            TextFormField(
              controller: _tokenEndpointController,
              keyboardType: TextInputType.url,
              style: const TextStyle(fontSize: AppTextSizes.base),
              decoration: const InputDecoration(
                labelText: "Endpoint de login",
                hintText: "https://api.prosembra.com/auth/token",
                prefixIcon: Icon(Icons.link),
              ),
              validator: Validators.url,
              onChanged: (_) {
                if (_isEditing && !_authTouched) _unlockCredentials();
              },
            ),
            const SizedBox(height: 16),
            _SecretField(
              controller: _credUsernameController,
              locked: _fieldLocked(_hasUsername),
              onUnlock: _unlockCredentials,
              decoration: const InputDecoration(
                labelText: "Usuario",
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) {
                if (_isEditing && !_authTouched) return null;
                return Validators.required(v, message: 'Ingresa el usuario');
              },
            ),
            const SizedBox(height: 16),
            _SecretField(
              controller: _credPasswordController,
              locked: _fieldLocked(_hasPassword),
              onUnlock: _unlockCredentials,
              decoration: const InputDecoration(
                labelText: "Contraseña",
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (v) {
                if (_isEditing && !_authTouched) return null;
                return Validators.required(v, message: 'Ingresa la contraseña');
              },
            ),
          ],
        );
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
        appBar: AppBar(title: Text(widget.title)),
        body: SingleChildScrollView(
          // Scrolls when content exceeds the viewport (small screens / keyboard open),
          // which avoids the bottom-overflow stripe.
          child: Column(
            children: [
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text('Información general'),

                      SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          fontSize: AppTextSizes.base,
                        ), // 16 value text
                        decoration: InputDecoration(
                          labelText: "Nombre de la API",
                          hintText: "Prosembra API",
                          prefixIcon: Icon(Icons.api),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Ingresa un nombre' : null;
                        },
                      ),

                      SizedBox(height: 16),

                      AppDropdown<Company>(
                        value: _selectedCompany,
                        items: _companies,
                        itemLabel: (item) => item.name,
                        onChanged: _loadingCompanies
                            ? null
                            : (company) =>
                                  setState(() => _selectedCompany = company),
                        label: "Cliente",
                        prefixIcon: Icons.corporate_fare,
                        validator: (value) =>
                            value == null ? 'Selecciona un cliente' : null,
                        hint: _loadingCompanies
                            ? "Cargando clientes…"
                            : _companiesError
                            ? "Error al cargar"
                            : "Selecciona un cliente",
                      ),

                      SizedBox(height: 16),

                      TextFormField(
                        controller: _urlController,
                        keyboardType: TextInputType.url,
                        style: const TextStyle(
                          fontSize: AppTextSizes.base,
                        ), // 16 value text
                        decoration: InputDecoration(
                          labelText: "URL de la API",
                          hintText: "https://api.prosembra.com",
                          prefixIcon: Icon(Icons.link),
                        ),
                        validator: Validators.url,
                      ),

                      SizedBox(height: 16),

                      TextField(
                        controller: _descriptionController,
                        keyboardType: TextInputType
                            .multiline,
                        minLines: 3,
                        maxLines:
                            5,
                        decoration: InputDecoration(
                          hintText: 'Descripción...',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      // AppDropdown<String>(
                      //   value: _intervalDropdownValue,
                      //   items: refreshApiIntervalOptions,
                      //   itemLabel: (item) => item,
                      //   onChanged: intervalDropdownCallback,
                      //   label: "Intervalo",
                      //   prefixIcon: Icons.timer,
                      //   validator: (value) =>
                      //       value == null ? 'Selecciona un cliente' : null,
                      // ),

                      SizedBox(height: 24),

                      Text('Autorización'),
                      SizedBox(height: 8),

                      _AuthTypeTabs(
                        value: _authType,
                        onChanged: (type) => setState(() {
                          _authType = type;
                          if (_isEditing) _authTouched = true;
                        }),
                      ),

                      SizedBox(height: 16),

                      // Ventana para configurar cada tipo de auth (placeholder por ahora).
                      _AuthTypePanel(child: _buildAuthTypeFields()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingNavFab(
          showMenu: false,
          actions: [
            NavFabAction(
              icon: Icons.check,
              onPressed: _save,
              loading: _saving,
              tooltip: 'Guardar API',
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

/// Campo para un secreto (bearer token, usuario, contraseña).
///
/// Bloqueado: muestra el placeholder de bolitas, de solo lectura, con un
/// ícono de lápiz para desbloquear. Desbloqueado: campo normal, en texto
/// claro (no como password) para que se vea justo lo que se está escribiendo.
class _SecretField extends StatelessWidget {
  const _SecretField({
    required this.controller,
    required this.locked,
    required this.onUnlock,
    required this.decoration,
    required this.validator,
  });

  final TextEditingController controller;
  final bool locked;
  final VoidCallback onUnlock;
  final InputDecoration decoration;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: locked,
      style: const TextStyle(fontSize: AppTextSizes.base),
      decoration: decoration.copyWith(
        suffixIcon: locked
            ? IconButton(
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Cambiar',
                onPressed: onUnlock,
              )
            : null,
      ),
      validator: validator,
    );
  }
}

/// Tabs tipo toggle (segmented control) para elegir el [AuthType].
class _AuthTypeTabs extends StatelessWidget {
  const _AuthTypeTabs({required this.value, required this.onChanged});

  final AuthType value;
  final ValueChanged<AuthType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.gray800,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          for (final type in AuthType.values) ...[
            if (type != AuthType.values.first) const SizedBox(width: 4),
            Expanded(
              child: _AuthTypeTab(
                type: type,
                selected: type == value,
                onTap: () => onChanged(type),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AuthTypeTab extends StatelessWidget {
  const _AuthTypeTab({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final AuthType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary400 : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              type.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSizes.sm,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppColors.textSecondary : AppColors.gray400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ventana donde cada [AuthType] configura sus propios campos.
/// Cada pantalla decide qué mostrar adentro vía [child].
class _AuthTypePanel extends StatelessWidget {
  const _AuthTypePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // if you want to return to the mapping of the code commented below make this a Container again
      width: double.infinity,
      // padding: const EdgeInsets.all(16),
      // decoration: BoxDecoration(
      //   color: AppColors.cardSurface,
      //   borderRadius: BorderRadius.circular(12),
      // ),
      // child: DefaultTextStyle.merge(
      //   style: const TextStyle(
      //     fontSize: AppTextSizes.base,
      //     color: AppColors.onCardMuted,
      //   ),
      // ),
      child: child,
    );
  }
}

/// Botón de acción secundaria con borde punteado y sin relleno.
// class _DashedButton extends StatelessWidget {
//   const _DashedButton({required this.label, required this.onPressed});

//   final String label;
//   final VoidCallback onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: CustomPaint(
//         painter: const _DashedRRectPainter(
//           color: AppColors.gray600,
//           radius: 16,
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: onPressed,
//             borderRadius: BorderRadius.circular(16),
//             child: Center(
//               child: Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: AppTextSizes.base,
//                   color: AppColors.gray400,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

/// Dibuja un rectángulo redondeado con borde punteado (Flutter no lo trae).
// class _DashedRRectPainter extends CustomPainter {
//   const _DashedRRectPainter({required this.color, this.radius = 16});

//   final Color color;
//   final double radius;

//   static const double _dash = 6;
//   static const double _gap = 4;
//   static const double _strokeWidth = 1.5;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = _strokeWidth;

//     final outline = Path()
//       ..addRRect(
//         RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
//       );

//     // Recorre el contorno troceándolo en guiones + espacios.
//     final dashed = Path();
//     for (final metric in outline.computeMetrics()) {
//       double distance = 0;
//       while (distance < metric.length) {
//         final end = (distance + _dash).clamp(0.0, metric.length);
//         dashed.addPath(metric.extractPath(distance, end), Offset.zero);
//         distance += _dash + _gap;
//       }
//     }
//     canvas.drawPath(dashed, paint);
//   }

//   @override
//   bool shouldRepaint(_DashedRRectPainter old) =>
//       old.color != color || old.radius != radius;
// }
