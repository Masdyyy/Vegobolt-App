const express = require('express');
const router = express.Router();

const inviteCodeController = require('../controllers/inviteCodeController');
const { authenticateToken, requireAdmin } = require('../middleware/authMiddleware');

/**
 * @route   POST /api/invite-codes
 * @desc    Admin: generate a unique signup code
 * @access  Private (admin)
 * body: { length?: number, expiresInDays?: number }
 */
router.post('/', authenticateToken, requireAdmin, inviteCodeController.generateInviteCode);

module.exports = router;
