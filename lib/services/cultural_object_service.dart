import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/app_config.dart';
import '../models/cultural_object.dart';
import 'auth_service.dart';

class CulturalObjectService {
  final String baseUrl = AppConfig.baseUrl;
  final AuthService _authService = AuthService();

  // Obtener todos los objetos culturales
  Future<List<CulturalObject>> getAllObjects() async {
    try {
      final authHeaders = _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/cultural-objects'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          ...authHeaders,
        },
      );

      print('🔍 Get all objects - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => CulturalObject.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load objects: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting objects: $e');
      throw Exception('Error getting objects: $e');
    }
  }

  // Crear un nuevo objeto cultural
  Future<CulturalObject> createObject(CulturalObjectRequest request) async {
    try {
      final authHeaders = _authService.getAuthHeaders();
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/cultural-objects'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          ...authHeaders,
        },
        body: json.encode(request.toJson()),
      );

      print('🔍 Create object - Status: ${response.statusCode}');
      print('🔍 Create object - Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CulturalObject.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create object: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating object: $e');
      throw Exception('Error creating object: $e');
    }
  }

  // Subir modelo 3D a Firebase Storage
  Future<Map<String, dynamic>> uploadModel(
    File modelFile, {
    required String objectName,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/api/firebase/storage/upload-model');
      var request = http.MultipartRequest('POST', uri);

      // ✅ AGREGAR AUTENTICACIÓN
      final authHeaders = _authService.getAuthHeaders();

      // Obtener userId del usuario autenticado
      String userId = 'anonymous'; // Default
      if (_authService.currentUser != null) {
        userId = _authService.currentUser!.userId;
      } else {
        print('⚠️ No authenticated user, using anonymous userId');
      }

      request.headers.addAll({
        'User-Agent': 'DisruptonApp/1.0',
        'Accept': 'application/json',
        ...authHeaders, // ✅ IMPORTANTE: Headers de autenticación
      });

      // Agregar el archivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          modelFile.path,
          contentType: MediaType('model', 'gltf-binary'),
        ),
      );

      // ✅ Agregar campos requeridos por FirebaseStorageController
      request.fields['userId'] = userId;
      request.fields['modelId'] = objectName; // Usar objectName como modelId

      print('🔍 Uploading model to: $uri');
      print('🔍 User ID: $userId');
      print('🔍 Model ID: $objectName');
      print('🔍 File path: ${modelFile.path}');
      print('🔍 File size: ${await modelFile.length()} bytes');
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      print('🔍 Upload response status: ${response.statusCode}');
      print('🔍 Upload response body: $responseBody');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ INTENTAR PARSEAR JSON
        try {
          final jsonResponse = json.decode(responseBody);

          print('✅ Upload successful!');
          print('📦 Response: $jsonResponse');

          // FirebaseStorageController devuelve 'downloadUrl' en lugar de 'gsUrl'
          // Normalizar la respuesta para compatibilidad
          if (jsonResponse['downloadUrl'] != null && jsonResponse['model3dUrl'] == null) {
            jsonResponse['model3dUrl'] = jsonResponse['downloadUrl'];
          }

          return jsonResponse;
        } catch (e) {
          print('⚠️ Response is not JSON: $responseBody');
          // Si no es JSON pero fue exitoso (200/201), retornar el body como mensaje
          return {
            'success': true,
            'message': responseBody.isNotEmpty ? responseBody : 'Upload successful',
            'downloadUrl': '', // URL vacía, se debe obtener después
          };
        }
      } else if (response.statusCode == 403) {
        throw Exception('Acceso denegado (403). Verifica la autenticación o permisos en el backend.');
      } else {
        throw Exception('Upload failed with status ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('❌ Error uploading model: $e');
      throw Exception('Error uploading model: $e');
    }
  }

  // Obtener un objeto por ID
  Future<CulturalObject> getObjectById(String objectId) async {
    try {
      final authHeaders = _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/cultural-objects/$objectId'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          ...authHeaders,
        },
      );

      if (response.statusCode == 200) {
        return CulturalObject.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load object: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting object: $e');
      throw Exception('Error getting object: $e');
    }
  }

  // Actualizar un objeto
  Future<CulturalObject> updateObject(
    String objectId,
    CulturalObjectRequest request,
  ) async {
    try {
      final authHeaders = _authService.getAuthHeaders();
      
      final response = await http.put(
        Uri.parse('$baseUrl/api/cultural-objects/$objectId'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          ...authHeaders,
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return CulturalObject.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update object: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating object: $e');
      throw Exception('Error updating object: $e');
    }
  }

  // Eliminar un objeto
  Future<void> deleteObject(String objectId) async {
    try {
      final authHeaders = _authService.getAuthHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cultural-objects/$objectId'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          ...authHeaders,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete object: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting object: $e');
      throw Exception('Error deleting object: $e');
    }
  }
}