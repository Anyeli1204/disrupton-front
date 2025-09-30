import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/onirix_config.dart';

class OnirixService {
  final String userToken;
  static const String _apiBaseUrl = 'https://api.onirix.io/v1';

  OnirixService({required this.userToken});

  // Verificar si el token es válido
  Future<bool> validateToken() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/me'),
        headers: _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error validando token: $e');
      return false;
    }
  }

  // Obtener información del proyecto
  Future<Map<String, dynamic>> getProjectInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/projects/${OnirixConfig.projectId}'),
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error obteniendo información del proyecto: $e');
      rethrow;
    }
  }

  // Obtener información de una escena
  Future<Map<String, dynamic>> getSceneInfo(String sceneId) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/projects/${OnirixConfig.projectId}/scenes/$sceneId'),
        headers: _getHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error obteniendo información de la escena: $e');
      rethrow;
    }
  }

  // Subir un modelo 3D
  Future<Map<String, dynamic>> upload3DModel(String filePath, String fileName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBaseUrl/projects/${OnirixConfig.projectId}/assets'),
      )..headers.addAll(_getHeaders());

      // Añadir archivo
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        filePath,
        filename: fileName,
      ));

      // Enviar petición
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error subiendo modelo 3D: $e');
      rethrow;
    }
  }

  // Métodos de ayuda
  // Obtener headers con autenticación
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $userToken',
    };
  }

  // Manejar respuesta de la API
  dynamic _handleResponse(http.Response response) {
    debugPrint('Respuesta de la API (${response.statusCode}): ${response.body}');
    
    if (response.statusCode == 401) {
      throw Exception('No autorizado. Verifica tu token de usuario.');
    }
    
    if (response.statusCode == 403) {
      throw Exception('Permiso denegado. Tu cuenta puede no tener acceso a este recurso.');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Error al decodificar la respuesta: $e');
      }
    } else {
      String errorMessage = 'Error en la petición (${response.statusCode})';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (_) {}
      
      throw Exception(errorMessage);
    }
  }
  
  // Método para probar la conexión con la API
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/me'),
        headers: _getHeaders(),
      );
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Conexión exitosa con la API de Onirix',
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error en la conexión (${response.statusCode})',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión',
        'details': e.toString(),
      };
    }
  }
}
