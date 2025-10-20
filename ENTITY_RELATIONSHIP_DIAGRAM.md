# Vegobolt System - Entity Relationship Diagram (ERD)

## System Overview
Complete Entity Relationship Diagram for the Vegobolt IoT Tank Monitoring Platform, showing all entities, their attributes, relationships, and constraints.

---

## Table of Contents
1. [ERD Notation Guide](#erd-notation-guide)
2. [Complete ERD - Visual Representation](#complete-erd---visual-representation)
3. [Entity Definitions](#entity-definitions)
4. [Relationship Details](#relationship-details)
5. [Database Schema Details](#database-schema-details)
6. [Indexes and Constraints](#indexes-and-constraints)
7. [Data Types and Validations](#data-types-and-validations)

---

## ERD Notation Guide

```
┌─────────────────┐
│   ENTITY_NAME   │  ← Entity (Table/Collection)
├─────────────────┤
│ PK: _id         │  ← Primary Key
│ FK: userId      │  ← Foreign Key
│ attr: type      │  ← Attribute with data type
│ *required       │  ← Required field
│ ?optional       │  ← Optional field
└─────────────────┘

Relationships:
  ──────  One to One (1:1)
  ──────< One to Many (1:N)
  >──────< Many to Many (M:N)
```

---

## Complete ERD - Visual Representation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      VEGOBOLT DATABASE SCHEMA (MongoDB)                      │
└─────────────────────────────────────────────────────────────────────────────┘


                        ┌──────────────────────────────┐
                        │          USER                │
                        │   (users collection)         │
                        ├──────────────────────────────┤
                        │ PK: _id               ObjectId│
                        │ *email                String │
                        │ *password             String │
                        │ *firstName            String │
                        │ *lastName             String │
                        │ displayName           String │
                        │ phoneNumber           String │
                        │ profilePicture        String │
                        │ isActive              Boolean│
                        │ isEmailVerified       Boolean│
                        │ emailVerificationToken String│
                        │ emailVerificationExpires Date│
                        │ googleId              String │
                        │ passwordResetToken    String │
                        │ passwordResetExpires  Date   │
                        │ createdAt             Date   │
                        │ updatedAt             Date   │
                        └──────────┬───────────────────┘
                                   │
                                   │ 1:N
                                   │ "owns"
                     ┌─────────────┼─────────────┐
                     │             │             │
                     │             │             │
                     ▼             ▼             ▼
        ┌────────────────┐  ┌──────────────┐  ┌────────────────────┐
        │     TANK       │  │    ALERT     │  │    MAINTENANCE     │
        │ (tanks coll.)  │  │(alerts coll.)│  │(maintenance coll.) │
        ├────────────────┤  ├──────────────┤  ├────────────────────┤
        │PK: _id    ObjId│  │PK: _id ObjId │  │PK: _id      ObjectId│
        │FK: userId ObjId│  │FK: userId OId│  │FK: userId   ObjectId│
        │machineId String│  │machineId Str │  │FK: machineId String │
        │*status   String│  │*type    Str  │  │*type        String │
        │*level    Number│  │*severity Str │  │*scheduledDate Date │
        │temperature Num │  │*message  Str │  │status       String │
        │batteryLevel Num│  │description Str│  │completedAt  Date   │
        │location  String│  │isRead Boolean│  │notes        String │
        │alert     String│  │priority  Str │  │technician   String │
        │lastUpdated Date│  │createdAt Date│  │cost         Number │
        │createdAt   Date│  │updatedAt Date│  │createdAt    Date   │
        │updatedAt   Date│  │resolvedAt Dte│  │updatedAt    Date   │
        └────────┬───────┘  └──────────────┘  └────────────────────┘
                 │
                 │ 1:N
                 │ "generates"
                 │
                 ▼
        ┌────────────────┐
        │  TANK_HISTORY  │
        │(history coll.) │
        ├────────────────┤
        │PK: _id    ObjId│
        │FK: tankId ObjId│
        │FK: userId ObjId│
        │level     Number│
        │temperature Num │
        │batteryLevel Num│
        │status    String│
        │alert     String│
        │timestamp   Date│
        └────────────────┘


                        ┌──────────────────────────────┐
                        │      EXTERNAL ENTITIES       │
                        │    (Not in database)         │
                        ├──────────────────────────────┤
                        │                              │
                        │  ESP32_DEVICE                │
                        │  • Sends data via HTTP POST  │
                        │  • Connects to /api/tank/update│
                        │  • No database storage       │
                        │                              │
                        │  GOOGLE_OAUTH                │
                        │  • External authentication   │
                        │  • Returns googleId          │
                        │  • Linked to User.googleId   │
                        │                              │
                        │  EMAIL_SERVICE               │
                        │  • Nodemailer integration    │
                        │  • Verification emails       │
                        │  • Alert notifications       │
                        │                              │
                        └──────────────────────────────┘
```

---

## Entity Definitions

### 1. USER Entity

**Purpose:** Stores user account information and authentication data

**Collection Name:** `users`

**Attributes:**

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| `_id` | ObjectId | PRIMARY KEY, Auto-generated | Unique user identifier |
| `email` | String | REQUIRED, UNIQUE, INDEXED | User's email address (lowercase) |
| `password` | String | REQUIRED | Bcrypt hashed password (salt rounds: 10) |
| `firstName` | String | REQUIRED | User's first name |
| `lastName` | String | REQUIRED | User's last name |
| `displayName` | String | Optional | Full name display (auto-generated from firstName + lastName) |
| `phoneNumber` | String | Optional | Contact phone number |
| `profilePicture` | String | Optional | URL to profile image |
| `isActive` | Boolean | DEFAULT: true | Account active status |
| `isEmailVerified` | Boolean | DEFAULT: false | Email verification status |
| `emailVerificationToken` | String | Optional | Token for email verification |
| `emailVerificationExpires` | Date | Optional | Token expiry timestamp (24 hours) |
| `googleId` | String | Optional, UNIQUE | Google OAuth user ID |
| `passwordResetToken` | String | Optional | Password reset token |
| `passwordResetExpires` | Date | Optional | Reset token expiry |
| `createdAt` | Date | DEFAULT: Date.now() | Account creation timestamp |
| `updatedAt` | Date | DEFAULT: Date.now() | Last update timestamp |

**Relationships:**
- One-to-Many with TANK (A user can own multiple tanks)
- One-to-Many with ALERT (A user can have multiple alerts)
- One-to-Many with MAINTENANCE (A user can schedule multiple maintenance tasks)

**Business Rules:**
- Email must be unique across the system
- Password must be hashed before storage (never store plain text)
- Email verification required before full access
- Google OAuth users skip email verification
- displayName auto-populated if not provided

---

### 2. TANK Entity

**Purpose:** Stores current tank status and sensor readings

**Collection Name:** `tanks`

**Attributes:**

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| `_id` | ObjectId | PRIMARY KEY, Auto-generated | Unique tank identifier |
| `userId` | ObjectId | FOREIGN KEY → users._id | Owner of the tank |
| `machineId` | String | REQUIRED, INDEXED | Unique machine/device identifier (from ESP32) |
| `status` | String | REQUIRED, ENUM | Tank status: "Full", "Low", "Normal", "Critical" |
| `level` | Number | REQUIRED, MIN: 0, MAX: 100 | Current tank level (percentage) |
| `temperature` | Number | DEFAULT: 0 | Current temperature (°C) |
| `batteryLevel` | Number | DEFAULT: 0, MIN: 0, MAX: 100 | Battery level (percentage, 0 = no sensor) |
| `location` | String | Optional | Physical location/address of tank |
| `alert` | String | DEFAULT: "normal", ENUM | Alert level: "normal", "overheating", "critical", "warning" |
| `lastUpdated` | Date | AUTO-UPDATE | Last sensor reading timestamp |
| `createdAt` | Date | AUTO-TIMESTAMP | Tank registration timestamp |
| `updatedAt` | Date | AUTO-TIMESTAMP | Last modification timestamp |

**Relationships:**
- Many-to-One with USER (Multiple tanks belong to one user)
- One-to-Many with TANK_HISTORY (Tank has multiple historical records)
- One-to-Many with ALERT (Tank generates alerts)
- One-to-Many with MAINTENANCE (Tank has maintenance records)

**Business Rules:**
- level must be between 0-100
- Alert auto-generated when level >= 90% (warning)
- Alert auto-generated when level >= 95% (critical)
- Alert auto-generated when temperature > 40°C
- Alert auto-generated when batteryLevel < 20%
- machineId should match ESP32 device identifier

---

### 3. ALERT Entity

**Purpose:** Stores system alerts and notifications

**Collection Name:** `alerts`

**Attributes:**

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| `_id` | ObjectId | PRIMARY KEY, Auto-generated | Unique alert identifier |
| `userId` | ObjectId | FOREIGN KEY → users._id | Alert recipient |
| `machineId` | String | INDEXED | Related machine/tank ID |
| `type` | String | REQUIRED, ENUM | Alert type: "tank_level", "battery_low", "temperature", "maintenance", "system" |
| `severity` | String | REQUIRED, ENUM | Severity: "info", "warning", "critical", "emergency" |
| `message` | String | REQUIRED | Alert message/title |
| `description` | String | Optional | Detailed alert description |
| `isRead` | Boolean | DEFAULT: false | Read status |
| `priority` | String | ENUM | Priority: "low", "medium", "high", "urgent" |
| `createdAt` | Date | AUTO-TIMESTAMP | Alert creation time |
| `updatedAt` | Date | AUTO-TIMESTAMP | Last update time |
| `resolvedAt` | Date | Optional | Alert resolution timestamp |

**Relationships:**
- Many-to-One with USER (Multiple alerts belong to one user)
- Many-to-One with TANK (Multiple alerts from one tank)

**Business Rules:**
- Auto-created when tank level >= 90%
- Auto-created when battery level < 20%
- Auto-created when temperature > 40°C
- Severity determines UI color coding
- Unread alerts shown with badge in UI
- Alerts can be dismissed (deleted) or marked as read

**Alert Type Rules:**
- `tank_level` → severity: "warning" or "critical"
- `battery_low` → severity: "warning"
- `temperature` → severity: "warning" or "critical"
- `maintenance` → severity: "info"
- `system` → severity: "info" or "warning"

---

### 4. MAINTENANCE Entity

**Purpose:** Tracks scheduled and completed maintenance activities

**Collection Name:** `maintenance`

**Attributes:**

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| `_id` | ObjectId | PRIMARY KEY, Auto-generated | Unique maintenance record ID |
| `userId` | ObjectId | FOREIGN KEY → users._id | User who scheduled maintenance |
| `machineId` | String | INDEXED | Related tank/machine ID |
| `type` | String | REQUIRED, ENUM | Maintenance type: "cleaning", "inspection", "repair", "replacement", "calibration" |
| `scheduledDate` | Date | REQUIRED | Scheduled date for maintenance |
| `status` | String | DEFAULT: "scheduled", ENUM | Status: "scheduled", "in_progress", "completed", "cancelled" |
| `completedAt` | Date | Optional | Actual completion timestamp |
| `notes` | String | Optional | Maintenance notes/comments |
| `technician` | String | Optional | Technician name |
| `cost` | Number | Optional | Maintenance cost |
| `createdAt` | Date | AUTO-TIMESTAMP | Record creation time |
| `updatedAt` | Date | AUTO-TIMESTAMP | Last update time |

**Relationships:**
- Many-to-One with USER (Multiple maintenance records per user)
- Many-to-One with TANK (Multiple maintenance records per tank)

**Business Rules:**
- Status transitions: scheduled → in_progress → completed
- completedAt only set when status = "completed"
- Cannot delete completed maintenance (for audit trail)
- Alert created 3 days before scheduledDate
- Overdue maintenance flagged if status != "completed" after scheduledDate

---

### 5. TANK_HISTORY Entity

**Purpose:** Stores historical sensor readings for analytics and trends

**Collection Name:** `tank_history` or `readings`

**Attributes:**

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| `_id` | ObjectId | PRIMARY KEY, Auto-generated | Unique record ID |
| `tankId` | ObjectId | FOREIGN KEY → tanks._id | Related tank |
| `userId` | ObjectId | FOREIGN KEY → users._id | Tank owner |
| `level` | Number | REQUIRED | Tank level at this time |
| `temperature` | Number | REQUIRED | Temperature at this time |
| `batteryLevel` | Number | REQUIRED | Battery level at this time |
| `status` | String | REQUIRED | Tank status at this time |
| `alert` | String | REQUIRED | Alert level at this time |
| `timestamp` | Date | REQUIRED, INDEXED | Reading timestamp |

**Relationships:**
- Many-to-One with TANK (Multiple history records per tank)
- Many-to-One with USER (Multiple history records per user)

**Business Rules:**
- Created automatically on every tank update
- Used for historical charts and trend analysis
- Retention policy: Keep 90 days of data (configurable)
- Indexed by timestamp for fast time-series queries
- Can be aggregated for daily/weekly/monthly reports

---

## Relationship Details

### 1. USER ↔ TANK (One-to-Many)

```
USER (1) ──────────< (N) TANK

One user can own/manage multiple tanks
Each tank belongs to exactly one user

Implementation:
- Tank.userId references User._id
- No cascading delete (preserve data for audit)
- Query: db.tanks.find({ userId: user._id })
```

**Cardinality:** 1:N (One-to-Many)

**Relationship Type:** Ownership

**Actions:**
- When user registers → Can add tanks
- When tank created → Must specify userId
- When user deletes account → Soft delete (set isActive: false), keep tank data

---

### 2. USER ↔ ALERT (One-to-Many)

```
USER (1) ──────────< (N) ALERT

One user can have multiple alerts
Each alert belongs to exactly one user

Implementation:
- Alert.userId references User._id
- Cascade delete on user removal
- Query: db.alerts.find({ userId: user._id, isRead: false })
```

**Cardinality:** 1:N (One-to-Many)

**Relationship Type:** Notification

**Actions:**
- When alert generated → Set userId from tank owner
- When user views alerts → Filter by userId
- When user deletes account → Delete all alerts

---

### 3. USER ↔ MAINTENANCE (One-to-Many)

```
USER (1) ──────────< (N) MAINTENANCE

One user can schedule multiple maintenance tasks
Each maintenance record belongs to one user

Implementation:
- Maintenance.userId references User._id
- No cascading delete (audit trail)
- Query: db.maintenance.find({ userId: user._id, status: "scheduled" })
```

**Cardinality:** 1:N (One-to-Many)

**Relationship Type:** Management

---

### 4. TANK ↔ TANK_HISTORY (One-to-Many)

```
TANK (1) ──────────< (N) TANK_HISTORY

One tank has multiple historical readings
Each history record belongs to one tank

Implementation:
- TankHistory.tankId references Tank._id
- Indexed for fast time-series queries
- Query: db.tank_history.find({ tankId: tank._id }).sort({ timestamp: -1 }).limit(100)
```

**Cardinality:** 1:N (One-to-Many)

**Relationship Type:** Historical Data

---

### 5. TANK ↔ ALERT (One-to-Many)

```
TANK (1) ──────────< (N) ALERT

One tank can generate multiple alerts
Each alert is related to one tank (via machineId)

Implementation:
- Alert.machineId matches Tank.machineId
- Not a strict foreign key (allows flexibility)
- Query: db.alerts.find({ machineId: tank.machineId })
```

**Cardinality:** 1:N (One-to-Many)

**Relationship Type:** Notification Generation

---

### 6. TANK ↔ MAINTENANCE (One-to-Many)

```
TANK (1) ──────────< (N) MAINTENANCE

One tank can have multiple maintenance records
Each maintenance record is for one tank

Implementation:
- Maintenance.machineId matches Tank.machineId
- Not a strict foreign key (flexible linking)
- Query: db.maintenance.find({ machineId: tank.machineId })
```

**Cardinality:** 1:N (One-to-Many)

**Relationship Type:** Service History

---

## Database Schema Details

### MongoDB Collections Overview

```
vegobolt_db (Database)
│
├── users               → User accounts and auth data
├── tanks               → Current tank status and sensors
├── alerts              → System alerts and notifications
├── maintenance         → Maintenance schedule and history
└── tank_history        → Historical sensor readings (time-series)
```

### Collection Sizes (Estimated)

| Collection | Avg Doc Size | Growth Rate | Index Size |
|------------|--------------|-------------|------------|
| users | 500 bytes | Low (user signups) | ~1KB per 100 users |
| tanks | 300 bytes | Medium (active tanks) | ~1KB per 100 tanks |
| alerts | 400 bytes | High (auto-generated) | ~2KB per 100 alerts |
| maintenance | 350 bytes | Medium (scheduled tasks) | ~1KB per 100 records |
| tank_history | 200 bytes | Very High (every update) | ~5KB per 1000 readings |

---

## Indexes and Constraints

### USER Collection Indexes

```javascript
// Primary Key
_id: ObjectId (default unique index)

// Unique Indexes
db.users.createIndex({ email: 1 }, { unique: true })
db.users.createIndex({ googleId: 1 }, { unique: true, sparse: true })

// Query Optimization Indexes
db.users.createIndex({ isEmailVerified: 1 })
db.users.createIndex({ emailVerificationToken: 1 }, { sparse: true })
db.users.createIndex({ passwordResetToken: 1 }, { sparse: true })
```

### TANK Collection Indexes

```javascript
// Primary Key
_id: ObjectId (default)

// Foreign Key Index
db.tanks.createIndex({ userId: 1 })

// Query Optimization Indexes
db.tanks.createIndex({ machineId: 1 })
db.tanks.createIndex({ status: 1 })
db.tanks.createIndex({ alert: 1 })
db.tanks.createIndex({ lastUpdated: -1 })

// Compound Indexes
db.tanks.createIndex({ userId: 1, machineId: 1 }, { unique: true })
```

### ALERT Collection Indexes

```javascript
// Primary Key
_id: ObjectId (default)

// Foreign Key Index
db.alerts.createIndex({ userId: 1 })

// Query Optimization Indexes
db.alerts.createIndex({ machineId: 1 })
db.alerts.createIndex({ isRead: 1 })
db.alerts.createIndex({ severity: 1 })
db.alerts.createIndex({ createdAt: -1 })

// Compound Indexes
db.alerts.createIndex({ userId: 1, isRead: 1, createdAt: -1 })
```

### MAINTENANCE Collection Indexes

```javascript
// Primary Key
_id: ObjectId (default)

// Foreign Key Index
db.maintenance.createIndex({ userId: 1 })

// Query Optimization Indexes
db.maintenance.createIndex({ machineId: 1 })
db.maintenance.createIndex({ status: 1 })
db.maintenance.createIndex({ scheduledDate: 1 })

// Compound Indexes
db.maintenance.createIndex({ userId: 1, status: 1, scheduledDate: 1 })
```

### TANK_HISTORY Collection Indexes

```javascript
// Primary Key
_id: ObjectId (default)

// Foreign Key Indexes
db.tank_history.createIndex({ tankId: 1 })
db.tank_history.createIndex({ userId: 1 })

// Time-Series Optimization
db.tank_history.createIndex({ timestamp: -1 })

// Compound Indexes for Range Queries
db.tank_history.createIndex({ tankId: 1, timestamp: -1 })
db.tank_history.createIndex({ userId: 1, timestamp: -1 })

// TTL Index (Auto-delete old records)
db.tank_history.createIndex({ timestamp: 1 }, { expireAfterSeconds: 7776000 }) // 90 days
```

---

## Data Types and Validations

### MongoDB Schema Validations

#### USER Schema Validation

```javascript
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "password", "firstName", "lastName"],
      properties: {
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
          description: "Must be a valid email address"
        },
        password: {
          bsonType: "string",
          minLength: 60,
          maxLength: 60,
          description: "Must be bcrypt hashed password (60 chars)"
        },
        firstName: {
          bsonType: "string",
          minLength: 1,
          maxLength: 50
        },
        lastName: {
          bsonType: "string",
          minLength: 1,
          maxLength: 50
        },
        phoneNumber: {
          bsonType: ["string", "null"],
          pattern: "^\\+?[0-9]{10,15}$"
        },
        isEmailVerified: {
          bsonType: "bool"
        }
      }
    }
  }
})
```

#### TANK Schema Validation

```javascript
db.createCollection("tanks", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "machineId", "status", "level"],
      properties: {
        userId: {
          bsonType: "objectId"
        },
        machineId: {
          bsonType: "string",
          minLength: 1
        },
        status: {
          enum: ["Full", "Low", "Normal", "Critical"]
        },
        level: {
          bsonType: "number",
          minimum: 0,
          maximum: 100
        },
        temperature: {
          bsonType: "number",
          minimum: -50,
          maximum: 100
        },
        batteryLevel: {
          bsonType: "number",
          minimum: 0,
          maximum: 100
        },
        alert: {
          enum: ["normal", "overheating", "critical", "warning"]
        }
      }
    }
  }
})
```

#### ALERT Schema Validation

```javascript
db.createCollection("alerts", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "type", "severity", "message"],
      properties: {
        userId: {
          bsonType: "objectId"
        },
        type: {
          enum: ["tank_level", "battery_low", "temperature", "maintenance", "system"]
        },
        severity: {
          enum: ["info", "warning", "critical", "emergency"]
        },
        priority: {
          enum: ["low", "medium", "high", "urgent"]
        },
        isRead: {
          bsonType: "bool"
        }
      }
    }
  }
})
```

#### MAINTENANCE Schema Validation

```javascript
db.createCollection("maintenance", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "machineId", "type", "scheduledDate"],
      properties: {
        userId: {
          bsonType: "objectId"
        },
        type: {
          enum: ["cleaning", "inspection", "repair", "replacement", "calibration"]
        },
        status: {
          enum: ["scheduled", "in_progress", "completed", "cancelled"]
        },
        scheduledDate: {
          bsonType: "date"
        },
        cost: {
          bsonType: ["number", "null"],
          minimum: 0
        }
      }
    }
  }
})
```

---

## Referential Integrity

### Foreign Key Constraints (Application-Level)

Since MongoDB doesn't enforce foreign key constraints at the database level, these must be enforced in the application layer:

```javascript
// Before creating a tank
const user = await User.findById(userId);
if (!user) {
  throw new Error('User not found');
}

// Before creating an alert
const tank = await Tank.findOne({ machineId: machineId });
if (!tank) {
  throw new Error('Tank not found');
}

// Before deleting a user
await Tank.updateMany({ userId: userId }, { isActive: false }); // Soft delete
await Alert.deleteMany({ userId: userId }); // Hard delete
await Maintenance.updateMany({ userId: userId }, { status: 'cancelled' });
```

---

## Data Integrity Rules

### Business Logic Constraints

1. **User Registration:**
   - Email must be unique
   - Password must be hashed with bcrypt (never store plain text)
   - Email verification required for full access
   - Google OAuth users auto-verified

2. **Tank Updates:**
   - Level must be 0-100
   - Temperature must be -50 to 100°C
   - Battery level must be 0-100
   - Create alert if level >= 90%
   - Create alert if battery < 20%
   - Create alert if temperature > 40°C

3. **Alert Generation:**
   - Auto-create on threshold violations
   - Cannot create duplicate alerts (same type + machine + 5 min window)
   - Severity determines UI display
   - Unread count shown in navbar badge

4. **Maintenance Scheduling:**
   - Cannot schedule in the past
   - Status progression: scheduled → in_progress → completed
   - Cannot modify completed maintenance
   - Alert created 3 days before due date

5. **Data Retention:**
   - Tank history: 90 days (configurable)
   - Alerts: 30 days after resolved
   - Maintenance: Indefinite (audit trail)
   - User accounts: Soft delete (preserve data integrity)

---

## Query Examples

### Common Queries

```javascript
// 1. Get user with all their tanks
db.users.aggregate([
  { $match: { _id: userId } },
  { $lookup: {
      from: "tanks",
      localField: "_id",
      foreignField: "userId",
      as: "tanks"
  }}
])

// 2. Get unread alerts for a user
db.alerts.find({
  userId: userId,
  isRead: false
}).sort({ createdAt: -1 })

// 3. Get tank history for last 7 days
db.tank_history.find({
  tankId: tankId,
  timestamp: {
    $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
  }
}).sort({ timestamp: -1 })

// 4. Get upcoming maintenance
db.maintenance.find({
  userId: userId,
  status: "scheduled",
  scheduledDate: { $gte: new Date() }
}).sort({ scheduledDate: 1 })

// 5. Get critical alerts
db.alerts.find({
  userId: userId,
  severity: { $in: ["critical", "emergency"] },
  resolvedAt: null
})

// 6. Tank with latest reading
db.tanks.aggregate([
  { $match: { userId: userId } },
  { $lookup: {
      from: "tank_history",
      let: { tankId: "$_id" },
      pipeline: [
        { $match: { $expr: { $eq: ["$tankId", "$$tankId"] } } },
        { $sort: { timestamp: -1 } },
        { $limit: 1 }
      ],
      as: "latestReading"
  }}
])
```

---

## ERD Summary Statistics

### Entity Count
- **Core Entities:** 5 (User, Tank, Alert, Maintenance, TankHistory)
- **External Entities:** 3 (ESP32, Google OAuth, Email Service)

### Relationship Count
- **Total Relationships:** 6
- **One-to-Many:** 6
- **Many-to-Many:** 0

### Attribute Count
| Entity | Attributes |
|--------|-----------|
| User | 17 |
| Tank | 12 |
| Alert | 11 |
| Maintenance | 11 |
| TankHistory | 8 |
| **Total** | **59** |

### Index Count
- **User Collection:** 5 indexes
- **Tank Collection:** 7 indexes
- **Alert Collection:** 7 indexes
- **Maintenance Collection:** 6 indexes
- **TankHistory Collection:** 6 indexes
- **Total:** 31 indexes

---

## Database Design Best Practices Applied

✅ **Normalization:** Entities are properly normalized to avoid redundancy
✅ **Indexing:** Strategic indexes on frequently queried fields
✅ **Referential Integrity:** Application-level enforcement of foreign keys
✅ **Data Validation:** Schema validation rules at database level
✅ **Timestamps:** All entities have createdAt/updatedAt for audit trails
✅ **Soft Deletes:** Users soft-deleted to preserve data integrity
✅ **TTL Indexes:** Auto-cleanup of old historical data
✅ **Compound Indexes:** Optimized for common query patterns
✅ **Enum Constraints:** Status and type fields restricted to valid values
✅ **Data Types:** Appropriate types chosen (ObjectId for IDs, Date for timestamps)

---

## Migration and Evolution Strategy

### Version 1 (Current)
- Basic entities: User, Tank, Alert, Maintenance
- Simple relationships
- Core functionality

### Future Enhancements (Potential)

**Version 2:**
- Add MACHINE entity (separate from TANK)
- Add ORGANIZATION entity (multi-tenant support)
- Add ROLE entity (role-based access control)
- Add NOTIFICATION_PREFERENCES entity

**Version 3:**
- Add ANALYTICS entity (dashboard metrics)
- Add REPORT entity (scheduled reports)
- Add SUBSCRIPTION entity (payment plans)
- Add AUDIT_LOG entity (compliance tracking)

---

*Generated: October 21, 2025*
*Version: 1.0*
*Database: MongoDB*
*System: Vegobolt IoT Tank Monitoring Platform*
