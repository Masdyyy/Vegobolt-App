import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration
/// 
/// This file contains the base URL and endpoints for the backend API.
/// Automatically detects the platform and uses the correct URL.
class ApiConfig {
  // Automatically detect platform and use correct URL
  static String get baseUrl {
    if (kIsWeb) {
      // Web browser (Chrome, Edge, etc.)
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      // Android Emulator
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      // iOS Simulator
      return 'http://localhost:3000';
    } else {
      // Physical devices on same WiFi network
      return 'http://192.168.100.8:3000';
    }
  }
  
  // API Endpoints
  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authVerify = '/api/auth/verify';
  static const String authProfile = '/api/auth/profile';
  static const String authLogout = '/api/auth/logout';
  static const String authPasswordReset = '/api/auth/password-reset';
  
  // Helper method to get full URL
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
