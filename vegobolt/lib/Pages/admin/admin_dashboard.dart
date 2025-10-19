import 'package:flutter/material.dart';
import '../../components/header.dart';
import '../../components/admin_navbar.dart';
import '../../components/add_maintenance_modal.dart';
import '../../utils/colors.dart';

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
  }

  // Sample data for the admin table
  final List<Map<String, dynamic>> _machineData = [
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
              Icon(Icons.restart_alt, size: 18, color: AppColors.primaryGreen),
              SizedBox(width: 8),
              Text('Restart Station'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              _showMsg('Restarting $machine...');
            });
          },
        ),
        PopupMenuItem(
          child: Row(
            children: const [
              Icon(Icons.power_settings_new, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text('Shutdown Station'),
            ],
          ),
          onTap: () {
            Future.delayed(Duration.zero, () {
              _showMsg('Shutting down $machine...');
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
        onAdd: (data) {
          _showMsg('Maintenance scheduled for $machine');
        },
        initialData: {'machineId': machine, 'location': 'Barangay 171'},
      ),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _toggleAccountStatus(
    int index,
    String fullname,
    bool isCurrentlyDisabled,
  ) {
    setState(() {
      _machineData[index]['isDisabled'] = !isCurrentlyDisabled;
    });

    final newStatus = !isCurrentlyDisabled ? 'disabled' : 'enabled';
    _showMsg('Account for $fullname has been $newStatus');
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
    setState(() {
      _machineData.removeAt(index);
    });
    _showMsg('Account for $fullname has been deleted');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Manage all machines and users',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Responsive Table
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 600;
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
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
                                columns: const [
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Full Name',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Machine',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Alerts',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Action',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                        fontSize: 11,
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
                                                          ? AppColors
                                                                .textSecondary
                                                          : AppColors
                                                                .textPrimary,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      decoration:
                                                          data['isDisabled'] ==
                                                              true
                                                          ? TextDecoration
                                                                .lineThrough
                                                          : null,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                    child: const Text(
                                                      'DISABLED',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 8,
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
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                  fontSize: 11,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                data['location'].replaceAll(
                                                  'Barangay ',
                                                  '',
                                                ),
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 9,
                                                ),
                                                overflow: TextOverflow.ellipsis,
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
                                                  fontSize: 9,
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
                                                fontSize: 10,
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
                                                  iconSize: 18,
                                                  color: AppColors.textPrimary,
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
