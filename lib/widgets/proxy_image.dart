import 'package:flutter/material.dart';
import '../config/app_config.dart';

class ProxyImage extends StatefulWidget {
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
  State<ProxyImage> createState() => _ProxyImageState();
}

class _ProxyImageState extends State<ProxyImage> {
  bool _useProxy = false;

  @override
  Widget build(BuildContext context) {
    print(
        '📱 ProxyImage - Cargando imagen: ${widget.imageUrl}, useProxy: $_useProxy');

    if (_useProxy) {
      // Usar el endpoint proxy del backend
      final proxyUrl =
          '${AppConfig.baseUrl}/api/firebase/storage/image-proxy?imageUrl=${Uri.encodeComponent(widget.imageUrl)}';
      print('📱 ProxyImage - Usando proxy: $proxyUrl');

      return Image.network(
        proxyUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ ProxyImage - Error cargando imagen con proxy: $error');
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey, size: 32),
                Text('Error cargando imagen',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        },
      );
    } else {
      // Intentar cargar directamente desde Firebase Storage
      return Image.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ ProxyImage - Error cargando imagen directa: $error');

          // Si falla la carga directa, cambiar a proxy
          if (!_useProxy) {
            print('🔄 ProxyImage - Cambiando a proxy debido a error');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _useProxy = true;
                });
              }
            });
          }

          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.grey, size: 32),
                Text('Cargando...',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        },
      );
    }
  }
}
