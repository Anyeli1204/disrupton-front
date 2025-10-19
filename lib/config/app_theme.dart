import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_dimensions.dart';

/// Tema principal de la aplicación Disrupton
/// Implementa un diseño minimalista y moderno
class AppTheme {
  AppTheme._(); // Constructor privado

  // ========== COMPATIBILIDAD CON CÓDIGO EXISTENTE ==========
  // Mantenemos estas propiedades para no romper el código existente

  @Deprecated('Use AppColors.primary instead')
  static const Color primaryCeleste = AppColors.primary;

  @Deprecated('Use AppColors.primaryLight instead')
  static const Color primaryCelesteLight = AppColors.primaryLight;

  @Deprecated('Use AppColors.primaryDark instead')
  static const Color primaryCelesteDark = AppColors.primaryDark;

  @Deprecated('Use AppColors.secondary instead')
  static const Color primaryYellow = AppColors.secondary;

  @Deprecated('Use AppColors.secondaryLight instead')
  static const Color primaryYellowLight = AppColors.secondaryLight;

  @Deprecated('Use AppColors.secondaryDark instead')
  static const Color primaryYellowDark = AppColors.secondaryDark;

  @Deprecated('Use AppColors.background instead')
  static const Color backgroundLight = AppColors.background;

  @Deprecated('Use AppColors.primaryDark instead')
  static const Color backgroundDark = AppColors.primaryDark;

  @Deprecated('Use AppColors.surface instead')
  static const Color surfaceLight = AppColors.surface;

  @Deprecated('Use AppColors.textPrimary instead')
  static const Color textPrimary = AppColors.textPrimary;

  @Deprecated('Use AppColors.textSecondary instead')
  static const Color textSecondary = AppColors.textSecondary;

  @Deprecated('Use AppColors.primaryBackground instead')
  static const Color accent = AppColors.primaryBackground;

  @Deprecated('Use AppColors.primaryGradient instead')
  static const LinearGradient primaryGradient = AppColors.primaryGradient;

  @Deprecated('Use AppColors.secondaryGradient instead')
  static const LinearGradient secondaryGradient = AppColors.secondaryGradient;

  @Deprecated('Use AppColors.subtleGradient instead')
  static const LinearGradient backgroundGradient = AppColors.subtleGradient;

  // ========== MÉTODOS HELPER (COMPATIBILIDAD) ==========

  @Deprecated('Use AppColors.getColorByIndex instead')
  static Color getFunctionColor(int index) {
    return AppColors.getColorByIndex(index);
  }

  @Deprecated('Use AppColors.getBackgroundColor instead')
  static Color getIconBackgroundColor(Color iconColor) {
    return AppColors.getBackgroundColor(iconColor);
  }

  // ========== TEMA PRINCIPAL ==========

  /// Tema principal de la aplicación (Light Mode)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // ========== COLOR SCHEME ==========
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
        outline: AppColors.border,
        shadow: AppColors.shadow,
      ),

      // ========== COLORES BÁSICOS ==========
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      cardColor: AppColors.surface,
      dividerColor: AppColors.divider,
      disabledColor: AppColors.textDisabled,

      // ========== TIPOGRAFÍA ==========
      fontFamily: 'RobotoMono',
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // ========== APP BAR ==========
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppDimensions.iconM,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // ========== BOTONES ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: AppDimensions.elevationS,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          padding: AppDimensions.paddingH,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          textStyle: AppTypography.buttonPrimary,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          padding: AppDimensions.paddingH,
          side: const BorderSide(
            color: AppColors.border,
            width: AppDimensions.borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
          textStyle: AppTypography.buttonSecondary,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppDimensions.paddingH,
          textStyle: AppTypography.buttonText,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          iconSize: AppDimensions.iconM,
        ),
      ),

      // ========== INPUTS ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space,
          vertical: AppDimensions.space,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimensions.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimensions.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: AppDimensions.borderWidthMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderWidthMedium,
          ),
        ),
        labelStyle: AppTypography.inputLabel,
        hintStyle: AppTypography.inputHint,
        errorStyle: AppTypography.error,
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // ========== CARDS ==========
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: AppDimensions.elevationS,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusM,
        ),
        margin: AppDimensions.paddingNone,
      ),

      // ========== DIALOG ==========
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppDimensions.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusL,
        ),
        titleTextStyle: AppTypography.titleLarge,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // ========== BOTTOM SHEET ==========
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppDimensions.elevationL,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusL),
          ),
        ),
      ),

      // ========== CHIP ==========
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.overlay,
        deleteIconColor: AppColors.textSecondary,
        disabledColor: AppColors.textDisabled,
        selectedColor: AppColors.primaryBackground,
        secondarySelectedColor: AppColors.secondaryBackground,
        padding: AppDimensions.paddingS,
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelSmall,
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusS,
        ),
      ),

      // ========== DIVIDER ==========
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: AppDimensions.borderWidthThin,
        space: AppDimensions.spaceL,
      ),

      // ========== SNACKBAR ==========
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusS,
        ),
      ),

      // ========== PROGRESS INDICATOR ==========
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      // ========== FLOATING ACTION BUTTON ==========
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: AppDimensions.elevation,
      ),

      // ========== NAVIGATION BAR ==========
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryBackground,
        elevation: AppDimensions.elevationS,
        labelTextStyle: MaterialStateProperty.all(AppTypography.labelSmall),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              color: AppColors.primary,
              size: AppDimensions.iconM,
            );
          }
          return const IconThemeData(
            color: AppColors.textSecondary,
            size: AppDimensions.iconM,
          );
        }),
      ),

      // ========== LIST TILE ==========
      listTileTheme: ListTileThemeData(
        contentPadding: AppDimensions.paddingH,
        tileColor: AppColors.surface,
        selectedTileColor: AppColors.primaryBackground,
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.titleMedium,
        subtitleTextStyle: AppTypography.bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusS,
        ),
      ),
    );
  }

  /// Tema oscuro (para futuras implementaciones)
  static ThemeData get darkTheme {
    // TODO: Implementar tema oscuro
    return lightTheme;
  }
}
