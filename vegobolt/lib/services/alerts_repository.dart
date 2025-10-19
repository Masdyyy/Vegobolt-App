// Simple alerts repository used by Dashboard and Alerts pages.
// For now this exposes a static list. Replace with network/db source later.
import 'package:flutter/material.dart';

final List<Map<String, dynamic>> sampleAlerts = [
  {
    'title': 'Overheating Detected',
    'machine': 'VB-0001',
    'location': 'Barangay 171',
    'time': '5 minutes ago',
    'status': 'Critical',
    'color': Colors.red,
    'icon': Icons.error_outline,
  },
  {
    'title': 'Low Oil Level',
    'machine': 'VB-0002',
    'location': 'Barangay 171',
    'time': '5 minutes ago',
    'status': 'Warning',
    'color': Colors.orange,
    'icon': Icons.warning_amber_rounded,
  },
  {
    'title': 'Battery Replacement',
    'machine': 'VB-0001',
    'location': 'Barangay 171',
    'time': '2 days ago',
    'status': 'Resolved',
    'color': Colors.green,
    'icon': Icons.check_circle_outline,
  },
];
