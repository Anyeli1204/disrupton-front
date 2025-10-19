/// Validadores reutilizables para formularios
class Validators {
  Validators._(); // Constructor privado

  /// Valida que un campo no esté vacío
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa ${fieldName ?? 'este campo'}';
    }
    return null;
  }

  /// Valida formato de email
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingresa un correo válido';
    }

    return null;
  }

  /// Valida longitud mínima
  static String? minLength(String? value, int length, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa ${fieldName ?? 'este campo'}';
    }

    if (value.length < length) {
      return '${fieldName ?? 'Este campo'} debe tener al menos $length caracteres';
    }

    return null;
  }

  /// Valida longitud máxima
  static String? maxLength(String? value, int length, [String? fieldName]) {
    if (value != null && value.length > length) {
      return '${fieldName ?? 'Este campo'} no puede tener más de $length caracteres';
    }
    return null;
  }

  /// Valida contraseña (mínimo 6 caracteres)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  /// Valida contraseña fuerte
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }

    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una mayúscula';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe contener al menos una minúscula';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }

    return null;
  }

  /// Valida que dos contraseñas coincidan
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }

    if (value != password) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  /// Valida número de teléfono peruano
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu número de teléfono';
    }

    // Formato: 9XX XXX XXX (números peruanos)
    final phoneRegex = RegExp(r'^9[0-9]{8}$');

    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (!phoneRegex.hasMatch(cleanValue)) {
      return 'Por favor ingresa un número válido (9 dígitos)';
    }

    return null;
  }

  /// Valida DNI peruano (8 dígitos)
  static String? dni(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu DNI';
    }

    final dniRegex = RegExp(r'^[0-9]{8}$');

    if (!dniRegex.hasMatch(value)) {
      return 'El DNI debe tener 8 dígitos';
    }

    return null;
  }

  /// Valida que sea un número
  static String? number(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa ${fieldName ?? 'un número'}';
    }

    if (double.tryParse(value) == null) {
      return 'Por favor ingresa un número válido';
    }

    return null;
  }

  /// Valida que sea un número entero
  static String? integer(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa ${fieldName ?? 'un número'}';
    }

    if (int.tryParse(value) == null) {
      return 'Por favor ingresa un número entero válido';
    }

    return null;
  }

  /// Valida rango numérico
  static String? numberRange(String? value, num min, num max, [String? fieldName]) {
    final numValue = number(value, fieldName);
    if (numValue != null) return numValue;

    final parsedValue = double.parse(value!);

    if (parsedValue < min || parsedValue > max) {
      return '${fieldName ?? 'El valor'} debe estar entre $min y $max';
    }

    return null;
  }

  /// Valida URL
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una URL';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Por favor ingresa una URL válida';
    }

    return null;
  }

  /// Combina múltiples validadores
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  /// Validador personalizado
  static String? custom(
    String? value,
    bool Function(String?) condition,
    String errorMessage,
  ) {
    if (value != null && !condition(value)) {
      return errorMessage;
    }
    return null;
  }
}
