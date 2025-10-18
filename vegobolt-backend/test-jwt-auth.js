/**
 * Test Script for JWT Authentication
 * Tests all authentication endpoints after Firebase removal
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000';
let authToken = null;
let userId = null;

// Test data
const testUser = {
    email: `test${Date.now()}@example.com`, // Unique email for each test
    password: 'testPassword123',
    displayName: 'Test User'
};

// Helper function to log test results
function logTest(testName, success, data = null) {
    const icon = success ? '✅' : '❌';
    console.log(`\n${icon} ${testName}`);
    if (data) {
        console.log(JSON.stringify(data, null, 2));
    }
}

// Helper function to make requests
async function makeRequest(method, endpoint, data = null, token = null) {
    try {
        const config = {
            method,
            url: `${BASE_URL}${endpoint}`,
            headers: {
                'Content-Type': 'application/json'
            }
        };

        if (token) {
            config.headers['Authorization'] = `Bearer ${token}`;
        }

        if (data) {
            config.data = data;
        }

        const response = await axios(config);
        return { success: true, data: response.data, status: response.status };
    } catch (error) {
        return {
            success: false,
            error: error.response?.data || error.message,
            status: error.response?.status
        };
    }
}

// Test 1: Health Check
async function testHealthCheck() {
    console.log('\n========================================');
    console.log('TEST 1: Health Check');
    console.log('========================================');
    
    const result = await makeRequest('GET', '/health');
    logTest('Health Check', result.success, result.data);
    return result.success;
}

// Test 2: User Registration
async function testRegistration() {
    console.log('\n========================================');
    console.log('TEST 2: User Registration');
    console.log('========================================');
    console.log('Test Data:', testUser);
    
    const result = await makeRequest('POST', '/api/auth/register', testUser);
    
    if (result.success) {
        authToken = result.data.data?.token;
        userId = result.data.data?.user?.id;
        console.log('\n📝 Token received:', authToken?.substring(0, 50) + '...');
        console.log('📝 User ID:', userId);
    }
    
    logTest('User Registration', result.success, result.data);
    return result.success;
}

// Test 3: Login with Correct Credentials
async function testLogin() {
    console.log('\n========================================');
    console.log('TEST 3: Login with Correct Credentials');
    console.log('========================================');
    
    const loginData = {
        email: testUser.email,
        password: testUser.password
    };
    
    const result = await makeRequest('POST', '/api/auth/login', loginData);
    
    if (result.success) {
        authToken = result.data.data?.token;
        console.log('\n📝 New token received:', authToken?.substring(0, 50) + '...');
    }
    
    logTest('Login', result.success, result.data);
    return result.success;
}

// Test 4: Login with Wrong Password
async function testLoginWrongPassword() {
    console.log('\n========================================');
    console.log('TEST 4: Login with Wrong Password (Should Fail)');
    console.log('========================================');
    
    const loginData = {
        email: testUser.email,
        password: 'wrongpassword'
    };
    
    const result = await makeRequest('POST', '/api/auth/login', loginData);
    
    // This should fail, so success = !result.success
    const testPassed = !result.success && result.status === 401;
    logTest('Wrong Password Rejected', testPassed, result.error);
    return testPassed;
}

// Test 5: Verify Token
async function testVerifyToken() {
    console.log('\n========================================');
    console.log('TEST 5: Verify JWT Token');
    console.log('========================================');
    
    const result = await makeRequest('POST', '/api/auth/verify-token', null, authToken);
    logTest('Token Verification', result.success, result.data);
    return result.success;
}

// Test 6: Get User Profile (Protected Route)
async function testGetProfile() {
    console.log('\n========================================');
    console.log('TEST 6: Get User Profile (Protected Route)');
    console.log('========================================');
    
    const result = await makeRequest('GET', '/api/auth/profile', null, authToken);
    logTest('Get Profile', result.success, result.data);
    return result.success;
}

// Test 7: Access Protected Route Without Token
async function testProtectedRouteWithoutToken() {
    console.log('\n========================================');
    console.log('TEST 7: Access Protected Route Without Token (Should Fail)');
    console.log('========================================');
    
    const result = await makeRequest('GET', '/api/auth/profile', null, null);
    
    // This should fail, so success = !result.success
    const testPassed = !result.success && result.status === 401;
    logTest('Access Denied Without Token', testPassed, result.error);
    return testPassed;
}

// Test 8: Access Protected Route With Invalid Token
async function testProtectedRouteWithInvalidToken() {
    console.log('\n========================================');
    console.log('TEST 8: Access Protected Route With Invalid Token (Should Fail)');
    console.log('========================================');
    
    const result = await makeRequest('GET', '/api/auth/profile', null, 'invalid-token-123');
    
    // This should fail, so success = !result.success
    const testPassed = !result.success && result.status === 403;
    logTest('Invalid Token Rejected', testPassed, result.error);
    return testPassed;
}

// Test 9: Registration with Missing Fields
async function testRegistrationMissingFields() {
    console.log('\n========================================');
    console.log('TEST 9: Registration with Missing Fields (Should Fail)');
    console.log('========================================');
    
    const incompleteUser = {
        email: 'incomplete@test.com'
        // Missing password and displayName
    };
    
    const result = await makeRequest('POST', '/api/auth/register', incompleteUser);
    
    // This should fail, so success = !result.success
    const testPassed = !result.success && result.status === 400;
    logTest('Incomplete Registration Rejected', testPassed, result.error);
    return testPassed;
}

// Test 10: Duplicate Registration
async function testDuplicateRegistration() {
    console.log('\n========================================');
    console.log('TEST 10: Duplicate Registration (Should Fail)');
    console.log('========================================');
    
    const result = await makeRequest('POST', '/api/auth/register', testUser);
    
    // This should fail because user already exists
    const testPassed = !result.success && result.status === 400;
    logTest('Duplicate Email Rejected', testPassed, result.error);
    return testPassed;
}

// Test 11: Logout
async function testLogout() {
    console.log('\n========================================');
    console.log('TEST 11: Logout');
    console.log('========================================');
    
    const result = await makeRequest('POST', '/api/auth/logout', null, authToken);
    logTest('Logout', result.success, result.data);
    return result.success;
}

// Main test runner
async function runAllTests() {
    console.log('\n');
    console.log('╔════════════════════════════════════════════════════════╗');
    console.log('║   JWT Authentication Test Suite                        ║');
    console.log('║   Testing MongoDB-Only Authentication (No Firebase)    ║');
    console.log('╚════════════════════════════════════════════════════════╝');
    console.log(`\nBase URL: ${BASE_URL}`);
    console.log(`Timestamp: ${new Date().toISOString()}`);

    const results = [];

    try {
        // Run all tests in sequence
        results.push({ name: 'Health Check', passed: await testHealthCheck() });
        results.push({ name: 'User Registration', passed: await testRegistration() });
        results.push({ name: 'User Login', passed: await testLogin() });
        results.push({ name: 'Wrong Password', passed: await testLoginWrongPassword() });
        results.push({ name: 'Verify Token', passed: await testVerifyToken() });
        results.push({ name: 'Get Profile', passed: await testGetProfile() });
        results.push({ name: 'No Token Access', passed: await testProtectedRouteWithoutToken() });
        results.push({ name: 'Invalid Token', passed: await testProtectedRouteWithInvalidToken() });
        results.push({ name: 'Missing Fields', passed: await testRegistrationMissingFields() });
        results.push({ name: 'Duplicate Email', passed: await testDuplicateRegistration() });
        results.push({ name: 'Logout', passed: await testLogout() });

        // Print summary
        console.log('\n');
        console.log('╔════════════════════════════════════════════════════════╗');
        console.log('║   TEST SUMMARY                                         ║');
        console.log('╚════════════════════════════════════════════════════════╝');
        
        results.forEach((result, index) => {
            const icon = result.passed ? '✅' : '❌';
            console.log(`${icon} ${(index + 1).toString().padStart(2, '0')}. ${result.name}`);
        });

        const totalTests = results.length;
        const passedTests = results.filter(r => r.passed).length;
        const failedTests = totalTests - passedTests;

        console.log('\n' + '='.repeat(60));
        console.log(`Total Tests: ${totalTests}`);
        console.log(`✅ Passed: ${passedTests}`);
        console.log(`❌ Failed: ${failedTests}`);
        console.log(`Success Rate: ${((passedTests / totalTests) * 100).toFixed(1)}%`);
        console.log('='.repeat(60));

        if (passedTests === totalTests) {
            console.log('\n🎉 ALL TESTS PASSED! Your JWT authentication is working perfectly!');
        } else {
            console.log('\n⚠️  Some tests failed. Please check the errors above.');
        }

    } catch (error) {
        console.error('\n❌ Test suite error:', error.message);
        console.error('Make sure the server is running on', BASE_URL);
    }
}

// Check if server is running before starting tests
async function checkServer() {
    try {
        await axios.get(`${BASE_URL}/health`);
        return true;
    } catch (error) {
        console.error('❌ Cannot connect to server at', BASE_URL);
        console.error('Please make sure the server is running with: npm start');
        return false;
    }
}

// Start tests
(async () => {
    const serverRunning = await checkServer();
    if (serverRunning) {
        await runAllTests();
    }
    process.exit(0);
})();
