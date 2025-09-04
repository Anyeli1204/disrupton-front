import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/favorite.dart';

class FavoritesService {
  static const String baseUrl = 'http://localhost:8080/api/favoritos';

  /// Obtener favoritos del usuario
  static Future<List<Favorite>> getUserFavorites(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuario/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> favoritesJson = responseData['data'];
          return favoritesJson.map((json) => Favorite.fromJson(json)).toList();
        }
      }

      return [];
    } catch (e) {
      print('❌ Error obteniendo favoritos: $e');
      return [];
    }
  }

  /// Agregar a favoritos
  static Future<bool> addToFavorites({
    required String userId,
    required String itemId,
    required String itemType,
    required String title,
    required String imageUrl,
    required double price,
    required String location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'itemId': itemId,
          'itemType': itemType,
          'title': title,
          'imageUrl': imageUrl,
          'price': price,
          'location': location,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error agregando a favoritos: $e');
      return false;
    }
  }

  /// Remover de favoritos
  static Future<bool> removeFromFavorites(String userId, String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/usuario/$userId/item/$itemId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error removiendo de favoritos: $e');
      return false;
    }
  }

  /// Verificar si un item está en favoritos
  static Future<bool> isFavorite(String userId, String itemId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuario/$userId/item/$itemId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['isFavorite'] ?? false;
      }

      return false;
    } catch (e) {
      print('❌ Error verificando favorito: $e');
      return false;
    }
  }
}
