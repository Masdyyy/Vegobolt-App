/**
 * GET /api/config/backend-url
 * Returns the current backend URL for mobile app configuration
 */
const { getAutoBackendUrl } = require('../utils/networkUtils');

const getBackendUrl = (req, res) => {
    try {
        const PORT = process.env.PORT || 3000;
        const backendUrl = process.env.BACKEND_URL || getAutoBackendUrl(PORT);
        
        res.status(200).json({
            success: true,
            backendUrl: backendUrl,
            autoDetected: !process.env.BACKEND_URL
        });
    } catch (error) {
        console.error('Error getting backend URL:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get backend URL',
            error: error.message
        });
    }
};

module.exports = {
    getBackendUrl
};
