import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_typography.dart';

/// Card para mostrar funcionalidades en el home
class FeatureCard extends StatelessWidget {
  /// Ícono de la funcionalidad
  final IconData icon;

  /// Título de la funcionalidad
  final String title;

  /// Subtítulo/descripción
  final String subtitle;

  /// Color principal del card
  final Color color;

  /// Función al hacer tap
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppDimensions.elevationS,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusM,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusM,
        child: Container(
          padding: AppDimensions.paddingM,
          decoration: BoxDecoration(
            borderRadius: AppDimensions.borderRadiusM,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.08),
                color.withOpacity(0.03),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono con fondo
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceM),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: AppDimensions.borderRadiusS,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: AppDimensions.iconL,
                ),
              ),

              const SizedBox(height: AppDimensions.spaceM),

              // Título
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppDimensions.spaceXS),

              // Subtítulo
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card base reutilizable
class BaseCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;

  const BaseCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? AppDimensions.elevationS,
      shadowColor: AppColors.shadow,
      color: color ?? AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusM,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusM,
        child: Padding(
          padding: padding ?? AppDimensions.padding,
          child: child,
        ),
      ),
    );
  }
}

/// Card de información
class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? color;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.info;

    return BaseCard(
      onTap: onTap,
      child: Row(
        children: [
          // Ícono
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceM),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: AppDimensions.borderRadiusS,
            ),
            child: Icon(
              icon,
              color: cardColor,
              size: AppDimensions.iconM,
            ),
          ),

          const SizedBox(width: AppDimensions.space),

          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spaceXS),
                Text(
                  description,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Ícono de navegación
          if (onTap != null)
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: AppDimensions.iconS,
            ),
        ],
      ),
    );
  }
}
