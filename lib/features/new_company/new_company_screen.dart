import 'package:apiland/features/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';

class NewCompanyScreen extends StatefulWidget {
  const NewCompanyScreen({super.key, required this.title});

  final String title;

  @override
  State<NewCompanyScreen> createState() => _NewCompanyScreenState();
}

const List<String> apiTypeList = <String>['Interna', 'Externa'];

class _NewCompanyScreenState extends State<NewCompanyScreen> {
  String _typeDropdownValue = apiTypeList.first;
  void apiTypeDropdownCallback(String? selectedValue) {
    setState(() {
      _typeDropdownValue = selectedValue!;
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
          backgroundColor: Theme.of(context).colorScheme.primary,
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
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          fontSize: AppTextSizes.base,
                        ), // 16 value text
                        decoration: InputDecoration(
                          labelText: "Razón social",
                          hintText: "Friomamut S.A.C.",
                          prefixIcon: Icon(Icons.corporate_fare),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Ingresa un cliente' : null;
                        },
                      ),

                      SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: _typeDropdownValue,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: "Tipo de API",
                          prefixIcon: Icon(Icons.lan),
                        ),
                        items: apiTypeList
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: apiTypeDropdownCallback,
                      ),

                      MaterialButton(
                        minWidth: double.infinity,
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Guardar compañía',
                          style: TextStyle(fontSize: AppTextSizes.base), // 16
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
