import 'package:flutter/material.dart';
import '../models/cultural_object.dart';
 
class CulturalObjectDetailScreen extends StatelessWidget {
  final CulturalObject culturalObject;

  const CulturalObjectDetailScreen({Key? key, required this.culturalObject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(culturalObject.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              culturalObject.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              culturalObject.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            // TODO: Add 3D model viewer here
          ],
        ),
      ),
    );
  }
}