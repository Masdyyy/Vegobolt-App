import 'package:flutter/material.dart';
import '../../components/header.dart';
import '../../components/admin_navbar.dart';
import '../../utils/colors.dart';
import '../login.dart';
import '../AccountSettings.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _enableNotifications = true;
  bool _autoRefresh = true;
  final int _currentIndex = 1; // Settings tab

  void _onNavTap(int index) {
    if (index == 0) {
      // Dashboard tab
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    }
    // If index is 1 (Settings), we're already here, so do nothing
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
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Settings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Manage admin preferences',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // Settings Options
                  _buildSettingTile(
                    icon: Icons.notifications_outlined,
                    title: 'Enable Notifications',
                    trailing: Switch(
                      value: _enableNotifications,
                      onChanged: (v) =>
                          setState(() => _enableNotifications = v),
                      activeThumbColor: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingTile(
                    icon: Icons.refresh_outlined,
                    title: 'Auto Refresh',
                    trailing: Switch(
                      value: _autoRefresh,
                      onChanged: (v) => setState(() => _autoRefresh = v),
                      activeThumbColor: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingTile(
                    icon: Icons.person_outline,
                    title: 'Account Settings',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AccountSettingsPage(isAdmin: true),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
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
      bottomNavigationBar: AdminNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            trailing,
          ],
        ),
      ),
    );
  }
}
