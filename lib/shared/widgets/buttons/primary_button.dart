import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

/// Botón primario con estilo minimalista y moderno
/// Usado para acciones principales en la aplicación
class PrimaryButton extends StatelessWidget {
  /// Texto del botón
  final String text;

  /// Función a ejecutar al presionar el botón
  final VoidCallback? onPressed;

  /// Indica si el botón está en estado de carga
  final bool isLoading;

  /// Icono opcional a mostrar antes del texto
  final IconData? icon;

  /// Ancho completo (por defecto true)
  final bool fullWidth;

  /// Color personalizado del botón (opcional)
  final Color? backgroundColor;

  /// Color del texto (opcional)
  final Color? textColor;

  /// Altura del botón
  final double? height;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.backgroundColor,
    this.textColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.textOnPrimary,
          elevation: AppDimensions.elevationS,
          shadowColor: AppColors.shadow,
          disabledBackgroundColor: AppColors.textDisabled,
          disabledForegroundColor: AppColors.textSecondary,
          padding: EdgeInsets.symmetric(
            horizontal: icon != null ? AppDimensions.spaceL : AppDimensions.space,
            vertical: AppDimensions.spaceM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: AppDimensions.iconS),
                    const SizedBox(width: AppDimensions.spaceS),
                  ],
                  Text(
                    text,
                    style: AppTypography.buttonPrimary.copyWith(
                      color: textColor ?? AppColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Botón primario pequeño (versión compacta)
class PrimaryButtonSmall extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButtonSmall({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      fullWidth: false,
      height: AppDimensions.buttonHeightS,
    );
  }
}

/// Botón primario grande (versión destacada)
class PrimaryButtonLarge extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButtonLarge({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      height: AppDimensions.buttonHeightL,
    );
  }
}
