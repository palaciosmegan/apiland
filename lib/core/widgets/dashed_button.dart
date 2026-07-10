import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';

/// Botón de acción secundaria con borde punteado y sin relleno
/// (ej. "Añadir endpoint").
class DashedButton extends StatelessWidget {
  const DashedButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: CustomPaint(
        painter: const _DashedRRectPainter(color: AppColors.gray600, radius: 16),
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
