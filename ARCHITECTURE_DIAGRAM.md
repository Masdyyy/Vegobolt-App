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


