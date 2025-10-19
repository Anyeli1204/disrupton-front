import 'package:flutter/material.dart';

/// Sistema de dimensiones y espaciados consistentes para Disrupton
/// Define todos los tamaños, radios y espaciados utilizados en la aplicación
class AppDimensions {
  AppDimensions._(); // Constructor privado

  // ========== ESPACIADOS (Padding/Margin) ==========

  /// Espaciado extra pequeño - 4px
  static const double spaceXS = 4.0;

  /// Espaciado pequeño - 8px
  static const double spaceS = 8.0;

  /// Espaciado mediano - 12px
  static const double spaceM = 12.0;

  /// Espaciado normal - 16px
  static const double space = 16.0;

  /// Espaciado grande - 24px
  static const double spaceL = 24.0;

  /// Espaciado extra grande - 32px
  static const double spaceXL = 32.0;

  /// Espaciado extra extra grande - 40px
  static const double spaceXXL = 40.0;

  /// Espaciado extra extra extra grande - 48px
  static const double spaceXXXL = 48.0;

  // ========== BORDES REDONDEADOS ==========

  /// Radio extra pequeño - 4px
  static const double radiusXS = 4.0;

  /// Radio pequeño - 8px
  static const double radiusS = 8.0;

  /// Radio mediano - 12px
  static const double radiusM = 12.0;

  /// Radio normal - 16px
  static const double radius = 16.0;

  /// Radio grande - 20px
  static const double radiusL = 20.0;

  /// Radio extra grande - 24px
  static const double radiusXL = 24.0;

  /// Radio completo (circular)
  static const double radiusFull = 9999.0;

  // ========== ELEVACIONES (Sombras) ==========

  /// Sin elevación
  static const double elevationNone = 0.0;

  /// Elevación mínima - 1px
  static const double elevationMin = 1.0;

  /// Elevación pequeña - 2px
  static const double elevationS = 2.0;

  /// Elevación mediana - 4px
  static const double elevationM = 4.0;

  /// Elevación normal - 6px
  static const double elevation = 6.0;

  /// Elevación grande - 8px
  static const double elevationL = 8.0;

  /// Elevación extra grande - 12px
  static const double elevationXL = 12.0;

  // ========== ANCHOS DE BORDE ==========

  /// Borde muy delgado - 0.5px
  static const double borderWidthThin = 0.5;

  /// Borde normal - 1px
  static const double borderWidth = 1.0;

  /// Borde mediano - 1.5px
  static const double borderWidthMedium = 1.5;

  /// Borde grueso - 2px
  static const double borderWidthThick = 2.0;

  // ========== ALTURAS DE COMPONENTES ==========

  /// Altura de botón pequeño
  static const double buttonHeightS = 36.0;

  /// Altura de botón normal
  static const double buttonHeight = 48.0;

  /// Altura de botón grande
  static const double buttonHeightL = 56.0;

  /// Altura de input/campo de texto
  static const double inputHeight = 56.0;

  /// Altura de app bar
  static const double appBarHeight = 56.0;

  /// Altura de bottom bar
  static const double bottomBarHeight = 64.0;

  /// Altura de list tile
  static const double listTileHeight = 72.0;

  // ========== TAMAÑOS DE ÍCONOS ==========

  /// Ícono extra pequeño
  static const double iconXS = 16.0;

  /// Ícono pequeño
  static const double iconS = 20.0;

  /// Ícono mediano
  static const double iconM = 24.0;

  /// Ícono normal
  static const double icon = 28.0;

  /// Ícono grande
  static const double iconL = 32.0;

  /// Ícono extra grande
  static const double iconXL = 40.0;

  /// Ícono extra extra grande
  static const double iconXXL = 48.0;

  // ========== TAMAÑOS DE AVATAR ==========

  /// Avatar pequeño
  static const double avatarS = 32.0;

  /// Avatar mediano
  static const double avatarM = 40.0;

  /// Avatar normal
  static const double avatar = 48.0;

  /// Avatar grande
  static const double avatarL = 64.0;

  /// Avatar extra grande
  static const double avatarXL = 80.0;

  /// Avatar extra extra grande
  static const double avatarXXL = 120.0;

  // ========== ANCHOS MÁXIMOS ==========

  /// Ancho máximo para contenido (pantallas grandes)
  static const double maxContentWidth = 1200.0;

  /// Ancho máximo para formularios
  static const double maxFormWidth = 480.0;

  /// Ancho máximo para cards
  static const double maxCardWidth = 400.0;

  // ========== ASPECTOS RATIO ==========

  /// Aspect ratio para cards cuadrados
  static const double aspectRatioSquare = 1.0;

  /// Aspect ratio para cards horizontales
  static const double aspectRatioCard = 1.5;

  /// Aspect ratio para imágenes panorámicas
  static const double aspectRatioPanorama = 2.0;

  /// Aspect ratio para imágenes de perfil
  static const double aspectRatioProfile = 0.75;

  // ========== OPACIDADES ==========

  /// Opacidad deshabilitado
  static const double opacityDisabled = 0.38;

  /// Opacidad secundario
  static const double opacitySecondary = 0.60;

  /// Opacidad hover
  static const double opacityHover = 0.08;

  /// Opacidad focus
  static const double opacityFocus = 0.12;

  /// Opacidad pressed
  static const double opacityPressed = 0.16;

  // ========== EDGE INSETS PREDEFINIDOS ==========

  /// Sin padding
  static const EdgeInsets paddingNone = EdgeInsets.zero;

  /// Padding extra pequeño - 4px
  static const EdgeInsets paddingXS = EdgeInsets.all(spaceXS);

  /// Padding pequeño - 8px
  static const EdgeInsets paddingS = EdgeInsets.all(spaceS);

  /// Padding mediano - 12px
  static const EdgeInsets paddingM = EdgeInsets.all(spaceM);

  /// Padding normal - 16px
  static const EdgeInsets padding = EdgeInsets.all(space);

  /// Padding grande - 24px
  static const EdgeInsets paddingL = EdgeInsets.all(spaceL);

  /// Padding extra grande - 32px
  static const EdgeInsets paddingXL = EdgeInsets.all(spaceXL);

  /// Padding horizontal normal
  static const EdgeInsets paddingH = EdgeInsets.symmetric(horizontal: space);

  /// Padding vertical normal
  static const EdgeInsets paddingV = EdgeInsets.symmetric(vertical: space);

  /// Padding horizontal pequeño
  static const EdgeInsets paddingHS = EdgeInsets.symmetric(horizontal: spaceS);

  /// Padding vertical pequeño
  static const EdgeInsets paddingVS = EdgeInsets.symmetric(vertical: spaceS);

  /// Padding horizontal grande
  static const EdgeInsets paddingHL = EdgeInsets.symmetric(horizontal: spaceL);

  /// Padding vertical grande
  static const EdgeInsets paddingVL = EdgeInsets.symmetric(vertical: spaceL);

  // ========== BORDER RADIUS PREDEFINIDOS ==========

  /// Border radius extra pequeño
  static const BorderRadius borderRadiusXS = BorderRadius.all(Radius.circular(radiusXS));

  /// Border radius pequeño
  static const BorderRadius borderRadiusS = BorderRadius.all(Radius.circular(radiusS));

  /// Border radius mediano
  static const BorderRadius borderRadiusM = BorderRadius.all(Radius.circular(radiusM));

  /// Border radius normal
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(radius));

  /// Border radius grande
  static const BorderRadius borderRadiusL = BorderRadius.all(Radius.circular(radiusL));

  /// Border radius extra grande
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(radiusXL));

  /// Border radius completo (circular)
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // ========== DURACIONES DE ANIMACIÓN ==========

  /// Duración muy rápida - 100ms
  static const Duration durationFast = Duration(milliseconds: 100);

  /// Duración rápida - 200ms
  static const Duration durationQuick = Duration(milliseconds: 200);

  /// Duración normal - 300ms
  static const Duration duration = Duration(milliseconds: 300);

  /// Duración lenta - 400ms
  static const Duration durationSlow = Duration(milliseconds: 400);

  /// Duración muy lenta - 600ms
  static const Duration durationVerySlow = Duration(milliseconds: 600);

  // ========== MÉTODOS HELPER ==========

  /// Crea un EdgeInsets simétrico
  static EdgeInsets symmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    );
  }

  /// Crea un EdgeInsets con valores específicos
  static EdgeInsets only({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left ?? 0,
      top: top ?? 0,
      right: right ?? 0,
      bottom: bottom ?? 0,
    );
  }

  /// Crea un BorderRadius circular
  static BorderRadius circular(double radius) {
    return BorderRadius.circular(radius);
  }

  /// Crea un BorderRadius con valores específicos
  static BorderRadius circularOnly({
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft ?? 0),
      topRight: Radius.circular(topRight ?? 0),
      bottomLeft: Radius.circular(bottomLeft ?? 0),
      bottomRight: Radius.circular(bottomRight ?? 0),
    );
  }
}
