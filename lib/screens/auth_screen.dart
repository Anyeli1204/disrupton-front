import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_dimensions.dart';
import '../shared/widgets/inputs/app_text_field.dart';
import '../shared/widgets/inputs/app_password_field.dart';
import '../shared/widgets/buttons/primary_button.dart';
import 'register_screen.dart';
import '../shared/layouts/bottom_navigation_layout.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final String _serverClientId;

  AuthService(this._serverClientId) {
    // Inicializar Google Sign In con el client ID
    if (!kIsWeb) {
      // Solo en plataformas móviles
      _googleSignIn.signInSilently();
    }
  }

  Future<User?> signInWithGoogle() async {
    debugPrint('Attempting Google Sign-In...');
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint(
          'Google Sign-In: User cancelled sign-in or no account selected.',
        );
        return null;
      }
      debugPrint('Google Sign-In: googleUser: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      debugPrint('Google Sign-In: idToken: ${googleAuth.idToken}');

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      debugPrint('Google Sign-In: Successfully signed in with Firebase.');
      return userCredential.user;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    debugPrint('Attempting Email/Password Sign-In...');
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      debugPrint('Email/Password Sign-In: Successfully signed in.');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint('Error signing in with email and password: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      rethrow;
    }
  }

  Future<void> saveRememberMeData(
    String email,
    String password,
    bool rememberMe,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', rememberMe);
    if (rememberMe) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  Future<Map<String, String?>> loadRememberMeData() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    final email = prefs.getString('email');
    final password = prefs.getString('password');
    return {
      'rememberMe': rememberMe.toString(),
      'email': email,
      'password': password,
    };
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigningInWithEmail = false;
  bool _isSigningInWithGoogle = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final String serverClientId =
      '979546276287-8rk608g3dni1gaglm0lcfg338p8mcii1.apps.googleusercontent.com';
  final String apiKey = 'AIzaSyDWm7tEGsSR2xgg909GgAFTlJjPEn5p9sI';
  final AuthService _authService = AuthService(
      '979546276287-8rk608g3dni1gaglm0lcfg338p8mcii1.apps.googleusercontent.com');

  final TextEditingController _resetEmailController = TextEditingController();

  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMeData();
  }

  // Function to load saved 'Remember me' data
  Future<void> _loadRememberMeData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      }
    });
  }

  // Function to save 'Remember me' data
  Future<void> _saveRememberMeData(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isSigningInWithEmail = true;
    });
    try {
      if (_formKey.currentState!.validate()) {
        final user = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
        await _saveRememberMeData(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (!mounted) return;
        if (user != null) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BottomNavigationLayout()),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Error: No se pudo obtener el usuario autenticado.')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message =
            'No existe una cuenta con este correo. Por favor, regístrate primero.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta. Verifica tus credenciales.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo electrónico no es válido.';
      } else if (e.code == 'user-disabled') {
        message = 'Esta cuenta ha sido deshabilitada.';
      } else if (e.code == 'invalid-credential') {
        message =
            'Las credenciales son inválidas. Verifica tu correo y contraseña, o regístrate si no tienes cuenta.';
      } else {
        message = 'Error de inicio de sesión: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isSigningInWithEmail = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningInWithGoogle = true;
    });
    try {
      final user = await _authService.signInWithGoogle();
      if (!mounted) return;
      if (user != null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BottomNavigationLayout()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inicio de sesión cancelado'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de inicio de sesión con Google: ${e.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isSigningInWithGoogle = false;
      });
    }
  }

  // Function to show the forgot password dialog
  void _showForgotPasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text('Restablecer Contraseña',
              style: AppTypography.headlineSmall),
          content: Form(
            key: formKey,
            child: AppTextField(
              controller: _resetEmailController,
              label: 'Correo Electrónico',
              hint: 'Ingresa tu correo electrónico',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingresa tu correo electrónico.';
                }
                if (!value.contains('@')) {
                  return 'El correo debe contener @';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancelar',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            PrimaryButton(
              text: 'Enviar',
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final authScreenContext = context;
                  try {
                    final navigator = Navigator.of(dialogContext);
                    await _authService
                        .sendPasswordResetEmail(_resetEmailController.text);
                    navigator.pop();
                    if (!authScreenContext.mounted) return;
                    ScaffoldMessenger.of(authScreenContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Se ha enviado un correo para restablecer tu contraseña.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (!authScreenContext.mounted) return;
                    ScaffoldMessenger.of(authScreenContext).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Error al enviar correo de restablecimiento: ${e.toString()}'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          final double maxHeight = constraints.maxHeight;
          final bool isTablet = maxWidth >= 600;
          final bool isDesktop = maxWidth >= 1024;
          final bool isSmallPhone = maxWidth < 360;
          final bool isLandscape = maxWidth > maxHeight;

          final double computedHorizontalPadding = isDesktop
              ? maxWidth * 0.18
              : isTablet
                  ? maxWidth * 0.12
                  : 24.0;
          final double horizontalPadding =
              computedHorizontalPadding.clamp(16.0, 140.0).toDouble();
          final double verticalPadding =
              isLandscape ? 32.0 : (isTablet ? 48.0 : 32.0);
          final double largeGap = isTablet ? 32.0 : 24.0;
          final double mediumGap = isTablet ? 24.0 : 16.0;
          final double smallGap = isTablet ? 16.0 : 12.0;
          final double logoHeight =
              isSmallPhone ? 120.0 : (isTablet ? 200.0 : 160.0);

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop
                        ? 520.0
                        : isTablet
                            ? 460.0
                            : 400.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/minkar.png',
                          height: logoHeight,
                        ),
                        SizedBox(height: largeGap + mediumGap / 2),
                        Text(
                          'Bienvenido de Nuevo',
                          textAlign: TextAlign.center,
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: mediumGap),
                        AppTextField(
                          controller: _emailController,
                          label: 'Correo Electrónico',
                          hint: 'Ingresa tu correo electrónico',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa tu correo electrónico.';
                            }
                            if (!value.contains('@')) {
                              return 'El correo debe contener @';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: mediumGap),
                        AppPasswordField(
                          controller: _passwordController,
                          label: 'Contraseña',
                          hint: 'Ingresa tu contraseña',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingresa tu contraseña.';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: mediumGap),
                        Wrap(
                          spacing: 12.0,
                          runSpacing: smallGap,
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                    _saveRememberMeData(
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                  },
                                  activeColor: AppColors.primary,
                                ),
                                Text(
                                  'Recordarme',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                _showForgotPasswordDialog(context);
                              },
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: largeGap),
                        PrimaryButton(
                          text: 'Iniciar sesión',
                          onPressed: () => _signInWithEmailAndPassword(),
                          isLoading: _isSigningInWithEmail,
                        ),
                        SizedBox(height: largeGap),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(
                                color: AppColors.textSecondary
                                    .withAlpha((255 * 0.5).round()),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'O inicia sesión con',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.textSecondary
                                    .withAlpha((255 * 0.5).round()),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: largeGap),
                        OutlinedButton(
                          onPressed:
                              _isSigningInWithGoogle ? null : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                                color: AppColors.divider, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusM),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/logo_google.jpeg',
                                height: 24.0,
                                width: 24.0,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Iniciar sesión con Google',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: largeGap),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: '¿No tienes cuenta? ',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Regístrate aquí',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
