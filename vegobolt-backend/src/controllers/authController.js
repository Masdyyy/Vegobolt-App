const bcrypt = require('bcryptjs');
const User = require('../models/User');
const { generateToken, verifyToken: verifyJWT } = require('../services/jwtService');

/**
 * Register a new user with email and password
 * Creates user in MongoDB and returns JWT token
 */
const register = async (req, res, next) => {
    console.log('🔵 Registration request received:', req.body);
    try {
        const { email, password, displayName } = req.body;
        console.log('🔵 Parsed data:', { email, displayName, hasPassword: !!password });

        // Validate input
        if (!email || !password || !displayName) {
            return res.status(400).json({
                success: false,
                message: 'Please provide email, password, and display name'
            });
        }

        // Validate password strength
        if (password.length < 6) {
            return res.status(400).json({
                success: false,
                message: 'Password must be at least 6 characters long'
            });
        }

        // Check if user already exists in MongoDB
        const existingUser = await User.findByEmail(email);
        if (existingUser) {
            return res.status(400).json({
                success: false,
                message: 'User already exists with this email'
            });
        }

        // Hash password for MongoDB
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Create user in MongoDB
        const mongoUser = await User.createUser({
            email,
            password: hashedPassword,
            displayName
        });

        // Generate JWT token
        const token = generateToken(mongoUser);

        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            data: {
                user: {
                    id: mongoUser._id,
                    email: mongoUser.email,
                    displayName: mongoUser.displayName,
                    createdAt: mongoUser.createdAt
                },
                token: token
            }
        });

    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({
            success: false,
            message: 'Error registering user',
            error: error.message
        });
    }
};

/**
 * Login user with email and password
 * Verifies credentials and returns JWT token
 */
const login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validate input
        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Please provide email and password'
            });
        }

        // Find user in MongoDB
        const user = await User.findByEmail(email);
        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        // Check if user is active
        if (!user.isActive) {
            return res.status(401).json({
                success: false,
                message: 'Account is inactive. Please contact support.'
            });
        }

        // Verify password
        const isPasswordValid = await bcrypt.compare(password, user.password);
        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                message: 'Invalid email or password'
            });
        }

        // Generate JWT token
        const token = generateToken(user);

        res.status(200).json({
            success: true,
            message: 'Login successful',
            data: {
                user: {
                    id: user._id,
                    email: user.email,
                    displayName: user.displayName
                },
                token: token
            }
        });

    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            success: false,
            message: 'Error logging in',
            error: error.message
        });
    }
};

/**
 * Verify JWT token
 * Used for validating tokens from mobile clients
 */
const verifyToken = async (req, res) => {
    try {
        const token = req.headers.authorization?.split(' ')[1];

        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'No token provided'
            });
        }

        // Verify the JWT token
        const decodedToken = await verifyJWT(token);

        // Find user in MongoDB
        const user = await User.findById(decodedToken.id);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Token is valid',
            data: {
                user: {
                    id: user._id,
                    email: user.email,
                    displayName: user.displayName
                },
                tokenInfo: {
                    id: decodedToken.id,
                    email: decodedToken.email,
                    expiresAt: new Date(decodedToken.exp * 1000)
                }
            }
        });

    } catch (error) {
        console.error('Token verification error:', error);
        res.status(403).json({
            success: false,
            message: 'Invalid or expired token',
            error: error.message
        });
    }
};

/**
 * Get current user profile
 * Requires valid JWT token
 */
const getProfile = async (req, res) => {
    try {
        // req.user is set by authMiddleware
        const user = await User.findById(req.user.id);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.status(200).json({
            success: true,
            data: {
                user: {
                    id: user._id,
                    email: user.email,
                    displayName: user.displayName,
                    phoneNumber: user.phoneNumber,
                    profilePicture: user.profilePicture,
                    createdAt: user.createdAt
                }
            }
        });

    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching user profile',
            error: error.message
        });
    }
};

/**
 * Logout user (client-side token invalidation)
 */
const logout = async (req, res) => {
    try {
        // JWT tokens are stateless, so logout is handled client-side
        // This endpoint is for consistency and can be used for logging/analytics
        
        res.status(200).json({
            success: true,
            message: 'Logout successful. Please remove the token from client storage.'
        });

    } catch (error) {
        console.error('Logout error:', error);
        res.status(500).json({
            success: false,
            message: 'Error during logout',
            error: error.message
        });
    }
};

/**
 * Request password reset
 * TODO: Implement with email service (e.g., SendGrid, Nodemailer)
 */
const requestPasswordReset = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'Please provide email'
            });
        }

        // Check if user exists
        const user = await User.findByEmail(email);
        if (!user) {
            // Don't reveal if user exists or not for security
            return res.status(200).json({
                success: true,
                message: 'If the email exists, a password reset link will be sent'
            });
        }

        // TODO: Generate password reset token and send email
        // For now, return a placeholder message
        
        res.status(200).json({
            success: true,
            message: 'Password reset functionality will be implemented with email service'
        });

    } catch (error) {
        console.error('Password reset error:', error);
        res.status(500).json({
            success: false,
            message: 'Error requesting password reset',
            error: error.message
        });
    }
};

module.exports = {
    register,
    login,
    verifyToken,
    getProfile,
    logout,
    requestPasswordReset
};