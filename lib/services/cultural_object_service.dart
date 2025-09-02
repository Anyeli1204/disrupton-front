// Servicio de Objetos Culturales (de Yeimi)
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cultural_object.dart';
import '../models/cultural_agent.dart';
import '../models/product.dart';
import '../config/api_config.dart';

class CulturalObjectService {
  static const String baseUrl = ApiConfig.baseUrl;

  // Mock data para desarrollo
  static List<CulturalObject> _getMockCulturalObjects() {
    return [
      CulturalObject(
        id: '1',
        name: 'Cerámica Inca',
        imageUrl: 'https://via.placeholder.com/300',
        description: 'Cerámica ritual del período Inca',
        origin: 'Cusco, Perú',
        cultureType: 'Inca',
        history: 'Utilizada en ceremonias religiosas del Imperio Inca',
        latitude: -13.5319,
        longitude: -71.9675,
      ),
      CulturalObject(
        id: '2',
        name: 'Textil Paracas',
        imageUrl: 'https://via.placeholder.com/300',
        description: 'Textil ceremonial de la cultura Paracas',
        origin: 'Ica, Perú',
        cultureType: 'Paracas',
        history: 'Mantos funerarios de la cultura Paracas',
        latitude: -14.2681,
        longitude: -75.7256,
      ),
    ];
  }

  static List<Product> _getMockProducts() {
    return [
      Product(
        id: '1',
        name: 'Replica Cerámica Inca',
        imageUrl: 'https://via.placeholder.com/300',
        price: 45.99,
        description: 'Réplica artesanal de cerámica inca',
        culturalAgentName: 'Artesano Local',
        modelUrl: 'assets/models/ceramica.glb',
      ),
      Product(
        id: '2',
        name: 'Textil Paracas Replica',
        imageUrl: 'https://via.placeholder.com/300',
        price: 89.99,
        description: 'Réplica de textil Paracas',
        culturalAgentName: 'Tejedora Tradicional',
        modelUrl: 'assets/models/textil.glb',
      ),
    ];
  }

  Future<List<CulturalObject>> fetchCulturalObjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cultural-objects'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body
            .map((dynamic item) => CulturalObject.fromJson(item))
            .toList();
      } else {
        throw Exception(
            'Failed to load cultural objects: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockCulturalObjects();
    }
  }

  Future<List<CulturalAgent>> fetchCulturalAgents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cultural-agents'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body
            .map((dynamic item) => CulturalAgent.fromJson(item))
            .toList();
      } else {
        throw Exception(
            'Failed to load cultural agents: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to empty list if API fails
      return [];
    }
  }

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockProducts();
    }
  }

  Future<CulturalObject?> getCulturalObjectById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cultural-objects/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return CulturalObject.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      // Fallback to mock data
      final mockObjects = _getMockCulturalObjects();
      return mockObjects.firstWhere(
        (obj) => obj.id == id,
        orElse: () => mockObjects.first,
      );
    }
  }
}
