# 🔧 Fix Google Sign-In Web Popup Closed Error

**Issue:** Google Sign-In popup closes immediately with error: `popup_closed`

**Root Cause:** Your Flutter web app is running on `http://localhost:52438` but your Google OAuth client is only configured for `http://localhost:3000`

---

## ✅ **Quick Fix - Add Authorized JavaScript Origins**

### **Step 1: Open Google Cloud Console**
1. Go to: https://console.cloud.google.com/apis/credentials
2. Select your project: **Vegobolt-App**
3. Click on your **Web client** (Client ID: `445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6`)

### **Step 2: Add Flutter Web Origins**

In the **"Authorized JavaScript origins"** section, add:
```
http://localhost:52438
http://localhost:3000
http://localhost:8080
http://localhost:5000
http://127.0.0.1:52438
http://127.0.0.1:3000
http://127.0.0.1:8080
http://127.0.0.1:5000
```

**Why multiple ports?**
- `52438` - Your current Flutter web dev server
- `3000` - Backend server
- `8080`, `5000` - Common Flutter web ports
- `127.0.0.1` variants - Alternative localhost address

### **Step 3: Add Redirect URIs** (if needed)

In the **"Authorized redirect URIs"** section, ensure you have:
```
http://localhost:3000/api/auth/google/callback
http://localhost:52438
http://localhost:8080
```

### **Step 4: Save Changes**
- Click **"SAVE"** at the bottom
- Wait **5-10 minutes** for changes to propagate

---

## 🔄 **Alternative: Use Fixed Port for Flutter Web**

Instead of random ports, use a fixed port for development:

### **Option A: Using start-web.ps1 (Recommended)**

Update your `start-web.ps1`:
```powershell
# Start Flutter web on fixed port
flutter run -d chrome --web-port=8080 --web-hostname=localhost
```

### **Option B: Manual Command**
```powershell
cd vegobolt
flutter run -d chrome --web-port=8080 --web-hostname=localhost
```

Then add `http://localhost:8080` to Google Console (as shown above).

---

## 🧪 **Test the Fix**

### **Step 1: Restart Flutter Web**
```powershell
# Stop current server (Ctrl+C in terminal)
cd vegobolt
flutter run -d chrome --web-port=8080
```

### **Step 2: Try Google Sign-In**
1. Navigate to the login page
2. Click "Log in with Google"
3. Select your Google account
4. ✅ Should now work without popup closing!

### **Step 3: Check Console Logs**

If still having issues, open browser DevTools (F12) and check:
- **Console Tab:** Look for Google Sign-In errors
- **Network Tab:** Check for failed requests
- **Application Tab > Cookies:** Verify cookies are set

---

## 🔍 **Debug Information**

The code now includes debug logging. Check your Flutter console for:
```
Google Sign-In Debug:
- Email: your.email@gmail.com
- Display Name: Your Name
- Has ID Token: true
- Has Access Token: true
- Platform: Web
```

If you see `Has ID Token: false`, it means:
1. ❌ Origins not properly configured in Google Console
2. ❌ Wrong Client ID in code or HTML
3. ❌ Google Console changes not propagated yet (wait 10 min)

---

## 📝 **Current Configuration Summary**

### **Web Client ID (in index.html):**
```html
<meta name="google-signin-client_id" content="445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com">
```

### **Required Origins in Google Console:**
- ✅ `http://localhost:3000` (Backend)
- ❌ `http://localhost:52438` (Current Flutter web) - **ADD THIS!**
- ⚠️ `http://localhost:8080` (Recommended Flutter web port) - **ADD THIS!**

---

## 🚀 **Production Deployment**

When deploying to production, you'll need to add:

### **Vercel/Netlify:**
```
https://your-app.vercel.app
https://your-app.netlify.app
```

### **Custom Domain:**
```
https://vegobolt.com
https://www.vegobolt.com
```

**Remember:** Always use HTTPS in production!

---

## ✨ **After Fix is Applied**

You should see:
1. ✅ Google Sign-In popup opens
2. ✅ You can select your account
3. ✅ Popup closes AFTER authentication
4. ✅ You're redirected to dashboard
5. ✅ No more `popup_closed` errors!

---

## 🆘 **Still Not Working?**

### **Clear Browser Cache:**
```
1. Open DevTools (F12)
2. Right-click the Refresh button
3. Select "Empty Cache and Hard Reload"
```

### **Try Incognito/Private Mode:**
Sometimes cached OAuth data causes issues.

### **Verify Client ID:**
```dart
// Check auth_service.dart
clientId: '445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com'
```

```html
<!-- Check web/index.html -->
<meta name="google-signin-client_id" content="445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com">
```

### **Check Google Console Status:**
- ✅ OAuth consent screen: Published or "Testing"
- ✅ Test users: Added or app is public
- ✅ APIs enabled: Google+ API, People API

---

## 📚 **Reference Links**

- **Google Cloud Console:** https://console.cloud.google.com/apis/credentials
- **OAuth Credentials:** https://console.cloud.google.com/apis/credentials?project=vegobolt-app-440419
- **Flutter Google Sign-In Package:** https://pub.dev/packages/google_sign_in

---

**Created:** October 20, 2025  
**Issue:** popup_closed error on Google Sign-In web  
**Solution:** Add Flutter web origins to Google OAuth client configuration
