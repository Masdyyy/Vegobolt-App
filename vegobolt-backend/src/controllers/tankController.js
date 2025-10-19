const Tank = require('../models/TankData');


// 🟩 GET /api/tank/status
exports.getStatus = async (req, res) => {
  try {
    const latest = await Tank.findOne().sort({ createdAt: -1 });
    res.json(latest || { status: "Unknown", level: 0 });
  } catch (err) {
    res.status(500).json({ message: "Error fetching tank data" });
  }
};

// 🟦 POST /api/tank/update
exports.updateStatus = async (req, res) => {
  try {
    const { status, level } = req.body;
    const tank = await Tank.create({ status, level });

    // Example alert logic
    if (status === "Full" || level >= 90) {
      console.log("🚨 ALERT: Tank Full!");
    }

    res.json({ success: true, message: "Tank data updated", tank });
  } catch (err) {
    res.status(500).json({ message: "Error saving tank data" });
  }
};
