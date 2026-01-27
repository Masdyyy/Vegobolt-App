import 'package:flutter/material.dart';
import '../components/add_maintenance_modal.dart';
import '../utils/colors.dart';
import '../utils/navigation_helper.dart';
import '../utils/responsive_layout.dart';
import '../services/maintenance_service.dart';
import 'dashboard.dart';
import 'alerts.dart';
import 'machine.dart';
import 'Settings.dart';

class MaintenancePage extends StatefulWidget {
  final List<Map<String, dynamic>>? initialScheduledItems;

  const MaintenancePage({super.key, this.initialScheduledItems});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isHovering = false;

  // Scheduled maintenance items (empty initially)
  late List<Map<String, dynamic>> scheduledItems;

  // History items
  List<Map<String, dynamic>> historyItems = [];

  final MaintenanceService _maintenanceService = MaintenanceService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize with empty list then load from backend
    scheduledItems = [];
    _loadMaintenance();
  }

  Future<void> _loadMaintenance() async {
    final items = await _maintenanceService.list();

    final scheduled = <Map<String, dynamic>>[];
    final history = <Map<String, dynamic>>[];

    for (final it in items) {
      final parsed = it['scheduledDate'] != null ? DateTime.tryParse(it['scheduledDate']) : null;
      final scheduledDate = parsed != null ? (parsed.isUtc ? parsed.toLocal() : parsed) : null;
      final priority = (it['priority'] ?? 'Medium') as String;
      final priorityColor = priority == 'High'
          ? AppColors.criticalRed
          : priority == 'Low'
              ? AppColors.darkGreen
              : const Color(0xFFFFD700);

      final mapped = {
        'id': it['_id'] ?? it['id'],
        'title': it['title'] ?? 'Maintenance',
        'machineId': it['machineId'] ?? '',
        'location': it['location'] ?? '',
        'priority': priority,
        'priorityColor': priorityColor,
        'scheduledDate': scheduledDate,
      };

      if ((it['status'] ?? 'Scheduled') == 'Resolved') {
        history.add({...mapped, 'resolvedDate': it['updatedAt'] ?? DateTime.now().toIso8601String()});
      } else {
        scheduled.add(mapped);
      }
    }

    setState(() {
      scheduledItems = scheduled;
      historyItems = history;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _resolveItem(Map<String, dynamic> item) {
    _maintenanceService.resolve(item['id']).then((updated) {
      if (updated != null) {
        setState(() {
          scheduledItems.remove(item);
          final resolvedDate = updated['updatedAt'] ?? DateTime.now().toIso8601String();
          historyItems.insert(0, {
            ...item,
            'resolvedDate': resolvedDate is String ? resolvedDate : resolvedDate.toString(),
            'status': 'Resolved',
          });
          _tabController.animateTo(1);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to resolve')));
      }
    });
  }

  void _editItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AddMaintenanceModal(
        isEdit: true,
        initialData: item,
        onAdd: (updatedData) async {
          final id = item['id'];
          final success = await _maintenanceService.update(id, {
            'title': updatedData['title'],
            'machineId': updatedData['machineId'],
            'location': updatedData['location'],
            'priority': updatedData['priority'],
            'scheduledDate': updatedData['scheduledDate']?.toIso8601String(),
          });

          if (success) {
            setState(() {
              final index = scheduledItems.indexOf(item);
              if (index != -1) {
                scheduledItems[index] = {
                  ...scheduledItems[index],
                  'title': updatedData['title'],
                  'machineId': updatedData['machineId'],
                  'location': updatedData['location'],
                  'priority': updatedData['priority'],
                  'priorityColor': updatedData['priorityColor'],
                  'scheduledDate': updatedData['scheduledDate'],
                };
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maintenance updated')));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update maintenance')));
          }
        },
      ),
    );
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Maintenance'),
        content: const Text(
          'Are you sure you want to delete this maintenance item?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Call backend to delete
              _maintenanceService.delete(item['id']).then((ok) {
                if (ok) {
                  setState(() {
                    scheduledItems.remove(item);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Maintenance item deleted'),
                      backgroundColor: AppColors.criticalRed,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete')));
                }
                Navigator.pop(context);
              });
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.criticalRed),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 3) return; // already in Maintenance page

    // If navigating to Machine page, prefer to pop with the updated scheduled items
    // when this Maintenance page was pushed from Machine (so Machine is below
    // in the Navigator stack). If there's no route to pop to (for example the
    // app used pushReplacement when navigating between pages), do a
    // pushReplacement to the MachinePage so navigation is explicit and
    // predictable.
    if (index == 1) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, scheduledItems);
      } else {
        NavigationHelper.navigateWithoutAnimation(context, const MachinePage());
      }
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);

    return AdaptiveScaffold(
      title: 'Maintenance',
      currentIndex: 3,
      onNavigationChanged: (index) => _onNavTap(context, index),
      navigationItems: const [
        NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
        NavigationItem(icon: Icons.oil_barrel, label: 'Tanks'),
        NavigationItem(icon: Icons.warning, label: 'Alerts'),
        NavigationItem(icon: Icons.build, label: 'Maintenance'),
        NavigationItem(icon: Icons.settings, label: 'Settings'),
      ],
      floatingActionButton: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()..scale(_isHovering ? 1.1 : 1.0),
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddMaintenanceModal(
                  onAdd: (maintenanceData) async {
                    final created = await _maintenanceService.create(maintenanceData);
                    if (created != null) {
                      DateTime? createdDate;
                      if (created['scheduledDate'] != null) {
                        final parsed = DateTime.tryParse(created['scheduledDate']);
                        createdDate = parsed != null ? (parsed.isUtc ? parsed.toLocal() : parsed) : null;
                      } else {
                        createdDate = maintenanceData['scheduledDate'];
                      }

                      final mapped = {
                        'id': created['_id'] ?? created['id'],
                        'title': created['title'],
                        'machineId': created['machineId'],
                        'location': created['location'],
                        'priority': created['priority'] ?? 'Medium',
                        'priorityColor': maintenanceData['priorityColor'],
                        'scheduledDate': createdDate,
                      };
                      setState(() {
                        scheduledItems.insert(0, mapped);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maintenance scheduled')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to schedule maintenance')));
                    }
                  },
                ),
              );
            },
            backgroundColor: _isHovering
                ? AppColors.darkGreen
                : AppColors.primaryGreen,
            elevation: _isHovering ? 8 : 4,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF121212)
                  : const Color(0xFFF5F5F5),
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFE8F5E9),
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
                      'Maintenance',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                      'Track maintenance activities',
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
                child: Padding(
                  padding: EdgeInsets.all(responsive.getPadding()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search bar
                      TextField(
                        style: TextStyle(color: AppColors.getTextPrimary(context)),
                    decoration: InputDecoration(
                      hintText: 'Search maintenance records...',
                      hintStyle: TextStyle(
                        color: AppColors.getTextLight(context),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.getTextSecondary(context),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkCardBackground
                          : AppColors.cardBackground,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                      ),
                      const SizedBox(height: 12),

                      // Tab Bar
                      Container(
                        height: 45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkCardBackground
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextLight
                            : AppColors.textLight,
                        width: 1,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkGreen
                            : AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? AppColors.cardBackground
                          : AppColors.getTextSecondary(context),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Scheduled'),
                        Tab(text: 'History'),
                      ],
                    ),
                  ),

                      const SizedBox(height: 16),

                      // Tab Content - fills remaining space
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [_buildScheduledTab(), _buildHistoryTab()],
                        ),
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

  Widget _buildScheduledTab() {
    if (scheduledItems.isEmpty) {
      return Center(
        child: Text(
          'No scheduled maintenance',
          style: TextStyle(
            color: AppColors.getTextLight(context),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: scheduledItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = scheduledItems[index];
        return _buildMaintenanceCard(
          title: item['title'],
          machineId: item['machineId'],
          location: item['location'],
          scheduledDate: item['scheduledDate'],
          priority: item['priority'],
          priorityColor: item['priorityColor'],
          onEdit: () => _editItem(item),
          onResolve: () => _resolveItem(item),
          onDelete: () => _deleteItem(item),
          isHistory: false,
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (historyItems.isEmpty) {
      return Center(
        child: Text(
          'No history records',
          style: TextStyle(
            color: AppColors.getTextLight(context),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: historyItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = historyItems[index];
        return _buildHistoryCard(
          title: item['title'],
          machineId: item['machineId'],
          location: item['location'],
          resolvedDate: item['resolvedDate'],
        );
      },
    );
  }

  Widget _buildMaintenanceCard({
    required String title,
    required String machineId,
    required String location,
    required DateTime? scheduledDate,
    required String priority,
    required Color priorityColor,
    required VoidCallback onEdit,
    required VoidCallback onResolve,
    required VoidCallback onDelete,
    required bool isHistory,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Priority Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.criticalRed,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
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
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$machineId • $location',
            style: TextStyle(
              color: AppColors.getTextLight(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.getTextLight(context),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onResolve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Resolve',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String machineId,
    required String location,
    required String resolvedDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: AppColors.primaryGreen, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: AppColors.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Machine: $machineId',
                  style: TextStyle(
                    color: AppColors.getTextLight(context),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.getTextLight(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: AppColors.getTextLight(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
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
                      resolvedDate,
                      style: TextStyle(
                        color: AppColors.getTextLight(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGreen, width: 1.5),
            ),
            child: Text(
              'Resolved',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
