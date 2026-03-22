import 'package:flutter/material.dart';
import '../../components/header.dart';
import '../../components/admin_navbar.dart';
import '../../utils/colors.dart';
import '../../services/maintenance_service.dart';

class AdminHistoryPage extends StatefulWidget {
  const AdminHistoryPage({super.key});

  @override
  State<AdminHistoryPage> createState() => _AdminHistoryPageState();
}

class _AdminHistoryPageState extends State<AdminHistoryPage> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  List<Map<String, dynamic>> _history = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      final all = await _maintenanceService.list();
      final history = all.where((m) => (m['status'] ?? '').toString() != 'Scheduled').toList();
      setState(() => _history = history.cast<Map<String, dynamic>>());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'Resolved') return AppColors.primaryGreen;
    if (status == 'Canceled') return AppColors.warningYellow;
    return AppColors.criticalRed;
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
                  Text(
                    'Maintenance History',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.getTextPrimary(context)),
                  ),
                  const SizedBox(height: 8),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else if (_history.isEmpty)
                    Text('No history yet', style: TextStyle(color: AppColors.getTextSecondary(context)))
                  else
                    Column(
                      children: _history.map((m) {
                        final status = m['status'] ?? 'Resolved';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.getCardBackground(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m['title'] ?? '${m['machineId'] ?? ''} maintenance', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.getTextPrimary(context))),
                                    const SizedBox(height: 6),
                                    Text('${m['machineId'] ?? ''} • ${m['location'] ?? ''}', style: TextStyle(color: AppColors.getTextSecondary(context))),
                                    const SizedBox(height: 6),
                                    Text(m['updatedAt']?.toString() ?? m['resolvedDate']?.toString() ?? '', style: TextStyle(color: AppColors.getTextLight(context), fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: _getStatusColor(status), width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/admin-dashboard');
          if (index == 2) Navigator.pushReplacementNamed(context, '/admin-settings');
        },
      ),
    );
  }
}
