import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pieza.dart';

class PiezaService {
  static const String baseUrl = 'https://api.disrupton.com'; // Cambiar por tu URL real
  
  // Obtener todas las piezas
  static Future<List<Pieza>> obtenerPiezas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/piezas'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pieza.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener piezas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener pieza por ID
  static Future<Pieza> obtenerPiezaPorId(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/piezas/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pieza.fromJson(data);
      } else {
        throw Exception('Error al obtener pieza: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener piezas por categoría
  static Future<List<Pieza>> obtenerPiezasPorCategoria(String categoria) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/piezas?categoria=$categoria'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pieza.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener piezas por categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener piezas por ubicación
  static Future<List<Pieza>> obtenerPiezasPorUbicacion(String ubicacion) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/piezas?ubicacion=$ubicacion'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pieza.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener piezas por ubicación: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Verificar si el modelo 3D está disponible
  static Future<bool> verificarModeloDisponible(String urlModelo) async {
    try {
      final response = await http.head(Uri.parse(urlModelo));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Obtener metadatos del modelo 3D
  static Future<Map<String, dynamic>> obtenerMetadatosModelo(String urlModelo) async {
    try {
      final response = await http.get(Uri.parse('$urlModelo.metadata'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // Buscar piezas por texto
  static Future<List<Pieza>> buscarPiezas(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/piezas/buscar?q=${Uri.encodeComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pieza.fromJson(json)).toList();
      } else {
        throw Exception('Error en la búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
