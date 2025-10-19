import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store_product.dart';
import '../models/tourism_service.dart';
import '../config/api_config.dart';

class StoreService {
  static const String baseUrl = '${ApiConfig.baseUrl}/api/tienda';

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
      ).timeout(const Duration(seconds: 3));

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
      // Retornar productos mock si la API falla
      return _getMockProducts();
    } catch (e) {
      print('❌ Error obteniendo productos: $e');
      print('📦 Usando productos de prueba...');
      // Retornar productos mock si hay error de conexión
      return _getMockProducts();
    }
  }

  /// Productos de prueba para cuando no hay backend disponible
  static List<StoreProduct> _getMockProducts() {
    final now = DateTime.now().toIso8601String();
    return [
      StoreProduct(
        id: 'mock-1',
        title: 'Cerámica Burilada',
        description:
            'Cerámica tradicional del norte peruano con diseños únicos',
        price: 120.0,
        formattedPrice: 'S/ 120.00',
        currency: 'PEN',
        category: 'ceramica',
        categoryDisplayName: 'Cerámica',
        type: 'artesania',
        typeDisplayName: 'Artesanía',
        images: ['assets/images/productos_images/ceramica_burilada.png'],
        location: 'Lima',
        department: 'Lima',
        stock: 10,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-1',
        artisanName: 'Artesano Tradicional',
        artisanEmail: 'artesano@example.com',
        artisanPhone: '999999999',
        rating: 4.5,
        formattedRating: '4.5',
        reviewCount: 12,
        viewCount: 45,
        createdAt: now,
        updatedAt: now,
      ),
      StoreProduct(
        id: 'mock-2',
        title: 'Manto Andino',
        description:
            'Textil artesanal tejido a mano con patrones tradicionales',
        price: 250.0,
        formattedPrice: 'S/ 250.00',
        currency: 'PEN',
        category: 'textiles',
        categoryDisplayName: 'Textiles',
        type: 'artesania',
        typeDisplayName: 'Artesanía',
        images: ['assets/images/productos_images/manto_andino.png'],
        location: 'Cusco',
        department: 'Cusco',
        stock: 5,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-2',
        artisanName: 'Tejedora Andina',
        artisanEmail: 'tejedora@example.com',
        artisanPhone: '999999998',
        rating: 5.0,
        formattedRating: '5.0',
        reviewCount: 25,
        viewCount: 89,
        createdAt: now,
        updatedAt: now,
      ),
      StoreProduct(
        id: 'mock-3',
        title: 'Muñecas Andinas',
        description: 'Muñecas tradicionales hechas a mano con trajes típicos',
        price: 80.0,
        formattedPrice: 'S/ 80.00',
        currency: 'PEN',
        category: 'artesania',
        categoryDisplayName: 'Artesanía',
        type: 'decoracion',
        typeDisplayName: 'Decoración',
        images: ['assets/images/productos_images/muñecas_andinas.png'],
        location: 'Ayacucho',
        department: 'Ayacucho',
        stock: 15,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-3',
        artisanName: 'Artesana Local',
        artisanEmail: 'artesana@example.com',
        artisanPhone: '999999997',
        rating: 4.8,
        formattedRating: '4.8',
        reviewCount: 18,
        viewCount: 67,
        createdAt: now,
        updatedAt: now,
      ),
      StoreProduct(
        id: 'mock-4',
        title: 'Plato de Arcilla Andino',
        description:
            'Plato decorativo de arcilla andina con diseños autóctonos',
        price: 60.0,
        formattedPrice: 'S/ 60.00',
        currency: 'PEN',
        category: 'ceramica',
        categoryDisplayName: 'Cerámica',
        type: 'decoracion',
        typeDisplayName: 'Decoración',
        images: ['assets/images/productos_images/plato_de_arcilla_andino.png'],
        location: 'Puno',
        department: 'Puno',
        stock: 20,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-4',
        artisanName: 'Ceramista del Altiplano',
        artisanEmail: 'ceramista@example.com',
        artisanPhone: '999999996',
        rating: 4.3,
        formattedRating: '4.3',
        reviewCount: 9,
        viewCount: 34,
        createdAt: now,
        updatedAt: now,
      ),
      StoreProduct(
        id: 'mock-5',
        title: 'Retablo Ayacuchano',
        description:
            'Retablo tradicional de Ayacucho con escenas costumbristas',
        price: 180.0,
        formattedPrice: 'S/ 180.00',
        currency: 'PEN',
        category: 'artesania',
        categoryDisplayName: 'Artesanía',
        type: 'decoracion',
        typeDisplayName: 'Decoración',
        images: ['assets/images/productos_images/retablo_ayacuchano.png'],
        location: 'Ayacucho',
        department: 'Ayacucho',
        stock: 8,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-5',
        artisanName: 'Maestro Retablista',
        artisanEmail: 'retablista@example.com',
        artisanPhone: '999999995',
        rating: 4.9,
        formattedRating: '4.9',
        reviewCount: 31,
        viewCount: 120,
        createdAt: now,
        updatedAt: now,
      ),
      StoreProduct(
        id: 'mock-6',
        title: 'Toro de Pucará',
        description: 'Icónica figura de toro de cerámica símbolo de protección',
        price: 150.0,
        formattedPrice: 'S/ 150.00',
        currency: 'PEN',
        category: 'ceramica',
        categoryDisplayName: 'Cerámica',
        type: 'decoracion',
        typeDisplayName: 'Decoración',
        images: ['assets/images/productos_images/toro_de_pucara.png'],
        location: 'Puno',
        department: 'Puno',
        stock: 12,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-6',
        artisanName: 'Artesano Puneño',
        artisanEmail: 'toro@example.com',
        artisanPhone: '999999994',
        rating: 4.7,
        formattedRating: '4.7',
        reviewCount: 22,
        viewCount: 78,
        createdAt: now,
        updatedAt: now,
      ),
    ];
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
