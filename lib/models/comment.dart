class Comment {
  final String id;
  final String text;
  final String userId;
  final String? userName;
  final String? userProfileImage;
  final String? objectId; // ID del objeto cultural o pregunta del mural
  final String? parentCommentId; // Para respuestas anidadas
  final List<String> likes;
  final List<String> dislikes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEdited;
  final bool isDeleted;
  final Map<String, dynamic>? metadata;
  final List<String> imageUrls; // URLs de las imágenes adjuntas
  final int likeCount; // Contador de likes del backend
  final int dislikeCount; // Contador de dislikes del backend
  final String? userReaction; // Reacción del usuario actual: 'like', 'dislike', null

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    this.userName,
    this.userProfileImage,
    this.objectId,
    this.parentCommentId,
    this.likes = const [],
    this.dislikes = const [],
    required this.createdAt,
    this.updatedAt,
    this.isEdited = false,
    this.isDeleted = false,
    this.metadata,
    this.imageUrls = const [],
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.userReaction,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      userId: json['userId'] ?? json['createdBy'] ?? '',
      userName: json['userName'],
      userProfileImage: json['userProfileImage'],
      objectId: json['objectId'],
      parentCommentId: json['parentCommentId'],
      likes: json['likes'] != null 
          ? List<String>.from(json['likes'])
          : [],
      dislikes: json['dislikes'] != null 
          ? List<String>.from(json['dislikes'])
          : [],
      createdAt: json['createdAt'] != null 
          ? _parseFirestoreTimestamp(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? _parseFirestoreTimestamp(json['updatedAt'])
          : null,
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      metadata: json['metadata'],
      imageUrls: (() {
        // Soportar distintos nombres de campo provenientes del backend
        final dynamic v = json['imageUrls'] ?? json['imagenes'] ?? json['downloadUrls'];
        if (v is List) {
          return List<String>.from(v);
        }
        if (v is String) {
          // Permitir string separado por comas
          return v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
        return <String>[];
      })(),
      likeCount: json['likeCount'] ?? 0,
      dislikeCount: json['dislikeCount'] ?? 0,
      userReaction: json['userReaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'objectId': objectId,
      'parentCommentId': parentCommentId,
      'likes': likes,
      'dislikes': dislikes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'metadata': metadata,
      'imageUrls': imageUrls,
    };
  }

  Comment copyWith({
    String? id,
    String? text,
    String? userId,
    String? userName,
    String? userProfileImage,
    String? objectId,
    String? parentCommentId,
    List<String>? likes,
    List<String>? dislikes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    bool? isDeleted,
    Map<String, dynamic>? metadata,
    List<String>? imageUrls,
    int? likeCount,
    int? dislikeCount,
    String? userReaction,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      objectId: objectId ?? this.objectId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      metadata: metadata ?? this.metadata,
      imageUrls: imageUrls ?? this.imageUrls,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      userReaction: userReaction ?? this.userReaction,
    );
  }

  // Helper method para parsear Firestore Timestamp
  static DateTime _parseFirestoreTimestamp(dynamic timestamp) {
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

  // Métodos de utilidad
  bool get hasLikes => likes.isNotEmpty;
  bool get hasDislikes => dislikes.isNotEmpty;
  int get totalReactions => likes.length + dislikes.length;
  bool isLikedBy(String userId) => likes.contains(userId);
  bool isDislikedBy(String userId) => dislikes.isNotEmpty && dislikes.contains(userId);
}
