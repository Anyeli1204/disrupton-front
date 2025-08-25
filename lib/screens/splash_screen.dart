import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/permission_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'role_selection_screen.dart';
import 'permission_flow_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simular carga inicial
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    if (!mounted) return;

    // Navegar según el estado de autenticación
    if (authProvider.isAuthenticated) {
      final needsRole = await authProvider.needsRoleSelection();
      if (needsRole) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      } else {
        // Check if permissions need to be shown
        final permissionsNeeded =
            await PermissionService.getPermissionsNeedingPopup();

        if (permissionsNeeded.isNotEmpty) {
          // Show permission flow for existing users with pending permissions
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PermissionFlowManager(
                isNewUser: false, // Existing user
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade600,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animado
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 60,
                      color: Colors.deepPurple.shade600,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Título con animación de fade
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 1, milliseconds: 500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: const Text(
                    'Disrupton',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Subtítulo
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'Explora la cultura con realidad aumentada',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            // Indicador de carga
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 1, milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
