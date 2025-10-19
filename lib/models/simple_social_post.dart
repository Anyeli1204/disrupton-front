/// Modelo simplificado de publicación social para la Red Cultural
class SimpleSocialPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final String imageUrl;
  final DateTime timestamp;
  int likes;
  final int comments;
  final int shares;
  bool isLiked;
  bool isSaved;
  final List<String> tags;

  SimpleSocialPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.content,
    required this.imageUrl,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.tags = const [],
  });

  SimpleSocialPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    String? imageUrl,
    DateTime? timestamp,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
    bool? isSaved,
    List<String>? tags,
  }) {
    return SimpleSocialPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      tags: tags ?? this.tags,
    );
  }
}
