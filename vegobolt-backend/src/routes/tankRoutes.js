const express = require("express");
const router = express.Router();
const TankController = require("../controllers/tankController");

router.get("/status", TankController.getStatus);
router.post("/update", TankController.updateStatus);

module.exports = router;
