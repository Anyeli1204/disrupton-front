import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales: Celeste y Amarillo
  static const Color primaryCeleste = Color(0xFF4FC3F7); // Celeste brillante
  static const Color primaryCelesteLight = Color(0xFF81D4FA); // Celeste claro
  static const Color primaryCelesteDark = Color(0xFF0288D1); // Celeste oscuro

  static const Color primaryYellow = Color(0xFFFFD54F); // Amarillo brillante
  static const Color primaryYellowLight = Color(0xFFFFF176); // Amarillo claro
  static const Color primaryYellowDark = Color(0xFFFF8F00); // Amarillo oscuro

  // Colores complementarios
  static const Color backgroundLight =
      Color(0xFFF8FDFF); // Fondo claro con toque celeste
  static const Color backgroundDark = Color(0xFF0D47A1); // Fondo oscuro azul
  static const Color surfaceLight = Colors.white;
  static const Color textPrimary = Color(0xFF1A237E); // Azul oscuro para texto
  static const Color textSecondary = Color(0xFF424242);
  static const Color accent =
      Color(0xFFE1F5FE); // Celeste muy claro para acentos

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryCeleste, primaryCelesteDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryYellow, primaryYellowDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, surfaceLight],
  );

  // Función para obtener el color de una función basado en su índice
  static Color getFunctionColor(int index) {
    final colors = [
      primaryCeleste,
      primaryYellow,
      primaryCelesteLight,
      primaryYellowLight,
      primaryCelesteDark,
      primaryYellowDark,
      const Color(0xFF26A69A), // Teal que combina con celeste
      const Color(0xFFFFB74D), // Naranja que combina con amarillo
    ];
    return colors[index % colors.length];
  }

  // Función para obtener el color de fondo de un ícono
  static Color getIconBackgroundColor(Color iconColor) {
    return iconColor.withOpacity(0.1);
  }

  // Tema principal de la aplicación
  static ThemeData lightTheme = ThemeData(
    primarySwatch: MaterialColor(0xFF4FC3F7, {
      50: const Color(0xFFE1F5FE),
      100: const Color(0xFFB3E5FC),
      200: const Color(0xFF81D4FA),
      300: const Color(0xFF4FC3F7),
      400: const Color(0xFF29B6F6),
      500: const Color(0xFF03A9F4),
      600: const Color(0xFF039BE5),
      700: const Color(0xFF0288D1),
      800: const Color(0xFF0277BD),
      900: const Color(0xFF01579B),
    }),
    primaryColor: primaryCeleste,
    colorScheme: const ColorScheme.light(
      primary: primaryCeleste,
      secondary: primaryYellow,
      background: backgroundLight,
      surface: surfaceLight,
      onPrimary: Colors.white,
      onSecondary: textPrimary,
      onBackground: textPrimary,
      onSurface: textPrimary,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: surfaceLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryCeleste,
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryCeleste,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: surfaceLight,
    ),
    fontFamily: 'Roboto',
  );
}
