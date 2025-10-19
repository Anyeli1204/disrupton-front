import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/firebase_auth_provider.dart';
import 'auth_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const String _appBarTitle = 'Cuenta';

  Future<void> _signOut() async {
    try {
      final authProvider = Provider.of<FirebaseAuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error al cerrar sesión: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final authProvider = Provider.of<FirebaseAuthProvider>(context, listen: false);
    final currentUser = authProvider.firebaseUser;

    if (currentUser == null) {
      // No user logged in, navigate to AuthScreen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (Route<dynamic> route) => false,
        );
      }
      return;
    }

    final bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar cuenta'),
          content: const Text(
              '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción es irreversible.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ??
        false;

    if (!confirmDelete) {
      return;
    }

    try {
      // Check if user signed in with Google
      final isGoogleUser = currentUser.providerData
          .any((info) => info.providerId == 'google.com');

      // Re-authenticate if necessary
      if (isGoogleUser) {
        // For Google users, re-authenticate with Google
        try {
          await authProvider.reauthenticateWithGoogle();
        } catch (e) {
          debugPrint('Error en re-autenticación con Google: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Por favor, inicia sesión de nuevo para eliminar tu cuenta.')),
            );
          }
          return;
        }
      } else {
        // For email/password users, show dialog to re-authenticate
        final password = await _showPasswordDialog();
        if (password == null || password.isEmpty) {
          return; // User cancelled
        }

        try {
          await authProvider.reauthenticateWithEmailAndPassword(
            email: currentUser.email!,
            password: password,
          );
        } catch (e) {
          debugPrint('Error en re-autenticación: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
          return;
        }
      }

      // Now delete the account
      await authProvider.deleteAccount();

      debugPrint('Cuenta eliminada exitosamente.');
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Error al eliminar la cuenta: ${e.code}');
      String message;
      if (e.code == 'requires-recent-login') {
        message = 'Por favor, inicia sesión de nuevo para eliminar tu cuenta.';
      } else {
        message = 'Error al eliminar la cuenta: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      debugPrint('Error inesperado al eliminar la cuenta: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrió un error inesperado.')),
        );
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    final TextEditingController passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar identidad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Por seguridad, ingresa tu contraseña para continuar:'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(passwordController.text),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_appBarTitle),
      ),
      body: Consumer<FirebaseAuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.firebaseUser;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User info
                  if (user != null) ...[
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.displayName ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!user.emailVerified)
                      Chip(
                        label: const Text('Email no verificado'),
                        backgroundColor: Colors.orange[100],
                      ),
                    const SizedBox(height: 32),
                  ],

                  // Sign out button
                  ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 48),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Delete account button
                  ElevatedButton.icon(
                    onPressed: _deleteAccount,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Eliminar cuenta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 48),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
