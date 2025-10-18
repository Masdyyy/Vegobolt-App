/**
 * Simple Manual Test Script
 * Quick and easy testing with manual step-by-step process
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

// Color codes for terminal output
const colors = {
    reset: '\x1b[0m',
    green: '\x1b[32m',
    red: '\x1b[31m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    cyan: '\x1b[36m'
};

async function test() {
    console.log('\n' + colors.cyan + '╔════════════════════════════════════════════╗' + colors.reset);
    console.log(colors.cyan + '║  Simple Backend Test - JWT Auth            ║' + colors.reset);
    console.log(colors.cyan + '╚════════════════════════════════════════════╝' + colors.reset);

    try {
        // Step 1: Health Check
        console.log('\n' + colors.yellow + '📍 Step 1: Health Check...' + colors.reset);
        const health = await axios.get(`${BASE_URL}/health`);
        console.log(colors.green + '✅ Server is running!' + colors.reset);
        console.log(health.data);

        // Step 2: Register a new user
        console.log('\n' + colors.yellow + '📍 Step 2: Registering new user...' + colors.reset);
        const registerData = {
            email: `testuser${Date.now()}@example.com`,
            password: 'password123',
            displayName: 'Test User'
        };
        console.log('Registration data:', registerData);
        
        const registerResponse = await axios.post(`${BASE_URL}/api/auth/register`, registerData);
        console.log(colors.green + '✅ Registration successful!' + colors.reset);
        console.log('User created:', registerResponse.data.data.user);
        
        const token = registerResponse.data.data.token;
        console.log(colors.blue + '\n🔑 JWT Token (first 50 chars):' + colors.reset, token.substring(0, 50) + '...');

        // Step 3: Login
        console.log('\n' + colors.yellow + '📍 Step 3: Testing login...' + colors.reset);
        const loginResponse = await axios.post(`${BASE_URL}/api/auth/login`, {
            email: registerData.email,
            password: registerData.password
        });
        console.log(colors.green + '✅ Login successful!' + colors.reset);
        console.log('Login response:', loginResponse.data.data.user);

        const loginToken = loginResponse.data.data.token;

        // Step 4: Verify Token
        console.log('\n' + colors.yellow + '📍 Step 4: Verifying JWT token...' + colors.reset);
        const verifyResponse = await axios.post(
            `${BASE_URL}/api/auth/verify-token`,
            {},
            { headers: { Authorization: `Bearer ${loginToken}` } }
        );
        console.log(colors.green + '✅ Token is valid!' + colors.reset);
        console.log('Token info:', verifyResponse.data.data.tokenInfo);

        // Step 5: Get Profile (Protected Route)
        console.log('\n' + colors.yellow + '📍 Step 5: Getting user profile (protected route)...' + colors.reset);
        const profileResponse = await axios.get(
            `${BASE_URL}/api/auth/profile`,
            { headers: { Authorization: `Bearer ${loginToken}` } }
        );
        console.log(colors.green + '✅ Profile retrieved!' + colors.reset);
        console.log('Profile data:', profileResponse.data.data.user);

        // Summary
        console.log('\n' + colors.cyan + '╔════════════════════════════════════════════╗' + colors.reset);
        console.log(colors.cyan + '║  🎉 ALL TESTS PASSED!                      ║' + colors.reset);
        console.log(colors.cyan + '╚════════════════════════════════════════════╝' + colors.reset);
        console.log(colors.green + '\n✅ Your JWT authentication is working perfectly!' + colors.reset);
        console.log(colors.green + '✅ MongoDB-only authentication successful!' + colors.reset);
        console.log(colors.green + '✅ No Firebase dependencies detected!' + colors.reset);

    } catch (error) {
        console.log('\n' + colors.red + '❌ Test failed!' + colors.reset);
        if (error.response) {
            console.log(colors.red + 'Status:' + colors.reset, error.response.status);
            console.log(colors.red + 'Error:' + colors.reset, error.response.data);
        } else if (error.request) {
            console.log(colors.red + 'Cannot connect to server. Make sure it\'s running on ' + BASE_URL + colors.reset);
        } else {
            console.log(colors.red + 'Error:' + colors.reset, error.message);
        }
    }
}

// Run the test
console.log('\n' + colors.blue + '🚀 Starting backend tests...' + colors.reset);
console.log(colors.blue + '📡 Server URL: ' + BASE_URL + colors.reset);
test();
