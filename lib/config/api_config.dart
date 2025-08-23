class ApiConfig {
  // Backend URLs - Cambia estas URLs según tu entorno

  // Para desarrollo local con Android Emulator
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:8080';

  // Para desarrollo local con iOS Simulator
  static const String iosSimulatorBaseUrl = 'http://localhost:8080';

  // Para desarrollo local con dispositivo físico (cambia la IP por la de tu máquina)
  static const String physicalDeviceBaseUrl = 'http://192.168.1.100:8080';

  // Para producción (reemplaza con tu URL de producción)
  static const String productionBaseUrl = 'https://tu-backend-url.com';

  // URL base actual - cambia esto según tu necesidad
  static const String baseUrl = androidEmulatorBaseUrl;

  // Para desarrollo rápido en Windows/Chrome usa:
  // static const String baseUrl = 'http://localhost:8080';

  // Para dispositivo físico usa tu IP local:
  // static const String baseUrl = 'http://192.168.1.100:8080';

  // Endpoints de la API
  static const String authEndpoint = '/api/auth';
  static const String usersEndpoint = '/api/users';
  static const String culturalObjectsEndpoint = '/api/cultural-objects';

  // URLs completas para autenticación
  static String get registerUrl => '$baseUrl$authEndpoint/register';
  static String get loginUrl => '$baseUrl$authEndpoint/login';
  static String get logoutUrl => '$baseUrl$authEndpoint/logout';
  static String get verifyUrl => '$baseUrl$authEndpoint/verify';
  static String get refreshUrl => '$baseUrl$authEndpoint/refresh';

  // Configuración de timeout
  static const int timeoutSeconds = 30;

  // Headers por defecto
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}

// Enum para diferentes entornos
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static const Environment currentEnvironment = Environment.development;

  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return ApiConfig.androidEmulatorBaseUrl;
      case Environment.staging:
        return 'https://staging.tu-backend-url.com';
      case Environment.production:
        return ApiConfig.productionBaseUrl;
    }
  }

  static bool get isDebugMode {
    return currentEnvironment == Environment.development;
  }
}
