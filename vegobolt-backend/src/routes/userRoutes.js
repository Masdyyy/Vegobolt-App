const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const { authenticateToken, requireAdmin } = require('../middleware/authMiddleware');

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

// Admin endpoints
router.get('/', authenticateToken, requireAdmin, userController.listUsers);
router.delete('/:id', authenticateToken, requireAdmin, userController.adminDeleteUser);
router.put('/:id/active', authenticateToken, requireAdmin, userController.setUserActive);
router.put('/:id/machine', authenticateToken, requireAdmin, userController.updateMachine);

module.exports = router;