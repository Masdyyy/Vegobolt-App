# Backend Integration Setup Guide

## Overview
This guide explains how the Flutter app integrates with the Node.js backend for authentication.

## Architecture

### Backend (Node.js + Express + MongoDB)
- **Location**: `vegobolt-backend/`
- **Database**: MongoDB Atlas (Cloud)
- **Authentication**: JWT (JSON Web Tokens)
- **Port**: 3000

### Frontend (Flutter)
- **Location**: `vegobolt/`
- **HTTP Client**: `http` package
- **Secure Storage**: `flutter_secure_storage` for JWT tokens
- **API Service**: `lib/services/auth_service.dart`

## Files Created/Modified

### New Files Created:
1. **`lib/utils/api_config.dart`**
   - Contains backend API base URL and endpoints
   - Update the `baseUrl` based on your testing environment:
     - Android Emulator: `http://10.0.2.2:3000`
     - iOS Simulator: `http://localhost:3000`
     - Physical Device: `http://YOUR_LOCAL_IP:3000`

2. **`lib/services/auth_service.dart`**
   - Handles all authentication API calls
   - Methods:
     - `login(email, password)` - Login user
     - `register(email, password, displayName)` - Register new user
     - `getProfile()` - Get user profile
     - `logout()` - Logout user
     - `isLoggedIn()` - Check authentication status
     - `getToken()` - Get stored JWT token

### Modified Files:
1. **`lib/Pages/Login.dart`**
   - Removed local storage-based authentication
   - Now uses `AuthService` to call backend API
   - Stores JWT token securely on successful login

2. **`lib/Pages/Signup.dart`**
   - Removed local storage-based registration
   - Now uses `AuthService` to call backend API
   - Automatically logs in user after registration

3. **`pubspec.yaml`**
   - Added `http: ^1.1.0` package for HTTP requests

## Setup Instructions

### 1. Start the Backend Server

```powershell
cd vegobolt-backend
npm install  # If not already installed
node src/app.js
```

Or use the provided batch file:
```powershell
cd vegobolt-backend
.\start-server.bat
```

The server should start on `http://localhost:3000`

### 2. Install Flutter Dependencies

```powershell
cd vegobolt
flutter pub get
```

### 3. Configure API Endpoint

Edit `lib/utils/api_config.dart` and set the correct `baseUrl`:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

**For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:3000';
```

**For Physical Device:**
First, find your computer's local IP:
```powershell
ipconfig  # Look for IPv4 Address
```
Then update:
```dart
static const String baseUrl = 'http://192.168.1.XXX:3000';  // Replace XXX
```

### 4. Run the Flutter App

```powershell
cd vegobolt
flutter run
```

## API Flow

### Registration Flow:
1. User fills signup form
2. App calls `AuthService.register(email, password, displayName)`
3. Backend creates user in MongoDB with hashed password
4. Backend returns JWT token
5. App stores token in secure storage
6. User is redirected to dashboard

### Login Flow:
1. User fills login form
2. App calls `AuthService.login(email, password)`
3. Backend verifies credentials against MongoDB
4. Backend returns JWT token
5. App stores token in secure storage
6. User is redirected to dashboard

### Authenticated Requests:
For future API calls that require authentication:
```dart
final token = await AuthService().getToken();
final response = await http.get(
  url,
  headers: {
    'Authorization': 'Bearer $token',
  },
);
```

## Security Features

1. **Password Hashing**: Backend uses bcrypt to hash passwords
2. **JWT Tokens**: Secure token-based authentication
3. **Secure Storage**: Tokens stored using `flutter_secure_storage`
4. **HTTPS Ready**: Backend can be configured for HTTPS in production

## Testing

### Test Registration:
1. Open the app
2. Navigate to Signup
3. Fill in:
   - Name: Test User
   - Email: test@example.com
   - Password: Test123 (min 6 chars, 1 uppercase, 1 lowercase, 1 number)
4. Accept terms and submit

### Test Login:
1. Navigate to Login
2. Enter registered email and password
3. Click "Log in"

### Verify in Database:
```powershell
cd vegobolt-backend
node view-database.js
```

## Troubleshooting

### "Network error" in app:
- Ensure backend server is running
- Check the API URL in `api_config.dart`
- For physical device, ensure computer and device are on same WiFi
- Check firewall settings

### "Connection refused":
- Verify backend is running on port 3000
- For Android Emulator, use `10.0.2.2` instead of `localhost`
- For iOS Simulator, use `localhost` or `127.0.0.1`

### "Invalid email or password":
- Ensure user is registered in MongoDB
- Check password meets requirements (6+ chars, uppercase, lowercase, number)
- Use the same email case (backend converts to lowercase)

### Backend not starting:
- Check MongoDB connection string in `.env`
- Ensure MongoDB Atlas cluster is running
- Verify all npm packages are installed

## Next Steps

For email verification and password reset:
- Backend already has `/api/auth/password-reset` endpoint
- Will be implemented in future updates
- Email service (e.g., SendGrid, Nodemailer) needs to be configured

## Environment Variables

Backend `.env` file should contain:
```
MONGODB_URI=mongodb+srv://...
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d
PORT=3000
NODE_ENV=development
```

## API Documentation

See `vegobolt-backend/API_DOCUMENTATION.md` for complete API reference.
