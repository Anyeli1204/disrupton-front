import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extensiones para String
extension StringExtensions on String {
  /// Capitaliza la primera letra
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitaliza cada palabra
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Valida si es un email válido
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Valida si es un número
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Remueve espacios en blanco al inicio y final
  String get trimmed => trim();

  /// Verifica si está vacío o solo tiene espacios
  bool get isBlank => trim().isEmpty;

  /// Verifica si no está vacío
  bool get isNotBlank => !isBlank;

  /// Trunca el texto a una longitud específica
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
}

/// Extensiones para DateTime
extension DateTimeExtensions on DateTime {
  /// Formatea la fecha como 'dd/MM/yyyy'
  String get formatted {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Formatea la fecha como 'dd MMM yyyy'
  String get formattedLong {
    return DateFormat('dd MMM yyyy', 'es_ES').format(this);
  }

  /// Formatea la fecha y hora como 'dd/MM/yyyy HH:mm'
  String get formattedWithTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }

  /// Verifica si es hoy
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verifica si es ayer
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Obtiene el tiempo relativo (hace X minutos/horas/días)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'hace ${years} ${years == 1 ? 'año' : 'años'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'hace ${months} ${months == 1 ? 'mes' : 'meses'}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'justo ahora';
    }
  }
}

/// Extensiones para num (int, double)
extension NumExtensions on num {
  /// Formatea como moneda peruana (S/.)
  String get toCurrency {
    return 'S/. ${toStringAsFixed(2)}';
  }

  /// Formatea con separadores de miles
  String get formatted {
    final formatter = NumberFormat('#,##0.00', 'es_PE');
    return formatter.format(this);
  }

  /// Verifica si está en un rango
  bool inRange(num min, num max) {
    return this >= min && this <= max;
  }
}

/// Extensiones para BuildContext
extension BuildContextExtensions on BuildContext {
  /// Obtiene el MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Obtiene el tamaño de la pantalla
  Size get screenSize => mediaQuery.size;

  /// Obtiene el ancho de la pantalla
  double get screenWidth => screenSize.width;

  /// Obtiene la altura de la pantalla
  double get screenHeight => screenSize.height;

  /// Verifica si es una pantalla pequeña (móvil)
  bool get isSmallScreen => screenWidth < 600;

  /// Verifica si es una pantalla mediana (tablet)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1024;

  /// Verifica si es una pantalla grande (desktop)
  bool get isLargeScreen => screenWidth >= 1024;

  /// Obtiene el tema actual
  ThemeData get theme => Theme.of(this);

  /// Obtiene el esquema de colores
  ColorScheme get colorScheme => theme.colorScheme;

  /// Obtiene el tema de texto
  TextTheme get textTheme => theme.textTheme;

  /// Muestra un SnackBar
  void showSnackBar(String message, {Duration? duration, bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  /// Cierra el teclado
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
}

/// Extensiones para List
extension ListExtensions<T> on List<T> {
  /// Verifica si la lista no está vacía
  bool get isNotEmpty => !isEmpty;

  /// Obtiene un elemento de forma segura
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Divide la lista en chunks
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

/// Extensiones para Color
extension ColorExtensions on Color {
  /// Convierte el color a hexadecimal
  String get toHex {
    return '#${value.toRadixString(16).substring(2, 8).toUpperCase()}';
  }

  /// Obtiene la luminancia y determina si es oscuro
  bool get isDark {
    return computeLuminance() < 0.5;
  }

  /// Obtiene la luminancia y determina si es claro
  bool get isLight {
    return !isDark;
  }
}
