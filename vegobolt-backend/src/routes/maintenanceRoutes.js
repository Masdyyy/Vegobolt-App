const express = require('express');
const router = express.Router();
const maintenanceController = require('../controllers/maintenanceController');
const { authenticateToken } = require('../middleware/authMiddleware');

// Public: list all maintenance items (optionally filter by status)
router.get('/', maintenanceController.listMaintenance);

// Protected: create new maintenance
router.post('/', authenticateToken, maintenanceController.createMaintenance);

// Protected: update
router.put('/:id', authenticateToken, maintenanceController.updateMaintenance);

// Protected: delete
router.delete('/:id', authenticateToken, maintenanceController.deleteMaintenance);

// Protected: resolve
router.post('/:id/resolve', authenticateToken, maintenanceController.resolveMaintenance);

module.exports = router;
