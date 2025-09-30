import 'package:flutter/material.dart';
import '../widgets/onirix_ar_view.dart';

class ExampleARScreen extends StatelessWidget {
  const ExampleARScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo de Realidad Aumentada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Experiencia de Realidad Aumentada con Onirix',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Vista previa de la experiencia AR
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                child: OnirixARView(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Abrir en pantalla completa'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Experiencia AR'),
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
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Apunta a una superficie plana y bien iluminada para ver el modelo en realidad aumentada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
