/**
 * Script to test admin login and verify password
 */

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const User = require('./src/models/User');

const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/vegobolt', {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
        return conn;
    } catch (error) {
        console.error('❌ MongoDB connection error:', error);
        process.exit(1);
    }
};

const testAdminLogin = async () => {
    try {
        await connectDB();

        const adminEmail = 'admin@vegobolt.com';
        const testPassword = 'Admin@123';

        console.log('\n🧪 Testing Admin Login...');
        console.log('================================');
        console.log(`Email: ${adminEmail}`);
        console.log(`Testing Password: ${testPassword}\n`);

        // Find admin user
        const user = await User.findByEmail(adminEmail);
        
        if (!user) {
            console.log('❌ Admin user not found!');
            await mongoose.connection.close();
            return;
        }

        console.log('✅ Admin user found in database');
        console.log(`   Display Name: ${user.displayName}`);
        console.log(`   Is Admin: ${user.isAdmin}`);
        console.log(`   Is Active: ${user.isActive}`);
        console.log(`   Email Verified: ${user.isEmailVerified}`);
        console.log(`   Hashed Password: ${user.password.substring(0, 30)}...`);

        // Test password comparison
        console.log('\n🔐 Testing password comparison...');
        const isPasswordValid = await bcrypt.compare(testPassword, user.password);
        
        if (isPasswordValid) {
            console.log('✅ Password is CORRECT!');
            console.log('✅ Admin login should work!\n');
        } else {
            console.log('❌ Password is INCORRECT!');
            console.log('⚠️  The password in the database does not match "Admin@123"');
            console.log('\n🔄 Would you like to reset the password? (Run create-admin.js to reset)\n');
        }

        await mongoose.connection.close();
        console.log('✅ Test completed. Connection closed.');
        
    } catch (error) {
        console.error('❌ Error testing admin login:', error);
        process.exit(1);
    }
};

// Run the test
testAdminLogin();
