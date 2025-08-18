import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

class AuthService {
  static const String baseUrl = AppConfig.baseUrl;
  
  // Claves para SharedPreferences
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Estado de autenticación
  bool _isAuthenticated = false;
  User? _currentUser;
  String? _currentToken;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get currentToken => _currentToken;

  // Inicializar el servicio
  Future<void> initialize() async {
    await _loadStoredAuth();
  }

  // Cargar autenticación almacenada
  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userId = prefs.getString(_userIdKey);
      final email = prefs.getString(_userEmailKey);
      final name = prefs.getString(_userNameKey);
      final role = prefs.getString(_userRoleKey);

      if (token != null && userId != null) {
        _currentToken = token;
        _currentUser = User(
          userId: userId,
          email: email ?? '',
          name: name ?? '',
          role: role ?? 'USER',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _isAuthenticated = true;
      }
    } catch (e) {
      developer.log('Error cargando autenticación: $e');
    }
  }

  // Guardar autenticación
  Future<void> _saveAuth(AuthResponse response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, response.token!);
      await prefs.setString(_refreshTokenKey, response.refreshToken!);
      await prefs.setString(_userIdKey, response.userId!);
      await prefs.setString(_userEmailKey, response.email!);
      await prefs.setString(_userNameKey, response.displayName!);
      
      // Actualizar estado
      _currentToken = response.token;
      _currentUser = User(
        userId: response.userId!,
        email: response.email!,
        name: response.displayName!,
        role: 'USER', // Por defecto, se puede actualizar después
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _isAuthenticated = true;
    } catch (e) {
      developer.log('Error guardando autenticación: $e');
    }
  }

  // Limpiar autenticación
  Future<void> _clearAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userRoleKey);
      
      // Limpiar estado
      _currentToken = null;
      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      developer.log('Error limpiando autenticación: $e');
    }
  }

  // Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      developer.log('Intentando login con: $email');
      developer.log('URL: $baseUrl/api/auth/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      developer.log('Respuesta del servidor: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        if (authResponse.success) {
          await _saveAuth(authResponse);
        }
        return authResponse;
      } else {
        final errorBody = json.decode(response.body);
        return AuthResponse.createError(errorBody['message'] ?? 'Error de login');
      }
    } catch (e) {
      return AuthResponse.createError('Error de conexión: $e');
    }
  }

  // Registro
  Future<AuthResponse> register({
    required String displayName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      developer.log('Intentando registro con: $displayName, $email');
      developer.log('URL: $baseUrl/api/auth/register');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'displayName': displayName,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
        }),
      );
      
      developer.log('Respuesta del servidor: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        if (authResponse.success) {
          await _saveAuth(authResponse);
        }
        return authResponse;
      } else {
        final errorBody = json.decode(response.body);
        return AuthResponse.createError(errorBody['message'] ?? 'Error de registro');
      }
    } catch (e) {
      return AuthResponse.createError('Error de conexión: $e');
    }
  }

  // Logout
  Future<AuthResponse> logout() async {
    try {
      if (_currentToken != null) {
        // Intentar logout en el backend
        await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: {
            'Authorization': 'Bearer $_currentToken',
            'Content-Type': 'application/json',
          },
        );
      }
      
      // Limpiar localmente
      await _clearAuth();
      return AuthResponse(success: true, message: 'Logout exitoso');
    } catch (e) {
      // Aún así limpiar localmente
      await _clearAuth();
      return AuthResponse(success: true, message: 'Logout exitoso');
    }
  }

  // Verificar token
  Future<bool> verifyToken() async {
    try {
      if (_currentToken == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/verify'),
        headers: {
          'Authorization': 'Bearer $_currentToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Refrescar token
  Future<AuthResponse> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null) {
        return AuthResponse.createError('No hay token de refresco');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $refreshToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        if (authResponse.success) {
          await _saveAuth(authResponse);
        }
        return authResponse;
      } else {
        return AuthResponse.createError('Error refrescando token');
      }
    } catch (e) {
      return AuthResponse.createError('Error de conexión: $e');
    }
  }

  // Obtener headers de autorización
  Map<String, String> getAuthHeaders() {
    if (_currentToken != null) {
      return {
        'Authorization': 'Bearer $_currentToken',
        'Content-Type': 'application/json',
      };
    }
    return {'Content-Type': 'application/json'};
  }

  // Verificar si el usuario tiene un rol específico
  bool hasRole(String role) {
    if (_currentUser == null) return false;
    return _currentUser!.role == role || _currentUser!.role == 'ADMIN';
  }

  // Verificar si es admin
  bool get isAdmin => hasRole('ADMIN');
}
