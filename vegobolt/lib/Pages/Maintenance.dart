import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/header.dart';
import '../components/add_maintenance_modal.dart';
import '../utils/colors.dart';
import 'dashboard.dart';
import 'machine.dart';
import 'alerts.dart';
import 'settings.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isHovering = false;

  // Scheduled maintenance items
  List<Map<String, dynamic>> scheduledItems = [
    {
      'title': 'Oil Refill',
      'machineId': 'VB-0001',
      'location': 'Sarangay 171',
      'scheduledDate': DateTime(2025, 10, 18),
      'priority': 'High',
      'priorityColor': Colors.red,
    },
    {
      'title': 'Filter Replacement',
      'machineId': 'VB-0001',
      'location': 'Sarangay 171',
      'scheduledDate': DateTime(2025, 10, 21),
      'priority': 'High',
      'priorityColor': Colors.red,
    },
    {
      'title': 'Battery replacement',
      'machineId': 'VB-0001',
      'location': 'Sarangay 171',
      'scheduledDate': DateTime(2025, 10, 24),
      'priority': 'Medium',
      'priorityColor': const Color(0xFFFFD700),
    },
  ];

  // History items
  List<Map<String, dynamic>> historyItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  Future<void> _rescheduleItem(Map<String, dynamic> item) async {
    final now = DateTime.now();
    final currentDate = item['scheduledDate'] as DateTime?;

    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        item['scheduledDate'] = picked;
      });

      // Show confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Maintenance rescheduled to ${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}',
            ),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 3) return; // already in Maintenance page

    Widget destination;
    switch (index) {
      case 0:
        destination = const DashboardPage();
        break;
      case 1:
        destination = const MachinePage();
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
                    const Text(
                      'Maintenance',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    const Text(
                      'Track maintenance activities',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search maintenance records...',
                        hintStyle: const TextStyle(color: AppColors.textLight),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.cardBackground,
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: const Color(0xFF808080),
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
      return const Center(
        child: Text(
          'No scheduled maintenance',
          style: TextStyle(color: Color(0xFF808080), fontSize: 16),
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
          onReschedule: () => _rescheduleItem(item),
          onResolve: () => _resolveItem(item),
          isHistory: false,
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (historyItems.isEmpty) {
      return const Center(
        child: Text(
          'No history records',
          style: TextStyle(color: Color(0xFF808080), fontSize: 16),
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
    required VoidCallback onReschedule,
    required VoidCallback onResolve,
    required bool isHistory,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
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
          const SizedBox(height: 8),
          Text(
            '$machineId • $location',
            style: const TextStyle(color: Color(0xFF808080), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Color(0xFFAAAAAA),
              ),
              const SizedBox(width: 4),
              Text(
                scheduledDate != null
                    ? '${scheduledDate.month.toString().padLeft(2, '0')}/${scheduledDate.day.toString().padLeft(2, '0')}/${scheduledDate.year}'
                    : 'Not scheduled',
                style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReschedule,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Reschedule',
                    style: TextStyle(
                      color: Color(0xFF5A6B47),
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
                    backgroundColor: AppColors.primaryGreen,
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
        color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Machine: $machineId',
                  style: const TextStyle(
                    color: Color(0xFF808080),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFFAAAAAA),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFFAAAAAA),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      resolvedDate,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
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
