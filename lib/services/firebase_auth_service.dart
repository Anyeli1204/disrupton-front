import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  // Configuración de Google Sign-In
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Stream del estado de autenticación
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  /// Usuario actual
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  /// Verifica si el usuario está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Registra un nuevo usuario con email y contraseña
  Future<firebase_auth.UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar el nombre del usuario
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();

      return userCredential;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Inicia sesión con email y contraseña
  Future<firebase_auth.UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Inicia sesión con Google
  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    try {
      // Disparar el flujo de autenticación
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Inicio de sesión cancelado por el usuario');
      }

      // Obtener los detalles de autenticación de la solicitud
      final googleAuth = await googleUser.authentication;

      // Crear una nueva credencial para Firebase
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase con la credencial de Google
      return await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: ${e.toString()}');
    }
  }

  /// Cierra la sesión del usuario
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  /// Envía un email de verificación al usuario
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('Error al enviar email de verificación: ${e.toString()}');
    }
  }

  /// Envía un email de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Elimina la cuenta del usuario actual
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Sign out from Google if signed in with Google
      await _googleSignIn.signOut();

      // Delete the user account
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
            'Por favor, inicia sesión de nuevo para eliminar tu cuenta');
      }
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al eliminar la cuenta: ${e.toString()}');
    }
  }

  /// Re-autentica al usuario (necesario para operaciones sensibles)
  Future<void> reauthenticateWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Re-autenticación cancelada');
      }

      final googleAuth = await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = currentUser;
      if (user != null) {
        await user.reauthenticateWithCredential(credential);
      }
    } catch (e) {
      throw Exception('Error en re-autenticación: ${e.toString()}');
    }
  }

  /// Re-autentica con email y contraseña
  Future<void> reauthenticateWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No hay usuario autenticado');
      }

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Maneja las excepciones de Firebase Auth y devuelve mensajes amigables
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'user-not-found':
        return 'No se encontró ninguna cuenta con este correo electrónico.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'operation-not-allowed':
        return 'Operación no permitida. Contacte al administrador.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Por favor, intente más tarde.';
      case 'network-request-failed':
        return 'Error de conexión. Verifique su internet.';
      case 'requires-recent-login':
        return 'Por seguridad, debe iniciar sesión nuevamente.';
      case 'invalid-credential':
        return 'Las credenciales proporcionadas son inválidas.';
      default:
        return 'Error de autenticación: ${e.message ?? e.code}';
    }
  }

  /// Obtiene el token de ID del usuario currente
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await currentUser?.getIdToken(forceRefresh);
    } catch (e) {
      return null;
    }
  }
}
