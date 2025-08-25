import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../config/api_config.dart';

class AuthService {
  // Claves para SharedPreferences
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';

  /// Registra un nuevo usuario
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.registerUrl),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));

      final responseData = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(responseData);

      if (response.statusCode == 200 && authResponse.success) {
        await _saveAuthData(authResponse);
      }

      return authResponse;
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  /// Inicia sesión con un usuario existente
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));

      final responseData = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(responseData);

      if (response.statusCode == 200 && authResponse.success) {
        await _saveAuthData(authResponse);
      }

      return authResponse;
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Error de conexión: ${e.toString()}',
      );
    }
  }

  /// Cierra la sesión del usuario
  Future<AuthResponse> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse(ApiConfig.logoutUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
      }
    } catch (e) {
      // Continuar con el logout local aunque falle el logout del servidor
    }

    await _clearAuthData();
    return AuthResponse(
      success: true,
      message: 'Sesión cerrada exitosamente',
    );
  }

  /// Verifica si el token es válido
  Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse(ApiConfig.verifyUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] ?? false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Refresca el token de acceso
  Future<AuthResponse> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return AuthResponse(
          success: false,
          message: 'No hay token de refresco disponible',
        );
      }

      final response = await http.post(
        Uri.parse(ApiConfig.refreshUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      ).timeout(const Duration(seconds: ApiConfig.timeoutSeconds));

      final responseData = jsonDecode(response.body);
      final authResponse = AuthResponse.fromJson(responseData);

      if (response.statusCode == 200 && authResponse.success) {
        await _saveAuthData(authResponse);
      }

      return authResponse;
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Error refrescando token: ${e.toString()}',
      );
    }
  }

  /// Obtiene el token de autenticación almacenado
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Obtiene el token de refresco almacenado
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Verifica si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;

    // Verificar si el token es válido
    return await verifyToken();
  }

  /// Obtiene la información del usuario almacenada
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString(_userIdKey);
    final email = prefs.getString(_userEmailKey);
    final displayName = prefs.getString(_userNameKey);
    final roleCode = prefs.getString(_userRoleKey);

    if (userId == null || email == null || displayName == null) {
      return null;
    }

    return User(
      userId: userId,
      email: email,
      displayName: displayName,
      role: UserRole.fromCode(roleCode ?? 'USER'),
      isActive: true,
    );
  }

  /// Guarda los datos de autenticación en SharedPreferences
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();

    if (authResponse.token != null) {
      await prefs.setString(_tokenKey, authResponse.token!);
    }

    if (authResponse.refreshToken != null) {
      await prefs.setString(_refreshTokenKey, authResponse.refreshToken!);
    }

    if (authResponse.userId != null) {
      await prefs.setString(_userIdKey, authResponse.userId!);
    }

    if (authResponse.email != null) {
      await prefs.setString(_userEmailKey, authResponse.email!);
    }

    if (authResponse.displayName != null) {
      await prefs.setString(_userNameKey, authResponse.displayName!);
    }

    // Intentar obtener el rol del usuario desde el backend después del login
    await _fetchAndSaveUserRole();
  }

  /// Limpia todos los datos de autenticación
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userRoleKey);
  }

  /// Obtiene el rol guardado (o null si aún no se ha elegido)
  Future<UserRole?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_userRoleKey);
    if (code == null) return null;
    return UserRole.fromCode(code);
  }

  /// Guarda el rol elegido localmente (y opcionalmente lo envía al backend)
  Future<void> setUserRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role.code);

    // Persistir en backend si hay token
    final token = await getToken();
    if (token != null) {
      try {
        await http
            .post(
              Uri.parse(
                  '${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/me/role'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({'role': role.code}),
            )
            .timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
      } catch (_) {
        // Ignorar errores de red para no bloquear la UX; el rol queda guardado localmente.
      }
    }
  }

  /// Obtiene headers con autenticación para API calls
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Obtiene el rol del usuario desde el backend
  Future<void> _fetchAndSaveUserRole() async {
    try {
      final token = await getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.usersEndpoint}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: ApiConfig.timeoutSeconds));

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final userRole = userData['role'];

        if (userRole != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userRoleKey, userRole);
        }
      }
    } catch (e) {
      // Fallar silenciosamente si no se puede obtener el rol
    }
  }
}
