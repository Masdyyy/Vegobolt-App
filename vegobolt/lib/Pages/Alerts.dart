import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/header.dart';
import '../components/alert_card.dart';
import '../utils/Colors.dart';
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

  // Alerts list (empty initially)
  final List<Map<String, dynamic>> _alerts = [];

  List<Map<String, dynamic>> get _filteredAlerts {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
                    // Title
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alerts',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Monitor system notifications',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search alerts...',
                        hintStyle: const TextStyle(color: AppColors.textLight),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🟨 Tabs
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.textLight,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildTab(0, 'All', isFirst: true),
                          _buildTab(1, 'Critical'),
                          _buildTab(2, 'Warning'),
                          _buildTab(3, 'Resolved', isLast: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 📋 Alert List
                    Expanded(
                      child: _filteredAlerts.isEmpty
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
                                return AlertCard(
                                  title: alert['title'],
                                  machine: alert['machine'],
                                  location: alert['location'],
                                  time: alert['time'],
                                  status: alert['status'],
                                  statusColor: alert['color'],
                                  icon: alert['icon'],
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

  Widget _buildTab(
    int index,
    String text, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? AppColors.warningYellow : Colors.white,
            border: Border(right: BorderSide(color: AppColors.textLight)),
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? const Radius.circular(8) : Radius.zero,
              right: isLast ? const Radius.circular(8) : Radius.zero,
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
