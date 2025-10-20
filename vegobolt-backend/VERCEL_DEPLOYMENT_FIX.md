# 🔧 Vercel Deployment Fix

## Issue Identified
The backend was failing to deploy to Vercel because **MongoDB connection was not being established in production mode**.

## Root Cause
In `src/app.js`, the MongoDB connection was only being initialized when `NODE_ENV !== 'production'`:

```javascript
// ❌ OLD CODE (BROKEN)
if (process.env.NODE_ENV !== 'production') {
    connectDB();
}
```

This meant that when Vercel deployed the app with `NODE_ENV=production`, the database connection was never established, causing all database operations to fail.

## Fix Applied ✅
Updated `src/app.js` to **always** connect to MongoDB regardless of environment:

```javascript
// ✅ NEW CODE (FIXED)
connectDB().catch(err => {
    console.error('Failed to connect to MongoDB:', err);
});
```

The connection handler is smart enough to:
- Cache connections in serverless environments (Vercel)
- Handle errors gracefully
- Work in both development and production

## Steps to Deploy

### 1. Verify Environment Variables on Vercel
Make sure these are set in your Vercel project settings:

**Required Variables:**
```
MONGODB_URI=mongodb+srv://admin:TpFObJ8b4rA21pQT@vegobolt.yx7itwk.mongodb.net/vegobolt?retryWrites=true&w=majority&appName=vegobolt
JWT_SECRET=vegobolt-super-secret-jwt-key-2025-change-this-in-production
JWT_EXPIRES_IN=7d
EMAIL_SERVICE=gmail
EMAIL_USER=masdyforsale1@gmail.com
EMAIL_PASSWORD=cqyygjzqlrvsgrfn
EMAIL_FROM=Vegobolt <masdyforsale1@gmail.com>
FRONTEND_URL=https://vegobolt-app.vercel.app
GOOGLE_CLIENT_IDS=1045365375193-5k5vvatq1qprf2d2h618h77fdbp2rli7.apps.googleusercontent.com,1045365375193-0siblothuaf936c6rfl6i1ieejr6c7u4.apps.googleusercontent.com
PORT=3000
NODE_ENV=production
```

### 2. Push Changes to GitHub
Run the deployment script:

```powershell
cd vegobolt-backend
.\deploy-to-vercel.ps1
```

Or manually:
```powershell
git add .
git commit -m "Fix: MongoDB connection for Vercel production deployment"
git push origin main
```

### 3. Monitor Deployment
- Go to: https://vercel.com/masdyyy/vegobolt-app
- Check the deployment logs
- Verify that MongoDB connection messages appear in logs

### 4. Test the Deployment
After successful deployment, test these endpoints:

```bash
# Health check
curl https://your-vercel-url.vercel.app/health

# Should return:
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2025-10-21T..."
}
```

## Common Vercel Deployment Issues & Solutions

### Issue 1: Missing Environment Variables
**Symptom:** `MONGODB_URI is not configured` error in logs
**Solution:** Add all required environment variables in Vercel dashboard under Settings → Environment Variables

### Issue 2: Build Fails
**Symptom:** Build process fails during deployment
**Solution:** 
- Check `package.json` has correct dependencies
- Ensure `index.js` exists and exports the app
- Verify `vercel.json` configuration is correct

### Issue 3: Database Connection Timeouts
**Symptom:** `serverSelectionTimeoutMS` errors in logs
**Solution:**
- Verify MongoDB Atlas allows connections from anywhere (0.0.0.0/0)
- Check MongoDB credentials are correct
- Ensure MongoDB Atlas cluster is running

### Issue 4: Routes Return 404
**Symptom:** API endpoints return "Route not found"
**Solution:**
- Verify `vercel.json` routes configuration
- Check that all route files are imported in `app.js`
- Ensure route paths match exactly (case-sensitive)

## Verification Checklist

After deployment, verify:

- [ ] Health endpoint returns 200 OK
- [ ] MongoDB connection succeeds (check Vercel logs)
- [ ] `/api/auth/register` endpoint works
- [ ] `/api/auth/login` endpoint works
- [ ] `/api/tank` endpoint works for ESP32
- [ ] `/api/alerts` endpoint works
- [ ] Email verification sends emails correctly

## Project Structure
```
vegobolt-backend/
├── index.js              # Vercel serverless entry point
├── vercel.json          # Vercel configuration
├── package.json         # Dependencies
├── .env                 # Local environment (not deployed)
└── src/
    ├── app.js           # Express app (FIXED HERE)
    ├── config/
    │   └── mongodb.js   # Handles serverless DB connections
    ├── routes/
    ├── controllers/
    └── ...
```

## Additional Resources

- [Vercel Documentation](https://vercel.com/docs)
- [MongoDB Atlas Serverless Best Practices](https://www.mongodb.com/docs/atlas/manage-connections-aws-lambda/)
- [Express with Vercel](https://vercel.com/guides/using-express-with-vercel)

## Notes

⚠️ **Security Reminder:**
- Never commit `.env` files to Git
- Always use environment variables in Vercel for secrets
- Consider rotating JWT_SECRET and other secrets periodically
- Use strong passwords for MongoDB

✅ **The fix has been applied and is ready to deploy!**

---
Last Updated: October 21, 2025
