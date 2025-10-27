import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/alert_card.dart';
import '../utils/colors.dart';
import '../utils/navigation_helper.dart';
import '../utils/responsive_layout.dart';
import '../components/machine_status_card.dart';
import 'machine.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import '../providers/machine_provider.dart';
import '../utils/api_config.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double tankLevel = 0.0;
  double batteryValue = 0.0;
  int temperatureC = 0;
  bool isLoading = true;
  List<dynamic> _alerts = [];
  bool _alertsLoading = true;
  Timer? _pollTimer;
  String _currentAlertStatus = 'normal'; // Track current alert status

  @override
  void initState() {
    super.initState();
    fetchTankData();
    fetchAlerts();
    // Auto-refresh alerts every 5 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      fetchAlerts();
      fetchTankData();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ✅ Get base URL from centralized config
  String _getBaseUrl() {
    return ApiConfig.baseUrl;
  }

  // Format ISO timestamp to readable format
  String _formatTime(String isoTime) {
    if (isoTime.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(isoTime);
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return isoTime;
    }
  }

  // ✅ Fetch data from backend
  Future<void> fetchTankData() async {
    try {
      final response = await http
          .get(Uri.parse('${_getBaseUrl()}/api/tank/status'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final int level = int.tryParse('${data['level'] ?? 0}') ?? 0;
        final double temperature =
            double.tryParse('${data['temperature'] ?? 0}') ?? 0.0;
        final int battery = int.tryParse('${data['batteryLevel'] ?? 0}') ?? 0;

        setState(() {
          tankLevel = level / 100.0; // percentage -> 0..1
          batteryValue = battery / 100.0;
          temperatureC = temperature.round(); // Convert to int for display
          isLoading = false;
        });
      } else {
        print('❌ Failed to fetch tank data: ${response.statusCode}');
        _useFallbackData();
      }
    } catch (e) {
      print('⚠️ Error fetching tank data: $e');
      _useFallbackData();
    }
  }

  void _useFallbackData() {
    setState(() {
      tankLevel = 1.0; // 100%
      batteryValue = 0.15; // 15%
      temperatureC = 96;
      isLoading = false;
    });
  }

  // ✅ Determine alert status based on recent alerts
  String _determineAlertStatus(List<dynamic> alerts) {
    if (alerts.isEmpty) {
      return 'normal';
    }

    // Check if any alert has Critical status (highest priority)
    bool hasCritical = alerts.any(
      (alert) => (alert['status'] ?? '').toString().toLowerCase() == 'critical',
    );

    if (hasCritical) {
      return 'critical';
    }

    // Check if any alert has Warning status
    bool hasWarning = alerts.any(
      (alert) => (alert['status'] ?? '').toString().toLowerCase() == 'warning',
    );

    if (hasWarning) {
      return 'warning';
    }

    return 'normal';
  }

  Future<void> fetchAlerts() async {
    try {
      // Fetch ALL alerts from the alerts endpoint (same as Alerts page)
      final response = await http
          .get(Uri.parse('${_getBaseUrl()}/api/tank/alerts'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> alertsData = json.decode(response.body);

        setState(() {
          _alerts = alertsData;
          _currentAlertStatus = _determineAlertStatus(alertsData);
          _alertsLoading = false;
        });
        print('✅ Fetched ${alertsData.length} alerts');
      } else {
        setState(() {
          _alertsLoading = false;
          _currentAlertStatus = 'normal';
          _alerts = [];
        });
        print('❌ Failed to fetch alerts: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _alertsLoading = false;
        _currentAlertStatus = 'normal';
        _alerts = [];
      });
      print('⚠️ Error fetching alerts: $e');
    }
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 0) return;

    Widget destination;
    switch (index) {
      case 1:
        destination = const MachinePage();
        break;
      case 2:
        destination = const AlertsPage();
        break;
      case 3:
        destination = const MaintenancePage();
        break;
      case 4:
        destination = const SettingsPage();
        break;
      default:
        destination = const DashboardPage();
    }

    NavigationHelper.navigateWithoutAnimation(context, destination);
  }

  @override
  Widget build(BuildContext context) {
    final machineProvider = Provider.of<MachineProvider>(context);
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveScaffold(
      title: 'VegoBolt Dashboard',
      currentIndex: 0,
      onNavigationChanged: (index) => _onNavTap(context, index),
      navigationItems: const [
        NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
        NavigationItem(icon: Icons.precision_manufacturing, label: 'Machine'),
        NavigationItem(icon: Icons.warning_amber, label: 'Alerts'),
        NavigationItem(icon: Icons.build, label: 'Maintenance'),
        NavigationItem(icon: Icons.settings, label: 'Settings'),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
              isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: ResponsiveLayout(
          maxWidth: 1600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page header at the top
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.getPadding(),
                  responsive.getValue(mobile: 16, tablet: 20, desktop: 24),
                  responsive.getPadding(),
                  responsive.getValue(mobile: 12, tablet: 16, desktop: 20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: responsive.getValue(
                              mobile: 28,
                              tablet: 32,
                              desktop: 36,
                            ),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monitor your VegoBolt system',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.getTextSecondary(context),
                        fontSize: responsive.getValue(
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(responsive.getPadding()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Machine Status'),
                      SizedBox(
                        height: responsive.getValue(
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),

                      MachineStatusCard(
                        machineId: 'VB-0001',
                        initialLocation: machineProvider.location,
                        statusText: machineProvider.statusText,
                        statusColor: machineProvider.statusColor,
                        tankLevel: tankLevel,
                        batteryValue: batteryValue,
                        temperatureC: temperatureC,
                        alertStatus: _currentAlertStatus,
                        isEditable: false,
                      ),

                      SizedBox(
                        height: responsive.getValue(
                          mobile: 20,
                          tablet: 24,
                          desktop: 32,
                        ),
                      ),
                      _buildSectionHeader('Recent Alerts'),
                      SizedBox(
                        height: responsive.getValue(
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),

                      _alertsLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _alerts.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                child: Text(
                                  'No alerts detected.',
                                  style: TextStyle(
                                    color: AppColors.getTextSecondary(context),
                                  ),
                                ),
                              ),
                            )
                          : ResponsiveGrid(
                              mobileColumns: 1,
                              tabletColumns: 1,
                              desktopColumns: 1,
                              spacing: responsive.getValue(
                                mobile: 12,
                                tablet: 16,
                                desktop: 20,
                              ),
                              runSpacing: responsive.getValue(
                                mobile: 12,
                                tablet: 16,
                                desktop: 20,
                              ),
                              children: _alerts.take(6).map((alert) {
                                final String alertType = alert['type'] ?? '';
                                IconData alertIcon =
                                    Icons.warning_amber_rounded;

                                if (alertType == 'temperature') {
                                  alertIcon = Icons.thermostat;
                                } else if (alertType == 'tank') {
                                  alertIcon = Icons.local_gas_station;
                                } else if (alertType == 'smoke') {
                                  alertIcon = Icons.warning_amber_rounded;
                                }

                                return AlertCard(
                                  title: alert['title'] ?? '',
                                  machine: alert['machine'] ?? '',
                                  location: alert['location'] ?? '',
                                  time: _formatTime(alert['time'] ?? ''),
                                  status: alert['status'] ?? '',
                                  statusColor: _getStatusColor(alert['status']),
                                  icon: alertIcon,
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkGreen
            : AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Critical':
        return AppColors.criticalRed;
      case 'Warning':
        return Colors.amber;
      case 'Resolved':
        return AppColors.primaryGreen;
      default:
        return AppColors.textSecondary;
    }
  }
}
