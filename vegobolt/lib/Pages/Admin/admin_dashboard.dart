import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../components/header.dart';
import '../../components/admin_navbar.dart';
import '../../components/add_maintenance_modal.dart';
import '../../utils/colors.dart';
import '../../utils/api_config.dart';
import '../../services/admin_user_service.dart';
import '../../services/invite_code_service.dart';
import '../../services/maintenance_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      // Navigate to Settings
      Navigator.pushReplacementNamed(context, '/admin-settings');
    }
    // When switching tabs, reload users to reflect changes
    _loadUsers();
  }

  final AdminUserService _adminService = AdminUserService();
  final MaintenanceService _maintenanceService = MaintenanceService();
  final InviteCodeService _inviteCodeService = InviteCodeService();

  bool _isGeneratingSignupCode = false;
  String? _latestSignupCode;
  List<dynamic> _alerts = [];
  bool _alertsLoading = false;

  // Table data (will be loaded from backend)
  List<Map<String, dynamic>> _machineData = [
    {
      'fullname': 'John Lorezo',
      'machine': 'VB-001',
      'location': 'Barangay ph1 Bagong Silang',
      'status': 'Active',
      'alerts': 2,
      'isDisabled': false,
    },
    {
      'fullname': 'Maria Santos',
      'machine': 'VB-002',
      'location': 'Barangay 172',
      'status': 'Inactive',
      'alerts': 0,
      'isDisabled': false,
    },
    {
      'fullname': 'Pedro Cruz',
      'machine': 'VB-003',
      'location': 'Barangay 173',
      'status': 'Maintenance',
      'alerts': 5,
      'isDisabled': false,
    },
    {
      'fullname': 'Ana Reyes',
      'machine': 'VB-004',
      'location': 'Barangay 174',
      'status': 'Active',
      'alerts': 1,
      'isDisabled': false,
    },
  ];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showActionMenu(
    BuildContext context,
    String machine,
    String fullname,
    Offset position,
    int dataIndex,
  ) {
    final isDisabled = _machineData[dataIndex]['isDisabled'] ?? false;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: Row(
            children: const [
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.primaryGreen,
              ),
              SizedBox(width: 8),
              Text('Edit Machine ID'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              _showEditMachineNameDialog(dataIndex, machine);
            });
          },
        ),
        PopupMenuItem(
          child: Row(
            children: const [
              Icon(Icons.schedule, size: 18, color: AppColors.warningYellow),
              SizedBox(width: 8),
              Text('Schedule Maintenance'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              _showMaintenanceModal(machine, fullname);
            });
          },
        ),
        // Divider
        const PopupMenuDivider(),
        // Disable/Enable Account
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                isDisabled ? Icons.check_circle : Icons.block,
                size: 18,
                color: isDisabled ? AppColors.primaryGreen : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(isDisabled ? 'Enable Account' : 'Disable Account'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              _toggleAccountStatus(dataIndex, fullname, isDisabled);
            });
          },
        ),
        // Delete Account
        PopupMenuItem(
          child: Row(
            children: const [
              Icon(Icons.delete, size: 18, color: AppColors.criticalRed),
              SizedBox(width: 8),
              Text('Delete Account'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              _confirmDeleteAccount(dataIndex, fullname);
            });
          },
        ),
      ],
    );
  }

  void _showMaintenanceModal(String machine, String fullname) {
    showDialog(
      context: context,
      builder: (context) => AddMaintenanceModal(
        onAdd: (data) async {
          // Save maintenance to backend so Maintenance page reflects it
          final created = await _maintenanceService.create(data);
          if (created != null) {
            _showMsg('Maintenance scheduled for $machine');
          } else {
            _showMsg('Failed to schedule maintenance for $machine');
          }
        },
        initialData: {'machineId': machine, 'location': 'Barangay 171'},
      ),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _generateSignupCode() async {
    if (_isGeneratingSignupCode) return;
    setState(() => _isGeneratingSignupCode = true);

    try {
      final result = await _inviteCodeService.generate();
      if (!mounted) return;

      if (result['success'] == true) {
        final code = result['code']?.toString();
        setState(() => _latestSignupCode = code);
        _showMsg('Signup code generated');
      } else {
        _showMsg(result['message']?.toString() ?? 'Failed to generate code');
      }
    } finally {
      if (mounted) setState(() => _isGeneratingSignupCode = false);
    }
  }

  void _copySignupCode() {
    final code = _latestSignupCode;
    if (code == null || code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    _showMsg('Copied code to clipboard');
  }

  void _showEditMachineNameDialog(int dataIndex, String currentMachine) {
    final controller = TextEditingController(text: currentMachine);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Machine Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new machine name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newMachine = controller.text.trim();
              if (newMachine.isEmpty) {
                _showMsg('Machine name cannot be empty');
                return;
              }
              Navigator.pop(context);
              _updateMachineName(dataIndex, newMachine);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMachineName(int dataIndex, String newMachine) async {
    final id = _machineData[dataIndex]['id'];
    if (id == null) {
      setState(() {
        _machineData[dataIndex]['machine'] = newMachine;
      });
      _showMsg('Machine name updated to $newMachine');
      return;
    }

    // Call backend to update machine name
    final success = await _adminService.updateMachine(id, {
      'machine': newMachine,
    });
    if (success) {
      setState(() {
        _machineData[dataIndex]['machine'] = newMachine;
      });
      _showMsg('Machine name updated to $newMachine');
    } else {
      _showMsg('Failed to update machine name');
    }
  }

  String _getBaseUrl() {
    return ApiConfig.baseUrl;
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _alertsLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('${_getBaseUrl()}/api/tank/alerts'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> alertsData = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          _alerts = alertsData;
          _alertsLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _alerts = [];
          _alertsLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _alerts = [];
        _alertsLoading = false;
      });
    }
  }

  Color _getAlertColor(Map<String, dynamic> alert) {
    final status = (alert['status'] ?? '').toString().toLowerCase();
    if (status == 'critical') return AppColors.criticalRed;
    if (status == 'warning') return AppColors.warningYellow;
    if (status == 'resolved') return AppColors.primaryGreen;
    return AppColors.getTextSecondary(context);
  }

  IconData _getAlertIcon(Map<String, dynamic> alert) {
    final type = (alert['type'] ?? '').toString().toLowerCase();
    if (type == 'temperature') return Icons.thermostat;
    if (type == 'tank') return Icons.local_gas_station;
    return Icons.warning_amber_rounded;
  }

  String _resolveAlertStaff(Map<String, dynamic> alert) {
    final explicitStaff = (alert['staff'] ?? '').toString().trim();
    if (explicitStaff.isNotEmpty) return explicitStaff;

    final machineId = (alert['machine'] ?? '').toString().trim();
    if (machineId.isEmpty) return 'Unknown Staff';

    final matched = _machineData.where((m) => m['machine'] == machineId);
    if (matched.isEmpty) return 'Unknown Staff';

    final name = (matched.first['fullname'] ?? '').toString().trim();
    return name.isEmpty ? 'Unknown Staff' : name;
  }

  Future<void> _showAllAlerts() async {
    await _loadAlerts();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Alerts List
              Expanded(
                child: _alertsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _alerts.isEmpty
                    ? Center(
                        child: Text(
                          'No alerts detected.',
                          style: TextStyle(
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _alerts.length,
                        itemBuilder: (context, index) {
                          final alert = _alerts[index] as Map<String, dynamic>;
                          final staffName = _resolveAlertStaff(alert);
                          final alertColor = _getAlertColor(alert);
                          final alertIcon = _getAlertIcon(alert);

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.getTextLight(
                                    context,
                                  ).withOpacity(0.2),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: alertColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    alertIcon,
                                    color: alertColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (alert['title'] ?? 'Alert').toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.getTextPrimary(
                                            context,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${alert['machine'] ?? 'Unknown'} • ${alert['location'] ?? '-'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.getTextSecondary(
                                            context,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Staff: $staffName',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.getTextSecondary(
                                            context,
                                          ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (alert['time'] ?? '-').toString(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.getTextLight(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: alertColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    (alert['status'] ?? '').toString(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: alertColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadAlerts();
  }

  Future<void> _loadUsers() async {
    final users = await _adminService.listUsers();
    if (users.isEmpty) return;

    final mapped = users.map((u) {
      final fullname = '${u['firstName'] ?? ''} ${u['lastName'] ?? ''}'.trim();
      // Try to get location from multiple fields
      final location =
          u['address'] ??
          u['location'] ??
          u['barangay'] ??
          u['city'] ??
          'Unknown';
      return {
        'id': u['_id'] ?? u['id'],
        'fullname': fullname.isEmpty
            ? (u['displayName'] ?? u['email'] ?? 'Unknown')
            : fullname,
        'machine': u['machine'] ?? 'VB-0000',
        'location': location,
        'status': u['isActive'] == true ? 'Active' : 'Inactive',
        'alerts': u['alerts'] ?? 0,
        'isDisabled': u['isActive'] == false,
      };
    }).toList();

    setState(() {
      _machineData = mapped.cast<Map<String, dynamic>>();
    });
  }

  void _toggleAccountStatus(
    int index,
    String fullname,
    bool isCurrentlyDisabled,
  ) {
    final id = _machineData[index]['id'];

    // If we don't have an id (sample/local), just toggle locally
    if (id == null) {
      setState(() {
        _machineData[index]['isDisabled'] = !isCurrentlyDisabled;
      });
      final newStatusLocal = !isCurrentlyDisabled ? 'disabled' : 'enabled';
      _showMsg('Account for $fullname has been $newStatusLocal');
      return;
    }

    final newActive = isCurrentlyDisabled; // enabling -> active=true
    _adminService.setActive(id, newActive).then((ok) {
      if (ok) {
        setState(() {
          _machineData[index]['isDisabled'] = !isCurrentlyDisabled;
          _machineData[index]['status'] = newActive ? 'Active' : 'Inactive';
        });
        final newStatus = !isCurrentlyDisabled ? 'disabled' : 'enabled';
        _showMsg('Account for $fullname has been $newStatus');
      } else {
        _showMsg('Failed to update account status for $fullname');
      }
    });
  }

  void _confirmDeleteAccount(int index, String fullname) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete the account for $fullname?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount(index, fullname);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.criticalRed,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteAccount(int index, String fullname) {
    final id = _machineData[index]['id'];

    if (id == null) {
      setState(() {
        _machineData.removeAt(index);
      });
      _showMsg('Account for $fullname has been deleted');
      return;
    }

    _adminService.adminDeleteUser(id).then((ok) {
      if (ok) {
        setState(() {
          _machineData.removeAt(index);
        });
        _showMsg('Account for $fullname has been deleted');
      } else {
        _showMsg('Failed to delete account for $fullname');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage all machines and users',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Signup code generator (minimal)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.getCardBackground(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.vpn_key_outlined,
                              color: AppColors.getTextSecondary(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Signup Code',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.getTextPrimary(context),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                onPressed: _isGeneratingSignupCode
                                    ? null
                                    : _generateSignupCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isGeneratingSignupCode
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Generate',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Generate a one-time code required for new user registration.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.getTextSecondary(context),
                          ),
                        ),
                        if ((_latestSignupCode ?? '').isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.getTextLight(
                                  context,
                                ).withOpacity(0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    _latestSignupCode!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: AppColors.getTextPrimary(context),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _copySignupCode,
                                  tooltip: 'Copy',
                                  icon: const Icon(Icons.copy),
                                  color: AppColors.primaryGreen,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Statistics Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final isSmallScreen = screenWidth < 600;

                      // Responsive font sizes
                      final titleFontSize = isSmallScreen ? 10.0 : 13.0;
                      final numberFontSize = isSmallScreen ? 20.0 : 28.0;
                      final percentFontSize = isSmallScreen ? 9.0 : 11.0;
                      final iconSize = isSmallScreen ? 16.0 : 20.0;
                      final badgeIconSize = isSmallScreen ? 10.0 : 12.0;
                      final cardPadding = isSmallScreen ? 12.0 : 16.0;

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(cardPadding),
                                decoration: BoxDecoration(
                                  color: AppColors.getCardBackground(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryGreen.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.group,
                                          color: AppColors.getTextSecondary(
                                            context,
                                          ),
                                          size: iconSize,
                                        ),
                                        SizedBox(width: isSmallScreen ? 4 : 8),
                                        Expanded(
                                          child: Text(
                                            'Active Accounts',
                                            style: TextStyle(
                                              color: AppColors.getTextSecondary(
                                                context,
                                              ),
                                              fontSize: titleFontSize,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isSmallScreen ? 8 : 12),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '${_machineData.where((user) => user['isDisabled'] != true).length}',
                                            style: TextStyle(
                                              fontSize: numberFontSize,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.getTextPrimary(
                                                context,
                                              ),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: isSmallScreen ? 4 : 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 4 : 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryGreen
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${(((_machineData.where((user) => user['isDisabled'] != true).length) / _machineData.length) * 100).toStringAsFixed(0)}%',
                                                style: TextStyle(
                                                  color: AppColors.primaryGreen,
                                                  fontSize: percentFontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(
                                                Icons.arrow_upward,
                                                color: AppColors.primaryGreen,
                                                size: badgeIconSize,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _showAllAlerts,
                                child: Container(
                                  padding: EdgeInsets.all(cardPadding),
                                  decoration: BoxDecoration(
                                    color: AppColors.getCardBackground(context),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.criticalRed.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.notifications_active,
                                            color: AppColors.getTextSecondary(
                                              context,
                                            ),
                                            size: iconSize,
                                          ),
                                          SizedBox(
                                            width: isSmallScreen ? 4 : 8,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Total Alerts',
                                              style: TextStyle(
                                                color:
                                                    AppColors.getTextSecondary(
                                                      context,
                                                    ),
                                                fontSize: titleFontSize,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isSmallScreen ? 8 : 12),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '${_machineData.fold<int>(0, (sum, user) => sum + (user['alerts'] as int))}',
                                              style: TextStyle(
                                                fontSize: numberFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.getTextPrimary(
                                                  context,
                                                ),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: isSmallScreen ? 4 : 8,
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isSmallScreen ? 4 : 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.criticalRed
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '34.0%',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.criticalRed,
                                                    fontSize: percentFontSize,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                Icon(
                                                  Icons.arrow_downward,
                                                  color: AppColors.criticalRed,
                                                  size: badgeIconSize,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(cardPadding),
                                decoration: BoxDecoration(
                                  color: AppColors.getCardBackground(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryGreen.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.precision_manufacturing,
                                          color: AppColors.getTextSecondary(
                                            context,
                                          ),
                                          size: iconSize,
                                        ),
                                        SizedBox(width: isSmallScreen ? 4 : 8),
                                        Expanded(
                                          child: Text(
                                            'Active Machines',
                                            style: TextStyle(
                                              color: AppColors.getTextSecondary(
                                                context,
                                              ),
                                              fontSize: titleFontSize,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isSmallScreen ? 8 : 12),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '${_machineData.where((machine) => machine['status']?.toString().toLowerCase() == 'active').length}',
                                            style: TextStyle(
                                              fontSize: numberFontSize,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.getTextPrimary(
                                                context,
                                              ),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: isSmallScreen ? 4 : 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 4 : 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryGreen
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${(((_machineData.where((machine) => machine['status']?.toString().toLowerCase() == 'active').length) / _machineData.length) * 100).toStringAsFixed(0)}%',
                                                style: TextStyle(
                                                  color: AppColors.primaryGreen,
                                                  fontSize: percentFontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(
                                                Icons.arrow_upward,
                                                color: AppColors.primaryGreen,
                                                size: badgeIconSize,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Responsive Table
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 600;
                      final isMediumScreen = constraints.maxWidth < 800;

                      // Responsive font sizes for table
                      final headerFontSize = isSmallScreen
                          ? 9.0
                          : (isMediumScreen ? 10.0 : 11.0);
                      final cellFontSize = isSmallScreen
                          ? 9.0
                          : (isMediumScreen ? 10.0 : 11.0);
                      final subTextFontSize = isSmallScreen
                          ? 7.0
                          : (isMediumScreen ? 8.0 : 9.0);
                      final badgeFontSize = isSmallScreen
                          ? 7.0
                          : (isMediumScreen ? 8.0 : 9.0);
                      final alertFontSize = isSmallScreen
                          ? 8.0
                          : (isMediumScreen ? 9.0 : 10.0);
                      final disabledBadgeFontSize = isSmallScreen
                          ? 6.0
                          : (isMediumScreen ? 7.0 : 8.0);

                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.getCardBackground(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
                                columnSpacing: isSmallScreen ? 4 : 8,
                                horizontalMargin: 8,
                                headingRowHeight: 40,
                                dataRowMinHeight: 48,
                                dataRowMaxHeight: 60,
                                headingRowColor: WidgetStateProperty.all(
                                  AppColors.primaryGreen.withOpacity(0.1),
                                ),
                                columns: [
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Full Name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.getTextPrimary(
                                            context,
                                          ),
                                          fontSize: headerFontSize,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Machine',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.getTextPrimary(
                                          context,
                                        ),
                                        fontSize: headerFontSize,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.getTextPrimary(
                                          context,
                                        ),
                                        fontSize: headerFontSize,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Alerts',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.getTextPrimary(
                                          context,
                                        ),
                                        fontSize: headerFontSize,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Action',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.getTextPrimary(
                                          context,
                                        ),
                                        fontSize: headerFontSize,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: _machineData.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final data = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        SizedBox(
                                          width: constraints.maxWidth * 0.26,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    data['fullname'],
                                                    style: TextStyle(
                                                      color:
                                                          data['isDisabled'] ==
                                                              true
                                                          ? AppColors.getTextSecondary(
                                                              context,
                                                            )
                                                          : AppColors.getTextPrimary(
                                                              context,
                                                            ),
                                                      fontSize: cellFontSize,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      decoration:
                                                          data['isDisabled'] ==
                                                              true
                                                          ? TextDecoration
                                                                .lineThrough
                                                          : null,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                                if (data['isDisabled'] == true)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          left: 4,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      'DISABLED',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize:
                                                            disabledBadgeFontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: constraints.maxWidth * 0.20,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['machine'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AppColors.getTextPrimary(
                                                        context,
                                                      ),
                                                  fontSize: cellFontSize,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.visible,
                                              ),
                                              Text(
                                                data['location'].replaceAll(
                                                  'Barangay ',
                                                  '',
                                                ),
                                                style: TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: subTextFontSize,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 85,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                  data['status'],
                                                ).withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                data['status'],
                                                style: TextStyle(
                                                  color: _getStatusColor(
                                                    data['status'],
                                                  ),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: badgeFontSize,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: constraints.maxWidth * 0.18,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              data['alerts'] > 0
                                                  ? '${data['alerts']} detected'
                                                  : 'No detected',
                                              style: TextStyle(
                                                color: data['alerts'] > 0
                                                    ? AppColors.criticalRed
                                                    : AppColors.textSecondary,
                                                fontWeight: FontWeight.w500,
                                                fontSize: alertFontSize,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: constraints.maxWidth * 0.16,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Builder(
                                              builder: (context) {
                                                return IconButton(
                                                  onPressed: () {
                                                    final RenderBox button =
                                                        context.findRenderObject()
                                                            as RenderBox;
                                                    final RenderBox overlay =
                                                        Overlay.of(context)
                                                                .context
                                                                .findRenderObject()
                                                            as RenderBox;
                                                    final Offset position =
                                                        button.localToGlobal(
                                                          button.size
                                                              .bottomLeft(
                                                                Offset.zero,
                                                              ),
                                                          ancestor: overlay,
                                                        );
                                                    _showActionMenu(
                                                      context,
                                                      data['machine'],
                                                      data['fullname'],
                                                      position,
                                                      index,
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.more_vert,
                                                  ),
                                                  iconSize: isSmallScreen
                                                      ? 16
                                                      : 18,
                                                  color:
                                                      AppColors.getTextPrimary(
                                                        context,
                                                      ),
                                                  tooltip: 'Actions',
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(
                                                        minWidth: 28,
                                                        minHeight: 28,
                                                      ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
