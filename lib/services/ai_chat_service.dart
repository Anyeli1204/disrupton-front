import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/ai_chat_models.dart';
import '../models/collection_models.dart';

class AiChatService {
  static const String _geminiServicePort =
      '5001'; // Puerto del microservicio de Gemini

  // URL base para el microservicio de Gemini (directamente)
  static String get _geminiBaseUrl {
    final baseUrl = ApiConfig.baseUrl;
    if (baseUrl.contains('10.0.2.2')) {
      return 'http://10.0.2.2:$_geminiServicePort';
    } else if (baseUrl.contains('localhost')) {
      return 'http://localhost:$_geminiServicePort';
    } else {
      // Para dispositivos físicos, usar la misma IP base pero puerto 5001
      final ip = baseUrl.split('://')[1].split(':')[0];
      return 'http://$ip:$_geminiServicePort';
    }
  }

  /// Envía un mensaje al avatar de IA
  /// Usa directamente el microservicio de Gemini para mejor rendimiento
  static Future<AiChatResponse> sendMessage({
    required AvatarType avatarType,
    required String message,
    CulturalObject? contextObject,
  }) async {
    try {
      // Construir el mensaje con contexto del objeto cultural si está disponible
      String enhancedMessage = message;
      if (contextObject != null) {
        enhancedMessage = _buildMessageWithContext(message, contextObject);
      }

      final response = await http
          .post(
        Uri.parse('$_geminiBaseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'avatarType': avatarType.backendValue,
          'message': enhancedMessage,
        }),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: La respuesta del avatar tardó demasiado');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AiChatResponse.fromJson(jsonData);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al comunicarse con el avatar: $e');
    }
  }

  /// Construye un mensaje con contexto del objeto cultural
  static String _buildMessageWithContext(
      String userMessage, CulturalObject object) {
    final context = '''
Contexto del objeto cultural:
- Nombre: ${object.name}
- Descripción: ${object.description}
- Categoría: ${object.category}
- Departamento: ${object.departmentId}
${object.additionalInfo?.isNotEmpty == true ? '- Información adicional: ${object.additionalInfo}' : ''}

Pregunta del usuario: $userMessage
    ''';

    return context;
  }

  /// Verifica si el servicio de IA está disponible
  static Future<bool> isServiceHealthy() async {
    try {
      final response = await http.get(
        Uri.parse('$_geminiBaseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el avatar recomendado según el objeto cultural
  static AvatarType getRecommendedAvatar(CulturalObject object) {
    final category = object.category.toLowerCase();
    final description = object.description.toLowerCase();
    final department = object.departmentId.toLowerCase();

    // Lógica para recomendar avatar según el contexto
    if (department.contains('cusco') ||
        description.contains('inca') ||
        description.contains('quechua') ||
        category.contains('textil')) {
      return AvatarType.vicuna; // Vicuña para cultura andina
    }

    if (description.contains('preinca') ||
        description.contains('moche') ||
        description.contains('chavín') ||
        description.contains('nazca') ||
        category.contains('cerámica') ||
        category.contains('metalurgia')) {
      return AvatarType.peruvianDog; // Perro peruano para culturas preincaicas
    }

    if (description.contains('amazonia') ||
        description.contains('selva') ||
        description.contains('pluma') ||
        category.contains('ornamento') ||
        department.contains('loreto') ||
        department.contains('amazonas')) {
      return AvatarType.cockOfTheRock; // Gallito para biodiversidad amazónica
    }

    // Por defecto, vicuña
    return AvatarType.vicuna;
  }

  /// Obtiene preguntas sugeridas según el objeto y avatar
  static List<String> getSuggestedQuestions(
      AvatarType avatar, CulturalObject object) {
    final baseQuestions = AvatarConfig.sampleQuestions[avatar] ?? [];

    // Preguntas específicas según el objeto
    final specificQuestions = <String>[];

    switch (object.category.toLowerCase()) {
      case 'cerámica':
        specificQuestions.addAll([
          '¿Cómo se elaboraba esta cerámica?',
          '¿Qué simbolismo tiene este diseño?',
        ]);
        break;
      case 'textil':
        specificQuestions.addAll([
          '¿Qué técnica de tejido se usó?',
          '¿Qué significan estos colores y patrones?',
        ]);
        break;
      case 'metalurgia':
        specificQuestions.addAll([
          '¿Qué metales se utilizaron?',
          '¿Para qué se usaba este objeto?',
        ]);
        break;
      case 'escultura':
        specificQuestions.addAll([
          '¿Qué representa esta figura?',
          '¿Dónde se encontró originalmente?',
        ]);
        break;
      default:
        specificQuestions.addAll([
          '¿Cuál es la importancia histórica de este objeto?',
          '¿Cómo llegó a formar parte de esta colección?',
        ]);
    }

    // Combinar preguntas base con específicas (máximo 4)
    final combined = [...baseQuestions, ...specificQuestions];
    return combined.take(4).toList();
  }
}
