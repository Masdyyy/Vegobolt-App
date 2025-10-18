# 🧪 How to Test Your Backend

## Quick Start

### Step 1: Start the Server
Open PowerShell in the project directory:
```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-Mobile-Backend\vegobolt-backend
npm start
```

Keep this terminal open!

---

### Step 2: Run Tests

Open a **NEW** PowerShell terminal and choose one method:

## Method 1: PowerShell Script (Recommended) ⭐
```powershell
cd c:\Users\CABUDSAN\Documents\GitHub\Vegobolt-Mobile-Backend\vegobolt-backend
.\test-backend.ps1
```

## Method 2: Node.js Test Scripts

### Simple Test:
```powershell
node test-simple.js
```

### Comprehensive Test:
```powershell
node test-jwt-auth.js
```

## Method 3: Manual Testing

### Quick Health Check:
```powershell
curl http://localhost:3000/health
```

### Register User:
```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method Post -Body (@{email="test@test.com";password="test123456";displayName="Test User"} | ConvertTo-Json) -ContentType "application/json"
```

---

## What Gets Tested

✅ **Health check** - Server is running  
✅ **User registration** - Create new accounts  
✅ **User login** - Authenticate users  
✅ **Token verification** - JWT token validation  
✅ **Protected routes** - Access control with tokens  
✅ **Security** - Wrong passwords & missing tokens rejected  

---

## Expected Output

You should see:
```
✅ PASSED: Server is running
✅ PASSED: User registered successfully
✅ PASSED: Login successful
✅ PASSED: Profile retrieved successfully
✅ PASSED: Token is valid
✅ PASSED: Wrong password correctly rejected
✅ PASSED: Access denied without token

🎉 ALL TESTS COMPLETED SUCCESSFULLY!
```

---

## Troubleshooting

### "Cannot connect to server"
→ Make sure server is running in another terminal with `npm start`

### "Port 3000 is already in use"
```powershell
# Find and kill process on port 3000
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### "MongoDB connection error"
→ Check your `.env` file has the correct `MONGODB_URI`

---

## Files Available for Testing

📄 **test-backend.ps1** - PowerShell test script (easiest)  
📄 **test-simple.js** - Simple Node.js test  
📄 **test-jwt-auth.js** - Comprehensive Node.js test  
📄 **TESTING_GUIDE.md** - Detailed testing instructions  

---

## Summary

1. **Start server**: `npm start` (Terminal 1)
2. **Run tests**: `.\test-backend.ps1` (Terminal 2)
3. **See results**: All tests should pass! ✅

**That's it!** Your MongoDB-only JWT authentication is ready to go! 🚀
