import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';
import 'package:archive/archive.dart';
import 'cultural_object_service.dart';
import '../models/cultural_object.dart';
import 'auth_service.dart'; // Importar AuthService

class ObjectScanService {
  final String baseUrl = AppConfig.baseUrl;
  final CulturalObjectService _culturalObjectService = CulturalObjectService();
  final AuthService _authService = AuthService(); // Instancia de AuthService
  
  Future<Map<String, dynamic>> uploadImages(
    List<File> imageFiles, {
    String? objectName,
    int modelQuality = 1,
    int textureQuality = 1,
    String fileFormat = 'GLB',
    int isMask = 1,
    int textureSmoothing = 1,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/api/kiri-engine/upload-images');
      
      print('🔍 Uploading to: $uri');
      print('🔍 Images count: ${imageFiles.length}');
      
      print('🔍 Testing basic connectivity...');
      var testResponse = await http.get(
        Uri.parse('$baseUrl/api/kiri-engine/health'),
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'DisruptonApp/1.0',
        },
      ).timeout(const Duration(seconds: 5));
      
      if (testResponse.statusCode != 200) {
        throw Exception('Backend no responde. Status: ${testResponse.statusCode}');
      }
      print('✅ Basic connectivity OK');
      
      if (imageFiles.length < 20) {
        throw Exception('Se requieren al menos 20 imágenes para Kiri Engine');
      }
      
      if (imageFiles.length > 300) {
        throw Exception('Kiri Engine acepta máximo 300 imágenes');
      }
      
      int totalSize = 0;
      for (var file in imageFiles) {
        int fileSize = await file.length();
        totalSize += fileSize;
        if (fileSize > 5 * 1024 * 1024) {
          print('⚠️ Imagen grande detectada: ${file.path} (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB)');
        }
      }
      print('📊 Tamaño total: ${(totalSize / 1024 / 1024).toStringAsFixed(1)}MB');
      
      if (totalSize > 50 * 1024 * 1024) {
        throw Exception('El tamaño total es demasiado grande para ngrok free (${(totalSize / 1024 / 1024).toStringAsFixed(1)}MB). Límite: 50MB');
      }
      
      var client = http.Client();
      var request = http.MultipartRequest('POST', uri);
      
      // Obtener headers de autenticación
      final authHeaders = _authService.getAuthHeaders();
      
      request.headers.addAll({
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'DisruptonApp/1.0',
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        ...authHeaders, // Añadir los headers de autenticación
      });
      
      request.fields.addAll({
        'modelQuality': modelQuality.toString(),
        'textureQuality': textureQuality.toString(),
        'fileFormat': fileFormat,
        'isMask': isMask.toString(),
        'textureSmoothing': textureSmoothing.toString(),
      });
      
      print('🔍 Adding files to request...');
      for (int i = 0; i < imageFiles.length; i++) {
        var file = imageFiles[i];
        try {
          var mimeType = lookupMimeType(file.path);
          var extension = mimeType?.split('/').last ?? 'jpg';
          
          var multipartFile = await http.MultipartFile.fromPath(
            'imagesFiles',
            file.path,
            contentType: MediaType('image', extension),
          );
          
          request.files.add(multipartFile);
          print('✅ Added file ${i + 1}/${imageFiles.length}: ${file.path.split('/').last}');
        } catch (e) {
          print('❌ Error adding file $i: $e');
          client.close();
          throw Exception('Error processing image $i: $e');
        }
      }
      
      print('🔍 Sending request...');
      
      var response = await client.send(request).timeout(
        const Duration(minutes: 15),
        onTimeout: () {
          client.close();
          throw Exception('Timeout: La subida tardó más de 15 minutos');
        },
      );
      
      print('🔍 Response received, reading data...');
      var responseData = await response.stream.bytesToString();
      client.close();
      
      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response data: $responseData');
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to upload images: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      print('❌ Upload error: $e');
      
      if (e.toString().contains('Connection reset by peer')) {
        print('💡 Sugerencias para "Connection reset by peer":');
        print('   1. Verificar que ngrok esté corriendo');
        print('   2. Verificar que el backend Spring Boot esté corriendo');
        print('   3. Intentar con menos imágenes');
        print('   4. Verificar el tamaño total de las imágenes');
        print('   5. Intentar con HTTP en lugar de HTTPS');
      }
      
      throw Exception('Error uploading images: $e');
    }
  }

  Future<Map<String, dynamic>> uploadVideo(
    File videoFile, {
    String? objectName,
    int modelQuality = 1,
    int textureQuality = 1,
    String fileFormat = 'GLB',
    int isMask = 1,
    int textureSmoothing = 1,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/api/kiri-engine/upload-video');
      
      print('🔍 Uploading video to: $uri');
      
      print('🔍 Testing basic connectivity...');
      var testResponse = await http.get(
        Uri.parse('$baseUrl/api/kiri-engine/health'),
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'DisruptonApp/1.0',
        },
      ).timeout(const Duration(seconds: 5));
      
      if (testResponse.statusCode != 200) {
        throw Exception('Backend no responde. Status: ${testResponse.statusCode}');
      }
      print('✅ Basic connectivity OK');
      
      int videoSize = await videoFile.length();
      print('📊 Tamaño del video: ${(videoSize / 1024 / 1024).toStringAsFixed(1)}MB');
      
      if (videoSize > 50 * 1024 * 1024) {
        throw Exception('El video es demasiado grande para ngrok free (${(videoSize / 1024 / 1024).toStringAsFixed(1)}MB). Límite: 50MB');
      }
      
      var client = http.Client();
      var request = http.MultipartRequest('POST', uri);
      
      // Obtener headers de autenticación
      final authHeaders = _authService.getAuthHeaders();

      request.headers.addAll({
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'DisruptonApp/1.0',
        'Accept': 'application/json',
        'Connection': 'keep-alive',
        ...authHeaders, // Añadir los headers de autenticación
      });
      
      request.fields.addAll({
        'modelQuality': modelQuality.toString(),
        'textureQuality': textureQuality.toString(),
        'fileFormat': fileFormat,
        'isMask': isMask.toString(),
        'textureSmoothing': textureSmoothing.toString(),
      });
      
      print('🔍 Adding video file to request...');
      try {
        var mimeType = lookupMimeType(videoFile.path);
        var extension = mimeType?.split('/').last ?? 'mp4';
        
        var multipartFile = await http.MultipartFile.fromPath(
          'videoFile',
          videoFile.path,
          contentType: MediaType('video', extension),
        );
        
        request.files.add(multipartFile);
        print('✅ Video file added: ${videoFile.path.split('/').last}');
      } catch (e) {
          print('❌ Error adding video file: $e');
          client.close();
          throw Exception('Error processing video file: $e');
      }
      
      print('🔍 Sending video request...');
      
      var response = await client.send(request).timeout(
        const Duration(minutes: 20),
        onTimeout: () {
          client.close();
          throw Exception('Timeout: La subida del video tardó más de 20 minutos');
        },
      );
      
      print('🔍 Video response received, reading data...');
      var responseData = await response.stream.bytesToString();
      client.close();
      
      print('🔍 Video response status: ${response.statusCode}');
      print('🔍 Video response data: $responseData');
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to upload video: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      print('❌ Video upload error: $e');
      
      if (e.toString().contains('Connection reset by peer')) {
        print('💡 Sugerencias para video "Connection reset by peer":');
        print('   1. El video puede ser demasiado grande');
        print('   2. ngrok free tiene límites de tiempo/tamaño');
        print('   3. Verificar que el backend esté corriendo');
        print('   4. Intentar comprimir el video');
        print('   5. Usar conexión WiFi estable');
      }
      
      throw Exception('Error uploading video: $e');
    }
  }
  
  Future<Map<String, dynamic>> getModelStatus(String serial) async {
    try {
      var uri = Uri.parse('$baseUrl/api/kiri-engine/model-status/$serial');
      
      // Obtener headers de autenticación
      final authHeaders = _authService.getAuthHeaders();

      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'DisruptonApp/1.0',
          ...authHeaders, // Añadir los headers de autenticación
        },
      );
      
      print('🔍 Status check for: $serial');
      print('🔍 Status response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('🔍 Status data: $data');
        return data;
      } else {
        throw Exception('Failed to get model status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting model status: $e');
    }
  }
  
  Future<Map<String, dynamic>> downloadModel(String serial) async {
    try {
      var uri = Uri.parse('$baseUrl/api/kiri-engine/download-model/$serial');
      
      // Obtener headers de autenticación
      final authHeaders = _authService.getAuthHeaders();

      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'DisruptonApp/1.0',
          ...authHeaders, // Añadir los headers de autenticación
        },
      );
      
      print('🔍 Download request for: $serial');
      print('🔍 Download response: ${response.statusCode}');
      print('🔍 Download body: ${response.body}');
      
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('🔍 Download data parsed: $data');
        return data;
      } else {
        throw Exception('Failed to get download link: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting download link: $e');
    }
  }
  
Future<String> downloadModelFile(String downloadUrl, String serial) async {
    try {
      print('🔍 Downloading model file from: $downloadUrl');
      var response = await http.get(Uri.parse(downloadUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download model file: ${response.statusCode}');
      }

      // Detectar si es ZIP (PK al inicio)
      if (response.bodyBytes.length > 2 &&
          response.bodyBytes[0] == 0x50 && // 'P'
          response.bodyBytes[1] == 0x4B) { // 'K'
        print("📦 Archivo ZIP detectado, descomprimiendo...");

        // Descomprimir el ZIP
        final archive = ZipDecoder().decodeBytes(response.bodyBytes);

        // Buscar un archivo .glb dentro
        final glbFile = archive.files.firstWhere(
          (file) => file.name.toLowerCase().endsWith(".glb"),
          orElse: () =>
              throw Exception("No se encontró ningún .glb dentro del ZIP"),
        );

        // Guardar el GLB en almacenamiento local
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'model_$serial.glb';
        final filePath = '${directory.path}/$fileName';

        File(filePath).writeAsBytesSync(glbFile.content as List<int>);
        print('✅ GLB extraído a: $filePath');

        return filePath;
      } else {
        print("📄 Archivo GLB detectado directamente");
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'model_$serial.glb';
        final filePath = '${directory.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print('✅ Model file descargado en: $filePath');
        return filePath;
      }
    } catch (e) {
      throw Exception('Error descargando modelo: $e');
    }
  }
  
  Future<String> processImagesAndGetModel(
    List<File> imageFiles, {
    String? objectName,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('Subiendo imágenes...');
      final uploadResult = await uploadImages(
        imageFiles,
        objectName: objectName,
        fileFormat: 'GLB',
      );
      
      String serial;
      if (uploadResult['data'] != null && uploadResult['data']['serialize'] != null) {
        serial = uploadResult['data']['serialize'];
      } else {
        throw Exception('No se pudo obtener el ID del modelo de la respuesta');
      }
      
      print('✅ Upload successful. Serial: $serial');
      
      onStatusUpdate?.call('Procesando modelo 3D...');
      bool isReady = false;
      int attempts = 0;
      const maxAttempts = 60;
      
      while (!isReady && attempts < maxAttempts) {
        await Future.delayed(const Duration(seconds: 30));
        attempts++;
        
        try {
          final statusResult = await getModelStatus(serial);
          print('🔍 Processing status: $statusResult');
          
          if (statusResult['status'] == 'completed' || 
              statusResult['ready'] == true ||
              statusResult['state'] == 'FINISHED') {
            isReady = true;
            onStatusUpdate?.call('Modelo listo, descargando...');
          } else if (statusResult['status'] == 'failed' ||
                    statusResult['error'] != null) {
            throw Exception('El procesamiento del modelo falló: $statusResult');
          } else {
            onStatusUpdate?.call('Procesando... (${attempts * 30}s)');
          }
        } catch (e) {
          print('⚠️ Error checking status (attempt $attempts): $e');
          if (attempts >= maxAttempts) {
            throw Exception('Timeout esperando que el modelo esté listo');
          }
        }
      }
      
      if (!isReady) {
        throw Exception('Timeout: El modelo no estuvo listo en 30 minutos');
      }
      
      final downloadResult = await downloadModel(serial);
      
      print('🔍 Full download result: $downloadResult');
      
      if (downloadResult['data'] == null || downloadResult['data']['modelUrl'] == null) {
        print('❌ Download result structure: ${downloadResult.keys}');
        if (downloadResult['data'] != null) {
          print('❌ Data keys: ${downloadResult['data'].keys}');
        }
        throw Exception('No se pudo obtener la URL de descarga. Estructura recibida: ${downloadResult.keys.join(", ")}');
      }
      
      final String downloadUrl = downloadResult['data']['modelUrl'];
      print('✅ Found modelUrl: $downloadUrl');
      
      onStatusUpdate?.call('Descargando archivo del modelo...');
      final localFilePath = await downloadModelFile(downloadUrl, serial);
      
      onStatusUpdate?.call('Subiendo modelo a Firebase Storage...');
      final modelFile = File(localFilePath);
      final uploadResponse = await _culturalObjectService.uploadModel(
        modelFile,
        objectName: objectName ?? 'model_$serial',
      );

      onStatusUpdate?.call('Creando registro del objeto cultural...');
      final newObjectRequest = CulturalObjectRequest(
        name: objectName ?? 'Objeto Escaneado',
        description: 'Modelo 3D generado a partir de escaneo con Kiri Engine.',
        model3dUrl: uploadResponse['gsUrl'], // Usamos la gsUrl
      );
      
      final createdObject = await _culturalObjectService.createObject(newObjectRequest);
      print('✅ Objeto cultural creado con ID: ${createdObject.objectId}');

      onStatusUpdate?.call('¡Proceso completado!');
      return localFilePath;
      
    } catch (e) {
      print('❌ Process error: $e');
      throw Exception('Error en el proceso completo: $e');
    }
  }
  
  Future<String> processVideoAndGetModel(
    File videoFile, {
    String? objectName,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('Subiendo video...');
      final uploadResult = await uploadVideo(
        videoFile,
        objectName: objectName,
        fileFormat: 'GLB',
      );
      
      String serial;
      if (uploadResult['data'] != null && uploadResult['data']['serialize'] != null) {
        serial = uploadResult['data']['serialize'];
      } else {
        throw Exception('No se pudo obtener el ID del modelo de la respuesta');
      }
      
      print('✅ Video upload successful. Serial: $serial');
      
      onStatusUpdate?.call('Procesando modelo 3D...');
      bool isReady = false;
      int attempts = 0;
      const maxAttempts = 60;
      
      while (!isReady && attempts < maxAttempts) {
        await Future.delayed(const Duration(seconds: 30));
        attempts++;
        
        try {
          final statusResult = await getModelStatus(serial);
          
          if (statusResult['status'] == 'completed' || 
              statusResult['ready'] == true ||
              statusResult['state'] == 'FINISHED') {
            isReady = true;
            onStatusUpdate?.call('Modelo listo, descargando...');
          } else if (statusResult['status'] == 'failed' ||
                    statusResult['error'] != null) {
            throw Exception('El procesamiento del modelo falló: $statusResult');
          } else {
            onStatusUpdate?.call('Procesando... (${attempts * 30}s)');
          }
        } catch (e) {
          print('⚠️ Error checking status (attempt $attempts): $e');
          if (attempts >= maxAttempts) {
            throw Exception('Timeout esperando que el modelo esté listo');
          }
        }
      }
      
      if (!isReady) {
        throw Exception('Timeout: El modelo no estuvo listo en 30 minutos');
      }
      
      final downloadResult = await downloadModel(serial);
      
      print('🔍 Full download result: $downloadResult');
      
      if (downloadResult['data'] == null || downloadResult['data']['modelUrl'] == null) {
        print('❌ Download result structure: ${downloadResult.keys}');
        if (downloadResult['data'] != null) {
          print('❌ Data keys: ${downloadResult['data'].keys}');
        }
        throw Exception('No se pudo obtener la URL de descarga. Estructura recibida: ${downloadResult.keys.join(", ")}');
      }
      
      final String downloadUrl = downloadResult['data']['modelUrl'];
      print('✅ Found modelUrl: $downloadUrl');
      
      onStatusUpdate?.call('Descargando archivo del modelo...');
      final localFilePath = await downloadModelFile(downloadUrl, serial);
      
      onStatusUpdate?.call('Subiendo modelo a Firebase Storage...');
      final modelFile = File(localFilePath);
      final uploadResponse = await _culturalObjectService.uploadModel(
        modelFile,
        objectName: objectName ?? 'model_$serial',
      );

      onStatusUpdate?.call('Creando registro del objeto cultural...');
      final newObjectRequest = CulturalObjectRequest(
        name: objectName ?? 'Objeto Escaneado desde Video',
        description: 'Modelo 3D generado a partir de video con Kiri Engine.',
        model3dUrl: uploadResponse['gsUrl'], // Usamos la gsUrl
      );
      
      final createdObject = await _culturalObjectService.createObject(newObjectRequest);
      print('✅ Objeto cultural creado con ID: ${createdObject.objectId}');

      onStatusUpdate?.call('¡Proceso completado!');
      return localFilePath;
      
    } catch (e) {
      print('❌ Video process error: $e');
      throw Exception('Error en el proceso completo de video: $e');
    }
  }

  Future<Map<String, dynamic>> uploadFeaturelessImages(
    List<File> imageFiles, {
    String fileFormat = 'GLB',
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/api/kiri-engine/upload-featureless-images');
      var request = http.MultipartRequest('POST', uri);
      
      print('🔍 Uploading featureless images to: $uri');
      
      // Obtener headers de autenticación
      final authHeaders = _authService.getAuthHeaders();

      request.headers.addAll({
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'DisruptonApp/1.0',
        ...authHeaders, // Añadir los headers de autenticación
      });
      
      request.fields.addAll({
        'fileFormat': fileFormat,
      });
      
      for (var file in imageFiles) {
        var mimeType = lookupMimeType(file.path);
        var extension = mimeType?.split('/').last ?? 'jpg';
        
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagesFiles',
            file.path,
            contentType: MediaType('image', extension),
          ),
        );
      }
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to upload featureless images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading featureless images: $e');
    }
  }
  
  Future<Map<String, dynamic>> uploadFeaturelessVideo(
    File videoFile, {
    String fileFormat = 'GLB',
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/api/kiri-engine/upload-featureless-video');
      var request = http.MultipartRequest('POST', uri);
      
      print('🔍 Uploading featureless video to: $uri');
      
      // Obtener headers de autenticación
      final authHeaders = _authService.getAuthHeaders();

      request.headers.addAll({
        'ngrok-skip-browser-warning': 'true',
        'User-Agent': 'DisruptonApp/1.0',
        ...authHeaders, // Añadir los headers de autenticación
      });
      
      request.fields.addAll({
        'fileFormat': fileFormat,
      });
      
      var mimeType = lookupMimeType(videoFile.path);
      var extension = mimeType?.split('/').last ?? 'mp4';
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'videoFile',
          videoFile.path,
          contentType: MediaType('video', extension),
        ),
      );
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to upload featureless video: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading featureless video: $e');
    }
  }
  
  Future<bool> checkHealth() async {
    try {
      var uri = Uri.parse('$baseUrl/api/kiri-engine/health');
      
      var response = await http.get(
        uri,
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'User-Agent': 'DisruptonApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('🏥 Health check: ${response.statusCode}');
      print('🏥 Health response: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }
}
