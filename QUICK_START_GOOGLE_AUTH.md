# 🚀 Quick Start - Google Authentication

## ⚡ Fast Setup (5 Steps)

### Step 1: Google Cloud Console (10 minutes)
```
1. Go to: https://console.cloud.google.com/
2. Create project "Vegobolt" (or select existing)
3. APIs & Services → OAuth consent screen → Configure
4. APIs & Services → Credentials → Create 3 OAuth Client IDs:
   - Web Application
   - Android (need SHA-1 fingerprint)
   - iOS (need bundle ID)
```

### Step 2: Get Android SHA-1 (2 minutes)
```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-App\vegobolt\android
./gradlew signingReport
```
Copy the SHA-1 fingerprint and add to Android OAuth client in Google Console.

### Step 3: Update Backend .env (1 minute)
Edit: `vegobolt-backend/.env`
```bash
GOOGLE_CLIENT_ID_WEB=your-web-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_ID_ANDROID=your-android-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_ID_IOS=your-ios-client-id.apps.googleusercontent.com
```

### Step 4: Update iOS Info.plist (1 minute - iOS only)
Edit: `vegobolt/ios/Runner/Info.plist`

Add before `</dict>`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-IOS-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

### Step 5: Test (5 minutes)
```powershell
# Terminal 1: Start backend
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-App\vegobolt-backend
npm install
npm start

# Terminal 2: Run Flutter app
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-App\vegobolt
flutter run
```

Tap "Log in with Google" → Select account → ✅ Success!

---

## 📚 Full Documentation

- **Complete Setup Guide**: `GOOGLE_AUTH_SETUP_GUIDE.md`
- **Implementation Details**: `GOOGLE_AUTH_IMPLEMENTATION_SUMMARY.md`
- **Architecture Diagram**: `GOOGLE_AUTH_ARCHITECTURE.md`
- **iOS Configuration**: `vegobolt/ios/IOS_GOOGLE_CONFIG_TEMPLATE.md`

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| "Sign in failed" | Check SHA-1 is correct and added to Google Console |
| "Invalid token" | Verify `.env` has correct Client IDs, restart backend |
| Backend error | Make sure MongoDB is connected |
| No Google picker | Wait 5-10 mins after adding SHA-1 |

---

## ✅ What's Implemented

✅ Backend Google token verification  
✅ User creation/login with Google  
✅ Flutter Google Sign-In button  
✅ JWT token generation  
✅ Secure token storage  
✅ Auto email verification for Google users  
✅ Complete documentation  

---

## 🎯 You're Ready When...

- [ ] Have 3 Client IDs from Google Console
- [ ] SHA-1 added to Google Console
- [ ] Backend `.env` updated with Client IDs
- [ ] iOS Info.plist configured (if testing iOS)
- [ ] Backend server running
- [ ] Can tap "Log in with Google" successfully

**Time to complete:** ~20 minutes (mostly waiting for Google Console)

**Next:** Follow `GOOGLE_AUTH_SETUP_GUIDE.md` for detailed steps!
