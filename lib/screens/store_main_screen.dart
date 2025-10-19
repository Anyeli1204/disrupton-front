import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'store_screen.dart';

/// Pantalla principal de Tienda
/// Contiene productos y servicios culturales
class StoreMainScreen extends StatelessWidget {
  const StoreMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const StoreScreen(),
    );
  }
}
