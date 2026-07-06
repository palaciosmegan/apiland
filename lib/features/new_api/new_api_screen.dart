import 'package:apiland/features/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';

class NewApiScreen extends StatefulWidget {
  const NewApiScreen({super.key, required this.title});

  final String title;

  @override
  State<NewApiScreen> createState() => _NewApiScreenState();
}

const List<String> apiTypeList = <String>['Interna', 'Externa'];
const List<String> refreshApiIntervalOptions = <String>[
  '1 hora',
  '2 horas',
  '3 horas',
];

class _NewApiScreenState extends State<NewApiScreen> {
  String _typeDropdownValue = apiTypeList.first;
  String _intervalDropdownValue = refreshApiIntervalOptions.first;
  void apiTypeDropdownCallback(String? selectedValue) {
    setState(() {
      _typeDropdownValue = selectedValue!;
    });
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

                      TextFormField(
                        keyboardType: TextInputType.text,
                        style: const TextStyle(
                          fontSize: AppTextSizes.base,
                        ), // 16 value text
                        decoration: InputDecoration(
                          labelText: "Cliente",
                          hintText: "Friomamut S.A.C.",
                          prefixIcon: Icon(Icons.corporate_fare),
                        ),
                        validator: (value) {
                          return value!.isEmpty ? 'Ingresa un cliente' : null;
                        },
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

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
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
                          ),

                          SizedBox(width: 16),

                          Expanded(
                            child: DropdownButtonFormField<String>(
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
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      Text('Acceso'),
                      Text('Endpoints'),

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
                          'Añadir endpoint',
                          style: TextStyle(fontSize: AppTextSizes.base), // 16
                        ),
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
                          'Crear API',
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
