import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MachineStatusCard extends StatefulWidget {
  final String machineId;
  final String initialLocation;
  final String statusText;
  final Color statusColor;
  final double tankLevel;
  final double batteryValue;
  final int temperatureC;
  final String alertStatus; // 'normal', 'warning', 'critical'
  final Function(String)? onLocationChanged;
  final bool isEditable; // New parameter to control if location is editable

  const MachineStatusCard({
    super.key,
    required this.machineId,
    required this.initialLocation,
    required this.statusText,
    required this.statusColor,
    required this.tankLevel,
    required this.batteryValue,
    required this.temperatureC,
    this.alertStatus = 'normal',
    this.onLocationChanged,
    this.isEditable = true, // Default to editable for backward compatibility
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
  State<MachineStatusCard> createState() => _MachineStatusCardState();
}

class _MachineStatusCardState extends State<MachineStatusCard> {
  late String currentLocation;
  bool isEditingLocation = false;
  late TextEditingController locationController;

  @override
  void initState() {
    super.initState();
    currentLocation = widget.initialLocation;
    locationController = TextEditingController(text: currentLocation);
  }

  @override
  void didUpdateWidget(MachineStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update location when it changes from provider
    if (oldWidget.initialLocation != widget.initialLocation) {
      setState(() {
        currentLocation = widget.initialLocation;
        locationController.text = widget.initialLocation;
      });
    }
  }

  void _saveLocation() {
    setState(() {
      currentLocation = locationController.text;
      isEditingLocation = false;
    });
    widget.onLocationChanged?.call(locationController.text);
  }

  void _cancelEditLocation() {
    locationController.text = currentLocation;
    setState(() {
      isEditingLocation = false;
    });
  }

  Widget _buildAlertBadge() {
    if (widget.alertStatus == 'normal') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey, width: 2),
          color: Colors.transparent,
        ),
        child: const Text(
          'Normal',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (widget.alertStatus == 'warning') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber, width: 2),
          color: Colors.transparent,
        ),
        child: const Text(
          'Warning',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (widget.alertStatus == 'critical') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.criticalRed, width: 2),
          color: Colors.transparent,
        ),
        child: Text(
          'Critical',
          style: TextStyle(
            color: AppColors.criticalRed,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
          // Header Row: Machine ID + Active Badge + Alert Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.machineId,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status Badge (Active/Offline)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: widget.statusText == 'Active'
                          ? AppColors.primaryGreen
                          : Colors.grey,
                    ),
                    child: Text(
                      widget.statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              // Alert Status Badge (Normal, Warning, or Critical)
              _buildAlertBadge(),
            ],
          ),
          const SizedBox(height: 12),
          // Location + Edit Icon (Inline Editing) - Only show edit when isEditable is true
          isEditingLocation
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          hintText: 'Enter location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        style: TextStyle(
                          color: AppColors.getTextPrimary(context),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _saveLocation,
                      child: Icon(
                        Icons.check_circle,
                        size: 24,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _cancelEditLocation,
                      child: Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: AppColors.criticalRed,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 18,
                      color: AppColors.getTextSecondary(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentLocation,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Only show edit button if isEditable is true
                    if (widget.isEditable)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isEditingLocation = true;
                          });
                        },
                        child: Icon(
                          Icons.edit,
                          size: 18,
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                  ],
                ),
          const SizedBox(height: 16),
          // Tank Status with Progress Bar
          Row(
            children: [
              Icon(
                Icons.water_drop,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Tank:',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${(widget.tankLevel * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: widget.tankLevel.clamp(0.0, 1.0),
            color: AppColors.primaryGreen,
            backgroundColor: Colors.grey.withOpacity(0.2),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 14),
          // Battery Status with Progress Bar
          Row(
            children: [
              Icon(
                Icons.battery_full,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Battery:',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${(widget.batteryValue * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: widget.batteryValue.clamp(0.0, 1.0),
            color: Colors.red,
            backgroundColor: Colors.grey.withOpacity(0.2),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 14),
          // Temperature
          Row(
            children: [
              Icon(
                Icons.thermostat,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Temperature',
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.temperatureC}°C',
                style: const TextStyle(
                  color: Colors.red,
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
