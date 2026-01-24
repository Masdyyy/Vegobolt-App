/**
 * Network utilities for auto-detecting IP addresses
 */
const os = require('os');

/**
 * Get the local network IP address (LAN IP)
 * @returns {string} Local IP address or 'localhost' if not found
 */
function getLocalIpAddress() {
    const interfaces = os.networkInterfaces();
    
    // Priority order: Wi-Fi, Ethernet, other
    const priority = ['Wi-Fi', 'WiFi', 'WLAN', 'Ethernet', 'eth0', 'en0'];
    
    // First try priority interfaces
    for (const name of priority) {
        if (interfaces[name]) {
            for (const iface of interfaces[name]) {
                // Skip internal (loopback) and non-IPv4 addresses
                if (iface.family === 'IPv4' && !iface.internal) {
                    return iface.address;
                }
            }
        }
    }
    
    // If no priority interface found, try all interfaces
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            // Skip internal (loopback) and non-IPv4 addresses
            if (iface.family === 'IPv4' && !iface.internal) {
                return iface.address;
            }
        }
    }
    
    // Fallback to localhost if no network interface found
    return 'localhost';
}

/**
 * Generate backend URL with auto-detected IP
 * @param {number} port - Port number (default: 3000)
 * @returns {string} Full backend URL
 */
function getAutoBackendUrl(port = 3000) {
    const ip = getLocalIpAddress();
    return `http://${ip}:${port}`;
}

module.exports = {
    getLocalIpAddress,
    getAutoBackendUrl
};
