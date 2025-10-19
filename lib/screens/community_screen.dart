import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'red_cultural_screen.dart';

/// Pantalla de Comunidad - Red Cultural
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Red Cultural tiene su propio AppBar dentro del NestedScrollView
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const RedCulturalScreen(),
    );
  }
}
