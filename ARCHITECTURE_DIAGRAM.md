# Backend Integration Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                              │
│                       (Mobile Client)                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │
                    ┌─────────┴─────────┐
                    │                   │
        ┌───────────▼──────────┐   ┌───▼──────────────┐
        │   Login.dart         │   │  Signup.dart     │
        │                      │   │                  │
        │  • Email field       │   │  • Name field    │
        │  • Password field    │   │  • Email field   │
        │  • Remember Me       │   │  • Password      │
        │  • Login button      │   │  • Sign up btn   │
        └──────────┬───────────┘   └──────┬───────────┘
                   │                      │
                   │                      │
                   └──────────┬───────────┘
                              │
                              │
                   ┌──────────▼────────────┐
                   │   AuthService         │
                   │  (API Client Layer)   │
                   │                       │
                   │  • login()            │
                   │  • register()         │
                   │  • logout()           │
                   │  • getProfile()       │
                   │  • isLoggedIn()       │
                   └──────────┬────────────┘
                              │
                              │ HTTP Requests
                              │ (http package)
                              │
                   ┌──────────▼────────────┐
                   │   ApiConfig           │
                   │  (Configuration)      │
                   │                       │
                   │  baseUrl:             │
                   │  http://10.0.2.2:3000 │
                   │                       │
                   │  Endpoints:           │
                   │  /api/auth/login      │
                   │  /api/auth/register   │
                   └──────────┬────────────┘
                              │
                              │ REST API
                              │
┌─────────────────────────────▼─────────────────────────────────┐
│                      NODE.JS BACKEND                          │
│                    (Express Server)                           │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │                   Routes Layer                         │  │
│  │                                                        │  │
│  │  POST /api/auth/login                                  │  │
│  │  POST /api/auth/register                               │  │
│  │  POST /api/auth/logout                                 │  │
│  │  GET  /api/auth/profile                                │  │
│  └─────────────────────┬──────────────────────────────────┘  │
│                        │                                      │
│  ┌─────────────────────▼──────────────────────────────────┐  │
│  │              Auth Controller                           │  │
│  │                                                        │  │
│  │  • Validate input                                      │  │
│  │  • Hash passwords (bcrypt)                             │  │
│  │  • Generate JWT tokens                                 │  │
│  │  • Handle errors                                       │  │
│  └─────────────────────┬──────────────────────────────────┘  │
│                        │                                      │
│  ┌─────────────────────▼──────────────────────────────────┐  │
│  │                User Model                              │  │
│  │                                                        │  │
│  │  • findByEmail()                                       │  │
│  │  • createUser()                                        │  │
│  │  • updateUser()                                        │  │
│  └─────────────────────┬──────────────────────────────────┘  │
│                        │                                      │
└────────────────────────┼──────────────────────────────────────┘
                         │
                         │ Mongoose ODM
                         │
         ┌───────────────▼────────────────┐
         │      MongoDB Atlas             │
         │     (Cloud Database)           │
         │                                │
         │  Collections:                  │
         │  • users                       │
         │    - _id                       │
         │    - email                     │
         │    - password (hashed)         │
         │    - displayName               │
         │    - isActive                  │
         │    - createdAt                 │
         │    - updatedAt                 │
         └────────────────────────────────┘


═══════════════════════════════════════════════════════════════

DATA FLOW - LOGIN EXAMPLE:

1. USER ACTION
   User enters: test@vegobolt.com / Test123
   Clicks "Log in"

2. FLUTTER APP
   Login.dart → _handleLogin()
   ↓
   Validates form
   ↓
   Calls: authService.login(email, password)

3. AUTH SERVICE
   Creates HTTP POST request
   ↓
   POST http://10.0.2.2:3000/api/auth/login
   Body: {"email": "test@vegobolt.com", "password": "Test123"}

4. BACKEND RECEIVES
   Express server → authRoutes.js
   ↓
   Route: POST /api/auth/login
   ↓
   Calls: authController.login()

5. AUTH CONTROLLER
   Validates input ✓
   ↓
   Calls: User.findByEmail('test@vegobolt.com')
   ↓
   MongoDB query executed
   ↓
   User found ✓
   ↓
   Compares: bcrypt.compare('Test123', hashedPasswordFromDB)
   ↓
   Match ✓
   ↓
   Generates JWT token
   ↓
   Returns response:
   {
     "success": true,
     "message": "Login successful",
     "data": {
       "user": {...},
       "token": "eyJhbGc..."
     }
   }

6. AUTH SERVICE RECEIVES
   Parses response
   ↓
   Saves token to secure storage:
   • auth_token: "eyJhbGc..."
   • user_email: "test@vegobolt.com"
   • user_display_name: "Test User"
   ↓
   Returns success to Login.dart

7. LOGIN PAGE
   Shows success message
   ↓
   Clears password field
   ↓
   Navigates to /dashboard

═══════════════════════════════════════════════════════════════

SECURITY LAYERS:

1. TRANSPORT
   • HTTP (development)
   • HTTPS (production - recommended)

2. PASSWORD HASHING
   • bcrypt with salt rounds (10)
   • One-way hash (cannot be reversed)

3. TOKEN AUTHENTICATION
   • JWT with secret key
   • 7-day expiration
   • Stateless authentication

4. SECURE STORAGE
   • flutter_secure_storage
   • OS-level encryption
   • Isolated app storage

5. INPUT VALIDATION
   • Email format validation
   • Password strength requirements
   • SQL injection prevention (MongoDB)

═══════════════════════════════════════════════════════════════
