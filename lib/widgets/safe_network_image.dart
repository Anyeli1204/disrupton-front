import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final String? fallbackAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? regionId;
  final String? category;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.fallbackAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.regionId,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Intentar con imagen de respaldo
        if (fallbackAsset != null) {
          return Image.asset(
            fallbackAsset!,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          );
        }

        // Intentar con imagen automática basada en región o categoría
        if (regionId != null) {
          final workingUrl = ImageHelper.getWorkingImageForRegion(regionId!);
          return Image.network(
            workingUrl,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        }

        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    IconData iconData = Icons.image;

    if (category != null) {
      final cat = category!.toLowerCase();
      if (cat.contains('arquitectura'))
        iconData = Icons.account_balance;
      else if (cat.contains('cerámica'))
        iconData = Icons.local_florist;
      else if (cat.contains('textil'))
        iconData = Icons.checkroom;
      else if (cat.contains('orfebrería'))
        iconData = Icons.diamond;
      else if (cat.contains('escultura')) iconData = Icons.museum;
    }

    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            regionId != null ? regionId!.toUpperCase() : 'IMAGEN',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
