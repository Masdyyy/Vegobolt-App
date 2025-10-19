import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/alert_card.dart';
import '../components/header.dart';
import '../utils/colors.dart';
import '../components/machine_status_card.dart';
import 'machine.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

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
        return 'http://192.168.100.28:3000'; // Your PC's IP
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
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final int level = int.tryParse('${data['level'] ?? 0}') ?? 0;
        final int temperature =
            int.tryParse('${data['temperature'] ?? 0}') ?? 0;
        final int battery = int.tryParse('${data['batteryLevel'] ?? 0}') ?? 0;

        setState(() {
          tankLevel = level / 100.0; // percentage -> 0..1
          batteryValue = battery / 100.0;
          temperatureC = temperature;
          isLoading = false;
        });
      } else {
        print('❌ Failed to fetch tank data: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error fetching tank data: $e');
    }
  }

  Future<void> fetchAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('${_getBaseUrl()}/api/tank/status'),
      );
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
          _alertsLoading = false;
        });
      } else {
        setState(() => _alertsLoading = false);
        print('❌ Failed to fetch alerts: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _alertsLoading = false);
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildSectionHeader('Machine Status'),
                        const SizedBox(height: 12),

                        MachineStatusCard(
                          machineId: 'VB-0001',
                          location: 'Barangay 171',
                          statusText: tankLevel >= 0.9 ? 'Full' : 'Normal',
                          statusColor: tankLevel >= 0.9
                              ? AppColors.criticalRed
                              : AppColors.primaryGreen,
                          tankLevel: tankLevel,
                          batteryValue: batteryValue,
                          temperatureC: temperatureC,
                        ),

                        const SizedBox(height: 20),
                        _buildSectionHeader('Recent Alerts'),
                        const SizedBox(height: 12),
                        _alertsLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _alerts.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.0),
                                  child: Text(
                                    'No alerts detected.',
                                    style: TextStyle(
                                      color: AppColors.getTextSecondary(
                                        context,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _alerts.length,
                                itemBuilder: (context, index) {
                                  final alert = _alerts[index];
                                  return AlertCard(
                                    title: alert['title'] ?? 'No title',
                                    machine: alert['machine'] ?? 'Unknown',
                                    location: alert['location'] ?? '-',
                                    time: alert['time'] ?? '',
                                    status: alert['status'] ?? '',
                                    statusColor: Colors.orange,
                                    icon: Icons.warning_amber_rounded,
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 0,
        onTap: (index) => _onNavTap(context, index),
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
}
