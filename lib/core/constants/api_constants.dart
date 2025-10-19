/// Constantes centralizadas para configuración de API
class ApiConstants {
  ApiConstants._(); // Constructor privado

  // ========== BASE URLs ==========

  /// URL base del backend en desarrollo
  static const String baseUrlDev = 'http://localhost:8080';

  /// URL base del backend en producción
  static const String baseUrlProd = 'https://api.disrupton.com';

  /// URL base actual (cambiar según entorno)
  static const String baseUrl = baseUrlDev;

  /// URL base de la API
  static const String apiUrl = '$baseUrl/api';

  // ========== ENDPOINTS - AUTENTICACIÓN ==========

  static const String authLogin = '$apiUrl/auth/login';
  static const String authRegister = '$apiUrl/auth/register';
  static const String authLogout = '$apiUrl/auth/logout';
  static const String authRefreshToken = '$apiUrl/auth/refresh';
  static const String authVerifyEmail = '$apiUrl/auth/verify-email';
  static const String authResetPassword = '$apiUrl/auth/reset-password';
  static const String authChangePassword = '$apiUrl/auth/change-password';

  // ========== ENDPOINTS - USUARIOS ==========

  static const String users = '$apiUrl/users';
  static const String userProfile = '$apiUrl/users/profile';
  static const String userUpdateProfile = '$apiUrl/users/profile/update';
  static const String userAvatar = '$apiUrl/users/avatar';

  // ========== ENDPOINTS - AVATARES AI ==========

  static const String avatars = '$apiUrl/avatars';
  static const String avatarChat = '$apiUrl/avatars/chat';
  static const String avatarConversations = '$apiUrl/avatars/conversations';

  // ========== ENDPOINTS - OBJETOS CULTURALES ==========

  static const String culturalObjects = '$apiUrl/cultural-objects';
  static const String culturalObjectsSearch = '$apiUrl/cultural-objects/search';
  static const String culturalObjectsByDepartment = '$apiUrl/cultural-objects/department';
  static const String culturalObjectsNearby = '$apiUrl/cultural-objects/nearby';

  // ========== ENDPOINTS - EVENTOS ==========

  static const String events = '$apiUrl/events';
  static const String eventsScraped = '$apiUrl/events/scraped';
  static const String eventsCreate = '$apiUrl/events/create';
  static const String eventsUpdate = '$apiUrl/events/update';
  static const String eventsDelete = '$apiUrl/events/delete';
  static const String eventsByCategory = '$apiUrl/events/category';

  // ========== ENDPOINTS - COLECCIONES ==========

  static const String collections = '$apiUrl/collections';
  static const String collectionsByDepartment = '$apiUrl/collections/department';

  // ========== ENDPOINTS - AGENTES CULTURALES ==========

  static const String culturalAgents = '$apiUrl/cultural-agents';
  static const String culturalAgentsArtisans = '$apiUrl/cultural-agents/artisans';
  static const String culturalAgentsGuides = '$apiUrl/cultural-agents/guides';

  // ========== ENDPOINTS - PRODUCTOS ==========

  static const String products = '$apiUrl/products';
  static const String productsArtisan = '$apiUrl/products/artisan';
  static const String productsCreate = '$apiUrl/products/create';
  static const String productsUpdate = '$apiUrl/products/update';
  static const String productsDelete = '$apiUrl/products/delete';

  // ========== ENDPOINTS - SERVICIOS TURÍSTICOS ==========

  static const String tourismServices = '$apiUrl/tourism-services';
  static const String tourismServicesGuide = '$apiUrl/tourism-services/guide';

  // ========== ENDPOINTS - TIENDA ==========

  static const String store = '$apiUrl/store';
  static const String storeProducts = '$apiUrl/store/products';
  static const String storeServices = '$apiUrl/store/services';

  // ========== ENDPOINTS - MURAL ==========

  static const String mural = '$apiUrl/mural';
  static const String muralQuestions = '$apiUrl/mural/questions';
  static const String muralComments = '$apiUrl/mural/comments';

  // ========== ENDPOINTS - RED SOCIAL ==========

  static const String socialPosts = '$apiUrl/social/posts';
  static const String socialPostsCreate = '$apiUrl/social/posts/create';
  static const String socialPostsLike = '$apiUrl/social/posts/like';
  static const String socialPostsComment = '$apiUrl/social/posts/comment';

  // ========== ENDPOINTS - FAVORITOS ==========

  static const String favorites = '$apiUrl/favorites';
  static const String favoritesAdd = '$apiUrl/favorites/add';
  static const String favoritesRemove = '$apiUrl/favorites/remove';

  // ========== ENDPOINTS - COMENTARIOS ==========

  static const String comments = '$apiUrl/comments';
  static const String commentsCreate = '$apiUrl/comments/create';
  static const String commentsUpdate = '$apiUrl/comments/update';
  static const String commentsDelete = '$apiUrl/comments/delete';

  // ========== ENDPOINTS - ANALYTICS ==========

  static const String analytics = '$apiUrl/analytics';
  static const String analyticsDashboard = '$apiUrl/analytics/dashboard';
  static const String analyticsEvents = '$apiUrl/analytics/events';

  // ========== ENDPOINTS - ADMIN ==========

  static const String admin = '$apiUrl/admin';
  static const String adminUsers = '$apiUrl/admin/users';
  static const String adminEvents = '$apiUrl/admin/events';
  static const String adminDashboard = '$apiUrl/admin/dashboard';

  // ========== ENDPOINTS - MODERADOR ==========

  static const String moderator = '$apiUrl/moderator';
  static const String moderatorPendingRequests = '$apiUrl/moderator/pending-requests';
  static const String moderatorApprove = '$apiUrl/moderator/approve';
  static const String moderatorReject = '$apiUrl/moderator/reject';

  // ========== ENDPOINTS - REALIDAD AUMENTADA ==========

  static const String ar = '$apiUrl/ar';
  static const String arModels = '$apiUrl/ar/models';
  static const String arKiriEngine = '$apiUrl/ar/kiri-engine';

  // ========== ENDPOINTS - GEOLOCALIZACION ==========

  static const String geolocation = '$apiUrl/geolocation';
  static const String geolocationNearby = '$apiUrl/geolocation/nearby';

  // ========== ENDPOINTS - STORAGE ==========

  static const String storage = '$apiUrl/storage';
  static const String storageUpload = '$apiUrl/storage/upload';
  static const String storageDelete = '$apiUrl/storage/delete';

  // ========== TIMEOUTS ==========

  /// Timeout para conexión (en segundos)
  static const int connectTimeout = 30;

  /// Timeout para recepción de datos (en segundos)
  static const int receiveTimeout = 30;

  /// Timeout para envío de datos (en segundos)
  static const int sendTimeout = 30;

  // ========== HEADERS ==========

  /// Content-Type para JSON
  static const String contentTypeJson = 'application/json';

  /// Content-Type para form data
  static const String contentTypeFormData = 'multipart/form-data';

  /// Key para el token de autorización
  static const String authorizationKey = 'Authorization';

  /// Prefijo del bearer token
  static const String bearerPrefix = 'Bearer';

  // ========== MÉTODOS HELPER ==========

  /// Construye URL completa para un endpoint con parámetros
  static String buildUrl(String endpoint, [Map<String, dynamic>? queryParams]) {
    if (queryParams == null || queryParams.isEmpty) {
      return endpoint;
    }

    final uri = Uri.parse(endpoint);
    final newUri = uri.replace(queryParameters: queryParams.map(
      (key, value) => MapEntry(key, value.toString()),
    ));

    return newUri.toString();
  }

  /// Construye URL con ID
  static String buildUrlWithId(String endpoint, String id) {
    return '$endpoint/$id';
  }

  /// Construye headers de autorización
  static Map<String, String> buildAuthHeaders(String token) {
    return {
      authorizationKey: '$bearerPrefix $token',
      'Content-Type': contentTypeJson,
    };
  }
}
