import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/api_config.dart';

/// Authentication Service
/// 
/// Handles all authentication-related API calls to the backend.
class AuthService {
  final _secureStorage = const FlutterSecureStorage();
  
  // Google Sign-In instance - configured based on platform
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'openid',
    ],
    // For web, the client ID is set in index.html meta tag
    // For mobile platforms (Android/iOS), use serverClientId
    clientId: kIsWeb 
        ? '445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com'
        : null,
    serverClientId: kIsWeb 
        ? null 
        : '445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com',
  );
  
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
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
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
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
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
    String displayName,
  ) async {
    try {
      final url = Uri.parse(ApiConfig.getUrl(ApiConfig.authRegister));
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
        }),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201 && responseData['success'] == true) {
        // Save token to secure storage
        final token = responseData['data']['token'];
        await _secureStorage.write(key: 'auth_token', value: token);
        
        // Save user data
        await _secureStorage.write(key: 'user_email', value: email);
        await _secureStorage.write(key: 'user_display_name', value: displayName);
        
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
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
  
  /// Get user profile
  /// 
  /// Requires authentication token
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      
      if (token == null) {
        return {
          'success': false,
          'message': 'No authentication token found',
        };
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
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
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
      
      // Sign out from Google if signed in
      await signOutFromGoogle();
      
      // Clear all stored data
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_email');
      await _secureStorage.delete(key: 'user_display_name');
      await _secureStorage.delete(key: 'user_profile_picture');
      
      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      // Even if the API call fails, clear local data
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_email');
      await _secureStorage.delete(key: 'user_display_name');
      await _secureStorage.delete(key: 'user_profile_picture');
      
      return {
        'success': true,
        'message': 'Logged out locally',
      };
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
  
  /// Login with Google
  /// 
  /// Returns a Map with:
  /// - success: bool
  /// - message: String
  /// - data: Map (contains user and token if successful)
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // Use google_sign_in package for ALL platforms (web, mobile, desktop)
      print('[AuthService] Starting Google Sign-In...');
      
      GoogleSignInAccount? googleUser;
      
      // On web, clear any previous session first to ensure clean state
      if (kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {
          // Ignore any errors during sign-out
        }
        
        // For web, directly trigger interactive sign-in
        // Silent sign-in often doesn't work well on web
        googleUser = await _googleSignIn.signIn();
      } else {
        // On mobile, try silent sign-in first (checks for existing session)
        googleUser = await _googleSignIn.signInSilently();
        
        // If silent sign-in failed, trigger interactive sign-in
        if (googleUser == null) {
          // Make sure any previous session is cleared
          await _googleSignIn.signOut();
          
          // Now trigger the sign-in
          googleUser = await _googleSignIn.signIn();
        }
      }
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return {
          'success': false,
          'message': 'Google sign-in cancelled by user',
        };
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Get the ID token
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;
      
      // Debug logging
      print('Google Sign-In Debug:');
      print('- Email: ${googleUser.email}');
      print('- Display Name: ${googleUser.displayName}');
      print('- Has ID Token: ${idToken != null}');
      print('- Has Access Token: ${accessToken != null}');
      print('- Platform: ${kIsWeb ? "Web" : "Mobile"}');
      
      if (idToken == null) {
        // On web, if idToken is null, try to get it via serverAuthCode
        if (kIsWeb) {
          return {
            'success': false,
            'message': 'Failed to get Google ID token. Please ensure your Google OAuth client is configured correctly for web with authorized JavaScript origins.',
          };
        }
        
        return {
          'success': false,
          'message': 'Failed to get Google ID token',
        };
      }
      
      // Send ID token to backend for verification
      final url = Uri.parse(ApiConfig.getUrl('/api/auth/google'));
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idToken': idToken,
        }),
      );
      
      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        // Save token to secure storage
        final token = responseData['data']['token'];
        await _secureStorage.write(key: 'auth_token', value: token);
        
        // Save user data
        final user = responseData['data']['user'];
        await _secureStorage.write(key: 'user_email', value: user['email']);
        await _secureStorage.write(key: 'user_display_name', value: user['displayName']);
        
        // Save profile picture if available
        if (user['profilePicture'] != null) {
          await _secureStorage.write(key: 'user_profile_picture', value: user['profilePicture']);
        }
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Google login successful',
          'data': responseData['data'],
        };
      } else {
        // Sign out from Google if backend fails
        await _googleSignIn.signOut();
        
        return {
          'success': false,
          'message': responseData['message'] ?? 'Google login failed',
        };
      }
    } catch (e) {
      // Sign out from Google on error
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // Ignore sign-out errors
      }
      
      return {
        'success': false,
        'message': 'Google sign-in error: ${e.toString()}',
      };
    }
  }
  
  /// Sign out from Google (if signed in with Google)
  Future<void> signOutFromGoogle() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
    } catch (e) {
      // Ignore errors during Google sign-out
    }
  }
}
