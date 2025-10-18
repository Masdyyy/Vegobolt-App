const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticateToken } = require('../middleware/authMiddleware');

/**
 * @route   GET /api/users/profile
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/profile', authenticateToken, userController.getUserProfile);

/**
 * @route   PUT /api/users/profile
 * @desc    Update current user profile
 * @access  Private
 */
router.put('/profile', authenticateToken, userController.updateUserProfile);

/**
 * @route   DELETE /api/users/account
 * @desc    Delete current user account
 * @access  Private
 */
router.delete('/account', authenticateToken, userController.deleteUserAccount);

module.exports = router;