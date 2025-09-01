import 'package:flutter/material.dart';
import '../models/ai_chat_models.dart';
import '../models/collection_models.dart';
import '../services/ai_chat_service.dart';

/// Ejemplo de cómo probar la funcionalidad del avatar de IA
/// Este archivo muestra diferentes formas de usar los componentes
class AiAvatarExample {
  /// Ejemplo 1: Obtener avatar recomendado para un objeto
  static void exampleGetRecommendedAvatar() {
    // Objeto de ejemplo - cerámica Moche
    final culturalObject = CulturalObject(
      id: 'moche_ceramic_1',
      name: 'Huaco Retrato Moche',
      description:
          'Cerámica ceremonial de la cultura Moche (100-800 d.C.) que representa un rostro humano con gran realismo.',
      category: 'Cerámica',
      imageUrl: 'https://example.com/moche_ceramic.jpg',
      departmentId: 'la_libertad',
      createdAt: DateTime.now(),
      additionalInfo: {
        'periodo': '100-800 d.C.',
        'tecnica': 'Moldeado y pintado',
        'funcion': 'Ceremonial',
      },
    );

    // El servicio recomendará automáticamente el Perro Peruano
    // porque es cerámica preincaica
    final recommendedAvatar =
        AiChatService.getRecommendedAvatar(culturalObject);

    print('Avatar recomendado: ${recommendedAvatar.displayName}');
    print('Emoji: ${recommendedAvatar.emoji}');
    print('Descripción: ${AvatarConfig.descriptions[recommendedAvatar]}');
  }

  /// Ejemplo 2: Obtener preguntas sugeridas
  static void exampleGetSuggestedQuestions() {
    final culturalObject = CulturalObject(
      id: 'inca_textile_1',
      name: 'Quipu Inca',
      description: 'Sistema de registro contable y narrativo del Imperio Inca.',
      category: 'Textil',
      imageUrl: 'https://example.com/quipu.jpg',
      departmentId: 'cusco',
      createdAt: DateTime.now(),
    );

    final avatar = AvatarType.vicuna; // Para cultura inca
    final questions =
        AiChatService.getSuggestedQuestions(avatar, culturalObject);

    print('Preguntas sugeridas para ${culturalObject.name}:');
    for (int i = 0; i < questions.length; i++) {
      print('${i + 1}. ${questions[i]}');
    }
  }

  /// Ejemplo 3: Simular envío de mensaje (requiere backend activo)
  static Future<void> exampleSendMessage() async {
    final culturalObject = CulturalObject(
      id: 'chavin_stone_1',
      name: 'Obelisco Tello',
      description:
          'Monolito de la cultura Chavín con complejas representaciones simbólicas.',
      category: 'Escultura',
      imageUrl: 'https://example.com/obelisco_tello.jpg',
      departmentId: 'ancash',
      createdAt: DateTime.now(),
    );

    try {
      // Verificar si el servicio está disponible
      final isHealthy = await AiChatService.isServiceHealthy();
      print('Servicio de IA saludable: $isHealthy');

      if (isHealthy) {
        // Enviar mensaje de ejemplo
        final response = await AiChatService.sendMessage(
          avatarType: AvatarType.peruvianDog,
          message: '¿Qué puedes contarme sobre este obelisco?',
          contextObject: culturalObject,
        );

        if (response.success && response.response != null) {
          print('Respuesta del avatar: ${response.response}');
          print('Modelo usado: ${response.model}');
        } else {
          print('Error: ${response.error}');
        }
      }
    } catch (e) {
      print('Error al comunicarse con el avatar: $e');
    }
  }

  /// Ejemplo 4: Crear mensaje de chat
  static ChatMessage exampleCreateChatMessage() {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '¡Hola! Soy una vicuña de los Andes y estoy aquí para ayudarte.',
      isFromUser: false,
      timestamp: DateTime.now(),
      avatarType: AvatarType.vicuna,
    );
  }

  /// Ejemplo 5: Diferentes tipos de objetos y sus avatares recomendados
  static void exampleAvatarRecommendations() {
    final examples = [
      // Objeto andino -> Vicuña
      CulturalObject(
        id: 'inca_1',
        name: 'Kero Inca',
        description:
            'Vaso ceremonial del Imperio Inca decorado con motivos geométricos.',
        category: 'Cerámica',
        imageUrl: 'example.jpg',
        departmentId: 'cusco',
        createdAt: DateTime.now(),
      ),

      // Objeto preincaico -> Perro Peruano
      CulturalObject(
        id: 'nazca_1',
        name: 'Líneas de Nazca',
        description: 'Geoglifo de la cultura Nazca que representa un colibrí.',
        category: 'Geoglifo',
        imageUrl: 'example.jpg',
        departmentId: 'ica',
        createdAt: DateTime.now(),
      ),

      // Objeto amazónico -> Gallito de las Rocas
      CulturalObject(
        id: 'amazon_1',
        name: 'Corona de Plumas',
        description:
            'Ornamento ceremonial amazónico elaborado con plumas de aves tropicales.',
        category: 'Ornamento',
        imageUrl: 'example.jpg',
        departmentId: 'loreto',
        createdAt: DateTime.now(),
      ),
    ];

    print('Recomendaciones de avatares:');
    for (final obj in examples) {
      final avatar = AiChatService.getRecommendedAvatar(obj);
      print('${obj.name} -> ${avatar.displayName} ${avatar.emoji}');
    }
  }

  /// Función principal para ejecutar todos los ejemplos
  static Future<void> runAllExamples() async {
    print('=== EJEMPLOS DEL AVATAR DE IA ===\n');

    print('1. Avatar recomendado:');
    exampleGetRecommendedAvatar();
    print('');

    print('2. Preguntas sugeridas:');
    exampleGetSuggestedQuestions();
    print('');

    print('3. Recomendaciones por tipo:');
    exampleAvatarRecommendations();
    print('');

    print('4. Mensaje de chat:');
    final message = exampleCreateChatMessage();
    print('Contenido: ${message.content}');
    print('Timestamp: ${message.timestamp}');
    print('Avatar: ${message.avatarType?.displayName}');
    print('');

    print('5. Comunicación con backend:');
    await exampleSendMessage();
  }
}

/// Widget de prueba para mostrar la funcionalidad en la app
class AiAvatarTestScreen extends StatefulWidget {
  const AiAvatarTestScreen({super.key});

  @override
  State<AiAvatarTestScreen> createState() => _AiAvatarTestScreenState();
}

class _AiAvatarTestScreenState extends State<AiAvatarTestScreen> {
  bool _isServiceHealthy = false;
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _checkService();
  }

  void _checkService() async {
    final isHealthy = await AiChatService.isServiceHealthy();
    setState(() {
      _isServiceHealthy = isHealthy;
    });
  }

  void _runTest() async {
    setState(() {
      _testResult = 'Ejecutando prueba...';
    });

    try {
      await AiAvatarExample.runAllExamples();
      setState(() {
        _testResult =
            'Prueba completada exitosamente! Revisa la consola para ver los resultados.';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error en la prueba: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba del Avatar de IA'),
        backgroundColor: Colors.deepPurple.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado del servicio
            Card(
              color:
                  _isServiceHealthy ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isServiceHealthy ? Icons.check_circle : Icons.error,
                      color: _isServiceHealthy ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isServiceHealthy
                            ? 'Servicio de IA disponible'
                            : 'Servicio de IA no disponible',
                        style: TextStyle(
                          color: _isServiceHealthy
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _checkService,
                      child: const Text('Verificar'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Avatares disponibles
            const Text(
              'Avatares Disponibles:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...AvatarType.values.map((avatar) => Card(
                  child: ListTile(
                    leading: Text(avatar.emoji,
                        style: const TextStyle(fontSize: 24)),
                    title: Text(avatar.displayName),
                    subtitle: Text(AvatarConfig.descriptions[avatar] ?? ''),
                  ),
                )),

            const SizedBox(height: 16),

            // Botón de prueba
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _runTest,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Ejecutar Prueba'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Resultado
            if (_testResult.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resultado:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_testResult),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
