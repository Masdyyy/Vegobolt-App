# Google Sign-In Web Fix (GIS Migration)

## Problem
The Google Sign-In popup was closing immediately without completing authentication on web. This is because `google_sign_in_web` v0.12+ migrated to Google Identity Services (GIS), which deprecated the old OAuth flow.

## Changes Made

### 1. Updated `auth_service.dart`
- Added `signInSilently()` for web to check for existing sessions first
- Added `forceCodeForRefreshToken: true` to GoogleSignIn configuration
- This follows the new GIS-compatible authentication flow

### 2. Updated `index.html`
- Removed the old `<script src="https://accounts.google.com/gsi/client">` tag
- The `google_sign_in_web` plugin now loads the GIS library automatically
- Kept the `meta` tag with your client ID (this is still required)

## How It Works Now

1. **Web Platform**: 
   - First tries `signInSilently()` to check for existing Google sessions
   - If no session exists, falls back to interactive `signIn()`
   - Uses the new GIS popup flow automatically

2. **Mobile Platforms**:
   - Continues to use the native OAuth flow
   - No changes needed for Android/iOS

## Additional Troubleshooting

If the popup still closes immediately, try these steps:

### Step 1: Clear Browser Cache
```powershell
# Stop the running app
# Then clear Flutter web cache
flutter clean
flutter pub get
```

### Step 2: Verify OAuth Configuration
Check your Google Cloud Console:
1. Go to: https://console.cloud.google.com/
2. Select your project
3. Navigate to: APIs & Services > Credentials
4. Find your Web OAuth 2.0 Client ID
5. Verify **Authorized JavaScript origins** includes:
   - `http://localhost:52438` (or whatever port your app uses)
   - `http://localhost:3000`
   - `https://vegobolt-app.vercel.app` (for production)

6. Verify **Authorized redirect URIs** includes:
   - `http://localhost:52438/` 
   - `https://vegobolt-app.vercel.app/`

### Step 3: Test with Different Browsers
Some browsers have stricter popup policies. Test with:
- Chrome (recommended)
- Edge
- Firefox

### Step 4: Check for Popup Blockers
Make sure your browser isn't blocking popups from `accounts.google.com`

### Step 5: Enable Debug Logging
Add this to your `main.dart` to see detailed Google Sign-In logs:

```dart
void main() {
  // Enable Google Sign-In debug logging
  if (kDebugMode) {
    GoogleSignIn.enableDebugMode = true;
  }
  
  runApp(const MyApp());
}
```

## Testing the Fix

1. **Hot Restart** (not Hot Reload):
   ```powershell
   # Press 'R' in the terminal where flutter run is active
   # Or stop and restart:
   flutter run -d chrome --web-port=52438
   ```

2. Click the Google Sign-In button
3. You should see a proper Google OAuth popup
4. Select your account
5. The popup should close and return an ID token

## Expected Flow

```
User clicks "Sign in with Google"
↓
App calls signInSilently() [web only]
↓
If no session: Opens Google OAuth popup
↓
User selects account and grants permissions
↓
Popup closes with authorization code
↓
Plugin exchanges code for ID token
↓
App sends ID token to backend
↓
Backend verifies and creates session
↓
User is signed in
```

## Migration Reference

Official migration guide: https://pub.dev/packages/google_sign_in_web#migrating-to-v011-and-v012-google-identity-services

## Backend Verification

Make sure your backend (`/api/auth/google`) properly:
1. Accepts the `idToken` in the request body
2. Verifies the token with Google
3. Returns user data and your app's authentication token

## Common Errors and Solutions

| Error | Solution |
|-------|----------|
| "popup_closed_by_user" | User closed popup - normal behavior |
| "access_denied" | User clicked "Cancel" - normal behavior |
| "popup_blocked_by_browser" | Disable popup blocker or add exception |
| "idpiframe_initialization_failed" | Check if 3rd-party cookies are enabled |
| "Failed to get Google ID token" | OAuth misconfiguration - check console settings |

## Next Steps

1. Stop your Flutter web app (if running)
2. Run: `flutter clean && flutter pub get`
3. Restart: `flutter run -d chrome --web-port=52438`
4. Test the Google Sign-In flow
5. Check browser console for any errors

If issues persist, check the browser's Developer Console (F12) for specific error messages.
