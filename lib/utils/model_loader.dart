import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/pieza.dart';

class ModelLoader {
  static const String _cacheDir = 'model_cache';
  
  // Cargar modelo 3D desde URL
  static Future<String?> cargarModeloDesdeUrl(String url, String modelId) async {
    try {
      // Verificar si el modelo ya está en caché
      final cachedPath = await _obtenerRutaCache(modelId);
      if (await File(cachedPath).exists()) {
        return cachedPath;
      }

      // Descargar el modelo
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Guardar en caché
        final file = File(cachedPath);
        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        return cachedPath;
      } else {
        throw Exception('Error al descargar modelo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error cargando modelo: $e');
      return null;
    }
  }

  // Obtener ruta de caché para el modelo
  static Future<String> _obtenerRutaCache(String modelId) async {
    final cacheDir = await getTemporaryDirectory();
    final modelCacheDir = Directory('${cacheDir.path}/$_cacheDir');
    if (!await modelCacheDir.exists()) {
      await modelCacheDir.create(recursive: true);
    }
    return '${modelCacheDir.path}/$modelId.glb';
  }

  // Verificar formato del modelo
  static bool esFormatoValido(String url) {
    final extension = url.split('.').last.toLowerCase();
    return ['glb', 'gltf'].contains(extension);
  }

  // Obtener tamaño del modelo
  static Future<int?> obtenerTamañoModelo(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        return int.tryParse(response.headers['content-length'] ?? '0');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Limpiar caché de modelos
  static Future<void> limpiarCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final modelCacheDir = Directory('${cacheDir.path}/$_cacheDir');
      if (await modelCacheDir.exists()) {
        await modelCacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error limpiando caché: $e');
    }
  }

  // Obtener información del modelo
  static Future<Map<String, dynamic>?> obtenerInfoModelo(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Aquí podrías parsear el archivo GLB/GLTF para obtener metadatos
        // Por ahora retornamos información básica
        return {
          'tamaño': response.bodyBytes.length,
          'formato': url.split('.').last.toLowerCase(),
          'disponible': true,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Pre-cargar modelos para mejor rendimiento
  static Future<void> precargarModelos(List<Pieza> piezas) async {
    for (final pieza in piezas) {
      if (pieza.urlModelo3D.isNotEmpty) {
        await cargarModeloDesdeUrl(pieza.urlModelo3D, pieza.id);
      }
    }
  }

  // Verificar espacio disponible en caché
  static Future<bool> hayEspacioDisponible(int tamañoRequerido) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final stat = await cacheDir.stat();
      final espacioDisponible = stat.size;
      return espacioDisponible > tamañoRequerido;
    } catch (e) {
      return false;
    }
  }
}
