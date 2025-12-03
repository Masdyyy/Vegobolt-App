import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import '../utils/google_oauth.dart';

class GoogleSignInService {
  // Always use your Web client ID for both clientId (Web) and serverClientId (Android/iOS)
  static const String webClientId =
      '1045365375193-5k5vvatq1qprf2d2h618h77fdbp2rli7.apps.googleusercontent.com';

  // IMPORTANT: Add your Web Client Secret from Google Cloud Console
  // Go to: APIs & Services → Credentials → Web client 1 → Copy Client Secret
  static const String webClientSecret = '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';

  // Redirect URI for Windows desktop app
  static const String redirectUri = 'http://localhost:8080/auth';

  late final GoogleSignIn? _googleSignIn =
      (kIsWeb || (!kIsWeb && !Platform.isWindows))
      ? (kIsWeb
            ? GoogleSignIn(
                scopes: <String>['email', 'profile'],
                clientId: webClientId,
              )
            : GoogleSignIn(
                scopes: <String>['email', 'profile'],
                serverClientId: webClientId,
              ))
      : null; // Don't initialize GoogleSignIn on Windows

  Future<String?> signInAndGetIdToken() async {
    // Use web-based OAuth for Windows
    if (!kIsWeb && Platform.isWindows) {
      return _signInWindows();
    }

    // Original implementation for mobile and web
    try {
      await _googleSignIn?.signOut();
    } catch (_) {}

    final account = await _googleSignIn?.signIn();
    if (account == null) return null; // user canceled

    final auth = await account.authentication;
    // idToken is what we need to send to backend; accessToken is optional
    return auth.idToken;
  }

  Future<String?> _signInWindows() async {
    try {
      // Build OAuth URL
      final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
        'client_id': webClientId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'scope': 'email profile',
        'access_type': 'offline',
      });

      print('🔵 Opening OAuth URL: $authUrl');

      // Launch OAuth flow in browser
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'http://localhost:8080',
      );

      print('🔵 Callback result: $result');

      // Extract authorization code from callback
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        print('❌ No authorization code received');
        return null;
      }

      print('🔵 Got authorization code, exchanging for token...');

      // Exchange code for tokens
      final tokenResponse = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'code': code,
          'client_id': webClientId,
          'client_secret': webClientSecret,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code',
        },
      );

      print('🔵 Token response status: ${tokenResponse.statusCode}');
      print('🔵 Token response body: ${tokenResponse.body}');

      if (tokenResponse.statusCode == 200) {
        final tokens = json.decode(tokenResponse.body);
        print('✅ Got ID token!');
        return tokens['id_token'] as String?;
      }

      print('❌ Token exchange failed');
      return null;
    } catch (e, stackTrace) {
      print('❌ Windows Google Sign-In error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
