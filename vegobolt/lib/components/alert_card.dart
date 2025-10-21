import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AlertCard extends StatelessWidget {
  final String title;
  final String machine;
  final String location;
  final String time;
  final String status;
  final Color statusColor;
  final IconData icon;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.title,
    required this.machine,
    required this.location,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(left: BorderSide(color: statusColor, width: 5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        dense: true,
        visualDensity: VisualDensity.compact,
        onTap: onTap,
        leading: Icon(icon, color: statusColor, size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              'Machine: $machine',
              style: TextStyle(
                color: AppColors.getTextSecondary(context),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 12,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.getTextLight(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: statusColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
