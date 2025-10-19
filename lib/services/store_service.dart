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
        title: 'Cerámica Burilada de Chulucanas',
        description:
            'Cerámica tradicional de Piura con técnica de burilado, caracterizada por sus diseños geométricos en negro sobre fondo natural',
        price: 145.0,
        formattedPrice: 'S/ 145.00',
        currency: 'PEN',
        category: 'ceramica',
        categoryDisplayName: 'Cerámica',
        type: 'artesania',
        typeDisplayName: 'Artesanía',
        images: ['assets/images/productos_images/ceramica_burilada.jpeg'],
        location: 'Chulucanas, Piura',
        department: 'Piura',
        stock: 8,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-1',
        artisanName: 'Rosa Flores',
        artisanEmail: 'rflores@artesanos.pe',
        artisanPhone: '987654321',
        rating: 4.8,
        formattedRating: '4.8',
        reviewCount: 24,
        viewCount: 156,
        createdAt: now,
        updatedAt: now,
      ),
      StoreProduct(
        id: 'mock-2',
        title: 'Manto Andino Tradicional',
        description:
            'Textil artesanal tejido a mano con técnicas ancestrales, elaborado en telar tradicional con lana de alpaca y diseños simbólicos andinos',
        price: 280.0,
        formattedPrice: 'S/ 280.00',
        currency: 'PEN',
        category: 'textil',
        categoryDisplayName: 'Textil',
        type: 'artesania',
        typeDisplayName: 'Artesanía',
        images: ['assets/images/productos_images/manto_andino.jpeg'],
        location: 'Cusco',
        department: 'Cusco',
        stock: 5,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-2',
        artisanName: 'María Quispe',
        artisanEmail: 'mquispe@artesanos.pe',
        artisanPhone: '987654322',
        rating: 4.9,
        formattedRating: '4.9',
        reviewCount: 31,
        viewCount: 189,
        createdAt: now,
        updatedAt: now,
      ),
      StoreProduct(
        id: 'mock-3',
        title: 'Muñecas Andinas Decorativas',
        description:
            'Muñecas artesanales vestidas con trajes típicos andinos, elaboradas con materiales naturales y detalles bordados a mano',
        price: 65.0,
        formattedPrice: 'S/ 65.00',
        currency: 'PEN',
        category: 'decoracion',
        categoryDisplayName: 'Decoración',
        type: 'artesania',
        typeDisplayName: 'Artesanía',
        images: ['assets/images/productos_images/muñecas_andinas.jpeg'],
        location: 'Puno',
        department: 'Puno',
        stock: 15,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-3',
        artisanName: 'Juana Mamani',
        artisanEmail: 'jmamani@artesanos.pe',
        artisanPhone: '987654323',
        rating: 4.6,
        formattedRating: '4.6',
        reviewCount: 18,
        viewCount: 92,
        createdAt: now,
        updatedAt: now,
      ),
      StoreProduct(
        id: 'mock-4',
        title: 'Plato de Arcilla Andino',
        description:
            'Plato decorativo de arcilla hecho a mano con motivos geométricos andinos, ideal para decoración o uso ceremonial',
        price: 85.0,
        formattedPrice: 'S/ 85.00',
        currency: 'PEN',
        category: 'ceramica',
        categoryDisplayName: 'Cerámica',
        type: 'artesania',
        typeDisplayName: 'Artesanía',
        images: ['assets/images/productos_images/plato_de_arcilla_andino.jpeg'],
        location: 'Ayacucho',
        department: 'Ayacucho',
        stock: 12,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-4',
        artisanName: 'Pedro Huamán',
        artisanEmail: 'phuaman@artesanos.pe',
        artisanPhone: '987654324',
        rating: 4.7,
        formattedRating: '4.7',
        reviewCount: 15,
        viewCount: 78,
        createdAt: now,
        updatedAt: now,
      ),
      StoreProduct(
        id: 'mock-5',
        title: 'Retablo Ayacuchano',
        description:
            'Retablo tradicional de Ayacucho con escenas costumbristas, elaborado con yeso y pintado a mano con colores vivos',
        price: 195.0,
        formattedPrice: 'S/ 195.00',
        currency: 'PEN',
        category: 'decoracion',
        categoryDisplayName: 'Decoración',
        type: 'artesania',
        typeDisplayName: 'Artesanía',
        images: ['assets/images/productos_images/retablo.jpeg'],
        location: 'Ayacucho',
        department: 'Ayacucho',
        stock: 7,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-5',
        artisanName: 'Luis Ccahuana',
        artisanEmail: 'lccahuana@artesanos.pe',
        artisanPhone: '987654325',
        rating: 4.9,
        formattedRating: '4.9',
        reviewCount: 28,
        viewCount: 145,
        createdAt: now,
        updatedAt: now,
      ),
      StoreProduct(
        id: 'mock-6',
        title: 'Toro de Pucará',
        description:
            'Escultura cerámica tradicional de Puno en forma de toro, símbolo de protección y buena suerte en la cultura andina',
        price: 120.0,
        formattedPrice: 'S/ 120.00',
        currency: 'PEN',
        category: 'ceramica',
        categoryDisplayName: 'Cerámica',
        type: 'artesania',
        typeDisplayName: 'Artesanía',
        images: ['assets/images/productos_images/toro_pucara.jpeg'],
        location: 'Pucará, Puno',
        department: 'Puno',
        stock: 10,
        isActive: true,
        availabilityStatus: 'available',
        artisanId: 'artisan-6',
        artisanName: 'Carlos Apaza',
        artisanEmail: 'capaza@artesanos.pe',
        artisanPhone: '987654326',
        rating: 4.8,
        formattedRating: '4.8',
        reviewCount: 22,
        viewCount: 134,
        createdAt: now,
        updatedAt: now,
      ),
    ];
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
      ).timeout(const Duration(seconds: 3));

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
      return _getMockServices();
    } catch (e) {
      print('❌ Error obteniendo servicios: $e');
      return _getMockServices();
    }
  }

  /// Servicios de prueba para cuando no hay backend disponible
  static List<TourismService> _getMockServices() {
    final now = DateTime.now().toIso8601String();
    return [
      TourismService(
        id: 'service-1',
        title: 'Expedición Machu Picchu',
        description:
            'Tour guiado completo a la ciudadela inca de Machu Picchu con guía bilingüe, incluyendo transporte en tren y almuerzo tradicional',
        price: 450.0,
        formattedPrice: 'S/ 450.00',
        currency: 'PEN',
        category: 'aventura',
        categoryDisplayName: 'Aventura',
        images: ['assets/images/servicios_images/expedicion_machu_picchu.jpeg'],
        location: 'Cusco',
        department: 'Cusco',
        durationHours: 12,
        formattedDuration: '12 horas',
        difficulty: 'MODERADO',
        difficultyDisplayName: 'Moderado',
        maxGroupSize: 15,
        languages: ['Español', 'Inglés'],
        included: [
          'Transporte en tren',
          'Almuerzo',
          'Guía bilingüe',
          'Entrada'
        ],
        notIncluded: ['Propinas', 'Bebidas alcohólicas'],
        requirements: ['Buen estado físico', 'Documentos de identidad'],
        advanceBookingDays: 3,
        isActive: true,
        availabilityStatus: 'available',
        guideId: 'guide-1',
        guideName: 'Carlos Quispe',
        guideContact: '984123456',
        rating: 4.9,
        formattedRating: '4.9',
        reviewCount: 145,
        viewCount: 876,
        createdAt: now,
        updatedAt: now,
      ),
      TourismService(
        id: 'service-2',
        title: 'Expedición Huascarán',
        description:
            'Trekking al nevado Huascarán, la montaña más alta del Perú con 6768m. Incluye equipo de montaña, guía experto y aclimatación previa',
        price: 1200.0,
        formattedPrice: 'S/ 1200.00',
        currency: 'PEN',
        category: 'aventura',
        categoryDisplayName: 'Aventura',
        images: ['assets/images/servicios_images/expedicion_huascaran.jpeg'],
        location: 'Huaraz',
        department: 'Ancash',
        durationHours: 168,
        formattedDuration: '7 días',
        difficulty: 'EXTREMO',
        difficultyDisplayName: 'Extremo',
        maxGroupSize: 8,
        languages: ['Español', 'Inglés'],
        included: [
          'Equipo de montaña',
          'Guía experto',
          'Aclimatación',
          'Alimentación completa'
        ],
        notIncluded: ['Seguro de viaje', 'Transporte aéreo'],
        requirements: [
          'Excelente estado físico',
          'Experiencia en alta montaña',
          'Certificado médico'
        ],
        advanceBookingDays: 15,
        isActive: true,
        availabilityStatus: 'available',
        guideId: 'guide-2',
        guideName: 'Raúl Morales',
        guideContact: '943234567',
        rating: 4.8,
        formattedRating: '4.8',
        reviewCount: 78,
        viewCount: 432,
        createdAt: now,
        updatedAt: now,
      ),
      TourismService(
        id: 'service-3',
        title: 'Clases de Cocina Peruana',
        description:
            'Aprende a preparar platos emblemáticos de la gastronomía peruana con chef profesional. Incluye ingredientes y recetario',
        price: 180.0,
        formattedPrice: 'S/ 180.00',
        currency: 'PEN',
        category: 'gastronomia',
        categoryDisplayName: 'Gastronomía',
        images: ['assets/images/servicios_images/clases_cocina_peruana.jpeg'],
        location: 'Lima',
        department: 'Lima',
        durationHours: 4,
        formattedDuration: '4 horas',
        difficulty: 'FACIL',
        difficultyDisplayName: 'Fácil',
        maxGroupSize: 12,
        languages: ['Español', 'Inglés'],
        included: ['Ingredientes', 'Recetario', 'Degustación', 'Certificado'],
        notIncluded: ['Transporte'],
        requirements: ['Ninguno especial'],
        advanceBookingDays: 2,
        isActive: true,
        availabilityStatus: 'available',
        guideId: 'guide-3',
        guideName: 'Chef María González',
        guideContact: '987345678',
        rating: 4.7,
        formattedRating: '4.7',
        reviewCount: 92,
        viewCount: 543,
        createdAt: now,
        updatedAt: now,
      ),
      TourismService(
        id: 'service-4',
        title: 'Clases de Tejido Inca',
        description:
            'Taller de tejido tradicional andino con técnicas ancestrales. Aprende a usar telar y crear diseños típicos con lana de alpaca',
        price: 150.0,
        formattedPrice: 'S/ 150.00',
        currency: 'PEN',
        category: 'cultura',
        categoryDisplayName: 'Cultura',
        images: ['assets/images/servicios_images/clases_de_tejido_inca.jpeg'],
        location: 'Cusco',
        department: 'Cusco',
        durationHours: 3,
        formattedDuration: '3 horas',
        difficulty: 'FACIL',
        difficultyDisplayName: 'Fácil',
        maxGroupSize: 10,
        languages: ['Español', 'Quechua'],
        included: [
          'Materiales',
          'Guía artesana',
          'Telar tradicional',
          'Pieza terminada'
        ],
        notIncluded: ['Transporte'],
        requirements: ['Ninguno especial'],
        advanceBookingDays: 1,
        isActive: true,
        availabilityStatus: 'available',
        guideId: 'guide-4',
        guideName: 'Tejedora Juana Ccahuana',
        guideContact: '984456789',
        rating: 4.8,
        formattedRating: '4.8',
        reviewCount: 67,
        viewCount: 321,
        createdAt: now,
        updatedAt: now,
      ),
      TourismService(
        id: 'service-5',
        title: 'Paseo Nocturno Plaza de Lima',
        description:
            'Recorrido nocturno por el centro histórico de Lima, descubriendo su arquitectura colonial iluminada y leyendas urbanas',
        price: 85.0,
        formattedPrice: 'S/ 85.00',
        currency: 'PEN',
        category: 'cultural',
        categoryDisplayName: 'Cultural',
        images: [
          'assets/images/servicios_images/paseo_noturno_plaza_lima.jpeg'
        ],
        location: 'Lima Centro',
        department: 'Lima',
        durationHours: 3,
        formattedDuration: '2.5 horas',
        difficulty: 'FACIL',
        difficultyDisplayName: 'Fácil',
        maxGroupSize: 20,
        languages: ['Español', 'Inglés'],
        included: ['Guía turístico', 'Entrada a monumentos', 'Snack'],
        notIncluded: ['Transporte', 'Cena'],
        requirements: ['Ninguno especial'],
        advanceBookingDays: 1,
        isActive: true,
        availabilityStatus: 'available',
        guideId: 'guide-5',
        guideName: 'Pedro Castillo',
        guideContact: '987567890',
        rating: 4.6,
        formattedRating: '4.6',
        reviewCount: 134,
        viewCount: 678,
        createdAt: now,
        updatedAt: now,
      ),
      TourismService(
        id: 'service-6',
        title: 'Cata de Vinos Peruanos',
        description:
            'Degustación de vinos artesanales del valle de Ica con sommelier experto. Incluye maridaje con quesos y productos locales',
        price: 220.0,
        formattedPrice: 'S/ 220.00',
        currency: 'PEN',
        category: 'gastronomia',
        categoryDisplayName: 'Gastronomía',
        images: ['assets/images/servicios_images/servicio_cata_de_vinos.jpeg'],
        location: 'Ica',
        department: 'Ica',
        durationHours: 3,
        formattedDuration: '3 horas',
        difficulty: 'FACIL',
        difficultyDisplayName: 'Fácil',
        maxGroupSize: 16,
        languages: ['Español'],
        included: [
          'Degustación de vinos',
          'Maridaje',
          'Sommelier',
          'Transporte desde hotel'
        ],
        notIncluded: ['Propinas'],
        requirements: ['Mayor de 18 años'],
        advanceBookingDays: 2,
        isActive: true,
        availabilityStatus: 'available',
        guideId: 'guide-6',
        guideName: 'Sommelier Ana Torres',
        guideContact: '956678901',
        rating: 4.9,
        formattedRating: '4.9',
        reviewCount: 88,
        viewCount: 456,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// Obtener categorías de productos  /// Obtener productos por categoría
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
