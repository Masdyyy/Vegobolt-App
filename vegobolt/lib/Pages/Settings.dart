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

  void _showShutdownConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.criticalRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.power_settings_new,
                    size: 48,
                    color: AppColors.criticalRed,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Shutdown Station',
                  style: TextStyle(
                    fontSize: 22,
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
                    fontSize: 15,
                    color: AppColors.getTextSecondary(context),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: AppColors.getTextSecondary(context),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.getTextPrimary(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Shutting down station...')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.criticalRed,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Shutdown',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
      bottomNavigationBar: NavBar(
        currentIndex: 4,
        onTap: (index) => _onNavTap(context, index),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 4),
                    Text(
                      'Manage your account and preferences',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // MACHINE CONTROL
                    _buildExpandableCard(
                      title: 'Machine Control',
                      icon: Icons.settings_outlined,
                      expanded: _isMachineExpanded,
                      onExpand: (v) => setState(() => _isMachineExpanded = v),
                      children: [
                        MachineControlButton(
                          label: 'Shutdown Station',
                          icon: Icons.power_settings_new,
                          color: AppColors.criticalRed,
                          onPressed: () => _showShutdownConfirmation(context),
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
}
