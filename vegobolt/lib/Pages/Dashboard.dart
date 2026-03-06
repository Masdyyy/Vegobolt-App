import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/alert_card.dart';
import '../utils/colors.dart';
import '../utils/navigation_helper.dart';
import '../utils/responsive_layout.dart';
import '../components/machine_status_card.dart';
import 'machine.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'Settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import '../providers/machine_provider.dart';
import '../utils/api_config.dart';
// removed modal import — location is displayed inline
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double tankLevel = 0.0;
  double batteryValue = 0.0;
  int temperatureC = 0;
  bool isLoading = true;
  List<dynamic> _alerts = [];
  bool _alertsLoading = true;
  Timer? _pollTimer;
  String _currentAlertStatus = 'normal'; // Track current alert status
  bool _isFabHovering = false;
  String _detectedBarangay = '';

  @override
  void initState() {
    super.initState();
    fetchTankData();
    fetchAlerts();
    // Auto-refresh alerts every 5 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      fetchAlerts();
      fetchTankData();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // ✅ Get base URL from centralized config
  String _getBaseUrl() {
    return ApiConfig.baseUrl;
  }

  // Format ISO timestamp to readable format
  String _formatTime(String isoTime) {
    if (isoTime.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(isoTime);
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return isoTime;
    }
  }

  // ✅ Fetch data from backend
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

        setState(() {
          tankLevel = level / 100.0; // percentage -> 0..1
          batteryValue = battery / 100.0;
          temperatureC = temperature.round(); // Convert to int for display
          isLoading = false;
        });
      } else {
        print('❌ Failed to fetch tank data: ${response.statusCode}');
        _useFallbackData();
      }
    } catch (e) {
      print('⚠️ Error fetching tank data: $e');
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

  Future<String> _getCurrentLocationString() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return 'Location permission denied';
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));

      try {
        final places = await placemarkFromCoordinates(
          pos.latitude, 
          pos.longitude,
        ).timeout(const Duration(seconds: 10));
        
        if (places.isNotEmpty) {
          final p = places.first;
          
          // Debug: print ALL placemark fields
          print('=== Geocoding Debug ===');
          print('subLocality: ${p.subLocality}');
          print('locality: ${p.locality}');
          print('subAdministrativeArea: ${p.subAdministrativeArea}');
          print('administrativeArea: ${p.administrativeArea}');
          print('thoroughfare: ${p.thoroughfare}');
          print('subThoroughfare: ${p.subThoroughfare}');
          print('name: ${p.name}');
          print('street: ${p.street}');
          print('country: ${p.country}');
          print('postalCode: ${p.postalCode}');
          print('======================');

          // Priority 1: Try subLocality (typical barangay field)
          if (p.subLocality != null && p.subLocality!.trim().isNotEmpty) {
            return p.subLocality!.trim();
          }
          
          // Priority 2: Try thoroughfare or street (may contain barangay)
          if (p.street != null && p.street!.trim().isNotEmpty) {
            return p.street!.trim();
          }
          if (p.thoroughfare != null && p.thoroughfare!.trim().isNotEmpty) {
            return p.thoroughfare!.trim();
          }
          
          // Priority 3: Try locality (city/municipality)
          if (p.locality != null && p.locality!.trim().isNotEmpty) {
            // If we have subAdministrativeArea, combine them
            if (p.subAdministrativeArea != null && p.subAdministrativeArea!.trim().isNotEmpty) {
              return '${p.locality!.trim()}, ${p.subAdministrativeArea!.trim()}';
            }
            return p.locality!.trim();
          }
          
          // Priority 4: Try subAdministrativeArea (district)
          if (p.subAdministrativeArea != null && p.subAdministrativeArea!.trim().isNotEmpty) {
            return p.subAdministrativeArea!.trim();
          }
          
          // Priority 5: Try administrativeArea (province/state)
          if (p.administrativeArea != null && p.administrativeArea!.trim().isNotEmpty) {
            if (p.country != null && p.country!.trim().isNotEmpty) {
              return '${p.administrativeArea!.trim()}, ${p.country!.trim()}';
            }
            return p.administrativeArea!.trim();
          }
          
          // Priority 6: Try name field
          if (p.name != null && p.name!.trim().isNotEmpty && p.name != '${pos.latitude}, ${pos.longitude}') {
            return p.name!.trim();
          }
          
          // Priority 7: Build from any available parts
          final parts = [
            p.subLocality,
            p.street,
            p.thoroughfare,
            p.locality,
            p.subAdministrativeArea,
            p.administrativeArea,
            p.country,
          ].where((s) => s != null && s.trim().isNotEmpty).map((s) => s!.trim()).toList();
          
          if (parts.isNotEmpty) {
            return parts.take(2).join(', ');
          }
        } else {
          print('Geocoding returned empty places list');
        }
      } catch (e) {
        print('Geocoding error: $e');
      }

      // If all geocoding fails, show approximate region based on coordinates
      String region = _getRegionFromCoordinates(pos.latitude, pos.longitude);
      return region;
    } catch (e) {
      print('Location error: $e');
      return 'Unable to get location';
    }
  }

  // Get nearest barangay based on actual coordinates (Caloocan City)
  String _getRegionFromCoordinates(double lat, double lng) {
    // Known Caloocan City barangay coordinates
    final barangays = [
      {'name': 'Bagong Silang (Barangay 176)', 'lat': 14.7753, 'lng': 121.0456},
      {'name': 'Camarin (Barangay 174)', 'lat': 14.7617, 'lng': 121.0536},
      {'name': 'Camarin (Barangay 175)', 'lat': 14.7590, 'lng': 121.0500},
      {'name': 'Camarin (Barangay 177)', 'lat': 14.7545, 'lng': 121.0565},
      {'name': 'Camarin (Barangay 178)', 'lat': 14.7525, 'lng': 121.0600},
      {'name': 'Tala (Barangay 183)', 'lat': 14.7830, 'lng': 121.0600},
      {'name': 'Tala (Barangay 184)', 'lat': 14.7815, 'lng': 121.0620},
      {'name': 'Tala (Barangay 185)', 'lat': 14.7840, 'lng': 121.0650},
      {'name': 'Tala (Barangay 186)', 'lat': 14.7865, 'lng': 121.0665},
      {'name': 'Tala (Barangay 187)', 'lat': 14.7890, 'lng': 121.0690},
      {'name': 'Tala (Barangay 188)', 'lat': 14.7905, 'lng': 121.0710},
      {'name': 'Bagumbong / Pag-asa (Barangay 171)', 'lat': 14.7592, 'lng': 121.0175},
      {'name': 'Bagumbong / Pag-asa (Barangay 172)', 'lat': 14.7555, 'lng': 121.0220},
      {'name': 'Bagumbong / Pag-asa (Barangay 173)', 'lat': 14.7568, 'lng': 121.0310},
      {'name': 'Kaybiga / Deparo (Barangay 164)', 'lat': 14.7485, 'lng': 121.0160},
      {'name': 'Kaybiga / Deparo (Barangay 165)', 'lat': 14.7500, 'lng': 121.0185},
      {'name': 'Kaybiga / Deparo (Barangay 166)', 'lat': 14.7520, 'lng': 121.0210},
      {'name': 'Kaybiga / Deparo (Barangay 167)', 'lat': 14.7540, 'lng': 121.0240},
      {'name': 'Kaybiga / Deparo (Barangay 168)', 'lat': 14.7530, 'lng': 121.0280},
      {'name': 'Capri / Amparo (Barangay 179)', 'lat': 14.7565, 'lng': 121.0640},
      {'name': 'Nagkaisang Nayon (Barangay 170)', 'lat': 14.7480, 'lng': 121.0335},
      {'name': 'Nagkaisang Nayon (Barangay 180)', 'lat': 14.7630, 'lng': 121.0645},
      {'name': 'Pangarap Village (Barangay 181)', 'lat': 14.7680, 'lng': 121.0700},
      {'name': 'Pangarap Village (Barangay 182)', 'lat': 14.7705, 'lng': 121.0725},
      {'name': 'Baesa / Libis Baesa (Barangay 158)', 'lat': 14.6575, 'lng': 120.9835},
      {'name': 'Baesa / Libis Baesa (Barangay 159)', 'lat': 14.6590, 'lng': 120.9850},
      {'name': 'Baesa / Libis Baesa (Barangay 160)', 'lat': 14.6605, 'lng': 120.9870},
      {'name': 'Baesa / Libis Baesa (Barangay 161)', 'lat': 14.6620, 'lng': 120.9890},
      {'name': 'Santa Quiteria (Barangay 162)', 'lat': 14.6510, 'lng': 120.9895},
      {'name': 'Santa Quiteria (Barangay 163)', 'lat': 14.6530, 'lng': 120.9910},
    ];

    // Find the nearest barangay using distance calculation
    double minDistance = double.infinity;
    String? nearestBarangay;

    for (var brgy in barangays) {
      // Calculate approximate distance using Euclidean distance
      // (Good enough for small areas like city barangays)
      double distance = _calculateDistance(
        lat, lng, 
        brgy['lat'] as double, 
        brgy['lng'] as double
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestBarangay = brgy['name'] as String;
      }
    }

    // If nearest barangay is within reasonable distance (0.02 degrees ≈ 2km)
    // return the barangay name, otherwise return "Unknown Location"
    if (nearestBarangay != null && minDistance < 0.02) {
      return nearestBarangay;
    }

    return 'Unknown Location';
  }

  // Calculate approximate distance between two coordinates
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    // Simple Euclidean distance (sufficient for small geographic areas)
    double dLat = lat1 - lat2;
    double dLng = lng1 - lng2;
    return (dLat * dLat + dLng * dLng);
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
      // Fetch ALL alerts from the alerts endpoint (same as Alerts page)
      final response = await http
          .get(Uri.parse('${_getBaseUrl()}/api/tank/alerts'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> alertsData = json.decode(response.body);

        setState(() {
          _alerts = alertsData;
          _currentAlertStatus = _determineAlertStatus(alertsData);
          _alertsLoading = false;
        });
        print('✅ Fetched ${alertsData.length} alerts');
      } else {
        setState(() {
          _alertsLoading = false;
          _currentAlertStatus = 'normal';
          _alerts = [];
        });
        print('❌ Failed to fetch alerts: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _alertsLoading = false;
        _currentAlertStatus = 'normal';
        _alerts = [];
      });
      print('⚠️ Error fetching alerts: $e');
    }
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 0) return;

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

    NavigationHelper.navigateWithoutAnimation(context, destination);
  }

  @override
  Widget build(BuildContext context) {
    final machineProvider = Provider.of<MachineProvider>(context);
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveScaffold(
      title: 'VegoBolt Dashboard',
      currentIndex: 0,
      onNavigationChanged: (index) => _onNavTap(context, index),
      navigationItems: const [
        NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
        NavigationItem(icon: Icons.oil_barrel, label: 'Tanks'),
        NavigationItem(icon: Icons.warning_amber, label: 'Alerts'),
        NavigationItem(icon: Icons.build, label: 'Maintenance'),
        NavigationItem(icon: Icons.settings, label: 'Settings'),
      ],
      floatingActionButton: MouseRegion(
        onEnter: (_) => setState(() => _isFabHovering = true),
        onExit: (_) => setState(() => _isFabHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isFabHovering ? 1.06 : 1.0),
          child: FloatingActionButton(
            onPressed: () async {
              // Attempt to get the current device barangay (or fallback) and
              // display it inline in the dashboard container.
              String locationText = await _getCurrentLocationString();
              if (locationText == 'Location permission denied' ||
                  locationText == 'Unable to get location') {
                setState(() {
                  _detectedBarangay = machineProvider.location;
                });
              } else {
                setState(() {
                  _detectedBarangay = locationText;
                });
              }
            },
            backgroundColor:
                _isFabHovering ? AppColors.darkGreen : AppColors.primaryGreen,
            child: const Icon(Icons.location_on, color: Colors.white),
          ),
        ),
      ),
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
                      'Dashboard',
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
                      'Monitor your VegoBolt system',
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
              // detected barangay is shown inside the MachineStatusCard
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(responsive.getPadding()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Machine Status'),
                      SizedBox(
                        height: responsive.getValue(
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                      ),

                      MachineStatusCard(
                        machineId: 'VB-0001',
                        initialLocation: machineProvider.location,
                        detectedBarangay: _detectedBarangay.isNotEmpty ? _detectedBarangay : null,
                        statusText: machineProvider.statusText,
                        statusColor: machineProvider.statusColor,
                        tankLevel: tankLevel,
                        batteryValue: batteryValue,
                        temperatureC: temperatureC,
                        alertStatus: _currentAlertStatus,
                        isEditable: true,
                        onLocationChanged: (newLocation) {
                          machineProvider.updateLocation(newLocation);
                        },
                      ),

                      SizedBox(
                        height: responsive.getValue(
                          mobile: 20,
                          tablet: 24,
                          desktop: 32,
                        ),
                      ),
                      _buildSectionHeader('Recent Alerts'),
                      SizedBox(
                        height: responsive.getValue(
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),

                      _alertsLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _alerts.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
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
                              children: _alerts.take(6).map((alert) {
                                final String alertType = alert['type'] ?? '';
                                IconData alertIcon =
                                    Icons.warning_amber_rounded;

                                if (alertType == 'temperature') {
                                  alertIcon = Icons.thermostat;
                                } else if (alertType == 'tank') {
                                  alertIcon = Icons.local_gas_station;
                                } else if (alertType == 'smoke') {
                                  alertIcon = Icons.warning_amber_rounded;
                                }

                                return AlertCard(
                                  title: alert['title'] ?? '',
                                  machine: alert['machine'] ?? '',
                                  location: alert['location'] ?? '',
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

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkGreen
            : AppColors.primaryGreen,
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Critical':
        return AppColors.criticalRed;
      case 'Warning':
        return Colors.amber;
      case 'Resolved':
        return AppColors.primaryGreen;
      default:
        return AppColors.textSecondary;
    }
  }
}
