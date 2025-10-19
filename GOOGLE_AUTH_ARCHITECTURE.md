# Google Authentication Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         VEGOBOLT GOOGLE AUTHENTICATION                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                              FLUTTER APP (Frontend)                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌────────────────┐          ┌──────────────────────────────────┐           │
│  │  Login Page    │          │     auth_service.dart            │           │
│  │  Login.dart    │          │                                  │           │
│  │                │          │  • loginWithGoogle()            │           │
│  │  [Google Btn]──┼─────────▶│  • GoogleSignIn instance        │           │
│  │  onClick       │          │  • Token management             │           │
│  └────────────────┘          │  • Secure storage               │           │
│         │                    └──────────────┬───────────────────┘           │
│         │                                   │                               │
│         │  1. User taps                     │  3. Get ID token              │
│         │  "Log in with                     │  4. Send to backend           │
│         │   Google"                         │                               │
│         ▼                                   ▼                               │
│  ┌─────────────────────────────────────────────────────┐                   │
│  │         google_sign_in package (^6.2.1)             │                   │
│  │         • Handles OAuth flow                        │                   │
│  │         • Gets Google ID token                      │                   │
│  └─────────────────────────────────────────────────────┘                   │
│         │                                   │                               │
│         │  2. OAuth flow                    │  5. Receive JWT + user        │
│         ▼                                   ▼                               │
│  ┌─────────────────┐          ┌──────────────────────┐                     │
│  │  Google OAuth   │          │  Secure Storage      │                     │
│  │  (External)     │          │  • JWT token         │                     │
│  └─────────────────┘          │  • User email        │                     │
│                               │  • Display name       │                     │
│                               └──────────────────────┘                     │
│                                                                              │
└────────────────────────────────────┬─────────────────────────────────────────┘
                                     │
                                     │ HTTP POST
                                     │ /api/auth/google
                                     │ { idToken: "..." }
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         BACKEND (Node.js/Express)                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────┐       │
│  │  authRoutes.js                                                   │       │
│  │  POST /api/auth/google                                           │       │
│  └───────────────────────────────┬──────────────────────────────────┘       │
│                                  │                                          │
│                                  ▼                                          │
│  ┌──────────────────────────────────────────────────────────────────┐       │
│  │  authController.js                                               │       │
│  │  googleLogin(req, res)                                           │       │
│  │  • Receives ID token                                             │       │
│  │  • Calls verifyGoogleToken()                                     │       │
│  │  • Creates/updates user                                          │       │
│  │  • Returns JWT token                                             │       │
│  └───────────────────────────────┬──────────────────────────────────┘       │
│                                  │                                          │
│                                  ▼                                          │
│  ┌──────────────────────────────────────────────────────────────────┐       │
│  │  googleAuthService.js                                            │       │
│  │  • verifyGoogleToken(idToken)                                    │       │
│  │  • Uses google-auth-library                                      │       │
│  │  • Verifies with Web/Android/iOS client IDs                      │       │
│  │  • Returns user info (email, name, picture, googleId)            │       │
│  └───────────────────────────────┬──────────────────────────────────┘       │
│                                  │                                          │
│                                  ▼                                          │
│  ┌──────────────────────────────────────────────────────────────────┐       │
│  │  User.js (MongoDB Model)                                         │       │
│  │  • email (required)                                              │       │
│  │  • password (optional for Google users)                          │       │
│  │  • displayName                                                   │       │
│  │  • googleId (Google user ID)                                     │       │
│  │  • authProvider: 'email' | 'google'                              │       │
│  │  • isEmailVerified (auto true for Google)                        │       │
│  │  • profilePicture                                                │       │
│  └───────────────────────────────┬──────────────────────────────────┘       │
│                                  │                                          │
│                                  ▼                                          │
│  ┌──────────────────────────────────────────────────────────────────┐       │
│  │  jwtService.js                                                   │       │
│  │  • generateToken(user)                                           │       │
│  │  • Creates JWT with user ID, email                               │       │
│  │  • Used for app authentication                                   │       │
│  └──────────────────────────────────────────────────────────────────┘       │
│                                                                              │
└────────────────────────────────────┬─────────────────────────────────────────┘
                                     │
                                     │ JWT Token +
                                     │ User Data
                                     ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            MongoDB (Database)                                │
├─────────────────────────────────────────────────────────────────────────────┤
│  Users Collection:                                                           │
│  {                                                                           │
│    _id: ObjectId,                                                            │
│    email: "user@gmail.com",                                                  │
│    displayName: "John Doe",                                                  │
│    googleId: "1234567890",                                                   │
│    authProvider: "google",                                                   │
│    isEmailVerified: true,                                                    │
│    profilePicture: "https://lh3.googleusercontent.com/...",                  │
│    isActive: true,                                                           │
│    createdAt: ISODate,                                                       │
│    updatedAt: ISODate                                                        │
│  }                                                                           │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                     GOOGLE CLOUD CONSOLE (Configuration)                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  OAuth 2.0 Credentials:                                                      │
│  ┌────────────────────────────────────────────────────────────────┐          │
│  │  1. Web Client ID                                              │          │
│  │     • For backend token verification                           │          │
│  │     • GOOGLE_CLIENT_ID_WEB in .env                             │          │
│  └────────────────────────────────────────────────────────────────┘          │
│  ┌────────────────────────────────────────────────────────────────┐          │
│  │  2. Android Client ID                                          │          │
│  │     • For Android app                                          │          │
│  │     • Requires SHA-1 fingerprint                               │          │
│  │     • GOOGLE_CLIENT_ID_ANDROID in .env                         │          │
│  └────────────────────────────────────────────────────────────────┘          │
│  ┌────────────────────────────────────────────────────────────────┐          │
│  │  3. iOS Client ID                                              │          │
│  │     • For iOS app                                              │          │
│  │     • Requires bundle ID                                       │          │
│  │     • URL scheme in Info.plist                                 │          │
│  │     • GOOGLE_CLIENT_ID_IOS in .env                             │          │
│  └────────────────────────────────────────────────────────────────┘          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          AUTHENTICATION FLOW                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. User taps "Log in with Google" button                                   │
│  2. google_sign_in package initiates OAuth 2.0 flow                          │
│  3. User selects Google account and grants permissions                       │
│  4. Flutter receives Google ID token                                         │
│  5. Flutter sends ID token to backend: POST /api/auth/google                 │
│  6. Backend verifies token with Google (google-auth-library)                 │
│  7. Backend extracts user info (email, name, picture, googleId)              │
│  8. Backend checks if user exists in MongoDB                                 │
│     • If exists: Update Google info if needed                                │
│     • If new: Create user with authProvider='google'                         │
│  9. Backend generates JWT token for the user                                 │
│ 10. Backend returns { success: true, token: "...", user: {...} }             │
│ 11. Flutter stores JWT in secure storage                                     │
│ 12. Flutter navigates to Dashboard                                           │
│ 13. ✅ User is authenticated!                                                 │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                            SECURITY LAYERS                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  1. Google OAuth 2.0          ✅ Industry-standard authentication            │
│  2. Token Verification        ✅ Server-side validation                      │
│  3. JWT Authentication        ✅ Stateless session management                │
│  4. Secure Storage            ✅ Platform-native encryption                  │
│  5. HTTPS Communication       ✅ Encrypted data transfer                     │
│  6. Environment Variables     ✅ Secrets not in code                         │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Key Components

### Frontend (Flutter)
- **google_sign_in**: ^6.2.1 - Official Google Sign-In plugin
- **auth_service.dart**: Handles authentication logic
- **Login.dart**: User interface with Google button
- **Secure Storage**: Stores JWT tokens safely

### Backend (Node.js)
- **google-auth-library**: Verifies Google ID tokens
- **googleAuthService.js**: Token verification service
- **authController.js**: Authentication business logic
- **User model**: Supports multiple auth providers
- **JWT**: Custom tokens for API authentication

### Infrastructure
- **MongoDB**: User data storage
- **Google Cloud Console**: OAuth credentials
- **Environment Variables**: Secure configuration

## Data Flow

1. **Outbound**: User → Google → App → Backend
2. **Inbound**: Backend → MongoDB → Backend → App → User
3. **Authentication**: Google ID Token → JWT Token → API Access
