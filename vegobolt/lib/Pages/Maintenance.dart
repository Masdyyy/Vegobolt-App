import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/header.dart';
import '../components/add_maintenance_modal.dart';
import '../utils/colors.dart';
import '../utils/navigation_helper.dart';
import 'dashboard.dart';
import 'alerts.dart';
import 'machine.dart';
import 'settings.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Initialize with items from machine page if provided, otherwise empty
    scheduledItems = widget.initialScheduledItems ?? [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _resolveItem(Map<String, dynamic> item) {
    setState(() {
      scheduledItems.remove(item);
      historyItems.insert(0, {
        ...item,
        'resolvedDate': 'August 18, 2025',
        'status': 'Resolved',
      });
      _tabController.animateTo(1); // Switch to History tab
    });
  }

  void _editItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AddMaintenanceModal(
        isEdit: true,
        initialData: item,
        onAdd: (updatedData) {
          setState(() {
            // Find and update the item
            final index = scheduledItems.indexOf(item);
            if (index != -1) {
              scheduledItems[index] = updatedData;
            }
          });
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
              setState(() {
                scheduledItems.remove(item);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maintenance item deleted'),
                  backgroundColor: AppColors.criticalRed,
                  duration: Duration(seconds: 2),
                ),
              );
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
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
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
                  onAdd: (maintenanceData) {
                    setState(() {
                      scheduledItems.insert(0, maintenanceData);
                    });
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
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Maintenance',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      'Track maintenance activities',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    TextField(
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                      ),
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
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkCardBackground
                            : AppColors.cardBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
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

                    // Tab Content
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
      bottomNavigationBar: NavBar(
        currentIndex: 3,
        onTap: (index) => _onNavTap(context, index),
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
