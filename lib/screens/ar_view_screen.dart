import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_updated/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin_updated/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_updated/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_updated/models/ar_node.dart';
import 'package:ar_flutter_plugin_updated/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_updated/widgets/ar_view.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import '../models/pieza.dart';
import '../utils/model_loader.dart';

class ARViewScreen extends StatefulWidget {
  final Pieza pieza;

  const ARViewScreen({super.key, required this.pieza});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;
  late ARAnchorManager arAnchorManager;

  List<ARNode> nodes = [];
  List<ARAnchor> anchors = [];

  @override
  void dispose() {
    arSessionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pieza.nombre} - RA'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
          ),
          _buildControls(),
          _buildInfoPanel(),
        ],
      ),
    );
  }

  void onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    arSessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      customPlaneTexturePath: "assets/triangle.png",
      showWorldOrigin: true,
      handleTaps: false,
    );

    arObjectManager.onInitialize();
    _cargarModelo3D();
  }

  Future<void> _cargarModelo3D() async {
    if (!mounted) return;
    
    try {
      // Mostrar indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cargando modelo 3D...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      debugPrint('Iniciando carga del modelo para la pieza: ${widget.pieza.nombre}');
      debugPrint('URL del modelo: ${widget.pieza.urlModelo3D}');
      
      // Cargar el modelo desde la URL
      final modelPath = await ModelLoader.cargarModeloDesdeUrl(
        widget.pieza.urlModelo3D,
        widget.pieza.id,
      );

      if (!mounted) return;
      
      if (modelPath == null) {
        throw Exception('No se pudo cargar el modelo 3D. Verifica tu conexión a Internet.');
      }
      
      debugPrint('Modelo cargado correctamente en: $modelPath');
      
      // Verificar que el archivo existe
      final modelFile = File(modelPath);
      final fileExists = await modelFile.exists();
      
      if (!fileExists) {
        throw Exception('El archivo del modelo no se encontró en la ruta: $modelPath');
      }
      
      // Crear el nodo AR
      final newNode = ARNode(
        type: NodeType.localGLTF2,
        uri: modelPath,
        scale: Vector3.all(widget.pieza.escala),
        position: Vector3(
          widget.pieza.posicionInicial[0],
          widget.pieza.posicionInicial[1],
          widget.pieza.posicionInicial[2],
        ),
        rotation: Vector4(
          widget.pieza.rotacionInicial[0],
          widget.pieza.rotacionInicial[1],
          widget.pieza.rotacionInicial[2],
          1.0,
        ),
      );

      // Añadir el nodo a la escena AR
      final didAddNodeSuccess = await arObjectManager.addNode(newNode);
      
      if (!mounted) return;
      
      if (didAddNodeSuccess == true) {
        nodes.add(newNode);
        debugPrint('Modelo 3D agregado correctamente a la escena AR');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Modelo 3D cargado correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('No se pudo agregar el modelo a la escena AR');
      }
    } catch (e) {
      debugPrint('❌ Error cargando modelo 3D: $e');
      
      if (!mounted) return;
      
      // Mostrar mensaje de error al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar el modelo 3D: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Reintentar',
            onPressed: _cargarModelo3D,
          ),
        ),
      );
    }
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: _resetModel,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.refresh),
          ),
          FloatingActionButton(
            onPressed: _toggleModelVisibility,
            backgroundColor: Colors.green,
            child: const Icon(Icons.visibility),
          ),
          FloatingActionButton(
            onPressed: _scaleModel,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.zoom_in),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.pieza.nombre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.pieza.descripcion,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Época: ${widget.pieza.epoca}',
              style: TextStyle(color: Colors.blue[300]),
            ),
          ],
        ),
      ),
    );
  }

  void _resetModel() {
    // Resetear posición y rotación del modelo
    debugPrint('Reseteando modelo');
  }

  void _toggleModelVisibility() {
    // Alternar visibilidad del modelo
    debugPrint('Alternando visibilidad del modelo');
  }

  void _scaleModel() {
    // Escalar el modelo
    debugPrint('Escalando modelo');
  }
}
