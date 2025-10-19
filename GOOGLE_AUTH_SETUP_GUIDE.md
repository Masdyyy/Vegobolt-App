# Google Authentication Setup Guide

This guide will help you configure Google Authentication for the Vegobolt app.

## 📋 Prerequisites

1. Google Cloud Console account
2. Android Studio (for SHA-1 fingerprint)
3. Xcode (for iOS development - Mac only)

---

## 🌐 Step 1: Google Cloud Console Setup

### 1.1 Create/Select a Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing "Vegobolt" project
3. Note down your Project ID

### 1.2 Configure OAuth Consent Screen

1. Navigate to **APIs & Services** → **OAuth consent screen**
2. Select **External** user type
3. Fill in required information:
   - **App name**: Vegobolt
   - **User support email**: Your email
   - **Developer contact email**: Your email
4. Add scopes:
   - `userinfo.email`
   - `userinfo.profile`
5. Save and continue

### 1.3 Create OAuth 2.0 Credentials

You need to create **3 separate credentials**:

---

## 🌍 Step 2: Web Client ID (for Backend)

1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Application type: **Web application**
4. Name: `Vegobolt Web Client`
5. Authorized redirect URIs: (Leave empty for now)
6. Click **CREATE**
7. **Copy the Client ID** (format: `xxxxx.apps.googleusercontent.com`)
8. Update `.env` file:
   ```bash
   GOOGLE_CLIENT_ID_WEB=your-web-client-id.apps.googleusercontent.com
   ```

---

## 🤖 Step 3: Android Client ID

### 3.1 Get SHA-1 Fingerprint

**⚡ QUICK METHOD - Use the helper script:**
```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-App
.\get-sha1.ps1
```

**OR Manual Methods (No Android Studio Required!):**

**Method 1: Using Gradle (Recommended)**
```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-App\vegobolt\android
.\gradlew signingReport
```

**Method 2: Using keytool (Java required)**
```powershell
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Method 3: Using Flutter**
```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-App\vegobolt
flutter run
# This creates the keystore, then use Method 1 or 2
```

**Copy the SHA-1 fingerprint** (looks like: `AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD`)

**Troubleshooting:**
- If keytool not found: You need Java JDK (Flutter includes it)
- If keystore doesn't exist: Run `flutter run` once to create it
- If Gradle fails: Try `.\gradlew.bat signingReport` instead

**For Release Build (later):**
```powershell
keytool -list -v -keystore path\to\your\release.keystore -alias your-key-alias
```

### 3.2 Create Android OAuth Client

1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Application type: **Android**
4. Name: `Vegobolt Android`
5. Package name: `com.example.vegobolt` (from `build.gradle.kts`)
6. SHA-1 certificate fingerprint: Paste your SHA-1 from above
7. Click **CREATE**
8. **Copy the Client ID**
9. Update `.env` file:
   ```bash
   GOOGLE_CLIENT_ID_ANDROID=your-android-client-id.apps.googleusercontent.com
   ```

### 3.3 Update Android Configuration (OPTIONAL - for custom setup)

If you need custom configuration, add to `android/app/src/main/res/values/strings.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">YOUR_WEB_CLIENT_ID</string>
</resources>
```

---

## 🍎 Step 4: iOS Client ID

### 4.1 Get Bundle Identifier

Check your bundle ID in `ios/Runner/Info.plist` or Xcode:
```xml
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

Default is usually: `com.example.vegobolt`

### 4.2 Create iOS OAuth Client

1. Go to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Application type: **iOS**
4. Name: `Vegobolt iOS`
5. Bundle ID: `com.example.vegobolt`
6. Click **CREATE**
7. **Copy the Client ID and iOS URL scheme**
8. Update `.env` file:
   ```bash
   GOOGLE_CLIENT_ID_IOS=your-ios-client-id.apps.googleusercontent.com
   ```

### 4.3 Update iOS Info.plist

Edit `ios/Runner/Info.plist` and add BEFORE the last `</dict>`:

```xml
<!-- Google Sign-In Configuration -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED iOS Client ID -->
            <string>com.googleusercontent.apps.YOUR-IOS-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

**Example:** If your iOS Client ID is `123456789-abcdefg.apps.googleusercontent.com`, the reversed URL scheme is:
```
com.googleusercontent.apps.123456789-abcdefg
```

---

## 🔧 Step 5: Update Backend Environment Variables

Edit `vegobolt-backend/.env`:

```bash
# Google OAuth Configuration
GOOGLE_CLIENT_ID_WEB=123456789-web.apps.googleusercontent.com
GOOGLE_CLIENT_ID_ANDROID=123456789-android.apps.googleusercontent.com
GOOGLE_CLIENT_ID_IOS=123456789-ios.apps.googleusercontent.com
```

**⚠️ Important:** Replace the placeholder values with your actual Client IDs from Google Cloud Console.

---

## 📦 Step 6: Install Dependencies

### Backend
```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-App\vegobolt-backend
npm install
```

### Flutter
```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-App\vegobolt
flutter pub get
```

---

## ✅ Step 7: Testing

### Test Backend (Optional)

Start the backend server:
```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-App\vegobolt-backend
npm start
```

### Test Flutter App

1. **Start an Android Emulator** or connect a device
2. Run the app:
   ```powershell
   cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-App\vegobolt
   flutter run
   ```

3. On the Login page, tap **"Log in with Google"**
4. Select a Google account
5. Grant permissions
6. Should navigate to Dashboard on success

---

## 🐛 Troubleshooting

### Common Issues

#### 1. "Sign in failed" on Android
**Cause:** SHA-1 fingerprint mismatch
**Solution:** 
- Re-generate SHA-1: `cd android; ./gradlew signingReport`
- Update in Google Cloud Console
- Wait 5-10 minutes for changes to propagate

#### 2. "idpiframe_initialization_failed" or "popup_closed_by_user"
**Cause:** Wrong client ID or configuration issue
**Solution:**
- Verify all 3 Client IDs are correct in `.env`
- Restart backend server
- Clear app data and try again

#### 3. Backend returns "Invalid Google token"
**Cause:** Client ID mismatch between app and backend
**Solution:**
- Ensure `.env` has correct Client IDs
- Restart backend server
- Check backend logs for detailed error

#### 4. iOS "Error 400: redirect_uri_mismatch"
**Cause:** URL scheme not configured properly
**Solution:**
- Verify reversed Client ID in `Info.plist`
- Format: `com.googleusercontent.apps.YOUR-CLIENT-ID`
- Rebuild iOS app

#### 5. Network Error
**Cause:** Backend not running or wrong API URL
**Solution:**
- Check backend is running on port 3000
- Verify `api_config.dart` has correct backend URL
- For Android emulator, use `10.0.2.2:3000` instead of `localhost:3000`

---

## 📱 Platform-Specific Notes

### Android
- **Minimum SDK**: 21 (Android 5.0)
- **Debug vs Release**: You need different SHA-1 fingerprints for debug and release builds
- **Emulator**: Works fine for testing
- **Real Device**: Needs SHA-1 from release keystore for production

### iOS
- **Minimum iOS**: 12.0
- **Simulator**: Works for testing
- **Real Device**: Requires Apple Developer account for production

### Web (Future)
- Need to add authorized JavaScript origins in Web Client configuration
- Add web-specific initialization in `web/index.html`

---

## 🔐 Security Best Practices

1. **Never commit `.env` files** to Git (already in `.gitignore`)
2. **Use different credentials** for development and production
3. **Restrict API keys** in Google Cloud Console
4. **Enable only required APIs** (Google Sign-In API)
5. **Set up OAuth consent screen** properly for production
6. **Store client secrets securely** (backend only)

---

## 📚 Additional Resources

- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Flutter Authentication Best Practices](https://docs.flutter.dev/cookbook/authentication)
- [Google Cloud Console](https://console.cloud.google.com/)

---

## ✨ Next Steps

After Google Auth is working:

1. ✅ Test on both Android and iOS
2. ✅ Test error scenarios (cancel, network error, invalid token)
3. ✅ Update Signup page with Google Sign-In
4. 🔄 Add account linking (link Google to existing email account)
5. 🔄 Implement profile picture sync
6. 🔄 Add "Sign in with Google" on web (if needed)
7. 🔄 Set up production OAuth credentials
8. 🔄 Submit app for OAuth verification (for production)

---

## 📝 Summary Checklist

- [ ] Created Google Cloud Project
- [ ] Configured OAuth consent screen
- [ ] Created Web Client ID
- [ ] Created Android Client ID (with SHA-1)
- [ ] Created iOS Client ID
- [ ] Updated backend `.env` with all 3 Client IDs
- [ ] Updated iOS `Info.plist` with URL scheme
- [ ] Ran `flutter pub get`
- [ ] Ran `npm install` in backend
- [ ] Tested Google Sign-In on Android
- [ ] Tested Google Sign-In on iOS (if on Mac)
- [ ] Verified backend logs user creation/login

---

**Need help?** Check the troubleshooting section or contact the development team.
