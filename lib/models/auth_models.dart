class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String displayName;
  final String email;
  final String password;
  final String? phoneNumber;

  RegisterRequest({
    required this.displayName,
    required this.email,
    required this.password,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'displayName': displayName,
      'email': email,
      'password': password,
    };

    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      data['phoneNumber'] = phoneNumber;
    }

    return data;
  }
}

class AuthResponse {
  final String? token;
  final String? refreshToken;
  final String? userId;
  final String? email;
  final String? displayName;
  final String message;
  final bool success;

  AuthResponse({
    this.token,
    this.refreshToken,
    this.userId,
    this.email,
    this.displayName,
    required this.message,
    required this.success,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      userId: json['userId'],
      email: json['email'],
      displayName: json['displayName'],
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }
}

enum UserRole {
  user('USER', 'Usuario regular'),
  admin('ADMIN', 'Administrador del sistema'),
  moderator('MODERATOR', 'Moderador de contenido'),
  guide('GUIDE', 'Guía turístico'),
  artisan('ARTISAN', 'Artesano'),
  premium('PREMIUM', 'Usuario premium');

  const UserRole(this.code, this.description);

  final String code;
  final String description;

  static UserRole fromCode(String code) {
    return UserRole.values.firstWhere(
      (role) => role.code == code,
      orElse: () => UserRole.user,
    );
  }

  static List<UserRole> get selectableRoles => [
        UserRole.user,
        UserRole.guide,
        UserRole.artisan,
      ];
}

class User {
  final String userId;
  final String email;
  final String displayName;
  final UserRole role;
  final bool isActive;

  User({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: UserRole.fromCode(json['role'] ?? 'USER'),
      isActive: json['isActive'] ?? true,
    );
  }
}
