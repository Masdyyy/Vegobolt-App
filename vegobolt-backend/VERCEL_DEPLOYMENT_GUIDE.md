# 🚀 Deploying Vegobolt Backend to Vercel

## Why Vercel?
- ✅ **FREE** for hobby projects
- ✅ Automatic HTTPS
- ✅ Global CDN
- ✅ Easy deployment from GitHub
- ✅ Environment variables support
- ✅ Automatic deployments on git push

---

## 📋 Prerequisites

1. ✅ GitHub account with your code pushed
2. ✅ Vercel account (sign up at https://vercel.com)
3. ✅ MongoDB Atlas (you already have this)
4. ✅ Email service configured (Gmail or SendGrid)

---

## 🔧 Step-by-Step Deployment

### Step 1: Push Your Code to GitHub

Make sure all your changes are committed and pushed:

```powershell
cd vegobolt-backend
git add .
git commit -m "Prepare backend for Vercel deployment"
git push origin main
```

### Step 2: Sign Up / Login to Vercel

1. Go to https://vercel.com
2. Click "Sign Up" or "Login"
3. Choose "Continue with GitHub"
4. Authorize Vercel to access your GitHub account

### Step 3: Import Your Project

1. Click "Add New..." → "Project"
2. Find your repository: **Masdyyy/Vegobolt-App**
3. Click "Import"
4. **Important:** Set "Root Directory" to `vegobolt-backend`
   - Click "Edit" next to Root Directory
   - Enter: `vegobolt-backend`
5. Framework Preset: **Other** (leave as is)

### Step 4: Configure Environment Variables

Click "Environment Variables" section and add these:

```env
MONGODB_URI=mongodb+srv://admin:TpFObJ8b4rA21pQT@vegobolt.yx7itwk.mongodb.net/vegobolt?retryWrites=true&w=majority&appName=vegobolt

JWT_SECRET=vegobolt-super-secret-jwt-key-2025-change-this-in-production

JWT_EXPIRES_IN=7d

NODE_ENV=production

EMAIL_SERVICE=gmail

EMAIL_USER=masdyforsale1@gmail.com

EMAIL_PASSWORD=cqyygjzqlrvsgrfn

EMAIL_FROM="Vegobolt <masdyforsale1@gmail.com>"

FRONTEND_URL=https://your-app-name.vercel.app

PORT=3000
```

**Important Notes:**
- Don't include spaces around the `=` sign
- The `FRONTEND_URL` will be updated after deployment (see Step 6)
- Click "Add" after each variable

### Step 5: Deploy!

1. Click "Deploy" button
2. Wait 1-2 minutes for deployment
3. You'll see "Congratulations! 🎉" when done

### Step 6: Get Your Production URL

After deployment, you'll get a URL like:
```
https://vegobolt-app-abc123.vercel.app
```

**Copy this URL!**

### Step 7: Update FRONTEND_URL

1. Go to your Vercel project dashboard
2. Click "Settings" → "Environment Variables"
3. Find `FRONTEND_URL`
4. Click "Edit"
5. Update to your actual Vercel URL:
   ```
   https://vegobolt-app-abc123.vercel.app
   ```
6. Click "Save"
7. Go to "Deployments" → Click "Redeploy" on the latest deployment

---

## 🧪 Testing Your Deployment

### Test 1: Health Check

Open in browser:
```
https://your-vercel-url.vercel.app/health
```

Should return:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "..."
}
```

### Test 2: Register a User

Use Postman or curl:
```bash
curl -X POST https://your-vercel-url.vercel.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "displayName": "Test User"
  }'
```

### Test 3: Check Email

- Check the email inbox (test@example.com)
- The verification link should now be:
  ```
  https://your-vercel-url.vercel.app/api/auth/verify-email/token123
  ```
- This link works from **ANY device, ANYWHERE!** 🌍

---

## 📱 Update Flutter App

Update your Flutter app's API configuration:

### File: `lib/utils/api_config.dart`

```dart
class ApiConfig {
  // For production (Vercel)
  static const String baseUrl = 'https://your-vercel-url.vercel.app/api';
  
  // For local testing (uncomment when testing locally)
  // static const String baseUrl = 'http://10.0.2.2:3000/api';  // Android Emulator
  // static const String baseUrl = 'http://localhost:3000/api';  // iOS Simulator
}
```

---

## 🔄 Automatic Deployments

Every time you push to GitHub, Vercel automatically:
1. Detects the push
2. Rebuilds your backend
3. Deploys the new version
4. Updates the URL (same URL, new code)

**No manual deployment needed!** 🎉

---

## 🌍 Custom Domain (Optional)

Want to use your own domain? (e.g., `api.vegobolt.com`)

1. Buy a domain (Namecheap, GoDaddy, etc.)
2. In Vercel: Settings → Domains
3. Add your domain
4. Update DNS records (Vercel shows you what to add)
5. Update `FRONTEND_URL` to your custom domain

---

## 📊 Monitoring

Vercel provides:
- ✅ Real-time logs (Functions → Logs)
- ✅ Performance analytics
- ✅ Error tracking
- ✅ Deployment history

Access from your Vercel dashboard.

---

## 🐛 Troubleshooting

### Issue: "500 Internal Server Error"

**Solution:** Check Vercel logs:
1. Go to your project in Vercel
2. Click "Functions" → "Logs"
3. Look for error messages

Common causes:
- Missing environment variables
- MongoDB connection issues
- Email service configuration

### Issue: "Cannot connect to database"

**Solution:** 
1. Check `MONGODB_URI` in environment variables
2. Make sure MongoDB Atlas allows connections from anywhere:
   - Go to MongoDB Atlas → Network Access
   - Add IP: `0.0.0.0/0` (allows all IPs)

### Issue: Email verification links still show localhost

**Solution:**
1. Make sure `FRONTEND_URL` is set to your Vercel URL
2. Redeploy after changing environment variables
3. Clear old verification tokens from database

---

## 💰 Pricing

**Free Tier Includes:**
- ✅ Unlimited deployments
- ✅ 100 GB bandwidth/month
- ✅ Automatic SSL/HTTPS
- ✅ Serverless functions
- ✅ Edge network

**Upgrade only needed for:**
- High traffic (>100GB/month)
- Team collaboration features
- Advanced analytics

**For your app:** Free tier is MORE than enough! 🎉

---

## 🎯 Summary

After deployment, your email verification links will look like:
```
https://vegobolt-backend.vercel.app/api/auth/verify-email/abc123
```

This link works:
- ✅ On any device
- ✅ On any network
- ✅ Anywhere in the world
- ✅ With automatic HTTPS

**No more localhost issues!** 🚀

---

## 📝 Quick Checklist

- [ ] Code pushed to GitHub
- [ ] Vercel account created
- [ ] Project imported to Vercel
- [ ] Root directory set to `vegobolt-backend`
- [ ] All environment variables added
- [ ] Deployed successfully
- [ ] `FRONTEND_URL` updated with actual Vercel URL
- [ ] Redeployed after updating `FRONTEND_URL`
- [ ] Health check tested
- [ ] Registration tested
- [ ] Email verification link tested
- [ ] Flutter app updated with new API URL

**You're ready to go!** 🎊
