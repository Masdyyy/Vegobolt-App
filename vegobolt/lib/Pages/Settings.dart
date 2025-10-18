import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/header.dart';
import '../components/machine_control_button.dart';
import '../utils/colors.dart';
import 'dashboard.dart';
import 'machine.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'login.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isMachineExpanded = false;
  bool _isNotifExpanded = false;
  bool _allNotif = true, _critical = true, _maintenance = false;

  void _onNavTap(BuildContext context, int i) {
    if (i == 4) return;
    final pages = [
      const DashboardPage(),
      const MachinePage(),
      const AlertsPage(),
      const MaintenancePage(),
    ];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pages[i]),
    );
  }

  void _logout() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logging out...')));
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage your app preference',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // MACHINE CONTROL
                    _buildExpandableCard(
                      title: 'Machine Control',
                      subtitle: 'Control your VEGOBOLT station remotely',
                      icon: Icons.settings_outlined,
                      expanded: _isMachineExpanded,
                      onExpand: (v) => setState(() => _isMachineExpanded = v),
                      children: [
                        MachineControlButton(
                          label: 'Restart Station',
                          icon: Icons.restart_alt,
                          color: AppColors.darkGreen,
                          onPressed: () => _showMsg('Restarting station...'),
                        ),
                        const SizedBox(height: 12),
                        MachineControlButton(
                          label: 'Shutdown Station',
                          icon: Icons.power_settings_new,
                          color: AppColors.criticalRed,
                          onPressed: () => _showMsg('Shutting down station...'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // NOTIFICATION SETTINGS
                    _buildExpandableCard(
                      title: 'Notification Settings',
                      subtitle: 'Manage notification preferences',
                      icon: Icons.notifications_none_outlined,
                      expanded: _isNotifExpanded,
                      onExpand: (v) => setState(() => _isNotifExpanded = v),
                      children: [
                        _buildSwitch(
                          'All Notifications',
                          'Enable push notifications',
                          _allNotif,
                          (v) => setState(() => _allNotif = v),
                        ),
                        _buildSwitch(
                          'Critical Alerts',
                          'Emergency notifications',
                          _critical,
                          (v) => setState(() => _critical = v),
                        ),
                        _buildSwitch(
                          'Maintenance Reminders',
                          'Scheduled maintenance alerts',
                          _maintenance,
                          (v) => setState(() => _maintenance = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ACCOUNT & HELP
                    _buildTile(Icons.person_outline, 'Account Settings', () {}),
                    const SizedBox(height: 8),
                    _buildTile(Icons.help_outline, 'Help & Support', () {}),
                    const SizedBox(height: 20),

                    // LOG OUT
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.criticalRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _logout,
                        child: const Text(
                          'Log out',
                          style:
                              TextStyle(color: Colors.white, fontSize: 16),
                        ),
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
        currentIndex: 4,
        onTap: (i) => _onNavTap(context, i),
      ),
    );
  }

  // 🔧 Reusable widgets
  Widget _buildExpandableCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool expanded,
    required Function(bool) onExpand,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          trailing: Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
          onExpansionChanged: onExpand,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(
    String title,
    String sub,
    bool val,
    ValueChanged<bool> onChanged,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    sub,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: val,
              onChanged: onChanged,
              activeThumbColor: AppColors.primaryGreen,
            ),
          ],
        ),
      );

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );

  void _showMsg(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
