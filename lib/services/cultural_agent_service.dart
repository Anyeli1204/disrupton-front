import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cultural_agent.dart';

class CulturalAgentService {
  static const String baseUrl = 'http://localhost:8080'; // Cambiar por tu URL del backend
  
  // Obtener todos los agentes culturales
  static Future<List<CulturalAgent>> getAllAgents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cultural-agents'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CulturalAgent.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener agentes culturales: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener agente por ID
  static Future<CulturalAgent?> getAgentById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cultural-agents/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CulturalAgent.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener agente: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener agentes por categoría
  static Future<List<CulturalAgent>> getAgentsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cultural-agents?category=$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CulturalAgent.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener agentes por categoría: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Buscar agentes por texto
  static Future<List<CulturalAgent>> searchAgents(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cultural-agents/search?q=${Uri.encodeComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CulturalAgent.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar agentes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener agentes por región
  static Future<List<CulturalAgent>> getAgentsByRegion(String region) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cultural-agents?region=${Uri.encodeComponent(region)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CulturalAgent.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener agentes por región: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear nuevo agente cultural
  static Future<bool> createAgent(CulturalAgent agent) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cultural-agents'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(agent.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error al crear agente: $e');
    }
  }

  // Actualizar agente cultural
  static Future<bool> updateAgent(String id, CulturalAgent agent) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/cultural-agents/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(agent.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar agente: $e');
    }
  }

  // Eliminar agente cultural
  static Future<bool> deleteAgent(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/cultural-agents/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error al eliminar agente: $e');
    }
  }

  // Calificar agente
  static Future<bool> rateAgent(String id, double rating, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/cultural-agents/$id/rate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'rating': rating,
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al calificar agente: $e');
    }
  }

  // Obtener agentes verificados
  static Future<List<CulturalAgent>> getVerifiedAgents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/cultural-agents?verified=true'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CulturalAgent.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener agentes verificados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Datos de ejemplo para cuando no hay conexión
  static List<CulturalAgent> getSampleAgents() {
    return [
      CulturalAgent(
        id: '1',
        name: 'María González',
        description: 'Artesana experta en cerámica tradicional de la región. Con más de 20 años de experiencia, María preserva las técnicas ancestrales de alfarería y las transmite a nuevas generaciones.',
        category: 'ARTISAN',
        imageUrl: null,
        phoneNumber: '+34 600 123 456',
        email: 'maria.gonzalez@email.com',
        website: 'www.mariaceramica.com',
        region: 'Andalucía',
        address: 'Calle del Alfar, 15, Sevilla',
        latitude: 37.3891,
        longitude: -5.9845,
        specialties: ['Cerámica', 'Alfarería', 'Técnicas tradicionales'],
        languages: ['Español', 'Inglés'],
        rating: 4.8,
        reviewCount: 127,
        isVerified: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 30)),
        userId: 'user123',
      ),
      CulturalAgent(
        id: '2',
        name: 'Carlos Mendoza',
        description: 'Guía turístico especializado en historia medieval y arquitectura gótica. Ofrece tours personalizados por los monumentos más importantes de la ciudad.',
        category: 'GUIDE',
        imageUrl: null,
        phoneNumber: '+34 600 234 567',
        email: 'carlos.mendoza@email.com',
        website: 'www.toursmedievales.com',
        region: 'Castilla y León',
        address: 'Plaza Mayor, 8, Salamanca',
        latitude: 40.9645,
        longitude: -5.6630,
        specialties: ['Historia medieval', 'Arquitectura gótica', 'Turismo cultural'],
        languages: ['Español', 'Inglés', 'Francés'],
        rating: 4.9,
        reviewCount: 89,
        isVerified: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 730)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 15)),
        userId: 'user456',
      ),
      CulturalAgent(
        id: '3',
        name: 'Ana Rodríguez',
        description: 'Experta en flamenco y danza española. Profesora de baile con amplia experiencia en la enseñanza de técnicas tradicionales y modernas del flamenco.',
        category: 'CULTURAL_EXPERT',
        imageUrl: null,
        phoneNumber: '+34 600 345 678',
        email: 'ana.rodriguez@email.com',
        website: 'www.anaflamenco.com',
        region: 'Andalucía',
        address: 'Calle del Baile, 22, Granada',
        latitude: 37.1765,
        longitude: -3.5976,
        specialties: ['Flamenco', 'Danza española', 'Cultura andaluza'],
        languages: ['Español', 'Inglés', 'Italiano'],
        rating: 4.7,
        reviewCount: 156,
        isVerified: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1095)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
        userId: 'user789',
      ),
      CulturalAgent(
        id: '4',
        name: 'Luis Fernández',
        description: 'Artesano del cuero con especialización en marroquinería tradicional. Crea bolsos, cinturones y accesorios usando técnicas centenarias.',
        category: 'ARTISAN',
        imageUrl: null,
        phoneNumber: '+34 600 456 789',
        email: 'luis.fernandez@email.com',
        website: 'www.luiscuero.com',
        region: 'Extremadura',
        address: 'Calle del Cuero, 33, Cáceres',
        latitude: 39.4753,
        longitude: -6.3724,
        specialties: ['Marroquinería', 'Cuero', 'Artesanía tradicional'],
        languages: ['Español', 'Portugués'],
        rating: 4.6,
        reviewCount: 73,
        isVerified: false,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 45)),
        userId: 'user101',
      ),
      CulturalAgent(
        id: '5',
        name: 'Isabel Martín',
        description: 'Guía especializada en rutas gastronómicas y enología. Conoce los mejores restaurantes, bodegas y productos locales de la región.',
        category: 'GUIDE',
        imageUrl: null,
        phoneNumber: '+34 600 567 890',
        email: 'isabel.martin@email.com',
        website: 'www.rutasgastronomicas.com',
        region: 'La Rioja',
        address: 'Calle del Vino, 12, Logroño',
        latitude: 42.4627,
        longitude: -2.4449,
        specialties: ['Gastronomía', 'Enología', 'Turismo rural'],
        languages: ['Español', 'Inglés', 'Alemán'],
        rating: 4.8,
        reviewCount: 112,
        isVerified: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 548)),
        lastUpdated: DateTime.now().subtract(const Duration(days: 22)),
        userId: 'user202',
      ),
    ];
  }
}
