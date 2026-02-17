const mqtt = require('mqtt');
const tapoService = require('./tapoService');

class MqttService {
  constructor() {
    this.client = null;
    this.isConnected = false;
  }

  connect() {
    console.log('🔄 Connecting to MQTT broker: broker.hivemq.com...');
    
    this.client = mqtt.connect('mqtt://broker.hivemq.com:1883', {
      clientId: `vegobolt_backend_${Date.now()}`,
      clean: true,
      connectTimeout: 5000,
      reconnectPeriod: 5000,
    });

    this.client.on('connect', () => {
      this.isConnected = true;
      console.log('✅ Backend connected to MQTT broker');
      
      // Subscribe to valve control topic to log commands
      this.client.subscribe('vegobolt/tank/valve/control', (err) => {
        if (!err) {
          console.log('📡 Subscribed to: vegobolt/tank/valve/control');
        }
      });

      // Subscribe to sensor data from ESP32
      this.client.subscribe('vegobolt/tank/sensor/data', (err) => {
        if (!err) {
          console.log('📡 Subscribed to: vegobolt/tank/sensor/data');
        }
      });

      // Subscribe to pump control topic (for Tapo plug control)
      this.client.subscribe('vegobolt/tank/pump/control', (err) => {
        if (!err) {
          console.log('📡 Subscribed to: vegobolt/tank/pump/control');
        }
      });
    });

    this.client.on('message', (topic, message) => {
      const payload = message.toString();
      console.log(`📥 MQTT Message on ${topic}:`, payload);
      
      // Handle sensor data from ESP32
      if (topic === 'vegobolt/tank/sensor/data') {
        try {
          const data = JSON.parse(payload);
          console.log('📊 Sensor data received:', data);
          // TODO: Save to database if needed
        } catch (e) {
          console.error('❌ Error parsing sensor data:', e);
        }
      }

      // Handle pump control (Tapo plug ON/OFF)
      if (topic === 'vegobolt/tank/pump/control') {
        this.handlePumpControl(payload);
      }
    });

    this.client.on('error', (error) => {
      console.error('❌ MQTT Error:', error);
      this.isConnected = false;
    });

    this.client.on('disconnect', () => {
      console.log('❌ MQTT Disconnected');
      this.isConnected = false;
    });

    this.client.on('reconnect', () => {
      console.log('🔄 Reconnecting to MQTT broker...');
    });
  }

  publish(topic, message) {
    if (!this.isConnected || !this.client) {
      console.warn('⚠️ MQTT not connected, cannot publish');
      return false;
    }

    this.client.publish(topic, message, { qos: 1 }, (err) => {
      if (err) {
        console.error('❌ Error publishing message:', err);
      } else {
        console.log(`📤 Published to ${topic}:`, message);
      }
    });

    return true;
  }

  /**
   * Handle pump control via MQTT -> Tapo plug
   * Expected payload: {"command": "ON"} or {"command": "OFF"} or "ON" / "OFF"
   */
  async handlePumpControl(payload) {
    try {
      let command;
      
      // Try to parse as JSON first
      try {
        const data = JSON.parse(payload);
        command = data.command || data.state || data.action;
      } catch (e) {
        // If not JSON, treat as plain text
        command = payload.toUpperCase();
      }

      console.log(`🔌 Pump control command received: ${command}`);

      if (command === 'ON' || command === '1' || command === 'true') {
        const result = await tapoService.turnOn();
        if (result.success) {
          console.log('✅ Pump/Plug turned ON via MQTT');
          // Publish status feedback
          this.publish('vegobolt/tank/pump/status', JSON.stringify({ state: 'ON', timestamp: new Date().toISOString() }));
        }
      } else if (command === 'OFF' || command === '0' || command === 'false') {
        const result = await tapoService.turnOff();
        if (result.success) {
          console.log('✅ Pump/Plug turned OFF via MQTT');
          // Publish status feedback
          this.publish('vegobolt/tank/pump/status', JSON.stringify({ state: 'OFF', timestamp: new Date().toISOString() }));
        }
      } else if (command === 'TOGGLE') {
        const result = await tapoService.toggle();
        if (result.success) {
          console.log(`✅ Pump/Plug toggled to ${result.state} via MQTT`);
          // Publish status feedback
          this.publish('vegobolt/tank/pump/status', JSON.stringify({ state: result.state, timestamp: new Date().toISOString() }));
        }
      } else {
        console.warn(`⚠️ Unknown pump command: ${command}`);
      }
    } catch (error) {
      console.error('❌ Error handling pump control:', error);
    }
  }

  disconnect() {
    if (this.client) {
      this.client.end();
      console.log('🔌 MQTT client disconnected');
    }
  }
}

// Singleton instance
const mqttService = new MqttService();

module.exports = mqttService;
