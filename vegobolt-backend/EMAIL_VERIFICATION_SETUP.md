# Email Verification Setup Guide

This guide explains how to set up and use the email verification feature in the Vegobolt backend.

## Features

- ✅ Email verification on signup
- ✅ Users must verify email before logging in
- ✅ Resend verification email option
- ✅ 24-hour verification token expiration
- ✅ Professional HTML email templates
- ✅ Support for multiple email providers (Gmail, SMTP, Development mode)

## Environment Configuration

### Option 1: Gmail (Recommended for Quick Setup)

1. Go to your Google Account settings
2. Enable 2-Factor Authentication
3. Generate an App Password:
   - Go to Security → 2-Step Verification → App passwords
   - Select "Mail" and your device
   - Copy the generated password

4. Update your `.env` file:
```env
EMAIL_SERVICE=gmail
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-16-character-app-password
EMAIL_FROM="Vegobolt <noreply@vegobolt.com>"
FRONTEND_URL=http://localhost:3000
```

### Option 2: Custom SMTP Server

For production environments, use a dedicated email service (SendGrid, AWS SES, Mailgun, etc.):

```env
EMAIL_SERVICE=smtp
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=apikey
SMTP_PASSWORD=your-sendgrid-api-key
EMAIL_FROM="Vegobolt <noreply@vegobolt.com>"
FRONTEND_URL=https://yourapp.com
```

### Option 3: Development Mode (Testing)

For development/testing without a real email service:

```env
# Leave EMAIL_SERVICE blank or don't set it
EMAIL_USER=test@ethereal.email
EMAIL_PASSWORD=test123
FRONTEND_URL=http://localhost:3000
```

In development mode, emails will be logged to the console with preview URLs.

## API Endpoints

### 1. Register User (with Email Verification)

**POST** `/api/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "displayName": "John Doe"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully. Please check your email to verify your account.",
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "displayName": "John Doe",
      "isEmailVerified": false,
      "createdAt": "2025-10-19T12:00:00.000Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "requiresEmailVerification": true
  }
}
```

### 2. Verify Email

**GET** `/api/auth/verify-email/:token`

**Example:**
```
GET /api/auth/verify-email/a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Email verified successfully! You can now log in.",
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "displayName": "John Doe",
      "isEmailVerified": true
    }
  }
}
```

**Response (Invalid/Expired Token):**
```json
{
  "success": false,
  "message": "Invalid or expired verification token"
}
```

### 3. Login (Requires Verified Email)

**POST** `/api/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (Email Not Verified):**
```json
{
  "success": false,
  "message": "Please verify your email before logging in. Check your inbox for the verification link.",
  "requiresEmailVerification": true
}
```

**Response (Email Verified):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "displayName": "John Doe"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### 4. Resend Verification Email

**POST** `/api/auth/resend-verification`

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Verification email sent successfully. Please check your inbox."
}
```

## User Flow

1. **User signs up** → Account created with `isEmailVerified: false`
2. **Verification email sent** → User receives email with verification link
3. **User clicks link** → GET request to `/api/auth/verify-email/:token`
4. **Email verified** → `isEmailVerified: true`, user can now log in
5. **User tries to login** → System checks if email is verified
   - ✅ Verified: Login successful
   - ❌ Not verified: Login denied with message to check email

## Database Schema Changes

The User model now includes:

```javascript
{
  // ... existing fields
  isEmailVerified: {
    type: Boolean,
    default: false
  },
  emailVerificationToken: {
    type: String,
    default: null
  },
  emailVerificationExpires: {
    type: Date,
    default: null
  }
}
```

## Testing

### Test with Development Mode

1. Don't set `EMAIL_SERVICE` in `.env`
2. Register a user
3. Check console for verification link
4. Copy the token from the link
5. Use GET request: `/api/auth/verify-email/{token}`

### Test with Real Email

1. Configure Gmail or SMTP in `.env`
2. Register with your real email
3. Check your inbox
4. Click the verification link
5. Try to login

## Security Features

- ✅ Tokens expire after 24 hours
- ✅ Tokens are cryptographically random (32 bytes)
- ✅ One-time use tokens (deleted after verification)
- ✅ Email verification required before login
- ✅ Secure password hashing with bcrypt
- ✅ JWT tokens for authentication

## Troubleshooting

### Emails Not Sending (Gmail)

1. Ensure 2FA is enabled on your Google account
2. Use App Password, not your regular password
3. Check "Less secure app access" is OFF (use App Password instead)
4. Verify EMAIL_SERVICE is set to "gmail"

### Emails Going to Spam

1. Use a professional email address in EMAIL_FROM
2. Consider using a dedicated email service (SendGrid, AWS SES)
3. Set up SPF, DKIM, and DMARC records for your domain

### Verification Link Not Working

1. Check FRONTEND_URL is correct in `.env`
2. Verify the token hasn't expired (24 hours)
3. Ensure the user exists in database
4. Check server logs for errors

## Production Recommendations

1. **Use a dedicated email service** (SendGrid, AWS SES, Mailgun)
2. **Set up email domain authentication** (SPF, DKIM, DMARC)
3. **Monitor email delivery rates**
4. **Implement rate limiting** for resend verification
5. **Add email templates customization**
6. **Log email sending failures** for debugging
7. **Set appropriate FRONTEND_URL** for production domain

## Future Enhancements

- [ ] Email change verification
- [ ] Welcome email after verification
- [ ] Account deletion confirmation email
- [ ] Email notification preferences
- [ ] Multi-language email templates
- [ ] Email delivery status tracking
