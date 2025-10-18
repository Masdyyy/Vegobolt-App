import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/header.dart';
import '../components/machine_control_button.dart';
import '../utils/colors.dart';
import 'dashboard.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'settings.dart';

class MachinePage extends StatelessWidget {
  const MachinePage({super.key});

  void _onNavTap(BuildContext context, int index) {
    if (index == 1) return; // already in Machine page

    Widget destination;
    switch (index) {
      case 0:
        destination = const DashboardPage();
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
      body: SafeArea(
        child: Column(
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
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Machine Card
                    Container(
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
                          // Header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'VB-001',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Barangay 171',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.warningYellow,
                                  ),
                                ),
                                child: const Text(
                                  'Maintenance',
                                  style: TextStyle(
                                    color: AppColors.warningYellow,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Oil Tank
                          _buildProgressRow(
                            icon: Icons.local_gas_station,
                            label: "Oil Tank",
                            value: 1.0,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(height: 8),

                          // Battery
                          _buildProgressRow(
                            icon: Icons.battery_full,
                            label: "Battery",
                            value: 0.15,
                            color: AppColors.criticalRed,
                          ),
                          const SizedBox(height: 12),

                          // Temperature & Filter
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildTextRow(
                                  Icons.thermostat,
                                  "Temperature: 96°C",
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextRow(
                                  Icons.filter_alt,
                                  "Filter: 30%",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

                    _buildMaintenanceCard(
                      title: "Oil Refill",
                      level: "High",
                      color: AppColors.criticalRed,
                    ),
                    _buildMaintenanceCard(
                      title: "Filter Replacement",
                      level: "High",
                      color: AppColors.criticalRed,
                    ),
                    _buildMaintenanceCard(
                      title: "Battery Replacement",
                      level: "Medium",
                      color: AppColors.warningYellow,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: 1,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  Widget _buildProgressRow({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    int percent = (value * 100).round();
    Color percentColor;

    if (percent < 20) {
      percentColor = AppColors.criticalRed;
    } else if (percent < 50) {
      percentColor = AppColors.warningYellow;
    } else {
      percentColor = AppColors.primaryGreen;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: percentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: value,
                color: color,
                backgroundColor: color.withValues(alpha: 0.2),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceCard({
    required String title,
    required String level,
    required Color color,
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  level,
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "VB-001 - Barangay 171",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Icon(Icons.access_time, size: 14, color: AppColors.textLight),
              SizedBox(width: 4),
              Text(
                '5 minutes ago',
                style: TextStyle(color: AppColors.textLight),
              ),
              SizedBox(width: 12),
              Icon(Icons.person, size: 14, color: AppColors.textLight),
              SizedBox(width: 4),
              Text('John Lorezo', style: TextStyle(color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}
