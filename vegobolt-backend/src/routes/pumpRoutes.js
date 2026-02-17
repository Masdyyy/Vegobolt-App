const express = require("express");
const router = express.Router();
const PumpController = require("../controllers/pumpController");

// Pump control routes
router.post("/on", PumpController.turnOn);
router.post("/off", PumpController.turnOff);
router.post("/toggle", PumpController.toggle);
router.post("/control", PumpController.control);
router.get("/status", PumpController.getStatus);
router.get("/energy", PumpController.getEnergyUsage);

module.exports = router;
