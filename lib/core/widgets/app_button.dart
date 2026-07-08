import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';

/// Botones estándar de la app. Los colores/estilo base vienen de los
/// *ButtonTheme del tema; estos widgets solo eligen la variante y añaden
/// comodidades (full-width, loading).

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}

/// Acción primaria (relleno).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const _ButtonSpinner(color: AppColors.textSecondary)
          : Text(label),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Acción secundaria (outline).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(onPressed: onPressed, child: Text(label));
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Acción destructiva (ej. cerrar sesión): tinte rojo suave + texto rojo.
class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.error.withValues(alpha: 0.12),
        foregroundColor: AppColors.error,
      ),
      child: Text(label),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
