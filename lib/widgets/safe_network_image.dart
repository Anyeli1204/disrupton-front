import 'package:flutter/material.dart';
import '../utils/image_helper.dart';
import 'local_cultural_image.dart';

/// Widget que maneja imágenes de manera segura usando assets locales
/// En lugar de depender del backend, usa las imágenes almacenadas localmente
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
    // Si hay regionId, usar LocalCulturalImage para aprovechar las imágenes AR
    if (regionId != null) {
      return LocalCulturalImage(
        imageUrl: imageUrl,
        departmentId: regionId!,
        category: category,
        objectId: _extractObjectIdFromUrl(imageUrl),
        width: width,
        height: height,
        fit: fit,
      );
    }

    // Si hay fallbackAsset, usarlo directamente
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

    // Por defecto, mostrar placeholder
    return _buildPlaceholder();
  }

  /// Intenta extraer un ID del objeto desde la URL para usarlo como semilla
  String? _extractObjectIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.last.replaceAll(RegExp(r'\.[^.]+$'), '');
      }
    } catch (e) {
      // Si falla el parsing, retornar null
    }
    return null;
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
