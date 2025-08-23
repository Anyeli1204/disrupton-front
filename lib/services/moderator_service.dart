import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/role_models.dart';

class ModeratorService {
  static const String _baseUrl = '${ApiConfig.baseUrl}/api/moderator';

  // Get authenticated headers
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Get pending moderation requests
  static Future<List<ModerationRequest>> getPendingRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/requests/pending'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ModerationRequest.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load pending requests: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data
      return _getMockPendingRequests();
    }
  }

  // Approve a moderation request
  static Future<bool> approveRequest(String requestId, {String? notes}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/requests/$requestId/approve'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'reviewerNotes': notes,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Reject a moderation request
  static Future<bool> rejectRequest(String requestId, {String? notes}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/requests/$requestId/reject'),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'reviewerNotes': notes,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get moderation history
  static Future<List<ModerationRequest>> getModerationHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/requests/history'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ModerationRequest.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load moderation history: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data
      return _getMockModerationHistory();
    }
  }

  // Mock data
  static List<ModerationRequest> _getMockPendingRequests() {
    return [
      ModerationRequest(
        id: '1',
        userId: 'user1',
        userName: 'Juan Artista',
        userEmail: 'juan@email.com',
        title: 'Cerámica Shipibo',
        description:
            'Hermosa pieza de cerámica tradicional shipibo con diseños geométricos únicos.',
        modelUrl: 'https://example.com/model1.glb',
        imageUrls: [
          'https://via.placeholder.com/300x300/4CAF50/white?text=Ceramica+1',
          'https://via.placeholder.com/300x300/2196F3/white?text=Ceramica+2',
        ],
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ModerationRequest(
        id: '2',
        userId: 'user2',
        userName: 'María Textil',
        userEmail: 'maria@email.com',
        title: 'Textil Andino',
        description:
            'Textil tradicional andino con técnicas ancestrales de tejido.',
        modelUrl: 'https://example.com/model2.glb',
        imageUrls: [
          'https://via.placeholder.com/300x300/FF9800/white?text=Textil+1',
          'https://via.placeholder.com/300x300/E91E63/white?text=Textil+2',
        ],
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ModerationRequest(
        id: '3',
        userId: 'user3',
        userName: 'Carlos Orfebre',
        userEmail: 'carlos@email.com',
        title: 'Joyería Moche',
        description:
            'Replica de joyería Moche con técnicas tradicionales de orfebrería.',
        modelUrl: 'https://example.com/model3.glb',
        imageUrls: [
          'https://via.placeholder.com/300x300/FFC107/white?text=Joya+1',
          'https://via.placeholder.com/300x300/795548/white?text=Joya+2',
        ],
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<ModerationRequest> _getMockModerationHistory() {
    return [
      ModerationRequest(
        id: '4',
        userId: 'user4',
        userName: 'Ana Ceramista',
        userEmail: 'ana@email.com',
        title: 'Vasija Nazca',
        description: 'Vasija inspirada en el arte Nazca.',
        modelUrl: 'https://example.com/model4.glb',
        imageUrls: [
          'https://via.placeholder.com/300x300/9C27B0/white?text=Nazca'
        ],
        status: 'approved',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        reviewedAt: DateTime.now().subtract(const Duration(days: 2)),
        reviewerNotes: 'Excelente calidad y autenticidad.',
      ),
      ModerationRequest(
        id: '5',
        userId: 'user5',
        userName: 'Pedro Tallador',
        userEmail: 'pedro@email.com',
        title: 'Máscara Ritual',
        description: 'Máscara ritual de madera.',
        modelUrl: 'https://example.com/model5.glb',
        imageUrls: [
          'https://via.placeholder.com/300x300/F44336/white?text=Mascara'
        ],
        status: 'rejected',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        reviewedAt: DateTime.now().subtract(const Duration(days: 4)),
        reviewerNotes: 'No cumple con los estándares de calidad requeridos.',
      ),
    ];
  }
}
