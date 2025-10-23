# Vegobolt System - Data Flow Diagram

## System Overview

A comprehensive IoT system for monitoring and managing vegetable oil storage tanks with mobile app interface, backend API, and ESP32 hardware integration.

---

## Level 0: System Context Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         VEGOBOLT ECOSYSTEM                               │
│                                                                          │
│  ┌──────────┐         ┌──────────────┐         ┌───────────────┐      │
│  │   User   │◄───────►│  Flutter App │◄───────►│   Backend     │      │
│  │  (Mobile)│         │  (Frontend)  │         │   (Node.js)   │      │
│  └──────────┘         └──────────────┘         └───────┬───────┘      │
│       │                      │                          │               │
│       │                      │                          │               │
│       │                      │                  ┌───────▼────────┐     │
│       │                      │                  │    MongoDB     │     │
│       │                      │                  │   (Database)   │     │
│       │                      │                  └───────┬────────┘     │
│       │                      │                          │               │
│       │               ┌──────▼──────┐          ┌───────▼────────┐     │
│       └──────────────►│   Google    │          │   Nodemailer   │     │
│                       │   OAuth     │          │ (Email Service)│     │
│                       └─────────────┘          └────────────────┘     │
│                                                                          │
│                       ┌─────────────────┐                               │
│                       │   ESP32 Device  │                               │
│                       │  (IoT Sensor)   │────────────────────────────► │
│                       └─────────────────┘         HTTP POST             │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Level 1: High-Level Data Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│   ┌──────────────┐                                                          │
│   │   FRONTEND   │                                                          │
│   │  (Flutter)   │                                                          │
│   └──────┬───────┘                                                          │
│          │                                                                   │
│          │ HTTP/HTTPS Requests (JSON)                                       │
│          │ - Authentication (JWT)                                           │
│          │ - Tank Data Queries                                              │
│          │ - Alerts Retrieval                                               │
│          │ - User Profile Management                                        │
│          │                                                                   │
│          ▼                                                                   │
│   ┌────────────────────────────────────────────┐                           │
│   │          BACKEND API LAYER                 │                           │
│   │         (Express.js Middleware)            │                           │
│   │                                            │                           │
│   │  ┌──────────┐  ┌──────────┐  ┌─────────┐ │                           │
│   │  │   Auth   │  │   Tank   │  │  Alert  │ │                           │
│   │  │  Routes  │  │  Routes  │  │ Routes  │ │                           │
│   │  └────┬─────┘  └────┬─────┘  └────┬────┘ │                           │
│   │       │             │              │      │                           │
│   └───────┼─────────────┼──────────────┼──────┘                           │
│           │             │              │                                   │
│           ▼             ▼              ▼                                   │
│   ┌────────────────────────────────────────────┐                           │
│   │        BUSINESS LOGIC LAYER                │                           │
│   │           (Controllers)                    │                           │
│   │                                            │                           │
│   │  ┌──────────────┐  ┌────────────────┐    │                           │
│   │  │     Auth     │  │      Tank      │    │                           │
│   │  │  Controller  │  │   Controller   │    │                           │
│   │  └──────┬───────┘  └───────┬────────┘    │                           │
│   └─────────┼────────────────────┼─────────────┘                           │
│             │                    │                                         │
│             ▼                    ▼                                         │
│   ┌──────────────────────────────────────────────┐                        │
│   │         DATA ACCESS LAYER                    │                        │
│   │        (Mongoose Models)                     │                        │
│   │                                              │                        │
│   │  ┌──────┐  ┌──────┐  ┌──────┐  ┌────────┐ │                        │
│   │  │ User │  │ Tank │  │Alert │  │Maint.  │ │                        │
│   │  │Model │  │Model │  │Model │  │ Model  │ │                        │
│   │  └──┬───┘  └───┬──┘  └───┬──┘  └───┬────┘ │                        │
│   └─────┼──────────┼─────────┼─────────┼───────┘                        │
│         │          │         │         │                                 │
│         └──────────┴─────────┴─────────┘                                 │
│                    │                                                      │
│                    ▼                                                      │
│         ┌─────────────────────┐                                          │
│         │      MongoDB        │                                          │
│         │     (Database)      │                                          │
│         │                     │                                          │
│         │ Collections:        │                                          │
│         │ • users             │                                          │
│         │ • tanks             │                                          │
│         │ • alerts            │                                          │
│         │ • maintenance       │                                          │
│         └─────────────────────┘                                          │
│                                                                           │
│   ┌─────────────────────────┐        ┌──────────────────────┐          │
│   │   ESP32 IoT Device      │        │  External Services   │          │
│   │                         │        │                      │          │
│   │ • Tank Level Sensor     │        │ • Google OAuth 2.0   │          │
│   │ • Battery Monitor       │───────►│ • Nodemailer (SMTP)  │          │
│   │ • Temperature Sensor    │ POST   │ • JWT Token Service  │          │
│   │                         │        │                      │          │
│   └─────────────────────────┘        └──────────────────────┘          │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

---

## Level 2: Detailed Component Data Flow

### A. Authentication Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         AUTHENTICATION DATA FLOW                              │
└──────────────────────────────────────────────────────────────────────────────┘

1. USER REGISTRATION
   ┌──────┐                     ┌─────────┐                  ┌──────────┐
   │ User │────[email/pwd]─────►│ Signup  │─────[POST]──────►│  /auth/  │
   └──────┘                     │  Page   │                  │ register │
                                └─────────┘                  └────┬─────┘
                                                                  │
                                                                  ▼
                                                        ┌──────────────────┐
                                                        │ authController   │
                                                        │  .register()     │
                                                        └────────┬─────────┘
                                                                 │
                                    ┌────────────────────────────┼──────────────┐
                                    │                            │              │
                                    ▼                            ▼              ▼
                              [Hash Password]            [Check if Exists] [Generate Token]
                                    │                            │              │
                                    └────────────────────────────┴──────────────┘
                                                                 │
                                                                 ▼
                                                        ┌──────────────────┐
                                                        │  MongoDB: users  │
                                                        │  - Save User     │
                                                        │  - isVerified: F │
                                                        └────────┬─────────┘
                                                                 │
                                                                 ▼
                                                        ┌──────────────────┐
                                                        │   Nodemailer     │
                                                        │ Send Verification│
                                                        │     Email        │
                                                        └────────┬─────────┘
                                                                 │
                                                                 ▼
                                                          [User's Email]


2. EMAIL VERIFICATION
   ┌──────┐                     ┌─────────┐                  ┌──────────┐
   │ User │──[click link]──────►│  Email  │─────[GET]───────►│  /auth/  │
   └──────┘                     │ Client  │                  │verify-   │
                                └─────────┘                  │email/:tkn│
                                                             └────┬─────┘
                                                                  │
                                                                  ▼
                                                        ┌──────────────────┐
                                                        │ authController   │
                                                        │  .verifyEmail()  │
                                                        └────────┬─────────┘
                                                                 │
                                                                 ▼
                                                        ┌──────────────────┐
                                                        │  MongoDB: users  │
                                                        │ - Find by Token  │
                                                        │ - Update: verified│
                                                        └────────┬─────────┘
                                                                 │
                                                                 ▼
                                                        [Success Response]


3. LOGIN FLOW
   ┌──────┐                     ┌─────────┐                  ┌──────────┐
   │ User │────[credentials]────►│  Login  │─────[POST]──────►│  /auth/  │
   └──────┘                     │  Page   │                  │  login   │
                                └─────────┘                  └────┬─────┘
                                                                  │
                                                                  ▼
                                                        ┌──────────────────┐
                                                        │ authController   │
                                                        │    .login()      │
                                                        └────────┬─────────┘
                                                                 │
                                    ┌────────────────────────────┼──────────────┐
                                    │                            │              │
                                    ▼                            ▼              ▼
                            [Verify Password]            [Check Verified] [Generate JWT]
                                    │                            │              │
                                    └────────────────────────────┴──────────────┘
                                                                 │
                                                                 ▼
                                                        ┌──────────────────┐
                                                        │ Return:          │
                                                        │ - JWT Token      │
                                                        │ - User Profile   │
                                                        │ - Expiry Time    │
                                                        └────────┬─────────┘
                                                                 │
                                                                 ▼
                                                        [Store Token Locally]


4. GOOGLE OAUTH LOGIN
   ┌──────┐                     ┌─────────┐                  ┌──────────┐
   │ User │──[Google Sign-in]──►│  Login  │─────[OAuth]─────►│  Google  │
   └──────┘                     │  Page   │                  │  OAuth   │
                                └────┬────┘                  └────┬─────┘
                                     │                            │
                                     │◄───[Google Token]──────────┘
                                     │
                                     └─────[POST /auth/google]─────►
                                                                    │
                                                                    ▼
                                                          ┌──────────────────┐
                                                          │ authController   │
                                                          │ .googleLogin()   │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          ┌──────────────────┐
                                                          │ Verify Google    │
                                                          │ Token            │
                                                          │ Create/Find User │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          [Return JWT Token]
```

### B. Tank Monitoring Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         TANK MONITORING DATA FLOW                             │
└──────────────────────────────────────────────────────────────────────────────┘

1. ESP32 SENSOR DATA COLLECTION
   ┌────────────┐
   │  ESP32     │
   │  Device    │
   └─────┬──────┘
         │ [Read Sensors]
         │
         ├─► Ultrasonic Sensor ──► Tank Level (%)
         │
         ├─► Battery Monitor ───► Battery Level (%)
         │
         └─► Temperature Sensor ─► Temperature (°C)
                    │
                    ▼
          ┌──────────────────┐
          │  JSON Payload:   │
          │  {               │
          │   tankLevel: 75, │
          │   battery: 85,   │
          │   temp: 28,      │
          │   machineId: "X" │
          │  }               │
          └────────┬─────────┘
                   │
                   ▼ [HTTP POST]
          ┌──────────────────┐
          │  /api/tank/      │
          │   update         │
          └────────┬─────────┘
                   │
                   ▼
          ┌──────────────────┐
          │ tankController   │
          │ .updateStatus()  │
          └────────┬─────────┘
                   │
                   ├─► [Validate Data]
                   │
                   ├─► [Check Thresholds]
                   │   • Tank > 90% → Create Alert
                   │   • Battery < 20% → Create Alert
                   │
                   ▼
          ┌──────────────────┐
          │  MongoDB         │
          │  - tanks (update)│
          │  - alerts (insert│
          │    if needed)    │
          └────────┬─────────┘
                   │
                   ▼
          [Response to ESP32]


2. MOBILE APP TANK DATA RETRIEVAL
   ┌──────────┐                     ┌─────────┐                  ┌──────────┐
   │   User   │──[Open Dashboard]──►│Dashboard│─────[GET]───────►│  /api/   │
   └──────────┘                     │  Page   │                  │  tank/   │
                                    └─────────┘                  │  status  │
                                                                 └────┬─────┘
                                                                      │
                                                                      ▼
                                                          ┌──────────────────┐
                                                          │ tankController   │
                                                          │  .getStatus()    │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          ┌──────────────────┐
                                                          │  MongoDB: tanks  │
                                                          │  - Find latest   │
                                                          │    readings      │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          ┌──────────────────┐
                                                          │  Return:         │
                                                          │  {               │
                                                          │   tankLevel: 75, │
                                                          │   battery: 85,   │
                                                          │   temperature: 28│
                                                          │   status: "OK",  │
                                                          │   timestamp: ... │
                                                          │  }               │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          [Display in UI]
                                                          • Machine Status Card
                                                          • Progress Bars
                                                          • Warning Badges


3. HISTORICAL DATA RETRIEVAL
   ┌──────────┐                     ┌─────────┐                  ┌──────────┐
   │   User   │──[View History]────►│ Machine │─────[GET]───────►│  /api/   │
   └──────────┘                     │  Page   │                  │  tank/   │
                                    └─────────┘                  │ history  │
                                                                 └────┬─────┘
                                                                      │
                                                                      ▼
                                                          ┌──────────────────┐
                                                          │ tankController   │
                                                          │  .getHistory()   │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          ┌──────────────────┐
                                                          │  MongoDB: tanks  │
                                                          │  - Query range   │
                                                          │  - Sort by time  │
                                                          │  - Aggregate     │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          [Return Time Series]
                                                          • Charts/Graphs
                                                          • Trend Analysis
```

### C. Alerts System Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                         ALERTS SYSTEM DATA FLOW                               │
└──────────────────────────────────────────────────────────────────────────────┘

1. ALERT GENERATION (Automated)
   ┌────────────────┐
   │  Tank Update   │ (from ESP32)
   └───────┬────────┘
           │
           ▼
   ┌────────────────────┐
   │ Check Thresholds:  │
   │ • Tank >= 90%      │───Yes──► [Create Critical Alert]
   │ • Battery <= 20%   │───Yes──► [Create Warning Alert]
   │ • Temp > 40°C      │───Yes──► [Create Warning Alert]
   └────────┬───────────┘
            │
            ▼
   ┌────────────────────┐
   │  MongoDB: alerts   │
   │  - Insert Document │
   │  {                 │
   │    type: "critical"│
   │    message: "..."  │
   │    machineId: "X"  │
   │    timestamp: ...  │
   │    read: false     │
   │  }                 │
   └────────┬───────────┘
            │
            ▼
   [Real-time Notification]
   (Future: Push notifications)


2. ALERT RETRIEVAL (Mobile App)
   ┌──────────┐                     ┌─────────┐                  ┌──────────┐
   │   User   │──[Open Alerts]─────►│ Alerts  │─────[GET]───────►│  /api/   │
   └──────────┘                     │  Page   │                  │ alerts/  │
                                    └─────────┘                  └────┬─────┘
                                                                      │
                                                                      ▼
                                                          ┌──────────────────┐
                                                          │  MongoDB: alerts │
                                                          │  - Find by user  │
                                                          │  - Sort: recent  │
                                                          │  - Filter: unread│
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          ┌──────────────────┐
                                                          │  Return List:    │
                                                          │  [               │
                                                          │   {              │
                                                          │    title: "...", │
                                                          │    severity: ".."│
                                                          │    timestamp: ..│
                                                          │   }              │
                                                          │  ]               │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          [Display Alert Cards]
                                                          • Color-coded badges
                                                          • Timestamps
                                                          • Actions (dismiss)


3. ALERT ACTIONS
   ┌──────────┐
   │   User   │─┬─[Mark as Read]──────►[Update alert.read = true]
   └──────────┘ │
                ├─[Dismiss]────────────►[Delete alert document]
                │
                └─[Navigate to Machine]►[Open Machine page with context]
```

### D. User Profile & Settings Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                      USER PROFILE MANAGEMENT FLOW                             │
└──────────────────────────────────────────────────────────────────────────────┘

1. VIEW PROFILE
   ┌──────────┐                     ┌─────────┐                  ┌──────────┐
   │   User   │──[View Settings]───►│Settings │─────[GET]───────►│  /api/   │
   └──────────┘                     │  Page   │  [+ JWT Token]   │ users/   │
                                    └─────────┘                  │ profile  │
                                                                 └────┬─────┘
                                                                      │
                                                                      ▼
                                                          ┌──────────────────┐
                                                          │ authenticateToken│
                                                          │  (Middleware)    │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          ┌──────────────────┐
                                                          │ userController   │
                                                          │ .getUserProfile()│
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          ┌──────────────────┐
                                                          │  MongoDB: users  │
                                                          │  - Find by ID    │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          [Return Profile Data]


2. UPDATE PROFILE
   ┌──────────┐                     ┌─────────┐                  ┌──────────┐
   │   User   │──[Edit & Save]─────►│Settings │─────[PUT]───────►│  /api/   │
   └──────────┘                     │  Page   │  [+ JWT Token]   │ users/   │
                                    └─────────┘                  │ profile  │
                                                                 └────┬─────┘
                                                                      │
                                                                      ▼
                                                          ┌──────────────────┐
                                                          │ Validate Input   │
                                                          │ - Name, Email    │
                                                          │ - Phone Number   │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          ┌──────────────────┐
                                                          │  MongoDB: users  │
                                                          │  - Update fields │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          [Return Success]


3. DELETE ACCOUNT
   ┌──────────┐                     ┌─────────┐                  ┌──────────┐
   │   User   │──[Confirm Delete]──►│Settings │────[DELETE]─────►│  /api/   │
   └──────────┘                     │  Page   │  [+ JWT Token]   │ users/   │
                                    └─────────┘                  │ account  │
                                                                 └────┬─────┘
                                                                      │
                                                                      ▼
                                                          ┌──────────────────┐
                                                          │  MongoDB         │
                                                          │  - Delete user   │
                                                          │  - Delete tanks  │
                                                          │  - Delete alerts │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          [Logout & Redirect]
```

### E. Maintenance Management Flow

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                      MAINTENANCE MANAGEMENT FLOW                              │
└──────────────────────────────────────────────────────────────────────────────┘

1. SCHEDULE MAINTENANCE
   ┌──────────┐                     ┌─────────┐                  ┌──────────┐
   │   User   │──[Add Maintenance]─►│Mainten. │────[POST]───────►│  /api/   │
   └──────────┘    (Modal)          │  Page   │                  │mainten./ │
                                    └─────────┘                  │ schedule │
                                                                 └────┬─────┘
                                                                      │
                                                                      ▼
                                                          ┌──────────────────┐
                                                          │  MongoDB:        │
                                                          │  maintenance     │
                                                          │  - Insert:       │
                                                          │   {              │
                                                          │    type: "...",  │
                                                          │    date: ...,    │
                                                          │    status: "due" │
                                                          │   }              │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          [Show in Schedule Tab]


2. VIEW MAINTENANCE HISTORY
   ┌──────────┐                     ┌─────────┐                  ┌──────────┐
   │   User   │──[History Tab]─────►│Mainten. │─────[GET]───────►│  /api/   │
   └──────────┘                     │  Page   │                  │mainten./ │
                                    └─────────┘                  │ history  │
                                                                 └────┬─────┘
                                                                      │
                                                                      ▼
                                                          ┌──────────────────┐
                                                          │  MongoDB:        │
                                                          │  maintenance     │
                                                          │  - Query:        │
                                                          │   status="done"  │
                                                          │  - Sort: recent  │
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          [Display History Cards]


3. MARK MAINTENANCE COMPLETE
   ┌──────────┐                     ┌─────────┐                  ┌──────────┐
   │   User   │──[Mark Complete]───►│Mainten. │────[PATCH]──────►│  /api/   │
   └──────────┘                     │  Page   │                  │mainten./ │
                                    └─────────┘                  │ :id      │
                                                                 └────┬─────┘
                                                                      │
                                                                      ▼
                                                          ┌──────────────────┐
                                                          │  MongoDB:        │
                                                          │  maintenance     │
                                                          │  - Update:       │
                                                          │   status="done"  │
                                                          │   completedAt:...│
                                                          └────────┬─────────┘
                                                                   │
                                                                   ▼
                                                          [Move to History Tab]
```

---

## Level 3: Data Entity Relationships

```
┌────────────────────────────────────────────────────────────────────────┐
│                      DATABASE SCHEMA RELATIONSHIPS                      │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│      users       │
├──────────────────┤
│ _id (ObjectId)   │◄────────┐
│ email (String)   │         │ userId (FK)
│ password (Hash)  │         │
│ name (String)    │         │
│ isVerified (Bool)│         │
│ verificationToken│         │
│ googleId (String)│         │
│ createdAt (Date) │         │
└──────────────────┘         │
                             │
                    ┌────────┴────────┐
                    │                 │
         ┌──────────▼─────┐  ┌────────▼────────┐
         │     tanks      │  │     alerts      │
         ├────────────────┤  ├─────────────────┤
         │ _id (ObjectId) │  │ _id (ObjectId)  │
         │ userId (FK)    │  │ userId (FK)     │
         │ machineId (Str)│  │ machineId (Str) │
         │ tankLevel (%)  │  │ type (String)   │
         │ battery (%)    │  │ severity (Str)  │
         │ temperature(°C)│  │ message (String)│
         │ location (Str) │  │ read (Boolean)  │
         │ status (String)│  │ timestamp (Date)│
         │ timestamp(Date)│  └─────────────────┘
         └────────────────┘
                 │
                 │ machineId (FK)
                 │
         ┌───────▼──────────┐
         │   maintenance    │
         ├──────────────────┤
         │ _id (ObjectId)   │
         │ userId (FK)      │
         │ machineId (FK)   │
         │ type (String)    │
         │ scheduledDate(Dt)│
         │ status (String)  │
         │ completedAt(Date)│
         │ notes (String)   │
         └──────────────────┘
```

---

## Level 4: Security & Authentication Flow

```
┌────────────────────────────────────────────────────────────────────────┐
│                      SECURITY ARCHITECTURE                              │
└────────────────────────────────────────────────────────────────────────┘

1. JWT TOKEN FLOW

   Registration/Login
         │
         ▼
   ┌─────────────────┐
   │ Generate JWT    │
   │ Secret Key:     │
   │ JWT_SECRET      │
   │ Expiry: 24h     │
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │ Return Token to │
   │ Client          │
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │ Store in Local  │
   │ Storage/Memory  │
   └────────┬────────┘
            │
            │ [Subsequent Requests]
            ▼
   ┌─────────────────────────────┐
   │ Send Token in Header:       │
   │ Authorization: Bearer <JWT> │
   └────────┬────────────────────┘
            │
            ▼
   ┌──────────────────────┐
   │ authenticateToken    │
   │ Middleware           │
   │ - Verify Signature   │
   │ - Check Expiry       │
   │ - Extract userId     │
   └──────┬──────────────┘
          │
          ├─► Valid ───► [Allow Request]
          │
          └─► Invalid ─► [401 Unauthorized]


2. PASSWORD SECURITY

   User Registration
         │
         ▼
   ┌─────────────────┐
   │ bcrypt.hash()   │
   │ Salt Rounds: 10 │
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │ Store Hashed    │
   │ Password in DB  │
   └─────────────────┘

   User Login
         │
         ▼
   ┌─────────────────────┐
   │ bcrypt.compare()    │
   │ Input vs Stored Hash│
   └────────┬────────────┘
            │
            ├─► Match ───► [Generate JWT]
            │
            └─► No Match ─► [401 Invalid Credentials]


3. EMAIL VERIFICATION SECURITY

   Registration
         │
         ▼
   ┌─────────────────────────┐
   │ Generate Random Token   │
   │ crypto.randomBytes(32)  │
   └────────┬────────────────┘
            │
            ▼
   ┌─────────────────────────┐
   │ Store in DB:            │
   │ - verificationToken     │
   │ - verificationExpiry    │
   │   (24 hours)            │
   └────────┬────────────────┘
            │
            ▼
   ┌─────────────────────────┐
   │ Send Email with Link:   │
   │ /verify-email/<token>   │
   └────────┬────────────────┘
            │
            ▼
   ┌─────────────────────────┐
   │ User Clicks Link        │
   │ - Check Token Exists    │
   │ - Check Not Expired     │
   │ - Update isVerified: T  │
   │ - Clear Token           │
   └─────────────────────────┘


4. CORS & MIDDLEWARE SECURITY

   Request from Flutter App
            │
            ▼
   ┌──────────────────────┐
   │ CORS Middleware      │
   │ - Origin: *          │
   │ - Methods: GET,POST..│
   │ - Headers: Auth,Cont.│
   └──────┬───────────────┘
          │
          ▼
   ┌──────────────────────┐
   │ Request Logger       │
   │ - Log Method & Path  │
   └──────┬───────────────┘
          │
          ▼
   ┌──────────────────────┐
   │ Body Parser          │
   │ - Parse JSON         │
   └──────┬───────────────┘
          │
          ▼
   ┌──────────────────────┐
   │ Route Handler        │
   └──────┬───────────────┘
          │
          ▼
   ┌──────────────────────┐
   │ Error Handler        │
   │ - Catch Errors       │
   │ - Return 500         │
   └──────────────────────┘
```

---

## Summary: Key Data Flows

### 1. **User Onboarding Flow**

User Registration → Email Sent → Email Verification → Account Active → Login → JWT Token → Access App

### 2. **Tank Monitoring Flow**

ESP32 Reads Sensors → POST to Backend → Validate & Store → Check Thresholds → Generate Alerts → Mobile App Fetches Data → Display UI

### 3. **Real-time Monitoring Flow**

Mobile App → Periodic GET Requests → Backend Queries Latest Data → Return to App → Update UI

### 4. **Alert Management Flow**

Threshold Exceeded → Auto-create Alert → Store in DB → Mobile App Fetches → Display Alert Card → User Actions (dismiss/acknowledge)

### 5. **Maintenance Flow**

User Schedules Maintenance → Store in DB → Display in Schedule Tab → Mark Complete → Move to History Tab

### 6. **Authentication Flow**

Login/Register → Generate JWT → Store Token → Attach to Requests → Middleware Validates → Grant/Deny Access

---

## Technology Stack Summary

| Layer                | Technology         | Purpose                        |
| -------------------- | ------------------ | ------------------------------ |
| **Frontend**         | Flutter (Dart)     | Cross-platform mobile app      |
| **State Management** | StatefulWidget     | Local component state          |
| **HTTP Client**      | dio / http package | API requests                   |
| **Theme System**     | AppColors utility  | Light/Dark mode support        |
| **Backend**          | Node.js + Express  | REST API server                |
| **Database**         | MongoDB + Mongoose | NoSQL data storage             |
| **Authentication**   | JWT + bcrypt       | Secure auth & password hashing |
| **Email**            | Nodemailer         | Verification & notifications   |
| **OAuth**            | Google OAuth 2.0   | Social login                   |
| **IoT Device**       | ESP32              | Hardware sensors               |
| **Communication**    | HTTP/HTTPS         | REST API calls                 |

---

## API Endpoints Summary

### Authentication (`/api/auth`)

- `POST /register` - User registration
- `POST /login` - Email/password login
- `POST /google` - Google OAuth login
- `GET /verify-email/:token` - Email verification
- `POST /resend-verification` - Resend verification email
- `POST /verify` - Verify JWT token
- `GET /profile` - Get user profile (protected)
- `POST /logout` - Logout user (protected)
- `POST /password-reset` - Request password reset

### Tank Management (`/api/tank`)

- `GET /status` - Get current tank status
- `POST /update` - Update tank data (ESP32)
- `GET /alerts` - Get tank-related alerts
- `GET /history` - Get historical tank data

### User Management (`/api/users`)

- `GET /profile` - Get user profile (protected)
- `PUT /profile` - Update user profile (protected)
- `DELETE /account` - Delete user account (protected)

### Alerts (`/api/alerts`)

- `GET /` - Get all alerts for user

---

## Future Enhancements (Potential)

1. **WebSocket Integration** - Real-time push notifications
2. **Firebase Cloud Messaging** - Mobile push notifications
3. **Analytics Dashboard** - Historical trends & insights
4. **Multi-machine Support** - Manage multiple tanks per user
5. **Role-based Access** - Admin, Manager, Operator roles
6. **Geofencing** - Location-based alerts
7. **Predictive Maintenance** - ML-based predictions
8. **API Rate Limiting** - Prevent abuse
9. **Redis Caching** - Improve performance
10. **GraphQL API** - More flexible data queries

---

_Generated: October 21, 2025_
_Version: 1.0_
_System: Vegobolt IoT Tank Monitoring Platform_
