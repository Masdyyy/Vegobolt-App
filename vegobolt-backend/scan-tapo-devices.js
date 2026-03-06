#!/usr/bin/env node
/**
 * Utility script to scan local network for Tapo devices
 * Run: node scan-tapo-devices.js
 */

require('dotenv').config();
const { findTapoDevices, getLocalIpAddress } = require('./src/utils/networkUtils');

async function main() {
  console.log('🔍 Tapo Device Scanner');
  console.log('='.repeat(50));
  
  const localIp = getLocalIpAddress();
  console.log(`📡 Your local IP: ${localIp}`);
  console.log('');
  
  console.log('Scanning network for Tapo devices...');
  console.log('This may take 1-2 minutes...');
  console.log('(Router/gateway IPs will be skipped)');
  console.log('');
  
  const startTime = Date.now();
  const devices = await findTapoDevices();
  const duration = ((Date.now() - startTime) / 1000).toFixed(1);
  
  console.log('');
  console.log('='.repeat(50));
  console.log(`✅ Scan complete in ${duration}s`);
  console.log('');
  
  if (devices.length === 0) {
    console.log('❌ No Tapo devices found on the network');
    console.log('');
    console.log('📋 Troubleshooting Steps:');
    console.log('');
    console.log('1. Check Tapo Device:');
    console.log('   - Is it powered on?');
    console.log('   - Is the LED light showing activity?');
    console.log('   - Try unplugging and replugging it');
    console.log('');
    console.log('2. Check Network:');
    console.log('   - Open the Tapo app on your phone');
    console.log('   - Go to device settings → Device Info');
    console.log('   - Check the IP address shown there');
    console.log('   - Make sure device is on the SAME Wi-Fi network');
    console.log('');
    console.log('3. Check Your Router:');
    console.log('   - Log into your router admin panel');
    console.log('   - Look for "Connected Devices" or "DHCP Clients"');
    console.log('   - Find devices named "Tapo" or by MAC address');
    console.log('');
    console.log('4. Manual IP Entry:');
    console.log('   - If you know the IP, add it to .env file:');
    console.log('     TAPO_DEVICE_IP=192.168.x.xxx');
    console.log('');
    console.log('5. Network Scan from Router:');
    console.log('   - Common router IPs:');
    console.log('     http://192.168.1.1');
    console.log('     http://192.168.0.1');
    console.log('     http://10.0.0.1');
  } else {
    console.log(`✅ Found ${devices.length} potential Tapo device(s):`);
    console.log('');
    
    devices.forEach((ip, index) => {
      console.log(`${index + 1}. ${ip}`);
      
      // Warn if it looks like a gateway
      const lastOctet = ip.split('.')[3];
      if (lastOctet === '1' || lastOctet === '254') {
        console.log(`   ⚠️  Warning: This might be your router/gateway`);
      }
    });
    
    console.log('');
    console.log('💡 To verify and use a device:');
    console.log('');
    console.log(`1. Test in browser: http://${devices[0]}/`);
    console.log('   (Tapo devices usually show a simple page or login)');
    console.log('');
    console.log('2. Update your .env file:');
    console.log(`   TAPO_DEVICE_IP=${devices[0]}`);
    console.log('');
    console.log('3. Or leave TAPO_DEVICE_IP empty for auto-discovery');
    console.log('   (Backend will try all found devices)');
  }
  
  console.log('');
}

main().catch(err => {
  console.error('Error:', err.message);
  process.exit(1);
});
