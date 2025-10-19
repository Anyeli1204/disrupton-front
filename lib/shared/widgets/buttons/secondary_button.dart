import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

/// Botón secundario con borde (outline)
/// Usado para acciones secundarias en la aplicación
class SecondaryButton extends StatelessWidget {
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

  /// Color personalizado del borde y texto
  final Color? borderColor;

  /// Altura del botón
  final double? height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
    this.borderColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? AppColors.primary;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(
            color: isLoading ? AppColors.textDisabled : color,
            width: AppDimensions.borderWidth,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: icon != null ? AppDimensions.spaceL : AppDimensions.space,
            vertical: AppDimensions.spaceM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusM,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
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
                    style: AppTypography.buttonSecondary.copyWith(
                      color: color,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Botón de texto simple (sin borde ni fondo)
class TextButtonCustom extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const TextButtonCustom({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppColors.primary;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(
          horizontal: icon != null ? AppDimensions.spaceM : AppDimensions.spaceS,
          vertical: AppDimensions.spaceS,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppDimensions.iconXS),
            const SizedBox(width: AppDimensions.spaceXS),
          ],
          Text(
            text,
            style: AppTypography.buttonText.copyWith(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
