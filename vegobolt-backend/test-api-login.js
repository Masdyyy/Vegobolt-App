/**
 * Test script to verify backend returns isAdmin correctly
 */

const axios = require('axios');

const testAdminLogin = async () => {
    try {
        console.log('🧪 Testing Admin Login via API...\n');
        
        const response = await axios.post('http://localhost:3000/api/auth/login', {
            email: 'admin@vegobolt.com',
            password: 'Admin@123'
        }, {
            headers: {
                'Content-Type': 'application/json'
            }
        });

        console.log('✅ Login Response Status:', response.status);
        console.log('✅ Success:', response.data.success);
        console.log('✅ Message:', response.data.message);
        console.log('\n📦 User Data:');
        console.log('   Email:', response.data.data.user.email);
        console.log('   Display Name:', response.data.data.user.displayName);
        console.log('   Is Admin:', response.data.data.user.isAdmin);
        console.log('   User ID:', response.data.data.user.id);
        
        console.log('\n🔐 Token:', response.data.data.token.substring(0, 50) + '...');
        
        if (response.data.data.user.isAdmin === true) {
            console.log('\n✅ BACKEND IS RETURNING isAdmin: true correctly!');
        } else {
            console.log('\n❌ WARNING: Backend is NOT returning isAdmin: true!');
            console.log('   Actual value:', response.data.data.user.isAdmin);
            console.log('   Type:', typeof response.data.data.user.isAdmin);
        }

    } catch (error) {
        console.error('❌ Error testing login:');
        if (error.response) {
            console.error('   Status:', error.response.status);
            console.error('   Message:', error.response.data.message);
        } else {
            console.error('   ', error.message);
        }
    }
};

testAdminLogin();
