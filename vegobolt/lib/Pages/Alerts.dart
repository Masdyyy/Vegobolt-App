import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import '../components/navbar.dart';
import '../components/header.dart';
import '../components/alert_card.dart';
import '../utils/colors.dart';
import 'dashboard.dart';
import 'machine.dart';
import 'maintenance.dart';
import 'settings.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  int _selectedTab = 0;
  List<dynamic> _alerts = [];
  bool _isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
    // Auto-refresh every 5 seconds so alerts show without switching pages
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      fetchAlerts();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchAlerts() async {
    try {
      // Fetch alerts from the new alerts endpoint
      final baseUrl = _getBaseUrl();
      final response = await http.get(Uri.parse('$baseUrl/api/tank/alerts'));

      if (response.statusCode == 200) {
        final List<dynamic> alertsData = json.decode(response.body);

        if (!mounted) return;
        setState(() {
          _alerts = alertsData;
          _isLoading = false;
        });
        debugPrint('✅ Fetched alerts: ${_alerts.length}');
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        debugPrint('❌ Error: Status ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('❌ Error fetching alerts: $e');
    }
  }

  String _getBaseUrl() {
    // Change this based on your setup:
    // - 'web': Use localhost (Chrome/Web)
    // - 'emulator': Use 10.0.2.2 (Android Emulator)
    // - 'device': Use your PC's IP (192.168.100.28)
    // - 'ios': Use localhost (iOS Simulator)
    const mode = 'device'; // 👈 CHANGE THIS!

    switch (mode) {
      case 'web':
        return 'http://localhost:3000'; // For Chrome/Web
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

  List<dynamic> get _filteredAlerts {
    switch (_selectedTab) {
      case 1:
        return _alerts.where((a) => a['status'] == 'Critical').toList();
      case 2:
        return _alerts.where((a) => a['status'] == 'Warning').toList();
      case 3:
        return _alerts.where((a) => a['status'] == 'Resolved').toList();
      default:
        return _alerts;
    }
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 2) return;
    Widget destination;
    switch (index) {
      case 0:
        destination = const DashboardPage();
        break;
      case 1:
        destination = const MachinePage();
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
      bottomNavigationBar: NavBar(
        currentIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alerts',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor system notifications',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTabs(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _filteredAlerts.isEmpty
                          ? const Center(
                              child: Text(
                                'No alerts detected.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredAlerts.length,
                              itemBuilder: (context, index) {
                                final alert = _filteredAlerts[index];
                                final String alertType = alert['type'] ?? '';

                                IconData alertIcon =
                                    Icons.warning_amber_rounded;

                                if (alertType == 'temperature') {
                                  alertIcon = Icons.thermostat;
                                } else if (alertType == 'tank') {
                                  alertIcon = Icons.local_gas_station;
                                }

                                return AlertCard(
                                  title: alert['title'] ?? 'No title',
                                  machine: alert['machine'] ?? 'Unknown',
                                  location: alert['location'] ?? '-',
                                  time: _formatTime(alert['time'] ?? ''),
                                  status: alert['status'] ?? '',
                                  statusColor: _getStatusColor(alert['status']),
                                  icon: alertIcon,
                                );
                              },
                            ),
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

  String _formatTime(String isoTime) {
    if (isoTime.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(isoTime);
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return isoTime;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Critical':
        return Colors.red;
      case 'Warning':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildTabs() {
    final List<String> tabs = ['All', 'Critical', 'Warning', 'Resolved'];
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCardBackground
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextLight
              : AppColors.textLight,
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = _selectedTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkGreen
                            : AppColors.lightGreen)
                      : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkCardBackground
                            : Colors.white),
                  borderRadius: BorderRadius.horizontal(
                    left: index == 0 ? const Radius.circular(8) : Radius.zero,
                    right: index == tabs.length - 1
                        ? const Radius.circular(8)
                        : Radius.zero,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Colors.white
                        : AppColors.getTextSecondary(context),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
