const { cloudLogin, loginDeviceByIp } = require('tp-link-tapo-connect');
const { findTapoDevices, checkPort } = require('../utils/networkUtils');

class TapoService {
  constructor() {
    this.device = null;
    this.isConnected = false;
    this.config = {
      email: process.env.TAPO_EMAIL || '',
      password: process.env.TAPO_PASSWORD || '',
      deviceIp: process.env.TAPO_DEVICE_IP || ''
    };
    this.discoveredIp = null; // Store auto-discovered IP
  }

  /**
   * Try to discover Tapo devices on the network
   */
  async discoverDevice() {
    try {
      console.log('🔍 Scanning network for Tapo devices...');
      const devices = await findTapoDevices();
      
      if (devices.length === 0) {
        console.warn('⚠️ No Tapo devices found on the network');
        return null;
      }
      
      console.log(`✅ Found ${devices.length} potential Tapo device(s):`, devices);
      
      // Filter out obvious router IPs (x.x.x.1 and x.x.x.254)
      const nonGatewayDevices = devices.filter(ip => {
        const lastOctet = ip.split('.')[3];
        return lastOctet !== '1' && lastOctet !== '254';
      });
      
      if (nonGatewayDevices.length > 0) {
        console.log(`✅ Using non-gateway IP: ${nonGatewayDevices[0]}`);
        return nonGatewayDevices[0];
      }
      
      // If only gateway IPs found, warn but return the first one
      if (devices.length > 0) {
        console.warn('⚠️ Only gateway IPs found. This might not be a Tapo device.');
        console.warn('💡 Check the Tapo app or router settings for the correct device IP');
        return devices[0];
      }
      
      return null;
    } catch (error) {
      console.error('❌ Error discovering Tapo devices:', error.message);
      return null;
    }
  }

  /**
   * Initialize connection to Tapo device
   * Will attempt auto-discovery if configured IP fails
   */
  async connect() {
    try {
      if (!this.config.email || !this.config.password) {
        console.warn('⚠️ Tapo credentials not configured in .env');
        return false;
      }

      let ipToTry = this.config.deviceIp || this.discoveredIp;

      // If no IP configured, try to discover devices
      if (!ipToTry) {
        console.log('⚠️ No Tapo device IP configured, attempting auto-discovery...');
        ipToTry = await this.discoverDevice();
        if (ipToTry) {
          this.discoveredIp = ipToTry;
          console.log(`✅ Using discovered IP: ${ipToTry}`);
        } else {
          console.warn('⚠️ Could not discover Tapo device. Please configure TAPO_DEVICE_IP in .env');
          return false;
        }
      }

      console.log(`🔄 Connecting to Tapo device at ${ipToTry}...`);
      
      // Login to TP-Link cloud
      const cloudToken = await cloudLogin(this.config.email, this.config.password);
      
      // Connect to device
      this.device = await loginDeviceByIp(this.config.email, this.config.password, ipToTry);
      this.isConnected = true;
      
      console.log('✅ Successfully connected to Tapo device');
      
      // Log device info
      const deviceInfo = await this.device.getDeviceInfo();
      console.log(`📱 Device: ${deviceInfo.nickname || 'Unknown'} (${deviceInfo.model})`);
      
      return true;
    } catch (error) {
      console.error('❌ Tapo connection error:', error.message);
      this.isConnected = false;
      
      // If connection failed and we haven't tried auto-discovery yet, try it now
      if (this.config.deviceIp && !this.discoveredIp) {
        console.log('⚠️ Configured IP failed, attempting auto-discovery as fallback...');
        const discoveredIp = await this.discoverDevice();
        
        if (discoveredIp && discoveredIp !== this.config.deviceIp) {
          this.discoveredIp = discoveredIp;
          console.log(`🔄 Retrying with discovered IP: ${discoveredIp}...`);
          
          try {
            const cloudToken = await cloudLogin(this.config.email, this.config.password);
            this.device = await loginDeviceByIp(this.config.email, this.config.password, discoveredIp);
            this.isConnected = true;
            console.log('✅ Successfully connected to Tapo device using discovered IP');
            
            const deviceInfo = await this.device.getDeviceInfo();
            console.log(`📱 Device: ${deviceInfo.nickname || 'Unknown'} (${deviceInfo.model})`);
            console.log(`💡 TIP: Update TAPO_DEVICE_IP in .env to: ${discoveredIp}`);
            
            return true;
          } catch (retryError) {
            console.error('❌ Retry with discovered IP also failed:', retryError.message);
          }
        }
      }
      
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
