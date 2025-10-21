# 📧 Email Verification Troubleshooting Guide

## Recent Fix Applied ✅

### Changes Made (Oct 21, 2025):
1. **Enhanced MongoDB connection in `index.js`** - Ensures connection is established on serverless cold start
2. **Updated `src/app.js`** - MongoDB connects regardless of environment
3. **Committed and pushed** - Vercel is now redeploying automatically

---

## How Email Verification Works

### Flow:
1. User registers → Backend sends email with verification link
2. User clicks link → Opens browser with URL like:
   ```
   https://your-backend.vercel.app/api/auth/verify-email/TOKEN_HERE
   ```
3. Backend:
   - Connects to MongoDB
   - Finds user with matching token
   - Updates `isEmailVerified` to `true`
   - Returns success HTML page

---

## Common Issues & Solutions

### ❌ Issue 1: "Error verifying email" in app
**Symptoms:**
- User clicks verification link
- Gets error page instead of success

**Possible Causes:**
1. **MongoDB connection not established (FIXED in latest deployment)**
2. Token expired (tokens last 24 hours)
3. Token already used
4. Environment variables not set in Vercel

**Solution:**
```bash
# Check Vercel deployment logs
# Go to: https://vercel.com/masdyyy/vegobolt-app
# Click latest deployment → View Function Logs

# Look for:
✅ "MongoDB Connected: ..."
❌ "MONGODB_URI is not set"
❌ "Failed to connect to MongoDB"
```

---

### ❌ Issue 2: Verification link returns "Invalid or expired"
**Symptoms:**
- Link shows error page
- Says token is invalid or expired

**Possible Causes:**
1. Token actually expired (>24 hours old)
2. User already verified
3. Token was regenerated (via resend)

**Solution:**
1. Have user request new verification email:
   ```http
   POST https://your-backend.vercel.app/api/auth/resend-verification
   Body: { "email": "user@example.com" }
   ```
2. Use the NEW link from the email

---

### ❌ Issue 3: Email not sending
**Symptoms:**
- User registers but never receives email
- Registration succeeds but no email in inbox

**Possible Causes:**
1. Email credentials incorrect in Vercel
2. Gmail App Password expired
3. Email in spam folder
4. Daily email limit reached (500/day for Gmail)

**Check Email Service:**
```bash
# Verify these environment variables in Vercel:
EMAIL_SERVICE=gmail
EMAIL_USER=masdyforsale1@gmail.com
EMAIL_PASSWORD=cqyygjzqlrvsgrfn
EMAIL_FROM=Vegobolt <masdyforsale1@gmail.com>
```

---

### ❌ Issue 4: Deployment fails on Vercel
**Symptoms:**
- Push to GitHub doesn't deploy
- Deployment shows "Error" status
- Build or runtime errors in logs

**Solution:**
1. Check Vercel deployment logs
2. Verify all environment variables are set
3. Check MongoDB Atlas allows connections from 0.0.0.0/0
4. Ensure no syntax errors in recent commits

---

## Testing the Fix

### 1. Wait for Vercel Deployment
After pushing to GitHub:
- Go to: https://vercel.com/masdyyy/vegobolt-app
- Wait for deployment to show "Ready" status (1-2 minutes)

### 2. Test Health Endpoint
```bash
curl https://your-backend.vercel.app/health

# Expected response:
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2025-10-21T..."
}
```

### 3. Test Registration
```bash
curl -X POST https://your-backend.vercel.app/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123",
    "firstName": "Test",
    "lastName": "User"
  }'

# Expected response:
{
  "success": true,
  "message": "User registered successfully. Please check your email...",
  "data": {
    "user": { ... },
    "requiresEmailVerification": true
  }
}
```

### 4. Check Email
- Check inbox for verification email
- Click the verification link
- Should see success page with green checkmark

### 5. Test Login
```bash
curl -X POST https://your-backend.vercel.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123"
  }'

# If NOT verified:
{
  "success": false,
  "message": "Please verify your email before logging in..."
}

# If verified:
{
  "success": true,
  "message": "Login successful",
  "data": { "user": {...}, "token": "..." }
}
```

---

## Vercel Environment Variables Checklist

Make sure these are ALL set in Vercel Dashboard:
- [ ] `MONGODB_URI` - Your MongoDB Atlas connection string
- [ ] `JWT_SECRET` - Secret key for JWT tokens
- [ ] `JWT_EXPIRES_IN` - Token expiration (e.g., "7d")
- [ ] `EMAIL_SERVICE` - "gmail"
- [ ] `EMAIL_USER` - Your Gmail address
- [ ] `EMAIL_PASSWORD` - Gmail App Password (16 characters, no spaces)
- [ ] `EMAIL_FROM` - Sender name and email
- [ ] `FRONTEND_URL` - Your app URL (for verification links)
- [ ] `GOOGLE_CLIENT_IDS` - Comma-separated Google OAuth client IDs
- [ ] `NODE_ENV` - "production"
- [ ] `PORT` - "3000"

---

## MongoDB Atlas Checklist

Make sure in your MongoDB Atlas dashboard:
- [ ] Cluster is running (not paused)
- [ ] Network Access allows `0.0.0.0/0` (everywhere)
- [ ] Database user credentials are correct
- [ ] Connection string includes database name: `/vegobolt?`

---

## Quick Debugging Commands

### Check current deployment status:
```bash
# In browser, visit:
https://vercel.com/masdyyy/vegobolt-app/deployments
```

### View logs of latest deployment:
```bash
# Click on latest deployment → "View Function Logs"
# Look for MongoDB connection messages
```

### Test if backend is responding:
```bash
curl https://your-backend.vercel.app/health
```

### Check MongoDB connection manually:
```bash
# In VS Code terminal:
cd vegobolt-backend
node view-database.js
```

---

## What Was Fixed

### Before (Broken):
```javascript
// MongoDB only connected in development
if (process.env.NODE_ENV !== 'production') {
    connectDB();
}
```

### After (Fixed):
```javascript
// MongoDB connects in ALL environments
connectDB().catch(err => {
    console.error('Failed to connect to MongoDB:', err);
});

// PLUS in index.js for serverless:
if (process.env.NODE_ENV === 'production') {
    connectDB().catch(err => {
        console.error('❌ Failed to connect to MongoDB on startup:', err);
    });
}
```

---

## Next Steps

1. ✅ **Deployment is in progress** - Check Vercel dashboard
2. ⏱️ **Wait 1-2 minutes** for deployment to complete
3. 🧪 **Test email verification** with a new registration
4. 📊 **Check logs** if issues persist
5. 🔄 **Resend verification** if needed using the resend endpoint

---

## Still Having Issues?

If email verification still fails after deployment:

1. **Check Vercel Function Logs:**
   - Look for MongoDB connection errors
   - Look for "User not found" or token issues

2. **Verify Environment Variables:**
   - All variables are set correctly
   - No typos in MONGODB_URI
   - EMAIL_PASSWORD is correct App Password

3. **Check MongoDB Atlas:**
   - Cluster is active
   - Network access allows all IPs
   - Database has users collection

4. **Test Locally:**
   ```bash
   cd vegobolt-backend
   npm start
   # Test at http://localhost:3000
   ```

---

Last Updated: October 21, 2025
Status: ✅ Fix deployed, awaiting Vercel build completion
