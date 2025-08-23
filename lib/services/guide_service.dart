import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/role_models.dart';

class GuideService {
  static const String _baseUrl = '${ApiConfig.baseUrl}/api/guide';

  // Get authenticated headers
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Get guide's promotions
  static Future<List<GuidePromotion>> getMyPromotions() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/promotions'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => GuidePromotion.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load promotions: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data
      return _getMockPromotions();
    }
  }

  // Create new promotion
  static Future<bool> createPromotion(GuidePromotion promotion) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/promotions'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(promotion.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Update promotion
  static Future<bool> updatePromotion(GuidePromotion promotion) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/promotions/${promotion.id}'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(promotion.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Delete promotion
  static Future<bool> deletePromotion(String promotionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/promotions/$promotionId'),
        headers: await _getAuthHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Toggle promotion active status
  static Future<bool> togglePromotionStatus(
      String promotionId, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/promotions/$promotionId/status'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({'isActive': isActive}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Mock data
  static List<GuidePromotion> _getMockPromotions() {
    return [
      GuidePromotion(
        id: '1',
        guideId: 'guide1',
        title: 'Tour Machu Picchu Exclusivo',
        description:
            'Experimenta la majestuosidad de Machu Picchu con un guía experto. Incluye transporte, entrada y almuerzo típico.',
        price: 150.0,
        currency: 'PEN',
        imageUrls: [
          'https://via.placeholder.com/400x300/4CAF50/white?text=Machu+Picchu',
          'https://via.placeholder.com/400x300/2196F3/white?text=Llamas',
        ],
        location: 'Cusco, Perú',
        duration: 8,
        maxParticipants: 12,
        highlights: [
          'Guía especializado en historia inca',
          'Transporte incluido desde Cusco',
          'Almuerzo típico peruano',
          'Entrada a Machu Picchu incluida',
        ],
        contactInfo: 'WhatsApp: +51 987 654 321',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      GuidePromotion(
        id: '2',
        guideId: 'guide1',
        title: 'Ruta Gastronómica Lima',
        description:
            'Descubre los sabores auténticos de Lima en un tour gastronómico por los mejores restaurantes locales.',
        price: 80.0,
        currency: 'PEN',
        imageUrls: [
          'https://via.placeholder.com/400x300/FF9800/white?text=Ceviche',
          'https://via.placeholder.com/400x300/E91E63/white?text=Anticuchos',
        ],
        location: 'Lima, Perú',
        duration: 4,
        maxParticipants: 8,
        highlights: [
          'Degustación en 5 restaurantes locales',
          'Aprende sobre la historia culinaria',
          'Incluye bebidas tradicionales',
          'Recetario digital incluido',
        ],
        contactInfo: 'Email: tours@lima.com',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      GuidePromotion(
        id: '3',
        guideId: 'guide1',
        title: 'Aventura Huacachina',
        description:
            'Vive la emoción del sandboarding y paseos en buggy en el oasis de Huacachina.',
        price: 120.0,
        currency: 'PEN',
        imageUrls: [
          'https://via.placeholder.com/400x300/FFC107/white?text=Oasis',
          'https://via.placeholder.com/400x300/795548/white?text=Buggy',
        ],
        location: 'Ica, Perú',
        duration: 6,
        maxParticipants: 15,
        highlights: [
          'Sandboarding en dunas',
          'Paseo en buggy 4x4',
          'Atardecer en el oasis',
          'Equipo de seguridad incluido',
        ],
        contactInfo: 'Teléfono: +51 956 123 456',
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }
}
