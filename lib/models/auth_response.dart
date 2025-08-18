class AuthResponse {
  final String? token;
  final String? refreshToken;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? message;
  final bool success;

  AuthResponse({
    this.token,
    this.refreshToken,
    this.userId,
    this.email,
    this.displayName,
    this.message,
    required this.success,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      userId: json['userId'],
      email: json['email'],
      displayName: json['displayName'],
      message: json['message'],
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'message': message,
      'success': success,
    };
  }

  // Métodos estáticos para crear respuestas
  static AuthResponse createSuccess({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
    required String displayName,
  }) {
    return AuthResponse(
      token: token,
      refreshToken: refreshToken,
      userId: userId,
      email: email,
      displayName: displayName,
      success: true,
      message: 'Autenticación exitosa',
    );
  }

  static AuthResponse createError(String message) {
    return AuthResponse(
      success: false,
      message: message,
    );
  }

  // Método para verificar si la autenticación fue exitosa
  bool get isAuthenticated => success && token != null && userId != null;

  @override
  String toString() {
    return 'AuthResponse(success: $success, message: $message, userId: $userId)';
  }
}
