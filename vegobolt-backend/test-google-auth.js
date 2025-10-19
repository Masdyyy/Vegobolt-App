/**
 * Test Google Authentication Backend
 * 
 * This script tests the Google authentication endpoint.
 * You need a real Google ID token to test this properly.
 * 
 * To get a test ID token:
 * 1. Use Google OAuth 2.0 Playground: https://developers.google.com/oauthplayground/
 * 2. Or run the Flutter app and capture the token from logs
 * 3. Or use Postman with Google Sign-In
 */

const axios = require('axios');

// Configuration
const BASE_URL = process.env.API_URL || 'http://localhost:3000';
const TEST_ID_TOKEN = process.env.TEST_GOOGLE_ID_TOKEN || 'YOUR_TEST_ID_TOKEN_HERE';

async function testGoogleAuth() {
    console.log('🧪 Testing Google Authentication Endpoint\n');
    console.log(`📍 Base URL: ${BASE_URL}`);
    console.log(`🔑 Using test ID token: ${TEST_ID_TOKEN.substring(0, 20)}...\n`);

    try {
        console.log('📤 Sending request to /api/auth/google...\n');

        const response = await axios.post(`${BASE_URL}/api/auth/google`, {
            idToken: TEST_ID_TOKEN
        }, {
            headers: {
                'Content-Type': 'application/json'
            }
        });

        console.log('✅ SUCCESS! Response:\n');
        console.log(JSON.stringify(response.data, null, 2));
        
        if (response.data.success) {
            console.log('\n✨ Google authentication is working!');
            console.log(`👤 User: ${response.data.data.user.displayName}`);
            console.log(`📧 Email: ${response.data.data.user.email}`);
            console.log(`🆕 New User: ${response.data.data.isNewUser}`);
            console.log(`🔐 Token received: ${response.data.data.token.substring(0, 20)}...`);
        }

    } catch (error) {
        console.error('❌ ERROR!');
        
        if (error.response) {
            // The request was made and the server responded with a status code
            console.error('Status:', error.response.status);
            console.error('Response:', JSON.stringify(error.response.data, null, 2));
            
            if (error.response.status === 401) {
                console.error('\n💡 This is expected if you haven\'t provided a valid Google ID token.');
                console.error('To test properly:');
                console.error('1. Run the Flutter app');
                console.error('2. Add console.log in auth_service.dart to print the idToken');
                console.error('3. Copy the real token and set TEST_GOOGLE_ID_TOKEN env variable');
                console.error('4. Run this test again');
            } else if (error.response.status === 500) {
                console.error('\n💡 Server error. Check:');
                console.error('1. MongoDB connection');
                console.error('2. GOOGLE_CLIENT_ID_* values in .env');
                console.error('3. Backend server logs for details');
            }
        } else if (error.request) {
            // The request was made but no response was received
            console.error('No response received. Is the backend server running?');
            console.error('Start the server with: npm start');
        } else {
            // Something else happened
            console.error('Error:', error.message);
        }
    }
}

// Check if test token is provided
if (TEST_ID_TOKEN === 'YOUR_TEST_ID_TOKEN_HERE') {
    console.log('⚠️  No test ID token provided.');
    console.log('This test requires a real Google ID token.\n');
    console.log('Options to get a test token:\n');
    console.log('1. Use Google OAuth 2.0 Playground:');
    console.log('   https://developers.google.com/oauthplayground/');
    console.log('   - Select "Google OAuth2 API v2"');
    console.log('   - Authorize APIs');
    console.log('   - Exchange authorization code for tokens');
    console.log('   - Copy the ID token\n');
    console.log('2. Run the Flutter app with debug logging:');
    console.log('   - Add print(idToken) in auth_service.dart');
    console.log('   - Perform Google Sign-In');
    console.log('   - Copy the token from console\n');
    console.log('3. Set environment variable:');
    console.log('   $env:TEST_GOOGLE_ID_TOKEN="your-actual-token"');
    console.log('   node test-google-auth.js\n');
    
    console.log('For now, testing with invalid token to check endpoint...\n');
}

// Run the test
testGoogleAuth();
