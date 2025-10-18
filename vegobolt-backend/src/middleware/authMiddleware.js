const { verifyToken } = require('../services/jwtService');
const User = require('../models/User');

/**
 * Middleware to authenticate JWT token
 * Verifies token and attaches user info to request object
 */
const authenticateToken = async (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader?.split(' ')[1]; // Format: "Bearer TOKEN"

    if (!token) {
        return res.status(401).json({ 
            success: false,
            message: 'Access denied. No token provided.' 
        });
    }

    try {
        // Verify JWT token
        const decoded = await verifyToken(token);
        
        // Optionally verify user still exists and is active
        const user = await User.findById(decoded.id);
        if (!user) {
            return res.status(404).json({ 
                success: false,
                message: 'User not found' 
            });
        }

        if (!user.isActive) {
            return res.status(403).json({ 
                success: false,
                message: 'Account is inactive' 
            });
        }

        // Attach user info to request
        req.user = {
            id: decoded.id,
            email: decoded.email,
            displayName: decoded.displayName
        };
        
        next();
    } catch (error) {
        console.error('Authentication error:', error.message);
        return res.status(403).json({ 
            success: false,
            message: error.message || 'Invalid or expired token' 
        });
    }
};

module.exports = {
    authenticateToken,
};