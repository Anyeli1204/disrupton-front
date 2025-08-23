import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/role_models.dart';

class AdminService {
  static const String _baseUrl = '${ApiConfig.baseUrl}/api/admin';

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

  // Get dashboard statistics
  static Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard/stats'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DashboardStats.fromJson(data);
      } else {
        throw Exception(
            'Failed to load dashboard stats: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockDashboardStats();
    }
  }

  // Get chart data for analytics
  static Future<List<ChartData>> getChartData(String chartType,
      {int days = 30}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/analytics/$chartType?days=$days'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => ChartData.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load chart data: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data
      return _getMockChartData(chartType);
    }
  }

  // Get user management data
  static Future<Map<String, dynamic>> getUserManagement() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to load user management data: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data
      return _getMockUserManagement();
    }
  }

  // Mock data methods
  static DashboardStats _getMockDashboardStats() {
    return const DashboardStats(
      totalUsers: 15420,
      activeUsers: 8765,
      totalContent: 2341,
      pendingApprovals: 47,
      totalInteractions: 98234,
      arSessions: 12678,
      averageSessionTime: 12.5,
      totalDownloads: 45678,
    );
  }

  static List<ChartData> _getMockChartData(String chartType) {
    final now = DateTime.now();
    switch (chartType) {
      case 'users':
        return List.generate(7, (index) {
          return ChartData(
            label: 'Día ${index + 1}',
            value: (100 + (index * 50)).toDouble(),
            date: now.subtract(Duration(days: 6 - index)),
          );
        });
      case 'sessions':
        return List.generate(7, (index) {
          return ChartData(
            label: 'Día ${index + 1}',
            value: (200 + (index * 75)).toDouble(),
            date: now.subtract(Duration(days: 6 - index)),
          );
        });
      default:
        return [];
    }
  }

  static Map<String, dynamic> _getMockUserManagement() {
    return {
      'recentUsers': [
        {
          'name': 'Juan Pérez',
          'email': 'juan@email.com',
          'role': 'USER',
          'status': 'active'
        },
        {
          'name': 'María García',
          'email': 'maria@email.com',
          'role': 'GUIDE',
          'status': 'active'
        },
        {
          'name': 'Carlos López',
          'email': 'carlos@email.com',
          'role': 'ARTISAN',
          'status': 'pending'
        },
      ],
      'roleDistribution': {
        'USER': 12500,
        'GUIDE': 150,
        'ARTISAN': 75,
        'MODERATOR': 25,
        'PREMIUM': 670,
        'ADMIN': 10,
      }
    };
  }
}
