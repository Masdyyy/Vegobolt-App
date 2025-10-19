import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/header.dart';
// alert_card import removed — no alerts displayed on Dashboard
import '../utils/colors.dart';
import 'machine.dart';
import '../components/machine_status_card.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'settings.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _onNavTap(BuildContext context, int index) {
    if (index == 0) return; // already in Dashboard page

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
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Monitor your VegoBolt system',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Machine Status Section
                  _buildSectionHeader('Machine Status'),
                  const SizedBox(height: 12),
                  const MachineStatusCard(
                    machineId: 'VB-0001',
                    location: 'Barangay 171',
                    statusText: 'Active',
                    statusColor: AppColors.primaryGreen,
                    oilValue: 0,
                    batteryValue: 0,
                    temperatureC: 0,
                  ),
                  const SizedBox(height: 20),

                  // Recent Alerts Section
                  _buildSectionHeader('Recent Alert'),
                  const SizedBox(height: 12),
                  // No alerts (empty state)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'No alerts detected.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
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
        color: AppColors.primaryGreen,
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

  // Machine card replaced by MachineStatusCard component
}
