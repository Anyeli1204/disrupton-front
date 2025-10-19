import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

/// Campo de texto personalizado con estilo minimalista
class AppTextField extends StatelessWidget {
  /// Controlador del campo de texto
  final TextEditingController? controller;

  /// Etiqueta del campo
  final String? label;

  /// Texto de ayuda
  final String? hint;

  /// Prefijo icon
  final IconData? prefixIcon;

  /// Sufijo icon
  final IconData? suffixIcon;

  /// Callback al presionar el ícono de sufijo
  final VoidCallback? onSuffixIconPressed;

  /// Tipo de teclado
  final TextInputType? keyboardType;

  /// Validador
  final String? Function(String?)? validator;

  /// Callback al cambiar el texto
  final void Function(String)? onChanged;

  /// Callback al enviar el formulario
  final void Function(String)? onFieldSubmitted;

  /// Número máximo de líneas
  final int? maxLines;

  /// Número mínimo de líneas
  final int? minLines;

  /// Máximo de caracteres
  final int? maxLength;

  /// Es de solo lectura
  final bool readOnly;

  /// Está habilitado
  final bool enabled;

  /// Texto inicial
  final String? initialValue;

  /// Formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Acción del teclado
  final TextInputAction? textInputAction;

  /// Focus node
  final FocusNode? focusNode;

  /// Auto validar
  final AutovalidateMode? autovalidateMode;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    this.enabled = true,
    this.initialValue,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: AppColors.textSecondary,
                size: AppDimensions.iconS,
              )
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(
                  suffixIcon,
                  color: AppColors.textSecondary,
                  size: AppDimensions.iconS,
                ),
                onPressed: onSuffixIconPressed,
              )
            : null,
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.overlay,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusM,
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: AppDimensions.borderWidth,
          ),
        ),
        labelStyle: AppTypography.inputLabel,
        hintStyle: AppTypography.inputHint,
        errorStyle: AppTypography.error,
        errorMaxLines: 2,
        counterText: maxLength != null ? null : '',
      ),
      style: AppTypography.input,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      readOnly: readOnly,
      enabled: enabled,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
    );
  }
}

/// Campo de texto para búsqueda
class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;

  const AppSearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hint: hint ?? 'Buscar...',
      prefixIcon: Icons.search,
      suffixIcon: controller?.text.isNotEmpty == true ? Icons.clear : null,
      onSuffixIconPressed: () {
        controller?.clear();
        onClear?.call();
      },
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
    );
  }
}
