require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/mongodb');
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const tankRoutes = require('./routes/tankRoutes');  // 👈 Added for ESP32 data
const alertRoutes = require('./routes/alertRoutes'); // 👈 Added alerts routes
const maintenanceRoutes = require('./routes/maintenanceRoutes'); // maintenance endpoints
const configRoutes = require('./routes/configRoutes'); // configuration endpoints
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
// Maintenance endpoints
app.use('/api/maintenance', maintenanceRoutes);

// Existing routes
app.use('/api/alerts', alertRoutes); // 👈 Wire up alerts route
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/config', configRoutes); // 👈 Configuration endpoints

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Route not found'
    });
});

// Error handler
app.use(errorHandler);

// MongoDB connect - only for local development
// For serverless, connection happens per request
if (require.main === module) {
    connectDB().catch(err => {
        console.error('Failed to connect to MongoDB:', err);
    });
}

// Export for serverless (Vercel, etc.)
module.exports = app;