import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/header.dart';
import '../../components/admin_navbar.dart';
import '../../utils/colors.dart';
import '../../utils/theme_provider.dart';
import '../login.dart';
import '../AccountSettings.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _enableNotifications = true;
  final int _currentIndex = 1; // Settings tab

  void _onNavTap(int index) {
    if (index == 0) {
      // Dashboard tab
      Navigator.pushReplacementNamed(context, '/admin-dashboard');
    }
    // If index is 1 (Settings), we're already here, so do nothing
  }

  void _logout() async {
    // Reset theme to light mode immediately before logout
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.resetToLightMode();

    // Show logout message with shorter duration
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logging out...'),
          duration: Duration(milliseconds: 500),
        ),
      );
    }

    // Navigate to login page
    Future.microtask(() {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
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
                  Text(
                    'Admin Settings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage admin preferences',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                    ),
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
                  // Dark Mode
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return _buildSettingTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        trailing: Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (v) => themeProvider.toggleTheme(),
                          activeThumbColor: AppColors.primaryGreen,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSettingTile(
                    icon: Icons.person_outline,
                    title: 'Account Settings',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.getTextSecondary(context),
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
          color: AppColors.getCardBackground(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.getTextPrimary(context), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(context),
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
