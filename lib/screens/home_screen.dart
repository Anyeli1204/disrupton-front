import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cultural_agents_screen.dart';
import 'mural_screen.dart';
import '../widgets/onirix_ar_view.dart';
import '../routes/app_routes.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('DISRUPTON'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
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
                            Text(
                              '¡Hola, ${user?.name ?? 'Usuario'}!',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Explora la cultura con realidad aumentada',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
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
            
            // Main Features Section
            const Text(
              'Funcionalidades',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Features Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildFeatureCard(
                  icon: Icons.view_in_ar,
                  title: 'Realidad Aumentada',
                  subtitle: 'Explora modelos 3D',
                  color: Colors.deepPurple,
                  onTap: _navigateToAR,
                ),
                _buildFeatureCard(
                  icon: Icons.people,
                  title: 'Agentes Culturales',
                  subtitle: 'Conoce a los creadores',
                  color: Colors.orange,
                  onTap: _navigateToCulturalAgents,
                ),
                _buildFeatureCard(
                  icon: Icons.forum,
                  title: 'Mural',
                  subtitle: 'Comunidad cultural',
                  color: Colors.green,
                  onTap: _navigateToMural,
                ),
                _buildFeatureCard(
                  icon: Icons.camera_alt,
                  title: 'Escanear 3D',
                  subtitle: 'Digitaliza objetos',
                  color: Colors.blue,
                  onTap: _navigateToObjectScan,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Additional Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explora la cultura',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Descubre piezas culturales en realidad aumentada y conecta con la comunidad de creadores.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Experiencia AR'),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white
          ),
          body: OnirixARView(
            accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjc2ODQ5LCJwcm9qZWN0SWQiOjEyNDAyMSwicm9sZSI6MywiaWF0IjoxNzU5MDMxMzg5fQ.p3bL68IkSTfVbZDEvHEr5ohpS5moyI4JOSBoEC9u6hk',
            onError: (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ),
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

  void _navigateToObjectScan() {
    Navigator.pushNamed(context, AppRoutes.objectScan);
  }
  
}
