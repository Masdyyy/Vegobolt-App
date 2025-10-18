# 🧪 Backend Testing Guide

## Prerequisites
Make sure you have:
- ✅ MongoDB connection is working
- ✅ Server is not already running on port 3000

---

## Step 1: Start the Server

Open a **NEW PowerShell terminal** and run:

```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-Mobile-Backend\vegobolt-backend
npm start
```

You should see:
```
🚀 Server is running on port 3000
📍 Health check: http://localhost:3000/health
🔐 Auth endpoints: http://localhost:3000/api/auth
MongoDB Connected: ...
```

**✅ Keep this terminal open!** The server needs to stay running.

---

## Step 2: Run Tests

Open a **SECOND PowerShell terminal** (keep the first one running!) and choose one:

### Option A: Simple Test (Quick & Easy)
```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-Mobile-Backend\vegobolt-backend
node test-simple.js
```

### Option B: Comprehensive Test (All Scenarios)
```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-Mobile-Backend\vegobolt-backend
node test-jwt-auth.js
```

---

## Step 3: Manual Testing with curl or Postman

If you prefer manual testing, here are the commands:

### 1. Health Check
```powershell
curl http://localhost:3000/health
```

### 2. Register a New User
```powershell
curl -X POST http://localhost:3000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"test@example.com\",\"password\":\"test123456\",\"displayName\":\"Test User\"}'
```

**Save the token from the response!**

### 3. Login
```powershell
curl -X POST http://localhost:3000/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"test@example.com\",\"password\":\"test123456\"}'
```

### 4. Get Profile (Protected Route)
Replace `YOUR_TOKEN_HERE` with the token from login:

```powershell
curl -X GET http://localhost:3000/api/auth/profile `
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 5. Verify Token
```powershell
curl -X POST http://localhost:3000/api/auth/verify-token `
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## Alternative: Use Postman

1. **Download Postman**: https://www.postman.com/downloads/

2. **Import these requests**:

### Register User
- **Method**: POST
- **URL**: `http://localhost:3000/api/auth/register`
- **Headers**: 
  - `Content-Type: application/json`
- **Body** (raw JSON):
```json
{
  "email": "test@example.com",
  "password": "test123456",
  "displayName": "Test User"
}
```

### Login
- **Method**: POST
- **URL**: `http://localhost:3000/api/auth/login`
- **Headers**: 
  - `Content-Type: application/json`
- **Body** (raw JSON):
```json
{
  "email": "test@example.com",
  "password": "test123456"
}
```

### Get Profile (Protected)
- **Method**: GET
- **URL**: `http://localhost:3000/api/auth/profile`
- **Headers**: 
  - `Authorization: Bearer YOUR_TOKEN_HERE`

---

## What to Test

### ✅ Should Work:
- [ ] Health check responds
- [ ] Register new user with email, password, displayName
- [ ] Login with correct credentials
- [ ] Get profile with valid token
- [ ] Verify valid token
- [ ] Access protected routes with valid token

### ❌ Should Fail (Security):
- [ ] Register without email/password/displayName
- [ ] Register with duplicate email
- [ ] Login with wrong password
- [ ] Access protected routes without token
- [ ] Access protected routes with invalid token
- [ ] Register with password less than 6 characters

---

## Expected Results

### Successful Registration Response:
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "...",
      "email": "test@example.com",
      "displayName": "Test User",
      "createdAt": "..."
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Successful Login Response:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "...",
      "email": "test@example.com",
      "displayName": "Test User"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Protected Route Response:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "...",
      "email": "test@example.com",
      "displayName": "Test User",
      "phoneNumber": null,
      "profilePicture": null,
      "createdAt": "..."
    }
  }
}
```

---

## Troubleshooting

### Server won't start:
```powershell
# Kill process on port 3000
netstat -ano | findstr :3000
# Note the PID and kill it
taskkill /PID <PID> /F

# Then start again
npm start
```

### MongoDB connection error:
- Check your `.env` file has correct `MONGODB_URI`
- Verify MongoDB is running (if local) or connection string is correct

### Tests fail with "Cannot connect":
- Make sure server is running in a separate terminal
- Check that port 3000 is not blocked by firewall
- Try accessing http://localhost:3000/health in your browser

### JWT Token errors:
- Make sure `JWT_SECRET` is set in `.env` file
- Token format should be: `Bearer <token>`
- Check token hasn't expired (default: 7 days)

---

## Quick Verification

Run this one-liner to check if server is working:

```powershell
curl http://localhost:3000/health
```

Should return:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "..."
}
```

---

## 🎉 Success Indicators

You'll know everything is working when:

1. ✅ Server starts without errors
2. ✅ MongoDB connection is successful
3. ✅ Health check returns 200 OK
4. ✅ Can register new users
5. ✅ Can login with credentials
6. ✅ Receive JWT tokens
7. ✅ Can access protected routes with tokens
8. ✅ Invalid tokens are rejected
9. ✅ No Firebase errors in logs
10. ✅ All data stored in MongoDB only

**When all these work, your migration is complete! 🚀**
