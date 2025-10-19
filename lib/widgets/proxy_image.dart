import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

/// Widget optimizado para mostrar imágenes usando assets locales
/// En lugar de cargar desde el backend o Firebase, usa las imágenes almacenadas localmente
class ProxyImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const ProxyImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Usar imagen local basada en el hash de la URL
    String localImage;

    // Determinar qué tipo de imagen es basándose en el contexto de la URL
    if (imageUrl.contains('post') || imageUrl.contains('social')) {
      localImage = ImageHelper.getImageByHash(ImageHelper.postImages, imageUrl);
    } else if (imageUrl.contains('product')) {
      localImage = ImageHelper.getImageByHash(ImageHelper.productImages, imageUrl);
    } else if (imageUrl.contains('service')) {
      localImage = ImageHelper.getImageByHash(ImageHelper.serviceImages, imageUrl);
    } else if (imageUrl.contains('event')) {
      localImage = ImageHelper.getImageByHash(ImageHelper.eventImages, imageUrl);
    } else {
      // Por defecto, usar imágenes de posts
      localImage = ImageHelper.getImageByHash(ImageHelper.postImages, imageUrl);
    }

    return Image.asset(
      localImage,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, color: Colors.grey, size: 32),
              SizedBox(height: 4),
              Text(
                'Imagen no disponible',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
