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

  /// URL: obligatoria + esquema http/https/ftp y con host (como pide el backend).
  static String? url(String? value) {
    final url = value?.trim() ?? '';
    if (url.isEmpty) return 'Ingresa la URL';
    final uri = Uri.tryParse(url);
    const validSchemes = {'http', 'https', 'ftp'};
    if (uri == null || !uri.hasAuthority || !validSchemes.contains(uri.scheme)) {
      return 'Ingresa una URL válida (http, https o ftp)';
    }
    return null;
  }
}
