import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/role_models.dart';

class ArtisanService {
  static const String _baseUrl = '${ApiConfig.baseUrl}/api/artisan';

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

  // Get artisan's products
  static Future<List<ArtisanProduct>> getMyProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ArtisanProduct.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data
      return _getMockProducts();
    }
  }

  // Create new product
  static Future<bool> createProduct(ArtisanProduct product) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/products'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(product.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Update product
  static Future<bool> updateProduct(ArtisanProduct product) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/products/${product.id}'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(product.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Delete product
  static Future<bool> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/products/$productId'),
        headers: await _getAuthHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Update product stock
  static Future<bool> updateStock(String productId, int newStock) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/products/$productId/stock'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({'stockQuantity': newStock}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Toggle product active status
  static Future<bool> toggleProductStatus(
      String productId, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/products/$productId/status'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({'isActive': isActive}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get product categories
  static List<String> getProductCategories() {
    return [
      'Cerámica',
      'Textiles',
      'Joyería',
      'Tallado en madera',
      'Metalurgia',
      'Cestería',
      'Cuero',
      'Instrumentos musicales',
      'Pinturas',
      'Esculturas',
    ];
  }

  // Get common materials
  static List<String> getCommonMaterials() {
    return [
      'Arcilla',
      'Algodón',
      'Lana de alpaca',
      'Plata',
      'Oro',
      'Cobre',
      'Madera de cedro',
      'Bambú',
      'Cuero',
      'Fibras naturales',
      'Piedras semi-preciosas',
      'Conchas marinas',
    ];
  }

  // Mock data
  static List<ArtisanProduct> _getMockProducts() {
    return [
      ArtisanProduct(
        id: '1',
        artisanId: 'artisan1',
        name: 'Vasija Shipibo Tradicional',
        description:
            'Hermosa vasija de cerámica con diseños geométricos tradicionales shipibo. Cada pieza es única y cuenta con certificado de autenticidad.',
        price: 150.0,
        currency: 'PEN',
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop&crop=center',
          'https://images.unsplash.com/photo-1605034313761-73ea4a0cfbf3?w=800&h=600&fit=crop&crop=center',
          'https://images.unsplash.com/photo-1616086555670-bb68e9f4a4d6?w=800&h=600&fit=crop&crop=center',
        ],
        category: 'Cerámica',
        materials: ['Arcilla', 'Pigmentos naturales'],
        dimensions: {
          'altura': '25cm',
          'diámetro': '20cm',
          'peso': '1.2kg',
        },
        stockQuantity: 5,
        origin: 'Ucayali, Perú',
        isHandmade: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      ArtisanProduct(
        id: '2',
        artisanId: 'artisan1',
        name: 'Chal de Alpaca Andino',
        description:
            'Chal tejido a mano con lana de alpaca 100% natural. Diseños inspirados en la tradición andina con colores naturales.',
        price: 200.0,
        currency: 'PEN',
        imageUrls: [
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&h=600&fit=crop&crop=center',
          'https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=800&h=600&fit=crop&crop=center',
        ],
        category: 'Textiles',
        materials: ['Lana de alpaca', 'Tintes naturales'],
        dimensions: {
          'largo': '180cm',
          'ancho': '60cm',
          'peso': '0.3kg',
        },
        stockQuantity: 8,
        origin: 'Cusco, Perú',
        isHandmade: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ArtisanProduct(
        id: '3',
        artisanId: 'artisan1',
        name: 'Collar de Plata Moche',
        description:
            'Collar inspirado en la joyería Moche, elaborado en plata 950 con técnicas ancestrales de orfebrería.',
        price: 350.0,
        currency: 'PEN',
        imageUrls: [
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=800&h=600&fit=crop&crop=center',
          'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=800&h=600&fit=crop&crop=center',
        ],
        category: 'Joyería',
        materials: ['Plata 950', 'Turquesa', 'Lapislázuli'],
        dimensions: {
          'largo': '45cm',
          'peso': '0.15kg',
          'ancho_colgante': '8cm',
        },
        stockQuantity: 3,
        origin: 'Trujillo, Perú',
        isHandmade: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      ArtisanProduct(
        id: '4',
        artisanId: 'artisan1',
        name: 'Quena de Bambú',
        description:
            'Quena tradicional andina tallada en bambú natural. Afinada en tonalidad G mayor, ideal para músicos y coleccionistas.',
        price: 80.0,
        currency: 'PEN',
        imageUrls: [
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=600&fit=crop&crop=center',
          'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=800&h=600&fit=crop&crop=center',
        ],
        category: 'Instrumentos musicales',
        materials: ['Bambú', 'Cera natural'],
        dimensions: {
          'largo': '35cm',
          'diámetro': '2cm',
          'peso': '0.08kg',
        },
        stockQuantity: 12,
        origin: 'Ayacucho, Perú',
        isHandmade: true,
        isActive: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }
}
