import 'package:flutter/material.dart';
import 'package:apiland/constants/theme/app_theme.dart';
import 'package:apiland/core/auth/session.dart';
import 'package:apiland/core/auth/user_role.dart';

/// FAB flotante (abajo a la derecha) que abre un drawer inferior animado con la
/// navegación principal de la app.
///
/// Sin GoRouter: navega con [Navigator] usando rutas con nombre. Las rutas que
/// todavía no tienen pantalla registrada muestran un aviso "próximamente".
class FloatingNavFab extends StatelessWidget {
  const FloatingNavFab({super.key, required this.currentRoute});

  /// Ruta actual (ej. '/dashboard'), para resaltar el item activo.
  final String currentRoute;

  /// Rutas que ya tienen pantalla registrada en el MaterialApp.
  static const Set<String> _implementedRoutes = {
    '/dashboard',
    '/services',
    '/companies',
    '/users',
  };

  static const List<_NavItem> _items = [
    _NavItem(Icons.home_outlined, 'Dashboard', '/dashboard'),
    _NavItem(Icons.history, 'Log', '/log'),
    _NavItem(
      Icons.api_outlined,
      'APIs',
      '/services',
      children: [
        _NavItem(null, 'Todas las APIs', '/services'),
      ],
    ),
    _NavItem(Icons.settings_outlined, 'Ajustes', '/settings'),
    _NavItem(Icons.groups_2, 'Usuarios', '/users', minRole: UserRole.root),
    _NavItem(Icons.business, 'Compañías', '/companies', minRole: UserRole.root),
  ];

  void _openDrawer(BuildContext context) {
    // Filtra los links según el rol de la sesión (jerarquía por rank).
    final role = Session.role;
    final visibleItems = _items
        .where((item) => role.rank >= item.minRole.rank)
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _NavDrawer(
        currentRoute: currentRoute,
        items: visibleItems,
        onSelect: (route) => _handleSelect(context, route),
      ),
    );
  }

  void _handleSelect(BuildContext context, String route) {
    // El drawer siempre se cierra primero.
    Navigator.pop(context);
    // Si ya estamos en la ruta, no navegamos (evita duplicar la ruta).
    if (route == currentRoute) return;
    if (_implementedRoutes.contains(route)) {
      Navigator.pushNamed(context, route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$route: próximamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Padding con el safe area inferior para no solaparse con la barra del sistema.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: FloatingActionButton.small(
        onPressed: () => _openDrawer(context),
        child: const Icon(Icons.menu),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(
    this.icon,
    this.label,
    this.route, {
    this.children = const [],
    this.minRole = UserRole.user,
  });

  final IconData? icon;
  final String label;
  final String route;

  /// Subitems. Si no está vacío, el tile es expandible (muestra chevron).
  final List<_NavItem> children;

  /// Rol mínimo para ver este link. Se compara por `rank`.
  final UserRole minRole;
}

/// Contenido del drawer inferior, con entrada animada (slide-up + fade).
class _NavDrawer extends StatefulWidget {
  const _NavDrawer({
    required this.currentRoute,
    required this.items,
    required this.onSelect,
  });

  final String currentRoute;
  final List<_NavItem> items;
  final ValueChanged<String> onSelect;

  @override
  State<_NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<_NavDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.15),
    end: Offset.zero,
  ).animate(_curve);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: _slide,
        // Material (no Container) para que los ListTile pinten su ink/fondo
        // correctamente sobre esta superficie.
        child: Material(
          color: colors.surface,
          clipBehavior: Clip.antiAlias,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra superior (handle) para arrastrar.
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.items.map((item) => _NavTile(
                        item: item,
                        currentRoute: widget.currentRoute,
                        onSelect: widget.onSelect,
                      )),
                  // Safe area inferior.
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.currentRoute,
    required this.onSelect,
  });

  final _NavItem item;
  final String currentRoute;
  final ValueChanged<String> onSelect;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasChildren = item.children.isNotEmpty;
    return Column(
      children: [
        _row(
          context,
          icon: item.icon,
          label: item.label,
          active: item.route == widget.currentRoute,
          // Solo los items con hijos muestran chevron (rota ▶ → ▼ al abrir).
          trailing: hasChildren
              ? AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.chevron_right,
                    color: item.route == widget.currentRoute
                        ? AppColors.success
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          onTap: hasChildren
              ? () => setState(() => _expanded = !_expanded)
              : () => widget.onSelect(item.route),
        ),
        // Subitems (indentados): se despliegan suave con AnimatedSize.
        if (hasChildren)
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              opacity: _expanded ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Column(
                        children: item.children
                            .map((child) => _row(
                                  context,
                                  icon: child.icon,
                                  label: child.label,
                                  active: child.route == widget.currentRoute,
                                  onTap: () => widget.onSelect(child.route),
                                ))
                            .toList(),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ),
      ],
    );
  }

  Widget _row(
    BuildContext context, {
    required IconData? icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final colors = Theme.of(context).colorScheme;
    // Activo: texto/icono en primaryLight. Inactivo: color de texto secundario.
    final color = active ? AppColors.primary : colors.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        // El fondo va en el propio ListTile (tileColor + shape), no en un
        // Container con decoration — así el ink/splash es visible.
        tileColor: active ? colors.primary.withValues(alpha: 0.1) : null,
        leading: icon == null ? null : Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
