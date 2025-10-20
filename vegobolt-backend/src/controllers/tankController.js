const Tank = require('../models/TankData');


// 🟩 GET /api/tank/status
exports.getStatus = async (req, res) => {
  try {
    const latest = await Tank.findOne().sort({ createdAt: -1 });
    res.json(latest || { 
      status: "Unknown", 
      level: 0, 
      temperature: 0, 
      batteryLevel: 100,
      alert: "normal" 
    });
  } catch (err) {
    res.status(500).json({ message: "Error fetching tank data" });
  }
};

// 🟦 POST /api/tank/update
exports.updateStatus = async (req, res) => {
  try {
    const { status, level, temperature, batteryLevel, alert, timestamp } = req.body;
    
    const tankData = {
      status: status || "Unknown",
      level: level || 0,
      temperature: temperature || 0,
      batteryLevel: batteryLevel || 0, // Default to 0 if no battery sensor
      alert: alert || "normal"
    };

    const tank = await Tank.create(tankData);

    // Detailed logging
    console.log(`📊 Data received - Status: ${tankData.status}, Level: ${tankData.level}%, Temp: ${tankData.temperature}°C, Battery: ${tankData.batteryLevel}%, Alert: ${tankData.alert}`);

    // Alert logic
    if (alert === "overheating") {
      console.log(`🔥 OVERHEATING ALERT! Temperature: ${temperature}°C`);
    } else if (status === "Full" || level >= 90) {
      console.log("🚨 ALERT: Tank Full!");
    }

    res.json({ success: true, message: "Tank data updated", tank });
  } catch (err) {
    console.error("Error saving tank data:", err);
    res.status(500).json({ message: "Error saving tank data" });
  }
};

// 🟧 GET /api/tank/alerts - Get recent alerts (overheating or tank full)
exports.getAlerts = async (req, res) => {
  try {
    // Get only the LATEST record (current status)
    const latest = await Tank.findOne().sort({ createdAt: -1 });

    if (!latest) {
      return res.json([]);
    }

    const alerts = [];
    
    // Only show overheating alert if CURRENTLY overheating
    if (latest.alert === "overheating" || latest.temperature > 50) {
      alerts.push({
        title: 'Overheating Alert',
        machine: 'VB-0001',
        location: 'Barangay 171',
        time: latest.createdAt,
        status: 'Critical',
        type: 'temperature',
        details: `Temperature: ${latest.temperature}°C`
      });
    }
    
    // Only show tank full alert if CURRENTLY full
    if (latest.status === "Full" || latest.level >= 90) {
      alerts.push({
        title: 'Tank Full',
        machine: 'VB-0001',
        location: 'Barangay 171',
        time: latest.createdAt,
        status: 'Critical',
        type: 'tank',
        details: `Level: ${latest.level}%`
      });
    }

    res.json(alerts);
  } catch (err) {
    console.error("Error fetching alerts:", err);
    res.status(500).json({ message: "Error fetching alerts" });
  }
};

// 🟪 GET /api/tank/history - Get historical data
exports.getHistory = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 100;
    const history = await Tank.find()
      .sort({ createdAt: -1 })
      .limit(limit);
    
    res.json(history);
  } catch (err) {
    console.error("Error fetching history:", err);
    res.status(500).json({ message: "Error fetching history" });
  }
};
