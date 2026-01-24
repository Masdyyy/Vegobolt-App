/**
 * Get Backend IP Address Script
 * This script outputs the auto-detected backend IP address
 * Can be used by the Flutter app to dynamically connect to the backend
 */

const { getLocalIpAddress, getAutoBackendUrl } = require('./src/utils/networkUtils');

const PORT = process.env.PORT || 3000;
const ip = getLocalIpAddress();
const url = getAutoBackendUrl(PORT);

console.log(JSON.stringify({
    ip: ip,
    port: PORT,
    url: url
}, null, 2));
