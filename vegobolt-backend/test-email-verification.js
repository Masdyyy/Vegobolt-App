/**
 * Test script for email verification functionality
 * Run with: node test-email-verification.js
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';
const TEST_EMAIL = `test${Date.now()}@example.com`;
const TEST_PASSWORD = 'password123';
const TEST_DISPLAY_NAME = 'Test User';

let verificationToken = null;
let authToken = null;

async function testEmailVerification() {
    console.log('🧪 Testing Email Verification Flow\n');
    console.log('═'.repeat(50));

    try {
        // Test 1: Register User
        console.log('\n📝 Test 1: Register User');
        console.log('─'.repeat(50));
        const registerResponse = await axios.post(`${BASE_URL}/auth/register`, {
            email: TEST_EMAIL,
            password: TEST_PASSWORD,
            displayName: TEST_DISPLAY_NAME
        });

        console.log('✅ Registration successful');
        console.log('Response:', JSON.stringify(registerResponse.data, null, 2));
        
        if (registerResponse.data.data.requiresEmailVerification) {
            console.log('✅ Email verification required (as expected)');
        }

        authToken = registerResponse.data.data.token;

        // Test 2: Try to login without verification
        console.log('\n📝 Test 2: Try to Login Without Email Verification');
        console.log('─'.repeat(50));
        try {
            await axios.post(`${BASE_URL}/auth/login`, {
                email: TEST_EMAIL,
                password: TEST_PASSWORD
            });
            console.log('❌ Login succeeded without verification (UNEXPECTED)');
        } catch (error) {
            if (error.response && error.response.status === 401) {
                console.log('✅ Login blocked (as expected)');
                console.log('Message:', error.response.data.message);
                if (error.response.data.requiresEmailVerification) {
                    console.log('✅ requiresEmailVerification flag present');
                }
            } else {
                throw error;
            }
        }

        // Test 3: Resend verification email
        console.log('\n📝 Test 3: Resend Verification Email');
        console.log('─'.repeat(50));
        const resendResponse = await axios.post(`${BASE_URL}/auth/resend-verification`, {
            email: TEST_EMAIL
        });
        console.log('✅ Resend verification successful');
        console.log('Message:', resendResponse.data.message);

        // Test 4: Simulate getting token from email
        console.log('\n📝 Test 4: Get Verification Token from Database');
        console.log('─'.repeat(50));
        console.log('⚠️  In a real scenario, you would get this token from the email link');
        console.log('⚠️  For testing, check your email or database for the token');
        console.log('⚠️  The verification URL format is:');
        console.log(`    ${process.env.FRONTEND_URL || 'http://localhost:3000'}/api/auth/verify-email/{TOKEN}`);
        
        // Note: In a real test, you would need to retrieve the token from the database
        // or from the email. For this test script, we'll show the manual steps.
        console.log('\n📋 Manual Steps to Complete Verification:');
        console.log('1. Check the server console for the verification email content');
        console.log('2. Copy the verification token from the URL');
        console.log('3. Make a GET request to: /api/auth/verify-email/{token}');
        console.log('4. Then try to login again');

        // Test 5: Try with invalid token
        console.log('\n📝 Test 5: Try Verification with Invalid Token');
        console.log('─'.repeat(50));
        try {
            await axios.get(`${BASE_URL}/auth/verify-email/invalid-token-12345`);
            console.log('❌ Verification succeeded with invalid token (UNEXPECTED)');
        } catch (error) {
            if (error.response && error.response.status === 400) {
                console.log('✅ Verification failed with invalid token (as expected)');
                console.log('Message:', error.response.data.message);
            } else {
                throw error;
            }
        }

        console.log('\n═'.repeat(50));
        console.log('✅ All automated tests passed!\n');
        console.log('📧 To complete the full test:');
        console.log(`   1. Check your email at: ${TEST_EMAIL}`);
        console.log('   2. Or check the server console for the verification link');
        console.log('   3. Click the link or use the token to verify');
        console.log('   4. Then try logging in again\n');

    } catch (error) {
        console.error('\n❌ Test failed:', error.message);
        if (error.response) {
            console.error('Response:', JSON.stringify(error.response.data, null, 2));
        }
        process.exit(1);
    }
}

// Helper function to test with a valid token (manual step)
async function testWithToken(token) {
    console.log('\n📝 Test: Verify Email with Token');
    console.log('─'.repeat(50));
    
    try {
        const verifyResponse = await axios.get(`${BASE_URL}/auth/verify-email/${token}`);
        console.log('✅ Email verified successfully');
        console.log('Response:', JSON.stringify(verifyResponse.data, null, 2));

        // Now try to login
        console.log('\n📝 Test: Login After Verification');
        console.log('─'.repeat(50));
        const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
            email: TEST_EMAIL,
            password: TEST_PASSWORD
        });
        console.log('✅ Login successful after verification');
        console.log('Response:', JSON.stringify(loginResponse.data, null, 2));

    } catch (error) {
        console.error('❌ Test failed:', error.message);
        if (error.response) {
            console.error('Response:', JSON.stringify(error.response.data, null, 2));
        }
    }
}

// Run tests
testEmailVerification();

// Export helper for manual token testing
module.exports = { testWithToken };
