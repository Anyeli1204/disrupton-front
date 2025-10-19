import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/auth_models.dart';
import '../routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_typography.dart';
import '../shared/widgets/cards/feature_card.dart';
import 'login_screen.dart';

/// Pantalla principal con diseño minimalista y moderno
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          return SingleChildScrollView(
            padding: AppDimensions.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bienvenida personalizada
                _buildWelcomeCard(user),

                const SizedBox(height: AppDimensions.spaceXL),

                // Funciones según el rol
                _buildRoleFunctions(context, user?.role ?? UserRole.user),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Disrupton',
        style: AppTypography.titleLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.surface,
      elevation: 0,
      actions: [
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(AppDimensions.spaceXS),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_circle,
                  color: AppColors.primary,
                ),
              ),
              onSelected: (String value) async {
                if (value == 'logout') {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusM,
              ),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: AppDimensions.iconS,
                      ),
                      const SizedBox(width: AppDimensions.spaceS),
                      Text(
                        authProvider.currentUser?.displayName ?? 'Usuario',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        size: AppDimensions.iconS,
                        color: AppColors.error,
                      ),
                      SizedBox(width: AppDimensions.spaceS),
                      Text('Cerrar sesión'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: AppDimensions.spaceS),
      ],
    );
  }

  Widget _buildWelcomeCard(user) {
    return Container(
      width: double.infinity,
      padding: AppDimensions.paddingL,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppDimensions.borderRadiusL,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, ${user?.displayName ?? 'Usuario'}!',
            style: AppTypography.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            'Bienvenido a Disrupton',
            style: AppTypography.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
              vertical: AppDimensions.spaceS,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: AppDimensions.borderRadiusL,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: AppDimensions.iconXS,
                ),
                const SizedBox(width: AppDimensions.spaceXS),
                Text(
                  'Rol: ${user?.role.description ?? 'Usuario'}',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFunctions(BuildContext context, UserRole role) {
    final functions = _getFunctionsByRole(role);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        Row(
          children: [
            const Icon(
              Icons.dashboard_outlined,
              color: AppColors.primary,
              size: AppDimensions.iconS,
            ),
            const SizedBox(width: AppDimensions.spaceS),
            Text(
              'Funciones disponibles',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimensions.spaceL),

        // Grid de funcionalidades
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: AppDimensions.spaceM,
            mainAxisSpacing: AppDimensions.spaceM,
          ),
          itemCount: functions.length,
          itemBuilder: (context, index) {
            final function = functions[index];
            return FeatureCard(
              icon: function['icon'],
              title: function['title'],
              subtitle: function['subtitle'],
              color: function['color'],
              onTap: () => _handleFunctionTap(context, function['action']),
            );
          },
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFunctionsByRole(UserRole role) {
    switch (role) {
      case UserRole.user:
        return [
          {
            'icon': Icons.collections_outlined,
            'title': 'Colecciones',
            'subtitle': 'Explora los 24 departamentos del Perú',
            'color': AppColors.primary,
            'action': 'collections',
          },
          {
            'icon': Icons.shopping_bag_outlined,
            'title': 'Tienda Cultural',
            'subtitle': 'Productos artesanales y servicios',
            'color': AppColors.store,
            'action': 'store',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Descubre eventos culturales',
            'color': AppColors.events,
            'action': 'events',
          },
          {
            'icon': Icons.museum_outlined,
            'title': 'Objetos Culturales',
            'subtitle': 'Explora patrimonio peruano',
            'color': AppColors.culture,
            'action': 'cultural_objects_feed',
          },
          {
            'icon': Icons.map_outlined,
            'title': 'Mapa Cultural',
            'subtitle': 'Descubre lugares cerca de ti',
            'color': AppColors.secondary,
            'action': 'cultural_objects_map',
          },
          {
            'icon': Icons.forum_outlined,
            'title': 'Mural Cultural',
            'subtitle': 'Participa en la comunidad',
            'color': AppColors.info,
            'action': 'mural',
          },
          {
            'icon': Icons.people_alt_outlined,
            'title': 'Agentes Culturales',
            'subtitle': 'Conecta con artesanos',
            'color': AppColors.accent,
            'action': 'agentes_culturales',
          },
          {
            'icon': Icons.share_outlined,
            'title': 'Red Cultural',
            'subtitle': 'Comparte experiencias',
            'color': AppColors.ar,
            'action': 'social_network',
          },
          {
            'icon': Icons.favorite_outline,
            'title': 'Favoritos',
            'subtitle': 'Guarda tus lugares favoritos',
            'color': AppColors.error,
            'action': 'favorites',
          },
        ];

      case UserRole.admin:
        return [
          {
            'icon': Icons.dashboard_outlined,
            'title': 'Panel de Admin',
            'subtitle': 'Gestiona usuarios y estadísticas',
            'color': AppColors.primary,
            'action': 'admin_dashboard',
          },
          {
            'icon': Icons.event_available_outlined,
            'title': 'Gestión de Eventos',
            'subtitle': 'Crea y administra eventos',
            'color': AppColors.events,
            'action': 'admin_events',
          },
          {
            'icon': Icons.people_outline,
            'title': 'Gestión de Usuarios',
            'subtitle': 'Administra roles y permisos',
            'color': AppColors.secondary,
            'action': 'admin_dashboard',
          },
        ];

      case UserRole.moderator:
        return [
          {
            'icon': Icons.shield_outlined,
            'title': 'Moderación',
            'subtitle': 'Revisa y aprueba solicitudes',
            'color': AppColors.info,
            'action': 'moderator_screen',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Ve eventos culturales',
            'color': AppColors.events,
            'action': 'events',
          },
          {
            'icon': Icons.history_outlined,
            'title': 'Historial',
            'subtitle': 'Revisa decisiones anteriores',
            'color': AppColors.secondary,
            'action': 'moderator_screen',
          },
        ];

      case UserRole.guide:
        return [
          {
            'icon': Icons.campaign_outlined,
            'title': 'Mis Promociones',
            'subtitle': 'Gestiona tours y experiencias',
            'color': AppColors.primary,
            'action': 'guide_promotions',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Descubre eventos',
            'color': AppColors.events,
            'action': 'events',
          },
          {
            'icon': Icons.add_business_outlined,
            'title': 'Crear Promoción',
            'subtitle': 'Diseña nuevas experiencias',
            'color': AppColors.secondary,
            'action': 'guide_promotions',
          },
        ];

      case UserRole.artisan:
        return [
          {
            'icon': Icons.inventory_2_outlined,
            'title': 'Mis Productos',
            'subtitle': 'Gestiona tu catálogo',
            'color': AppColors.store,
            'action': 'artisan_products',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Encuentra ferias artesanales',
            'color': AppColors.events,
            'action': 'events',
          },
          {
            'icon': Icons.add_shopping_cart_outlined,
            'title': 'Crear Producto',
            'subtitle': 'Añade nuevas creaciones',
            'color': AppColors.secondary,
            'action': 'artisan_products',
          },
        ];

      case UserRole.premium:
        return [
          {
            'icon': Icons.star_outline,
            'title': 'Contenido Exclusivo',
            'subtitle': 'Experiencias premium',
            'color': AppColors.warning,
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos VIP',
            'subtitle': 'Eventos exclusivos',
            'color': AppColors.events,
            'action': 'events',
          },
          {
            'icon': Icons.support_agent_outlined,
            'title': 'Soporte VIP',
            'subtitle': 'Atención prioritaria',
            'color': AppColors.secondary,
          },
        ];
    }
  }

  void _handleFunctionTap(BuildContext context, String? action) {
    if (action == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Función próximamente disponible'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    switch (action) {
      case 'collections':
        AppRoutes.pushNamed(context, AppRoutes.collections);
        break;
      case 'store':
        AppRoutes.pushNamed(context, AppRoutes.store);
        break;
      case 'events':
        AppRoutes.pushNamed(context, AppRoutes.events);
        break;
      case 'admin_events':
        AppRoutes.pushNamed(context, AppRoutes.adminEvents);
        break;
      case 'admin_dashboard':
        AppRoutes.pushNamed(context, AppRoutes.adminDashboard);
        break;
      case 'moderator_screen':
        AppRoutes.pushNamed(context, AppRoutes.moderator);
        break;
      case 'guide_promotions':
        AppRoutes.pushNamed(context, AppRoutes.guidePromotions);
        break;
      case 'artisan_products':
        AppRoutes.pushNamed(context, AppRoutes.artisanProducts);
        break;
      case 'cultural_objects_feed':
        AppRoutes.pushNamed(context, AppRoutes.culturalObjectsFeed);
        break;
      case 'cultural_objects_map':
        AppRoutes.pushNamed(
          context,
          AppRoutes.culturalObjectsMap,
          arguments: {'culturalObjects': []},
        );
        break;
      case 'mural':
        AppRoutes.pushNamed(context, AppRoutes.mural);
        break;
      case 'agentes_culturales':
        AppRoutes.pushNamed(context, AppRoutes.agentesCulturales);
        break;
      case 'social_network':
        AppRoutes.pushNamed(context, AppRoutes.socialNetwork);
        break;
      case 'favorites':
        AppRoutes.pushNamed(context, AppRoutes.favorites);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Función próximamente disponible'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}
