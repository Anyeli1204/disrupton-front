import 'package:flutter/material.dart';
import '../models/collection_models.dart';

class CulturalObjectDetailScreen extends StatelessWidget {
  final CulturalObject object;

  const CulturalObjectDetailScreen({
    super.key,
    required this.object,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar con imagen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.deepPurple.shade600,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade600,
                    ],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Aquí iría la imagen real
                    // Image.network(
                    //   object.imageUrl,
                    //   fit: BoxFit.cover,
                    //   errorBuilder: (context, error, stackTrace) => Container(...)
                    // ),

                    // Placeholder mientras tanto
                    const Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.white30,
                    ),

                    // Overlay gradiente
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareObject(context),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () => _toggleFavorite(context),
              ),
            ],
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y categoría
                  Text(
                    object.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      object.category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.deepPurple.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Descripción
                  _buildSection(
                    title: 'Descripción',
                    icon: Icons.description,
                    child: Text(
                      object.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Información adicional
                  if (object.additionalInfo != null &&
                      object.additionalInfo!.isNotEmpty)
                    _buildAdditionalInfo(),

                  const SizedBox(height: 24),

                  // Información del departamento
                  _buildSection(
                    title: 'Origen',
                    icon: Icons.place,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Departamento de ${_getDepartmentName(object.departmentId)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Registrado el ${_formatDate(object.createdAt)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botones de acción
                  _buildActionButtons(context),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.deepPurple.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return _buildSection(
      title: 'Información adicional',
      icon: Icons.info,
      child: Column(
        children: object.additionalInfo!.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    '${_capitalize(entry.key)}:',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _viewInAR(context),
            icon: const Icon(Icons.view_in_ar),
            label: const Text(
              'Ver en Realidad Aumentada',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showMoreInfo(context),
                icon: const Icon(Icons.info_outline),
                label: const Text('Más información'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple.shade600,
                  side: BorderSide(color: Colors.deepPurple.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addToCollection(context),
                icon: const Icon(Icons.bookmark_add),
                label: const Text('Guardar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.deepPurple.shade600,
                  side: BorderSide(color: Colors.deepPurple.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getDepartmentName(String departmentId) {
    // Mapeo simplificado de IDs a nombres
    final departmentNames = {
      'amazonas': 'Amazonas',
      'ancash': 'Áncash',
      'apurimac': 'Apurímac',
      'arequipa': 'Arequipa',
      'ayacucho': 'Ayacucho',
      'cajamarca': 'Cajamarca',
      'callao': 'Callao',
      'cusco': 'Cusco',
      'huancavelica': 'Huancavelica',
      'huanuco': 'Huánuco',
      'ica': 'Ica',
      'junin': 'Junín',
      'la_libertad': 'La Libertad',
      'lambayeque': 'Lambayeque',
      'lima': 'Lima',
      'loreto': 'Loreto',
      'madre_de_dios': 'Madre de Dios',
      'moquegua': 'Moquegua',
      'pasco': 'Pasco',
      'piura': 'Piura',
      'puno': 'Puno',
      'san_martin': 'San Martín',
      'tacna': 'Tacna',
      'tumbes': 'Tumbes',
    };

    return departmentNames[departmentId] ?? departmentId;
  }

  String _formatDate(DateTime date) {
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _shareObject(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de compartir en desarrollo'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleFavorite(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Agregado a favoritos'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewInAR(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Realidad Aumentada'),
        content: const Text(
          'Esta función abrirá el objeto en modo AR. '
          'Asegúrate de tener permisos de cámara activados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Aquí iría la navegación al viewer AR
            },
            child: const Text('Abrir AR'),
          ),
        ],
      ),
    );
  }

  void _showMoreInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(object.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${object.id}'),
              const SizedBox(height: 8),
              Text('Categoría: ${object.category}'),
              const SizedBox(height: 8),
              Text('Departamento: ${_getDepartmentName(object.departmentId)}'),
              const SizedBox(height: 8),
              Text('Fecha de registro: ${_formatDate(object.createdAt)}'),
              if (object.additionalInfo != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Información adicional:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...object.additionalInfo!.entries.map(
                  (entry) => Text('${_capitalize(entry.key)}: ${entry.value}'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _addToCollection(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${object.name} guardado en tu colección'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver colección',
          onPressed: () {
            // Navegar a la colección personal del usuario
          },
        ),
      ),
    );
  }
}
