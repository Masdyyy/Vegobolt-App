import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/header.dart';
import '../utils/colors.dart';
import '../utils/navigation_helper.dart';
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
  bool _isGuideExpanded = false;
  bool _isContactExpanded = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _guideKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onNavTap(BuildContext context, int i) {
    if (i == 4) {
      NavigationHelper.navigateWithoutAnimation(
        context,
        const SettingsPage(),
      );
      return;
    }
    final pages = [
      const DashboardPage(),
      const MachinePage(),
      const AlertsPage(),
      const MaintenancePage(),
    ];
    NavigationHelper.navigateWithoutAnimation(context, pages[i]);
  }

  void _viewGuide() {
    setState(() {
      _isGuideExpanded = !_isGuideExpanded;
    });

    if (_isGuideExpanded) {
      // Scroll to the guide card after expansion animation
      Future.delayed(const Duration(milliseconds: 350), () {
        final RenderBox? renderBox =
            _guideKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero).dy;
          final scrollPosition =
              _scrollController.position.pixels + position - 100;

          _scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _toggleContactInfo() {
    setState(() {
      _isContactExpanded = !_isContactExpanded;
    });

    if (_isContactExpanded) {
      // Scroll to the contact card after expansion animation
      Future.delayed(const Duration(milliseconds: 350), () {
        final RenderBox? renderBox =
            _contactKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero).dy;
          final scrollPosition =
              _scrollController.position.pixels + position - 100;

          _scrollController.animateTo(
            scrollPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      bottomNavigationBar: NavBar(
        currentIndex: 4,
        onTap: (i) => _onNavTap(context, i),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find answers, contact support, and explore guides.',
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // TROUBLESHOOTING GUIDE CARD
                    _buildTroubleshootingCard(),
                    const SizedBox(height: 16),

                    // CONTACT TECHNICAL SUPPORT CARD
                    _buildContactSupportCard(),
                  ],
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
      key: _guideKey,
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
      key: _contactKey,
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
