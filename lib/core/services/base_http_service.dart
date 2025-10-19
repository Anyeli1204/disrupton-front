import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../services/auth_service.dart';

/// Servicio base para todas las peticiones HTTP
/// Proporciona funcionalidad común y manejo centralizado de errores
class BaseHttpService {
  late final Dio _dio;
  final AuthService? _authService;

  BaseHttpService({AuthService? authService}) : _authService = authService {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiUrl,
        connectTimeout: Duration(seconds: ApiConstants.connectTimeout),
        receiveTimeout: Duration(seconds: ApiConstants.receiveTimeout),
        sendTimeout: Duration(seconds: ApiConstants.sendTimeout),
        headers: {
          'Content-Type': ApiConstants.contentTypeJson,
        },
      ),
    );

    _setupInterceptors();
  }

  /// Configura interceptores para logging y autenticación
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar token de autenticación si existe
          if (_authService != null) {
            final token = await _authService!.getToken();
            if (token != null) {
              options.headers[ApiConstants.authorizationKey] =
                  '${ApiConstants.bearerPrefix} $token';
            }
          }

          // Log de request
          print('📤 REQUEST: ${options.method} ${options.uri}');
          if (options.data != null) {
            print('📦 DATA: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log de response
          print('📥 RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log de error
          print('❌ ERROR: ${error.message}');
          print('   URL: ${error.requestOptions.uri}');

          // Manejar error 401 (no autorizado) - Refresh token
          if (error.response?.statusCode == 401 && _authService != null) {
            try {
              // Intentar refrescar el token
              final newToken = await _authService!.refreshToken();
              // Reintentar la petición con el nuevo token
              error.requestOptions.headers[ApiConstants.authorizationKey] =
                  '${ApiConstants.bearerPrefix} $newToken';

              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              // Si falla el refresh, logout
              await _authService!.logout();
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  // ========== MÉTODOS HTTP ==========

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload de archivos
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          contentType: ApiConstants.contentTypeFormData,
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download de archivos
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== MANEJO DE ERRORES ==========

  /// Maneja errores de Dio y los convierte a excepciones personalizadas
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return HttpException('Tiempo de conexión agotado. Verifica tu conexión a internet.');

      case DioExceptionType.sendTimeout:
        return HttpException('Tiempo de envío agotado. Intenta nuevamente.');

      case DioExceptionType.receiveTimeout:
        return HttpException('Tiempo de respuesta agotado. El servidor no responde.');

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return HttpException('Petición cancelada.');

      case DioExceptionType.connectionError:
        return HttpException('Error de conexión. Verifica tu conexión a internet.');

      default:
        return HttpException('Error inesperado: ${error.message}');
    }
  }

  /// Maneja respuestas incorrectas del servidor
  Exception _handleBadResponse(Response? response) {
    if (response == null) {
      return HttpException('Error del servidor. Sin respuesta.');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Intentar extraer mensaje de error del servidor
    String message = 'Error del servidor ($statusCode)';
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? data['error'] ?? message;
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(message);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 500:
        return ServerException(message);
      default:
        return HttpException(message);
    }
  }

  /// Cierra el cliente Dio
  void dispose() {
    _dio.close();
  }
}

// ========== EXCEPCIONES PERSONALIZADAS ==========

class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}

class BadRequestException extends HttpException {
  BadRequestException(String message) : super(message);
}

class UnauthorizedException extends HttpException {
  UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends HttpException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends HttpException {
  NotFoundException(String message) : super(message);
}

class ServerException extends HttpException {
  ServerException(String message) : super(message);
}
