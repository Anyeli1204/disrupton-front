// Widget de Tile de Objeto Cultural (de Yeimi)
import 'package:flutter/material.dart';
import '../models/cultural_object.dart';
import 'proxy_image.dart';

class CulturalObjectListTile extends StatelessWidget {
  final CulturalObject culturalObject;

  const CulturalObjectListTile({super.key, required this.culturalObject});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: culturalObject.imageUrl.isNotEmpty
              ? ProxyImage(
                  imageUrl: culturalObject.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.account_balance),
                ),
        ),
        title: Text(
          culturalObject.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              culturalObject.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    culturalObject.origin,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Tipo: ${culturalObject.cultureType}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            // TODO: Navigate to detail screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ver detalles de ${culturalObject.name}')),
            );
          },
        ),
        onTap: () {
          // TODO: Navigate to detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ver detalles de ${culturalObject.name}')),
          );
        },
      ),
    );
  }
}
