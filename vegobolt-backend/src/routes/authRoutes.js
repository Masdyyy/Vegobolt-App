const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticateToken } = require('../middleware/authMiddleware');

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post('/register', authController.register);

/**
 * @route   POST /api/auth/login
 * @desc    Login user and get token
 * @access  Public
 */
router.post('/login', authController.login);

/**
 * @route   POST /api/auth/google
 * @desc    Login/Register with Google ID token
 * @access  Public
 */
router.post('/google', authController.googleLogin);

/**
 * @route   POST /api/auth/verify
 * @desc    Verify Firebase ID token
 * @access  Public
 */
router.post('/verify', authController.verifyToken);

/**
 * @route   GET /api/auth/verify-email/:token
 * @desc    Verify user email with token
 * @access  Public
 */
router.get('/verify-email/:token', authController.verifyEmail);

/**
 * @route   POST /api/auth/resend-verification
 * @desc    Resend email verification
 * @access  Public
 */
router.post('/resend-verification', authController.resendVerificationEmail);

/**
 * @route   GET /api/auth/profile
 * @desc    Get current user profile
 * @access  Private (requires authentication)
 */
router.get('/profile', authenticateToken, authController.getProfile);

/**
 * @route   POST /api/auth/logout
 * @desc    Logout user
 * @access  Private (requires authentication)
 */
router.post('/logout', authenticateToken, authController.logout);

/**
 * @route   POST /api/auth/password-reset
 * @desc    Request password reset
 * @access  Public
 */
router.post('/password-reset', authController.requestPasswordReset);

/**
 * @route   GET /api/auth/reset-password/:token
 * @desc    Show password reset page (like email verification)
 * @access  Public
 */
router.get('/reset-password/:token', authController.showResetPasswordPage);

/**
 * @route   POST /api/auth/reset-password
 * @desc    Reset password with token (API endpoint)
 * @access  Public
 */
router.post('/reset-password', authController.resetPassword);

module.exports = router;