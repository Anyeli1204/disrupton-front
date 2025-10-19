import 'package:flutter/material.dart';

/// Sistema de colores minimalista y moderno para Disrupton
/// Paleta de colores suaves y profesionales
class AppColors {
  AppColors._(); // Constructor privado para evitar instanciación

  // ========== COLORES PRINCIPALES ==========

  /// Color primario principal - Verde vibrante
  static const Color primary = Color(0xFF39E079);

  /// Variante clara del color primario
  static const Color primaryLight = Color(0xFF5FE88F);

  /// Variante oscura del color primario
  static const Color primaryDark = Color(0xFF2BC965);

  /// Variante muy clara para fondos
  static const Color primaryBackground = Color(0xFFE8FBF0);

  // ========== COLORES SECUNDARIOS ==========

  /// Color secundario - Verde esmeralda suave
  static const Color secondary = Color(0xFF10B981);

  /// Variante clara del secundario
  static const Color secondaryLight = Color(0xFF34D399);

  /// Variante oscura del secundario
  static const Color secondaryDark = Color(0xFF059669);

  /// Variante muy clara para fondos
  static const Color secondaryBackground = Color(0xFFECFDF5);

  // ========== COLORES NEUTROS ==========

  /// Fondo principal de la app
  static const Color background = Color(0xFFF9FAFB);

  /// Color de superficie (cards, sheets)
  static const Color surface = Color(0xFFFFFFFF);

  /// Color de superficie elevada
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  /// Color para overlays
  static const Color overlay = Color(0xFFF3F4F6);

  // ========== COLORES DE TEXTO ==========

  /// Texto principal - Gris muy oscuro
  static const Color textPrimary = Color(0xFF111827);

  /// Texto secundario - Gris medio
  static const Color textSecondary = Color(0xFF6B7280);

  /// Texto terciario - Gris claro
  static const Color textTertiary = Color(0xFF9CA3AF);

  /// Texto deshabilitado
  static const Color textDisabled = Color(0xFFD1D5DB);

  /// Texto sobre color primario
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Texto sobre color secundario
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // ========== COLORES DE ACENTO ==========

  /// Color de acento - Azul
  static const Color accent = Color(0xFF3B82F6);

  /// Color de información
  static const Color info = Color(0xFF3B82F6);

  /// Color de éxito
  static const Color success = Color(0xFF10B981);

  /// Color de advertencia
  static const Color warning = Color(0xFFF59E0B);

  /// Color de error
  static const Color error = Color(0xFFEF4444);

  // ========== FONDOS DE ESTADO ==========

  /// Fondo para info
  static const Color infoBackground = Color(0xFFEFF6FF);

  /// Fondo para éxito
  static const Color successBackground = Color(0xFFECFDF5);

  /// Fondo para advertencia
  static const Color warningBackground = Color(0xFFFEF3C7);

  /// Fondo para error
  static const Color errorBackground = Color(0xFFFEE2E2);

  // ========== BORDES Y DIVISORES ==========

  /// Color de borde principal
  static const Color border = Color(0xFFE5E7EB);

  /// Color de borde claro
  static const Color borderLight = Color(0xFFF3F4F6);

  /// Color de borde oscuro
  static const Color borderDark = Color(0xFFD1D5DB);

  /// Color de divisor
  static const Color divider = Color(0xFFE5E7EB);

  // ========== SOMBRAS ==========

  /// Sombra suave para elevación
  static const Color shadow = Color(0x0F000000); // rgba(0, 0, 0, 0.06)

  /// Sombra media
  static const Color shadowMedium = Color(0x1A000000); // rgba(0, 0, 0, 0.10)

  /// Sombra fuerte
  static const Color shadowStrong = Color(0x26000000); // rgba(0, 0, 0, 0.15)

  // ========== COLORES ESPECIALES ==========

  /// Color para elementos AR
  static const Color ar = Color(0xFF8B5CF6);

  /// Color para cultura
  static const Color culture = Color(0xFFEC4899);

  /// Color para eventos
  static const Color events = Color(0xFFF59E0B);

  /// Color para tienda
  static const Color store = Color(0xFF14B8A6);

  // ========== GRADIENTES ==========

  /// Gradiente principal
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  /// Gradiente secundario
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  /// Gradiente sutil para fondos
  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBFBFB), Color(0xFFF9FAFB)],
  );

  /// Gradiente para shimmer/loading
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
    colors: [
      Color(0xFFF3F4F6),
      Color(0xFFE5E7EB),
      Color(0xFFF3F4F6),
    ],
  );

  // ========== MÉTODOS HELPER ==========

  /// Obtiene un color según el índice (para listas dinámicas)
  static Color getColorByIndex(int index) {
    final colors = [
      primary,
      secondary,
      accent,
      culture,
      events,
      store,
      ar,
      success,
    ];
    return colors[index % colors.length];
  }

  /// Obtiene el color de fondo basado en el color principal
  static Color getBackgroundColor(Color color) {
    return color.withOpacity(0.1);
  }

  /// Obtiene el color de borde basado en el color principal
  static Color getBorderColor(Color color) {
    return color.withOpacity(0.2);
  }
}
