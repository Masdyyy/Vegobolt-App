/**
 * Entry point for Vercel Serverless Function
 * This file wraps the Express app to work with Vercel's serverless environment
 */

require('dotenv').config();
const app = require('./src/app');
const connectDB = require('./src/config/mongodb');
const mqttService = require('./src/services/mqttService');

// Initialize MongoDB connection (cached for serverless)
let isConnected = false;

async function connectToDatabase() {
    if (isConnected) {
        console.log('Using existing MongoDB connection');
        return;
    }
    
    try {
        await connectDB();
        isConnected = true;
    } catch (error) {
        console.error('MongoDB connection error:', error);
        // Don't throw - let the request proceed and fail gracefully
    }
}

// Vercel serverless function handler
module.exports = async (req, res) => {
    // Ensure MongoDB is connected before handling request
    await connectToDatabase();
    
    // Let Express handle the request
    return app(req, res);
};

// Local development server
if (require.main === module) {
    const PORT = process.env.PORT || 3000;
    
    connectDB().then(() => {
        // Connect to MQTT broker
        mqttService.connect();
        
        app.listen(PORT, '0.0.0.0', () => {
            console.log(`🚀 Local server running at http://localhost:${PORT}`);
            console.log(`📍 Health check: http://localhost:${PORT}/health`);
            console.log(`🔐 Auth endpoints: http://localhost:${PORT}/api/auth`);
            console.log(`📱 ESP32 API: http://localhost:${PORT}/api/tank`);
            console.log(`🚨 Alerts API: http://localhost:${PORT}/api/alerts`);
        });
    }).catch(err => {
        console.error('Failed to start server:', err);
        process.exit(1);
    });
}
