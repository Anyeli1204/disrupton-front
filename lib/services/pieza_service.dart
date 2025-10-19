import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/pieza.dart';
import '../config/api_config.dart';

class PiezaService {
  static const String baseUrl = ApiConfig.baseUrl;
  static final _timeout = Duration(seconds: ApiConfig.timeoutSeconds);

  // Datos de demostración para fallback
  static List<Pieza> _getMockPiezas() {
    return [
      Pieza(
        id: '1',
        nombre: 'Máscara Ceremonial Inca',
        descripcion: 'Máscara ritual utilizada en ceremonias importantes del Imperio Inca',
        categoria: 'Artefactos Ceremoniales',
        epoca: 'Imperio Inca (1438-1533)',
        ubicacion: 'Cusco, Perú',
        urlImagen: 'https://picsum.photos/400/400?random=1',
        urlModelo3D: '',
      ),
      Pieza(
        id: '2',
        nombre: 'Textil Andino Tradicional',
        descripcion: 'Tejido andino con patrones geométricos tradicionales',
        categoria: 'Textiles',
        epoca: 'Período Colonial (1532-1821)',
        ubicacion: 'Puno, Perú',
        urlImagen: 'https://picsum.photos/400/400?random=2',
        urlModelo3D: '',
      ),
      Pieza(
        id: '3',
        nombre: 'Cerámica Mochica',
        descripcion: 'Vasija ceremonial de la cultura Moche con representaciones de deidades',
        categoria: 'Cerámica',
        epoca: 'Cultura Moche (100-800 d.C.)',
        ubicacion: 'Trujillo, Perú',
        urlImagen: 'https://picsum.photos/400/400?random=3',
        urlModelo3D: '',
      ),
      Pieza(
        id: '4',
        nombre: 'Quipu Inca',
        descripcion: 'Sistema de registro mediante cuerdas anudadas utilizado por los Incas',
        categoria: 'Documentos Históricos',
        epoca: 'Imperio Inca (1438-1533)',
        ubicacion: 'Lima, Perú',
        urlImagen: 'https://picsum.photos/400/400?random=4',
        urlModelo3D: '',
      ),
      Pieza(
        id: '5',
        nombre: 'Máscara de Oro Chimú',
        descripcion: 'Máscara funeraria de oro de la cultura Chimú',
        categoria: 'Orfebrería',
        epoca: 'Cultura Chimú (900-1470 d.C.)',
        ubicacion: 'Chiclayo, Perú',
        urlImagen: 'https://picsum.photos/400/400?random=5',
        urlModelo3D: '',
      ),
    ];
  }

  // Obtener todas las piezas
  static Future<List<Pieza>> obtenerPiezas() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/cultural-objects'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pieza.fromJson(json)).toList();
      } else {
        print('Backend no disponible para piezas (${response.statusCode}), usando datos de demostración...');
        return _getMockPiezas();
      }
    } on SocketException {
      print('Sin conexión a internet, usando datos de demostración para piezas');
      return _getMockPiezas();
    } on TimeoutException {
      print('Timeout al obtener piezas, usando datos de demostración');
      return _getMockPiezas();
    } on HandshakeException {
      print('Error SSL al obtener piezas, usando datos de demostración');
      return _getMockPiezas();
    } catch (e) {
      print('Error al obtener piezas: $e, usando datos de demostración');
      return _getMockPiezas();
    }
  }

  // Obtener pieza por ID
  static Future<Pieza> obtenerPiezaPorId(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/cultural-objects/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Pieza.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Pieza no encontrada');
      } else {
        throw Exception('Error al obtener pieza: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sin conexión a internet');
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado');
    } on HandshakeException {
      throw Exception('Error de seguridad SSL');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener piezas por categoría
  static Future<List<Pieza>> obtenerPiezasPorCategoria(String categoria) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/cultural-objects?categoria=$categoria'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pieza.fromJson(json)).toList();
      } else {
        print('Error obteniendo piezas por categoría, usando mock');
        return _getMockPiezas()
            .where((p) => p.categoria == categoria)
            .toList();
      }
    } catch (e) {
      print('Error al obtener piezas por categoría: $e');
      return _getMockPiezas().where((p) => p.categoria == categoria).toList();
    }
  }

  // Obtener piezas por ubicación
  static Future<List<Pieza>> obtenerPiezasPorUbicacion(String ubicacion) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/cultural-objects?ubicacion=$ubicacion'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pieza.fromJson(json)).toList();
      } else {
        print('Error obteniendo piezas por ubicación, usando mock');
        return _getMockPiezas()
            .where((p) => p.ubicacion.contains(ubicacion))
            .toList();
      }
    } catch (e) {
      print('Error al obtener piezas por ubicación: $e');
      return _getMockPiezas()
          .where((p) => p.ubicacion.contains(ubicacion))
          .toList();
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
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/cultural-objects/search?q=${Uri.encodeComponent(query)}'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Pieza.fromJson(json)).toList();
      } else {
        print('Error en búsqueda, usando mock filtrado');
        final lowerQuery = query.toLowerCase();
        return _getMockPiezas()
            .where((p) =>
                p.nombre.toLowerCase().contains(lowerQuery) ||
                p.descripcion.toLowerCase().contains(lowerQuery))
            .toList();
      }
    } catch (e) {
      print('Error en búsqueda: $e, usando mock filtrado');
      final lowerQuery = query.toLowerCase();
      return _getMockPiezas()
          .where((p) =>
              p.nombre.toLowerCase().contains(lowerQuery) ||
              p.descripcion.toLowerCase().contains(lowerQuery))
          .toList();
    }
  }
}
