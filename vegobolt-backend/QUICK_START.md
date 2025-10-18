# Vegobolt Backend - Quick Start Guide

## Prerequisites

Before running the backend, ensure you have:

1. ✅ **Node.js** installed (v14 or higher)
2. ✅ **MongoDB** installed and running
3. ✅ **Firebase project** set up with Admin SDK credentials

## Installation

```bash
# Install dependencies
npm install
```

## Configuration

Your `.env` file is already configured with Firebase and MongoDB settings.

## Starting MongoDB

### Windows:
```powershell
# If MongoDB is installed as a service:
net start MongoDB

# Or run manually:
"C:\Program Files\MongoDB\Server\<version>\bin\mongod.exe" --dbpath "C:\data\db"
```

### macOS:
```bash
brew services start mongodb-community
```

### Linux:
```bash
sudo systemctl start mongod
```

## Running the Server

### Development Mode (with auto-restart):
```bash
npm run dev
```

### Production Mode:
```bash
npm start
```

The server will start on `http://localhost:3000`

## Testing the API

### 1. Check Server Health
```bash
curl http://localhost:3000/health
```

### 2. Register a User
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "displayName": "Test User"
  }'
```

### 3. Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

## Testing with Postman

1. Import the endpoints from `API_DOCUMENTATION.md`
2. Create a collection for "Vegobolt API"
3. Test each endpoint following the documentation

## Project Structure

```
vegobolt-backend/
├── src/
│   ├── app.js              # Main application file
│   ├── config/
│   │   ├── firebase.js     # Firebase Admin SDK config
│   │   └── mongodb.js      # MongoDB connection
│   ├── controllers/
│   │   ├── authController.js   # Authentication logic
│   │   └── userController.js
│   ├── middleware/
│   │   └── authMiddleware.js   # Token verification
│   ├── models/
│   │   └── User.js         # User schema
│   ├── routes/
│   │   ├── authRoutes.js   # Auth endpoints
│   │   └── userRoutes.js
│   ├── services/
│   │   ├── firebaseService.js  # Firebase helpers
│   │   └── mongoService.js
│   └── utils/
│       └── errorHandler.js
├── .env                    # Environment variables
├── .env.example            # Example env file
├── package.json
├── API_DOCUMENTATION.md    # Complete API docs
└── README.md
```

## Available Endpoints

- `GET /health` - Server health check
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `POST /api/auth/verify` - Verify token
- `GET /api/auth/profile` - Get user profile (protected)
- `POST /api/auth/logout` - Logout (protected)
- `POST /api/auth/password-reset` - Request password reset

## Troubleshooting

### MongoDB Connection Issues
```
Error: connect ECONNREFUSED 127.0.0.1:27017
```
**Solution:** Make sure MongoDB is running. Start it using the commands above.

### Firebase Configuration Issues
```
Error: Service account object must contain a string "project_id" property
```
**Solution:** Check your `.env` file has all required Firebase variables.

### Port Already in Use
```
Error: listen EADDRINUSE: address already in use :::3000
```
**Solution:** Change the PORT in `.env` or kill the process using port 3000.

## Next Steps

1. ✅ Test all authentication endpoints
2. ⏳ Integrate with mobile app
3. ⏳ Add more features (orders, products, etc.)
4. ⏳ Set up production deployment

## Support

For issues or questions, check:
- `API_DOCUMENTATION.md` for endpoint details
- Firebase Console for authentication logs
- MongoDB logs for database issues
