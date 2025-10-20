/**
 * Entry point for the Vercel Serverless Function or local server
 * Imports the Express app from src/app.js
 */

const app = require('./src/app');
const connectDB = require('./src/config/mongodb');

// ✅ Initialize MongoDB connection for serverless
// This ensures the connection is established before handling requests
if (process.env.NODE_ENV === 'production') {
    connectDB().catch(err => {
        console.error('❌ Failed to connect to MongoDB on startup:', err);
    });
}

// ✅ For Vercel deployment — export the app
module.exports = app;

// ✅ Optional: Local development support
if (process.env.NODE_ENV !== 'production') {
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`🚀 Local server running at http://localhost:${PORT}`);
        console.log(`📍 Health check: http://localhost:${PORT}/health`);
        console.log(`📱 ESP32 API: http://localhost:${PORT}/api/tank`);
    });
}
