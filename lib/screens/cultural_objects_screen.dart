import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../models/cultural_object.dart';
import '../services/cultural_object_service.dart';
import 'model_3d_viewer_screen.dart';

class CulturalObjectsScreen extends StatefulWidget {
  const CulturalObjectsScreen({Key? key}) : super(key: key);

  @override
  _CulturalObjectsScreenState createState() => _CulturalObjectsScreenState();
}

class _CulturalObjectsScreenState extends State<CulturalObjectsScreen> {
  final CulturalObjectService _culturalObjectService = CulturalObjectService();
  late Future<List<CulturalObject>> _culturalObjectsFuture;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadObjects();
  }

  void _loadObjects() {
    setState(() {
      _culturalObjectsFuture = _culturalObjectService.getAllObjects().then((objects) {
        print('📦 Loaded ${objects.length} objects from backend');
        for (var obj in objects) {
          print('  - ${obj.name}: model3dUrl = ${obj.model3dUrl}');
        }
        return objects;
      });
    });
  }

  List<CulturalObject> _filterObjects(List<CulturalObject> objects) {
    var filtered = objects;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((obj) =>
              obj.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              obj.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply category filter
    if (_selectedFilter != 'all') {
      filtered = filtered
          .where((obj) => obj.culturalType == _selectedFilter)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colección Cultural'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadObjects,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con gradiente
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Explora objetos culturales en 3D',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Visualiza y experimenta en realidad aumentada',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar objetos culturales...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Todos', 'all'),
                _buildFilterChip('Artesanía', 'ARTESANIA'),
                _buildFilterChip('Arquitectura', 'ARQUITECTURA'),
                _buildFilterChip('Escultura', 'ESCULTURA'),
                _buildFilterChip('Otro', 'OTRO'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Objects grid
          Expanded(
            child: FutureBuilder<List<CulturalObject>>(
              future: _culturalObjectsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                        ),
                        SizedBox(height: 16),
                        Text('Cargando colección...'),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadObjects,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.collections, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No se encontraron objetos culturales',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Escanea un objeto para empezar tu colección',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final objects = _filterObjects(snapshot.data!);

                if (objects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'No se encontraron resultados',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: objects.length,
                  itemBuilder: (context, index) {
                    return _buildObjectCard(objects[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/object-scan'),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text('Escanear', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        selectedColor: Colors.deepPurple.withOpacity(0.2),
        checkmarkColor: Colors.deepPurple,
        labelStyle: TextStyle(
          color: isSelected ? Colors.deepPurple : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildObjectCard(CulturalObject object) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showObjectDetails(object),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 3D Preview o imagen
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.grey[200],
                child: object.model3dUrl != null && object.model3dUrl!.isNotEmpty
                    ? _build3DPreview(object.model3dUrl!)
                    : object.imageUrl != null && object.imageUrl!.isNotEmpty
                        ? Image.network(
                            object.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
              ),
            ),

            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      object.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      object.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (object.model3dUrl != null && object.model3dUrl!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.view_in_ar, size: 14, color: Colors.deepPurple),
                                SizedBox(width: 4),
                                Text(
                                  '3D',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DPreview(String modelUrl) {
    return Stack(
      children: [
        ModelViewer(
          src: modelUrl,
          alt: 'Vista previa 3D',
          autoRotate: true,
          cameraControls: false,
          backgroundColor: const Color(0xFFEEEEEE),
          loading: Loading.eager,
          disableZoom: true,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.threed_rotation,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.museum,
        size: 64,
        color: Colors.grey[400],
      ),
    );
  }

  void _showObjectDetails(CulturalObject object) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            object.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Type badge
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(
                                label: Text(object.culturalType ?? 'Sin categoría'),
                                backgroundColor: Colors.deepPurple.withOpacity(0.1),
                                labelStyle: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (object.theme != null && object.theme!.isNotEmpty)
                                Chip(
                                  label: Text(object.theme!),
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // 3D Preview grande
                          if (object.model3dUrl != null && object.model3dUrl!.isNotEmpty)
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: ModelViewer(
                                  src: object.model3dUrl!,
                                  alt: 'Modelo 3D de ${object.name}',
                                  ar: true,
                                  arModes: const ['webxr', 'scene-viewer', 'quick-look'],
                                  autoRotate: true,
                                  cameraControls: true,
                                  backgroundColor: const Color(0xFFEEEEEE),
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Description
                          const Text(
                            'Descripción',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            object.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Additional info
                          if (object.culture != null || object.period != null || object.region != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Información adicional',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (object.culture != null)
                                  _buildInfoRow(Icons.people, 'Cultura', object.culture!),
                                if (object.period != null)
                                  _buildInfoRow(Icons.calendar_today, 'Período', object.period!),
                                if (object.region != null)
                                  _buildInfoRow(Icons.location_on, 'Región', object.region!),
                              ],
                            ),

                          const SizedBox(height: 32),

                          // Action buttons
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: object.model3dUrl != null && object.model3dUrl!.isNotEmpty
                                  ? () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Model3DViewerScreen(
                                            modelUrl: object.model3dUrl!,
                                            modelName: object.name,
                                            isLocalFile: false,
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.threed_rotation, color: Colors.white),
                              label: const Text('Abrir Visor 3D con AR', style: TextStyle(color: Colors.white, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
