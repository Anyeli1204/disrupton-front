import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  User? _currentUser;
  String? _errorMessage;

  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  /// Inicializa el provider verificando si hay una sesión activa
  Future<void> initialize() async {
    _setState(AuthState.loading);

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _currentUser = await _authService.getCurrentUser();
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('Error inicializando autenticación: ${e.toString()}');
    }
  }

  /// Registra un nuevo usuario
  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    _setState(AuthState.loading);

    try {
      final request = RegisterRequest(
        displayName: displayName,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
      );

      final response = await _authService.register(request);

      if (response.success) {
        final savedRole = await _authService.getSavedRole();
        _currentUser = User(
          userId: response.userId!,
          email: response.email!,
          displayName: response.displayName!,
          role: savedRole ?? UserRole.user,
          isActive: true,
        );
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Error durante el registro: ${e.toString()}');
      return false;
    }
  }

  /// Inicia sesión con email y contraseña
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);

    try {
      final request = LoginRequest(
        email: email,
        password: password,
      );

      final response = await _authService.login(request);

      if (response.success) {
        final savedRole = await _authService.getSavedRole();
        _currentUser = User(
          userId: response.userId!,
          email: response.email!,
          displayName: response.displayName!,
          role: savedRole ?? UserRole.user,
          isActive: true,
        );
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Error durante el login: ${e.toString()}');
      return false;
    }
  }

  // Roles
  Future<void> setUserRole(UserRole role) async {
    await _authService.setUserRole(role);
    if (_currentUser != null) {
      _currentUser = User(
        userId: _currentUser!.userId,
        email: _currentUser!.email,
        displayName: _currentUser!.displayName,
        role: role,
        isActive: _currentUser!.isActive,
      );
      notifyListeners();
    }
  }

  bool get hasChosenRole => _currentUser?.role != null;

  Future<bool> needsRoleSelection() async {
    final role = await _authService.getSavedRole();
    return role == null;
  }

  Future<UserRole?> getSavedRole() async {
    return _authService.getSavedRole();
  }

  /// Cierra la sesión del usuario
  Future<void> logout() async {
    _setState(AuthState.loading);

    try {
      await _authService.logout();
      _currentUser = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Error durante el logout: ${e.toString()}');
    }
  }

  /// Refresca el token de autenticación
  Future<bool> refreshToken() async {
    try {
      final response = await _authService.refreshToken();
      return response.success;
    } catch (e) {
      _setError('Error refrescando token: ${e.toString()}');
      return false;
    }
  }

  /// Limpia los errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Actualiza el estado y notifica a los listeners
  void _setState(AuthState newState) {
    _state = newState;
    if (newState != AuthState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  /// Establece un error y actualiza el estado
  void _setError(String error) {
    _errorMessage = error;
    _state = AuthState.error;
    notifyListeners();
  }
}
