import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class Model3DViewerScreen extends StatefulWidget {
  final String modelUrl;
  final String modelName;
  final bool isLocalFile; // NUEVO: indica si es archivo local o URL

  const Model3DViewerScreen({
    Key? key, 
    required this.modelUrl,
    required this.modelName,
    this.isLocalFile = false, // Por defecto false para compatibilidad
  }) : super(key: key);

  @override
  State<Model3DViewerScreen> createState() => _Model3DViewerScreenState();
}

class _Model3DViewerScreenState extends State<Model3DViewerScreen> {
  bool _isLoading = true;
  String? _dataUrl; // Para almacenar la data URL del archivo local
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isLocalFile) {
      _loadLocalFile();
    }
  }

  Future<void> _loadLocalFile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final file = File(widget.modelUrl);
      
      if (!await file.exists()) {
        throw Exception('El archivo no existe: ${widget.modelUrl}');
      }

      print('📁 Loading local file: ${widget.modelUrl}');
      final bytes = await file.readAsBytes();
      print('📊 File size: ${bytes.length} bytes');
      
      final base64String = base64Encode(bytes);
      final dataUrl = 'data:model/gltf-binary;base64,$base64String';
      
      setState(() {
        _dataUrl = dataUrl;
        _isLoading = false;
      });
      
      print('✅ Data URL created successfully');
    } catch (e) {
      print('❌ Error loading local file: $e');
      setState(() {
        _error = 'Error al cargar el modelo: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modelName),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (!widget.isLocalFile)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadModel,
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareModel(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.modelName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isLocalFile
                      ? 'Modelo local generado con Kiri Engine'
                      : 'Modelo generado con Kiri Engine',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.view_in_ar, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'AR disponible - Toca el botón AR en el visor',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Visor 3D
          Expanded(
            child: _buildModelViewer(),
          ),

          // Controles inferiores
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControl(Icons.refresh, 'Resetear', _resetView),
                _buildControl(Icons.fullscreen, 'Fullscreen', _toggleFullscreen),
                _buildControl(Icons.info, 'Info', _showModelInfo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelViewer() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.isLocalFile ? _loadLocalFile : null,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (widget.isLocalFile && _dataUrl == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
            ),
            SizedBox(height: 12),
            Text("Preparando modelo local...",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ModelViewer(
          src: widget.isLocalFile ? _dataUrl! : widget.modelUrl,
          alt: 'Modelo 3D de ${widget.modelName}',
          ar: true,
          arModes: const ['webxr', 'scene-viewer', 'quick-look'],
          arScale: ArScale.auto,
          autoRotate: true,
          cameraControls: true,
          backgroundColor: const Color(0xFF455A64),
          loading: Loading.eager,
          onWebViewCreated: (controller) {
            setState(() => _isLoading = false);
          },
        ),
        if (_isLoading)
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                ),
                SizedBox(height: 12),
                Text("Cargando modelo...",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildControl(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.deepPurple),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Future<void> _downloadModel() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${widget.modelName}.glb');

      final response = await http.get(Uri.parse(widget.modelUrl));
      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Modelo guardado en: ${file.path}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar: $e')),
      );
    }
  }

  void _shareModel() {
    if (widget.isLocalFile) {
      // Para archivos locales, comparte el archivo
      Share.shareXFiles(
        [XFile(widget.modelUrl)],
        text: 'Modelo 3D: ${widget.modelName}',
      );
    } else {
      // Para URLs, comparte el enlace
      Share.share('Explora este modelo 3D: ${widget.modelUrl}');
    }
  }

  void _resetView() {
    if (widget.isLocalFile) {
      _loadLocalFile();
    } else {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }

  void _toggleFullscreen() {
    if (widget.isLocalFile && _dataUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El modelo aún se está cargando')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: ModelViewer(
              src: widget.isLocalFile ? _dataUrl! : widget.modelUrl,
              alt: 'Modelo 3D en pantalla completa',
              autoRotate: true,
              cameraControls: true,
              backgroundColor: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  void _showModelInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Información del Modelo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nombre: ${widget.modelName}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.isLocalFile ? 'Tipo: Archivo local' : 'Tipo: URL remota'),
              const SizedBox(height: 8),
              if (widget.isLocalFile)
                Text('Ruta: ${widget.modelUrl}',
                    style: const TextStyle(fontSize: 11))
              else
                Text('URL: ${widget.modelUrl}',
                    style: const TextStyle(fontSize: 11)),
              const SizedBox(height: 8),
              const Text('Formato: GLB (Kiri Engine)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              const Text('Controles:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('• Arrastrar → Rotar'),
              const Text('• Pellizcar → Zoom'),
              const Text('• Dos dedos → Mover'),
              const Divider(),
              const Row(
                children: [
                  Icon(Icons.view_in_ar, color: Colors.deepPurple, size: 20),
                  SizedBox(width: 8),
                  Text('Realidad Aumentada:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Busca el botón AR en la esquina inferior derecha del visor.'),
              const SizedBox(height: 4),
              const Text('• Android: Usa WebXR o Scene Viewer'),
              const Text('• iOS: Usa AR Quick Look'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}