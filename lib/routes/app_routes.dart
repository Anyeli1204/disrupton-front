import 'package:disrupton_app/screens/cultural_objects_screen.dart';
import 'package:disrupton_app/screens/home_screen.dart';
import 'package:disrupton_app/screens/login_screen.dart';
import 'package:disrupton_app/screens/ar_screen.dart';
import 'package:disrupton_app/screens/ar_view_screen.dart';
import 'package:disrupton_app/screens/mural_screen.dart';
import 'package:disrupton_app/screens/cultural_agents_screen.dart';
import 'package:disrupton_app/screens/object_scan_screen.dart';
import 'package:disrupton_app/screens/model_3d_viewer_screen.dart';
import 'package:disrupton_app/screens/test_screen.dart';
import 'package:disrupton_app/models/cultural_object.dart'; // ✅ CAMBIADO
import 'package:disrupton_app/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String ar = '/ar';
  static const String arView = '/ar-view';
  static const String mural = '/mural';
  static const String culturalAgents = '/cultural-agents';
  static const String objectScan = '/object-scan';
  static const String modelViewer = '/model-viewer';
  static const String culturalObjects = '/cultural-objects';
  static const String test = '/test';

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';

        // Si no está autenticado y no está en login, redirigir a login
        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }

        // Si está autenticado y está en login, redirigir a home
        if (isAuthenticated && isLoggingIn) {
          return '/';
        }

        // No redirigir
        return null;
      },
      routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/ar',
        builder: (context, state) => const ARScreen(),
      ),
      GoRoute(
        path: '/ar-view',
        builder: (context, state) {
          // ✅ CAMBIADO: Usar CulturalObject
          final CulturalObject culturalObject = state.extra as CulturalObject;
          return ARViewScreen(culturalObject: culturalObject);
        },
      ),
      GoRoute(
        path: '/mural',
        builder: (context, state) => const MuralScreen(),
      ),
      GoRoute(
        path: '/cultural-agents',
        builder: (context, state) => const CulturalAgentsScreen(),
      ),
      GoRoute(
        path: '/object-scan',
        builder: (context, state) => const ObjectScanScreen(),
      ),
      GoRoute(
        path: '/model-viewer',
        builder: (context, state) {
          final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return Model3DViewerScreen(
            modelUrl: args['modelUrl']!,
            modelName: args['modelName']!, // ✅ CORREGIDO
            isLocalFile: args['isLocalFile'] ?? false,
          );
        },
      ),
      GoRoute(
        path: '/cultural-objects',
        builder: (context, state) => const CulturalObjectsScreen(),
      ),
      GoRoute(
        path: '/test',
        builder: (context, state) => const TestScreen(),
      ),
    ],
    );
  }
}