import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Solicitar permisos necesarios
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Verificar si los permisos están concedidos
  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // Abrir configuración de la aplicación
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
