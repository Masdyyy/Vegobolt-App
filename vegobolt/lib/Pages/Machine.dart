import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../utils/api_config.dart';
import '../utils/colors.dart';
import '../utils/navigation_helper.dart';
import '../utils/responsive_layout.dart';
import '../services/maintenance_service.dart';
import '../services/tank_service.dart';
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

  // Tapo Socket state
  bool isSocketOn = false;
  bool isSocketLoading = false;

  // MQTT Client
  MqttServerClient? _mqttClient;
  bool _isMqttConnected = false;

  final MaintenanceService _maintenanceService = MaintenanceService();

  @override
  void initState() {
    super.initState();
    _initializeMqtt();
    fetchTankData();
    fetchAlerts();
    _loadMaintenanceData();
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
    _mqttClient?.disconnect();
    super.dispose();
  }

  // Get base URL from centralized config
  String _getBaseUrl() {
    return ApiConfig.baseUrl;
  }

  Future<void> _loadMaintenanceData() async {
    final items = await _maintenanceService.list();
    final scheduled = <Map<String, dynamic>>[];

    for (final it in items) {
      if ((it['status'] ?? 'Scheduled') != 'Resolved') {
        final parsed = it['scheduledDate'] != null
            ? DateTime.tryParse(it['scheduledDate'])
            : null;
        final scheduledDate = parsed != null
            ? (parsed.isUtc ? parsed.toLocal() : parsed)
            : null;
        final priority = (it['priority'] ?? 'Medium') as String;
        final priorityColor = priority == 'High'
            ? AppColors.criticalRed
            : priority == 'Low'
            ? AppColors.darkGreen
            : const Color(0xFFFFD700);

        scheduled.add({
          'id': it['_id'] ?? it['id'],
          'title': it['title'] ?? 'Maintenance',
          'machineId': it['machineId'] ?? '',
          'location': it['location'] ?? '',
          'priority': priority,
          'priorityColor': priorityColor,
          'scheduledDate': scheduledDate,
        });
      }
    }

    setState(() {
      scheduledMaintenanceItems = scheduled;
    });
  }

  // Initialize MQTT Connection
  Future<void> _initializeMqtt() async {
    try {
      print('🔄 Attempting MQTT connection to broker.hivemq.com:1883...');

      _mqttClient = MqttServerClient.withPort(
        'broker.hivemq.com',
        'vegobolt_app_${DateTime.now().millisecondsSinceEpoch}',
        1883,
      );
      _mqttClient!.logging(on: true);
      _mqttClient!.setProtocolV311();
      _mqttClient!.keepAlivePeriod = 20;
      _mqttClient!.connectTimeoutPeriod = 5000; // 5 seconds timeout
      _mqttClient!.autoReconnect = true;
      _mqttClient!.onConnected = _onMqttConnected;
      _mqttClient!.onDisconnected = _onMqttDisconnected;
      _mqttClient!.onAutoReconnect = () {
        print('🔄 Auto-reconnecting to MQTT broker...');
      };
      _mqttClient!.onAutoReconnected = () {
        print('✅ Auto-reconnected to MQTT broker');
        setState(() {
          _isMqttConnected = true;
        });
      };

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(
            'vegobolt_app_${DateTime.now().millisecondsSinceEpoch}',
          )
          .withWillTopic('vegobolt/will')
          .withWillMessage('Flutter app disconnected')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      _mqttClient!.connectionMessage = connMessage;

      print('🔌 Connecting to MQTT broker...');
      final status = await _mqttClient!.connect();

      if (status?.state == MqttConnectionState.connected) {
        print('✅ Successfully connected to broker.hivemq.com');
      } else {
        print('❌ Connection failed with state: ${status?.state}');
        print('❌ Return code: ${status?.returnCode}');
        _mqttClient?.disconnect();
      }
    } catch (e) {
      print('⚠️ MQTT Connection Error: $e');
      if (_mqttClient != null) {
        _mqttClient!.disconnect();
      }
    }
  }

  void _onMqttConnected() {
    setState(() {
      _isMqttConnected = true;
    });
    print('✅ MQTT Connected to broker.hivemq.com');

    // Subscribe to status topics to listen for ESP32 responses
    _mqttClient!.subscribe('vegobolt/tank/valve1/status', MqttQos.atLeastOnce);
    _mqttClient!.subscribe('vegobolt/tank/valve2/status', MqttQos.atLeastOnce);
    _mqttClient!.subscribe('vegobolt/tank/sensors', MqttQos.atLeastOnce);

    print('📥 Subscribed to valve status topics');

    // Set up message listener
    _mqttClient!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        message.payload.message,
      );
      print('📩 Received message: ${c[0].topic} -> $payload');
    });
  }

  void _onMqttDisconnected() {
    setState(() {
      _isMqttConnected = false;
    });
    print('❌ MQTT Disconnected - Attempting reconnect in 5 seconds...');
    // Auto-reconnect after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      _initializeMqtt();
    });
  }

  // Send valve control command via MQTT
  void _sendValveCommand(String action, {int valve = 1}) {
    if (_mqttClient == null || !_isMqttConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 12),
              Text('MQTT not connected. Please check connection.'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final topic = valve == 1
        ? 'vegobolt/tank/valve1/control'
        : 'vegobolt/tank/valve2/control';

    final builder = MqttClientPayloadBuilder();
    builder.addString('{"action":"$action"}');

    print('📤 Publishing to topic: $topic');
    print('📤 Message: {"action":"$action"}');

    _mqttClient!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

    print('✅ MQTT command published successfully');
  }

  // Control Tapo socket/plug
  Future<void> _controlSocket(bool turnOn) async {
    setState(() {
      isSocketLoading = true;
    });

    try {
      final result = turnOn
          ? await TankService.turnPumpOn()
          : await TankService.turnPumpOff();

      if (result['success'] == true) {
        setState(() {
          isSocketOn = turnOn;
          isSocketLoading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  turnOn ? Icons.power : Icons.power_off,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text('Socket turned ${turnOn ? "ON" : "OFF"}'),
              ],
            ),
            backgroundColor: turnOn ? Colors.blue : Colors.grey[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          isSocketLoading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text('Failed: ${result['error'] ?? "Unknown error"}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isSocketLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text('Error: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
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

  void _onNavTap(BuildContext context, int index) {
    if (index == 1) return;

    // Special handling for maintenance page to reload data on return
    if (index == 3) {
      NavigationHelper.navigateWithoutAnimation(
        context,
        MaintenancePage(initialScheduledItems: scheduledMaintenanceItems),
      );
      return;
    }

    // Handle other navigation
    Widget destination;
    switch (index) {
      case 0:
        destination = const DashboardPage();
        break;
      case 2:
        destination = const AlertsPage();
        break;
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
            // MQTT Connection Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isMqttConnected
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isMqttConnected
                      ? AppColors.primaryGreen
                      : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isMqttConnected ? Icons.cloud_done : Icons.cloud_off,
                    size: 16,
                    color: _isMqttConnected
                        ? AppColors.primaryGreen
                        : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isMqttConnected ? 'MQTT Connected' : 'MQTT Connecting...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isMqttConnected
                          ? AppColors.primaryGreen
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tank control buttons
            Row(
              children: [
                // Oil Tank Button
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        final newState = !isOilTankOpen;
                        setState(() {
                          isOilTankOpen = newState;
                        });
                        // Send MQTT command to ESP32 for oil tank (valve1)
                        _sendValveCommand(
                          newState ? 'open' : 'close',
                          valve: 1,
                        );

                        // Show confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  newState ? Icons.check_circle : Icons.lock,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text('Valve ${newState ? "opened" : "closed"}'),
                              ],
                            ),
                            backgroundColor: newState
                                ? AppColors.primaryGreen
                                : Colors.grey[700],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
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
                          isOilTankOpen
                              ? 'Oil Tank - Open'
                              : 'Oil Tank - Closed',
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
                        final newState = !isDieselTankOpen;
                        setState(() {
                          isDieselTankOpen = newState;
                        });
                        // Send MQTT command to ESP32 for diesel tank (valve2)
                        _sendValveCommand(
                          newState ? 'open' : 'close',
                          valve: 2,
                        );

                        // Show confirmation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  newState ? Icons.check_circle : Icons.lock,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Diesel valve ${newState ? "opened" : "closed"}',
                                ),
                              ],
                            ),
                            backgroundColor: newState
                                ? const Color(0xFFFFD700)
                                : Colors.grey[700],
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
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
            const SizedBox(height: 12),
            // Tapo Socket Control Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isSocketLoading
                    ? null
                    : () {
                        _controlSocket(!isSocketOn);
                      },
                icon: isSocketLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isSocketOn ? Icons.power : Icons.power_off,
                        size: 24,
                      ),
                label: Text(
                  isSocketLoading
                      ? 'Processing...'
                      : isSocketOn
                      ? 'Tapo Socket - ON'
                      : 'Tapo Socket - OFF',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSocketOn
                      ? Colors.blue
                      : isDark
                      ? Colors.grey[700]
                      : const Color(0xFFE5E7EB),
                  foregroundColor: isSocketOn
                      ? Colors.white
                      : AppColors.getTextSecondary(context),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: isDark
                      ? Colors.grey[800]
                      : Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                ),
              ),
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
