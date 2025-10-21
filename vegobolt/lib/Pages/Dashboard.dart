import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/navbar.dart';
import '../components/alert_card.dart';
import '../components/header.dart';
import '../utils/colors.dart';
import '../utils/navigation_helper.dart';
import '../components/machine_status_card.dart';
import 'machine.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../providers/machine_provider.dart';

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

  // ✅ Get base URL for backend
  String _getBaseUrl() {
    // Change this based on your setup:
    // - 'web': Use localhost (Chrome/Web)
    // - 'emulator': Use 10.0.2.2 (Android Emulator)
    // - 'device': Use your PC's IP (192.168.100.28)
    // - 'ios': Use localhost (iOS Simulator)
    const mode = 'device'; // 👈 For Android device
    switch (mode) {
      case 'web':
        return 'http://localhost:3000';
      case 'emulator':
        return 'http://10.0.2.2:3000';
      case 'device':
        return 'http://192.168.100.49:3000'; // Your PC's IP
      case 'ios':
        return 'http://localhost:3000';
      default:
        return 'http://localhost:3000';
    }
  }

  // ✅ Fetch data from backend
  Future<void> fetchTankData() async {
    try {
      final response = await http.get(
        Uri.parse('${_getBaseUrl()}/api/tank/status'),
      ).timeout(const Duration(seconds: 3));

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
    bool hasCritical = alerts.any((alert) => 
      (alert['status'] ?? '').toString().toLowerCase() == 'critical'
    );
    
    if (hasCritical) {
      return 'critical';
    }

    // Check if any alert has Warning status
    bool hasWarning = alerts.any((alert) => 
      (alert['status'] ?? '').toString().toLowerCase() == 'warning'
    );
    
    if (hasWarning) {
      return 'warning';
    }

    return 'normal';
  }

  Future<void> fetchAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('${_getBaseUrl()}/api/tank/status'),
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String status = (data['status'] ?? '').toString();
        final int level = int.tryParse('${data['level'] ?? 0}') ?? 0;
        final String timeIso =
            (data['createdAt'] ?? DateTime.now().toIso8601String()).toString();

        final List<dynamic> derivedAlerts =
            (status.toLowerCase() == 'full' || level >= 90)
            ? [
                {
                  'title': 'Tank Full',
                  'machine': 'VB-0001',
                  'location': '-',
                  'time': timeIso,
                  'status': 'Critical',
                },
              ]
            : [];

        setState(() {
          _alerts = derivedAlerts;
          _currentAlertStatus = _determineAlertStatus(derivedAlerts);
          _alertsLoading = false;
        });
      } else {
        setState(() {
          _alertsLoading = false;
          _currentAlertStatus = 'critical';
          _alerts = [
            {
              'title': 'Tank Full',
              'machine': 'VB-0001',
              'location': '-',
              'time': DateTime.now().toIso8601String(),
              'status': 'Critical',
            },
          ];
        });
        print('❌ Failed to fetch alerts: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _alertsLoading = false;
        _currentAlertStatus = 'critical';
        _alerts = [
          {
            'title': 'Tank Full',
            'machine': 'VB-0001',
            'location': '-',
            'time': DateTime.now().toIso8601String(),
            'status': 'Critical',
          },
        ];
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
    
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) => _onNavTap(context, index),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor your VegoBolt system',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSectionHeader('Machine Status'),
                    const SizedBox(height: 12),

                    MachineStatusCard(
                      machineId: 'VB-0001',
                      initialLocation: 'Barangay 171',
                      statusText: machineProvider.statusText,
                      statusColor: machineProvider.statusColor,
                      tankLevel: tankLevel,
                      batteryValue: batteryValue,
                      temperatureC: temperatureC,
                      alertStatus: _currentAlertStatus,
                      onLocationChanged: (newLocation) {
                        print('Location updated to: $newLocation');
                      },
                    ),

                    const SizedBox(height: 12),
                    _buildSectionHeader('Recent Alerts'),
                    const SizedBox(height: 14),
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
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Text(
                                    'No alerts detected.',
                                    style: TextStyle(
                                      color: AppColors.getTextSecondary(context),
                                    ),
                                  ),
                                ),
                              )
                            : Column(
                                children: _alerts.take(3).map((alert) {
                                  return AlertCard(
                                    title: alert['title'] ?? '',
                                    machine: alert['machine'] ?? '',
                                    location: alert['location'] ?? '',
                                    time: alert['time'] ?? '',
                                    status: alert['status'] ?? '',
                                    statusColor: _getStatusColor(alert['status']),
                                    icon: Icons.local_gas_station,
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