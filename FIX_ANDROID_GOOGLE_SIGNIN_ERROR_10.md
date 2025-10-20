# Fix Android Google Sign-In Error 10

## Problem
Getting error: `PlatformException(sign_in_failed, com.google.gms.common.api.ApiException: 10: , null, null)`

Error code 10 = `API_NOT_CONNECTED` - This means Google Play Services cannot authenticate because:
1. Missing `google-services.json` file
2. SHA-1 fingerprint not registered in Google Cloud Console
3. Wrong OAuth client configuration

## Your SHA-1 Fingerprint
```
SHA1: B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7
SHA-256: 89:47:D9:C1:29:5D:10:34:FB:83:E1:62:AF:CF:6C:8F:C4:D1:F4:68:39:6B:9C:84:4F:7F:39:7F:B1:D3:08:16
Package Name: com.example.vegobolt
```

## Solution Steps

### Step 1: Go to Google Cloud Console
1. Visit https://console.cloud.google.com/
2. Select your project (or create a new one if needed)
3. Enable these APIs:
   - Google+ API (or Google People API)
   - Google Identity Toolkit API

### Step 2: Configure OAuth 2.0 Client ID for Android

#### Option A: Using Firebase (RECOMMENDED)
1. Go to https://console.firebase.google.com/
2. Select/Create your project
3. Click on Project Settings (gear icon)
4. Scroll to "Your apps" section
5. Click "Add app" → Select Android
6. Register your app with:
   - **Package name**: `com.example.vegobolt`
   - **SHA-1 certificate**: `B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7`
7. Download the `google-services.json` file
8. Place it in: `vegobolt/android/app/google-services.json`

#### Option B: Using Google Cloud Console directly
1. Go to **APIs & Services** → **Credentials**
2. Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
3. If prompted, configure OAuth consent screen first
4. Select **Application type**: Android
5. Enter:
   - **Name**: Vegobolt Android
   - **Package name**: `com.example.vegobolt`
   - **SHA-1 certificate fingerprint**: `B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7`
6. Click **Create**

**Note**: With Option B, you still need a `google-services.json` file. You can generate it from Firebase or use a template.

### Step 3: Update Your OAuth Web Client (Already in use)
Your current Web client ID: `445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com`

Make sure this Web client ID is configured with:
- **Authorized JavaScript origins**: 
  - `http://localhost` (for local testing)
  - Your production web domain
- **Authorized redirect URIs**: 
  - `http://localhost` (for local testing)
  - Your production web domain

### Step 4: Place google-services.json
After downloading `google-services.json` from Firebase:
1. Place it at: `vegobolt/android/app/google-services.json`
2. Verify the file contains your package name: `com.example.vegobolt`

### Step 5: Verify Build Configuration (ALREADY DONE)
✅ Added Google Services plugin to `android/build.gradle.kts`
✅ Applied plugin in `android/app/build.gradle.kts`

### Step 6: Clean and Rebuild
```powershell
cd vegobolt
flutter clean
flutter pub get
cd android
.\gradlew clean
cd ..
```

### Step 7: Test on Android Device
```powershell
flutter run -d "adb-RRCX100T75R-q5L2TJ._adb-tls-connect._tcp"
```

## Important Notes

### For Production
When you create a release build, you'll need to:
1. Generate a release keystore
2. Get the SHA-1 from the release keystore
3. Add that SHA-1 to your Google Cloud/Firebase configuration
4. Update your `android/app/build.gradle.kts` with signing config

### Multiple SHA-1 Fingerprints
You can add multiple SHA-1 fingerprints to the same Android app in Firebase/Google Cloud:
- Debug SHA-1 (current): for development
- Release SHA-1: for production
- Team members' SHA-1s: if they test on their machines

### Troubleshooting
If you still get error 10 after following these steps:
1. Double-check package name matches exactly: `com.example.vegobolt`
2. Verify SHA-1 is correctly added in Google Cloud Console
3. Wait 5-10 minutes for changes to propagate
4. Clear app data and cache on your device
5. Uninstall and reinstall the app
6. Check that `google-services.json` is in the correct location

## Common Mistakes to Avoid
❌ Using Web client ID in Android config
❌ Wrong package name
❌ SHA-1 from different keystore
❌ Missing `google-services.json` file
❌ Not applying the google-services plugin
❌ Not waiting for changes to propagate

## Current Configuration Summary
- **Package Name**: `com.example.vegobolt`
- **Debug SHA-1**: `B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7`
- **Web Client ID**: `445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com`
- **Auth Service**: Using `serverClientId` for Android (correct approach)

## What I've Already Fixed
1. ✅ Added Google Services classpath to `android/build.gradle.kts`
2. ✅ Applied Google Services plugin to `android/app/build.gradle.kts`
3. ✅ Retrieved your SHA-1 fingerprint

## What You Need to Do
1. ⏳ Go to Firebase Console and add Android app with your SHA-1
2. ⏳ Download `google-services.json`
3. ⏳ Place `google-services.json` in `vegobolt/android/app/`
4. ⏳ Run `flutter clean` and rebuild
5. ⏳ Test Google Sign-In again

## Quick Command Reference
```powershell
# Get SHA-1 (already done)
cd vegobolt\android
.\gradlew signingReport

# Clean and rebuild
cd ..
flutter clean
flutter pub get

# Run on device
flutter run -d "adb-RRCX100T75R-q5L2TJ._adb-tls-connect._tcp"
```
