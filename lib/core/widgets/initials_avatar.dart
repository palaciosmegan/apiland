import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';

/// Avatar circular con las iniciales de un nombre y un color propio derivado
/// del mismo (el mismo nombre siempre produce el mismo color).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.radius = 20});

  final String name;
  final double radius;

  static const List<Color> _palette = [
    AppColors.primary300,
    AppColors.info300,
    AppColors.green300,
    AppColors.orange300,
    AppColors.accent,
  ];

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final w = parts.first;
      return (w.length >= 2 ? w.substring(0, 2) : w).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Color get _color => _palette[name.hashCode.abs() % _palette.length];

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _color,
      child: Text(
        _initials,
        style: const TextStyle(
          fontSize: AppTextSizes.sm,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
