import 'package:flutter/material.dart';
import '../models/cultural_object.dart';

class CulturalObjectMarker extends StatelessWidget {
  final CulturalObject culturalObject;
  final VoidCallback? onTap;

  const CulturalObjectMarker({
    Key? key,
    required this.culturalObject,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20, // Adjust the size as needed
            backgroundImage: NetworkImage(culturalObject.imageUrl),
            backgroundColor: Colors.grey[200], // Placeholder color
          ),
          // Optional: Add the object name below the image
          // Padding(
          //   padding: const EdgeInsets.only(top: 4.0),
          //   child: Text(
          //     culturalObject.name,
          //     style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          //     overflow: TextOverflow.ellipsis,
          //   ),
          // ),
        ],
      ),
    );
  }
}