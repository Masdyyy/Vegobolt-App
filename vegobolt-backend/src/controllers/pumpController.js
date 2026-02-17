const tapoService = require('../services/tapoService');
const mqttService = require('../services/mqttService');

// 🟢 POST /api/pump/on - Turn pump ON
exports.turnOn = async (req, res) => {
  try {
    const result = await tapoService.turnOn();
    
    if (result.success) {
      // Also publish to MQTT for ESP32 to be notified
      mqttService.publish('vegobolt/tank/pump/status', JSON.stringify({ 
        state: 'ON', 
        timestamp: new Date().toISOString(),
        source: 'api'
      }));
      
      res.json({ success: true, message: 'Pump turned ON', state: 'ON' });
    } else {
      res.status(500).json({ success: false, message: 'Failed to turn pump ON', error: result.error });
    }
  } catch (error) {
    console.error('Error turning pump ON:', error);
    res.status(500).json({ success: false, message: 'Error turning pump ON', error: error.message });
  }
};

// 🔴 POST /api/pump/off - Turn pump OFF
exports.turnOff = async (req, res) => {
  try {
    const result = await tapoService.turnOff();
    
    if (result.success) {
      // Also publish to MQTT for ESP32 to be notified
      mqttService.publish('vegobolt/tank/pump/status', JSON.stringify({ 
        state: 'OFF', 
        timestamp: new Date().toISOString(),
        source: 'api'
      }));
      
      res.json({ success: true, message: 'Pump turned OFF', state: 'OFF' });
    } else {
      res.status(500).json({ success: false, message: 'Failed to turn pump OFF', error: result.error });
    }
  } catch (error) {
    console.error('Error turning pump OFF:', error);
    res.status(500).json({ success: false, message: 'Error turning pump OFF', error: error.message });
  }
};

// 🔄 POST /api/pump/toggle - Toggle pump state
exports.toggle = async (req, res) => {
  try {
    const result = await tapoService.toggle();
    
    if (result.success) {
      // Also publish to MQTT for ESP32 to be notified
      mqttService.publish('vegobolt/tank/pump/status', JSON.stringify({ 
        state: result.state, 
        timestamp: new Date().toISOString(),
        source: 'api'
      }));
      
      res.json({ success: true, message: `Pump toggled to ${result.state}`, state: result.state });
    } else {
      res.status(500).json({ success: false, message: 'Failed to toggle pump', error: result.error });
    }
  } catch (error) {
    console.error('Error toggling pump:', error);
    res.status(500).json({ success: false, message: 'Error toggling pump', error: error.message });
  }
};

// 📊 GET /api/pump/status - Get pump/plug status
exports.getStatus = async (req, res) => {
  try {
    const result = await tapoService.getStatus();
    
    if (result.success) {
      res.json({ 
        success: true, 
        status: result.device_on ? 'ON' : 'OFF',
        device: {
          nickname: result.nickname,
          model: result.model,
          signal_level: result.signal_level,
          on_time: result.on_time
        }
      });
    } else {
      res.status(500).json({ success: false, message: 'Failed to get pump status', error: result.error });
    }
  } catch (error) {
    console.error('Error getting pump status:', error);
    res.status(500).json({ success: false, message: 'Error getting pump status', error: error.message });
  }
};

// ⚡ GET /api/pump/energy - Get energy usage
exports.getEnergyUsage = async (req, res) => {
  try {
    const result = await tapoService.getEnergyUsage();
    
    if (result.success) {
      res.json({ success: true, energy: result.data });
    } else {
      res.status(500).json({ success: false, message: 'Failed to get energy usage', error: result.error });
    }
  } catch (error) {
    console.error('Error getting energy usage:', error);
    res.status(500).json({ success: false, message: 'Error getting energy usage', error: error.message });
  }
};

// 🔌 POST /api/pump/control - Unified control endpoint
// Accepts: { "command": "ON" | "OFF" | "TOGGLE" }
exports.control = async (req, res) => {
  try {
    const { command } = req.body;
    
    if (!command) {
      return res.status(400).json({ success: false, message: 'Command is required' });
    }

    const cmd = command.toUpperCase();
    let result;

    switch(cmd) {
      case 'ON':
      case '1':
        result = await tapoService.turnOn();
        break;
      case 'OFF':
      case '0':
        result = await tapoService.turnOff();
        break;
      case 'TOGGLE':
        result = await tapoService.toggle();
        break;
      default:
        return res.status(400).json({ success: false, message: 'Invalid command. Use ON, OFF, or TOGGLE' });
    }

    if (result.success) {
      // Publish to MQTT
      mqttService.publish('vegobolt/tank/pump/status', JSON.stringify({ 
        state: result.state || (cmd === 'ON' ? 'ON' : 'OFF'), 
        timestamp: new Date().toISOString(),
        source: 'api'
      }));
      
      res.json({ success: true, message: `Pump ${cmd}`, state: result.state });
    } else {
      res.status(500).json({ success: false, message: 'Control failed', error: result.error });
    }
  } catch (error) {
    console.error('Error controlling pump:', error);
    res.status(500).json({ success: false, message: 'Error controlling pump', error: error.message });
  }
};
