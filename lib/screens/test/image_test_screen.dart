import 'package:flutter/material.dart';

class ImageTestScreen extends StatelessWidget {
  const ImageTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Imágenes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pruebas de carga de imágenes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Test 1: Lorem Picsum (HTTPS simple)
            _buildImageTest(
              'Lorem Picsum (HTTPS)',
              'https://picsum.photos/300/200?random=1',
            ),

            // Test 2: Unsplash (HTTPS con parámetros)
            _buildImageTest(
              'Unsplash (HTTPS con parámetros)',
              'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=300&h=200&fit=crop',
            ),

            // Test 3: HTTPBin (HTTP simple)
            _buildImageTest(
              'HTTPBin (HTTPS)',
              'https://httpbin.org/image/jpeg',
            ),

            // Test 4: Assets locales
            _buildImageTest(
              'Asset Local',
              'assets/images/logo.png',
              isAsset: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTest(String title, String imageUrl,
      {bool isAsset = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              imageUrl,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: isAsset
                  ? Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                Text('Error cargando asset'),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const Text('Error cargando imagen'),
                                const SizedBox(height: 8),
                                Text(
                                  error.toString(),
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
