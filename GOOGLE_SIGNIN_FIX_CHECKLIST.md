# ✅ Google Sign-In Web Fix Checklist

## Quick Diagnosis
**Error:** `[google_sign_in_web] Error on TokenResponse: popup_closed`

**Cause:** Flutter web app URL not authorized in Google OAuth client

---

## ⚡ Quick Fix (5 minutes)

### ☐ **Step 1: Run the Fix Script**
```powershell
.\fix-google-signin.ps1
```
This will:
- ✅ Show you the URLs to add
- ✅ Open Google Cloud Console
- ✅ Guide you through the setup

### ☐ **Step 2: Add URLs to Google Console**

Go to: https://console.cloud.google.com/apis/credentials

Find your Web Client:
- **Client ID:** `445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6`

Add these to **"Authorized JavaScript origins"**:
- [ ] `http://localhost:52438`
- [ ] `http://127.0.0.1:52438`
- [ ] `http://localhost:8080`
- [ ] `http://127.0.0.1:8080`
- [ ] `http://localhost:3000` (already there)

Click **SAVE**

### ☐ **Step 3: Wait 5-10 Minutes**
Google needs time to propagate the changes. Go grab a coffee! ☕

### ☐ **Step 4: Test**
```powershell
cd vegobolt
.\start-web.ps1
```

Try logging in with Google. Should work! 🎉

---

## 🔍 Verification

After fixing, you should see in console:
```
Google Sign-In Debug:
- Email: your.email@gmail.com
- Display Name: Your Name
- Has ID Token: true  ← Must be true!
- Has Access Token: true
- Platform: Web
```

If `Has ID Token: false`, wait longer or check console config again.

---

## 🆘 Still Not Working?

### Try These:

1. **Clear Browser Cache**
   - Press `Ctrl + Shift + Delete`
   - Clear "Cached images and files"
   - Close and reopen browser

2. **Try Incognito Mode**
   - Opens fresh session without cached OAuth data

3. **Check Client ID Match**
   ```html
   <!-- web/index.html -->
   <meta name="google-signin-client_id" 
         content="445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com">
   ```

4. **Verify Origins in Console**
   - Go to Google Console → Credentials
   - Click your Web Client
   - Check "Authorized JavaScript origins"
   - Should see all localhost URLs

5. **Check OAuth Consent Screen**
   - Must be "Published" or in "Testing" mode
   - If "Testing", add your email as test user

---

## 📝 Manual Fix (if script doesn't work)

### Add Origins Manually:

1. Open: https://console.cloud.google.com/apis/credentials
2. Click pencil icon ✏️ on Web Client (ID: 445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6)
3. Find "Authorized JavaScript origins"
4. Click "+ ADD URI" 5 times and add:
   - `http://localhost:52438`
   - `http://127.0.0.1:52438`
   - `http://localhost:8080`
   - `http://127.0.0.1:8080`
   - `http://localhost:3000`
5. Click "SAVE"
6. Wait 5-10 minutes
7. Test again

---

## 🎯 Expected Result

### Before Fix:
```
[GSI_LOGGER-OAUTH2_CLIENT]: Popup window closed.
[google_sign_in_web] Error on TokenResponse: popup_closed
```

### After Fix:
```
Google Sign-In Debug:
- Email: user@example.com
- Display Name: User Name
- Has ID Token: true
- Has Access Token: true
- Platform: Web
```

Then navigates to Dashboard! ✅

---

## 🚀 Future Reference

When deploying to production:
- Add your production domain to origins
- Use HTTPS (required for OAuth)
- Update client ID if using different OAuth client

Example for production:
```
https://your-domain.com
https://www.your-domain.com
```

---

**Last Updated:** October 20, 2025  
**Status:** Ready to fix! 🔧
