import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/header.dart';
import '../utils/colors.dart';
import 'dashboard.dart';
import 'machine.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'settings.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});
  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  void _onNavTap(BuildContext context, int i) {
    if (i == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
      return;
    }
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

  void _viewGuide() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Troubleshooting Guide...')),
    );
    // Add your guide navigation logic here
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening Contact Support...')),
    );
    // Add your contact support logic here (email, form, etc.)
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
                  // Back button
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Find answers, contact support, and explore guides.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // TROUBLESHOOTING GUIDE CARD
                  _buildSupportCard(
                    title: 'Troubleshooting Guide',
                    description:
                        'Find solutions to common issues and frequently asked questions.',
                    icon: Icons.help_outline,
                    iconColor: AppColors.primaryGreen,
                    buttonLabel: 'View Guide',
                    onPressed: _viewGuide,
                  ),
                  const SizedBox(height: 16),

                  // CONTACT TECHNICAL SUPPORT CARD
                  _buildSupportCard(
                    title: 'Contact Technical Support',
                    description:
                        'Get in touch with our support team for personalized assistance.',
                    icon: Icons.mail_outline,
                    iconColor: AppColors.criticalRed,
                    buttonLabel: 'Contact Us',
                    onPressed: _contactSupport,
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

  // 🔧 Reusable Support Card Widget
  Widget _buildSupportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
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
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Icon and Description Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Description
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Button
          Center(
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: onPressed,
                child: Text(
                  buttonLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
