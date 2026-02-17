const { cloudLogin, loginDeviceByIp } = require('tp-link-tapo-connect');

class TapoService {
  constructor() {
    this.device = null;
    this.isConnected = false;
    this.config = {
      email: process.env.TAPO_EMAIL || '',
      password: process.env.TAPO_PASSWORD || '',
      deviceIp: process.env.TAPO_DEVICE_IP || ''
    };
  }

  /**
   * Initialize connection to Tapo device
   */
  async connect() {
    try {
      if (!this.config.email || !this.config.password || !this.config.deviceIp) {
        console.warn('⚠️ Tapo credentials not configured in .env');
        return false;
      }

      console.log(`🔄 Connecting to Tapo device at ${this.config.deviceIp}...`);
      
      // Login to TP-Link cloud
      const cloudToken = await cloudLogin(this.config.email, this.config.password);
      
      // Connect to device
      this.device = await loginDeviceByIp(this.config.email, this.config.password, this.config.deviceIp);
      this.isConnected = true;
      
      console.log('✅ Successfully connected to Tapo device');
      
      // Log device info
      const deviceInfo = await this.device.getDeviceInfo();
      console.log(`📱 Device: ${deviceInfo.nickname || 'Unknown'} (${deviceInfo.model})`);
      
      return true;
    } catch (error) {
      console.error('❌ Tapo connection error:', error.message);
      this.isConnected = false;
      return false;
    }
  }

  /**
   * Turn the plug ON
   */
  async turnOn() {
    try {
      if (!this.isConnected) {
        await this.connect();
      }

      if (!this.device) {
        throw new Error('Device not connected');
      }

      await this.device.turnOn();
      console.log('🟢 Tapo plug turned ON');
      return { success: true, state: 'ON' };
    } catch (error) {
      console.error('❌ Error turning plug ON:', error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Turn the plug OFF
   */
  async turnOff() {
    try {
      if (!this.isConnected) {
        await this.connect();
      }

      if (!this.device) {
        throw new Error('Device not connected');
      }

      await this.device.turnOff();
      console.log('🔴 Tapo plug turned OFF');
      return { success: true, state: 'OFF' };
    } catch (error) {
      console.error('❌ Error turning plug OFF:', error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Toggle the plug state
   */
  async toggle() {
    try {
      const status = await this.getStatus();
      if (status.device_on) {
        return await this.turnOff();
      } else {
        return await this.turnOn();
      }
    } catch (error) {
      console.error('❌ Error toggling plug:', error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Get current device status
   */
  async getStatus() {
    try {
      if (!this.isConnected) {
        await this.connect();
      }

      if (!this.device) {
        throw new Error('Device not connected');
      }

      const deviceInfo = await this.device.getDeviceInfo();
      
      return {
        success: true,
        device_on: deviceInfo.device_on,
        nickname: deviceInfo.nickname,
        model: deviceInfo.model,
        signal_level: deviceInfo.signal_level,
        rssi: deviceInfo.rssi,
        on_time: deviceInfo.on_time
      };
    } catch (error) {
      console.error('❌ Error getting device status:', error.message);
      return { success: false, error: error.message };
    }
  }

  /**
   * Get energy usage (if supported by device)
   */
  async getEnergyUsage() {
    try {
      if (!this.isConnected) {
        await this.connect();
      }

      if (!this.device) {
        throw new Error('Device not connected');
      }

      const energyUsage = await this.device.getEnergyUsage();
      console.log('⚡ Energy usage:', energyUsage);
      
      return {
        success: true,
        data: energyUsage
      };
    } catch (error) {
      console.error('❌ Error getting energy usage:', error.message);
      return { success: false, error: error.message };
    }
  }
}

// Singleton instance
const tapoService = new TapoService();

module.exports = tapoService;
