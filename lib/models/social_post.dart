// Modelo de Publicación de Red Social Cultural
class SocialPost {
  final String id;
  final String userId;
  final String userName;
  final String? userProfileImage;
  final String? userRole; // 'artesano', 'guia', 'usuario', etc.

  // Contenido principal
  final List<String> imageUrls; // Múltiples imágenes (obligatorio al menos 1)
  final String description; // Descripción/pie de foto

  // Ubicación
  final String? location;
  final String? department;
  final double? latitude;
  final double? longitude;

  // Etiquetas y referencias
  final List<String> tags; // Tags libres
  final List<String> mentionedUsers; // @usuarios mencionados
  final List<String> mentionedProducts; // Productos etiquetados
  final List<String> mentionedEvents; // Eventos etiquetados
  final List<String> mentionedCulturalObjects; // Objetos culturales etiquetados

  // Interacciones
  final List<String> likes;
  final int likeCount;
  final int commentCount;
  final List<String> saves; // Usuarios que guardaron
  final int shareCount;

  // Metadatos
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;
  final bool isDeleted;
  final bool isModerated;
  final String status; // 'published', 'pending', 'rejected', 'draft'

  // Configuración de privacidad
  final String visibility; // 'public', 'followers', 'private'
  final bool allowComments;
  final bool allowSharing;

  const SocialPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userProfileImage,
    this.userRole,
    required this.imageUrls,
    required this.description,
    this.location,
    this.department,
    this.latitude,
    this.longitude,
    this.tags = const [],
    this.mentionedUsers = const [],
    this.mentionedProducts = const [],
    this.mentionedEvents = const [],
    this.mentionedCulturalObjects = const [],
    this.likes = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.saves = const [],
    this.shareCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.isEdited = false,
    this.isDeleted = false,
    this.isModerated = false,
    this.status = 'published',
    this.visibility = 'public',
    this.allowComments = true,
    this.allowSharing = true,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    // Extraer URLs de imágenes del formato del backend
    List<String> extractImageUrls(dynamic images) {
      if (images == null) return [];

      if (images is List) {
        return images
            .map((img) {
              if (img is Map<String, dynamic> && img.containsKey('imageUrl')) {
                return img['imageUrl'] as String;
              } else if (img is String) {
                return img;
              }
              return '';
            })
            .where((url) => url.isNotEmpty)
            .toList();
      }

      return [];
    }

    return SocialPost(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userProfileImage: json['userProfileImageUrl'] ?? json['userProfileImage'],
      userRole: json['userRole'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : extractImageUrls(json['images']),
      description: json['description'] ?? '',
      location: json['location'],
      department: json['department'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      mentionedUsers: List<String>.from(json['mentionedUsers'] ?? []),
      mentionedProducts: List<String>.from(json['mentionedProducts'] ?? []),
      mentionedEvents: List<String>.from(json['mentionedEvents'] ?? []),
      mentionedCulturalObjects:
          List<String>.from(json['mentionedCulturalObjects'] ?? []),
      likes: List<String>.from(json['likes'] ?? []),
      likeCount: json['likeCount'] ?? json['likesCount'] ?? 0,
      commentCount: json['commentCount'] ?? json['commentsCount'] ?? 0,
      saves: List<String>.from(json['saves'] ?? []),
      shareCount: json['shareCount'] ?? json['sharesCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? _parseDateTime(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? _parseDateTime(json['updatedAt']) : null,
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      isModerated: json['isModerated'] ?? false,
      status: json['status'] ?? 'published',
      visibility: json['visibility'] ?? 'public',
      allowComments: json['allowComments'] ?? true,
      allowSharing: json['allowSharing'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'userRole': userRole,
      'imageUrls': imageUrls,
      'description': description,
      'location': location,
      'department': department,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags,
      'mentionedUsers': mentionedUsers,
      'mentionedProducts': mentionedProducts,
      'mentionedEvents': mentionedEvents,
      'mentionedCulturalObjects': mentionedCulturalObjects,
      'likes': likes,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'saves': saves,
      'shareCount': shareCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'isModerated': isModerated,
      'status': status,
      'visibility': visibility,
      'allowComments': allowComments,
      'allowSharing': allowSharing,
    };
  }

  // Métodos de utilidad
  bool get hasLocation => location != null && location!.isNotEmpty;
  bool get hasCoordinates => latitude != null && longitude != null;
  bool get hasTags => tags.isNotEmpty;
  bool get hasMentions =>
      mentionedUsers.isNotEmpty ||
      mentionedProducts.isNotEmpty ||
      mentionedEvents.isNotEmpty ||
      mentionedCulturalObjects.isNotEmpty;
  bool isLikedBy(String userId) => likes.contains(userId);
  bool isSavedBy(String userId) => saves.contains(userId);

  String get formattedLocation {
    if (department != null && location != null) {
      return '$location, $department';
    }
    return location ?? '';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes}min';
    } else {
      return 'ahora';
    }
  }

  // Helper para parsear fechas
  static DateTime _parseDateTime(dynamic timestamp) {
    if (timestamp is String) {
      return DateTime.parse(timestamp);
    }
    if (timestamp is Map && timestamp.containsKey('_seconds')) {
      final seconds = timestamp['_seconds'] as int;
      return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    }
    return DateTime.now();
  }

  // Copiar con modificaciones
  SocialPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? userRole,
    List<String>? imageUrls,
    String? description,
    String? location,
    String? department,
    double? latitude,
    double? longitude,
    List<String>? tags,
    List<String>? mentionedUsers,
    List<String>? mentionedProducts,
    List<String>? mentionedEvents,
    List<String>? mentionedCulturalObjects,
    List<String>? likes,
    int? likeCount,
    int? commentCount,
    List<String>? saves,
    int? shareCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    bool? isDeleted,
    bool? isModerated,
    String? status,
    String? visibility,
    bool? allowComments,
    bool? allowSharing,
  }) {
    return SocialPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      userRole: userRole ?? this.userRole,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      location: location ?? this.location,
      department: department ?? this.department,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      tags: tags ?? this.tags,
      mentionedUsers: mentionedUsers ?? this.mentionedUsers,
      mentionedProducts: mentionedProducts ?? this.mentionedProducts,
      mentionedEvents: mentionedEvents ?? this.mentionedEvents,
      mentionedCulturalObjects:
          mentionedCulturalObjects ?? this.mentionedCulturalObjects,
      likes: likes ?? this.likes,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      saves: saves ?? this.saves,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      isModerated: isModerated ?? this.isModerated,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      allowComments: allowComments ?? this.allowComments,
      allowSharing: allowSharing ?? this.allowSharing,
    );
  }
}

// Modelo para crear un nuevo post
class CreatePostRequest {
  final List<String> imageUrls; // URLs de imágenes ya subidas
  final String description;
  final String? location;
  final String? department;
  final double? latitude;
  final double? longitude;
  final List<String> tags;
  final List<String> mentionedUsers;
  final List<String> mentionedProducts;
  final List<String> mentionedEvents;
  final List<String> mentionedCulturalObjects;
  final String visibility;
  final bool allowComments;
  final bool allowSharing;

  const CreatePostRequest({
    required this.imageUrls,
    required this.description,
    this.location,
    this.department,
    this.latitude,
    this.longitude,
    this.tags = const [],
    this.mentionedUsers = const [],
    this.mentionedProducts = const [],
    this.mentionedEvents = const [],
    this.mentionedCulturalObjects = const [],
    this.visibility = 'public',
    this.allowComments = true,
    this.allowSharing = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'imageUrls': imageUrls,
      'description': description,
      'location': location,
      'department': department,
      'latitude': latitude,
      'longitude': longitude,
      'tags': tags,
      'mentionedUsers': mentionedUsers,
      'mentionedProducts': mentionedProducts,
      'mentionedEvents': mentionedEvents,
      'mentionedCulturalObjects': mentionedCulturalObjects,
      'visibility': visibility,
      'allowComments': allowComments,
      'allowSharing': allowSharing,
    };
  }
}
