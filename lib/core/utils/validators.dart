/// Validadores reutilizables para formularios.
///
/// Cada uno devuelve `null` si es válido, o un mensaje de error si no.
/// Compatible con el `validator:` de los TextFormField.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  /// Campo obligatorio (no vacío tras trim).
  static String? required(
    String? value, {
    String message = 'Este campo es obligatorio',
  }) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  /// Email: obligatorio + formato básico `algo@algo.algo`.
  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Ingresa tu correo';
    if (!_emailRegex.hasMatch(email)) return '¡Ese no es un email válido!';
    return null;
  }
}
