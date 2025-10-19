const express = require("express");
const router = express.Router();
const Tank = require("../models/TankData");

// GET /api/alerts
// Returns an array with a single alert only when the latest tank status is Full (or level >= 90), otherwise []
router.get("/", async (req, res) => {
  try {
    const latest = await Tank.findOne().sort({ createdAt: -1 });
    if (!latest) return res.json([]);

    const isFull =
      (typeof latest.status === "string" && latest.status.toLowerCase() === "full") ||
      (typeof latest.level === "number" && latest.level >= 90);

    if (!isFull) return res.json([]);

    const alert = {
      title: "Tank Full",
      machine: "VB-0001", // optional static label for UI; adjust if you track machine IDs
      location: "", // optional
      time: latest.createdAt ? latest.createdAt.toISOString() : new Date().toISOString(),
      status: "Critical",
    };

    return res.json([alert]);
  } catch (err) {
    console.error("/api/alerts error:", err);
    res.status(500).json({ message: "Failed to load alerts" });
  }
});

module.exports = router;
