import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/header.dart';
import '../components/alert_card.dart';
import '../utils/colors.dart';
import 'machine.dart';
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
                  _buildMachineStatusCard(context),
                  const SizedBox(height: 20),

                  // Recent Alerts Section
                  _buildSectionHeader('Recent Alert'),
                  const SizedBox(height: 12),
                  AlertCard(
                    title: 'Overheating Detected',
                    machine: 'VB-0001',
                    location: 'Barangay 171',
                    time: '5 minutes ago',
                    status: 'Critical',
                    statusColor: AppColors.criticalRed,
                    icon: Icons.error_outline,
                  ),
                  AlertCard(
                    title: 'Low Oil Level',
                    machine: 'VB-0002',
                    location: 'Barangay 171',
                    time: '5 minutes ago',
                    status: 'Warning',
                    statusColor: AppColors.warningYellow,
                    icon: Icons.warning_amber_rounded,
                  ),
                  AlertCard(
                    title: 'Battery Replacement',
                    machine: 'VB-0001',
                    location: 'Barangay 171',
                    time: '2 days ago',
                    status: 'Resolved',
                    statusColor: AppColors.resolvedGreen,
                    icon: Icons.check_circle_outline,
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

  Widget _buildMachineStatusCard(BuildContext context) {
    return Container(
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
              const Row(
                children: [
                  Text(
                    'VB-0001',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGreen),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Barangay 171',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Oil Tank
          _buildProgressRow(
            icon: Icons.local_gas_station,
            label: "Oil Tank",
            value: 1.0,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: 12),

          // Battery
          _buildProgressRow(
            icon: Icons.battery_full,
            label: "Battery",
            value: 0.15,
            color: AppColors.criticalRed,
          ),
          const SizedBox(height: 12),

          // Filter
          _buildProgressRow(
            icon: Icons.filter_alt,
            label: "Filter",
            value: 0.30,
            color: AppColors.warningYellow,
          ),
          const SizedBox(height: 16),

          // Temperature
          Row(
            children: [
              const Icon(
                Icons.thermostat,
                size: 20,
                color: AppColors.criticalRed,
              ),
              const SizedBox(width: 6),
              const Text(
                'Temperature',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '96°C',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.criticalRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rating section
          Row(
            children: [
              const Text(
                '4.1',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < 4 ? Icons.star : Icons.star_border,
                    color: AppColors.warningYellow,
                    size: 18,
                  );
                }),
              ),
              const SizedBox(width: 8),
              const Text(
                '2.6K ratings',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
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
}
