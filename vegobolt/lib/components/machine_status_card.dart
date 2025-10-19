import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MachineStatusCard extends StatelessWidget {
  final String machineId;
  final String location;
  final String statusText;
  final Color statusColor;
  final double tankLevel; // 0.0 - 1.0
  final double batteryValue; // 0.0 - 1.0
  final int temperatureC;

  const MachineStatusCard({
    super.key,
    required this.machineId,
    required this.location,
    this.statusText = 'Active',
    this.statusColor = AppColors.primaryGreen,
    this.tankLevel = 0.0,
    this.batteryValue = 0.0,
    this.temperatureC = 0,
  });

  // Determine textual status of tank
  String getTankStatus(double value) {
    if (value >= 0.9) return 'Full';
    if (value <= 0.2) return 'Low';
    return 'Normal';
  }

  // Determine color based on tank level
  Color getTankColor(double value) {
    if (value >= 0.9) return AppColors.primaryGreen;
    if (value <= 0.2) return AppColors.criticalRed;
    return AppColors.warningYellow;
  }

  @override
  Widget build(BuildContext context) {
    String tankStatus = getTankStatus(tankLevel);
    Color tankColor = getTankColor(tankLevel);

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    machineId,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
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
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                  color: statusColor.withOpacity(0.1),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            location,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // 🟩 Tank Status
          Row(
            children: [
              const Icon(
                Icons.local_gas_station,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tank Status',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          tankStatus,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tankColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: tankLevel.clamp(0.0, 1.0),
                      color: tankColor,
                      backgroundColor: tankColor.withOpacity(0.2),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tank Level: ${(tankLevel * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔋 Battery
          _buildProgressRow(
            icon: Icons.battery_full,
            label: 'Battery',
            value: batteryValue,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: 12),

          // 🌡 Temperature
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
                '$temperatureC°C',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.criticalRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shared progress row for things like battery
  Widget _buildProgressRow({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    int percent = (value * 100).round().clamp(0, 100);
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
                value: value.clamp(0.0, 1.0),
                color: color,
                backgroundColor: color.withOpacity(0.2),
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
