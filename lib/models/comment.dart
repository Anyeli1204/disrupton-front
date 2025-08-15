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
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      metadata: json['metadata'],
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
    );
  }

  // Métodos de utilidad
  bool get hasLikes => likes.isNotEmpty;
  bool get hasDislikes => dislikes.isNotEmpty;
  int get totalReactions => likes.length + dislikes.length;
  bool isLikedBy(String userId) => likes.contains(userId);
  bool isDislikedBy(String userId) => dislikes.isNotEmpty && dislikes.contains(userId);
}

