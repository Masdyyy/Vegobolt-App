import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/google_oauth.dart';

class GoogleSignInService {
  // Always use your Web client ID for both clientId (Web) and serverClientId (Android/iOS)
  static const String webClientId =
      '1045365375193-5k5vvatq1qprf2d2h618h77fdbp2rli7.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn = kIsWeb
      ? GoogleSignIn(
          scopes: <String>['email', 'profile'],
          clientId: webClientId,
        )
      : GoogleSignIn(
          scopes: <String>['email', 'profile'],
          serverClientId: webClientId,
        );

  Future<String?> signInAndGetIdToken() async {
    // Ensure any previous session is signed out to allow account picker
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    final account = await _googleSignIn.signIn();
    if (account == null) return null; // user canceled

    final auth = await account.authentication;
    // idToken is what we need to send to backend; accessToken is optional
    return auth.idToken;
  }
}
