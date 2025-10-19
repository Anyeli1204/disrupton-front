import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

/// Widget para mostrar imágenes locales de objetos culturales
/// Usa las imágenes almacenadas en assets en lugar de cargarlas desde el backend
class LocalCulturalImage extends StatelessWidget {
  final String? imageUrl; // URL ignorada, se mantiene para compatibilidad
  final String departmentId;
  final String? category;
  final String? objectId;
  final double? width;
  final double? height;
  final BoxFit fit;

  const LocalCulturalImage({
    super.key,
    this.imageUrl,
    required this.departmentId,
    this.category,
    this.objectId,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener imagen basada en el departamento y el ID del objeto
    String assetPath;

    // Si el departamento tiene imágenes AR, usar una basada en el hash del ID
    if (ImageHelper.hasARImages(departmentId)) {
      final arImages = ImageHelper.getDepartmentARImages(departmentId);
      if (objectId != null && arImages.isNotEmpty) {
        // Usar el hash del ID para seleccionar una imagen consistente
        assetPath = ImageHelper.getImageByHash(arImages, objectId!);
      } else {
        // Si no hay objectId, usar la primera imagen AR
        assetPath = arImages.isNotEmpty
            ? arImages[0]
            : ImageHelper.getDepartmentImage(departmentId);
      }
    } else {
      // Si no hay imágenes AR, usar la imagen del departamento
      assetPath = ImageHelper.getDepartmentImage(departmentId);
    }

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
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
      else if (cat.contains('escultura'))
        iconData = Icons.museum;
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
            departmentId.toUpperCase(),
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
