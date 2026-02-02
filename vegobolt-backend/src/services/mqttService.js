const mqtt = require('mqtt');

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
    });

    this.client.on('message', (topic, message) => {
      const payload = message.toString();
      console.log(`📥 MQTT Message on ${topic}:`, payload);
      
      // You can add logic here to store sensor data to database
      if (topic === 'vegobolt/tank/sensor/data') {
        try {
          const data = JSON.parse(payload);
          console.log('📊 Sensor data received:', data);
          // TODO: Save to database if needed
        } catch (e) {
          console.error('❌ Error parsing sensor data:', e);
        }
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
