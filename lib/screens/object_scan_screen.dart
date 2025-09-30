import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../services/object_scan_service.dart';
import '../utils/camera_utils.dart';
import 'model_3d_viewer_screen.dart';

class ObjectScanScreen extends StatefulWidget {
  const ObjectScanScreen({super.key});

  @override
  State<ObjectScanScreen> createState() => _ObjectScanScreenState();
}

class _ObjectScanScreenState extends State<ObjectScanScreen> {
  late CameraController _cameraController;
  bool _isLoading = true;
  bool _isRecording = false;
  bool _isProcessing = false;
  String _processingStatus = '';
  final List<File> _capturedImages = [];
  File? _recordedVideo;
  final _objectNameController = TextEditingController();
  final _objectScanService = ObjectScanService();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraController = await CameraUtils.initializeCamera();
      await _cameraController.initialize();
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  Future<void> _takePicture() async {
    if (_isProcessing) return;
    
    try {
      final imageFile = await CameraUtils.takePicture(_cameraController);
      setState(() => _capturedImages.add(imageFile));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image captured (${_capturedImages.length} total)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: $e')),
        );
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isProcessing) return;
    
    try {
      if (!_isRecording) {
        // Clear images if switching to video mode
        if (_capturedImages.isNotEmpty) {
          bool clearImages = await _showConfirmDialog(
            'Switch to Video Mode',
            'This will clear all captured images. Continue?',
          );
          if (!clearImages) return;
          setState(() {
            _capturedImages.clear();
          });
        }
        
        // Start recording
        await CameraUtils.startVideoRecording(_cameraController);
        setState(() => _isRecording = true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording started'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Stop recording
        final videoFile = await CameraUtils.stopVideoRecording(_cameraController);
        setState(() {
          _isRecording = false;
          _recordedVideo = videoFile;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording saved'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during recording: $e')),
        );
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _processForModel() async {
    // Validaciones
    if (_capturedImages.isEmpty && _recordedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture at least 20 images or 1 video')),
      );
      return;
    }

    if (_capturedImages.isNotEmpty && _capturedImages.length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Need at least 20 images for 3D model. You have ${_capturedImages.length}.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final objectName = _objectNameController.text.trim();
    if (objectName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name for the object')),
      );
      return;
    }

    // Verificar conectividad primero
    setState(() {
      _isProcessing = true;
      _processingStatus = 'Checking connection...';
    });

    try {
      bool isHealthy = await _objectScanService.checkHealth();
      if (!isHealthy) {
        throw Exception('Backend server is not responding. Please check your connection.');
      }

      String modelFilePath;

      if (_recordedVideo != null) {
        // Procesar video
        modelFilePath = await _objectScanService.processVideoAndGetModel(
          _recordedVideo!,
          objectName: objectName,
          onStatusUpdate: (status) {
            if (mounted) {
              setState(() {
                _processingStatus = status;
              });
            }
          },
        );
      } else {
        // Procesar imágenes
        modelFilePath = await _objectScanService.processImagesAndGetModel(
          _capturedImages,
          objectName: objectName,
          onStatusUpdate: (status) {
            if (mounted) {
              setState(() {
                _processingStatus = status;
              });
            }
          },
        );
      }

      setState(() {
        _isProcessing = false;
        _processingStatus = '';
      });

      if (mounted) {
        // Navegar al visor 3D
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Model3DViewerScreen(
              modelUrl: modelFilePath,
              modelName: objectName,
              isLocalFile: true,
            ),
          ),
        );
      }
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _processingStatus = '';
      });
      
      if (mounted) {
        // Mostrar error detallado
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Processing Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error: $e'),
                const SizedBox(height: 16),
                const Text(
                  'Troubleshooting tips:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text('• Check your internet connection'),
                const Text('• Make sure you have at least 20 images'),
                const Text('• Try with smaller image sizes'),
                const Text('• Check if the backend server is running'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _clearCaptures() {
    if (_isProcessing) return;
    
    setState(() {
      _capturedImages.clear();
      _recordedVideo = null;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Captures cleared')),
    );
  }

  void _removeImage(int index) {
    if (_isProcessing) return;
    
    setState(() {
      _capturedImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _objectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing camera...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Object Scanning'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_capturedImages.isNotEmpty || _recordedVideo != null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearCaptures,
              tooltip: 'Clear all captures',
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Camera preview
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple, width: 2),
                  ),
                  child: AspectRatio(
                    aspectRatio: _cameraController.value.aspectRatio,
                    child: CameraPreview(_cameraController),
                  ),
                ),
              ),
              
              // Status info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                color: Colors.grey[100],
                child: Column(
                  children: [
                    Text(
                      _recordedVideo != null 
                          ? 'Video recorded' 
                          : 'Images: ${_capturedImages.length} / 20 minimum',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _capturedImages.length >= 20 || _recordedVideo != null
                            ? Colors.green 
                            : Colors.orange,
                      ),
                    ),
                    if (_capturedImages.isNotEmpty)
                      Text(
                        _capturedImages.length < 20 
                            ? 'Need ${20 - _capturedImages.length} more images'
                            : 'Ready for processing!',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              
              // Captured media preview
              if (_capturedImages.isNotEmpty || _recordedVideo != null)
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._capturedImages.asMap().entries.map((entry) => 
                        _buildThumbnail(
                          FileImage(entry.value), 
                          index: entry.key,
                        )),
                      if (_recordedVideo != null) 
                        _buildThumbnail(
                          FileImage(_recordedVideo!), 
                          isVideo: true,
                        ),
                    ],
                  ),
                ),
              
              // Object name input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _objectNameController,
                  enabled: !_isProcessing,
                  decoration: const InputDecoration(
                    labelText: 'Object Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                    hintText: 'Enter a name for your 3D model',
                  ),
                ),
              ),
              
              // Capture controls
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Take Photo Button
                    FloatingActionButton(
                      heroTag: 'photo',
                      onPressed: _isProcessing || _recordedVideo != null ? null : _takePicture,
                      backgroundColor: _isProcessing || _recordedVideo != null 
                          ? Colors.grey 
                          : Colors.deepPurple,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                    
                    // Toggle Video Recording Button
                    FloatingActionButton(
                      heroTag: 'video',
                      onPressed: _isProcessing ? null : _toggleRecording,
                      backgroundColor: _isProcessing 
                          ? Colors.grey
                          : (_isRecording ? Colors.red : Colors.deepPurple),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.videocam,
                        color: Colors.white,
                      ),
                    ),
                    
                    // Process Button
                    FloatingActionButton.extended(
                      heroTag: 'process',
                      onPressed: (_capturedImages.length >= 20 || _recordedVideo != null) && !_isProcessing
                          ? _processForModel
                          : null,
                      backgroundColor: (_capturedImages.length >= 20 || _recordedVideo != null) && !_isProcessing
                          ? Colors.deepPurple 
                          : Colors.grey,
                      label: Text(
                        _isProcessing ? 'Processing...' : 'Create 3D Model',
                        style: const TextStyle(color: Colors.white),
                      ),
                      icon: _isProcessing 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.view_in_ar, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text(
                          'Creating 3D Model',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _processingStatus,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'This may take several minutes...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(ImageProvider image, {bool isVideo = false, int? index}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.deepPurple, width: 2),
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (isVideo)
            const Positioned.fill(
              child: Icon(Icons.videocam, color: Colors.white, size: 24),
            ),
          if (index != null && !_isProcessing)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}