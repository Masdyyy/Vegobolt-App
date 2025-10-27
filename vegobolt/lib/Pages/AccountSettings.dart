import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/responsive_layout.dart';
import '../utils/navigation_helper.dart';
import 'dashboard.dart';
import 'machine.dart';
import 'alerts.dart';
import 'maintenance.dart';
import 'settings.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});
  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Profile Information Controllers
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  // Password Controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

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

  void _saveProfileChanges() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile information updated successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  // Password validation function that shows all requirements
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }

    List<String> errors = [];

    if (value.length < 8) {
      errors.add('at least 8 characters');
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      errors.add('1 uppercase letter');
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      errors.add('1 lowercase letter');
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      errors.add('1 number');
    }
    // include a broader set of special characters for safety
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\\/]').hasMatch(value)) {
      errors.add('1 special character');
    }

    if (errors.isNotEmpty) {
      return 'Password must have: ${errors.join(', ')}';
    }

    return null;
  }

  void _savePassword() {
    if (_passwordFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      _currentPasswordController.clear();
      _newPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final responsivePadding = responsive.getValue(
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );

    return AdaptiveScaffold(
      title: 'Account Settings',
      currentIndex: 4,
      onNavigationChanged: (i) => _onNavTap(context, i),
      navigationItems: const [
        NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
        NavigationItem(icon: Icons.precision_manufacturing, label: 'Machine'),
        NavigationItem(icon: Icons.warning_amber, label: 'Alerts'),
        NavigationItem(icon: Icons.build, label: 'Maintenance'),
        NavigationItem(icon: Icons.settings, label: 'Settings'),
      ],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFFF5F5F5),
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2D2D2D)
                  : Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Header
              Padding(
                padding: EdgeInsets.all(responsivePadding),
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
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Text(
                        'Manage your profile and security',
                        style: TextStyle(
                          color: AppColors.getTextSecondary(context),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Scrollable Content
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsivePadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PROFILE INFORMATION CARD
                            _buildProfileSection(),
                            const SizedBox(height: 24),

                            // SECURITY CARD
                            _buildSecuritySection(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Profile Information Section
  Widget _buildProfileSection() {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 20),

            // Email Address
            Text(
              'Email Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: AppColors.getTextPrimary(context)),
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: TextStyle(
                  color: AppColors.getTextSecondary(context),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCardBackground
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Full Name
            Text(
              'Full Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: AppColors.getTextPrimary(context)),
              decoration: InputDecoration(
                hintText: 'Full Name',
                hintStyle: TextStyle(
                  color: AppColors.getTextSecondary(context),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCardBackground
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address
            Text(
              'Address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              style: TextStyle(color: AppColors.getTextPrimary(context)),
              decoration: InputDecoration(
                hintText: 'Address',
                hintStyle: TextStyle(
                  color: AppColors.getTextSecondary(context),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCardBackground
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Save Changes Button
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _saveProfileChanges,
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

  // Security Section
  Widget _buildSecuritySection() {
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
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 12),

            // Change Password Header
            Text(
              'Change Password',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you change your password, we keep you logged in to this device but may logged out from other devices.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.getTextSecondary(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Current Password
            Text(
              'Current Password *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              style: TextStyle(color: AppColors.getTextPrimary(context)),
              decoration: InputDecoration(
                hintText: 'Enter Current Password',
                hintStyle: TextStyle(
                  color: AppColors.getTextSecondary(context),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCardBackground
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // New Password
            Text(
              'New Password *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              style: TextStyle(color: AppColors.getTextPrimary(context)),
              decoration: InputDecoration(
                hintText: 'Enter New Password',
                hintStyle: TextStyle(
                  color: AppColors.getTextSecondary(context),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCardBackground
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              validator: _validatePassword,
            ),
            const SizedBox(height: 20),

            // Save Password Button
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _savePassword,
                  child: const Text(
                    'Save Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
}
