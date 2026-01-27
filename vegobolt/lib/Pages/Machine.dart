import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../utils/colors.dart';
import '../utils/navigation_helper.dart';
import '../utils/responsive_layout.dart';
import 'dashboard.dart';
import '../components/machine_status_card.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'Settings.dart';
import '../providers/machine_provider.dart';

class MachinePage extends StatefulWidget {
  const MachinePage({super.key});

  @override
  State<MachinePage> createState() => _MachinePageState();
}

class _MachinePageState extends State<MachinePage> {
  List<Map<String, dynamic>> scheduledMaintenanceItems = [];

  // Live data (same approach as Dashboard)
  double tankLevel = 0.0;
  double batteryValue = 0.0;
  int temperatureC = 0;
  bool isLoading = true;
  Timer? _pollTimer;
  String _currentAlertStatus = 'normal'; // Track current alert status

  // Tank states
  bool isOilTankOpen = true;
  bool isDieselTankOpen = true;

  @override
  void initState() {
    super.initState();
    fetchTankData();
    fetchAlerts();
    // Auto-refresh every 5 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      fetchTankData();
      fetchAlerts();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // Get base URL from centralized config
  String _getBaseUrl() {
    return ApiConfig.baseUrl;
  }

  Future<void> fetchTankData() async {
    try {
      final response = await http
          .get(Uri.parse('${_getBaseUrl()}/api/tank/status'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final int level = int.tryParse('${data['level'] ?? 0}') ?? 0;
        final double temperature =
            double.tryParse('${data['temperature'] ?? 0}') ?? 0.0;
        final int battery = int.tryParse('${data['batteryLevel'] ?? 0}') ?? 0;
        if (!mounted) return;
        setState(() {
          tankLevel = (level.clamp(0, 100)) / 100.0;
          batteryValue = (battery.clamp(0, 100)) / 100.0;
          temperatureC = temperature.round(); // Convert to int for display
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        _useFallbackData();
      }
    } catch (e) {
      if (!mounted) return;
      _useFallbackData();
    }
  }

  void _useFallbackData() {
    setState(() {
      tankLevel = 1.0; // 100%
      batteryValue = 0.15; // 15%
      temperatureC = 96;
      isLoading = false;
    });
  }

  // ✅ Determine alert status based on recent alerts
  String _determineAlertStatus(List<dynamic> alerts) {
    if (alerts.isEmpty) {
      return 'normal';
    }

    // Check if any alert has Critical status (highest priority)
    bool hasCritical = alerts.any(
      (alert) => (alert['status'] ?? '').toString().toLowerCase() == 'critical',
    );

    if (hasCritical) {
      return 'critical';
    }

    // Check if any alert has Warning status
    bool hasWarning = alerts.any(
      (alert) => (alert['status'] ?? '').toString().toLowerCase() == 'warning',
    );

    if (hasWarning) {
      return 'warning';
    }

    return 'normal';
  }

  Future<void> fetchAlerts() async {
    try {
      final response = await http
          .get(Uri.parse('${_getBaseUrl()}/api/tank/status'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String status = (data['status'] ?? '').toString();
        final int level = int.tryParse('${data['level'] ?? 0}') ?? 0;
        final String timeIso =
            (data['createdAt'] ?? DateTime.now().toIso8601String()).toString();

        final List<dynamic> derivedAlerts =
            (status.toLowerCase() == 'full' || level >= 90)
            ? [
                {
                  'title': 'Tank Full',
                  'machine': 'VB-0001',
                  'location': '-',
                  'time': timeIso,
                  'status': 'Critical',
                },
              ]
            : [];

        setState(() {
          _currentAlertStatus = _determineAlertStatus(derivedAlerts);
        });
      } else {
        setState(() {
          _currentAlertStatus = 'critical';
        });
        print('❌ Failed to fetch alerts: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _currentAlertStatus = 'critical';
      });
      print('⚠️ Error fetching alerts: $e');
    }
  }

  void _onNavTap(BuildContext context, int index) async {
    if (index == 1) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const DashboardPage();
        break;
      case 2:
        destination = const AlertsPage();
        break;
      case 3:
        // Pass current items to maintenance page and get updated items back
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MaintenancePage(
              initialScheduledItems: scheduledMaintenanceItems,
            ),
          ),
        );
        // Update items if we received data back
        if (result != null && result is List<Map<String, dynamic>>) {
          setState(() {
            scheduledMaintenanceItems = result;
          });
        }
        return; // Don't use pushReplacement for maintenance page
      case 4:
        destination = const SettingsPage();
        break;
      default:
        destination = const DashboardPage();
    }

    NavigationHelper.navigateWithoutAnimation(context, destination);
  }

  void _showShutdownConfirmation(BuildContext context) {
    final machineProvider = Provider.of<MachineProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.getCardBackground(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.criticalRed.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.power_settings_new,
                      size: 40,
                      color: AppColors.criticalRed,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Shutdown Machine',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message
                  Text(
                    'Are you sure you want to shutdown this station? This will stop all operations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondary(context),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: AppColors.getTextSecondary(
                                context,
                              ).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            machineProvider.shutdown();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 12),
                                    Text('Machine shutdown successfully'),
                                  ],
                                ),
                                backgroundColor: AppColors.criticalRed,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.criticalRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Shutdown',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showActivateConfirmation(BuildContext context) {
    final machineProvider = Provider.of<MachineProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.getCardBackground(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.power_rounded,
                      size: 40,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Activate Machine',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Message
                  Text(
                    'Are you sure you want to activate this station? This will start all operations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondary(context),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: AppColors.getTextSecondary(
                                context,
                              ).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            machineProvider.activate();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 12),
                                    Text('Machine activated successfully'),
                                  ],
                                ),
                                backgroundColor: AppColors.primaryGreen,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Activate',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final machineProvider = Provider.of<MachineProvider>(context);
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveScaffold(
      title: 'Tanks',
      currentIndex: 1,
      onNavigationChanged: (index) => _onNavTap(context, index),
      navigationItems: const [
        NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
        NavigationItem(icon: Icons.oil_barrel, label: 'Tanks'),
        NavigationItem(icon: Icons.warning_amber, label: 'Alerts'),
        NavigationItem(icon: Icons.build, label: 'Maintenance'),
        NavigationItem(icon: Icons.settings, label: 'Settings'),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
              isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: ResponsiveLayout(
          maxWidth: 1600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page header at the top
              Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.getPadding(),
                  responsive.getValue(mobile: 16, tablet: 20, desktop: 24),
                  responsive.getPadding(),
                  responsive.getValue(mobile: 12, tablet: 16, desktop: 20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanks',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: responsive.getValue(
                              mobile: 28,
                              tablet: 32,
                              desktop: 36,
                            ),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Control your VegoBolt tanks remotely',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.getTextSecondary(context),
                        fontSize: responsive.getValue(
                          mobile: 14,
                          tablet: 15,
                          desktop: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(responsive.getPadding()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Machine Control Card with Tank Buttons
                      _buildMachineControlCard(
                        context: context,
                        responsive: responsive,
                      ),

                      SizedBox(
                        height: responsive.getValue(
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                        ),
                      ),

                      _buildSectionHeader('Scheduled Maintenance'),
                      const SizedBox(height: 16),

                      if (scheduledMaintenanceItems.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Text(
                              'No scheduled maintenance',
                              style: TextStyle(
                                color: AppColors.getTextSecondary(context),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      else
                        ResponsiveGrid(
                          mobileColumns: 1,
                          tabletColumns: 2,
                          desktopColumns: 3,
                          spacing: 16,
                          runSpacing: 16,
                          children: scheduledMaintenanceItems
                              .map(
                                (item) => _buildMaintenanceCard(
                                  title: item['title'],
                                  machineId: item['machineId'],
                                  location: item['location'],
                                  scheduledDate: item['scheduledDate'],
                                  priority: item['priority'],
                                  priorityColor: item['priorityColor'],
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMachineControlCard({
    required BuildContext context,
    required ResponsiveHelper responsive,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: _currentAlertStatus == 'critical'
                ? AppColors.criticalRed
                : _currentAlertStatus == 'warning'
                ? const Color(0xFFF59E0B)
                : AppColors.primaryGreen,
            width: 5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with warning icon, machine ID and status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Warning icon and info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Warning icon and Machine ID row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Warning triangle icon
                          Icon(
                            Icons.warning_amber_rounded,
                            color: _currentAlertStatus == 'critical'
                                ? AppColors.criticalRed
                                : _currentAlertStatus == 'warning'
                                ? const Color(0xFFF59E0B)
                                : AppColors.primaryGreen,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          // Machine ID
                          Expanded(
                            child: Text(
                              'VB-0001',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextPrimary(context),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Location row
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.getTextSecondary(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Baranggay 171',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextSecondary(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Timestamp row
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_outlined,
                            size: 16,
                            color: AppColors.getTextLight(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '5 minutes ago',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.getTextLight(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Warning status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _currentAlertStatus == 'critical'
                          ? AppColors.criticalRed
                          : _currentAlertStatus == 'warning'
                          ? const Color(0xFFF59E0B)
                          : AppColors.primaryGreen,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _currentAlertStatus == 'critical'
                        ? 'Warning'
                        : _currentAlertStatus == 'warning'
                        ? 'Warning'
                        : 'Normal',
                    style: TextStyle(
                      color: _currentAlertStatus == 'critical'
                          ? AppColors.criticalRed
                          : _currentAlertStatus == 'warning'
                          ? const Color(0xFFF59E0B)
                          : AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Tank control buttons
            Row(
              children: [
                // Oil Tank Button
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isOilTankOpen = !isOilTankOpen;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOilTankOpen
                            ? AppColors.primaryGreen
                            : isDark
                            ? Colors.grey[700]
                            : const Color(0xFFE5E7EB),
                        foregroundColor: isOilTankOpen
                            ? Colors.white
                            : AppColors.getTextSecondary(context),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isOilTankOpen ? 'Oil Tank - Open' : 'Oil Tank - Closed',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Diesel Tank Button
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isDieselTankOpen = !isDieselTankOpen;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDieselTankOpen
                            ? const Color(0xFFFFD700)
                            : isDark
                            ? Colors.grey[700]
                            : const Color(0xFFE5E7EB),
                        foregroundColor: isDieselTankOpen
                            ? Colors.white
                            : AppColors.getTextSecondary(context),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isDieselTankOpen
                              ? 'Diesel Tank - Open'
                              : 'Diesel Tank - Closed',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkGreen : AppColors.primaryGreen,
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

  Widget _buildMaintenanceCard({
    required String title,
    required String machineId,
    required String location,
    required DateTime? scheduledDate,
    required String priority,
    required Color priorityColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$machineId • $location',
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: AppColors.getTextLight(context),
              ),
              const SizedBox(width: 4),
              Text(
                scheduledDate != null
                    ? '${scheduledDate.month.toString().padLeft(2, '0')}/${scheduledDate.day.toString().padLeft(2, '0')}/${scheduledDate.year}'
                    : 'Not scheduled',
                style: TextStyle(
                  color: AppColors.getTextLight(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
