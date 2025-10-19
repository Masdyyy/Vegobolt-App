require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/mongodb');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const tankRoutes = require('./routes/tankRoutes');  // 👈 Added for ESP32 data
const alertRoutes = require('./routes/alertRoutes'); // 👈 Added alerts routes
const errorHandler = require('./utils/errorHandler');

const app = express();

// Middleware
app.use((req, res, next) => {
    console.log(`🟢 ${req.method} ${req.path}`);
    next();
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS setup
app.use(cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true
}));

// Health check
app.get('/health', (req, res) => {
    res.status(200).json({
        success: true,
        message: 'Server is running',
        timestamp: new Date().toISOString()
    });
});

// ✅ New ESP32 Tank Data Route
app.use('/api/tank', tankRoutes);

// Existing routes
app.use('/api/alerts', alertRoutes); // 👈 Wire up alerts route
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Route not found'
    });
});

// Error handler
app.use(errorHandler);

// MongoDB connect
if (process.env.NODE_ENV !== 'production') {
    connectDB();
}

// Local server start (for development)
if (process.env.NODE_ENV !== 'production') {
    const PORT = process.env.PORT || 3000;
    const server = app.listen(PORT, '0.0.0.0', () => {
        console.log(`🚀 Server is running on port ${PORT}`);
        console.log(`📍 Health check: http://localhost:${PORT}/health`);
        console.log(`🔐 Auth endpoints: http://localhost:${PORT}/api/auth`);
        console.log(`📱 ESP32 API: http://localhost:${PORT}/api/tank`);
        console.log(`🚨 Alerts API: http://localhost:${PORT}/api/alerts`);
    });

    server.on('error', (error) => {
        console.error('❌ Server error:', error);
    });
}

// Export for serverless (Vercel, etc.)
module.exports = app;