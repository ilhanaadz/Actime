import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import '../components/admin_layout.dart';
import '../services/services.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _dashboardService = DashboardService();
  final _screenshotController = ScreenshotController();

  bool _isLoading = true;
  String? _error;

  int _totalUsers = 0;
  int _totalOrganizations = 0;
  int _totalEvents = 0;
  List<UserGrowthData> _userGrowthData = [];

  // Date range filter
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime _endDate = DateTime.now();

  // Chart type toggle
  String _selectedChartType = 'line'; // 'line', 'area', 'bar'

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
      final growthResponse = await _dashboardService.getUserGrowth(
        startDate: _startDate,
        endDate: _endDate,
      );

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
            child: Column(
              children: [
                Row(
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
                const SizedBox(height: 16),
                // Toolbar with filters and export
                _buildToolbar(),
              ],
            ),
          ),

          // Dashboard Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : Screenshot(
                        controller: _screenshotController,
                        child: SingleChildScrollView(
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

                            // Charts Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bar Chart - User Growth
                                Expanded(
                                  flex: 2,
                                  child: Container(
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
                                          child: _buildFlBarChart(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Pie Chart - Distribution
                                Expanded(
                                  child: Container(
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
                                          'Data Distribution',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          height: 220,
                                          child: _buildPieChart(),
                                        ),
                                        const SizedBox(height: 16),
                                        _buildPieChartLegend(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Line Chart - Combined Trends
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
                                  Row(
                                    children: [
                                      const Text(
                                        'Growth Trends',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const Spacer(),
                                      _buildLineChartLegend(),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    height: 300,
                                    child: _buildDynamicChart(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildFlBarChart() {
    if (_userGrowthData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    final maxCount = _userGrowthData
        .map((e) => e.count)
        .reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCount > 0 ? maxCount.toDouble() * 1.2 : 10,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black87,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${_userGrowthData[groupIndex].month}\n${rod.toY.toInt()} users',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _userGrowthData.length) {
                    final month = _userGrowthData[value.toInt()].month;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        month.length > 3 ? month.substring(0, 3) : month,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxCount > 0 ? (maxCount / 5) : 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200]!,
                strokeWidth: 1,
              );
            },
          ),
          barGroups: _userGrowthData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.count.toDouble(),
                  color: const Color(0xFF0D7C8C),
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final total = _totalUsers + _totalOrganizations + _totalEvents;

    if (total == 0) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: [
          PieChartSectionData(
            color: const Color(0xFF0D7C8C),
            value: _totalUsers.toDouble(),
            title: '${((_totalUsers / total) * 100).toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.orange,
            value: _totalOrganizations.toDouble(),
            title: '${((_totalOrganizations / total) * 100).toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: _totalEvents.toDouble(),
            title: '${((_totalEvents / total) * 100).toStringAsFixed(1)}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicChart() {
    switch (_selectedChartType) {
      case 'line':
        return _buildLineChart();
      case 'area':
        return _buildAreaChart();
      case 'bar':
        return _buildMultiBarChart();
      default:
        return _buildLineChart();
    }
  }

  Widget _buildLineChart() {
    if (_userGrowthData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    // Generate simulated data for organizations and events based on users
    final orgData = _userGrowthData.map((d) => (d.count * 0.3).toInt()).toList();
    final eventData = _userGrowthData.map((d) => (d.count * 0.5).toInt()).toList();

    final maxValue = [
      ..._userGrowthData.map((e) => e.count),
      ...orgData,
      ...eventData,
    ].reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue > 0 ? (maxValue / 5) : 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200]!,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _userGrowthData.length) {
                    final month = _userGrowthData[value.toInt()].month;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        month.length > 3 ? month.substring(0, 3) : month,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          minX: 0,
          maxX: (_userGrowthData.length - 1).toDouble(),
          minY: 0,
          maxY: maxValue > 0 ? maxValue.toDouble() * 1.2 : 10,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.black87,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  String label = '';
                  if (spot.barIndex == 0) label = 'Users';
                  if (spot.barIndex == 1) label = 'Orgs';
                  if (spot.barIndex == 2) label = 'Events';

                  return LineTooltipItem(
                    '$label: ${spot.y.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            // Users line
            LineChartBarData(
              spots: _userGrowthData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
              }).toList(),
              isCurved: true,
              color: const Color(0xFF0D7C8C),
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF0D7C8C).withOpacity(0.1),
              ),
            ),
            // Organizations line
            LineChartBarData(
              spots: orgData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.orange,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.1),
              ),
            ),
            // Events line
            LineChartBarData(
              spots: eventData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaChart() {
    if (_userGrowthData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    // Generate simulated data for organizations and events based on users
    final orgData = _userGrowthData.map((d) => (d.count * 0.3).toInt()).toList();
    final eventData = _userGrowthData.map((d) => (d.count * 0.5).toInt()).toList();

    final maxValue = [
      ..._userGrowthData.map((e) => e.count),
      ...orgData,
      ...eventData,
    ].reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue > 0 ? (maxValue / 5) : 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200]!,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _userGrowthData.length) {
                    final month = _userGrowthData[value.toInt()].month;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        month.length > 3 ? month.substring(0, 3) : month,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          minX: 0,
          maxX: (_userGrowthData.length - 1).toDouble(),
          minY: 0,
          maxY: maxValue > 0 ? maxValue.toDouble() * 1.2 : 10,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.black87,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  String label = '';
                  if (spot.barIndex == 0) label = 'Users';
                  if (spot.barIndex == 1) label = 'Orgs';
                  if (spot.barIndex == 2) label = 'Events';

                  return LineTooltipItem(
                    '$label: ${spot.y.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            // Users area
            LineChartBarData(
              spots: _userGrowthData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
              }).toList(),
              isCurved: true,
              color: const Color(0xFF0D7C8C),
              barWidth: 0,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF0D7C8C).withOpacity(0.3),
              ),
            ),
            // Organizations area
            LineChartBarData(
              spots: orgData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.orange,
              barWidth: 0,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            // Events area
            LineChartBarData(
              spots: eventData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 0,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.green.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiBarChart() {
    if (_userGrowthData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    // Generate simulated data for organizations and events based on users
    final orgData = _userGrowthData.map((d) => (d.count * 0.3).toInt()).toList();
    final eventData = _userGrowthData.map((d) => (d.count * 0.5).toInt()).toList();

    final maxValue = [
      ..._userGrowthData.map((e) => e.count),
      ...orgData,
      ...eventData,
    ].reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue > 0 ? maxValue.toDouble() * 1.2 : 10,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black87,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String label = '';
                if (rodIndex == 0) label = 'Users';
                if (rodIndex == 1) label = 'Orgs';
                if (rodIndex == 2) label = 'Events';

                return BarTooltipItem(
                  '${_userGrowthData[groupIndex].month}\n$label: ${rod.toY.toInt()}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _userGrowthData.length) {
                    final month = _userGrowthData[value.toInt()].month;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        month.length > 3 ? month.substring(0, 3) : month,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue > 0 ? (maxValue / 5) : 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200]!,
                strokeWidth: 1,
              );
            },
          ),
          barGroups: _userGrowthData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.count.toDouble(),
                  color: const Color(0xFF0D7C8C),
                  width: 6,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(2),
                  ),
                ),
                BarChartRodData(
                  toY: orgData[entry.key].toDouble(),
                  color: Colors.orange,
                  width: 6,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(2),
                  ),
                ),
                BarChartRodData(
                  toY: eventData[entry.key].toDouble(),
                  color: Colors.green,
                  width: 6,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(2),
                    topRight: Radius.circular(2),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPieChartLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLegendItem('Users', const Color(0xFF0D7C8C), _totalUsers),
        const SizedBox(height: 8),
        _buildLegendItem('Organizations', Colors.orange, _totalOrganizations),
        const SizedBox(height: 8),
        _buildLegendItem('Events', Colors.green, _totalEvents),
      ],
    );
  }

  Widget _buildLineChartLegend() {
    return Row(
      children: [
        _buildLegendIndicator('Users', const Color(0xFF0D7C8C)),
        const SizedBox(width: 16),
        _buildLegendIndicator('Orgs', Colors.orange),
        const SizedBox(width: 16),
        _buildLegendIndicator('Events', Colors.green),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendIndicator(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Date Range Filter
          Icon(Icons.date_range, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            'Date Range:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          _buildDateButton(
            DateFormat('MMM d, yyyy').format(_startDate),
            () => _selectDate(isStart: true),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey[600]),
          ),
          _buildDateButton(
            DateFormat('MMM d, yyyy').format(_endDate),
            () => _selectDate(isStart: false),
          ),
          const SizedBox(width: 24),

          // Chart Type Selector
          Icon(Icons.show_chart, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            'Chart Type:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          _buildChartTypeButton('Line', 'line', Icons.show_chart),
          const SizedBox(width: 8),
          _buildChartTypeButton('Area', 'area', Icons.area_chart),
          const SizedBox(width: 8),
          _buildChartTypeButton('Bar', 'bar', Icons.bar_chart),

          const Spacer(),

          // Export Buttons
          ElevatedButton.icon(
            onPressed: _exportToPNG,
            icon: const Icon(Icons.image, size: 18),
            label: const Text('Export PNG'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D7C8C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _exportToPDF,
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('Export PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 4),
          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(String label, String type, IconData icon) {
    final isSelected = _selectedChartType == type;
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _selectedChartType = type;
        });
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: isSelected ? const Color(0xFF0D7C8C) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        side: BorderSide(
          color: isSelected ? const Color(0xFF0D7C8C) : Colors.grey[300]!,
        ),
      ),
    );
  }

  Future<void> _selectDate({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 30));
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 30));
          }
        }
      });
      _loadDashboardData();
    }
  }

  Future<void> _exportToPNG() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) {
        _showMessage('Failed to capture screenshot');
        return;
      }

      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Dashboard Screenshot',
        fileName: 'dashboard_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png',
        type: FileType.image,
      );

      if (path != null) {
        final file = File(path);
        await file.writeAsBytes(image);
        _showMessage('Dashboard exported successfully to PNG!');
      }
    } catch (e) {
      _showMessage('Error exporting to PNG: $e');
    }
  }

  Future<void> _exportToPDF() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) {
        _showMessage('Failed to capture screenshot');
        return;
      }

      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (context) {
            return pw.Center(
              child: pw.Image(pw.MemoryImage(image)),
            );
          },
        ),
      );

      final String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Dashboard PDF',
        fileName: 'dashboard_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (path != null) {
        final file = File(path);
        await file.writeAsBytes(await doc.save());
        _showMessage('Dashboard exported successfully to PDF!');
      }
    } catch (e) {
      _showMessage('Error exporting to PDF: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
