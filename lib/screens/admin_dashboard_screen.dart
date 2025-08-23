import 'package:flutter/material.dart';
import '../models/role_models.dart';
import '../services/admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  DashboardStats? _stats;
  List<ChartData> _userChartData = [];
  List<ChartData> _sessionChartData = [];
  Map<String, dynamic> _userManagement = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        AdminService.getDashboardStats(),
        AdminService.getChartData('users'),
        AdminService.getChartData('sessions'),
        AdminService.getUserManagement(),
      ]);

      setState(() {
        _stats = results[0] as DashboardStats;
        _userChartData = results[1] as List<ChartData>;
        _sessionChartData = results[2] as List<ChartData>;
        _userManagement = results[3] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildDashboardContent(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            _buildStatsGrid(),

            const SizedBox(height: 24),

            // Charts Section
            Text(
              'Analíticas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
            ),
            const SizedBox(height: 16),
            _buildChartsSection(),

            const SizedBox(height: 24),

            // User Management Section
            Text(
              'Gestión de Usuarios',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
            ),
            const SizedBox(height: 16),
            _buildUserManagementSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = _stats!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Usuarios Totales',
          stats.totalUsers.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Usuarios Activos',
          stats.activeUsers.toString(),
          Icons.person_add,
          Colors.green,
        ),
        _buildStatCard(
          'Contenido Total',
          stats.totalContent.toString(),
          Icons.inventory,
          Colors.orange,
        ),
        _buildStatCard(
          'Pendientes',
          stats.pendingApprovals.toString(),
          Icons.pending_actions,
          Colors.red,
        ),
        _buildStatCard(
          'Interacciones',
          _formatNumber(stats.totalInteractions),
          Icons.touch_app,
          Colors.purple,
        ),
        _buildStatCard(
          'Sesiones AR',
          _formatNumber(stats.arSessions),
          Icons.view_in_ar,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuarios Registrados (Últimos 7 días)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildSimpleChart(_userChartData, Colors.blue),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sesiones Activas (Últimos 7 días)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildSimpleChart(_sessionChartData, Colors.green),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleChart(List<ChartData> data, Color color) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No hay datos disponibles',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((point) {
        final height = (point.value / maxValue) * 160;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              point.label,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildUserManagementSection() {
    final roleDistribution =
        _userManagement['roleDistribution'] as Map<String, dynamic>? ?? {};
    final recentUsers = _userManagement['recentUsers'] as List<dynamic>? ?? [];

    return Column(
      children: [
        // Role Distribution
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribución por Roles',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                ...roleDistribution.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          _formatNumber(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Recent Users
        Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuarios Recientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                ...recentUsers.map((user) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      child: Text(
                        user['name']
                                ?.toString()
                                .substring(0, 1)
                                .toUpperCase() ??
                            'U',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    title: Text(user['name']?.toString() ?? 'Usuario'),
                    subtitle: Text(user['email']?.toString() ?? ''),
                    trailing: Chip(
                      label: Text(
                        user['role']?.toString() ?? 'USER',
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: _getRoleColor(user['role']?.toString()),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'ADMIN':
        return Colors.red.shade100;
      case 'MODERATOR':
        return Colors.orange.shade100;
      case 'GUIDE':
        return Colors.teal.shade100;
      case 'ARTISAN':
        return Colors.purple.shade100;
      case 'PREMIUM':
        return Colors.amber.shade100;
      default:
        return Colors.blue.shade100;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
