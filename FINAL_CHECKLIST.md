# ✅ FINAL CHECKLIST - Fix Error 10

## Changes I Just Made
✅ Added INTERNET permission to AndroidManifest.xml
✅ Added ACCESS_NETWORK_STATE permission to AndroidManifest.xml
✅ Ran flutter clean
✅ Ran flutter pub get

## What You Need to Check in Google Cloud Console

### 1. OAuth Consent Screen Configuration (MOST IMPORTANT!)

Go to: https://console.cloud.google.com/apis/credentials/consent

#### Check Publishing Status:
- If status is **"Testing"**: You MUST add your Google account as a test user
- If status is **"In Production"**: Should work with any Google account

#### Add Test Users (if in Testing mode):
1. Scroll to "Test users" section
2. Click "+ ADD USERS"
3. Add your Google email (the one you're trying to sign in with)
4. Click "SAVE"

**This is the #1 cause of Error 10 when OAuth config is correct!**

### 2. Enable Required APIs

Go to: https://console.cloud.google.com/apis/library

Search and ENABLE these:
- **Google+ API** (or **People API**)
- **Google Identity Toolkit API**

### 3. Verify Android OAuth Client (You said this is correct ✅)

Go to: https://console.cloud.google.com/apis/credentials

Your Android OAuth client should have:
- Package: `com.example.vegobolt` ✅
- SHA-1: `B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7` ✅

## What You Need to Do on Your Device

### 1. Clear Google Play Services Cache
```
Settings → Apps → Google Play Services → Storage → Clear Cache
```
(Don't clear data, just cache)

### 2. Update Google Play Services
```
Play Store → Search "Google Play Services" → Update (if available)
```

### 3. Clear Vegobolt App Data
```
Settings → Apps → Vegobolt → Storage → Clear Data
```

## Test Steps

### Step 1: Run the app
```powershell
cd vegobolt
flutter run -d "adb-RRCX100T75R-q5L2TJ._adb-tls-connect._tcp"
```

### Step 2: Wait for app to install and launch

### Step 3: Try Google Sign-In

### Step 4: If still Error 10, wait 10 minutes
- Google Cloud changes can take time to propagate
- Clear Google Play Services cache again
- Try again

## Quick Diagnosis Guide

### Error 10 + OAuth Config Correct =

Most likely one of these:
1. **OAuth Consent Screen in Testing** + Your email not in test users (90% of cases)
2. **Required APIs not enabled** (Google+ API, Identity Toolkit)
3. **Google Play Services cache** needs clearing
4. **Recent changes** need time to propagate (wait 10-15 min)

## Copy-Paste Checklist

Check these off:

**In Google Cloud Console:**
- [ ] OAuth consent screen configured
- [ ] If "Testing" mode → My email added to test users
- [ ] Google+ API (or People API) enabled
- [ ] Identity Toolkit API enabled
- [ ] Android OAuth client has package: `com.example.vegobolt`
- [ ] Android OAuth client has SHA-1: `B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7`

**On Android Device:**
- [ ] Google Play Services updated
- [ ] Google Play Services cache cleared
- [ ] Vegobolt app data cleared
- [ ] Device has internet connection

**In Code:**
- [x] INTERNET permission added (I did this)
- [x] ACCESS_NETWORK_STATE permission added (I did this)
- [x] Package name is `com.example.vegobolt` (already correct)

## Run This Now

```powershell
cd vegobolt
flutter run -d "adb-RRCX100T75R-q5L2TJ._adb-tls-connect._tcp"
```

Then:
1. Let app install
2. Try Google Sign-In
3. If Error 10 → Check OAuth Consent Screen test users!

## Most Likely Fix

Based on "OAuth config is correct" but still Error 10:

👉 **OAuth Consent Screen is in "Testing" mode**
👉 **Your Google account is NOT added as a test user**

Fix: Add your email to test users in OAuth consent screen!

---

**Priority Actions:**
1. Check OAuth Consent Screen test users ← START HERE
2. Enable required APIs
3. Clear Google Play Services cache
4. Run app and test

Good luck! 🚀
