import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../widgets/onirix_ar_view.dart';

class ARScreen extends StatefulWidget {
  final String? sceneId;
  final String? accessToken;
  final String? title;

  const ARScreen({
    super.key,
    this.sceneId,
    this.accessToken,
    this.title = 'Realidad Aumentada',
  });

  @override
  ARScreenState createState() => ARScreenState();
}

class ARScreenState extends State<ARScreen> {
  bool _hasPermission = false;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final hasPermission = await PermissionService.hasCameraPermission();
      if (!hasPermission) {
        final granted = await PermissionService.requestCameraPermission();
        setState(() {
          _hasPermission = granted;
          if (!granted) {
            _errorMessage = 'Se requieren permisos de cámara para usar la realidad aumentada';
          }
        });
      } else {
        setState(() {
          _hasPermission = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al verificar los permisos: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Realidad Aumentada'),
        actions: [
          if (!_hasPermission && _errorMessage.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => PermissionService.openAppSettings(),
              tooltip: 'Abrir configuración',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
              const SizedBox(height: 24),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                onPressed: _checkPermissions,
              ),
            ],
          ),
        ),
      );
    }

    if (_hasPermission) {
      return OnirixARView(
        sceneId: widget.sceneId,
        accessToken: widget.accessToken,
        onError: (error) {
          setState(() {
            _errorMessage = error;
          });
        },
      );
    }

    return const Center(
      child: Text('Estado desconocido. Por favor, reinicia la aplicación.'),
    );
  }
}
