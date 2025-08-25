import 'package:flutter/material.dart';
import '../models/cultural_object.dart';
import '../screens/cultural_object_detail_screen.dart'; // Import the detail screen
class CulturalObjectListTile extends StatelessWidget {
  final CulturalObject culturalObject;

  const CulturalObjectListTile({
    Key? key,
    required this.culturalObject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
 return InkWell(
 onTap: () {
 Navigator.push(
 context,
 MaterialPageRoute(
 builder: (context) => CulturalObjectDetailScreen(culturalObject: culturalObject),
 ),
 );
      },
      child: ListTile(
        leading: culturalObject.imageUrl.isNotEmpty
            ? Image.network(
                culturalObject.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey,
                    child: Icon(Icons.broken_image),
                  );
                },
              )
            : Container(
                width: 50,
                height: 50,
                color: Colors.grey,
                child: Icon(Icons.image_not_supported),
              ),
        title: Text(
          culturalObject.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          culturalObject.description.isNotEmpty
              ? culturalObject.description
              : 'No description available.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}