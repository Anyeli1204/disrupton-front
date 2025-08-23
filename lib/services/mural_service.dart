import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/app_config.dart';
import '../models/comment.dart';
import '../models/mural_question.dart';
import '../models/user.dart';
import 'auth_service.dart';

// Helper method para parsear Firestore Timestamp
DateTime _parseFirestoreTimestamp(dynamic timestamp) {
  if (timestamp is Map<String, dynamic>) {
    final seconds = timestamp['seconds'] as int?;
    if (seconds != null) {
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
  }
  if (timestamp is String) {
    return DateTime.parse(timestamp);
  }
  return DateTime.now();
}

class MuralService {
  static const String baseUrl = AppConfig.baseUrl;
  
  // Obtener comentarios del mural con reacciones
  static Future<List<Comment>> getMuralComments({String? userId}) async {
    try {
      final activeQuestion = await getActiveMuralQuestion();
      if (activeQuestion == null) {
        return [];
      }

      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      
      String url = '$baseUrl/api/mural/comentarios/${activeQuestion.id}';
      if (userId != null) {
        url += '?userId=$userId';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener comentarios: ${response.statusCode}');
      }
    } catch (e) {
      return getSampleComments();
    }
  }

  // Obtener la pregunta activa del mural
  static Future<MuralQuestion?> getActiveMuralQuestion() async {
    try {
      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/mural/active'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MuralQuestion.fromJson(data);
      } else if (response.statusCode == 204) { // No Content
        return null;
      } else {
        throw Exception('Error al obtener la pregunta activa: ${response.statusCode}');
      }
    } catch (e) {
      // En caso de error, se puede devolver null o manejarlo de otra forma
      return null;
    }
  }

  // Crear comentario en el mural con soporte para imágenes y respuestas
  static Future<Comment?> createMuralComment(String text, String userId, Map<String, String> authHeaders, {String? questionId, User? user, List<String>? imageUrls, String? parentCommentId}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      }..addAll(authHeaders);

      final body = <String, dynamic>{
        'text': text,
        'userId': userId,
        'preguntaId': questionId,
      };
      
      if (imageUrls != null && imageUrls.isNotEmpty) {
        body['imageUrls'] = imageUrls;
      }
      
      if (parentCommentId != null && parentCommentId.isNotEmpty) {
        body['parentCommentId'] = parentCommentId;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/mural/comentarios'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) { // El backend devuelve 200 OK
        final data = json.decode(response.body);
        
        // El backend devuelve un objeto con información de moderación
        if (data['aprobado'] == true) {
          // Si fue aprobado, usar los datos del comentario guardado
          final commentData = data['commentData'];
          if (commentData != null) {
            return Comment(
              id: commentData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
              text: commentData['text'] ?? text,
              userId: commentData['userId'] ?? userId,
              userName: user?.name ?? 'Usuario',
              parentCommentId: commentData['parentCommentId'] ?? parentCommentId,
              createdAt: commentData['createdAt'] != null 
                  ? _parseFirestoreTimestamp(commentData['createdAt'])
                  : DateTime.now(),
              likes: [],
              dislikes: [],
              isEdited: false,
              imageUrls: imageUrls ?? [],
            );
          } else {
            // Fallback si no hay commentData
            return Comment(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: text,
              userId: userId,
              userName: user?.name ?? 'Usuario',
              parentCommentId: parentCommentId,
              createdAt: DateTime.now(),
              likes: [],
              dislikes: [],
              isEdited: false,
              imageUrls: imageUrls ?? [],
            );
          }
        } else {
          // Comentario rechazado por moderación
          throw Exception('Comentario rechazado: ${data['motivo'] ?? 'Contenido inapropiado'}');
        }
      } else {
        // Si hay un error en el servidor, lanzamos una excepción
        throw Exception('Error al crear el comentario: ${response.body}');
      }
    } catch (e) {
      // Si hay un error de conexión o de otro tipo, lo relanzamos
      throw Exception('Error de conexión al crear comentario: $e');
    }
  }

  // Obtener comentarios por objeto cultural
  static Future<List<Comment>> getCommentsByObject(String objectId) async {
    try {
      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/mural/comments?objectId=$objectId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener comentarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener comentarios por usuario
  static Future<List<Comment>> getCommentsByUser(String userId) async {
    try {
      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/mural/comments?userId=$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener comentarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Reaccionar a un comentario (like/dislike con toggle)
  static Future<Map<String, dynamic>> reactToComment(String commentId, String userId, String reactionType) async {
    try {
      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/mural/comentarios/$commentId/reactions?userId=$userId&type=$reactionType'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Asegurar que los conteos nunca sean negativos
        if (responseData.containsKey('likeCount')) {
          responseData['likeCount'] = (responseData['likeCount'] as int? ?? 0).clamp(0, double.infinity).toInt();
        }
        if (responseData.containsKey('dislikeCount')) {
          responseData['dislikeCount'] = (responseData['dislikeCount'] as int? ?? 0).clamp(0, double.infinity).toInt();
        }
        
        return responseData;
      } else {
        throw Exception('Error al reaccionar: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al reaccionar: $e');
    }
  }

  // Dar like a un comentario (usando nuevo sistema)
  static Future<bool> likeComment(String commentId, String userId) async {
    try {
      await reactToComment(commentId, userId, 'like');
      return true;
    } catch (e) {
      throw Exception('Error al dar like: $e');
    }
  }

  // Quitar like de un comentario (usando nuevo sistema)
  static Future<bool> unlikeComment(String commentId, String userId) async {
    try {
      await reactToComment(commentId, userId, 'like'); // Toggle behavior
      return true;
    } catch (e) {
      throw Exception('Error al quitar like: $e');
    }
  }

  // Dar dislike a un comentario (usando nuevo sistema)
  static Future<bool> dislikeComment(String commentId, String userId) async {
    try {
      await reactToComment(commentId, userId, 'dislike');
      return true;
    } catch (e) {
      throw Exception('Error al dar dislike: $e');
    }
  }

  // Quitar dislike de un comentario (usando nuevo sistema)
  static Future<bool> undislikeComment(String commentId, String userId) async {
    try {
      await reactToComment(commentId, userId, 'dislike'); // Toggle behavior
      return true;
    } catch (e) {
      throw Exception('Error al quitar dislike: $e');
    }
  }

  // Subir imágenes para comentarios
  static Future<List<String>> uploadCommentImages(List<File> images, String userId, String commentId) async {
    try {
      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/firebase/storage/upload-comment-images'),
      );

      // Agregar headers de autenticación
      request.headers.addAll(headers);
      
      // Agregar parámetros
      request.fields['userId'] = userId;
      request.fields['commentId'] = commentId;

      // Agregar archivos con el nombre correcto esperado por el backend
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        
        // Detectar el tipo de contenido basado en la extensión del archivo
        String? mimeType;
        final extension = file.path.toLowerCase().split('.').last;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          default:
            mimeType = 'image/jpeg'; // Fallback
        }
        
        final multipartFile = await http.MultipartFile.fromPath(
          'files', // Cambiar de 'images' a 'files' para coincidir con el backend
          file.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        // El backend devuelve 'downloadUrls' no 'imageUrls'
        final urls = data['downloadUrls'];
        if (urls is List) {
          return List<String>.from(urls);
        } else if (urls is String) {
          // Si es un string separado por comas, dividirlo
          return urls.split(',').where((url) => url.trim().isNotEmpty).toList();
        }
        return [];
      } else {
        throw Exception('Error al subir imágenes: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Error al subir imágenes: $e');
    }
  }

  // Obtener conteos de reacciones para un comentario
  static Future<Map<String, dynamic>> getCommentReactions(String commentId) async {
    try {
      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/mural/comentarios/$commentId/reactions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener reacciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener reacciones: $e');
    }
  }

  // Obtener preguntas semanales (mock data por ahora)
  static List<MuralQuestion> getSampleQuestions() {
    return [
      MuralQuestion(
        id: '1',
        question: '¿Cuál es tu experiencia más memorable con la artesanía peruana?',
        description: 'Comparte con la comunidad tus vivencias y aprendizajes sobre las artesanías tradicionales de nuestro país.',
        category: 'artesanía',
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        tags: ['artesanía', 'tradición', 'cultura'],
        commentCount: 12,
        likeCount: 45,
        createdBy: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MuralQuestion(
        id: '2',
        question: '¿Qué lugar cultural te gustaría visitar en Perú y por qué?',
        description: 'Cuéntanos sobre ese sitio histórico o cultural que te llama la atención y qué esperas encontrar allí.',
        category: 'turismo',
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 0)),
        tags: ['turismo', 'historia', 'cultura'],
        commentCount: 8,
        likeCount: 23,
        createdBy: 'admin',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      MuralQuestion(
        id: '3',
        question: '¿Cómo crees que podemos preservar mejor nuestras tradiciones culturales?',
        description: 'Reflexiona sobre las formas de mantener vivas nuestras costumbres y tradiciones para las futuras generaciones.',
        category: 'reflexión',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        tags: ['tradición', 'preservación', 'futuro'],
        commentCount: 3,
        likeCount: 7,
        createdBy: 'admin',
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Obtener comentarios de ejemplo (mock data por ahora)
  static List<Comment> getSampleComments() {
    return [
      Comment(
        id: '1',
        text: '¡Excelente pregunta! Mi experiencia más memorable fue en Cusco, donde aprendí a tejer con lana de alpaca. Los artesanos son muy pacientes y generosos con su conocimiento.',
        userId: 'user1',
        userName: 'María González',
        userProfileImage: null,
        objectId: '1',
        likes: ['user2', 'user3'],
        dislikes: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Comment(
        id: '2',
        text: 'Para mí fue en Ayacucho, viendo cómo se hacen los retablos. Es increíble la paciencia y el detalle que ponen en cada pieza.',
        userId: 'user2',
        userName: 'Carlos Ruiz',
        userProfileImage: null,
        objectId: '1',
        likes: ['user1'],
        dislikes: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Comment(
        id: '3',
        text: 'Me encantaría visitar Chan Chan en Trujillo. La arquitectura de barro es fascinante y quiero aprender más sobre la cultura Chimú.',
        userId: 'user3',
        userName: 'Ana López',
        userProfileImage: null,
        objectId: '2',
        likes: ['user1', 'user2'],
        dislikes: [],
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }
}
