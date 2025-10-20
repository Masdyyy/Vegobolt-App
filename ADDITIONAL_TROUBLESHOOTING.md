# Troubleshooting Error 10 - OAuth Config is Correct

## ✅ What's Confirmed Working
- Package name matches: `com.example.vegobolt`
- SHA-1 matches: `B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7`
- Android OAuth client exists in Google Cloud Console

## ✅ What I Just Fixed
- Added INTERNET permission to AndroidManifest.xml
- Added ACCESS_NETWORK_STATE permission

## 🔍 Additional Things to Check

### 1. Enable Required APIs in Google Cloud Console

Go to: https://console.cloud.google.com/apis/library

Make sure these APIs are **ENABLED**:

#### Required APIs:
1. **Google+ API** (or **People API**)
   - Search for "Google+ API" or "People API"
   - Click on it
   - Click "ENABLE" if not already enabled

2. **Google Identity Toolkit API**
   - Search for "Identity Toolkit API"
   - Click on it
   - Click "ENABLE" if not already enabled

3. **Google Sign-In API** (if available)

### 2. Check OAuth Consent Screen

Go to: https://console.cloud.google.com/apis/credentials/consent

Verify:
- ✅ OAuth consent screen is configured
- ✅ Publishing status: "Testing" or "In Production"
- ✅ If "Testing", your Google account is added to test users
- ✅ Scopes include: `email`, `profile`, `openid`

**Important**: If your OAuth consent screen is in "Testing" mode, you MUST add your Google account as a test user!

### 3. Clear App Data and Cache on Device

On your Android device:
1. Go to **Settings** → **Apps** → **Vegobolt**
2. Tap **Storage**
3. Tap **Clear Storage** (or Clear Data)
4. Tap **Clear Cache**

This clears any cached authentication state.

### 4. Clear Google Play Services Cache

On your Android device:
1. Go to **Settings** → **Apps** → **Google Play Services**
2. Tap **Storage**
3. Tap **Clear Cache** (DON'T clear data, just cache)

### 5. Completely Reinstall the App

```powershell
cd vegobolt

# Uninstall from device
flutter clean
adb uninstall com.example.vegobolt

# Reinstall
flutter pub get
flutter run -d "adb-RRCX100T75R-q5L2TJ._adb-tls-connect._tcp"
```

### 6. Wait for Propagation

If you just updated the OAuth client:
- Google's servers need 5-15 minutes to propagate changes
- Sometimes can take up to 1 hour
- Try again after waiting

### 7. Check Google Play Services Version

Error 10 can occur if Google Play Services is outdated:
1. On device, open **Google Play Store**
2. Search for "**Google Play Services**"
3. Update if available

### 8. Verify OAuth Client is Active

In Google Cloud Console:
1. Go to **APIs & Services** → **Credentials**
2. Click on your Android OAuth client
3. Verify status is not "Suspended" or "Disabled"
4. Check that there are no warnings or errors

### 9. Check if Multiple OAuth Clients Exist

Sometimes having multiple Android OAuth clients with the same package name can cause conflicts:
1. Go to **APIs & Services** → **Credentials**
2. Check if there are multiple "Android" OAuth clients
3. If yes, make sure the one with your SHA-1 is the active one
4. Consider deleting old/duplicate ones

### 10. Test with Different Google Account

Try signing in with a different Google account:
- If your OAuth consent screen is in "Testing" mode, use a test user account
- Try a personal Gmail account
- Try a different Google Workspace account

## 🔄 Complete Reset Process

If nothing works, do a complete reset:

```powershell
cd vegobolt

# 1. Clean everything
flutter clean
cd android
.\gradlew clean
cd ..

# 2. Uninstall from device
adb uninstall com.example.vegobolt

# 3. Get dependencies
flutter pub get

# 4. Reinstall
flutter run -d "adb-RRCX100T75R-q5L2TJ._adb-tls-connect._tcp"
```

Then on device:
1. Clear Google Play Services cache
2. Clear Vegobolt app data
3. Try Google Sign-In again

## 🐛 Debug Information to Collect

If still not working, check these:

### In Google Cloud Console:
- [ ] OAuth consent screen status (Testing/In Production)
- [ ] Your email is in test users (if Testing mode)
- [ ] APIs enabled: Google+ API, Identity Toolkit API
- [ ] Android OAuth client shows correct package + SHA-1
- [ ] No errors or warnings on OAuth client

### On Device:
- [ ] Google Play Services is up to date
- [ ] Device has internet connection
- [ ] Account used for sign-in is a test user (if consent screen is in Testing)

### In Your App:
- [ ] `com.example.vegobolt` package name in build.gradle
- [ ] INTERNET permission in AndroidManifest.xml
- [ ] google_sign_in plugin version is compatible

## Alternative: Try serverClientId Approach

Even though auto-detection should work, you can explicitly specify the Android client ID:

In `lib/services/auth_service.dart`, find the GoogleSignIn initialization and try:

```dart
late final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile', 'openid'],
  clientId: kIsWeb 
      ? '445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com'
      : null,
  // Try explicitly setting the Android OAuth client ID
  serverClientId: kIsWeb
      ? null
      : 'YOUR-ANDROID-CLIENT-ID.apps.googleusercontent.com', // Copy from Google Cloud Console
);
```

Replace `YOUR-ANDROID-CLIENT-ID` with the actual client ID of your Android OAuth client.

## Get Your Android OAuth Client ID

1. Go to: https://console.cloud.google.com/apis/credentials
2. Click on your **Android** OAuth 2.0 Client
3. Copy the **Client ID** (looks like: `XXXXX-YYYYY.apps.googleusercontent.com`)
4. Use that in `serverClientId` above

## Test Command

After making any changes:

```powershell
cd vegobolt
flutter clean
flutter pub get
adb uninstall com.example.vegobolt
flutter run -d "adb-RRCX100T75R-q5L2TJ._adb-tls-connect._tcp"
```

---

## Most Likely Causes (in order):

1. **OAuth Consent Screen in Testing mode** - Your Google account not added as test user
2. **Google Play Services needs cache cleared** - Old cached config
3. **Required APIs not enabled** - Google+ API or Identity Toolkit API
4. **Recent changes need time to propagate** - Wait 15 minutes
5. **Google Play Services outdated** - Update from Play Store

Try these in order! 🚀
