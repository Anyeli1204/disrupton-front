import 'package:flutter/material.dart';
import 'cultural_agents_screen.dart';
import 'mural_screen.dart';
import 'ar_view_screen.dart';
import '../models/pieza.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DISRUPTON'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de bienvenida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.view_in_ar,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '¡Bienvenido a DISRUPTON!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                                                         Text(
                               'Realidad Aumentada para Exploración Cultural',
                               style: TextStyle(
                                 fontSize: 16,
                                 color: Colors.white.withValues(alpha: 0.9),
                               ),
                             ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Sección de funcionalidades principales
            const Text(
              'Funcionalidades Principales',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Grid de funcionalidades
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildFeatureCard(
                  icon: Icons.view_in_ar,
                  title: 'Realidad Aumentada',
                  subtitle: 'Explora piezas culturales en 3D',
                  color: Colors.deepPurple,
                  onTap: () => _navigateToAR(),
                ),
                _buildFeatureCard(
                  icon: Icons.people,
                  title: 'Agentes Culturales',
                  subtitle: 'Conoce artesanos y guías',
                  color: Colors.orange,
                  onTap: () => _navigateToCulturalAgents(),
                ),
                _buildFeatureCard(
                  icon: Icons.forum,
                  title: 'Mural Cultural',
                  subtitle: 'Participa en la comunidad',
                  color: Colors.green,
                  onTap: () => _navigateToMural(),
                ),
                _buildFeatureCard(
                  icon: Icons.explore,
                  title: 'Explorar',
                  subtitle: 'Descubre más funcionalidades',
                  color: Colors.blue,
                  onTap: () => _showComingSoon(),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Sección de información adicional
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.deepPurple[600],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Acerca de DISRUPTON',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DISRUPTON es una plataforma innovadora que combina realidad aumentada con exploración cultural. '
                    'Descubre piezas históricas en 3D, conecta con agentes culturales y participa en nuestra comunidad virtual.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAR() {
    // Crear una pieza de ejemplo para probar
    final piezaEjemplo = Pieza(
      id: '1',
      nombre: 'Pieza Demo',
      descripcion: 'Una pieza de ejemplo para probar la funcionalidad AR',
      urlModelo3D: 'https://ejemplo.com/modelo.gltf',
      urlImagen: 'https://ejemplo.com/imagen.jpg',
      categoria: 'Demo',
      epoca: 'Época moderna',
      ubicacion: 'Museo Virtual',
      escala: 1.0,
      posicionInicial: [0.0, 0.0, -0.5],
      rotacionInicial: [0.0, 0.0, 0.0],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ARViewScreen(pieza: piezaEjemplo),
      ),
    );
  }

  void _navigateToCulturalAgents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CulturalAgentsScreen(),
      ),
    );
  }

  void _navigateToMural() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MuralScreen(),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Más funcionalidades próximamente!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
