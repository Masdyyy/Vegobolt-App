# 🔐 Forgot Password - Architecture & Flow Diagram

## 📊 System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        FORGOT PASSWORD SYSTEM                        │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│                  │         │                  │         │                  │
│  Flutter App     │ ←─────→ │  Node.js API     │ ←─────→ │  MongoDB Atlas   │
│  (Mobile)        │  HTTP   │  (Express)       │  Query  │  (Database)      │
│                  │         │                  │         │                  │
└──────────────────┘         └──────────────────┘         └──────────────────┘
                                      │
                                      │
                                      ↓
                             ┌──────────────────┐
                             │                  │
                             │  Gmail SMTP      │
                             │  (Email Service) │
                             │                  │
                             └──────────────────┘
```

---

## 🔄 Data Flow - Request Reset

```
User                    Flutter App              Backend API              Database              Email Service
  │                          │                        │                       │                       │
  │  1. Enter Email         │                        │                       │                       │
  ├────────────────────────→│                        │                       │                       │
  │                          │                        │                       │                       │
  │                          │  2. POST /password-reset                      │                       │
  │                          ├───────────────────────→│                       │                       │
  │                          │                        │                       │                       │
  │                          │                        │  3. Find User         │                       │
  │                          │                        ├──────────────────────→│                       │
  │                          │                        │                       │                       │
  │                          │                        │  4. User Found        │                       │
  │                          │                        │←──────────────────────┤                       │
  │                          │                        │                       │                       │
  │                          │                        │  5. Generate Token    │                       │
  │                          │                        │  6. Save Token + Expiry                       │
  │                          │                        ├──────────────────────→│                       │
  │                          │                        │                       │                       │
  │                          │                        │  7. Send Reset Email  │                       │
  │                          │                        ├───────────────────────┼──────────────────────→│
  │                          │                        │                       │                       │
  │                          │  8. Success Response   │                       │                       │
  │                          │←───────────────────────┤                       │                       │
  │                          │                        │                       │                       │
  │  9. Show Success Msg     │                        │                       │                       │
  │←─────────────────────────┤                        │                       │                       │
  │                          │                        │                       │                       │
  │  10. Check Email         │                        │                       │                       │
  │←─────────────────────────┼────────────────────────┼───────────────────────┼───────────────────────┤
  │     (Reset Link)         │                        │                       │                       │
```

---

## 🔄 Data Flow - Reset Password

```
User                    Email               Flutter App              Backend API              Database
  │                       │                      │                        │                       │
  │  1. Click Link       │                      │                        │                       │
  │      in Email        │                      │                        │                       │
  ├─────────────────────→│                      │                        │                       │
  │                       │                      │                        │                       │
  │                       │  2. Extract Token    │                        │                       │
  │                       ├─────────────────────→│                        │                       │
  │                       │                      │                        │                       │
  │  3. Enter New         │                      │                        │                       │
  │     Password          │                      │                        │                       │
  ├──────────────────────────────────────────────→│                        │                       │
  │                       │                      │                        │                       │
  │                       │                      │  4. POST /reset-password                      │
  │                       │                      ├───────────────────────→│                       │
  │                       │                      │                        │                       │
  │                       │                      │                        │  5. Validate Token   │
  │                       │                      │                        │     & Check Expiry   │
  │                       │                      │                        ├─────────────────────→│
  │                       │                      │                        │                       │
  │                       │                      │                        │  6. Token Valid      │
  │                       │                      │                        │←─────────────────────┤
  │                       │                      │                        │                       │
  │                       │                      │                        │  7. Hash New Password│
  │                       │                      │                        │  8. Update Password  │
  │                       │                      │                        │  9. Clear Token      │
  │                       │                      │                        ├─────────────────────→│
  │                       │                      │                        │                       │
  │                       │                      │  10. Success Response  │                       │
  │                       │                      │←───────────────────────┤                       │
  │                       │                      │                        │                       │
  │  11. Redirect to Login                       │                        │                       │
  │←─────────────────────────────────────────────┤                        │                       │
  │                       │                      │                        │                       │
  │  12. Login with       │                      │                        │                       │
  │      New Password     │                      │                        │                       │
  │───────────────────────────────────────────────────────────────────────→│                       │
```

---

## 🗄️ Database Schema

### User Model - New Fields

```javascript
{
  // ... existing fields ...
  
  // 🆕 Password Reset Fields
  passwordResetToken: {
    type: String,
    default: null,
    description: "Secure token for password reset"
  },
  
  passwordResetExpires: {
    type: Date,
    default: null,
    description: "Token expiration time (1 hour from generation)"
  }
}
```

### Example Document

```json
{
  "_id": "507f1f77bcf86cd799439011",
  "email": "user@example.com",
  "password": "$2a$10$abcd1234...",
  "firstName": "John",
  "lastName": "Doe",
  "passwordResetToken": "a1b2c3d4e5f6...",
  "passwordResetExpires": "2025-10-21T15:30:00.000Z",
  "createdAt": "2025-01-01T00:00:00.000Z",
  "updatedAt": "2025-10-21T14:30:00.000Z"
}
```

---

## 📧 Email Template Structure

```html
┌──────────────────────────────────────┐
│                                      │
│  VEGOBOLT LOGO / HEADER              │
│                                      │
├──────────────────────────────────────┤
│                                      │
│  Password Reset Request              │
│                                      │
│  Hello John Doe,                     │
│                                      │
│  We received a request to reset      │
│  your password...                    │
│                                      │
│  ┌──────────────────────────────┐   │
│  │  [Reset Password Button]     │   │
│  └──────────────────────────────┘   │
│                                      │
│  Or copy this link:                  │
│  https://vegobolt.../reset?token=... │
│                                      │
│  This link expires in 1 hour         │
│                                      │
│  Security Notice:                    │
│  If you didn't request this...       │
│                                      │
├──────────────────────────────────────┤
│  © 2025 Vegobolt. All rights reserved│
└──────────────────────────────────────┘
```

---

## 🔐 Security Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    SECURITY MEASURES                         │
└─────────────────────────────────────────────────────────────┘

1. Token Generation
   ┌────────────────────────────┐
   │ crypto.randomBytes(32)     │
   │ → 64-character hex string  │
   │ → Cryptographically secure │
   └────────────────────────────┘

2. Token Storage
   ┌────────────────────────────┐
   │ Store in MongoDB           │
   │ + Expiration timestamp     │
   │ + Link to user account     │
   └────────────────────────────┘

3. Token Validation
   ┌────────────────────────────┐
   │ ✓ Token exists?            │
   │ ✓ Token not expired?       │
   │ ✓ Linked to valid user?    │
   └────────────────────────────┘

4. Password Hashing
   ┌────────────────────────────┐
   │ bcrypt.hash(password, 10)  │
   │ → Salted hash              │
   │ → Store in database        │
   └────────────────────────────┘

5. Token Cleanup
   ┌────────────────────────────┐
   │ Clear token field          │
   │ Clear expiration           │
   │ → After successful reset   │
   └────────────────────────────┘
```

---

## 📱 Flutter App Pages

```
App Pages Structure
│
├── LoginPage
│   └── [Forgot Password?] ──→ ForgotPasswordPage
│
├── ForgotPasswordPage
│   ├── Email Input Field
│   ├── [Continue Button]
│   └── → Success → Navigate Back to Login
│
└── ResetPasswordPage (Token-based)
    ├── New Password Input
    ├── Confirm Password Input
    ├── [Reset Password Button]
    └── → Success → Navigate to Login
```

---

## 🔄 State Management

```
ForgotPasswordPage State Flow
│
├── Initial State
│   ├── _isLoading = false
│   ├── _emailController = ""
│   └── Form not validated
│
├── User Enters Email
│   └── Validate email format
│
├── Click Continue
│   ├── _isLoading = true
│   ├── Call API
│   ├── Wait for response
│   │
│   ├── Success?
│   │   ├── _isLoading = false
│   │   ├── Show success message
│   │   └── Navigate back
│   │
│   └── Error?
│       ├── _isLoading = false
│       └── Show error message
```

---

## 🎯 Component Interaction

```
┌────────────────────────────────────────────────────────────┐
│                      COMPONENT DIAGRAM                      │
└────────────────────────────────────────────────────────────┘

Flutter App
├── Pages/
│   ├── ForgotPasswordPage.dart
│   │   └── Uses → AuthService
│   └── ResetPasswordPage.dart
│       └── Uses → AuthService
│
├── Services/
│   └── AuthService.dart
│       ├── requestPasswordReset()
│       └── resetPassword()
│           └── Uses → ApiConfig
│
└── Utils/
    └── ApiConfig.dart
        ├── authPasswordReset = "/api/auth/password-reset"
        └── authResetPassword = "/api/auth/reset-password"

Backend API
├── Routes/
│   └── authRoutes.js
│       ├── POST /password-reset → authController.requestPasswordReset
│       └── POST /reset-password → authController.resetPassword
│
├── Controllers/
│   └── authController.js
│       ├── requestPasswordReset()
│       │   └── Uses → EmailService, User Model
│       └── resetPassword()
│           └── Uses → User Model, bcrypt
│
├── Services/
│   └── emailService.js
│       └── sendPasswordResetEmail()
│           └── Uses → nodemailer
│
└── Models/
    └── User.js
        ├── passwordResetToken
        └── passwordResetExpires
```

---

## 🌐 Network Communication

```
Request Format
──────────────

POST /api/auth/password-reset
Content-Type: application/json

{
  "email": "user@example.com"
}

───────────────────────────────

Response Format (Success)
──────────────────────────

Status: 200 OK
Content-Type: application/json

{
  "success": true,
  "message": "If the email exists, a password reset link will be sent"
}

───────────────────────────────

Response Format (Error)
───────────────────────

Status: 400/500
Content-Type: application/json

{
  "success": false,
  "message": "Error message here",
  "error": "Detailed error (dev mode only)"
}
```

---

## ⏱️ Timeline

```
Token Lifecycle
────────────────

00:00 │ Token Generated
      │ ├─ Saved to database
      │ └─ Email sent
      │
00:30 │ Token still valid ✓
      │ User can reset password
      │
00:59 │ Token about to expire ⚠️
      │
01:00 │ Token expired ✗
      │ User must request new link
      │
01:01 │ Token rejected
      │ "Invalid or expired token"
```

---

## 📊 Success Metrics

```
Expected Success Flow
─────────────────────

Request → Email Sent → Email Received → Link Clicked → 
Password Reset → Token Cleared → Login Success

Failure Points
──────────────

1. ✗ Email not in database
   → Silent success (security)

2. ✗ Email service failure
   → Error: "Failed to send email"

3. ✗ Token expired
   → Error: "Invalid or expired token"

4. ✗ Password validation fails
   → Error: "Password must be at least 6 characters"

5. ✗ Network error
   → Error: "Network error: [details]"
```

---

This visual guide helps understand the complete architecture and flow of the forgot password feature!
