/**
 * Test script for password reset functionality
 * 
 * This script tests:
 * 1. Requesting a password reset
 * 2. Resetting password with token
 * 
 * Usage: node test-password-reset.js
 */

const axios = require('axios');

// Configuration
const BASE_URL = 'http://localhost:3000';
const TEST_EMAIL = 'test@example.com'; // Change this to a real email in your database
const NEW_PASSWORD = 'newPassword123';

// Colors for console output
const colors = {
    reset: '\x1b[0m',
    green: '\x1b[32m',
    red: '\x1b[31m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
};

function log(message, color = 'reset') {
    console.log(`${colors[color]}${message}${colors.reset}`);
}

async function testPasswordReset() {
    log('\n🔐 Testing Password Reset Functionality\n', 'blue');

    try {
        // Step 1: Request password reset
        log('1️⃣ Requesting password reset...', 'yellow');
        const resetRequest = await axios.post(`${BASE_URL}/api/auth/password-reset`, {
            email: TEST_EMAIL
        });

        if (resetRequest.data.success) {
            log('✅ Password reset request successful!', 'green');
            log(`   Message: ${resetRequest.data.message}`, 'green');
        } else {
            log('❌ Password reset request failed!', 'red');
            log(`   Message: ${resetRequest.data.message}`, 'red');
            return;
        }

        // Note: In a real scenario, you would get the token from the email
        // For this test, you need to manually retrieve it from the database
        log('\n⚠️  Note: To complete the test, you need to:', 'yellow');
        log('   1. Check the email inbox for the reset link', 'yellow');
        log('   2. Extract the token from the URL', 'yellow');
        log('   3. Use the token to test the reset endpoint', 'yellow');
        log('\n   Example:', 'yellow');
        log(`   POST ${BASE_URL}/api/auth/reset-password`, 'yellow');
        log('   Body: { "token": "YOUR_TOKEN", "newPassword": "newPassword123" }', 'yellow');

        // Step 2: Test reset password endpoint (you need to provide a real token)
        log('\n2️⃣ To test password reset with token:', 'yellow');
        log('   Run this command with a real token from the email:', 'yellow');
        log(`   curl -X POST ${BASE_URL}/api/auth/reset-password \\`, 'yellow');
        log('     -H "Content-Type: application/json" \\', 'yellow');
        log('     -d \'{"token":"YOUR_TOKEN_HERE","newPassword":"newPassword123"}\'', 'yellow');

        log('\n✨ Test completed! Check your email for the reset link.', 'green');

    } catch (error) {
        log('\n❌ Test failed!', 'red');
        if (error.response) {
            log(`   Status: ${error.response.status}`, 'red');
            log(`   Message: ${error.response.data.message || 'Unknown error'}`, 'red');
        } else if (error.request) {
            log('   No response from server. Is it running?', 'red');
            log(`   Check if server is running on ${BASE_URL}`, 'red');
        } else {
            log(`   Error: ${error.message}`, 'red');
        }
    }
}

// Test with token (if provided as command line argument)
async function testResetWithToken(token) {
    log('\n🔐 Testing Password Reset with Token\n', 'blue');

    try {
        const resetResponse = await axios.post(`${BASE_URL}/api/auth/reset-password`, {
            token: token,
            newPassword: NEW_PASSWORD
        });

        if (resetResponse.data.success) {
            log('✅ Password reset successful!', 'green');
            log(`   Message: ${resetResponse.data.message}`, 'green');
            log('\n   You can now login with:', 'green');
            log(`   Email: ${TEST_EMAIL}`, 'green');
            log(`   Password: ${NEW_PASSWORD}`, 'green');
        } else {
            log('❌ Password reset failed!', 'red');
            log(`   Message: ${resetResponse.data.message}`, 'red');
        }

    } catch (error) {
        log('\n❌ Reset failed!', 'red');
        if (error.response) {
            log(`   Status: ${error.response.status}`, 'red');
            log(`   Message: ${error.response.data.message || 'Unknown error'}`, 'red');
        } else {
            log(`   Error: ${error.message}`, 'red');
        }
    }
}

// Run tests
const args = process.argv.slice(2);

if (args.length > 0 && args[0] === '--with-token') {
    if (args.length < 2) {
        log('❌ Error: Token required', 'red');
        log('Usage: node test-password-reset.js --with-token YOUR_TOKEN_HERE', 'yellow');
        process.exit(1);
    }
    testResetWithToken(args[1]);
} else {
    log('📧 Make sure you have a test user with email: ' + TEST_EMAIL, 'yellow');
    log('   If not, update TEST_EMAIL in this script\n', 'yellow');
    testPasswordReset();
}
