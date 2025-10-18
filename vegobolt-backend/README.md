# Vegobolt Backend

## Overview
The Vegobolt Backend is a Node.js application that provides authentication and user management functionalities using Firebase for login and MongoDB for data storage. This project serves as the backend for the Vegobolt mobile application.

## Features
- User authentication using Firebase
- User data management with MongoDB
- RESTful API for user-related operations
- Middleware for authentication and error handling

## Project Structure
```
vegobolt-backend
├── src
│   ├── config
│   │   ├── firebase.js
│   │   └── mongodb.js
│   ├── controllers
│   │   ├── authController.js
│   │   └── userController.js
│   ├── middleware
│   │   └── authMiddleware.js
│   ├── models
│   │   └── User.js
│   ├── routes
│   │   ├── authRoutes.js
│   │   └── userRoutes.js
│   ├── services
│   │   ├── firebaseService.js
│   │   └── mongoService.js
│   ├── utils
│   │   └── errorHandler.js
│   └── app.js
├── .env.example
├── .gitignore
├── package.json
└── README.md
```

## Installation
1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd vegobolt-backend
   ```
3. Install the dependencies:
   ```
   npm install
   ```

## Configuration
- Create a `.env` file in the root directory and copy the contents from `.env.example`. Update the values with your Firebase and MongoDB credentials.

## Usage
To start the application, run:
```
npm start
```

The server will start on the specified port, and you can access the API endpoints for authentication and user management.

## API Endpoints
- **Authentication**
  - `POST /api/auth/login`: Login a user
  - `POST /api/auth/register`: Register a new user

- **User Management**
  - `GET /api/users/:id`: Get user profile
  - `PUT /api/users/:id`: Update user information

## Contributing
Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License
This project is licensed under the MIT License.