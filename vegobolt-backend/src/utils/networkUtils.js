const os = require('os');
const net = require('net');

/**
 * Get the local IP address of the machine
 * Prioritizes Wi-Fi and Ethernet connections
 * @returns {string} Local IP address or 'localhost'
 */
function getLocalIpAddress() {
  const interfaces = os.networkInterfaces();
  
  // Priority order: Wi-Fi, Ethernet, then others
  const priorityOrder = ['Wi-Fi', 'wlan0', 'wlan1', 'Ethernet', 'eth0', 'eth1', 'en0', 'en1'];
  
  // First, try priority interfaces
  for (const name of priorityOrder) {
    const iface = interfaces[name];
    if (iface) {
      for (const addr of iface) {
        // Skip internal (loopback) and non-IPv4 addresses
        if (addr.family === 'IPv4' && !addr.internal) {
          return addr.address;
        }
      }
    }
  }
  
  // If no priority interface found, scan all interfaces
  for (const name of Object.keys(interfaces)) {
    const iface = interfaces[name];
    for (const addr of iface) {
      // Skip internal (loopback) and non-IPv4 addresses
      if (addr.family === 'IPv4' && !addr.internal) {
        return addr.address;
      }
    }
  }
  
  // Fallback to localhost
  return 'localhost';
}

/**
 * Get the backend URL with auto-detected IP
 * @param {number} port - Server port
 * @returns {string} Backend URL
 */
function getBackendUrl(port = 3000) {
  // In production/Vercel, use environment variable
  if (process.env.NODE_ENV === 'production' || process.env.VERCEL_URL) {
    return process.env.BACKEND_URL || 
           (process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : undefined) ||
           process.env.FRONTEND_URL ||
           'http://localhost:3000';
  }
  
  // Auto-detect local IP
  const localIp = getLocalIpAddress();
  
  // In development, check if BACKEND_URL is set
  if (process.env.BACKEND_URL) {
    const backendUrl = process.env.BACKEND_URL.toLowerCase();
    
    // If it's localhost or empty, use auto-detected IP
    if (backendUrl.includes('localhost') || backendUrl === 'auto' || backendUrl === '') {
      return `http://${localIp}:${port}`;
    }
    
    // If it contains a local IP pattern (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
    // but doesn't match current IP, prefer auto-detection (user switched networks)
    const localIpPatterns = [
      /192\.168\.\d+\.\d+/,
      /10\.\d+\.\d+\.\d+/,
      /172\.(1[6-9]|2[0-9]|3[0-1])\.\d+\.\d+/
    ];
    
    const hasLocalIpPattern = localIpPatterns.some(pattern => pattern.test(backendUrl));
    if (hasLocalIpPattern && !backendUrl.includes(localIp)) {
      console.log(`⚠️  BACKEND_URL (${process.env.BACKEND_URL}) doesn't match current IP (${localIp})`);
      console.log(`💡 Using auto-detected IP instead. Update .env if you want to keep the old IP.`);
      return `http://${localIp}:${port}`;
    }
    
    // Use the configured URL (public domain, VPS, etc.)
    return process.env.BACKEND_URL;
  }
  
  // Default: auto-detect
  return `http://${localIp}:${port}`;
}

/**
 * Scan local network for a device on a specific port
 * @param {number} port - Port to scan (default 80 for Tapo)
 * @param {number} timeout - Timeout per IP in milliseconds
 * @returns {Promise<string[]>} Array of responsive IP addresses
 */
async function scanLocalNetwork(port = 80, timeout = 1000) {
  const localIp = getLocalIpAddress();
  
  if (localIp === 'localhost') {
    console.warn('Could not determine local IP for network scanning');
    return [];
  }
  
  // Extract network prefix (e.g., "192.168.1" from "192.168.1.17")
  const ipParts = localIp.split('.');
  const networkPrefix = ipParts.slice(0, 3).join('.');
  
  console.log(`🔍 Scanning network ${networkPrefix}.0/24 on port ${port}...`);
  
  // Common router/gateway IPs to skip (they often respond on port 80 but aren't Tapo devices)
  const commonGatewayIPs = ['1', '254'];
  
  const promises = [];
  const foundDevices = [];
  
  // Scan common IP range (2-253, skip 1 and 254 which are usually gateways)
  for (let i = 2; i <= 253; i++) {
    const ip = `${networkPrefix}.${i}`;
    
    // Skip the local machine's IP
    if (ip === localIp) {
      continue;
    }
    
    promises.push(
      checkPort(ip, port, timeout)
        .then(isOpen => {
          if (isOpen) {
            foundDevices.push(ip);
            console.log(`✅ Found device at ${ip}:${port}`);
          }
        })
        .catch(() => {}) // Ignore errors
    );
    
    // Process in batches to avoid overwhelming the system
    if (promises.length >= 50) {
      await Promise.all(promises);
      promises.length = 0;
    }
  }
  
  // Wait for remaining promises
  await Promise.all(promises);
  
  // If no devices found in the main range, check gateway IPs as last resort
  if (foundDevices.length === 0) {
    console.log('⚠️ No devices found in main range, checking gateway IPs...');
    for (const lastOctet of commonGatewayIPs) {
      const ip = `${networkPrefix}.${lastOctet}`;
      if (ip !== localIp && await checkPort(ip, port, timeout)) {
        foundDevices.push(ip);
        console.log(`⚠️ Found device at gateway IP ${ip}:${port} (might be router)`);
      }
    }
  }
  
  return foundDevices;
}

/**
 * Check if a port is open on a given IP
 * @param {string} ip - IP address to check
 * @param {number} port - Port number
 * @param {number} timeout - Timeout in milliseconds
 * @returns {Promise<boolean>} True if port is open
 */
function checkPort(ip, port, timeout) {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    
    const onError = () => {
      socket.destroy();
      resolve(false);
    };
    
    socket.setTimeout(timeout);
    socket.once('error', onError);
    socket.once('timeout', onError);
    
    socket.connect(port, ip, () => {
      socket.destroy();
      resolve(true);
    });
  });
}

/**
 * Find Tapo devices on the local network
 * Tapo devices typically use port 80
 * @returns {Promise<string[]>} Array of potential Tapo device IPs
 */
async function findTapoDevices() {
  return scanLocalNetwork(80, 500);
}

module.exports = {
  getLocalIpAddress,
  getBackendUrl,
  scanLocalNetwork,
  findTapoDevices,
  checkPort
};
