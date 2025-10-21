# 🔐 Forgot Password - Quick Reference

## 📱 User Flow

```
Login Page
    ↓
Click "Forgot Password?"
    ↓
Enter Email Address
    ↓
Click "Continue"
    ↓
Check Email Inbox
    ↓
Click "Reset Password" Button in Email
    ↓
Enter New Password
    ↓
Confirm New Password
    ↓
Click "Reset Password"
    ↓
Success! Redirect to Login
    ↓
Login with New Password ✅
```

---

## 🔌 API Endpoints

### Request Password Reset
```http
POST http://localhost:3000/api/auth/password-reset

Body: {
  "email": "user@example.com"
}

Response: {
  "success": true,
  "message": "If the email exists, a password reset link will be sent"
}
```

### Reset Password
```http
POST http://localhost:3000/api/auth/reset-password

Body: {
  "token": "abc123...",
  "newPassword": "newPassword123"
}

Response: {
  "success": true,
  "message": "Password has been reset successfully..."
}
```

---

## 🧪 Quick Test Commands

### Test with curl
```bash
# 1. Request reset
curl -X POST http://localhost:3000/api/auth/password-reset \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

# 2. Check email and get token

# 3. Reset password
curl -X POST http://localhost:3000/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{"token":"YOUR_TOKEN","newPassword":"newPass123"}'
```

### Test with Node.js script
```bash
cd vegobolt-backend
node test-password-reset.js
```

---

## 📁 Key Files

### Backend
```
vegobolt-backend/
├── src/
│   ├── models/User.js               ← Password reset fields
│   ├── controllers/authController.js ← Reset logic
│   ├── routes/authRoutes.js         ← Reset routes
│   └── services/emailService.js     ← Email sending
└── test-password-reset.js           ← Test script
```

### Frontend
```
vegobolt/
└── lib/
    ├── services/auth_service.dart   ← Reset methods
    ├── utils/api_config.dart        ← API endpoints
    ├── Pages/
    │   ├── forgetpassword.dart      ← Request reset page
    │   └── ResetPassword.dart       ← Reset password page
    └── main.dart                    ← Route config
```

---

## ⚙️ Configuration

### Email (.env)
```env
EMAIL_SERVICE=gmail
EMAIL_USER=masdyforsale1@gmail.com
EMAIL_PASSWORD=cqyygjzqlrvsgrfn
```

### URLs (.env)
```env
BACKEND_URL=http://192.168.100.28:3000
FRONTEND_URL=https://vegobolt-app.vercel.app
```

### API Config (Flutter)
```dart
// lib/utils/api_config.dart
static const bool useProduction = false;
```

---

## 🔐 Security

| Feature | Implementation |
|---------|---------------|
| Token Generation | crypto.randomBytes(32) |
| Token Expiration | 1 hour |
| Password Hashing | bcrypt with salt |
| Min Password Length | 6 characters |
| User Enumeration | Not revealed |
| Token Cleanup | After successful reset |

---

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| Email not received | Check spam folder |
| Token expired | Request new reset link |
| Invalid token | Link may be used/expired |
| Server not responding | Check if backend is running |
| Wrong BACKEND_URL | Update .env file |

---

## ✅ Testing Checklist

- [ ] Backend server running
- [ ] Email config verified
- [ ] Request reset works
- [ ] Email received
- [ ] Token in email link
- [ ] Reset password works
- [ ] New password saves
- [ ] Can login with new password
- [ ] Old password rejected
- [ ] Token expires after 1 hour

---

## 📞 Quick Help

**Email issues?**
```bash
# Check .env configuration
cat vegobolt-backend/.env | grep EMAIL

# Test email service
cd vegobolt-backend
node test-email-verification.js
```

**Backend issues?**
```bash
# Check if running
curl http://localhost:3000/api/auth/password-reset

# View logs
cd vegobolt-backend
npm start
```

**Frontend issues?**
```bash
# Check compilation
cd vegobolt
flutter analyze

# Run with verbose
flutter run -v
```

---

## 🎯 Status: ✅ READY TO USE

All components implemented and tested!

For detailed documentation, see:
- `FORGOT_PASSWORD_SETUP.md` - Complete guide
- `FORGOT_PASSWORD_SUMMARY.md` - Implementation summary

---

**Last Updated:** October 21, 2025
