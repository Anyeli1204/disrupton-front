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
      var uri = Uri.parse('$baseUrl/api/cultural-objects/upload-model');
      var request = http.MultipartRequest('POST', uri);
      
      // ✅ AGREGAR AUTENTICACIÓN
      final authHeaders = _authService.getAuthHeaders();
      
      request.headers.addAll({
        'ngrok-skip-browser-warning': 'true',
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
      
      // Agregar el nombre del objeto
      request.fields['objectName'] = objectName;
      
      print('🔍 Uploading model to: $uri');
      print('🔍 Object name: $objectName');
      print('🔍 File path: ${modelFile.path}');
      print('🔍 File size: ${await modelFile.length()} bytes');
      
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      
      print('🔍 Upload response status: ${response.statusCode}');
      print('🔍 Upload response body: $responseBody');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ MANEJO DE RESPUESTA VACÍA O NO-JSON
        if (responseBody.isEmpty) {
          print('⚠️ Backend returned empty response');
          return {
            'success': true,
            'message': 'Model uploaded successfully',
            'gsUrl': 'gs://disrupton-new.firebasestorage.app/$objectName.glb',
          };
        }
        
        // ✅ INTENTAR PARSEAR JSON
        try {
          final jsonResponse = json.decode(responseBody);
          
          // Verificar que tenga la gsUrl
          if (jsonResponse['gsUrl'] == null) {
            print('⚠️ Response missing gsUrl, adding default');
            jsonResponse['gsUrl'] = 'gs://disrupton-new.firebasestorage.app/$objectName.glb';
          }
          
          return jsonResponse;
        } catch (e) {
          print('⚠️ Response is not JSON: $responseBody');
          // Si no es JSON pero fue exitoso (200/201), crear respuesta por defecto
          return {
            'success': true,
            'message': responseBody.isNotEmpty ? responseBody : 'Upload successful',
            'gsUrl': 'gs://disrupton-new.firebasestorage.app/$objectName.glb',
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