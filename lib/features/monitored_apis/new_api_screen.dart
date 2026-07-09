import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/utils/validators.dart';
import 'package:apiland/core/widgets/app_dropdown.dart';
import 'package:apiland/features/monitored_apis/data/monitored_api.dart';
import 'package:apiland/features/monitored_apis/data/monitored_api_service.dart';
import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/widgets/app_button.dart';
import 'package:apiland/features/companies/data/company.dart';
import 'package:apiland/features/companies/data/company_service.dart';

class NewApiScreen extends StatefulWidget {
  const NewApiScreen({super.key, required this.title});

  final String title;

  @override
  State<NewApiScreen> createState() => _NewApiScreenState();
}

const List<String> refreshApiIntervalOptions = <String>[
  '1 hora',
  '2 horas',
  '3 horas',
];

class _NewApiScreenState extends State<NewApiScreen> {
  final _formKey = GlobalKey<FormState>();
  final CompanyService _companyService = CompanyService();
  final MonitoredApiService _monitoredApiService = MonitoredApiService();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  String _intervalDropdownValue = refreshApiIntervalOptions.first;
  bool _saving = false;

  List<Company> _companies = [];
  Company? _selectedCompany;
  bool _loadingCompanies = true;
  bool _companiesError = false;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await _monitoredApiService.createMonitoredApi(
        MonitoredApi(
          name: _nameController.text.trim(),
          companyId: _selectedCompany!.id!,
          url: _urlController.text.trim(),
          // refreshInterval: _intervalDropdownValue,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('API creada')));
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

  void intervalDropdownCallback(String? selectedValue) {
    setState(() {
      _intervalDropdownValue = selectedValue!;
    });
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

                      AppDropdown<String>(
                        value: _intervalDropdownValue,
                        items: refreshApiIntervalOptions,
                        itemLabel: (item) => item,
                        onChanged: intervalDropdownCallback,
                        label: "Intervalo",
                        prefixIcon: Icons.timer,
                        validator: (value) =>
                            value == null ? 'Selecciona un cliente' : null,
                      ),

                      SizedBox(height: 24),

                      Text('Acceso'),
                      Text('Endpoints'),

                      // Acción secundaria: borde punteado, sin relleno.
                      _DashedButton(label: 'Añadir endpoint', onPressed: () {}),

                      SizedBox(height: 16),

                      // Acción primaria.
                      PrimaryButton(
                        label: 'Guardar API',
                        loading: _saving,
                        onPressed: _save,
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

/// Botón de acción secundaria con borde punteado y sin relleno.
class _DashedButton extends StatelessWidget {
  const _DashedButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: CustomPaint(
        painter: const _DashedRRectPainter(
          color: AppColors.gray600,
          radius: 16,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: AppTextSizes.base,
                  color: AppColors.gray400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dibuja un rectángulo redondeado con borde punteado (Flutter no lo trae).
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, this.radius = 16});

  final Color color;
  final double radius;

  static const double _dash = 6;
  static const double _gap = 4;
  static const double _strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    // Recorre el contorno troceándolo en guiones + espacios.
    final dashed = Path();
    for (final metric in outline.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + _dash).clamp(0.0, metric.length);
        dashed.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += _dash + _gap;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}
