import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_auth_provider.dart';
import '../services/permission_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/validators.dart';
import '../shared/widgets/buttons/primary_button.dart';
import '../shared/widgets/inputs/app_text_field.dart';
import '../shared/widgets/inputs/app_password_field.dart';
import '../utils/network_diagnostics.dart';
import '../config/api_config.dart';
import 'register_screen.dart';
import '../shared/layouts/bottom_navigation_layout.dart';
import 'role_selection_screen.dart';
import 'permission_flow_manager.dart';

/// Pantalla de inicio de sesión con diseño minimalista
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider =
        Provider.of<FirebaseAuthProvider>(context, listen: false);

    // Mostrar información de diagnóstico en consola
    print('🔄 Intentando login con:');
    print('  Email: ${_emailController.text.trim()}');
    print('  URL: ${ApiConfig.loginUrl}');

    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final needsRole = await authProvider.needsRoleSelection();
      if (needsRole) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      } else {
        final permissionsNeeded =
            await PermissionService.getPermissionsNeedingPopup();

        if (permissionsNeeded.isNotEmpty) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PermissionFlowManager(
                isNewUser: false,
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const BottomNavigationLayout()),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error al iniciar sesión'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceXL,
            vertical: AppDimensions.spaceS,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spaceS),

                // Logo y título
                _buildHeader(),

                const SizedBox(height: AppDimensions.spaceM),

                // Formulario
                _buildForm(),

                const SizedBox(height: AppDimensions.spaceM),

                // Botón de login
                _buildLoginButton(),

                const SizedBox(height: AppDimensions.spaceS),

                // Divider
                _buildDivider(),

                const SizedBox(height: AppDimensions.spaceS),

                // Link de registro
                _buildRegisterLink(),

                const Spacer(), // Empuja el contenido hacia arriba
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            child: Image.asset(
              'assets/images/minkar.png',
              fit: BoxFit.contain,
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spaceXS),

        // Título principal
        Text(
          'MinkAR',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontFamily: 'RobotoMono',
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 2),

        // Subtítulo
        Text(
          'CONECTA CON TU CULTURA',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w500,
            fontFamily: 'RobotoMono',
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campo de email
        AppTextField(
          controller: _emailController,
          label: 'Correo Electrónico',
          hint: 'tu@ejemplo.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: Validators.email,
        ),

        const SizedBox(height: AppDimensions.spaceS),

        // Campo de contraseña
        AppPasswordField(
          controller: _passwordController,
          label: 'Contraseña',
          hint: 'Tu contraseña',
          textInputAction: TextInputAction.done,
          validator: Validators.password,
          onFieldSubmitted: (_) => _handleLogin(),
        ),

        const SizedBox(height: AppDimensions.spaceXS),

        // Recordarme y Recuperar contraseña
        _buildRememberAndForgot(),
      ],
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Checkbox Recordarme
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Recordarme',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontFamily: 'RobotoMono',
                fontSize: 12,
              ),
            ),
          ],
        ),

        // Enlace Recuperar contraseña (alineado a la derecha)
        GestureDetector(
          onTap: () {
            // TODO: Implementar recuperación de contraseña
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Función de recuperación de contraseña próximamente'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: Text(
            '¿Olvidaste tu contraseña?',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontFamily: 'RobotoMono',
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Consumer<FirebaseAuthProvider>(
      builder: (context, authProvider, child) {
        return PrimaryButton(
          text: 'Iniciar Sesión',
          onPressed: _handleLogin,
          isLoading: authProvider.isLoading,
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.divider),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space),
          child: Text(
            'o',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.divider),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¿No tienes una cuenta? ',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'RobotoMono',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                ),
              );
            },
            child: Text(
              'Regístrate',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontFamily: 'RobotoMono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
