import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import '../models/pieza.dart';
import '../utils/model_loader.dart';

class ARViewScreen extends StatefulWidget {
  final Pieza pieza;

  const ARViewScreen({Key? key, required this.pieza}) : super(key: key);

  @override
  _ARViewScreenState createState() => _ARViewScreenState();
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
    try {
      final modelPath = await ModelLoader.cargarModeloDesdeUrl(
        widget.pieza.urlModelo3D,
        widget.pieza.id,
      );

      if (modelPath != null) {
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

        bool? didAddNodeSuccess = await arObjectManager.addNode(newNode);
        if (didAddNodeSuccess!) {
          nodes.add(newNode);
        }
      }
    } catch (e) {
      print('Error cargando modelo 3D: $e');
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
            child: Icon(Icons.refresh),
            backgroundColor: Colors.blue,
          ),
          FloatingActionButton(
            onPressed: _toggleModelVisibility,
            child: Icon(Icons.visibility),
            backgroundColor: Colors.green,
          ),
          FloatingActionButton(
            onPressed: _scaleModel,
            child: Icon(Icons.zoom_in),
            backgroundColor: Colors.orange,
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
        padding: EdgeInsets.all(16),
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
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              widget.pieza.descripcion,
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 8),
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
  }

  void _toggleModelVisibility() {
    // Alternar visibilidad del modelo
  }

  void _scaleModel() {
    // Escalar el modelo
  }
}
