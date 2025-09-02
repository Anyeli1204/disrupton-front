class User {
  final String userId;
  final String email;
  final String name;
  final String role;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    this.profileImageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['displayName'] ?? '',
      role: json['role'] ?? 'USER',
      profileImageUrl: json['profileImageUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? userId,
    String? email,
    String? name,
    String? role,
    String? profileImageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Métodos de utilidad para roles
  bool get isAdmin => role == 'ADMIN';
  bool get isModerator => role == 'MODERATOR' || role == 'ADMIN';
  bool get isGuide => role == 'GUIDE' || role == 'ADMIN';
  bool get isArtisan => role == 'ARTISAN' || role == 'ADMIN';
  bool get isCulturalAgent => role == 'AGENTE_CULTURAL' || role == 'ADMIN';
  bool get isCollaborator => isGuide || isArtisan || isCulturalAgent;
  bool get isPremium => role == 'PREMIUM' || role == 'ADMIN';

  @override
  String toString() {
    return 'User(userId: $userId, email: $email, name: $name, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

