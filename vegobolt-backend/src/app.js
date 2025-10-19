require('dotenv').config();
const express = require('express');
const connectDB = require('./config/mongodb');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const errorHandler = require('./utils/errorHandler');

const app = express();

// Middleware
app.use((req, res, next) => {
    console.log(`🟢 ${req.method} ${req.path}`);
    next();
});
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS middleware - Enable for mobile app and web access
const cors = require('cors');
app.use(cors({
    origin: '*', // Allow all origins (for development and production)
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true
}));

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({
        success: true,
        message: 'Server is running',
        timestamp: new Date().toISOString()
    });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Route not found'
    });
});

// Error handling middleware
app.use(errorHandler);

// Connect to MongoDB (initialize on startup)
// For serverless, connection will be cached and reused
if (process.env.NODE_ENV !== 'production') {
    connectDB();
}

// Start the server (only in development, not on Vercel)
if (process.env.NODE_ENV !== 'production') {
    const PORT = process.env.PORT || 3000;
    const server = app.listen(PORT, '0.0.0.0', () => {
        console.log(`🚀 Server is running on port ${PORT}`);
        console.log(`📍 Health check: http://localhost:${PORT}/health`);
        console.log(`🔐 Auth endpoints: http://localhost:${PORT}/api/auth`);
        console.log(`📱 Mobile access: http://10.0.2.2:${PORT} (Android Emulator)`);
    });

    server.on('error', (error) => {
        console.error('❌ Server error:', error);
    });
}

// Export for Vercel serverless
module.exports = app;