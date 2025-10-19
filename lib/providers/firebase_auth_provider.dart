import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/firebase_auth_service.dart';
import '../models/auth_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class FirebaseAuthProvider extends ChangeNotifier {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  AuthState _state = AuthState.initial;
  firebase_auth.User? _firebaseUser;
  String? _errorMessage;
  UserRole? _userRole;

  AuthState get state => _state;
  firebase_auth.User? get firebaseUser => _firebaseUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      _state == AuthState.authenticated && _firebaseUser != null;
  bool get isLoading => _state == AuthState.loading;
  UserRole? get userRole => _userRole;

  // Claves para SharedPreferences
  static const String _userRoleKey = 'user_role';

  /// Inicializa el provider y escucha cambios de autenticación
  Future<void> initialize() async {
    _setState(AuthState.loading);

    // Cargar rol guardado
    await _loadSavedRole();

    // Escuchar cambios en el estado de autenticación
    _firebaseAuthService.authStateChanges.listen((firebase_auth.User? user) {
      _firebaseUser = user;
      if (user != null) {
        _setState(AuthState.authenticated);
      } else {
        _setState(AuthState.unauthenticated);
      }
    });

    // Obtener usuario actual
    _firebaseUser = _firebaseAuthService.currentUser;
    if (_firebaseUser != null) {
      _setState(AuthState.authenticated);
    } else {
      _setState(AuthState.unauthenticated);
    }
  }

  /// Registra un nuevo usuario con email y contraseña
  Future<bool> registerWithEmailAndPassword({
    required String displayName,
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);

    try {
      final userCredential =
          await _firebaseAuthService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      _firebaseUser = userCredential.user;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Inicia sesión con email y contraseña
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setState(AuthState.loading);

    try {
      final userCredential =
          await _firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = userCredential.user;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Inicia sesión con Google
  Future<bool> signInWithGoogle() async {
    _setState(AuthState.loading);

    try {
      final userCredential = await _firebaseAuthService.signInWithGoogle();

      _firebaseUser = userCredential.user;
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    _setState(AuthState.loading);

    try {
      await _firebaseAuthService.signOut();
      _firebaseUser = null;
      _userRole = null;
      await _clearSavedRole();
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError('Error al cerrar sesión: ${e.toString()}');
    }
  }

  /// Envía un email de verificación
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuthService.sendEmailVerification();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Envía un email de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuthService.sendPasswordResetEmail(email);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Elimina la cuenta del usuario actual
  Future<void> deleteAccount() async {
    _setState(AuthState.loading);

    try {
      await _firebaseAuthService.deleteAccount();
      _firebaseUser = null;
      _userRole = null;
      await _clearSavedRole();
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError(e.toString());
      _setState(_firebaseUser != null
          ? AuthState.authenticated
          : AuthState.unauthenticated);
    }
  }

  /// Re-autentica con Google
  Future<void> reauthenticateWithGoogle() async {
    try {
      await _firebaseAuthService.reauthenticateWithGoogle();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  /// Re-autentica con email y contraseña
  Future<void> reauthenticateWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuthService.reauthenticateWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  /// Guarda el rol del usuario
  Future<void> setUserRole(UserRole role) async {
    _userRole = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role.code);
    notifyListeners();
  }

  /// Verifica si se necesita seleccionar un rol
  Future<bool> needsRoleSelection() async {
    return _userRole == null;
  }

  /// Carga el rol guardado desde SharedPreferences
  Future<void> _loadSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleCode = prefs.getString(_userRoleKey);
    if (roleCode != null) {
      _userRole = UserRole.fromCode(roleCode);
    }
  }

  /// Limpia el rol guardado
  Future<void> _clearSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userRoleKey);
  }

  /// Obtiene el token de ID del usuario actual
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _firebaseAuthService.getIdToken(forceRefresh: forceRefresh);
  }

  /// Obtiene headers de autenticación con el token de Firebase
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getIdToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
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

  /// Getter para compatibilidad con el código existente
  User? get currentUser {
    if (_firebaseUser == null) return null;

    return User(
      userId: _firebaseUser!.uid,
      email: _firebaseUser!.email ?? '',
      displayName: _firebaseUser!.displayName ?? 'Usuario',
      role: _userRole ?? UserRole.user,
      isActive: true,
    );
  }

  /// Getter para compatibilidad con LoginScreen
  bool get hasChosenRole => _userRole != null;

  /// Método de compatibilidad para login (wrapper)
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return await signInWithEmailAndPassword(email: email, password: password);
  }

  /// Método de compatibilidad para register (wrapper)
  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    return await registerWithEmailAndPassword(
      displayName: displayName,
      email: email,
      password: password,
    );
  }

  /// Método de compatibilidad para logout (wrapper)
  Future<void> logout() async {
    await signOut();
  }

  /// Método de compatibilidad para getSavedRole
  Future<UserRole?> getSavedRole() async {
    if (_userRole != null) return _userRole;
    await _loadSavedRole();
    return _userRole;
  }

  /// Obtiene headers con autenticación de forma asíncrona (desde Firebase)
  Future<Map<String, String>> getAuthHeadersAsync() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_firebaseUser != null) {
      try {
        final idToken = await _firebaseUser!.getIdToken();
        if (idToken != null && idToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $idToken';
        }
      } catch (e) {
        // Si hay error obteniendo el token, continuar sin auth
        print('Error obteniendo ID token: $e');
      }
    }

    return headers;
  }
}
