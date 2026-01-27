import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/responsive_layout.dart';
import '../utils/navigation_helper.dart';
import 'dashboard.dart';
import 'machine.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'Settings.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});
  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  bool _isGuideExpanded = false;
  bool _isContactExpanded = false;

  void _onNavTap(BuildContext context, int i) {
    if (i == 4) return; // Already on Settings-related page

    final pages = [
      const DashboardPage(),
      const MachinePage(),
      const AlertsPage(),
      const MaintenancePage(),
      const SettingsPage(),
    ];
    NavigationHelper.navigateWithoutAnimation(context, pages[i]);
  }

  void _viewGuide() {
    setState(() {
      _isGuideExpanded = !_isGuideExpanded;
    });
  }

  void _toggleContactInfo() {
    setState(() {
      _isContactExpanded = !_isContactExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveScaffold(
      title: 'Help & Support',
      currentIndex: 4,
      onNavigationChanged: (index) => _onNavTap(context, index),
      navigationItems: const [
        NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
        NavigationItem(icon: Icons.oil_barrel, label: 'Tanks'),
        NavigationItem(icon: Icons.warning_amber, label: 'Alerts'),
        NavigationItem(icon: Icons.build, label: 'Maintenance'),
        NavigationItem(icon: Icons.settings, label: 'Settings'),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
              isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed header at top
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: responsive.getValue(
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
                vertical: responsive.getValue(
                  mobile: 12,
                  tablet: 16,
                  desktop: 20,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Back button
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColors.getTextPrimary(context),
                    ),
                    onPressed: () {
                      NavigationHelper.navigateWithoutAnimation(
                        context,
                        const SettingsPage(),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help & Support',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find answers, contact support, and explore guides',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.getTextSecondary(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.getValue(
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                  vertical: 8,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TROUBLESHOOTING GUIDE CARD
                        _buildTroubleshootingCard(),
                        const SizedBox(height: 16),

                        // CONTACT TECHNICAL SUPPORT CARD
                        _buildContactSupportCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 Troubleshooting Guide Card with Expandable Content
  Widget _buildTroubleshootingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Title
          Text(
            'Troubleshooting Guide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
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
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Description
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Find solutions to common issues and frequently asked questions.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondary(context),
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
                onPressed: _viewGuide,
                child: Text(
                  _isGuideExpanded ? 'Hide Guide' : 'View Guide',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Expandable Content with Animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isGuideExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Common Issues Section
                      Text(
                        'Common Issues:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildIssueItem(
                        'Issue 1: Machine not responding.',
                        'Make sure the vendo machine is powered on and the container is properly placed. Check that there\'s no blockage in the oil dispensing system.',
                      ),
                      const SizedBox(height: 12),

                      _buildIssueItem(
                        'Issue 2: App not showing updated data.',
                        'If the collected oil amount is not updating, refresh the app or log out and log back in. Ensure the machine has finished processing the oil before checking.',
                      ),
                      const SizedBox(height: 12),

                      _buildIssueItem(
                        'Issue 3: Oil not being measured correctly.',
                        'Verify that the oil container is clean and free from sediment. Ensure you are using the required limit for accurate measurement.',
                      ),
                      const SizedBox(height: 20),

                      // FAQs Section
                      Text(
                        'FAQs:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildFAQItem(
                        'Q: Can I use the machine without internet?',
                        'Yes, the machine works offline. Data will update in the app once it\'s synced.',
                      ),
                      const SizedBox(height: 12),

                      _buildFAQItem(
                        'Q: Do I need to pay with money?',
                        'No. Payment is done by depositing used cooking oil, which the machine measures.',
                      ),
                      const SizedBox(height: 12),

                      _buildFAQItem(
                        'Q: What type of oil can I bring?',
                        'Only used cooking oil.',
                      ),
                      const SizedBox(height: 12),

                      _buildFAQItem(
                        'Q: How will I know my oil was accepted?',
                        'Check the app to view the collected amount and confirm the transaction once processing is complete.',
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Helper widget for issue items
  Widget _buildIssueItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• $title',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.getTextSecondary(context),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget for FAQ items
  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.getTextSecondary(context),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // 🔧 Reusable Support Card Widget
  Widget _buildContactSupportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Title
          Text(
            'Contact Technical Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(context),
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
                  color: AppColors.criticalRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.mail_outline,
                  color: AppColors.criticalRed,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Description
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Get in touch with our support team for personalized assistance.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondary(context),
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
                onPressed: _toggleContactInfo,
                child: Text(
                  _isContactExpanded ? 'Hide Contact Info' : 'Contact Us',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Expandable Contact Information with Animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isContactExpanded
                ? Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email Support
                            _buildContactItem(
                              icon: Icons.email_outlined,
                              label: 'Email Support',
                              value: 'support@vegobolt.com',
                              iconColor: AppColors.primaryGreen,
                            ),
                            const SizedBox(height: 16),

                            // Phone Support
                            _buildContactItem(
                              icon: Icons.phone_outlined,
                              label: 'Email Support',
                              value: '+63 12 3456 789',
                              iconColor: AppColors.criticalRed,
                            ),
                            const SizedBox(height: 16),

                            // Support Hours
                            _buildContactItem(
                              icon: Icons.access_time_outlined,
                              label: 'Support Hours',
                              value: 'Monday - Friday: 9am - 6pm',
                              iconColor: AppColors.warningYellow,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // Helper widget for contact items
  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextSecondary(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
