import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/navbar.dart';
import '../components/header.dart';
import '../components/machine_control_button.dart';
import '../utils/colors.dart';
import '../utils/theme_provider.dart';
import 'dashboard.dart';
import 'machine.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'login.dart';
import 'HelpSupport.dart';
import 'AccountSettings.dart';

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
                    'Settings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage your app preference',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // MACHINE CONTROL
                  _buildExpandableCard(
                    title: 'Machine Control',
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

                  // APPEARANCE SETTINGS
                  _buildExpandableCard(
                    title: 'Appearance',
                    icon: Icons.palette_outlined,
                    expanded: false,
                    onExpand: (v) {},
                    children: [
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return _buildSwitch(
                            'Dark Mode',
                            'Switch between light and dark theme',
                            themeProvider.isDarkMode,
                            (v) => themeProvider.toggleTheme(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ACCOUNT & HELP
                  _buildTile(Icons.person_outline, 'Account Settings', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountSettingsPage(),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildTile(Icons.help_outline, 'Help & Support', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportPage(),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),

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
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    required IconData icon,
    required bool expanded,
    required Function(bool) onExpand,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          initiallyExpanded: expanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Row(
            children: [
              Icon(icon, color: AppColors.getTextPrimary(context), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
            ],
          ),
          subtitle: null,
          trailing: Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppColors.getTextSecondary(context),
          ),
          onExpansionChanged: onExpand,
          children: [
            Padding(
              // remove vertical gap between title and content
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
  ) => Padding(
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
                ),
              ),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: val,
          onChanged: onChanged,
          activeColor: AppColors.primaryGreen,
        ),
      ],
    ),
  );

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
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
          Icon(icon, color: AppColors.getTextPrimary(context), size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextPrimary(context),
            ),
          ),
        ],
      ),
    ),
  );

  void _showMsg(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
