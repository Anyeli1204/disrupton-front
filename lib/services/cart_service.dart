import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart.dart';

class CartService {
  static const String baseUrl = 'http://localhost:8080/api/carrito';

  /// Obtener carrito del usuario
  static Future<Cart?> getUserCart(String userId) async {
    try {
      print('🛒 Obteniendo carrito para usuario: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final cartData = responseData['data'];
          final cart = Cart.fromJson(cartData);

          print('✅ Carrito obtenido: ${cart.totalItems} items');
          return cart;
        }
      } else if (response.statusCode == 404) {
        // Carrito vacío, crear uno nuevo
        print('📝 Carrito vacío, creando nuevo carrito');
        return Cart(
          userId: userId,
          items: [],
          updatedAt: DateTime.now(),
        );
      }

      print('❌ Error obteniendo carrito: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error obteniendo carrito: $e');
      return null;
    }
  }

  /// Agregar item al carrito
  static Future<bool> addToCart({
    required String userId,
    required String itemId,
    required String itemType,
    required String title,
    required String imageUrl,
    required double price,
    required String location,
    int quantity = 1,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      print('🛒 Agregando al carrito: $title (x$quantity)');

      final requestBody = {
        'itemId': itemId,
        'itemType': itemType,
        'title': title,
        'imageUrl': imageUrl,
        'price': price,
        'location': location,
        'quantity': quantity,
        'metadata': metadata,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/$userId/agregar'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          print('✅ Item agregado al carrito exitosamente');
          return true;
        }
      }

      print('❌ Error agregando al carrito: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error agregando al carrito: $e');
      return false;
    }
  }

  /// Actualizar cantidad de item en carrito
  static Future<bool> updateCartItemQuantity({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    try {
      print('🛒 Actualizando cantidad: $itemId -> $quantity');

      final requestBody = {
        'quantity': quantity,
      };

      final response = await http.put(
        Uri.parse('$baseUrl/$userId/items/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          print('✅ Cantidad actualizada exitosamente');
          return true;
        }
      }

      print('❌ Error actualizando cantidad: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error actualizando cantidad: $e');
      return false;
    }
  }

  /// Remover item del carrito
  static Future<bool> removeFromCart({
    required String userId,
    required String itemId,
  }) async {
    try {
      print('🛒 Removiendo del carrito: $itemId');

      final response = await http.delete(
        Uri.parse('$baseUrl/$userId/items/$itemId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          print('✅ Item removido del carrito exitosamente');
          return true;
        }
      }

      print('❌ Error removiendo del carrito: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error removiendo del carrito: $e');
      return false;
    }
  }

  /// Limpiar carrito completo
  static Future<bool> clearCart(String userId) async {
    try {
      print('🛒 Limpiando carrito: $userId');

      final response = await http.delete(
        Uri.parse('$baseUrl/$userId/limpiar'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          print('✅ Carrito limpiado exitosamente');
          return true;
        }
      }

      print('❌ Error limpiando carrito: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error limpiando carrito: $e');
      return false;
    }
  }

  /// Realizar pedido (checkout)
  static Future<Map<String, dynamic>?> checkout({
    required String userId,
    required Map<String, dynamic> orderDetails,
  }) async {
    try {
      print('🛒 Procesando pedido para usuario: $userId');

      final response = await http.post(
        Uri.parse('$baseUrl/$userId/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderDetails),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          print('✅ Pedido procesado exitosamente');
          return responseData['data'];
        }
      }

      print('❌ Error procesando pedido: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error procesando pedido: $e');
      return null;
    }
  }

  /// Obtener estadísticas del carrito
  static Future<Map<String, dynamic>?> getCartStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }

      return null;
    } catch (e) {
      print('❌ Error obteniendo estadísticas: $e');
      return null;
    }
  }
}
