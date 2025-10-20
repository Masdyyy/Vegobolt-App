import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MachineStatusCard extends StatelessWidget {
  final String machineId;
  final String location;
  final String statusText;
  final Color statusColor;
  final double tankLevel;
  final double batteryValue;
  final int temperatureC;

  const MachineStatusCard({
    super.key,
    required this.machineId,
    required this.location,
    required this.statusText,
    required this.statusColor,
    required this.tankLevel,
    required this.batteryValue,
    required this.temperatureC,
  });

  // Helper to get tank status string
  static String getTankStatus(double tankLevel) {
    if (tankLevel >= 0.9) {
      return 'Full';
    } else if (tankLevel >= 0.5) {
      return 'Normal';
    } else if (tankLevel > 0.0) {
      return 'Low';
    } else {
      return 'Empty';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.getTextSecondary(context),
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
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          // 🟩 Tank Status
          Row(
            children: [
              Icon(
                Icons.local_gas_station,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Tank: ${getTankStatus(tankLevel)}',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(tankLevel * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 🔋 Battery
          Row(
            children: [
              Icon(Icons.battery_full, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 6),
              Text(
                'Battery: ${(batteryValue * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 🌡️ Temperature
          Row(
            children: [
              Icon(Icons.thermostat, color: AppColors.primaryGreen, size: 20),
              const SizedBox(width: 6),
              Text(
                'Temperature: $temperatureC°C',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
