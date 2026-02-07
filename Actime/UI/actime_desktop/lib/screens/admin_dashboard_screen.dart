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
  List<OrganizationUserData> _organizationUserData = [];

  // Export options
  bool _exportStats = true;
  bool _exportDistribution = true;
  bool _exportUsersPerOrg = true;

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
      final usersPerOrgResponse = await _dashboardService.getUsersPerOrganization();

      if (!mounted) return;

      if (statsResponse.success && statsResponse.data != null) {
        setState(() {
          _totalUsers = statsResponse.data!.totalUsers;
          _totalOrganizations = statsResponse.data!.totalOrganizations;
          _totalEvents = statsResponse.data!.totalEvents;
        });
      }

      if (usersPerOrgResponse.success && usersPerOrgResponse.data != null) {
        setState(() {
          _organizationUserData = usersPerOrgResponse.data!;
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 900;

                if (isSmallScreen) {
                  // Small screen: Stack vertically
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (!_isLoading) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _loadDashboardData,
                              tooltip: 'Refresh',
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.tune),
                              tooltip: 'Export Options',
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  enabled: false,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Select sections to export:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      CheckboxListTile(
                                        title: const Text('Stats Cards', style: TextStyle(fontSize: 13)),
                                        value: _exportStats,
                                        dense: true,
                                        onChanged: (value) {
                                          setState(() => _exportStats = value ?? true);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      CheckboxListTile(
                                        title: const Text('Data Distribution', style: TextStyle(fontSize: 13)),
                                        value: _exportDistribution,
                                        dense: true,
                                        onChanged: (value) {
                                          setState(() => _exportDistribution = value ?? true);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      CheckboxListTile(
                                        title: const Text('Users Per Organization', style: TextStyle(fontSize: 13)),
                                        value: _exportUsersPerOrg,
                                        dense: true,
                                        onChanged: (value) {
                                          setState(() => _exportUsersPerOrg = value ?? true);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: _exportToPNG,
                              icon: const Icon(Icons.image, size: 18),
                              label: const Text('Export PNG'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D7C8C),
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _exportToPDF,
                              icon: const Icon(Icons.picture_as_pdf, size: 18),
                              label: const Text('Export PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                }

                // Large screen: Original row layout
                return Row(
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
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadDashboardData,
                            tooltip: 'Refresh',
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.tune),
                            tooltip: 'Export Options',
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                enabled: false,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Select sections to export:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    CheckboxListTile(
                                      title: const Text('Stats Cards', style: TextStyle(fontSize: 13)),
                                      value: _exportStats,
                                      dense: true,
                                      onChanged: (value) {
                                        setState(() => _exportStats = value ?? true);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Data Distribution', style: TextStyle(fontSize: 13)),
                                      value: _exportDistribution,
                                      dense: true,
                                      onChanged: (value) {
                                        setState(() => _exportDistribution = value ?? true);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Users Per Organization', style: TextStyle(fontSize: 13)),
                                      value: _exportUsersPerOrg,
                                      dense: true,
                                      onChanged: (value) {
                                        setState(() => _exportUsersPerOrg = value ?? true);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _exportToPNG,
                            icon: const Icon(Icons.image, size: 18),
                            label: const Text('Export PNG'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D7C8C),
                              foregroundColor: Colors.white,
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
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
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
                        child: Screenshot(
                          controller: _screenshotController,
                          child: Container(
                            color: Colors.grey[100],
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Stats Cards
                                if (_exportStats)
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final cardWidth = constraints.maxWidth > 700
                                        ? (constraints.maxWidth - 32) / 3
                                        : constraints.maxWidth;

                                      return Wrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        children: [
                                          SizedBox(
                                            width: cardWidth,
                                            child: _buildStatCard(
                                              'Users',
                                              _totalUsers.toString(),
                                              Icons.people_outline,
                                              const Color(0xFF0D7C8C),
                                            ),
                                          ),
                                          SizedBox(
                                            width: cardWidth,
                                            child: _buildStatCard(
                                              'Organizations',
                                              _totalOrganizations.toString(),
                                              Icons.apartment_outlined,
                                              Colors.orange,
                                            ),
                                          ),
                                          SizedBox(
                                            width: cardWidth,
                                            child: _buildStatCard(
                                              'Events',
                                              _totalEvents.toString(),
                                              Icons.event_outlined,
                                              Colors.green,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                if (_exportStats && (_exportDistribution || _exportUsersPerOrg))
                                  const SizedBox(height: 24),

                                // Data Distribution Chart
                                if (_exportDistribution)
                                  LayoutBuilder(
                                  builder: (context, constraints) {
                                    final chartHeight = (constraints.maxWidth * 0.3).clamp(300.0, 500.0);

                                    return Container(
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
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            height: chartHeight,
                                            child: _buildDistributionBarChart(),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                if (_exportDistribution && _exportUsersPerOrg)
                                  const SizedBox(height: 24),

                                // Users Per Organization Chart
                                if (_exportUsersPerOrg)
                                  LayoutBuilder(
                                  builder: (context, constraints) {
                                    final chartHeight = (_organizationUserData.length * 60.0).clamp(300.0, 600.0);

                                    return Container(
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
                                            'Users Per Organization',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            height: chartHeight,
                                            child: _buildUsersPerOrganizationChart(),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
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

  Widget _buildDistributionBarChart() {
    final total = _totalUsers + _totalOrganizations + _totalEvents;

    if (total == 0) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    final maxValue = [_totalUsers, _totalOrganizations, _totalEvents]
        .reduce((a, b) => a > b ? a : b);

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
                if (groupIndex == 0) label = 'Users';
                if (groupIndex == 1) label = 'Organizations';
                if (groupIndex == 2) label = 'Events';

                final percentage = ((rod.toY / total) * 100).toStringAsFixed(1);
                return BarTooltipItem(
                  '$label\n${rod.toY.toInt()} ($percentage%)',
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
                  const labels = ['Users', 'Orgs', 'Events'];
                  if (value.toInt() >= 0 && value.toInt() < labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[value.toInt()],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: _totalUsers.toDouble(),
                  color: const Color(0xFF0D7C8C),
                  width: 40,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: _totalOrganizations.toDouble(),
                  color: Colors.orange,
                  width: 40,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: _totalEvents.toDouble(),
                  color: Colors.green,
                  width: 40,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersPerOrganizationChart() {
    if (_organizationUserData.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    final maxValue = _organizationUserData
        .map((e) => e.totalUsers)
        .reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue > 0 ? maxValue.toDouble() * 1.2 : 10,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black87,
              tooltipPadding: const EdgeInsets.all(12),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final org = _organizationUserData[groupIndex];
                return BarTooltipItem(
                  '${org.organizationName}\n'
                  'Members: ${org.memberCount}\n'
                  'Event Participants: ${org.eventParticipantCount}\n'
                  'Total: ${org.totalUsers}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
                reservedSize: 120,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _organizationUserData.length) {
                    final orgName = _organizationUserData[value.toInt()].organizationName;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Text(
                          orgName.length > 15 ? '${orgName.substring(0, 15)}...' : orgName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
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
                reservedSize: 50,
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
          barGroups: _organizationUserData.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.totalUsers.toDouble(),
                  color: const Color(0xFF0D7C8C),
                  width: 30,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0D7C8C),
                      const Color(0xFF0D7C8C).withOpacity(0.7),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
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
