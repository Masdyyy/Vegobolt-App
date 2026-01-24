const express = require('express');
const router = express.Router();
const { getBackendUrl } = require('../controllers/configController');

/**
 * GET /api/config/backend-url
 * Get the current backend URL (auto-detected or from env)
 */
router.get('/backend-url', getBackendUrl);

module.exports = router;
