import 'package:apiland/features/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
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
  final CompanyService _companyService = CompanyService();

  String _intervalDropdownValue = refreshApiIntervalOptions.first;

  List<Company> _companies = [];
  Company? _selectedCompany;
  bool _loadingCompanies = true;
  bool _companiesError = false;

  @override
  void initState() {
    super.initState();
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
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingCompanies = false;
        _companiesError = true;
      });
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
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          // Scrolls when content exceeds the viewport (small screens / keyboard open),
          // which avoids the bottom-overflow stripe.
          child: Column(
            children: [
              SizedBox(height: 64),

              // Text(
              //   'Iniciar sesión',
              //   style: TextStyle(
              //     fontSize: AppTextSizes.xl4, // 24 — top of the type scale
              //     fontWeight: FontWeight.w600,
              //     color: AppColors.gray50,
              //   ),
              // ),
              SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  child: Column(
                    children: [
                      Text('Información general'),

                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: AppTextSizes.base,
                        ), // 16 value text
                        decoration: InputDecoration(
                          labelText: "Nombre de la API",
                          hintText: "Prosembra API",
                          prefixIcon: Icon(Icons.api),
                        ),
                        onChanged: (String value) {},
                        validator: (value) {
                          return value!.isEmpty ? 'Ingresa un nombre' : null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Cliente: dropdown poblado con el GET de compañías.
                      DropdownButtonFormField<Company>(
                        initialValue: _selectedCompany,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Cliente",
                          hintText: _loadingCompanies
                              ? "Cargando compañías…"
                              : _companiesError
                              ? "Error al cargar (toca refrescar)"
                              : "Selecciona un cliente",
                          prefixIcon: const Icon(Icons.corporate_fare),
                          suffixIcon: _loadingCompanies
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : _companiesError
                              ? IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _loadCompanies,
                                )
                              : null,
                        ),
                        items: _companies
                            .map(
                              (c) => DropdownMenuItem<Company>(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        // Deshabilitado mientras carga.
                        onChanged: _loadingCompanies
                            ? null
                            : (company) =>
                                  setState(() => _selectedCompany = company),
                        validator: (value) =>
                            value == null ? 'Selecciona un cliente' : null,
                      ),

                      SizedBox(height: 16),

                      TextFormField(
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          fontSize: AppTextSizes.base,
                        ), // 16 value text
                        decoration: InputDecoration(
                          labelText: "URL de la API",
                          hintText: "https://api.prosembra.com",
                          prefixIcon: Icon(Icons.link),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Ingresa la url' : null;
                        },
                      ),

                      SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _intervalDropdownValue,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: "Intervalo",
                          prefixIcon: Icon(Icons.timer),
                        ),
                        items: refreshApiIntervalOptions
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: intervalDropdownCallback,
                      ),

                      SizedBox(height: 24),

                      Text('Acceso'),
                      Text('Endpoints'),

                      // Acción secundaria: borde punteado, sin relleno.
                      _DashedButton(
                        label: 'Añadir endpoint',
                        onPressed: () {},
                      ),

                      SizedBox(height: 16),

                      // Acción primaria: relleno morado tipo píldora.
                      SizedBox(
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const DashboardScreen(),
                              ),
                            );
                          },
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          disabledColor: AppColors.gray700,
                          disabledTextColor: AppColors.gray400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Text(
                            'Guardar API',
                            style: TextStyle(fontSize: AppTextSizes.base), // 16
                          ),
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
        painter: const _DashedRRectPainter(color: AppColors.gray600, radius: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
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
  const _DashedRRectPainter({required this.color, this.radius = 12});

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
