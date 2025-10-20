const express = require("express");
const router = express.Router();
const TankController = require("../controllers/tankController");

router.get("/status", TankController.getStatus);
router.post("/update", TankController.updateStatus);
router.get("/alerts", TankController.getAlerts);
router.get("/history", TankController.getHistory);

module.exports = router;
