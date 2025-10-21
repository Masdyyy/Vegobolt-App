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

  // Toggle between production and development
  // Set to true for production, false for local testing
  static const bool useProduction = false;

  // Automatically detect platform and use correct URL
  static String get baseUrl {
    // Use production if enabled
    if (useProduction) {
      return productionUrl;
    }

    // Otherwise use local development URLs
    if (kIsWeb) {
      // Web browser (Chrome, Edge, etc.)
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      // Android real device (use your PC's LAN IP)
      return 'http://10.141.161.224:3000';
    } else if (Platform.isIOS) {
      // iOS Simulator
      return 'http://localhost:3000';
    } else {
      // Physical devices on same WiFi network
      return 'http://10.141.161.224:3000';
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

  // Helper method to get full URL
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
