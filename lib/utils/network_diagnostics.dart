import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Herramienta de diagnóstico para probar la conexión con el backend
class NetworkDiagnostics {
  /// Prueba la conexión con el backend
  static Future<DiagnosticResult> testConnection() async {
    final results = <String, dynamic>{};
    final errors = <String>[];

    // 1. Verificar la URL configurada
    results['configuredBaseUrl'] = ApiConfig.baseUrl;
    results['loginUrl'] = ApiConfig.loginUrl;

    // 2. Intentar conexión básica
    try {
      print('🔍 Probando conexión a: ${ApiConfig.baseUrl}');

      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/actuator/health'))
          .timeout(const Duration(seconds: 5));

      results['healthCheck'] = {
        'status': response.statusCode,
        'body': response.body,
      };

      if (response.statusCode == 200) {
        print('✅ Backend respondió correctamente');
      } else {
        errors.add('Backend respondió con código: ${response.statusCode}');
        print('⚠️ Backend respondió con código: ${response.statusCode}');
      }
    } catch (e) {
      errors.add('Error en health check: $e');
      print('❌ Error en health check: $e');
    }

    // 3. Probar el endpoint de login
    try {
      print('🔍 Probando endpoint de login: ${ApiConfig.loginUrl}');

      final testData = {
        'email': 'test@example.com',
        'password': 'test123'
      };

      final response = await http
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(testData),
          )
          .timeout(const Duration(seconds: 5));

      results['loginEndpoint'] = {
        'status': response.statusCode,
        'body': response.body.length > 200
            ? '${response.body.substring(0, 200)}...'
            : response.body,
      };

      print('📊 Login endpoint respondió con: ${response.statusCode}');

      if (response.statusCode == 401 || response.statusCode == 400) {
        print('✅ Endpoint de login está accesible (credenciales incorrectas es esperado)');
      } else if (response.statusCode == 200) {
        print('✅ Endpoint de login está accesible');
      } else {
        errors.add('Login endpoint respondió con código inesperado: ${response.statusCode}');
        print('⚠️ Código inesperado: ${response.statusCode}');
      }
    } catch (e) {
      errors.add('Error probando login: $e');
      print('❌ Error probando login: $e');
    }

    // 4. Probar URLs alternativas
    final alternativeUrls = [
      'http://localhost:8080',
      'http://10.0.2.2:8080',
      'http://127.0.0.1:8080',
    ];

    final reachableUrls = <String>[];

    for (final url in alternativeUrls) {
      if (url == ApiConfig.baseUrl) continue; // Ya lo probamos

      try {
        print('🔍 Probando URL alternativa: $url');
        final response = await http
            .get(Uri.parse('$url/actuator/health'))
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200 || response.statusCode == 404) {
          reachableUrls.add(url);
          print('✅ URL alternativa alcanzable: $url');
        }
      } catch (e) {
        print('❌ URL alternativa no alcanzable: $url');
      }
    }

    results['alternativeUrls'] = reachableUrls;

    return DiagnosticResult(
      success: errors.isEmpty,
      results: results,
      errors: errors,
      reachableUrls: reachableUrls,
    );
  }

  /// Imprime un reporte detallado del diagnóstico
  static void printReport(DiagnosticResult result) {
    print('\n' + '=' * 50);
    print('📋 REPORTE DE DIAGNÓSTICO DE RED');
    print('=' * 50);

    print('\n🔧 Configuración actual:');
    print('  Base URL: ${result.results['configuredBaseUrl']}');
    print('  Login URL: ${result.results['loginUrl']}');

    if (result.results['healthCheck'] != null) {
      print('\n💚 Health Check:');
      print('  Status: ${result.results['healthCheck']['status']}');
      print('  Body: ${result.results['healthCheck']['body']}');
    }

    if (result.results['loginEndpoint'] != null) {
      print('\n🔐 Login Endpoint:');
      print('  Status: ${result.results['loginEndpoint']['status']}');
      print('  Response: ${result.results['loginEndpoint']['body']}');
    }

    if (result.reachableUrls.isNotEmpty) {
      print('\n✅ URLs alternativas alcanzables:');
      for (final url in result.reachableUrls) {
        print('  - $url');
      }
    }

    if (result.errors.isNotEmpty) {
      print('\n❌ Errores encontrados:');
      for (final error in result.errors) {
        print('  - $error');
      }
    }

    print('\n💡 Recomendaciones:');
    if (result.errors.isEmpty) {
      print('  ✅ La conexión está funcionando correctamente');
    } else {
      print('  1. Verifica que el backend esté corriendo en puerto 8080');
      print('  2. Si usas Android Emulator, usa: http://10.0.2.2:8080');
      print('  3. Si usas iOS Simulator, usa: http://localhost:8080');
      print('  4. Si usas dispositivo físico, usa tu IP local (ej: http://192.168.1.100:8080)');
      print('  5. Verifica que no haya firewall bloqueando la conexión');

      if (result.reachableUrls.isNotEmpty) {
        print('\n  💡 Intenta cambiar la URL a: ${result.reachableUrls.first}');
        print('     En api_config.dart, cambia:');
        print('     static const String baseUrl = \'${result.reachableUrls.first}\';');
      }
    }

    print('\n' + '=' * 50 + '\n');
  }
}

/// Resultado del diagnóstico
class DiagnosticResult {
  final bool success;
  final Map<String, dynamic> results;
  final List<String> errors;
  final List<String> reachableUrls;

  DiagnosticResult({
    required this.success,
    required this.results,
    required this.errors,
    required this.reachableUrls,
  });
}
