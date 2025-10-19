/**
 * Entry point for the Vercel Serverless Function or local server
 * Imports the Express app from src/app.js
 */

const app = require('./src/app');

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
