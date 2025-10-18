# Vegobolt Backend API Documentation

## Base URL
```
http://localhost:3000
```

## Authentication Endpoints

### 1. Register User
Creates a new user account in both Firebase and MongoDB.

**Endpoint:** `POST /api/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "displayName": "John Doe"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "mongodb_user_id",
      "email": "user@example.com",
      "displayName": "John Doe",
      "firebaseUid": "firebase_uid",
      "createdAt": "2025-10-17T10:30:00.000Z"
    },
    "token": "firebase_custom_token"
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "User already exists with this email"
}
```

---

### 2. Login
Authenticates a user and returns a custom token.

**Endpoint:** `POST /api/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "mongodb_user_id",
      "email": "user@example.com",
      "displayName": "John Doe",
      "firebaseUid": "firebase_uid"
    },
    "token": "firebase_custom_token"
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

---

### 3. Verify Token
Verifies a Firebase ID token.

**Endpoint:** `POST /api/auth/verify`

**Headers:**
```
Authorization: Bearer <firebase_id_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Token is valid",
  "data": {
    "user": {
      "id": "mongodb_user_id",
      "email": "user@example.com",
      "displayName": "John Doe",
      "firebaseUid": "firebase_uid"
    },
    "tokenInfo": {
      "uid": "firebase_uid",
      "email": "user@example.com"
    }
  }
}
```

**Error Response (403):**
```json
{
  "success": false,
  "message": "Invalid or expired token",
  "error": "Token verification failed"
}
```

---

### 4. Get Profile
Retrieves the current user's profile (requires authentication).

**Endpoint:** `GET /api/auth/profile`

**Headers:**
```
Authorization: Bearer <firebase_id_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "mongodb_user_id",
      "email": "user@example.com",
      "displayName": "John Doe",
      "firebaseUid": "firebase_uid",
      "createdAt": "2025-10-17T10:30:00.000Z"
    }
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "No token provided"
}
```

---

### 5. Logout
Logs out the current user (client-side token invalidation).

**Endpoint:** `POST /api/auth/logout`

**Headers:**
```
Authorization: Bearer <firebase_id_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logout successful. Please remove the token from client storage."
}
```

---

### 6. Request Password Reset
Sends a password reset link to the user's email.

**Endpoint:** `POST /api/auth/password-reset`

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Password reset link generated",
  "data": {
    "resetLink": "https://firebase-reset-link.com/..."
  }
}
```

**Note:** In production, the reset link should be sent via email, not returned in the response.

---

## Health Check

### Check Server Status
**Endpoint:** `GET /health`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2025-10-17T10:30:00.000Z"
}
```

---

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "success": false,
  "message": "Please provide email, password, and display name"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "No token provided"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Invalid or expired token"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "User not found"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Error registering user",
  "error": "Detailed error message"
}
```

---

## Authentication Flow

### For Mobile App (Flutter/React Native):

1. **Registration:**
   - Call `POST /api/auth/register` with user details
   - Receive custom token
   - Use Firebase SDK to sign in with custom token
   - Store the ID token for subsequent requests

2. **Login:**
   - Call `POST /api/auth/login` with credentials
   - Receive custom token
   - Use Firebase SDK to sign in with custom token
   - Store the ID token for subsequent requests

3. **Making Authenticated Requests:**
   - Include the Firebase ID token in the Authorization header
   - Format: `Authorization: Bearer <id_token>`

4. **Token Refresh:**
   - Firebase SDK automatically handles token refresh
   - Tokens expire after 1 hour

### Testing with Postman/cURL:

```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "displayName": "Test User"
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Get Profile (requires token)
curl -X GET http://localhost:3000/api/auth/profile \
  -H "Authorization: Bearer YOUR_FIREBASE_ID_TOKEN"
```

---

## Environment Variables

Make sure your `.env` file contains:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account@your-project.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/...

# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/vegobolt

# Server Configuration
PORT=3000
NODE_ENV=development
```

---

## Notes

- All timestamps are in ISO 8601 format (UTC)
- Passwords are hashed using bcrypt before storage
- Firebase handles token generation and verification
- MongoDB stores user profile data
- Password field is excluded from all JSON responses
