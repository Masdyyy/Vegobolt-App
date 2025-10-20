# Google Sign-In WITHOUT Firebase - Android Setup

## The Problem
Error 10 (`API_NOT_CONNECTED`) occurs because Google Sign-In for Android requires proper OAuth configuration in Google Cloud Console, even without Firebase.

## Your Current Configuration
- **Package Name**: `com.example.vegobolt`
- **SHA-1 Fingerprint**: `B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7`
- **Web Client ID**: `445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com`

## Solution: Configure Google Cloud Console Properly

### Step 1: Go to Google Cloud Console
1. Visit: https://console.cloud.google.com/
2. Select your project (the one with ID `445716724471`)
3. Go to **APIs & Services** → **Credentials**

### Step 2: Verify/Enable Required APIs
Go to **APIs & Services** → **Library** and enable:
1. **Google+ API** (or **People API**)
2. **Google Identity Toolkit API**

### Step 3: Create Android OAuth 2.0 Client ID

#### Check if you already have an Android client:
Look in your credentials list for an **Android** OAuth 2.0 Client ID.

#### If you DON'T have one, create it:
1. Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
2. If prompted, configure the **OAuth consent screen** first:
   - User Type: External (or Internal if using Google Workspace)
   - App name: Vegobolt
   - User support email: Your email
   - Add scopes: email, profile, openid
   - Add test users if needed
   - Save and continue

3. After consent screen is configured:
   - Click **"+ CREATE CREDENTIALS"** → **"OAuth client ID"**
   - **Application type**: Select **"Android"**
   - **Name**: `Vegobolt Android Client`
   - **Package name**: `com.example.vegobolt`
   - **SHA-1 certificate fingerprint**: `B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7`
   - Click **Create**

4. **IMPORTANT**: Copy the **Android Client ID** that's generated (it will look like `XXXXX.apps.googleusercontent.com`)

### Step 4: Verify Your Web OAuth Client
Make sure your existing Web client (`445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com`) has:
- **Authorized JavaScript origins**:
  - `http://localhost` (for local web testing)
  - `http://localhost:5000` (or your web server port)
  - Your production domain
- **Authorized redirect URIs**:
  - `http://localhost`
  - Your production domain

### Step 5: Update Your Flutter Code

After creating the Android OAuth client, update `auth_service.dart`:

**Current configuration (using Web client for Android - WRONG):**
```dart
serverClientId: kIsWeb 
    ? null 
    : '445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com',
```

**Should be (use Android client ID):**
```dart
serverClientId: kIsWeb 
    ? null 
    : 'YOUR-ANDROID-CLIENT-ID.apps.googleusercontent.com',  // Use Android OAuth client ID here
```

**OR** you can remove `serverClientId` entirely and let Google Sign-In auto-detect:
```dart
late final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'profile',
    'openid',
  ],
  // For web, specify the Web client ID
  clientId: kIsWeb 
      ? '445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com'
      : null,
  // For Android/iOS, let it auto-detect from google-services.json
  // Since we're not using Firebase, we DON'T specify serverClientId
  // The Android OAuth client is detected via package name + SHA-1
);
```

### Step 6: Clean and Test

```powershell
cd vegobolt
flutter clean
flutter pub get
flutter run -d "adb-RRCX100T75R-q5L2TJ._adb-tls-connect._tcp"
```

## How It Works Without Firebase

### For Android:
1. Google Sign-In plugin uses your **package name** (`com.example.vegobolt`)
2. Google Play Services on the device generates a signature from your app's signing key (SHA-1)
3. Google's servers verify: "Does this app (package + SHA-1) have an Android OAuth client?"
4. If YES → Sign-in succeeds
5. If NO → Error 10 (`API_NOT_CONNECTED`)

### For Web:
1. Uses the `clientId` specified in `GoogleSignIn()` constructor
2. Verifies against JavaScript origins configured in Web OAuth client

### For Backend Verification:
Your backend receives the `idToken` and verifies it using:
```javascript
const ticket = await client.verifyIdToken({
    idToken: idToken,
    audience: process.env.GOOGLE_CLIENT_ID, // Your Web client ID
});
```

## Important Notes

### You Need TWO OAuth Clients:
1. **Web OAuth Client** (already have): `445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com`
   - Used for: Web app, backend token verification
   
2. **Android OAuth Client** (need to create): `XXXXX-YYYYY.apps.googleusercontent.com`
   - Used for: Android app sign-in
   - Configured with: Package name + SHA-1

### Why Error 10 Happens:
❌ You're trying to use the **Web client ID** on Android
❌ Google Play Services looks for an **Android OAuth client** with your package name + SHA-1
❌ Can't find it → Returns error 10

### The Fix:
✅ Create **Android OAuth client** in Google Cloud Console
✅ Add your package name: `com.example.vegobolt`
✅ Add your SHA-1: `B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7`
✅ Either specify the Android client ID in `serverClientId`, OR
✅ Remove `serverClientId` and let it auto-detect via package name + SHA-1

## Recommended Approach (Simplest)

**Remove `serverClientId` entirely:**

```dart
late final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile', 'openid'],
  clientId: kIsWeb 
      ? '445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com'
      : null,
  // Don't specify serverClientId - let Google Play Services find it
);
```

Then Google Play Services will automatically find your Android OAuth client based on:
- Package name match: `com.example.vegobolt`
- SHA-1 match: `B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7`

## Quick Checklist

- [ ] Go to Google Cloud Console → APIs & Services → Credentials
- [ ] Create Android OAuth 2.0 Client ID
- [ ] Add package name: `com.example.vegobolt`
- [ ] Add SHA-1: `B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7`
- [ ] Update `auth_service.dart` (remove or update `serverClientId`)
- [ ] Run `flutter clean && flutter pub get`
- [ ] Test Google Sign-In on Android device

## Troubleshooting

### Still getting Error 10?
1. Double-check package name is **exactly** `com.example.vegobolt`
2. Verify SHA-1 is correctly added (copy-paste to avoid typos)
3. Wait 5-10 minutes for Google's servers to propagate changes
4. Clear app data on device: Settings → Apps → Vegobolt → Storage → Clear data
5. Uninstall and reinstall the app
6. Check OAuth consent screen is configured and app is not suspended

### Check if OAuth client is working:
After adding the Android OAuth client, you can verify it's working by:
1. Checking Google Cloud Console → Credentials
2. Click on your Android OAuth client
3. Verify package name and SHA-1 are listed
4. Status should be "Active"

## What I've Done
✅ Removed Firebase google-services plugin (not needed)
✅ Retrieved your SHA-1 fingerprint
✅ Identified the issue: Missing Android OAuth client

## What You Need to Do
⏳ Go to Google Cloud Console and create Android OAuth client
⏳ Add your package name and SHA-1
⏳ Update `auth_service.dart` (optional: remove `serverClientId`)
⏳ Clean and rebuild
⏳ Test Google Sign-In
