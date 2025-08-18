import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // Estado
  bool _isLoading = false;
  bool _isAuthenticated = false;
  User? _currentUser;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;
  String? get error => _error;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Constructor
  AuthProvider() {
    _initialize();
  }

  // Inicializar
  Future<void> _initialize() async {
    _setLoading(true);
    await _authService.initialize();
    
    _isAuthenticated = _authService.isAuthenticated;
    _currentUser = _authService.currentUser;
    _setLoading(false);
  }

  // Set loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _authService.login(email, password);
      
      if (response.success) {
        _isAuthenticated = true;
        _currentUser = _authService.currentUser;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Error de login');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  // Registro
  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await _authService.register(
        displayName: displayName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );
      
      if (response.success) {
        _isAuthenticated = true;
        _currentUser = _authService.currentUser;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Error de registro');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authService.logout();
      
      _isAuthenticated = false;
      _currentUser = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Error en logout: $e');
      _setLoading(false);
    }
  }

  // Verificar token
  Future<bool> verifyToken() async {
    try {
      final isValid = await _authService.verifyToken();
      if (!isValid) {
        // Token inválido, hacer logout
        await logout();
      }
      return isValid;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Refrescar token
  Future<bool> refreshToken() async {
    try {
      final response = await _authService.refreshToken();
      if (response.success) {
        _currentUser = _authService.currentUser;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Verificar si tiene un rol específico
  bool hasRole(String role) {
    if (_currentUser == null) return false;
    return _currentUser!.role == role || _currentUser!.role == 'ADMIN';
  }

  // Verificar si es moderador
  bool get isModerator => hasRole('MODERATOR');

  // Verificar si es guía
  bool get isGuide => hasRole('GUIDE');

  // Verificar si es artesano
  bool get isArtisan => hasRole('ARTISAN');

  // Verificar si es agente cultural
  bool get isCulturalAgent => hasRole('AGENTE_CULTURAL');

  // Verificar si es colaborador
  bool get isCollaborator => isGuide || isArtisan || isCulturalAgent;

  // Verificar si es premium
  bool get isPremium => hasRole('PREMIUM');

  // Obtener headers de autorización
  Map<String, String> getAuthHeaders() {
    return _authService.getAuthHeaders();
  }
}

