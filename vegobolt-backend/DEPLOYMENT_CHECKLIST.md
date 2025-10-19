# 🎯 Vercel Deployment - Quick Start Checklist

## ⚡ Before You Deploy

### 1. Files Ready ✅
- [x] `vercel.json` created
- [x] `src/app.js` exports module
- [x] `.gitignore` configured
- [x] Environment variables documented

### 2. Services Configured ✅
- [x] MongoDB Atlas (cloud database)
- [x] Gmail App Password (email service)
- [x] Email verification working locally

---

## 🚀 Deployment Steps (5 minutes)

### Step 1: Push to GitHub
```powershell
cd vegobolt-backend
.\deploy-to-vercel.ps1
```
Or manually:
```powershell
git add .
git commit -m "Prepare for Vercel deployment"
git push origin main
```

### Step 2: Deploy on Vercel
1. Go to https://vercel.com
2. Login with GitHub
3. Click "Add New..." → "Project"
4. Select **Vegobolt-App** repository
5. **Important:** Set Root Directory to `vegobolt-backend`
6. Add environment variables (see below)
7. Click "Deploy"

### Step 3: Environment Variables

Add these in Vercel dashboard:

```
MONGODB_URI = mongodb+srv://admin:TpFObJ8b4rA21pQT@vegobolt.yx7itwk.mongodb.net/vegobolt?retryWrites=true&w=majority&appName=vegobolt

JWT_SECRET = vegobolt-super-secret-jwt-key-2025-change-this-in-production

JWT_EXPIRES_IN = 7d

NODE_ENV = production

EMAIL_SERVICE = gmail

EMAIL_USER = masdyforsale1@gmail.com

EMAIL_PASSWORD = cqyygjzqlrvsgrfn

EMAIL_FROM = "Vegobolt <masdyforsale1@gmail.com>"

FRONTEND_URL = https://your-app-name.vercel.app

PORT = 3000
```

### Step 4: Update FRONTEND_URL

After first deployment:
1. Copy your Vercel URL (e.g., `https://vegobolt-backend-abc123.vercel.app`)
2. Update `FRONTEND_URL` environment variable with this URL
3. Redeploy

---

## ✅ Testing Checklist

After deployment, test these:

### Test 1: Health Check
```
https://your-vercel-url.vercel.app/health
```
Expected: `{ "success": true, "message": "Server is running" }`

### Test 2: Register User
```
POST https://your-vercel-url.vercel.app/api/auth/register
{
  "email": "test@example.com",
  "password": "password123",
  "displayName": "Test User"
}
```

### Test 3: Email Verification
- Check email inbox
- Click verification link
- Should see beautiful success page
- Works from any device! 🌍

### Test 4: Login
```
POST https://your-vercel-url.vercel.app/api/auth/login
{
  "email": "test@example.com",
  "password": "password123"
}
```
Should fail if email not verified ✅

---

## 📱 Update Flutter App

### File: `lib/utils/api_config.dart`

```dart
class ApiConfig {
  // Production URL (Vercel)
  static const String baseUrl = 'https://your-vercel-url.vercel.app/api';
  
  // Local testing (comment out for production)
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
}
```

---

## 🎯 What You Get

### Before (localhost):
- ❌ Only works on your computer
- ❌ Can't test on real phone
- ❌ Email links don't work on other devices

### After (Vercel):
- ✅ Works from anywhere
- ✅ Test on any device
- ✅ Email verification works globally
- ✅ Free HTTPS
- ✅ Automatic deployments
- ✅ Professional URL

---

## 🔄 Future Updates

To update your backend:

1. Make changes locally
2. Run: `.\deploy-to-vercel.ps1`
3. Vercel automatically deploys!

**That's it!** No manual deployment needed.

---

## 🆘 Need Help?

- 📖 Full guide: `VERCEL_DEPLOYMENT_GUIDE.md`
- 🐛 Common issues: Check Vercel logs (Functions → Logs)
- 💬 Vercel support: https://vercel.com/support

---

## 🎊 You're Ready!

Follow the steps above and your backend will be live in 5 minutes!

**Email verification will work from ANY device, ANYWHERE in the world!** 🌍🚀
