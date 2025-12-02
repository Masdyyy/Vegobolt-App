import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import '../utils/api_config.dart';
import '../components/alert_card.dart';
import '../utils/colors.dart';
import '../utils/navigation_helper.dart';
import '../utils/responsive_layout.dart';
import 'dashboard.dart';
import 'machine.dart';
import 'maintenance.dart';
import 'Settings.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  int _selectedTab = 0;
  List<dynamic> _alerts = [];
  bool _isLoading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
    // Auto-refresh every 5 seconds so alerts show without switching pages
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      fetchAlerts();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchAlerts() async {
    try {
      // Fetch alerts from the new alerts endpoint
      final baseUrl = _getBaseUrl();
      final response = await http.get(Uri.parse('$baseUrl/api/tank/alerts'));

      if (response.statusCode == 200) {
        final List<dynamic> alertsData = json.decode(response.body);

        if (!mounted) return;
        setState(() {
          _alerts = alertsData;
          _isLoading = false;
        });
        debugPrint('✅ Fetched alerts: ${_alerts.length}');
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        debugPrint('❌ Error: Status ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('❌ Error fetching alerts: $e');
    }
  }

  String _getBaseUrl() {
    return ApiConfig.baseUrl;
  }

  List<dynamic> get _filteredAlerts {
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

    NavigationHelper.navigateWithoutAnimation(context, destination);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveScaffold(
      title: 'Alerts',
      currentIndex: 2,
      onNavigationChanged: (index) => _onNavTap(context, index),
      navigationItems: const [
        NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
        NavigationItem(icon: Icons.precision_manufacturing, label: 'Machine'),
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
                      'Alerts',
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
                      'Monitor system notifications',
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
                      _buildTabs(),
                      SizedBox(
                        height: responsive.getValue(
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),
                      _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _filteredAlerts.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Text(
                                  'No alerts detected.',
                                  style: TextStyle(
                                    color: AppColors.getTextSecondary(context),
                                  ),
                                ),
                              ),
                            )
                          : ResponsiveGrid(
                              mobileColumns: 1,
                              tabletColumns: 1,
                              desktopColumns: 1,
                              spacing: responsive.getValue(
                                mobile: 12,
                                tablet: 16,
                                desktop: 20,
                              ),
                              runSpacing: responsive.getValue(
                                mobile: 12,
                                tablet: 16,
                                desktop: 20,
                              ),
                              children: _filteredAlerts.map((alert) {
                                final String alertType = alert['type'] ?? '';

                                IconData alertIcon =
                                    Icons.warning_amber_rounded;

                                if (alertType == 'temperature') {
                                  alertIcon = Icons.thermostat;
                                } else if (alertType == 'tank') {
                                  alertIcon = Icons.local_gas_station;
                                }

                                return AlertCard(
                                  title: alert['title'] ?? 'No title',
                                  machine: alert['machine'] ?? 'Unknown',
                                  location: alert['location'] ?? '-',
                                  time: _formatTime(alert['time'] ?? ''),
                                  status: alert['status'] ?? '',
                                  statusColor: _getStatusColor(alert['status']),
                                  icon: alertIcon,
                                );
                              }).toList(),
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

  String _formatTime(String isoTime) {
    if (isoTime.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(isoTime);
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return isoTime;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Critical':
        return Colors.red;
      case 'Warning':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildTabs() {
    final List<String> tabs = ['All', 'Critical', 'Warning', 'Resolved'];
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCardBackground
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextLight
              : AppColors.textLight,
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = _selectedTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkGreen
                            : AppColors.lightGreen)
                      : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkCardBackground
                            : Colors.white),
                  borderRadius: BorderRadius.horizontal(
                    left: index == 0 ? const Radius.circular(8) : Radius.zero,
                    right: index == tabs.length - 1
                        ? const Radius.circular(8)
                        : Radius.zero,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Colors.white
                        : AppColors.getTextSecondary(context),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
