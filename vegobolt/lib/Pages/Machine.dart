import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../components/navbar.dart';
import '../components/header.dart';
import '../components/machine_control_button.dart';
import '../utils/colors.dart';
import 'dashboard.dart';
import '../components/machine_status_card.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'settings.dart';

class MachinePage extends StatefulWidget {
  const MachinePage({super.key});

  @override
  State<MachinePage> createState() => _MachinePageState();
}

class _MachinePageState extends State<MachinePage> {
  List<Map<String, dynamic>> scheduledMaintenanceItems = [];

  // Live data (same approach as Dashboard)
  double tankLevel = 0.0;
  double batteryValue = 0.0;
  int temperatureC = 0;
  bool isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    fetchTankData();
    // Auto-refresh every 5 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      fetchTankData();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // Match Dashboard's base URL logic
  String _getBaseUrl() {
    const mode = 'device'; // For Android device testing
    switch (mode) {
      case 'web':
        return 'http://localhost:3000';
      case 'emulator':
        return 'http://10.0.2.2:3000';
      case 'device':
        return 'http://192.168.100.28:3000';
      case 'ios':
        return 'http://localhost:3000';
      default:
        return 'http://localhost:3000';
    }
  }

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
        if (!mounted) return;
        setState(() {
          tankLevel = (level.clamp(0, 100)) / 100.0;
          batteryValue = (battery.clamp(0, 100)) / 100.0;
          temperatureC = temperature;
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _onNavTap(BuildContext context, int index) async {
    if (index == 1) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const DashboardPage();
        break;
      case 2:
        destination = const AlertsPage();
        break;
      case 3:
        // Pass current items to maintenance page and get updated items back
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MaintenancePage(
              initialScheduledItems: scheduledMaintenanceItems,
            ),
          ),
        );
        // Update items if we received data back
        if (result != null && result is List<Map<String, dynamic>>) {
          setState(() {
            scheduledMaintenanceItems = result;
          });
        }
        return; // Don't use pushReplacement for maintenance page
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
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Machine',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Control your VEGOBOLT station remotely',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Live Machine Card (same data as Dashboard)
                  MachineStatusCard(
                    machineId: 'VB-001',
                    location: 'Barangay 171',
                    statusText: 'Maintenance',
                    statusColor: AppColors.warningYellow,
                    tankLevel: tankLevel,
                    batteryValue: batteryValue,
                    temperatureC: temperatureC,
                  ),

                  const SizedBox(height: 16),

                  // Buttons
                  MachineControlButton(
                    label: 'Restart Station',
                    icon: Icons.restart_alt,
                    color: AppColors.darkGreen,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 12),
                  MachineControlButton(
                    label: 'Shutdown Station',
                    icon: Icons.power_settings_new,
                    color: AppColors.criticalRed,
                    onPressed: () {},
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Scheduled Maintenance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Display maintenance items or empty state
                  if (scheduledMaintenanceItems.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'No scheduled maintenance',
                          style: TextStyle(
                            color: Color(0xFF808080),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ...scheduledMaintenanceItems.map(
                      (item) => _buildMaintenanceCard(
                        title: item['title'],
                        machineId: item['machineId'],
                        location: item['location'],
                        scheduledDate: item['scheduledDate'],
                        priority: item['priority'],
                        priorityColor: item['priorityColor'],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 1,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  Widget _buildMaintenanceCard({
    required String title,
    required String machineId,
    required String location,
    required DateTime? scheduledDate,
    required String priority,
    required Color priorityColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$machineId • $location',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                scheduledDate != null
                    ? '${scheduledDate.month.toString().padLeft(2, '0')}/${scheduledDate.day.toString().padLeft(2, '0')}/${scheduledDate.year}'
                    : 'Not scheduled',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
