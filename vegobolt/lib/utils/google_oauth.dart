/// Google OAuth configuration for Flutter google_sign_in
///
/// Fill this with your Web OAuth 2.0 Client ID from Google Cloud Console.
/// This is required (especially on Android) to obtain a non-null idToken.
class GoogleOAuthConfig {
  // IMPORTANT: Provide your Web OAuth 2.0 Client ID from Google Cloud Console.
  // Preferred: pass it via --dart-define so you don't hardcode values:
  //   --dart-define=GOOGLE_WEB_CLIENT_ID=1234567890-abcdefg.apps.googleusercontent.com
  // Fallback: set the defaultValue here if you want it checked into source.
  static const String serverClientId =
      '1045365375193-5k5vvatq1qprf2d2h618h77fdbp2rli7.apps.googleusercontent.com';
}
