import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_typography.dart';
import '../providers/firebase_auth_provider.dart';
import '../models/auth_models.dart';
import '../routes/app_routes.dart';
import 'auth_screen.dart';

/// Pantalla de Perfil consolidada
/// Combina: Perfil de Usuario, Favoritos, Configuración, Panel Admin
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Consumer<FirebaseAuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return _buildNotLoggedIn(context);
          }

          return SingleChildScrollView(
            padding: AppDimensions.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de perfil de usuario
                _buildProfileCard(user),

                const SizedBox(height: AppDimensions.spaceXL),

                // Secciones según el rol
                _buildRoleSections(context, user.role),

                const SizedBox(height: AppDimensions.spaceXL),

                // Secciones comunes
                _buildCommonSections(context),

                const SizedBox(height: AppDimensions.spaceXL),

                // Botón de cerrar sesión
                _buildLogoutButton(context, authProvider),

                const SizedBox(height: AppDimensions.spaceXL),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppDimensions.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 100,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            Text(
              'No has iniciado sesión',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceM),
            Text(
              'Inicia sesión para acceder a tu perfil\ny todas las funciones',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceXXL,
                  vertical: AppDimensions.spaceM,
                ),
              ),
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(user) {
    return Container(
      width: double.infinity,
      padding: AppDimensions.paddingL,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppDimensions.borderRadiusL,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(AppDimensions.spaceL),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceL),

          // Nombre
          Text(
            user.displayName ?? 'Usuario',
            style: AppTypography.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXS),

          // Email
          Text(
            user.email,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // Rol
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceL,
              vertical: AppDimensions.spaceS,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppDimensions.borderRadiusL,
            ),
            child: Text(
              user.role.description,
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSections(BuildContext context, UserRole role) {
    if (role == UserRole.admin) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Administración',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          _buildMenuTile(
            context,
            icon: Icons.dashboard,
            title: 'Panel de Administración',
            subtitle: 'Gestiona usuarios y estadísticas',
            color: AppColors.primary,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.adminDashboard);
            },
          ),
          _buildMenuTile(
            context,
            icon: Icons.event,
            title: 'Gestión de Eventos',
            subtitle: 'Administra eventos culturales',
            color: AppColors.events,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.adminEvents);
            },
          ),
        ],
      );
    } else if (role == UserRole.moderator) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Moderación',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          _buildMenuTile(
            context,
            icon: Icons.shield,
            title: 'Panel de Moderación',
            subtitle: 'Revisa y aprueba contenido',
            color: AppColors.info,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.moderator);
            },
          ),
        ],
      );
    } else if (role == UserRole.artisan) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mi Negocio',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          _buildMenuTile(
            context,
            icon: Icons.inventory_2,
            title: 'Mis Productos',
            subtitle: 'Gestiona tu catálogo',
            color: AppColors.store,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.artisanProducts);
            },
          ),
        ],
      );
    } else if (role == UserRole.guide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis Servicios',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          _buildMenuTile(
            context,
            icon: Icons.campaign,
            title: 'Mis Promociones',
            subtitle: 'Gestiona tours y experiencias',
            color: AppColors.secondary,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.guidePromotions);
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCommonSections(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'General',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceM),
        _buildMenuTile(
          context,
          icon: Icons.favorite,
          title: 'Favoritos',
          subtitle: 'Tus lugares y objetos guardados',
          color: AppColors.error,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.favorites);
          },
        ),
        _buildMenuTile(
          context,
          icon: Icons.settings,
          title: 'Configuración',
          subtitle: 'Preferencias y privacidad',
          color: AppColors.textSecondary,
          onTap: () {
            // TODO: Implementar pantalla de configuración
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Configuración próximamente'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        _buildMenuTile(
          context,
          icon: Icons.help_outline,
          title: 'Ayuda y Soporte',
          subtitle: 'Preguntas frecuentes',
          color: AppColors.info,
          onTap: () {
            // TODO: Implementar pantalla de ayuda
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ayuda próximamente'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDimensions.borderRadiusM,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceS),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppDimensions.borderRadiusS,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
      BuildContext context, FirebaseAuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cerrar Sesión'),
              content: const Text('¿Estás seguro que deseas cerrar sesión?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await authProvider.logout();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar Sesión'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spaceM,
          ),
        ),
      ),
    );
  }
}
