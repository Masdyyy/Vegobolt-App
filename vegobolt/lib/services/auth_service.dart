import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/api_config.dart';

/// Authentication Service
///
/// Handles all authentication-related API calls to the backend.
class AuthService {
  final _secureStorage = const FlutterSecureStorage();

  /// Login with email and password
  ///
  /// Returns a Map with:
  /// - success: bool
  /// - message: String
  /// - data: Map (contains user and token if successful)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse(ApiConfig.getUrl(ApiConfig.authLogin));

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Save token to secure storage
        final token = responseData['data']['token'];
        await _secureStorage.write(key: 'auth_token', value: token);

        // Save user email
        await _secureStorage.write(key: 'user_email', value: email);

        // Save user display name if available
        if (responseData['data']['user']['displayName'] != null) {
          await _secureStorage.write(
            key: 'user_display_name',
            value: responseData['data']['user']['displayName'],
          );
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Login/Register using Google ID token
  /// Pass the idToken obtained from google_sign_in
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final url = Uri.parse(ApiConfig.getUrl(ApiConfig.authGoogleLogin));

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final token = responseData['data']['token'];
        await _secureStorage.write(key: 'auth_token', value: token);

        // Save user email/displayName if available
        final user = responseData['data']['user'];
        if (user != null) {
          if (user['email'] != null) {
            await _secureStorage.write(key: 'user_email', value: user['email']);
          }
          if (user['displayName'] != null) {
            await _secureStorage.write(
              key: 'user_display_name',
              value: user['displayName'],
            );
          }
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Google login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Register a new user
  ///
  /// Returns a Map with:
  /// - success: bool
  /// - message: String
  /// - data: Map (contains user and token if successful)
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final url = Uri.parse(ApiConfig.getUrl(ApiConfig.authRegister));

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        // Save token to secure storage
        final token = responseData['data']['token'];
        await _secureStorage.write(key: 'auth_token', value: token);

        // Save user data
        await _secureStorage.write(key: 'user_email', value: email);
        
        // Save display name (auto-generated from firstName + lastName by backend)
        if (responseData['data']['user']['displayName'] != null) {
          await _secureStorage.write(
            key: 'user_display_name',
            value: responseData['data']['user']['displayName'],
          );
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Registration successful',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Get user profile
  ///
  /// Requires authentication token
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final url = Uri.parse(ApiConfig.getUrl(ApiConfig.authProfile));

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Profile retrieved',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Logout user
  ///
  /// Clears local storage and calls logout endpoint
  Future<Map<String, dynamic>> logout() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token != null) {
        final url = Uri.parse(ApiConfig.getUrl(ApiConfig.authLogout));

        // Call logout endpoint (optional, depends on backend implementation)
        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }

      // Clear all stored data
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_email');
      await _secureStorage.delete(key: 'user_display_name');

      return {'success': true, 'message': 'Logged out successfully'};
    } catch (e) {
      // Even if the API call fails, clear local data
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_email');
      await _secureStorage.delete(key: 'user_display_name');

      return {'success': true, 'message': 'Logged out locally'};
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  /// Get stored authentication token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
}
