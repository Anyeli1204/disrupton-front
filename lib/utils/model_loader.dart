import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// ignore: avoid_classes_with_only_static_members
/// Clase para manejar la carga y caché de modelos 3D

/// Clase para manejar la carga y caché de modelos 3D
class ModelLoader {
  static const String _cacheDir = 'model_cache';
  static Directory? _cacheDirectory;
  static final Map<String, Future<String?>> _downloadsInProgress = {};

  /// Carga un modelo 3D desde una URL con manejo de caché
  static Future<String?> cargarModeloDesdeUrl(
    String url, 
    String modelId, {
    bool forceRefresh = false,
  }) async {
    // Validaciones iniciales
    if (url.isEmpty) {
      debugPrint('Error: La URL del modelo está vacía');
      return null;
    }
    
    if (modelId.isEmpty) {
      debugPrint('Error: El ID del modelo está vacío');
      return null;
    }

    // Si ya hay una descarga en curso para este modelo, devolver esa promesa
    if (_downloadsInProgress.containsKey(modelId)) {
      return _downloadsInProgress[modelId];
    }

    final completer = Completer<String?>();
    _downloadsInProgress[modelId] = completer.future;

    try {
      debugPrint('🔄 Iniciando carga del modelo ID: $modelId');
      debugPrint('🔗 URL del modelo: $url');

      // Obtener URL de descarga directa
      final directDownloadUrl = _getDirectDownloadUrl(url);
      if (directDownloadUrl == null) {
        debugPrint('❌ Error: No se pudo construir la URL de descarga directa para $url');
        completer.complete(null);
        return null;
      }

      // Obtener ruta de caché
      final cachedPath = await _obtenerRutaCache(modelId);
      final cachedFile = File(cachedPath);

      // Verificar si el modelo ya está en caché
      if (await cachedFile.exists() && !forceRefresh) {
        final fileSize = await cachedFile.length();
        debugPrint('✅ Modelo $modelId encontrado en caché (${fileSize.toStringAsFixed(0)} bytes): $cachedPath');

        // Verificar tamaño mínimo del archivo (1KB)
        if (fileSize > 1024) {
          completer.complete(cachedPath);
          return cachedPath;
        } else {
          debugPrint('⚠️ Archivo en caché demasiado pequeño (${fileSize.toStringAsFixed(0)} bytes), forzando nueva descarga...');
          await cachedFile.delete();
        }
      }

      // Continuar con la descarga
      debugPrint('⬇️ Descargando modelo $modelId...');

      try {
        final client = http.Client();
        final request = await client.get(Uri.parse(directDownloadUrl));

        if (request.statusCode != 200) {
          throw Exception('Error al descargar el modelo: ${request.statusCode}');
        }

        // Asegurarse de que el directorio de caché existe
        await _ensureCacheDirectory();

        // Escribir el archivo en caché
        await cachedFile.writeAsBytes(request.bodyBytes, flush: true);

        // Verificar que el archivo se escribió correctamente
        final fileSize = await cachedFile.length();
        if (fileSize == 0) {
          throw Exception('El archivo descargado está vacío');
        }

        debugPrint('✅ Modelo $modelId descargado correctamente (${fileSize.toStringAsFixed(0)} bytes)');
        completer.complete(cachedPath);
        return cachedPath;

      } catch (e) {
        debugPrint('❌ Error al descargar el modelo $modelId: $e');
        // Intentar eliminar el archivo si está corrupto
        if (await cachedFile.exists()) {
          await cachedFile.delete();
        }
        completer.complete(null);
        return null;
      } finally {
        _downloadsInProgress.remove(modelId);
      }
    } catch (e) {
      debugPrint('❌ Error inesperado al cargar el modelo $modelId: $e');
      return null;
    }
  }

  /// Asegura que el directorio de caché exista
  static Future<void> _ensureCacheDirectory() async {
    _cacheDirectory ??= await getTemporaryDirectory();
    final cacheDir = Directory(path.join(_cacheDirectory!.path, _cacheDir));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
  }


  /// Limpia toda la caché de modelos descargados
  static Future<void> limpiarCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        debugPrint('Caché de modelos limpiada correctamente');
      }
    } catch (e) {
      debugPrint('Error al limpiar la caché: $e');
      rethrow;
    }
  }

  /// Obtiene el directorio de caché
  static Future<Directory> _getCacheDirectory() async {
    final dir = await getTemporaryDirectory();
    return Directory('${dir.path}/$_cacheDir');
  }

  /// Obtiene la ruta de caché para un modelo
  static Future<String> _obtenerRutaCache(String modelId) async {
    final cacheDir = await _getCacheDirectory();
    return '${cacheDir.path}/$modelId';
  }

  /// Construye una URL de descarga directa a partir de una URL de modelo
  static String? _getDirectDownloadUrl(String url) {
    try {
      // Si ya es una URL directa, devolverla tal cual
      if (url.endsWith('.glb') || url.endsWith('.gltf') || url.endsWith('.zip')) {
        return url;
      }
      
      // Aquí puedes agregar lógica adicional para transformar URLs de servicios específicos
      // Por ejemplo, si usas Google Drive, Dropbox, etc.
      
      return url; // Por defecto, devolver la URL original
    } catch (e) {
      debugPrint('Error al construir URL de descarga: $e');
      return null;
    }
  }
}
