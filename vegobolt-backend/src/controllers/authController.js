const bcrypt = require('bcryptjs');
const User = require('../models/User');
const { generateToken, verifyToken: verifyJWT } = require('../services/jwtService');
const { generateVerificationToken, sendVerificationEmail } = require('../services/emailService');
const connectDB = require('../config/mongodb');
const { verifyGoogleIdToken } = require('../services/googleAuthService');

/**
 * Register a new user with email and password
 * Creates user in MongoDB and returns JWT token
 */
const register = async (req, res, next) => {
    console.log('🔵 Registration request received:', req.body);
    try {
        // Ensure MongoDB is connected (for serverless environments)
        await connectDB();
        
        const { email, password, firstName, lastName } = req.body;
        console.log('🔵 Parsed data:', { email, firstName, lastName, hasPassword: !!password });

        // Validate input
        if (!email || !password || !firstName || !lastName) {
            return res.status(400).json({
                success: false,
                message: 'Please provide email, password, first name, and last name'
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

        // Generate email verification token
        const verificationToken = generateVerificationToken();
        const verificationExpires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

        // Create user in MongoDB
        const mongoUser = await User.createUser({
            email,
            password: hashedPassword,
            firstName,
            lastName,
            emailVerificationToken: verificationToken,
            emailVerificationExpires: verificationExpires,
            isEmailVerified: false
        });

        // Send verification email
        try {
            await sendVerificationEmail(email, verificationToken, mongoUser.displayName);
            console.log('✅ Verification email sent successfully');
        } catch (emailError) {
            console.error('⚠️ Failed to send verification email:', emailError);
            // Continue with registration even if email fails
        }

        // Generate JWT token (but user still needs to verify email to login)
        const token = generateToken(mongoUser);

        res.status(201).json({
            success: true,
            message: 'User registered successfully. Please check your email to verify your account.',
            data: {
                user: {
                    id: mongoUser._id,
                    email: mongoUser.email,
                    firstName: mongoUser.firstName,
                    lastName: mongoUser.lastName,
                    displayName: mongoUser.displayName,
                    isEmailVerified: mongoUser.isEmailVerified,
                    createdAt: mongoUser.createdAt
                },
                token: token,
                requiresEmailVerification: true
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
        // Ensure MongoDB is connected (for serverless environments)
        await connectDB();
        
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

        // Check if email is verified
        if (!user.isEmailVerified) {
            return res.status(401).json({
                success: false,
                message: 'Please verify your email before logging in. Check your inbox for the verification link.',
                requiresEmailVerification: true
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
                    firstName: user.firstName,
                    lastName: user.lastName,
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
 * Login or register via Google ID token
 * Body: { idToken: string }
 */
const googleLogin = async (req, res) => {
    try {
        // Ensure MongoDB is connected (for serverless environments)
        await connectDB();

        const { idToken } = req.body;

        if (!idToken) {
            return res.status(400).json({
                success: false,
                message: 'Missing idToken'
            });
        }

        // Verify Google ID token and extract profile
        const payload = await verifyGoogleIdToken(idToken);
        const email = (payload.email || '').toLowerCase();
        const fullName = payload.name || email.split('@')[0];
        const picture = payload.picture || null;
        const emailVerified = !!payload.email_verified;

        // Parse first and last name from Google name
        const nameParts = fullName.split(' ');
        const firstName = payload.given_name || nameParts[0] || 'User';
        const lastName = payload.family_name || (nameParts.length > 1 ? nameParts.slice(1).join(' ') : '');

        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'No email found in Google token'
            });
        }

        // Find or create user
        let user = await User.findByEmail(email);
        if (!user) {
            user = await User.createUser({
                email,
                // store a non-usable password placeholder for social login
                password: `google:${payload.sub}`,
                firstName,
                lastName,
                profilePicture: picture,
                isEmailVerified: emailVerified,
                emailVerificationToken: null,
                emailVerificationExpires: null,
            });
        } else {
            // Update existing profile with Google info
            if (!user.firstName && firstName) user.firstName = firstName;
            if (!user.lastName && lastName) user.lastName = lastName;
            if (!user.displayName) user.displayName = `${firstName} ${lastName}`.trim();
            if (picture && !user.profilePicture) user.profilePicture = picture;
            if (emailVerified && !user.isEmailVerified) user.isEmailVerified = true;
            await user.save();
        }

        // Issue JWT
        const token = generateToken(user);

        return res.status(200).json({
            success: true,
            message: 'Login successful',
            data: {
                user: {
                    id: user._id,
                    email: user.email,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    displayName: user.displayName,
                    profilePicture: user.profilePicture,
                },
                token,
            },
        });
    } catch (error) {
        console.error('Google login error:', error);
        return res.status(500).json({
            success: false,
            message: 'Google login failed',
            error: error.message,
        });
    }
};

/**
 * Verify JWT token
 * Used for validating tokens from mobile clients
 */
const verifyToken = async (req, res) => {
    try {
        // Ensure MongoDB is connected (for serverless environments)
        await connectDB();
        
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
                    firstName: user.firstName,
                    lastName: user.lastName,
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
        // Ensure MongoDB is connected (for serverless environments)
        await connectDB();
        
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
                    firstName: user.firstName,
                    lastName: user.lastName,
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
 * Verify user email with token
 */
const verifyEmail = async (req, res) => {
    try {
        // Ensure MongoDB is connected (for serverless environments)
        await connectDB();
        
        const { token } = req.params;

        if (!token) {
            return res.status(400).json({
                success: false,
                message: 'Verification token is required'
            });
        }

        // Find user with this verification token
        const user = await User.findOne({
            emailVerificationToken: token,
            emailVerificationExpires: { $gt: Date.now() }
        });

        if (!user) {
            return res.status(400).send(`
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Verification Failed - Vegobolt</title>
                    <style>
                        * { margin: 0; padding: 0; box-sizing: border-box; }
                        body {
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
                            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                            display: flex;
                            justify-content: center;
                            align-items: center;
                            min-height: 100vh;
                            padding: 20px;
                        }
                        .container {
                            background: white;
                            padding: 40px;
                            border-radius: 20px;
                            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                            text-align: center;
                            max-width: 500px;
                        }
                        .error-icon {
                            width: 80px;
                            height: 80px;
                            background: #f44336;
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin: 0 auto 30px;
                            color: white;
                            font-size: 50px;
                            font-weight: bold;
                        }
                        h1 { color: #333; font-size: 28px; margin-bottom: 15px; }
                        p { color: #666; font-size: 16px; line-height: 1.6; margin-bottom: 20px; }
                        .instruction {
                            background: #fff3cd;
                            border-left: 4px solid #ffc107;
                            padding: 15px;
                            border-radius: 5px;
                            margin-top: 30px;
                            text-align: left;
                        }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="error-icon">!</div>
                        <h1>Verification Failed</h1>
                        <p>This verification link is invalid or has expired.</p>
                        <div class="instruction">
                            <p style="margin: 0;">
                                <strong>What to do:</strong><br>
                                1. Open the Vegobolt app<br>
                                2. Try to log in<br>
                                3. Request a new verification email
                            </p>
                        </div>
                    </div>
                </body>
                </html>
            `);
        }

        // Update user as verified
        user.isEmailVerified = true;
        user.emailVerificationToken = null;
        user.emailVerificationExpires = null;
        await user.save();

        // Return HTML success page for mobile users
        res.status(200).send(`
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Email Verified - Vegobolt</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        min-height: 100vh;
                        padding: 20px;
                    }
                    .container {
                        background: white;
                        padding: 40px;
                        border-radius: 20px;
                        box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                        text-align: center;
                        max-width: 500px;
                        animation: slideUp 0.5s ease-out;
                    }
                    @keyframes slideUp {
                        from {
                            opacity: 0;
                            transform: translateY(30px);
                        }
                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }
                    .success-icon {
                        width: 80px;
                        height: 80px;
                        background: #7AB93F;
                        border-radius: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        margin: 0 auto 30px;
                        animation: scaleIn 0.5s ease-out 0.2s both;
                    }
                    @keyframes scaleIn {
                        from {
                            transform: scale(0);
                        }
                        to {
                            transform: scale(1);
                        }
                    }
                    .checkmark {
                        width: 40px;
                        height: 40px;
                        border: 4px solid white;
                        border-top: none;
                        border-left: none;
                        transform: rotate(45deg);
                        margin-top: -10px;
                    }
                    h1 {
                        color: #333;
                        font-size: 28px;
                        margin-bottom: 15px;
                    }
                    p {
                        color: #666;
                        font-size: 16px;
                        line-height: 1.6;
                        margin-bottom: 20px;
                    }
                    .user-info {
                        background: #F5F5DC;
                        padding: 15px;
                        border-radius: 10px;
                        margin: 20px 0;
                    }
                    .user-info strong {
                        color: #5A6B47;
                    }
                    .instruction {
                        background: #F5F5DC;
                        border-left: 4px solid #7AB93F;
                        padding: 15px;
                        border-radius: 5px;
                        margin-top: 30px;
                        text-align: left;
                    }
                    .instruction strong {
                        color: #5A6B47;
                        display: block;
                        margin-bottom: 10px;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="success-icon">
                        <div class="checkmark"></div>
                    </div>
                    <h1>Email Verified!</h1>
                    <p>Your email address has been successfully verified.</p>
                    
                    <div class="user-info">
                        <p><strong>${user.displayName}</strong></p>
                        <p style="font-size: 14px; color: #888;">${user.email}</p>
                    </div>
                    
                    <div class="instruction">
                        <strong>Next Steps:</strong>
                        <p style="margin: 0;">
                            1. Return to the Vegobolt app<br>
                            2. Log in with your email and password<br>
                            3. Start using Vegobolt!
                        </p>
                    </div>
                </div>
            </body>
            </html>
        `);

    } catch (error) {
        console.error('Email verification error:', error);
        res.status(500).json({
            success: false,
            message: 'Error verifying email',
            error: error.message
        });
    }
};

/**
 * Resend verification email
 */
const resendVerificationEmail = async (req, res) => {
    try {
        // Ensure MongoDB is connected (for serverless environments)
        await connectDB();
        
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'Please provide email'
            });
        }

        // Find user
        const user = await User.findByEmail(email);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Check if already verified
        if (user.isEmailVerified) {
            return res.status(400).json({
                success: false,
                message: 'Email is already verified'
            });
        }

        // Generate new verification token
        const verificationToken = generateVerificationToken();
        const verificationExpires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

        // Update user with new token
        user.emailVerificationToken = verificationToken;
        user.emailVerificationExpires = verificationExpires;
        await user.save();

        // Send verification email
        try {
            await sendVerificationEmail(email, verificationToken, user.displayName);
            
            res.status(200).json({
                success: true,
                message: 'Verification email sent successfully. Please check your inbox.'
            });
        } catch (emailError) {
            console.error('Failed to send verification email:', emailError);
            res.status(500).json({
                success: false,
                message: 'Failed to send verification email. Please try again later.'
            });
        }

    } catch (error) {
        console.error('Resend verification error:', error);
        res.status(500).json({
            success: false,
            message: 'Error resending verification email',
            error: error.message
        });
    }
};

/**
 * Request password reset
 * Generates reset token and sends email
 */
const requestPasswordReset = async (req, res) => {
    try {
        // Ensure MongoDB is connected (for serverless environments)
        await connectDB();
        
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

        // Generate password reset token
        const { generateVerificationToken, sendPasswordResetEmail } = require('../services/emailService');
        const resetToken = generateVerificationToken();
        const resetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

        // Save reset token to user
        user.passwordResetToken = resetToken;
        user.passwordResetExpires = resetExpires;
        await user.save();

        // Send password reset email
        try {
            await sendPasswordResetEmail(email, resetToken, user.displayName);
            
            res.status(200).json({
                success: true,
                message: 'If the email exists, a password reset link will be sent'
            });
        } catch (emailError) {
            console.error('Failed to send password reset email:', emailError);
            res.status(500).json({
                success: false,
                message: 'Failed to send password reset email. Please try again later.'
            });
        }

    } catch (error) {
        console.error('Password reset error:', error);
        res.status(500).json({
            success: false,
            message: 'Error requesting password reset',
            error: error.message
        });
    }
};

/**
 * Display password reset page with token
 * Similar to email verification - shows HTML page directly
 */
const showResetPasswordPage = async (req, res) => {
    try {
        // Ensure MongoDB is connected (for serverless environments)
        await connectDB();
        
        const { token } = req.params;

        if (!token) {
            return res.status(400).send(`
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Invalid Link - Vegobolt</title>
                    <style>
                        * { margin: 0; padding: 0; box-sizing: border-box; }
                        body {
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
                            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                            display: flex;
                            justify-content: center;
                            align-items: center;
                            min-height: 100vh;
                            padding: 20px;
                        }
                        .container {
                            background: white;
                            padding: 40px;
                            border-radius: 20px;
                            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                            text-align: center;
                            max-width: 500px;
                        }
                        .error-icon {
                            width: 80px;
                            height: 80px;
                            background: #f44336;
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin: 0 auto 30px;
                            color: white;
                            font-size: 50px;
                        }
                        h1 { color: #333; font-size: 28px; margin-bottom: 15px; }
                        p { color: #666; font-size: 16px; line-height: 1.6; }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="error-icon">!</div>
                        <h1>Invalid Link</h1>
                        <p>This password reset link is invalid.</p>
                    </div>
                </body>
                </html>
            `);
        }

        // Find user with valid reset token
        const user = await User.findOne({
            passwordResetToken: token,
            passwordResetExpires: { $gt: Date.now() }
        });

        if (!user) {
            return res.status(400).send(`
                <!DOCTYPE html>
                <html lang="en">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Reset Link Expired - Vegobolt</title>
                    <style>
                        * { margin: 0; padding: 0; box-sizing: border-box; }
                        body {
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
                            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                            display: flex;
                            justify-content: center;
                            align-items: center;
                            min-height: 100vh;
                            padding: 20px;
                        }
                        .container {
                            background: white;
                            padding: 40px;
                            border-radius: 20px;
                            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                            text-align: center;
                            max-width: 500px;
                        }
                        .error-icon {
                            width: 80px;
                            height: 80px;
                            background: #FF9800;
                            border-radius: 50%;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            margin: 0 auto 30px;
                            color: white;
                            font-size: 50px;
                        }
                        h1 { color: #333; font-size: 28px; margin-bottom: 15px; }
                        p { color: #666; font-size: 16px; line-height: 1.6; margin-bottom: 15px; }
                        .instruction {
                            background: #fff3cd;
                            border-left: 4px solid #ffc107;
                            padding: 15px;
                            border-radius: 5px;
                            margin-top: 20px;
                            text-align: left;
                        }
                    </style>
                </head>
                <body>
                    <div class="container">
                        <div class="error-icon">⏱</div>
                        <h1>Link Expired</h1>
                        <p>This password reset link has expired or has already been used.</p>
                        <div class="instruction">
                            <p style="margin: 0;">
                                <strong>What to do:</strong><br>
                                1. Open the Vegobolt app<br>
                                2. Go to "Forgot Password?"<br>
                                3. Request a new reset link
                            </p>
                        </div>
                    </div>
                </body>
                </html>
            `);
        }

        // Show password reset form
        res.status(200).send(`
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Reset Password - Vegobolt</title>
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        min-height: 100vh;
                        padding: 20px;
                    }
                    .container {
                        background: white;
                        padding: 40px;
                        border-radius: 20px;
                        box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                        max-width: 450px;
                        width: 100%;
                        animation: slideUp 0.5s ease-out;
                    }
                    @keyframes slideUp {
                        from {
                            opacity: 0;
                            transform: translateY(30px);
                        }
                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }
                    h1 {
                        color: #333;
                        font-size: 28px;
                        margin-bottom: 10px;
                        text-align: center;
                    }
                    .subtitle {
                        color: #666;
                        font-size: 14px;
                        text-align: center;
                        margin-bottom: 30px;
                    }
                    .form-group {
                        margin-bottom: 20px;
                    }
                    label {
                        display: block;
                        color: #333;
                        font-size: 14px;
                        font-weight: 600;
                        margin-bottom: 8px;
                    }
                    input[type="password"] {
                        width: 100%;
                        padding: 12px 15px;
                        border: 2px solid #e0e0e0;
                        border-radius: 8px;
                        font-size: 16px;
                        transition: border-color 0.3s;
                    }
                    input[type="password"]:focus {
                        outline: none;
                        border-color: #7AB93F;
                    }
                    .error-message {
                        color: #f44336;
                        font-size: 13px;
                        margin-top: 5px;
                        display: none;
                    }
                    button {
                        width: 100%;
                        padding: 14px;
                        background: #FFD700;
                        color: white;
                        border: none;
                        border-radius: 8px;
                        font-size: 16px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: transform 0.2s, background 0.2s;
                    }
                    button:hover {
                        transform: translateY(-2px);
                        background: #E6C200;
                    }
                    button:disabled {
                        opacity: 0.6;
                        cursor: not-allowed;
                        transform: none;
                    }
                    .success-message {
                        background: #7AB93F;
                        color: white;
                        padding: 15px;
                        border-radius: 8px;
                        text-align: center;
                        display: none;
                        margin-top: 20px;
                    }
                    .password-requirements {
                        background: #F5F5DC;
                        padding: 12px;
                        border-radius: 6px;
                        font-size: 13px;
                        color: #666;
                        margin-top: 10px;
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>Reset Your Password</h1>
                    <p class="subtitle">Enter your new password below</p>
                    
                    <form id="resetForm">
                        <div class="form-group">
                            <label for="password">New Password</label>
                            <input type="password" id="password" name="password" required minlength="6">
                            <div class="error-message" id="passwordError"></div>
                        </div>
                        
                        <div class="form-group">
                            <label for="confirmPassword">Confirm Password</label>
                            <input type="password" id="confirmPassword" name="confirmPassword" required>
                            <div class="error-message" id="confirmError"></div>
                        </div>
                        
                        <div class="password-requirements">
                            Password must be at least 6 characters long
                        </div>
                        
                        <button type="submit" id="submitBtn">Reset Password</button>
                        
                        <div class="success-message" id="successMessage">
                            Password reset successful! You can now close this page and login with your new password.
                        </div>
                    </form>
                </div>

                <script>
                    const form = document.getElementById('resetForm');
                    const passwordInput = document.getElementById('password');
                    const confirmInput = document.getElementById('confirmPassword');
                    const submitBtn = document.getElementById('submitBtn');
                    const successMessage = document.getElementById('successMessage');

                    form.addEventListener('submit', async (e) => {
                        e.preventDefault();
                        
                        // Clear previous errors
                        document.getElementById('passwordError').style.display = 'none';
                        document.getElementById('confirmError').style.display = 'none';
                        
                        const password = passwordInput.value;
                        const confirmPassword = confirmInput.value;
                        
                        // Validate
                        if (password.length < 6) {
                            document.getElementById('passwordError').textContent = 'Password must be at least 6 characters';
                            document.getElementById('passwordError').style.display = 'block';
                            return;
                        }
                        
                        if (password !== confirmPassword) {
                            document.getElementById('confirmError').textContent = 'Passwords do not match';
                            document.getElementById('confirmError').style.display = 'block';
                            return;
                        }
                        
                        // Submit
                        submitBtn.disabled = true;
                        submitBtn.textContent = 'Resetting...';
                        
                        try {
                            const response = await fetch('/api/auth/reset-password', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json'
                                },
                                body: JSON.stringify({
                                    token: '${token}',
                                    newPassword: password
                                })
                            });
                            
                            const data = await response.json();
                            
                            if (data.success) {
                                form.style.display = 'none';
                                successMessage.style.display = 'block';
                            } else {
                                alert(data.message || 'Failed to reset password');
                                submitBtn.disabled = false;
                                submitBtn.textContent = 'Reset Password';
                            }
                        } catch (error) {
                            alert('An error occurred. Please try again.');
                            submitBtn.disabled = false;
                            submitBtn.textContent = 'Reset Password';
                        }
                    });
                </script>
            </body>
            </html>
        `);

    } catch (error) {
        console.error('Show reset password page error:', error);
        res.status(500).send(`
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Error - Vegobolt</title>
            </head>
            <body>
                <h1>An error occurred</h1>
                <p>Please try again later.</p>
            </body>
            </html>
        `);
    }
};

/**
 * Reset password with token (API endpoint)
 */
const resetPassword = async (req, res) => {
    try {
        // Ensure MongoDB is connected (for serverless environments)
        await connectDB();
        
        const { token, newPassword } = req.body;

        if (!token || !newPassword) {
            return res.status(400).json({
                success: false,
                message: 'Please provide reset token and new password'
            });
        }

        // Validate password strength
        if (newPassword.length < 6) {
            return res.status(400).json({
                success: false,
                message: 'Password must be at least 6 characters long'
            });
        }

        // Find user with valid reset token
        const user = await User.findOne({
            passwordResetToken: token,
            passwordResetExpires: { $gt: Date.now() }
        });

        if (!user) {
            return res.status(400).json({
                success: false,
                message: 'Invalid or expired reset token'
            });
        }

        // Hash new password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(newPassword, salt);

        // Update user password and clear reset token
        user.password = hashedPassword;
        user.passwordResetToken = null;
        user.passwordResetExpires = null;
        await user.save();

        res.status(200).json({
            success: true,
            message: 'Password has been reset successfully. You can now login with your new password.'
        });

    } catch (error) {
        console.error('Reset password error:', error);
        res.status(500).json({
            success: false,
            message: 'Error resetting password',
            error: error.message
        });
    }
};

module.exports = {
    register,
    login,
    googleLogin,
    verifyToken,
    verifyEmail,
    resendVerificationEmail,
    getProfile,
    logout,
    requestPasswordReset,
    showResetPasswordPage,
    resetPassword
};