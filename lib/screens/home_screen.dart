import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/auth_models.dart';
import '../routes/app_routes.dart';
import '../config/app_theme.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disrupton'),
        backgroundColor: AppTheme.primaryCeleste,
        foregroundColor: Colors.white,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
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
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline),
                        const SizedBox(width: 8),
                        Text(
                            authProvider.currentUser?.displayName ?? 'Usuario'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Cerrar sesión'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bienvenida personalizada
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, ${user?.displayName ?? 'Usuario'}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bienvenido a Disrupton',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Rol: ${user?.role.description ?? 'Usuario'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Información del usuario
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información de la cuenta',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.email_outlined,
                          'Email',
                          user?.email ?? 'No disponible',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.badge_outlined,
                          'ID de Usuario',
                          user?.userId ?? 'No disponible',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.verified_user_outlined,
                          'Estado',
                          user?.isActive == true ? 'Activo' : 'Inactivo',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Funciones según el rol
                _buildRoleFunctions(user?.role ?? UserRole.user),

                const SizedBox(height: 24),

                // Botón de realidad aumentada
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: Navegar a la pantalla AR
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función AR próximamente disponible'),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: AppTheme.primaryYellowDark,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explorar con AR',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Descubre la cultura con realidad aumentada',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleFunctions(UserRole role) {
    List<Map<String, dynamic>> functions = [];

    switch (role) {
      case UserRole.user:
        functions = [
          {
            'icon': Icons.collections_outlined,
            'title': 'Colecciones',
            'subtitle': 'Explora los 24 departamentos del Perú',
            'color': AppTheme.primaryCeleste,
            'action': 'collections',
          },
          {
            'icon': Icons.shopping_bag_outlined,
            'title': 'Tienda Cultural',
            'subtitle': 'Productos artesanales y servicios turísticos',
            'color': AppTheme.primaryYellow,
            'action': 'store',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Descubre eventos culturales y actividades',
            'color': AppTheme.primaryCelesteLight,
            'action': 'events',
          },
          {
            'icon': Icons.museum_outlined,
            'title': 'Objetos Culturales',
            'subtitle': 'Explora patrimonio cultural peruano',
            'color': AppTheme.primaryYellowLight,
            'action': 'cultural_objects_feed',
          },
          {
            'icon': Icons.map_outlined,
            'title': 'Mapa Cultural',
            'subtitle': 'Descubre lugares cerca de ti',
            'color': AppTheme.primaryCelesteDark,
            'action': 'cultural_objects_map',
          },
          {
            'icon': Icons.forum_outlined,
            'title': 'Mural Cultural',
            'subtitle': 'Participa en la comunidad',
            'color': AppTheme.primaryYellowDark,
            'action': 'mural',
          },
          {
            'icon': Icons.people_alt_outlined,
            'title': 'Agentes Culturales',
            'subtitle': 'Conecta con artesanos y guías',
            'color': const Color(0xFF26A69A),
            'action': 'agentes_culturales',
          },
          {
            'icon': Icons.share_outlined,
            'title': 'Red Cultural',
            'subtitle': 'Comparte experiencias y descubrimientos',
            'color': const Color(0xFFFFB74D),
            'action': 'social_network',
          },
          {
            'icon': Icons.explore_outlined,
            'title': 'Explorar contenido',
            'subtitle': 'Descubre tours y contenido cultural',
            'color': AppTheme.primaryCeleste,
          },
          {
            'icon': Icons.favorite_outline,
            'title': 'Favoritos',
            'subtitle': 'Guarda tus lugares favoritos',
            'color': AppTheme.primaryYellow,
          },
        ];
        break;
      case UserRole.admin:
        functions = [
          {
            'icon': Icons.dashboard_outlined,
            'title': 'Panel de administración',
            'subtitle': 'Gestiona usuarios y estadísticas',
            'color': AppTheme.primaryCeleste,
            'action': 'admin_dashboard',
          },
          {
            'icon': Icons.event_available_outlined,
            'title': 'Gestión de eventos',
            'subtitle': 'Crea y administra eventos culturales',
            'color': AppTheme.primaryYellow,
            'action': 'admin_events',
          },
          {
            'icon': Icons.people_outline,
            'title': 'Gestión de usuarios',
            'subtitle': 'Administra roles y permisos',
            'color': AppTheme.primaryCelesteDark,
            'action': 'admin_dashboard',
          },
        ];
        break;
      case UserRole.moderator:
        functions = [
          {
            'icon': Icons.shield_outlined,
            'title': 'Moderación de contenido',
            'subtitle': 'Revisa y aprueba solicitudes',
            'color': AppTheme.primaryCelesteLight,
            'action': 'moderator_screen',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Ve eventos culturales y actividades',
            'color': AppTheme.primaryYellowLight,
            'action': 'events',
          },
          {
            'icon': Icons.history_outlined,
            'title': 'Historial de moderación',
            'subtitle': 'Revisa decisiones anteriores',
            'color': AppTheme.primaryYellowDark,
            'action': 'moderator_screen',
          },
        ];
        break;
      case UserRole.guide:
        functions = [
          {
            'icon': Icons.campaign_outlined,
            'title': 'Mis promociones',
            'subtitle': 'Gestiona tours y experiencias',
            'color': AppTheme.primaryCeleste,
            'action': 'guide_promotions',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Descubre eventos para promocionar',
            'color': AppTheme.primaryYellow,
            'action': 'events',
          },
          {
            'icon': Icons.add_business_outlined,
            'title': 'Crear promoción',
            'subtitle': 'Diseña nuevas experiencias turísticas',
            'color': AppTheme.primaryCelesteDark,
            'action': 'guide_promotions',
          },
        ];
        break;
      case UserRole.artisan:
        functions = [
          {
            'icon': Icons.inventory_2_outlined,
            'title': 'Mis productos',
            'subtitle': 'Gestiona tu catálogo artesanal',
            'color': AppTheme.primaryCelesteLight,
            'action': 'artisan_products',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Encuentra ferias y eventos artesanales',
            'color': AppTheme.primaryYellowLight,
            'action': 'events',
          },
          {
            'icon': Icons.add_shopping_cart_outlined,
            'title': 'Crear producto',
            'subtitle': 'Añade nuevas creaciones',
            'color': AppTheme.primaryYellowDark,
            'action': 'artisan_products',
          },
        ];
        break;
      case UserRole.premium:
        functions = [
          {
            'icon': Icons.star_outline,
            'title': 'Contenido exclusivo',
            'subtitle': 'Accede a experiencias premium',
            'color': AppTheme.primaryYellow,
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos VIP',
            'subtitle': 'Eventos exclusivos para miembros premium',
            'color': AppTheme.primaryCeleste,
            'action': 'events',
          },
          {
            'icon': Icons.support_agent_outlined,
            'title': 'Soporte VIP',
            'subtitle': 'Atención prioritaria',
            'color': AppTheme.primaryYellowDark,
          },
        ];
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.apps,
                  color: AppTheme.primaryCeleste,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Funciones disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columnas
                childAspectRatio:
                    1.3, // Proporción más horizontal para dar más espacio
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: functions.length,
              itemBuilder: (context, index) {
                final function = functions[index];
                return _buildFunctionCard(context, function);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionCard(
      BuildContext context, Map<String, dynamic> function) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          switch (function['action']) {
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
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${function['title']} próximamente disponible'),
                  backgroundColor: AppTheme.primaryCeleste,
                ),
              );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12), // Reducido de 16 a 12
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                function['color'].withOpacity(0.1),
                function['color'].withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Añadido para minimizar el espacio
            children: [
              Container(
                padding: const EdgeInsets.all(8), // Reducido de 12 a 8
                decoration: BoxDecoration(
                  color: function['color'].withOpacity(0.15),
                  borderRadius:
                      BorderRadius.circular(10), // Reducido de 12 a 10
                ),
                child: Icon(
                  function['icon'],
                  color: function['color'],
                  size: 24, // Reducido de 28 a 24
                ),
              ),
              const SizedBox(height: 8), // Reducido de 12 a 8
              Text(
                function['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12, // Reducido de 13 a 12
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // Reducido de 4 a 2
              Text(
                function['subtitle'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9, // Reducido de 10 a 9
                  color: AppTheme.textSecondary,
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
