import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/comment.dart';
import '../models/mural_question.dart';
import '../models/user.dart';
import 'auth_service.dart';

class MuralService {
  static const String baseUrl = AppConfig.baseUrl;
  
  // Obtener comentarios del mural
  static Future<List<Comment>> getMuralComments() async {
    try {
      final activeQuestion = await getActiveMuralQuestion();
      if (activeQuestion == null) {
        // Si no hay pregunta activa, devolver una lista vacía o manejar como se prefiera
        return [];
      }

      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/mural/comentarios/${activeQuestion.id}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener comentarios: ${response.statusCode}');
      }
    } catch (e) {
      // Si hay error, usar datos de ejemplo
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

  // Crear comentario en el mural
  static Future<Comment?> createMuralComment(String text, String userId, Map<String, String> authHeaders, {String? questionId, User? user}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      }..addAll(authHeaders);

      final response = await http.post(
        Uri.parse('$baseUrl/api/mural/comentarios'), // Endpoint corregido
        headers: headers,
        body: json.encode({
          'text': text,
          'userId': userId,
          'preguntaId': questionId, // El backend espera 'preguntaId'
        }),
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
              createdAt: commentData['createdAt'] != null 
                  ? DateTime.parse(commentData['createdAt'].toString())
                  : DateTime.now(),
              likes: [],
              dislikes: [],
              isEdited: false,
            );
          } else {
            // Fallback si no hay commentData
            return Comment(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: text,
              userId: userId,
              userName: user?.name ?? 'Usuario',
              createdAt: DateTime.now(),
              likes: [],
              dislikes: [],
              isEdited: false,
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

  // Dar like a un comentario
  static Future<bool> likeComment(String commentId, String userId) async {
    try {
      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/mural/comments/$commentId/like'),
        headers: headers,
        body: json.encode({
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al dar like: $e');
    }
  }

  // Quitar like de un comentario
  static Future<bool> unlikeComment(String commentId, String userId) async {
    try {
      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/mural/comments/$commentId/like/$userId'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al quitar like: $e');
    }
  }

  // Dar dislike a un comentario
  static Future<bool> dislikeComment(String commentId, String userId) async {
    try {
      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/mural/comments/$commentId/dislike'),
        headers: headers,
        body: json.encode({
          'userId': userId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al dar dislike: $e');
    }
  }

  // Quitar dislike de un comentario
  static Future<bool> undislikeComment(String commentId, String userId) async {
    try {
      final authService = AuthService();
      final headers = authService.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/mural/comments/$commentId/dislike/$userId'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al quitar dislike: $e');
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
