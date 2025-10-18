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

// CORS middleware (optional, uncomment if needed)
// const cors = require('cors');
// app.use(cors());

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

// Connect to MongoDB
connectDB();

// Start the server
const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, 'localhost', () => {
    console.log(`🚀 Server is running on port ${PORT}`);
    console.log(`📍 Health check: http://localhost:${PORT}/health`);
    console.log(`🔐 Auth endpoints: http://localhost:${PORT}/api/auth`);
});

server.on('error', (error) => {
    console.error('❌ Server error:', error);
});