/**
 * Entry point for Vercel Serverless Function
 * This file wraps the Express app to work with Vercel's serverless environment
 */

require('dotenv').config();
const app = require('./src/app');
const connectDB = require('./src/config/mongodb');
const mqttService = require('./src/services/mqttService');
const tapoService = require('./src/services/tapoService');
const { getLocalIpAddress, getBackendUrl } = require('./src/utils/networkUtils');

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
        
        // Connect to Tapo smart plug
        tapoService.connect().catch(err => {
            console.warn('⚠️ Tapo connection failed (will retry on command):', err.message);
        });
        
        const localIp = getLocalIpAddress();
        const backendUrl = getBackendUrl(PORT);
        
        app.listen(PORT, '0.0.0.0', () => {
            console.log(`\n📡 Network Information:`);
            console.log(`   Local IP: ${localIp}`);
            console.log(`   Backend URL: ${backendUrl}`);
            console.log(`\n🚀 Server Endpoints:`);
            console.log(`   Local: http://localhost:${PORT}`);
            console.log(`   Network: http://${localIp}:${PORT}`);
            console.log(`\n📍 API Endpoints:`);
            console.log(`   Health: http://${localIp}:${PORT}/health`);
            console.log(`   Auth: http://${localIp}:${PORT}/api/auth`);
            console.log(`   ESP32: http://${localIp}:${PORT}/api/tank`);
            console.log(`   Alerts: http://${localIp}:${PORT}/api/alerts`);
            console.log(`   Pump: http://${localIp}:${PORT}/api/pump`);
        });
    }).catch(err => {
        console.error('Failed to start server:', err);
        process.exit(1);
    });
}
