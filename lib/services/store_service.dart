import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store_product.dart';
import '../models/tourism_service.dart';

class StoreService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/tienda';

  // Cache simple con timestamps
  static Map<String, dynamic> _cache = {};
  static const Duration cacheExpiry = Duration(minutes: 5);

  /// Obtener todos los productos
  static Future<List<StoreProduct>> getAllProducts() async {
    const cacheKey = 'all_products';

    // Verificar cache
    if (_isValidCache(cacheKey)) {
      final List<dynamic> cached = _cache[cacheKey]['data'];
      return cached.map((json) => StoreProduct.fromJson(json)).toList();
    }

    try {
      print('🛍️ Obteniendo productos desde API...');

      final response = await http.get(
        Uri.parse('$baseUrl/productos'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> productsJson = responseData['data'];
          final products =
              productsJson.map((json) => StoreProduct.fromJson(json)).toList();

          // Guardar en cache
          _cache[cacheKey] = {
            'data': productsJson,
            'timestamp': DateTime.now(),
          };

          print('✅ ${products.length} productos obtenidos exitosamente');
          return products;
        }
      }

      print('❌ Error en respuesta: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error obteniendo productos: $e');
      return [];
    }
  }

  /// Obtener productos por categoría
  static Future<List<StoreProduct>> getProductsByCategory(
      String category) async {
    final cacheKey = 'products_$category';

    // Verificar cache
    if (_isValidCache(cacheKey)) {
      final List<dynamic> cached = _cache[cacheKey]['data'];
      return cached.map((json) => StoreProduct.fromJson(json)).toList();
    }

    try {
      print('🎨 Obteniendo productos de categoría: $category');

      final response = await http.get(
        Uri.parse('$baseUrl/productos/categoria/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> productsJson = responseData['data'];
          final products =
              productsJson.map((json) => StoreProduct.fromJson(json)).toList();

          // Guardar en cache
          _cache[cacheKey] = {
            'data': productsJson,
            'timestamp': DateTime.now(),
          };

          return products;
        }
      }

      return [];
    } catch (e) {
      print('❌ Error obteniendo productos por categoría: $e');
      return [];
    }
  }

  /// Buscar productos con filtros
  static Future<List<StoreProduct>> searchProducts({
    String? searchTerm,
    double? minPrice,
    double? maxPrice,
    String? department,
  }) async {
    try {
      print('🔍 Buscando productos con filtros...');

      final queryParams = <String, String>{};
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['termino'] = searchTerm;
      }
      if (minPrice != null) queryParams['precioMin'] = minPrice.toString();
      if (maxPrice != null) queryParams['precioMax'] = maxPrice.toString();
      if (department != null && department.isNotEmpty) {
        queryParams['departamento'] = department;
      }

      final uri = Uri.parse('$baseUrl/productos/buscar').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> productsJson = responseData['data'];
          return productsJson
              .map((json) => StoreProduct.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('❌ Error en búsqueda de productos: $e');
      return [];
    }
  }

  /// Obtener todos los servicios turísticos
  static Future<List<TourismService>> getAllServices() async {
    const cacheKey = 'all_services';

    // Verificar cache
    if (_isValidCache(cacheKey)) {
      final List<dynamic> cached = _cache[cacheKey]['data'];
      return cached.map((json) => TourismService.fromJson(json)).toList();
    }

    try {
      print('🗺️ Obteniendo servicios desde API...');

      final response = await http.get(
        Uri.parse('$baseUrl/servicios'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> servicesJson = responseData['data'];
          final services = servicesJson
              .map((json) => TourismService.fromJson(json))
              .toList();

          // Guardar en cache
          _cache[cacheKey] = {
            'data': servicesJson,
            'timestamp': DateTime.now(),
          };

          print('✅ ${services.length} servicios obtenidos exitosamente');
          return services;
        }
      }

      print('❌ Error en respuesta: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Error obteniendo servicios: $e');
      return [];
    }
  }

  /// Obtener servicios por categoría
  static Future<List<TourismService>> getServicesByCategory(
      String category) async {
    final cacheKey = 'services_$category';

    // Verificar cache
    if (_isValidCache(cacheKey)) {
      final List<dynamic> cached = _cache[cacheKey]['data'];
      return cached.map((json) => TourismService.fromJson(json)).toList();
    }

    try {
      print('🏛️ Obteniendo servicios de categoría: $category');

      final response = await http.get(
        Uri.parse('$baseUrl/servicios/categoria/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> servicesJson = responseData['data'];
          final services = servicesJson
              .map((json) => TourismService.fromJson(json))
              .toList();

          // Guardar en cache
          _cache[cacheKey] = {
            'data': servicesJson,
            'timestamp': DateTime.now(),
          };

          return services;
        }
      }

      return [];
    } catch (e) {
      print('❌ Error obteniendo servicios por categoría: $e');
      return [];
    }
  }

  /// Buscar servicios con filtros
  static Future<List<TourismService>> searchServices({
    String? searchTerm,
    double? minPrice,
    double? maxPrice,
    String? department,
    String? difficulty,
    int? minDuration,
    int? maxDuration,
  }) async {
    try {
      print('🔍 Buscando servicios con filtros...');

      final queryParams = <String, String>{};
      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['termino'] = searchTerm;
      }
      if (minPrice != null) queryParams['precioMin'] = minPrice.toString();
      if (maxPrice != null) queryParams['precioMax'] = maxPrice.toString();
      if (department != null && department.isNotEmpty) {
        queryParams['departamento'] = department;
      }
      if (difficulty != null && difficulty.isNotEmpty) {
        queryParams['dificultad'] = difficulty;
      }
      if (minDuration != null)
        queryParams['duracionMin'] = minDuration.toString();
      if (maxDuration != null)
        queryParams['duracionMax'] = maxDuration.toString();

      final uri = Uri.parse('$baseUrl/servicios/buscar').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> servicesJson = responseData['data'];
          return servicesJson
              .map((json) => TourismService.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('❌ Error en búsqueda de servicios: $e');
      return [];
    }
  }

  /// Obtener categorías de productos
  static Future<Map<String, String>> getProductCategories() async {
    const cacheKey = 'product_categories';

    // Verificar cache
    if (_isValidCache(cacheKey)) {
      return Map<String, String>.from(_cache[cacheKey]['data']);
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/productos/categorias'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final Map<String, String> categories =
              Map<String, String>.from(responseData['data']);

          // Guardar en cache
          _cache[cacheKey] = {
            'data': categories,
            'timestamp': DateTime.now(),
          };

          return categories;
        }
      }

      return {};
    } catch (e) {
      print('❌ Error obteniendo categorías de productos: $e');
      return {};
    }
  }

  /// Obtener categorías de servicios
  static Future<Map<String, String>> getServiceCategories() async {
    const cacheKey = 'service_categories';

    // Verificar cache
    if (_isValidCache(cacheKey)) {
      return Map<String, String>.from(_cache[cacheKey]['data']);
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/servicios/categorias'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final Map<String, String> categories =
              Map<String, String>.from(responseData['data']);

          // Guardar en cache
          _cache[cacheKey] = {
            'data': categories,
            'timestamp': DateTime.now(),
          };

          return categories;
        }
      }

      return {};
    } catch (e) {
      print('❌ Error obteniendo categorías de servicios: $e');
      return {};
    }
  }

  /// Verificar si el cache es válido
  static bool _isValidCache(String key) {
    if (!_cache.containsKey(key)) return false;

    final cacheTime = _cache[key]['timestamp'] as DateTime;
    return DateTime.now().difference(cacheTime) < cacheExpiry;
  }

  /// Obtener producto por ID
  static Future<StoreProduct?> getProductById(String productId) async {
    try {
      print('🛍️ Obteniendo producto $productId...');

      final response = await http.get(
        Uri.parse('$baseUrl/productos/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final productJson = responseData['data'];
          final product = StoreProduct.fromJson(productJson);

          print('✅ Producto obtenido exitosamente');
          return product;
        }
      }

      print('❌ Error obteniendo producto: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error obteniendo producto: $e');
      return null;
    }
  }

  /// Obtener servicio por ID
  static Future<TourismService?> getServiceById(String serviceId) async {
    try {
      print('🎯 Obteniendo servicio $serviceId...');

      final response = await http.get(
        Uri.parse('$baseUrl/servicios/$serviceId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final serviceJson = responseData['data'];
          final service = TourismService.fromJson(serviceJson);

          print('✅ Servicio obtenido exitosamente');
          return service;
        }
      }

      print('❌ Error obteniendo servicio: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Error obteniendo servicio: $e');
      return null;
    }
  }

  /// Limpiar cache
  static void clearCache() {
    _cache.clear();
    print('🧹 Cache de tienda limpiado');
  }
}
