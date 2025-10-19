# 🔧 Flutter Web Google OAuth Fix

## 🚨 The Problem
You're getting a 404 error from Google because:
- Your Flutter web app runs on `http://localhost:52438`
- Your Web OAuth Client is configured for `http://localhost:3000` (backend)
- Google rejects the sign-in because the origin doesn't match

## ✅ Solution: Add Flutter Web Origin to Google Console

### Step 1: Go to Google Cloud Console
1. Visit: https://console.cloud.google.com/apis/credentials
2. Find your OAuth 2.0 Client: **"Vegobolt Web"**
3. Click on it to edit

### Step 2: Add Flutter Web Origins
In the **Authorized JavaScript origins** section, add:
```
http://localhost:52438
```

Your list should now have:
- `http://localhost:3000` (for backend)
- `http://localhost:52438` (for Flutter web)

### Step 3: Add Redirect URIs (if needed)
In the **Authorized redirect URIs** section, you might need to add:
```
http://localhost:52438/
```

### Step 4: Save and Wait
1. Click **SAVE**
2. **Wait 5-10 minutes** for Google's changes to propagate
3. Close your browser completely (to clear cached OAuth state)
4. Restart your Flutter app

---

## 🏃 Quick Test After Fix

### 1. Stop your Flutter app
Press `q` in the terminal running Flutter

### 2. Restart Flutter web
```powershell
cd vegobolt
flutter run -d chrome --web-port=52438
```

### 3. Try Google Sign-In again
- Click "Log in with google"
- It should now work! ✨

---

## 🔄 Alternative: Use Port 3000 for Flutter Web

If you want to keep things simple, run Flutter web on the same port:

```powershell
cd vegobolt
flutter run -d chrome --web-port=3000
```

⚠️ **Warning:** This will conflict with your backend if both run at the same time!

---

## 📱 Better Long-Term Solution

### Create Separate OAuth Clients

You should have:
1. **Backend OAuth Client** - for server-side token verification
   - Origin: `http://localhost:3000`
   - Type: Web application
   
2. **Flutter Web OAuth Client** - for web app sign-in
   - Origin: `http://localhost:52438`
   - Type: Web application

To create a new one:
1. Go to: https://console.cloud.google.com/apis/credentials
2. Click **+ CREATE CREDENTIALS** > **OAuth client ID**
3. Select **Web application**
4. Name: `Vegobolt Flutter Web`
5. Add Authorized JavaScript origin: `http://localhost:52438`
6. Click **CREATE**
7. Copy the Client ID
8. Update `vegobolt/web/index.html`:
   ```html
   <meta name="google-signin-client_id" content="YOUR-NEW-CLIENT-ID.apps.googleusercontent.com">
   ```

---

## ✅ Verification Checklist

After applying the fix:
- [ ] Added `http://localhost:52438` to Authorized JavaScript origins
- [ ] Saved changes in Google Console
- [ ] Waited 5-10 minutes
- [ ] Closed browser completely
- [ ] Restarted Flutter app
- [ ] Tested Google Sign-In

---

## 🐛 Still Not Working?

### Check Console Logs
Open browser DevTools (F12) and check:
1. **Console tab** - for JavaScript errors
2. **Network tab** - look for failed requests to Google

### Common Issues:
- **Still getting 404** → Wait longer (can take up to 15 minutes)
- **"popup_blocked_by_browser"** → Allow popups for localhost
- **"idpiframe_initialization_failed"** → Clear browser cookies/cache

---

## 📞 Need Help?

If still not working, check:
1. Browser console errors (F12)
2. Flutter console output
3. Make sure backend is **NOT** using port 52438

---

**Last Updated:** October 20, 2025
