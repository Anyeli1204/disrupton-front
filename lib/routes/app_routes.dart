import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/role_selection_screen.dart';
import '../screens/permission_flow_manager.dart';
import '../screens/tutorial_screen.dart';
import '../screens/home_screen.dart';
import '../screens/collections_screen.dart';
import '../screens/department_objects_screen.dart';
import '../screens/ar_view_screen.dart';
import '../screens/events_screen.dart';
import '../screens/event_detail_screen.dart';
import '../screens/create_edit_event_screen.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_events_screen.dart';
import '../screens/moderator_screen.dart';
import '../screens/guide_promotions_screen.dart';
import '../screens/artisan_products_screen.dart';
import '../screens/cultural_objects_feed_screen.dart';
import '../screens/cultural_objects_map_screen.dart';
import '../screens/mural_screen.dart';
import '../screens/agentes_culturales_screen.dart';
import '../screens/store_screen.dart';
import '../screens/favorites_screen.dart';
import '../models/collection_models.dart';
import '../models/pieza.dart';
import '../models/event.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';
  static const String permissionFlow = '/permission-flow';
  static const String tutorial = '/tutorial';
  static const String home = '/home';
  static const String collections = '/collections';
  static const String departmentObjects = '/department-objects';
  static const String objectDetail = '/object-detail';
  static const String arView = '/ar-view';
  static const String events = '/events';
  static const String eventDetail = '/event-detail';
  static const String createEditEvent = '/create-edit-event';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminEvents = '/admin-events';
  static const String moderator = '/moderator';
  static const String guidePromotions = '/guide-promotions';
  static const String artisanProducts = '/artisan-products';
  static const String culturalObjectsFeed = '/cultural-objects-feed';
  static const String culturalObjectsMap = '/cultural-objects-map';
  static const String mural = '/mural';
  static const String agentesCulturales = '/agentes-culturales';
  static const String store = '/store';
  static const String favorites = '/favorites';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      roleSelection: (context) => const RoleSelectionScreen(),
      tutorial: (context) => const TutorialScreen(),
      home: (context) => const HomeScreen(),
      collections: (context) => const CollectionsScreen(),
      events: (context) => const EventsScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
      adminEvents: (context) => const AdminEventsScreen(),
      moderator: (context) => const ModeratorScreen(),
      guidePromotions: (context) => const GuidePromotionsScreen(),
      artisanProducts: (context) => const ArtisanProductsScreen(),
      culturalObjectsFeed: (context) => const CulturalObjectsFeedScreen(),
      mural: (context) => const MuralScreen(),
      agentesCulturales: (context) => const AgentesCulturalesScreen(),
      store: (context) => const StoreScreen(),
      favorites: (context) => const FavoritesScreen(),
    };
  }

  // Navegación con argumentos
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case permissionFlow:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => PermissionFlowManager(
            isNewUser: args?['isNewUser'] ?? false,
          ),
        );

      case departmentObjects:
        final args = settings.arguments as Map<String, dynamic>?;
        final department = args?['department'] as Department?;
        if (department == null) {
          return _errorRoute('Departamento requerido');
        }
        return MaterialPageRoute(
          builder: (context) => DepartmentObjectsScreen(department: department),
        );

      case culturalObjectsMap:
        return MaterialPageRoute(
          builder: (context) =>
              const CulturalObjectsMapScreen(culturalObjects: []),
        );

      default:
        return _errorRoute('Ruta no encontrada: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos de navegación helpers
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate,
      arguments: arguments,
    );
  }
}
