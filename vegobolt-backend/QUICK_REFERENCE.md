# Quick Reference: Firebase vs MongoDB-Only Authentication

## 🔄 Authentication Comparison

### Firebase (OLD) ❌
- Dual authentication: Firebase Auth + MongoDB
- Two places to manage users
- Required Firebase SDK and credentials
- Custom tokens from Firebase
- Firebase UID stored in MongoDB

### MongoDB-Only (NEW) ✅
- Single source of truth: MongoDB only
- All user data in one place
- Standard JWT tokens
- No external service dependencies
- Simple bcrypt password hashing

---

## 📝 Code Changes Summary

### User Model
```diff
- firebaseUid: {
-     type: String,
-     required: true,
-     unique: true,
- },
```

### Auth Controller - Register
```diff
- const { auth } = require('../config/firebase');
- const { createCustomToken } = require('../services/firebaseService');
+ const { generateToken } = require('../services/jwtService');

- const firebaseUser = await auth.createUser({...});
- const customToken = await createCustomToken(firebaseUser.uid);
+ const token = generateToken(mongoUser);
```

### Auth Controller - Login
```diff
- const customToken = await createCustomToken(user.firebaseUid);
+ const token = generateToken(user);
```

### Auth Middleware
```diff
- const admin = require('firebase-admin');
- const decodedToken = await getAuth().verifyIdToken(token);
+ const { verifyToken } = require('../services/jwtService');
+ const decoded = await verifyToken(token);
```

### Environment Variables
```diff
- FIREBASE_PROJECT_ID=...
- FIREBASE_PRIVATE_KEY=...
- FIREBASE_CLIENT_EMAIL=...
- FIREBASE_CLIENT_ID=...
- FIREBASE_CERT_URL=...
+ JWT_SECRET=your-secret-key
+ JWT_EXPIRES_IN=7d
```

---

## 🔐 Token Format Comparison

### Firebase Custom Token (OLD)
```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
- Signed by Firebase private key
- Verified by Firebase SDK
- Contains Firebase UID
```

### JWT Token (NEW)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
- Signed by your JWT_SECRET
- Verified by jsonwebtoken library
- Contains MongoDB _id
```

---

## 📡 API Request Comparison

### Registration

**Before (Firebase):**
```javascript
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "password123",
  "displayName": "User Name"
}

Response:
{
  "success": true,
  "data": {
    "user": {
      "id": "mongodb_id",
      "firebaseUid": "firebase_uid", // ❌
      "email": "user@example.com",
      "displayName": "User Name"
    },
    "token": "firebase_custom_token"
  }
}
```

**After (MongoDB-Only):**
```javascript
POST /api/auth/register
{
  "email": "user@example.com",
  "password": "password123",
  "displayName": "User Name"
}

Response:
{
  "success": true,
  "data": {
    "user": {
      "id": "mongodb_id",
      "email": "user@example.com",
      "displayName": "User Name"
    },
    "token": "jwt_token" // ✅ Standard JWT
  }
}
```

### Using Protected Routes

**Before & After (Same):**
```javascript
GET /api/auth/profile
Headers:
  Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "user": { ... }
  }
}
```

---

## 🏗️ Architecture Changes

### Before (Firebase + MongoDB):
```
Mobile App
    ↓
Firebase Auth SDK
    ↓
Backend (Express)
    ↓
├── Firebase Admin SDK → Firebase Cloud
├── MongoDB → User Data
```

### After (MongoDB Only):
```
Mobile App
    ↓
Backend (Express)
    ↓
├── JWT Service → Token Generation/Verification
├── MongoDB → User Data + Authentication
```

---

## 📦 Dependencies

### Removed:
- ❌ `firebase-admin` - No longer needed

### Added:
- ✅ `jsonwebtoken` - For JWT token handling

### Still Using:
- ✅ `bcryptjs` - Password hashing
- ✅ `mongoose` - MongoDB ORM
- ✅ `express` - Web framework
- ✅ `dotenv` - Environment variables

---

## 🔒 Security Considerations

### Password Storage
**Both Old & New:** Passwords hashed with bcrypt (10 salt rounds)

### Token Security
- **Old:** Firebase managed token security
- **New:** You manage JWT_SECRET - **MUST BE SECURE!**

### Best Practices:
1. Use a strong, random JWT_SECRET (64+ characters)
2. Never commit JWT_SECRET to version control
3. Rotate JWT_SECRET periodically
4. Use HTTPS in production
5. Implement rate limiting on auth endpoints
6. Consider adding refresh tokens for better UX

---

## 🧪 Testing Checklist

- [ ] Register new user
- [ ] Login with correct credentials
- [ ] Login with wrong password (should fail)
- [ ] Access protected route with valid token
- [ ] Access protected route with expired token (should fail)
- [ ] Access protected route without token (should fail)
- [ ] Get user profile
- [ ] Logout (client-side)

---

## 💡 Tips

### Generate Secure JWT_SECRET:
```bash
# In Node.js
node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"

# In PowerShell
[Convert]::ToBase64String((1..64 | ForEach-Object { Get-Random -Minimum 0 -Maximum 255 }))
```

### Decode JWT (for debugging):
Visit: https://jwt.io
Paste your token to see the payload

### MongoDB User Migration:
If you have existing users with `firebaseUid`, run this to clean:
```javascript
// In MongoDB shell or script
db.users.updateMany({}, { $unset: { firebaseUid: "" } })
```

---

## 🎯 Quick Start After Migration

1. **Update .env:**
   ```env
   JWT_SECRET=<generate-secure-key>
   JWT_EXPIRES_IN=7d
   MONGODB_URI=<your-mongodb-uri>
   PORT=3000
   ```

2. **Start server:**
   ```bash
   npm start
   ```

3. **Test registration:**
   ```bash
   curl -X POST http://localhost:3000/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{"email":"test@test.com","password":"test123","displayName":"Test"}'
   ```

4. **Update mobile app** to use new JWT tokens

---

**That's it! You're now running on MongoDB-only authentication! 🎉**
