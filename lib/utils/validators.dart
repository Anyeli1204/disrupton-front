class Validators {
  // Validar email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es obligatorio';
    }
    
    // Expresión regular para validar email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'El formato del email no es válido';
    }
    
    return null;
  }

  // Validar contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }

  // Validar nombre
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es obligatorio';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (value.trim().length > 50) {
      return 'El nombre no puede exceder 50 caracteres';
    }
    
    return null;
  }

  // Validar teléfono
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // El teléfono es opcional
    }
    
    // Expresión regular para validar teléfono (formato internacional)
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'El formato del teléfono no es válido';
    }
    
    return null;
  }

  // Validar que no esté vacío
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  // Validar longitud mínima
  static String? minLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    return null;
  }

  // Validar longitud máxima
  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName no puede exceder $maxLength caracteres';
    }
    return null;
  }

  // Validar que sea un número
  static String? number(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    
    if (double.tryParse(value.trim()) == null) {
      return '$fieldName debe ser un número válido';
    }
    
    return null;
  }

  // Validar que sea un entero positivo
  static String? positiveInteger(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    
    final number = int.tryParse(value.trim());
    if (number == null) {
      return '$fieldName debe ser un número entero válido';
    }
    
    if (number <= 0) {
      return '$fieldName debe ser un número positivo';
    }
    
    return null;
  }

  // Validar URL
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // La URL es opcional
    }
    
    try {
      Uri.parse(value.trim());
      return null;
    } catch (e) {
      return 'La URL no tiene un formato válido';
    }
  }
}

