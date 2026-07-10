import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';

/// Envuelve un item de lista para que el swipe hacia la izquierda dispare
/// [onEdit] (ej. navegar al form de edición). Nunca remueve el item: el
/// swipe siempre "rebota" de vuelta después de [onEdit].
class SwipeToEdit extends StatelessWidget {
  const SwipeToEdit({
    super.key,
    required this.itemKey,
    required this.onEdit,
    required this.child,
    this.borderRadius = 16,
  });

  /// Identifica el item (ej. el id) para que Dismissible no confunda
  /// posiciones al reordenarse la lista.
  final Object itemKey;
  final Future<void> Function() onEdit;
  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(itemKey),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await onEdit();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.primary400,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Icon(Icons.edit, color: AppColors.textSecondary),
      ),
      child: child,
    );
  }
}
