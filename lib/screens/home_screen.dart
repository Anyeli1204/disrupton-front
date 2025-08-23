import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/auth_models.dart';
import 'login_screen.dart';
import 'collections_screen.dart';
import 'admin_dashboard_screen.dart';
import 'moderator_screen.dart';
import 'guide_promotions_screen.dart';
import 'artisan_products_screen.dart';
import 'events_screen.dart';
import 'admin_events_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disrupton'),
        backgroundColor: Colors.deepPurple.shade600,
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
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade600,
                        Colors.deepPurple.shade400,
                      ],
                    ),
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
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.orange.shade600,
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
            'color': Colors.deepPurple,
            'action': 'collections',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Descubre eventos culturales y actividades',
            'color': Colors.orange,
            'action': 'events',
          },
          {
            'icon': Icons.explore_outlined,
            'title': 'Explorar contenido',
            'subtitle': 'Descubre tours y contenido cultural',
            'color': Colors.blue,
          },
          {
            'icon': Icons.favorite_outline,
            'title': 'Favoritos',
            'subtitle': 'Guarda tus lugares favoritos',
            'color': Colors.red,
          },
        ];
        break;
      case UserRole.admin:
        functions = [
          {
            'icon': Icons.dashboard_outlined,
            'title': 'Panel de administración',
            'subtitle': 'Gestiona usuarios y estadísticas',
            'color': Colors.purple,
            'action': 'admin_dashboard',
          },
          {
            'icon': Icons.event_available_outlined,
            'title': 'Gestión de eventos',
            'subtitle': 'Crea y administra eventos culturales',
            'color': Colors.orange,
            'action': 'admin_events',
          },
          {
            'icon': Icons.people_outline,
            'title': 'Gestión de usuarios',
            'subtitle': 'Administra roles y permisos',
            'color': Colors.indigo,
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
            'color': Colors.green,
            'action': 'moderator_screen',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Ve eventos culturales y actividades',
            'color': Colors.orange,
            'action': 'events',
          },
          {
            'icon': Icons.history_outlined,
            'title': 'Historial de moderación',
            'subtitle': 'Revisa decisiones anteriores',
            'color': Colors.orange.shade600,
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
            'color': Colors.teal,
            'action': 'guide_promotions',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Descubre eventos para promocionar',
            'color': Colors.orange,
            'action': 'events',
          },
          {
            'icon': Icons.add_business_outlined,
            'title': 'Crear promoción',
            'subtitle': 'Diseña nuevas experiencias turísticas',
            'color': Colors.cyan,
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
            'color': Colors.brown,
            'action': 'artisan_products',
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos',
            'subtitle': 'Encuentra ferias y eventos artesanales',
            'color': Colors.orange,
            'action': 'events',
          },
          {
            'icon': Icons.add_shopping_cart_outlined,
            'title': 'Crear producto',
            'subtitle': 'Añade nuevas creaciones',
            'color': Colors.deepOrange,
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
            'color': Colors.amber,
          },
          {
            'icon': Icons.event_outlined,
            'title': 'Eventos VIP',
            'subtitle': 'Eventos exclusivos para miembros premium',
            'color': Colors.orange,
            'action': 'events',
          },
          {
            'icon': Icons.support_agent_outlined,
            'title': 'Soporte VIP',
            'subtitle': 'Atención prioritaria',
            'color': Colors.yellow.shade700,
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
            const Text(
              'Funciones disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...functions
                .map((function) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Builder(
                        builder: (context) => ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: function['color'].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              function['icon'],
                              color: function['color'],
                              size: 24,
                            ),
                          ),
                          title: Text(
                            function['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(function['subtitle']),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            switch (function['action']) {
                              case 'collections':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CollectionsScreen(),
                                  ),
                                );
                                break;
                              case 'events':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EventsScreen(),
                                  ),
                                );
                                break;
                              case 'admin_events':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminEventsScreen(),
                                  ),
                                );
                                break;
                              case 'admin_dashboard':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminDashboardScreen(),
                                  ),
                                );
                                break;
                              case 'moderator_screen':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ModeratorScreen(),
                                  ),
                                );
                                break;
                              case 'guide_promotions':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const GuidePromotionsScreen(),
                                  ),
                                );
                                break;
                              case 'artisan_products':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ArtisanProductsScreen(),
                                  ),
                                );
                                break;
                              default:
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${function['title']} próximamente disponible'),
                                  ),
                                );
                            }
                          },
                        ),
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
