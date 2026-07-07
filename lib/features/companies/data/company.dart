/// Modelo de una compañía, con la misma estructura que devuelve la API:
/// `{ id, name, tipoCliente }`.
class Company {
  const Company({this.id, required this.name, required this.tipoCliente});

  final int? id;
  final String name;
  final String tipoCliente;

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int?,
      name: (json['name'] ?? '') as String,
      tipoCliente: (json['tipoCliente'] ?? '') as String,
    );
  }

  /// Para el POST no mandamos el id (lo genera el backend).
  Map<String, dynamic> toJson() => {
    'name': name,
    'tipoCliente': tipoCliente,
  };
}
