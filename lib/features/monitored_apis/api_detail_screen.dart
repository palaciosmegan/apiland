import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/widgets/app_dropdown.dart';
import 'package:apiland/core/widgets/dashed_button.dart';
import 'package:apiland/core/widgets/entity_avatar.dart';
import 'package:apiland/core/widgets/error_state.dart';
import 'package:apiland/features/companies/data/company.dart';
import 'package:apiland/features/monitored_apis/data/api_credentials.dart';
import 'package:apiland/features/monitored_apis/data/api_credentials_service.dart';
import 'package:apiland/features/monitored_apis/data/auth_type.dart';
import 'package:apiland/features/monitored_apis/data/endpoint.dart';
import 'package:apiland/features/monitored_apis/data/endpoint_service.dart';
import 'package:apiland/features/monitored_apis/data/monitored_api.dart';

/// Opciones de intervalo de chequeo (mismo texto que usa MonitoredApi).
const List<String> checkIntervalOptions = <String>['1 hora', '2 horas', '3 horas'];

class ApiDetailScreen extends StatefulWidget {
  const ApiDetailScreen({super.key, required this.api, this.company});

  final MonitoredApi api;
  final Company? company;

  @override
  State<ApiDetailScreen> createState() => _ApiDetailScreenState();
}

class _ApiDetailScreenState extends State<ApiDetailScreen> {
  final ApiCredentialsService _credentialService = ApiCredentialsService();
  final EndpointService _endpointService = EndpointService();

  ApiCredentials? _credential;
  bool _loadingCredential = true;

  List<Endpoint> _endpoints = const [];
  bool _loadingEndpoints = true;
  Object? _endpointsError;

  @override
  void initState() {
    super.initState();
    _loadCredential();
    _loadEndpoints();
  }

  Future<void> _loadCredential() async {
    final id = widget.api.id;
    if (id == null) {
      setState(() => _loadingCredential = false);
      return;
    }
    try {
      final credential = await _credentialService.getByMonitoredApiId(id);
      if (!mounted) return;
      setState(() {
        _credential = credential;
        _loadingCredential = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingCredential = false);
    }
  }

  Future<void> _loadEndpoints() async {
    final id = widget.api.id;
    if (id == null) {
      setState(() => _loadingEndpoints = false);
      return;
    }
    setState(() {
      _loadingEndpoints = true;
      _endpointsError = null;
    });
    try {
      final list = await _endpointService.getAllEndpointsFromApi(id);
      if (!mounted) return;
      setState(() {
        _endpoints = list;
        _loadingEndpoints = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _endpointsError = e;
        _loadingEndpoints = false;
      });
    }
  }

  Future<void> _addEndpoint() async {
    final parentApiId = widget.api.id;
    if (parentApiId == null) return;
    final draft = await showModalBottomSheet<Endpoint>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEndpointSheet(
        parentUrl: widget.api.url,
        parentApiId: parentApiId,
      ),
    );
    if (draft == null) return;
    try {
      final created = await _endpointService.createEndpoint(draft);
      if (!mounted) return;
      setState(() => _endpoints = [..._endpoints, created]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }

  Future<void> _editEndpoint(int index) async {
    final parentApiId = widget.api.id;
    if (parentApiId == null) return;
    final draft = await showModalBottomSheet<Endpoint>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddEndpointSheet(
        parentUrl: widget.api.url,
        parentApiId: parentApiId,
        initial: _endpoints[index],
      ),
    );
    if (draft == null) return;
    try {
      final updated = await _endpointService.updateEndpoint(draft);
      if (!mounted) return;
      setState(() {
        final next = [..._endpoints];
        next[index] = updated;
        _endpoints = next;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    final company = widget.company;
    return Scaffold(
      appBar: AppBar(title: Text(api.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(api: api, company: company),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'General',
              children: [
                _InfoRow(label: 'URL', value: api.url, mono: true),
                if (api.description.trim().isNotEmpty)
                  _InfoRow(label: 'Descripción', value: api.description),
                _InfoRow(label: 'Cliente', value: company?.name ?? '—'),
              ],
            ),
            const SizedBox(height: 16),
            _AuthSectionCard(loading: _loadingCredential, credential: _credential),
            const SizedBox(height: 24),
            const _SectionLabel('ENDPOINTS'),
            const SizedBox(height: 12),
            if (_loadingEndpoints)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_endpointsError != null)
              ErrorState(
                title: 'No se pudieron traer los endpoints',
                message: apiErrorMessage(_endpointsError!),
                onRetry: _loadEndpoints,
              )
            else ...[
              for (var i = 0; i < _endpoints.length; i++) ...[
                _EndpointCard(
                  endpoint: _endpoints[i],
                  onEdit: () => _editEndpoint(i),
                ),
                const SizedBox(height: 12),
              ],
              DashedButton(label: 'Añadir endpoint', onPressed: _addEndpoint),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header: logo de la API + nombre + logo/nombre de la compañía.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.api, required this.company});

  final MonitoredApi api;
  final Company? company;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary400.withValues(alpha: 0.16),
            AppColors.cardSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary400.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              EntityAvatar(
                name: api.name,
                imageUrl: api.pictureUrl,
                shape: AvatarShape.roundedSquare,
                size: 56,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  api.name,
                  style: const TextStyle(
                    fontSize: AppTextSizes.xl,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textStandout,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              EntityAvatar(
                name: company?.name ?? '?',
                imageUrl: company?.pictureUrl,
                size: 24,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  company?.name ?? 'Sin cliente asignado',
                  style: const TextStyle(
                    fontSize: AppTextSizes.sm,
                    color: AppColors.onCardMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: AppTextSizes.xs,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1.1,
      ),
    );
  }
}

/// Card genérica con título arriba (fuera de la card) + filas adentro.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(title.toUpperCase()),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: AppColors.gray700.withValues(alpha: 0.5)),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.mono = false,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTextSizes.sm,
              color: AppColors.onCardMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  valueWidget ??
                  Text(
                    value ?? '—',
                    textAlign: TextAlign.right,
                    style: mono
                        ? GoogleFonts.robotoMono(
                            fontSize: AppTextSizes.sm,
                            color: AppColors.onCard,
                          )
                        : const TextStyle(
                            fontSize: AppTextSizes.sm,
                            color: AppColors.onCard,
                            fontWeight: FontWeight.w500,
                          ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Detalles de autorización: tipo elegido + qué secretos están configurados
/// (nunca el valor real, el backend no lo devuelve).
class _AuthSectionCard extends StatelessWidget {
  const _AuthSectionCard({required this.loading, required this.credential});

  final bool loading;
  final ApiCredentials? credential;

  Color _authTypeColor(AuthType type) => switch (type) {
    AuthType.none => AppColors.gray500,
    AuthType.staticBearer => AppColors.primary400,
    AuthType.credentialsLogin => AppColors.info300,
  };

  @override
  Widget build(BuildContext context) {
    final authType = credential?.authType ?? AuthType.none;
    return _SectionCard(
      title: 'Autorización',
      children: [
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else ...[
          _InfoRow(
            label: 'Tipo',
            valueWidget: _Chip(
              text: authType.label,
              color: _authTypeColor(authType),
            ),
          ),
          if (authType == AuthType.staticBearer)
            _InfoRow(
              label: 'Bearer token',
              valueWidget: _ConfiguredChip(configured: credential?.hasBearerToken ?? false),
            ),
          if (authType == AuthType.credentialsLogin) ...[
            _InfoRow(
              label: 'Endpoint de login',
              value: credential?.tokenEndpoint,
              mono: true,
            ),
            _InfoRow(
              label: 'Usuario',
              valueWidget: _ConfiguredChip(configured: credential?.hasUsername ?? false),
            ),
            _InfoRow(
              label: 'Contraseña',
              valueWidget: _ConfiguredChip(configured: credential?.hasPassword ?? false),
            ),
          ],
          if (authType == AuthType.none)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Esta API no requiere autenticación.',
                style: TextStyle(fontSize: AppTextSizes.sm, color: AppColors.onCardMuted),
              ),
            ),
        ],
      ],
    );
  }
}

class _ConfiguredChip extends StatelessWidget {
  const _ConfiguredChip({required this.configured});

  final bool configured;

  @override
  Widget build(BuildContext context) {
    final color = configured ? AppColors.green400 : AppColors.gray500;
    return _Chip(
      text: configured ? 'Configurado' : 'No configurado',
      color: color,
      icon: configured ? Icons.check_circle : Icons.remove_circle_outline,
    );
  }
}

/// Pill translúcida reutilizable para valores cortos (tipo, status, método).
class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: AppTextSizes.xs,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

Color _methodColor(String method) => switch (method.toUpperCase()) {
  'GET' => AppColors.green400,
  'POST' => AppColors.primary400,
  'PUT' => AppColors.orange300,
  'PATCH' => AppColors.accent,
  'DELETE' => AppColors.error,
  'HEAD' => AppColors.gray400,
  _ => AppColors.info300,
};

class _EndpointCard extends StatelessWidget {
  const _EndpointCard({required this.endpoint, required this.onEdit});

  final Endpoint endpoint;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 4),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  endpoint.name,
                  style: const TextStyle(
                    fontSize: AppTextSizes.base,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onCard,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: AppColors.onCardMuted,
                tooltip: 'Editar',
                onPressed: onEdit,
              ),
            ],
          ),
          _InfoRow(label: 'URL', value: endpoint.url, mono: true),
          _InfoRow(
            label: 'Método',
            valueWidget: _Chip(
              text: endpoint.method.toUpperCase(),
              color: _methodColor(endpoint.method),
            ),
          ),
          _InfoRow(label: 'Intervalo', value: endpoint.checkInterval),
          _InfoRow(
            label: 'Verificación',
            valueWidget: _Chip(
              text: endpoint.isManualOnly ? 'Manual' : 'Automática',
              color: endpoint.isManualOnly ? AppColors.gray500 : AppColors.green400,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Bottom sheet para agregar o editar un endpoint.
class _AddEndpointSheet extends StatefulWidget {
  const _AddEndpointSheet({
    required this.parentUrl,
    required this.parentApiId,
    this.initial,
  });

  /// URL base de la API padre: el endpoint solo agrega el path, no puede
  /// tocar esta parte.
  final String parentUrl;
  final int parentApiId;

  /// Si viene seteado, el sheet edita este endpoint en vez de crear uno.
  final Endpoint? initial;

  @override
  State<_AddEndpointSheet> createState() => _AddEndpointSheetState();
}

class _AddEndpointSheetState extends State<_AddEndpointSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.initial?.name);
  // Solo el path: la base (widget.parentUrl) va fija como prefixText.
  late final _pathController = TextEditingController(text: _initialPath);
  late String _method = widget.initial?.method.toUpperCase() ?? 'GET';
  late String _checkInterval =
      checkIntervalOptions.contains(widget.initial?.checkInterval)
      ? widget.initial!.checkInterval
      : checkIntervalOptions.first;
  late bool _isManualOnly = widget.initial?.isManualOnly ?? false;

  // Todavía no existen en el backend (Endpoint no los tiene) — se muestran
  // pero no se mandan, pendiente de definir si esto va o no.
  final _statusController = TextEditingController(text: '200');
  final _timeoutController = TextEditingController(text: '5');

  static const _methods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD'];

  bool get _isEditing => widget.initial != null;

  /// Le quita la base al url completo del endpoint (si existe) para dejar
  /// solo la parte editable.
  String get _initialPath {
    final url = widget.initial?.url;
    if (url == null) return '';
    return url.startsWith(widget.parentUrl)
        ? url.substring(widget.parentUrl.length)
        : url;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _statusController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Endpoint(
        id: widget.initial?.id,
        name: _nameController.text.trim(),
        method: _method,
        url: '${widget.parentUrl}${_pathController.text.trim()}',
        checkInterval: _checkInterval,
        parentApiId: widget.parentApiId,
        isManualOnly: _isManualOnly,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.gray600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  _isEditing ? 'Editar endpoint' : 'Nuevo endpoint',
                  style: const TextStyle(
                    fontSize: AppTextSizes.lg,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textStandout,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: AppTextSizes.base),
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Health check',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Ingresa un nombre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pathController,
                  keyboardType: TextInputType.url,
                  style: const TextStyle(fontSize: AppTextSizes.base),
                  decoration: InputDecoration(
                    labelText: 'URL',
                    hintText: '/health',
                    prefixIcon: const Icon(Icons.link),
                    // Base de la API padre: se ve, pero no se puede editar.
                    prefixText: widget.parentUrl,
                    prefixStyle: const TextStyle(
                      fontSize: AppTextSizes.base,
                      color: AppColors.gray400,
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Ingresa el path' : null,
                ),
                const SizedBox(height: 16),
                AppDropdown<String>(
                  value: _method,
                  items: _methods,
                  itemLabel: (m) => m,
                  onChanged: (m) => setState(() => _method = m ?? 'GET'),
                  label: 'Método',
                  prefixIcon: Icons.swap_calls,
                ),
                const SizedBox(height: 16),
                AppDropdown<String>(
                  value: _checkInterval,
                  items: checkIntervalOptions,
                  itemLabel: (i) => i,
                  onChanged: (i) =>
                      setState(() => _checkInterval = i ?? checkIntervalOptions.first),
                  label: 'Intervalo de chequeo',
                  prefixIcon: Icons.schedule,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _statusController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: AppTextSizes.base),
                        decoration: const InputDecoration(
                          labelText: 'Status esperado',
                          prefixIcon: Icon(Icons.check_circle_outline),
                        ),
                        validator: (v) =>
                            int.tryParse(v?.trim() ?? '') == null
                            ? 'Número inválido'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _timeoutController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: AppTextSizes.base),
                        decoration: const InputDecoration(
                          labelText: 'Timeout (s)',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                        validator: (v) =>
                            int.tryParse(v?.trim() ?? '') == null
                            ? 'Número inválido'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isManualOnly,
                  onChanged: (v) => setState(() => _isManualOnly = v),
                  title: const Text(
                    'Solo verificación manual',
                    style: TextStyle(fontSize: AppTextSizes.sm, color: AppColors.textPrimary),
                  ),
                  subtitle: const Text(
                    'No se chequea automáticamente en el intervalo',
                    style: TextStyle(fontSize: AppTextSizes.xs, color: AppColors.gray400),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(_isEditing ? 'Guardar cambios' : 'Añadir endpoint'),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
