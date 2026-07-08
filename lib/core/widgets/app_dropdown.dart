import 'package:flutter/material.dart';

/// Genérico sobre [T]: se le pasa la lista de items y una función [itemLabel]
/// que devuelve el texto a mostrar por item.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.height = 56.0,
  });

  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(T?)? validator;
  final double height;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        style: style,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
          suffixIcon: suffixIcon,
        ),
        items: items
            .map(
              (item) => (DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item), style: style),
              )),
            )
            .toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
