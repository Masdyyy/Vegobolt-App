# 🎯 Add Authorized Origins - Visual Guide

## Your Client ID
```
445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6.apps.googleusercontent.com
```

---

## 📋 URLs to Add (Copy These!)

```
http://localhost:52438
http://127.0.0.1:52438
http://localhost:8080
http://127.0.0.1:8080
http://localhost:3000
```

---

## 🖱️ Step-by-Step Instructions

### Step 1: Open Google Cloud Console
URL: https://console.cloud.google.com/apis/credentials

### Step 2: Find Your Web Client
Look for:
- **Type:** OAuth 2.0 Client ID
- **Name:** Vegobolt Web (or similar)
- **Client ID:** ends with `...4rc6.apps.googleusercontent.com`

### Step 3: Click Edit (Pencil Icon ✏️)
The pencil icon is on the right side of the row

### Step 4: Scroll to "Authorized JavaScript origins"
You should see a section that looks like this:

```
Authorized JavaScript origins
For use with requests from a browser

URIs                                    [Delete]
http://localhost:3000                      [×]

                                    [+ ADD URI]
```

### Step 5: Add Each URL
For each URL in the list above:
1. Click **"+ ADD URI"**
2. Paste the URL (e.g., `http://localhost:52438`)
3. Press Enter or click outside the box
4. Repeat for all 5 URLs

After adding all URLs, it should look like:
```
Authorized JavaScript origins

URIs                                    [Delete]
http://localhost:3000                      [×]
http://localhost:52438                     [×]
http://127.0.0.1:52438                     [×]
http://localhost:8080                      [×]
http://127.0.0.1:8080                      [×]

                                    [+ ADD URI]
```

### Step 6: Save Changes
- Scroll to the **bottom** of the page
- Click the blue **"SAVE"** button
- Wait for "Saved" confirmation message

### Step 7: Wait for Propagation
⏱️ **Important:** Google takes 5-10 minutes to apply changes globally.

During this time:
- ☕ Grab a coffee
- 📧 Check emails
- 📖 Read documentation

---

## ✅ Verification

After 5-10 minutes, test Google Sign-In:

1. Open your Flutter web app: http://localhost:52438
2. Go to Login page
3. Click "Log in with Google"
4. Select your Google account

**Expected Result:**
- ✅ Popup stays open
- ✅ Account selection works
- ✅ You're logged in and redirected to dashboard

**No More:**
- ❌ `popup_closed` error
- ❌ Popup closing immediately

---

## 🔍 Troubleshooting

### If it still doesn't work after 10 minutes:

1. **Check the URLs were saved correctly**
   - Go back to Google Console
   - Open your Web Client
   - Verify all 5 URLs are listed

2. **Clear browser cache**
   ```
   Ctrl + Shift + Delete
   → Clear "Cached images and files"
   → Clear "Cookies and site data"
   ```

3. **Try incognito mode**
   - Close all browser windows
   - Open new incognito/private window
   - Go to http://localhost:52438
   - Try Google Sign-In

4. **Check Flutter app is on correct port**
   - Look at browser URL bar
   - Should be: `http://localhost:52438`
   - If different port, add that port to Google Console

5. **Restart Flutter app**
   ```powershell
   # Press 'r' in terminal to hot reload
   # Or press 'R' to hot restart
   # Or Ctrl+C and run again:
   flutter run -d edge --web-port=52438
   ```

---

## 🎯 Quick Checklist

Before testing, ensure:
- [ ] All 5 URLs added to Google Console
- [ ] Clicked SAVE in Google Console
- [ ] Waited at least 5 minutes
- [ ] Flutter app running on port 52438
- [ ] Browser cleared cache (or using incognito)

---

## 📞 Need Help?

Common issues:
- **"Invalid origin"** → URL not added or typo in URL
- **"popup_closed"** → Haven't waited long enough (wait 10 min)
- **"Developer error"** → Wrong Client ID in code
- **"Access denied"** → OAuth consent screen not configured

---

**Last Updated:** October 20, 2025  
**Your Port:** 52438  
**Your Client ID:** 445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6
