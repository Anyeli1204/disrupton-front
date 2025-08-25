import 'package:flutter/material.dart';
import '../models/cultural_object.dart';
import '../screens/cultural_object_detail_screen.dart';

class CulturalObjectCarouselItem extends StatelessWidget { 
  final CulturalObject culturalObject;
  final VoidCallback? onTap;

  const CulturalObjectCarouselItem({
    Key? key,
    required this.culturalObject,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
 final onTapHandler = onTap ??
 () {
 Navigator.push(
 context,
 MaterialPageRoute(
 builder: (context) => CulturalObjectDetailScreen(culturalObject: culturalObject)),
 );
 };
    return GestureDetector(
      onTap: onTapHandler,
      child: Container(
        width: 120, // Fixed width for the carousel item
        margin: EdgeInsets.symmetric(horizontal: 8.0), // Add some spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  culturalObject.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey), // Placeholder for error
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                culturalObject.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}