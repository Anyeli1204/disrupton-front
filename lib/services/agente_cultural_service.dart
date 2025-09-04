import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/cultural_agent.dart';
import 'auth_service.dart';

class AgenteCulturalService {
  static const String _baseUrl = '${AppConfig.baseUrl}/api/agentes-culturales';

  /// Obtiene todos los agentes culturales
  static Future<List<CulturalAgent>> obtenerTodosLosAgentes() async {
    try {
      print('🏛️ Obteniendo todos los agentes culturales');

      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers,
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> artesanosJson = data['artesanos'] ?? [];
          final List<dynamic> guiasJson = data['guias'] ?? [];

          List<CulturalAgent> agentes = [];
          agentes.addAll(
              artesanosJson.map((json) => CulturalAgent.fromJson(json)));
          agentes.addAll(guiasJson.map((json) => CulturalAgent.fromJson(json)));

          return agentes;
        } else {
          throw Exception('Error en la respuesta: ${data['error']}');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error al obtener agentes: $e');
      rethrow;
    }
  }

  /// Obtiene artesanos
  static Future<List<CulturalAgent>> obtenerArtesanos() async {
    try {
      print('🎨 Obteniendo artesanos');

      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final response = await http.get(
        Uri.parse('$_baseUrl/artesanos'),
        headers: headers,
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> artesanosJson = data['data'] ?? [];
          return artesanosJson
              .map((json) => CulturalAgent.fromJson(json))
              .toList();
        } else {
          throw Exception('Error en la respuesta: ${data['error']}');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error al obtener artesanos: $e');
      rethrow;
    }
  }

  /// Obtiene guías turísticos
  static Future<List<CulturalAgent>> obtenerGuias() async {
    try {
      print('🗺️ Obteniendo guías turísticos');

      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final response = await http.get(
        Uri.parse('$_baseUrl/guias'),
        headers: headers,
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> guiasJson = data['data'] ?? [];
          return guiasJson.map((json) => CulturalAgent.fromJson(json)).toList();
        } else {
          throw Exception('Error en la respuesta: ${data['error']}');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error al obtener guías: $e');
      rethrow;
    }
  }

  /// Busca agentes por término
  static Future<List<CulturalAgent>> buscarAgentes(
    String termino, {
    AgentType? tipo,
  }) async {
    try {
      print('🔍 Buscando agentes: $termino');

      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final Map<String, String> queryParams = {'termino': termino};
      if (tipo != null) {
        queryParams['tipo'] =
            tipo == AgentType.artisan ? 'ARTISAN' : 'TOURIST_GUIDE';
      }

      final uri =
          Uri.parse('$_baseUrl/buscar').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: headers,
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> agentesJson = data['data'] ?? [];
          return agentesJson
              .map((json) => CulturalAgent.fromJson(json))
              .toList();
        } else {
          throw Exception('Error en la respuesta: ${data['error']}');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error al buscar agentes: $e');
      rethrow;
    }
  }

  /// Obtiene agentes por ubicación
  static Future<List<CulturalAgent>> obtenerAgentesPorUbicacion(
      String departamento) async {
    try {
      print('📍 Obteniendo agentes de: $departamento');

      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final response = await http.get(
        Uri.parse('$_baseUrl/ubicacion/$departamento'),
        headers: headers,
      );

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> agentesJson = data['data'] ?? [];
          return agentesJson
              .map((json) => CulturalAgent.fromJson(json))
              .toList();
        } else {
          throw Exception('Error en la respuesta: ${data['error']}');
        }
      } else {
        throw Exception('Error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error al obtener agentes por ubicación: $e');
      rethrow;
    }
  }
}
