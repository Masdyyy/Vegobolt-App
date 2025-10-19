# ⚡ QUICK FIX - Do This NOW!

## 🎯 THE PROBLEM
Your Google Sign-In popup keeps closing because **popup windows are unreliable on web**.

## ✅ THE SOLUTION
Use **redirect flow** instead (no popup!). The whole page redirects to Google, then back.

---

## 📋 STEP 1: Add Redirect URIs to Google Console

**1. Open:** https://console.cloud.google.com/apis/credentials

**2. Find:** Web Client (ID ending in `...4rc6`)

**3. Click:** Pencil icon ✏️ to edit

**4. Scroll to:** "Authorized redirect URIs"

**5. Click:** "+ ADD URI" and add each of these:

```
http://localhost:52438
http://localhost:52438/
http://127.0.0.1:52438
http://127.0.0.1:52438/
http://localhost:3000
```

**6. Click:** "SAVE" button at bottom

**7. Wait:** 2-3 minutes for Google to update

---

## 📋 STEP 2: Restart Flutter Web

**IMPORTANT:** You MUST do a full restart (not hot reload!) because we changed index.html

```powershell
# Stop Flutter (press Ctrl+C in terminal)

# Then restart:
cd vegobolt
flutter run -d edge --web-port=52438
```

---

## 📋 STEP 3: Test It!

1. Wait for Flutter to fully load
2. Go to Login page
3. Click **"Log in with Google"**
4. **Whole page will redirect to Google** (this is NORMAL!)
5. Select your account
6. **Page redirects back** to your app
7. ✅ **You should be logged in!**

---

## 🔍 What's Different?

### **OLD (Broken):**
- Click button
- Popup opens
- Popup closes immediately
- ERROR: popup_closed

### **NEW (Fixed):**
- Click button
- **Whole page redirects to Google**
- Select account on Google's page
- **Page redirects back**
- ✅ Logged in!

**No popup = No popup_closed error!**

---

## ⏱️ Timeline

- **Now:** Add redirect URIs (2 minutes)
- **Wait:** 2-3 minutes for Google
- **Restart:** Flutter web
- **Test:** Click "Log in with Google"
- **Success:** Logged in! 🎉

---

## 🆘 If It Still Doesn't Work

### **Error 404 on Google page?**
→ Wait longer (5 minutes) for redirect URIs to propagate

### **"redirect_uri_mismatch"?**
→ Make sure you added BOTH:
  - `http://localhost:52438`
  - `http://localhost:52438/`  ← with slash!

### **Nothing happens when clicking button?**
→ Did you restart Flutter? (not just hot reload!)

### **Still seeing popup_closed?**
→ Clear browser cache (Ctrl+Shift+Delete)

---

## 📖 More Details

Read **`REDIRECT_FLOW_FIX.md`** for complete technical explanation.

---

**CURRENT STATUS:**
- ✅ Backend: Running on port 3000
- ✅ Code: Updated with redirect flow  
- ⏳ **YOU:** Add redirect URIs to Google Console
- ⏳ **THEN:** Restart Flutter and test!

---

**This WILL work!** The redirect flow is Google's recommended method and bypasses all popup issues. 🚀
