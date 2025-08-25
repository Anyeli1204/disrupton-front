import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/cultural_object.dart';
import '../widgets/cultural_object_marker.dart';

class CulturalObjectsMapScreen extends StatefulWidget {
  final List<CulturalObject> culturalObjects;

  const CulturalObjectsMapScreen({Key? key, required this.culturalObjects})
      : super(key: key);

  @override
  _CulturalObjectsMapScreenState createState() => _CulturalObjectsMapScreenState();
}

class _CulturalObjectsMapScreenState extends State<CulturalObjectsMapScreen> {
  // Define a constant for the approximate width of a carousel item
  static const double _carouselItemWidth = 120.0;

  final ScrollController _carouselController = ScrollController();
  final MapController _mapController = MapController();
  Set<Marker> _markers = {};
import 'widgets/cultural_object_carousel_item.dart';

  @override
  void initState() {
    super.initState();
    _addMarkers();
 _mapController.onReady.then((_) => _addMarkers());
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _addMarkers() {
    for (int i = 0; i < widget.culturalObjects.length; i++) {
      final CulturalObject object = widget.culturalObjects[i];
      _markers.add(
        Marker(
          point: LatLng(object.latitude, object.longitude), width: 80,
          height: 80,
          builder: (ctx) => CulturalObjectMarker(
 culturalObject: object, index: i, onTap: _scrollToCarouselItem,),
          onTap: () {
            _scrollToCarouselItem(i);
          },
        ),
      );
    }
  }

  void _scrollToCarouselItem(int index) {
    // Calculate the scroll offset to center the tapped item (approximately)
    final double offset = (index * _carouselItemWidth) - (MediaQuery.of(context).size.width / 2) + (_carouselItemWidth / 2);
    _carouselController.animateTo(offset,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cultural Objects Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: FlutterMap(
                  options: MapOptions(
 mapController: _mapController,
                    center: LatLng(-9.1900, -75.0152), // Centered on Peru
                    zoom: 5.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yourcompany.app', // Replace with your package name
                    ),
                    MarkerLayer(
                      markers: _markers.toList(),
                    ),
                  ]),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(controller: _carouselController, scrollDirection: Axis.horizontal, itemCount: widget.culturalObjects.length, // Use the actual list length
                  itemBuilder: (context, index) => CulturalObjectCarouselItem(culturalObject: widget.culturalObjects[index], onTap: (object) {
                          // Optional: Center map on carousel item tap
                          _mapController.move(LatLng(object.latitude, object.longitude), _mapController.zoom ?? 5.0);
                        })),
              ),
            ),
          ],
        ),
      ),
    );
  }
}