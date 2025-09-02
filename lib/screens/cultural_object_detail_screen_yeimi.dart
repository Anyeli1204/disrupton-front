// Pantalla de Detalle de Objeto Cultural (versión unificada)
import 'package:flutter/material.dart';
import '../models/cultural_object.dart';

class CulturalObjectDetailScreen extends StatelessWidget {
  final CulturalObject culturalObject;

  const CulturalObjectDetailScreen({super.key, required this.culturalObject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(culturalObject.name),
        backgroundColor: Colors.deepPurple.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade300,
              ),
              child: culturalObject.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        culturalObject.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.museum,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Título
            Text(
              culturalObject.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 12),

            // Información básica
            _buildInfoCard(
              'Información General',
              [
                _InfoItem('Descripción', culturalObject.description),
                _InfoItem('Tipo Cultural', culturalObject.cultureType),
                _InfoItem('Origen', culturalObject.origin),
              ],
            ),

            const SizedBox(height: 16),

            // Historia
            if (culturalObject.history.isNotEmpty)
              _buildInfoCard(
                'Historia',
                [_InfoItem('', culturalObject.history)],
              ),

            const SizedBox(height: 16),

            // Ubicación
            _buildInfoCard(
              'Ubicación',
              [
                _InfoItem('Latitud', culturalObject.latitude.toString()),
                _InfoItem('Longitud', culturalObject.longitude.toString()),
              ],
            ),

            const SizedBox(height: 20),

            // Botón AR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar navegación a AR
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función AR próximamente disponible'),
                    ),
                  );
                },
                icon: const Icon(Icons.view_in_ar),
                label: const Text('Ver en Realidad Aumentada'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<_InfoItem> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildInfoRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    if (item.label.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          item.value,
          style: const TextStyle(height: 1.5),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '${item.label}:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.value,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}
