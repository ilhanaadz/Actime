import 'package:flutter/material.dart';
import '../components/admin_layout.dart';
import '../services/services.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _dashboardService = DashboardService();

  bool _isLoading = true;
  String? _error;

  int _totalUsers = 0;
  int _totalOrganizations = 0;
  int _totalEvents = 0;
  List<UserGrowthData> _userGrowthData = [];

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
      final statsResponse = await _dashboardService.getStats();
      final growthResponse = await _dashboardService.getUserGrowth();

      if (!mounted) return;

      if (statsResponse.success && statsResponse.data != null) {
        setState(() {
          _totalUsers = statsResponse.data!.totalUsers;
          _totalOrganizations = statsResponse.data!.totalOrganizations;
          _totalEvents = statsResponse.data!.totalEvents;
        });
      }

      if (growthResponse.success && growthResponse.data != null) {
        setState(() {
          _userGrowthData = growthResponse.data!;
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load dashboard data';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: 'dashboard',
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadDashboardData,
                    tooltip: 'Refresh',
                  ),
              ],
            ),
          ),

          // Dashboard Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Users',
                                    _totalUsers.toString(),
                                    Icons.people_outline,
                                    const Color(0xFF0D7C8C),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    'Organizations',
                                    _totalOrganizations.toString(),
                                    Icons.apartment_outlined,
                                    Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    'Events',
                                    _totalEvents.toString(),
                                    Icons.event_outlined,
                                    Colors.green,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Chart Section
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'User Growth',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    height: 300,
                                    child: _buildBarChart(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (_userGrowthData.isEmpty) {
      // Fallback to default data if API doesn't return data
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar(120, 'Jan'),
          _buildBar(150, 'Feb'),
          _buildBar(100, 'Mar'),
          _buildBar(180, 'Apr'),
          _buildBar(140, 'May'),
          _buildBar(190, 'Jun'),
          _buildBar(160, 'Jul'),
          _buildBar(200, 'Aug'),
          _buildBar(170, 'Sep'),
          _buildBar(210, 'Oct'),
          _buildBar(180, 'Nov'),
          _buildBar(220, 'Dec'),
        ],
      );
    }

    final maxCount = _userGrowthData
        .map((e) => e.count)
        .reduce((a, b) => a > b ? a : b);
    final scaleFactor = maxCount > 0 ? 250 / maxCount : 1.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _userGrowthData.map((data) {
        return _buildBar(
          (data.count * scaleFactor).toDouble(),
          data.month.length > 3 ? data.month.substring(0, 3) : data.month,
        );
      }).toList(),
    );
  }

  Widget _buildBar(double height, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF0D7C8C),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
