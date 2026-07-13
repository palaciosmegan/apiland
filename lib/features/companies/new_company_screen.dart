import 'package:apiland/core/utils/validators.dart';
import 'package:apiland/core/widgets/app_dropdown.dart';
import 'package:apiland/core/widgets/entity_avatar.dart';
import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/network/api_error.dart';
import 'package:apiland/core/widgets/floating_nav_fab.dart';
import 'package:apiland/features/companies/data/company.dart';
import 'package:apiland/features/companies/data/company_service.dart';

class NewCompanyScreen extends StatefulWidget {
  const NewCompanyScreen({super.key, required this.title});

  final String title;

  @override
  State<NewCompanyScreen> createState() => _NewCompanyScreenState();
}

const List<String> apiTypeList = <String>['Interna', 'Externa'];

class _NewCompanyScreenState extends State<NewCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pictureUrlController = TextEditingController();
  final CompanyService _service = CompanyService();

  String _typeDropdownValue = apiTypeList.first;
  bool _saving = false;

  void apiTypeDropdownCallback(String? selectedValue) {
    setState(() {
      _typeDropdownValue = selectedValue!;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pictureUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // Valida el form antes de mandar nada al backend.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final pictureUrl = _pictureUrlController.text.trim();
      await _service.createCompany(
        Company(
          name: _nameController.text.trim(),
          tipoCliente: _typeDropdownValue,
          pictureUrl: pictureUrl.isEmpty ? null : pictureUrl,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Compañía creada')));
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
                          labelText: "Razón social",
                          hintText: "Friomamut S.A.C.",
                          prefixIcon: Icon(Icons.corporate_fare),
                        ),
                        validator: (value) {
                          return value == null || value.trim().isEmpty
                              ? 'Ingresa la razón social'
                              : null;
                        },
                      ),

                      SizedBox(height: 16),

                      AppDropdown<String>(
                        value: _typeDropdownValue,
                        items: apiTypeList,
                        itemLabel: (item) => item,
                        onChanged: apiTypeDropdownCallback,
                        label: "Tipo",
                        prefixIcon: Icons.lan,
                      ),

                      SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: EntityAvatar(
                              name: _nameController.text,
                              imageUrl: _pictureUrlController.text,
                              size: 48,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _pictureUrlController,
                              keyboardType: TextInputType.url,
                              style: const TextStyle(fontSize: AppTextSizes.base),
                              decoration: const InputDecoration(
                                labelText: "URL del logo",
                                hintText: "https://.../logo.png",
                                prefixIcon: Icon(Icons.image_outlined),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? null
                                  : Validators.url(v),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
              tooltip: 'Guardar compañía',
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
