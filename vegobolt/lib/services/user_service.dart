import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/api_config.dart';

/// User Service
///
/// Handles user profile management and account operations
class UserService {
  final _secureStorage = const FlutterSecureStorage();

  /// Get user profile
  ///
  /// Returns user profile data including email, name, address, etc.
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final url = Uri.parse(ApiConfig.getUrl(ApiConfig.userProfile));

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
          'message': 'Profile retrieved successfully',
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

  /// Update user profile
  ///
  /// Updates user profile information (name, address, phone, etc.)
  Future<Map<String, dynamic>> updateProfile({
    String? email,
    String? firstName,
    String? lastName,
    String? displayName,
    String? address,
    String? phoneNumber,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final url = Uri.parse(ApiConfig.getUrl(ApiConfig.userProfile));

      // Build request body with only provided fields
      final Map<String, dynamic> body = {};
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (displayName != null) body['displayName'] = displayName;
      if (address != null) body['address'] = address;
      if (phoneNumber != null) body['phoneNumber'] = phoneNumber;

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Update stored user display name if changed
        if (responseData['data']?['user']?['displayName'] != null) {
          await _secureStorage.write(
            key: 'user_display_name',
            value: responseData['data']['user']['displayName'],
          );
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Profile updated successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Change password
  ///
  /// Changes the user's password after verifying current password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final url = Uri.parse(ApiConfig.getUrl(ApiConfig.authChangePassword));

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Delete user account
  ///
  /// Permanently deletes the user's account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');

      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final url = Uri.parse(ApiConfig.getUrl(ApiConfig.userAccount));

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Clear all stored data
        await _secureStorage.delete(key: 'auth_token');
        await _secureStorage.delete(key: 'user_email');
        await _secureStorage.delete(key: 'user_display_name');

        return {
          'success': true,
          'message': responseData['message'] ?? 'Account deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete account',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
