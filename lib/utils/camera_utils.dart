import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraUtils {
  static Future<CameraController> initializeCamera() async {
    // Check camera permission
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
      status = await Permission.camera.status;
      if (!status.isGranted) {
        throw Exception('Camera permission denied');
      }
    }

    // Get available cameras
    final cameras = await availableCameras();
    
    // Get a specific camera from the list of available cameras
    final firstCamera = cameras.first;

    // Create and return controller
    return CameraController(
      firstCamera,
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
  }

  static Future<File> takePicture(CameraController controller) async {
    try {
      // Ensure camera is initialized
      if (!controller.value.isInitialized) {
        throw Exception('Camera is not initialized');
      }

      // Get the path where the image will be saved
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/object_scan_$timestamp.jpg';

      // Take the picture
      final XFile image = await controller.takePicture();
      
      // Move the file to our desired location
      final savedImage = await File(image.path).copy(filePath);
      
      // Delete the original file
      await File(image.path).delete();
      
      return savedImage;
    } catch (e) {
      throw Exception('Failed to take picture: $e');
    }
  }

  static Future<File> startVideoRecording(CameraController controller) async {
    try {
      if (!controller.value.isInitialized) {
        throw Exception('Camera is not initialized');
      }

      // Get the path where the video will be saved
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/object_scan_$timestamp.mp4';

      // Start recording
      await controller.startVideoRecording();
      
      // Return the file where the video will be saved
      return File(filePath);
    } catch (e) {
      throw Exception('Failed to start video recording: $e');
    }
  }

  static Future<File> stopVideoRecording(CameraController controller) async {
    try {
      if (!controller.value.isRecordingVideo) {
        throw Exception('No video is being recorded');
      }

      // Stop recording
      final XFile videoFile = await controller.stopVideoRecording();
      
      // Get the path where the video will be saved
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/object_scan_${timestamp}_final.mp4';
      
      // Move the file to our desired location
      final savedVideo = await File(videoFile.path).copy(filePath);
      
      // Delete the original file
      await File(videoFile.path).delete();
      
      return savedVideo;
    } catch (e) {
      throw Exception('Failed to stop video recording: $e');
    }
  }
}
