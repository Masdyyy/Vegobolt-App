/**
 * Entry point for the Vercel Serverless Function or local server
 * Imports the Express app from src/app.js
 */

const app = require('./src/app');
const connectDB = require('./src/config/mongodb');

// ✅ For Vercel serverless - connect to MongoDB on cold start
connectDB().catch(err => {
    console.error('Failed to connect to MongoDB:', err);
});

// ✅ Export the app as serverless function handler
module.exports = app;

// ✅ Local development support
if (require.main === module) {
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, '0.0.0.0', () => {
        console.log(`🚀 Local server running at http://localhost:${PORT}`);
        console.log(`📍 Health check: http://localhost:${PORT}/health`);
        console.log(`🔐 Auth endpoints: http://localhost:${PORT}/api/auth`);
        console.log(`📱 ESP32 API: http://localhost:${PORT}/api/tank`);
        console.log(`🚨 Alerts API: http://localhost:${PORT}/api/alerts`);
    });
}
