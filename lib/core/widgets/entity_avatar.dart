import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/widgets/initials_avatar.dart';

enum AvatarShape { circle, roundedSquare }

/// Logo de una entidad (API, compañía): si [imageUrl] existe lo muestra, si
/// no o falla la carga cae a las iniciales de [name].
class EntityAvatar extends StatelessWidget {
  const EntityAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
    this.shape = AvatarShape.circle,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final AvatarShape shape;

  BorderRadius get _radius => shape == AvatarShape.circle
      ? BorderRadius.circular(size / 2)
      : BorderRadius.circular(size * 0.28);

  Widget _fallback() => shape == AvatarShape.circle
      ? InitialsAvatar(name: name, radius: size / 2)
      : _SquareInitials(name: name, size: size);

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return _fallback();
    return ClipRRect(
      borderRadius: _radius,
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      ),
    );
  }
}

/// Versión cuadrada-redondeada de las iniciales, para logos tipo ícono
/// de app (a diferencia del `CircleAvatar` de [InitialsAvatar]).
class _SquareInitials extends StatelessWidget {
  const _SquareInitials({required this.name, required this.size});

  final String name;
  final double size;

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
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}
