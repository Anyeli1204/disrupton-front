import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_theme.dart';
import 'providers/firebase_auth_provider.dart';
import 'providers/collection_provider.dart';
import 'providers/agentes_culturales_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Usar FirebaseAuthProvider en lugar de AuthProvider
        ChangeNotifierProvider(
          create: (context) => FirebaseAuthProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (context) => CollectionProvider()),
        ChangeNotifierProvider(
            create: (context) => AgentesCulturalesProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Disrupton App - Cultura Peruana AR',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
