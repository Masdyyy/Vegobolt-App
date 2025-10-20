# 🚀 QUICK FIX - Error 10 Google Sign-In (No Firebase)

## The ONE Thing You Need to Do

Go to: **https://console.cloud.google.com/**

1. **APIs & Services** → **Credentials**
2. **+ CREATE CREDENTIALS** → **OAuth client ID**
3. Select: **Android**
4. Enter:
   ```
   Package: com.example.vegobolt
   SHA-1:   B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7
   ```
5. Click **Create**
6. Wait 5 minutes
7. Test your app!

That's it! 🎉

---

## Copy-Paste Values

**Package Name**:
```
com.example.vegobolt
```

**SHA-1**:
```
B9:3F:B9:45:67:95:C6:FA:58:89:E2:60:6E:70:2A:BD:47:16:73:B7
```

---

## Why This Fixes Error 10

Error 10 means: "I can't find an Android OAuth client for your app"

By creating the Android OAuth client with your package name + SHA-1, Google Play Services can now authenticate your app. ✅

No Firebase needed. No google-services.json needed. Just the OAuth client.

---

## After Creating the OAuth Client

```powershell
# Test the app
cd vegobolt
flutter run -d "adb-RRCX100T75R-q5L2TJ._adb-tls-connect._tcp"
```

Then try Google Sign-In - should work! 🚀
