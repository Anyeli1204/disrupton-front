// Tipo de avatar de IA
enum AvatarType {
  vicuna('VICUNA', '🦙', 'Vicuña'),
  peruvianDog('PERUVIAN_DOG', '🐕', 'Perro Peruano'),
  cockOfTheRock('COCK_OF_THE_ROCK', '🐦', 'Gallito de las Rocas');

  const AvatarType(this.backendValue, this.emoji, this.displayName);

  final String backendValue;
  final String emoji;
  final String displayName;

  static AvatarType fromString(String value) {
    return AvatarType.values.firstWhere(
      (type) => type.backendValue == value,
      orElse: () => AvatarType.vicuna,
    );
  }
}

// Mensaje del chat
class ChatMessage {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime timestamp;
  final AvatarType? avatarType;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.timestamp,
    this.avatarType,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isFromUser,
    DateTime? timestamp,
    AvatarType? avatarType,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isFromUser: isFromUser ?? this.isFromUser,
      timestamp: timestamp ?? this.timestamp,
      avatarType: avatarType ?? this.avatarType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.content == content &&
        other.isFromUser == isFromUser &&
        other.timestamp == timestamp &&
        other.avatarType == avatarType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        content.hashCode ^
        isFromUser.hashCode ^
        timestamp.hashCode ^
        avatarType.hashCode;
  }
}

// Estado del chat
enum ChatState {
  idle,
  loading,
  error,
}

// Modelo para la respuesta de la IA
class AiChatResponse {
  final bool success;
  final String? response;
  final String? error;
  final AvatarType avatarType;
  final String userMessage;
  final DateTime timestamp;
  final String model;

  const AiChatResponse({
    required this.success,
    this.response,
    this.error,
    required this.avatarType,
    required this.userMessage,
    required this.timestamp,
    required this.model,
  });

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      success: json['success'] ?? false,
      response: json['response'],
      error: json['error'],
      avatarType: AvatarType.fromString(json['avatarType'] ?? 'VICUNA'),
      userMessage: json['userMessage'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      model: json['model'] ?? 'gemini-1.5-flash',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AiChatResponse &&
        other.success == success &&
        other.response == response &&
        other.error == error &&
        other.avatarType == avatarType &&
        other.userMessage == userMessage &&
        other.timestamp == timestamp &&
        other.model == model;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        response.hashCode ^
        error.hashCode ^
        avatarType.hashCode ^
        userMessage.hashCode ^
        timestamp.hashCode ^
        model.hashCode;
  }
}

// Configuración del avatar
class AvatarConfig {
  static const Map<AvatarType, String> descriptions = {
    AvatarType.vicuna:
        'Soy una vicuña de los Andes peruanos. Te ayudo con información sobre nuestra rica cultura.',
    AvatarType.peruvianDog:
        'Soy un perro peruano sin pelo, guardián ancestral. Conozco las tradiciones de mi tierra.',
    AvatarType.cockOfTheRock:
        'Soy el gallito de las rocas, ave nacional del Perú. Te cuento sobre nuestra biodiversidad.',
  };

  static const Map<AvatarType, List<String>> sampleQuestions = {
    AvatarType.vicuna: [
      '¿Qué puedes contarme sobre este objeto?',
      '¿De qué época es esta pieza?',
      '¿Qué simboliza este objeto cultural?',
    ],
    AvatarType.peruvianDog: [
      '¿Cómo se usaba este objeto antiguamente?',
      '¿Qué técnicas se usaron para crearlo?',
      '¿Qué representa en la cultura peruana?',
    ],
    AvatarType.cockOfTheRock: [
      '¿Hay otros objetos similares en el Perú?',
      '¿Qué materiales se usaron?',
      '¿Dónde se puede ver algo parecido?',
    ],
  };
}
