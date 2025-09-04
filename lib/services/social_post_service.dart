import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/social_post.dart';
import '../config/app_config.dart';
import 'auth_service.dart';

class SocialPostService {
  static const String baseUrl = AppConfig.baseUrl;

  // ==================== CRUD de Posts ====================

  /// Obtener feed de posts con paginación
  static Future<List<SocialPost>> getFeedPosts({
    int page = 0,
    int limit = 10,
    String? userId,
    String? tag,
    String? location,
    String? department,
  }) async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      // Construir query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (userId != null) queryParams['userId'] = userId;
      if (tag != null) queryParams['tag'] = tag;
      if (location != null) queryParams['location'] = location;
      if (department != null) queryParams['department'] = department;

      final uri = Uri.parse('$baseUrl/api/social/posts').replace(
        queryParameters: queryParams,
      );

      print('🔍 Obteniendo posts del feed: $uri');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final posts = data.map((json) => SocialPost.fromJson(json)).toList();

        print('✅ ${posts.length} posts obtenidos exitosamente');
        return posts;
      } else {
        print('❌ Error al obtener posts: ${response.statusCode}');
        throw Exception('Error al obtener posts: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getFeedPosts: $e');
      // Retornar datos de ejemplo en caso de error
      return _getSamplePosts();
    }
  }

  /// Obtener posts de un usuario específico
  static Future<List<SocialPost>> getUserPosts(
    String userId, {
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final uri = Uri.parse('$baseUrl/api/social/users/$userId/posts').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SocialPost.fromJson(json)).toList();
      } else {
        throw Exception(
            'Error al obtener posts del usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getUserPosts: $e');
      return [];
    }
  }

  /// Crear una nueva publicación
  static Future<SocialPost> createPost(CreatePostRequest request) async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      print('📝 Creando nueva publicación...');

      // Convertir la estructura para que coincida con el backend
      final backendRequest = {
        'imageUrls': request.imageUrls,
        'description': request.description,
        'location': request.location,
        'department': request.department,
        'latitude': request.latitude,
        'longitude': request.longitude,
        'tags': request.tags,
        'mentionedCulturalObjects': request.mentionedCulturalObjects,
        'privacy': request.visibility.toUpperCase()
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/social/posts'),
            headers: headers,
            body: json.encode(backendRequest),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        print('✅ Publicación creada exitosamente');
        if (data is Map<String, dynamic>) {
          if (data.containsKey('post')) {
            return SocialPost.fromJson(data['post']);
          } else {
            return SocialPost.fromJson(data);
          }
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al crear publicación: $e');
      throw Exception('Error al crear publicación: $e');
    }
  }

  /// Obtener detalles de un post específico
  static Future<SocialPost?> getPostById(String postId) async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final response = await http.get(
        Uri.parse('$baseUrl/api/social/posts/$postId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SocialPost.fromJson(data);
      } else {
        throw Exception('Error al obtener post: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getPostById: $e');
      return null;
    }
  }

  // ==================== Interacciones ====================

  /// Dar/quitar like a un post
  static Future<Map<String, dynamic>> toggleLike(String postId) async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final response = await http.post(
        Uri.parse('$baseUrl/api/social/posts/$postId/like'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'liked': data['liked'] ?? false,
          'likeCount': data['likeCount'] ?? 0,
        };
      } else {
        throw Exception('Error al dar like: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en toggleLike: $e');
      throw Exception('Error al dar like: $e');
    }
  }

  /// Guardar/quitar guardado a un post
  static Future<Map<String, dynamic>> toggleSave(String postId) async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final response = await http.post(
        Uri.parse('$baseUrl/api/social/posts/$postId/save'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'saved': data['saved'] ?? false,
          'saveCount': data['saveCount'] ?? 0,
        };
      } else {
        throw Exception('Error al guardar: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en toggleSave: $e');
      throw Exception('Error al guardar: $e');
    }
  }

  /// Compartir un post
  static Future<bool> sharePost(String postId) async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final response = await http.post(
        Uri.parse('$baseUrl/api/social/posts/$postId/share'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error al compartir: $e');
      return false;
    }
  }

  // ==================== Gestión de Imágenes ====================

  /// Subir imágenes para un post
  static Future<List<String>> uploadPostImages(
    List<File> images,
    String userId,
  ) async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      print('📸 Subiendo ${images.length} imágenes...');

      // Crear multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/social/upload/images'),
      );

      // Agregar solo header de autenticación (no forzar Content-Type en multipart)
      final authHeader = <String, String>{};
      if (headers.containsKey('Authorization')) {
        authHeader['Authorization'] = headers['Authorization']!;
      }
      request.headers.addAll(authHeader);

      // Agregar archivos
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final ext = _getFileExtension(file.path);
        final safeExt = _normalizeImageExtension(ext);
        final contentType = _inferMediaType(safeExt);

        final multipartFile = await http.MultipartFile.fromPath(
          'images',
          file.path,
          filename:
              'post_image_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.$safeExt',
          contentType: contentType,
        );
        request.files.add(multipartFile);
      }

      // Agregar campos adicionales
      request.fields['userId'] = userId;
      request.fields['type'] = 'social_post';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final urls = List<String>.from(data['imageUrls'] ?? []);

        print('✅ ${urls.length} imágenes subidas exitosamente');
        return urls;
      } else {
        print(
            '❌ Falló subida de imágenes. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Error al subir imágenes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al subir imágenes: $e');
      throw Exception('Error al subir imágenes: $e');
    }
  }

  // ==================== Filtros y Búsqueda ====================

  /// Buscar posts por texto
  static Future<List<SocialPost>> searchPosts(
    String query, {
    int page = 0,
    int limit = 10,
  }) async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final uri = Uri.parse('$baseUrl/api/social/posts/search').replace(
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SocialPost.fromJson(json)).toList();
      } else {
        throw Exception('Error en búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en searchPosts: $e');
      return [];
    }
  }

  /// Obtener tags trending
  static Future<List<String>> getTrendingTags({int limit = 10}) async {
    try {
      final authService = AuthService();
      final headers = await authService.getAuthHeadersAsync();

      final uri = Uri.parse('$baseUrl/api/social/trending-tags').replace(
        queryParameters: {'limit': limit.toString()},
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<String>.from(data);
      } else {
        return _getSampleTags();
      }
    } catch (e) {
      print('❌ Error en getTrendingTags: $e');
      return _getSampleTags();
    }
  }

  // ==================== Datos de Ejemplo ====================

  static List<SocialPost> _getSamplePosts() {
    return [
      SocialPost(
        id: '1',
        userId: 'user1',
        userName: 'María Artesana',
        userRole: 'artesano',
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',
          'https://images.unsplash.com/photo-1605034313761-73ea4a0cfbf3?w=800&h=600&fit=crop',
        ],
        description:
            '¡Terminé esta hermosa cerámica shipibo! 🏺✨ Cada línea cuenta una historia ancestral. #CerámicaShipibo #ArtePeruano #Tradición',
        location: 'Pucallpa',
        department: 'Ucayali',
        tags: ['ceramica', 'shipibo', 'arte', 'tradicion'],
        likeCount: 47,
        commentCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SocialPost(
        id: '2',
        userId: 'user2',
        userName: 'Carlos Guía',
        userRole: 'guia',
        imageUrls: [
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=600&fit=crop',
        ],
        description:
            'Vista increíble desde Machu Picchu al amanecer 🌄 Los turistas quedaron sin palabras. Estos momentos hacen que todo valga la pena. #MachuPicchu #Sunrise #TourismoPeru',
        location: 'Machu Picchu',
        department: 'Cusco',
        tags: ['machupicchu', 'turismo', 'cusco', 'amanecer'],
        likeCount: 156,
        commentCount: 23,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      SocialPost(
        id: '3',
        userId: 'user3',
        userName: 'Ana Viajera',
        userRole: 'usuario',
        imageUrls: [
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800&h=600&fit=crop',
        ],
        description:
            'Aprendiendo a tejer con doña Rosa en Chinchero 🧶 Sus manos guardan siglos de sabiduría. Qué experiencia tan enriquecedora! #Chinchero #Tejido #CulturaViva',
        location: 'Chinchero',
        department: 'Cusco',
        tags: ['tejido', 'chinchero', 'cultura', 'tradicion'],
        likeCount: 89,
        commentCount: 18,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }

  static List<String> _getSampleTags() {
    return [
      'arte',
      'tradicion',
      'cultura',
      'ceramica',
      'tejido',
      'machupicchu',
      'cusco',
      'lima',
      'artesania',
      'turismo',
    ];
  }

  // ==================== Utilidades internas ====================
  // Extrae la extensión del archivo (sin el punto), en minúsculas
  static String _getFileExtension(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1 || idx == path.length - 1) return '';
    return path.substring(idx + 1).toLowerCase();
  }

  // Normaliza la extensión a un subconjunto soportado
  static String _normalizeImageExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpeg':
        return 'jpeg';
      case 'jpg':
        return 'jpg';
      case 'png':
        return 'png';
      case 'webp':
        return 'webp';
      default:
        return 'jpg';
    }
  }

  // Devuelve el MediaType correcto para la imagen
  static MediaType _inferMediaType(String extOrNormalized) {
    final e = _normalizeImageExtension(extOrNormalized);
    if (e == 'png') return MediaType('image', 'png');
    if (e == 'webp') return MediaType('image', 'webp');
    // Para jpg/jpeg usar image/jpeg (aceptado por el backend)
    return MediaType('image', 'jpeg');
  }
}
