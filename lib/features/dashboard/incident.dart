/// Datos de un incidente activo mostrado en el dashboard.
class Incident {
  const Incident({
    required this.title,
    required this.badge,
    required this.description,
    required this.actions,
    required this.lastRefresh,
  });

  final String title;
  final String badge;
  final String description;
  final List<String> actions;
  final String lastRefresh;
}
