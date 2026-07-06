import 'package:flutter/material.dart';

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
  static const Set<String> _implementedRoutes = {'/dashboard'};

  static const List<_NavItem> _items = [
    _NavItem(Icons.home_outlined, 'Dashboard', '/dashboard'),
    _NavItem(Icons.history, 'Log', '/log'),
    _NavItem(Icons.api_outlined, 'APIs', '/services'),
    _NavItem(Icons.settings_outlined, 'Ajustes', '/settings'),
    _NavItem(Icons.groups_2, 'Usuarios', '/users'),
  ];

  static const _NavItem _settingsItem = _NavItem(
    Icons.logout_outlined,
    'Cerrar sesión',
    '/logout',
  );

  void _openDrawer(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _NavDrawer(
        currentRoute: currentRoute,
        items: _items,
        settingsItem: _settingsItem,
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
      Navigator.pushReplacementNamed(context, route);
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
  const _NavItem(this.icon, this.label, this.route);

  final IconData icon;
  final String label;
  final String route;
}

/// Contenido del drawer inferior, con entrada animada (slide-up + fade).
class _NavDrawer extends StatefulWidget {
  const _NavDrawer({
    required this.currentRoute,
    required this.items,
    required this.settingsItem,
    required this.onSelect,
  });

  final String currentRoute;
  final List<_NavItem> items;
  final _NavItem settingsItem;
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
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
                    active: item.route == widget.currentRoute,
                    onTap: () => widget.onSelect(item.route),
                  )),
              const Divider(height: 24),
              _NavTile(
                item: widget.settingsItem,
                active: widget.settingsItem.route == widget.currentRoute,
                onTap: () => widget.onSelect(widget.settingsItem.route),
              ),
              // Safe area inferior.
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Activo: color primario. Inactivo: color de texto secundario.
    final color = active ? colors.primary : colors.onSurfaceVariant;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: active ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(item.icon, color: color),
        title: Text(
          item.label,
          style: TextStyle(
            color: color,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
