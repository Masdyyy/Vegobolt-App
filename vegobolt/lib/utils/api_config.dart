import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration
///
/// This file contains the base URL and endpoints for the backend API.
/// Automatically detects the platform and uses the correct URL.
class ApiConfig {
  // 🚀 PRODUCTION URL (Vercel)
  static const String productionUrl = 'https://vegobolt-app.vercel.app';

  // 🧪 LOCAL DEVELOPMENT URL
  static const String developmentUrl = 'http://localhost:3000';

  // 🌐 mDNS LOCAL NETWORK URL (auto-discovery)
  // Works automatically when backend and app are on same WiFi
  static const String mdnsUrl = 'http://vegobolt.local:3000';

  // 📍 FALLBACK: Manual IP (change this to your computer's IP if mDNS doesn't work)
  static const String manualIpUrl = 'http://192.168.1.23:3000';

  // Toggle between production and development
  // Set to true for production, false for local testing
  static const bool useProduction = true;

  // Use manual IP instead of mDNS (for troubleshooting on mobile)
  static const bool useManualIp = false;

  // Automatically detect platform and use correct URL
  static String get baseUrl {
    print('🔍 Detecting platform...');

    // Use production if enabled
    if (useProduction) {
      print('✅ Using PRODUCTION: $productionUrl');
      return productionUrl;
    }

    // Otherwise use local development URLs
    if (kIsWeb) {
      // Web browser (Chrome, Edge, etc.)
      print('🌐 Platform: Web Browser → using localhost');
      return 'http://localhost:3000';
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // Desktop platforms
      print(
        '🖥️ Platform: Desktop (${Platform.operatingSystem}) → using localhost',
      );
      return developmentUrl;
    } else if (Platform.isAndroid) {
      // Android real device
      print('📱 Platform: Android');
      if (useManualIp) {
        print('   → using manual IP: $manualIpUrl');
        return manualIpUrl;
      } else {
        print('   → using mDNS: $mdnsUrl');
        return mdnsUrl;
      }
    } else if (Platform.isIOS) {
      // iOS devices
      print('📱 Platform: iOS');
      if (useManualIp) {
        print('   → using manual IP: $manualIpUrl');
        return manualIpUrl;
      } else {
        print('   → using mDNS: $mdnsUrl');
        return mdnsUrl;
      }
    } else {
      // Unknown platform
      print('❓ Platform: Unknown → using localhost');
      return developmentUrl;
    }
  }

  // API Endpoints
  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authGoogleLogin = '/api/auth/google';
  static const String authVerify = '/api/auth/verify';
  static const String authProfile = '/api/auth/profile';
  static const String authLogout = '/api/auth/logout';
  static const String authPasswordReset = '/api/auth/password-reset';
  static const String authResetPassword = '/api/auth/reset-password';
  static const String authChangePassword = '/api/auth/change-password';

  // User Endpoints
  static const String userProfile = '/api/users/profile';
  static const String userAccount = '/api/users/account';

  // Helper method to get full URL
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }

  // Maintenance endpoints
  static const String maintenanceBase = '/api/maintenance';
  static const String maintenanceList = maintenanceBase + '/';
}
