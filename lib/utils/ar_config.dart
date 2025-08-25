class ARConfig {
  // Configuración de la sesión AR
  static const bool showFeaturePoints = false;
  static const bool showPlanes = true;
  static const bool showWorldOrigin = true;
  static const bool handleTaps = false;
  
  // Configuración de modelos 3D
  static const double defaultScale = 1.0;
  static const List<double> defaultPosition = [0.0, 0.0, 0.0];
  static const List<double> defaultRotation = [0.0, 0.0, 0.0];
  
  // Configuración de caché
  static const int maxCacheSize = 500 * 1024 * 1024; // 500MB
  static const String cacheDirectory = 'ar_model_cache';
  
  // Configuración de calidad
  static const bool enableShadows = true;
  static const bool enableLighting = true;
  static const double lightingIntensity = 1.0;
  
  // Configuración de interacción
  static const bool enableGestures = true;
  static const bool enableRotation = true;
  static const bool enableScaling = true;
  static const bool enableTranslation = true;
  
  // Configuración de rendimiento
  static const int maxConcurrentModels = 5;
  static const bool enableLOD = true; // Level of Detail
  static const bool enableOcclusion = true;
  
  // Configuración de tracking
  static const bool enablePlaneTracking = true;
  static const bool enableImageTracking = false;
  static const bool enableObjectTracking = false;
  
  // Configuración de UI
  static const double infoPanelOpacity = 0.8;
  static const double controlPanelOpacity = 0.9;
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Configuración de errores
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Configuración de permisos
  static const List<String> requiredPermissions = [
    'android.permission.CAMERA',
    'android.permission.INTERNET',
    'android.permission.WRITE_EXTERNAL_STORAGE',
  ];
  
  // Configuración de plataforma específica
  static const Map<String, dynamic> platformConfig = {
    'android': {
      'minSdkVersion': 24,
      'targetSdkVersion': 33,
      'arCoreVersion': '1.40.0',
    },
    'ios': {
      'minVersion': '11.0',
      'arkitVersion': '2.0',
    },
  };
}
