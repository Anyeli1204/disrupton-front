// Pantalla de Mapa de Objetos Culturales (de Yeimi)
import 'package:flutter/material.dart';
import '../models/cultural_object.dart';

class CulturalObjectsMapScreen extends StatefulWidget {
  final List<CulturalObject> culturalObjects;

  const CulturalObjectsMapScreen({super.key, required this.culturalObjects});

  @override
  State<CulturalObjectsMapScreen> createState() =>
      _CulturalObjectsMapScreenState();
}

class _CulturalObjectsMapScreenState extends State<CulturalObjectsMapScreen> {
  static const double _carouselItemWidth = 120.0;
  final ScrollController _carouselController = ScrollController();

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _scrollToCarouselItem(int index) {
    _carouselController.animateTo(
      index * _carouselItemWidth,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Cultural'),
        backgroundColor: Colors.deepPurple.shade600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Placeholder para el mapa (se puede integrar Google Maps o Mapbox más tarde)
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Mapa Cultural',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Integración con Google Maps próximamente',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista horizontal de objetos culturales
          Container(
            height: 120,
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              controller: _carouselController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.culturalObjects.length,
              itemBuilder: (context, index) {
                final object = widget.culturalObjects[index];
                return Container(
                  width: _carouselItemWidth,
                  margin: const EdgeInsets.only(right: 8),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                              color: Colors.grey.shade300,
                            ),
                            child: const Center(
                              child: Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            object.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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
    );
  }
}
