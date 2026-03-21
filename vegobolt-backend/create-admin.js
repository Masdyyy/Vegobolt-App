/**
 * Script to create an admin@vegobolt user in MongoDB
 * Run this script to create an admin@vegobolt account for testing
 */

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import User model
const User = require('./src/models/User');

// MongoDB connection
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

// Create admin user
const createAdminUser = async () => {
    try {
        await connectDB();

        const adminEmail = 'vegobolt@gmail.com';
        const adminPassword = 'Pass@123';
        const adminDisplayName = 'Vegobolt Admin';
        const adminFirstName = 'Vegobolt';
        const adminLastName = 'Admin';

        // Check if admin already exists
        const existingAdmin = await User.findByEmail(adminEmail);
        if (existingAdmin) {
            console.log('⚠️  Admin user already exists!');
            console.log(`Email: ${adminEmail}`);
            console.log('🔄 Updating admin user with new password and settings...');
            
            // Hash the new password
            const hashedPassword = await bcrypt.hash(adminPassword, 10);
            
            // Update user to admin with new password
            existingAdmin.password = hashedPassword;
            existingAdmin.isAdmin = true;
            if (!existingAdmin.firstName) existingAdmin.firstName = adminFirstName;
            if (!existingAdmin.lastName) existingAdmin.lastName = adminLastName;
            existingAdmin.isEmailVerified = true; // Also verify email
            existingAdmin.isActive = true; // Make sure active
            await existingAdmin.save();
            
            console.log('✅ Admin user updated successfully!');
            console.log('=====================================');
            console.log(`Email: ${adminEmail}`);
            console.log(`Password: ${adminPassword}`);
            console.log('=====================================');
            console.log('⚠️  IMPORTANT: Change the password after first login!');
            
            await mongoose.connection.close();
            return;
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(adminPassword, 10);

        // Create admin user
        const adminUser = new User({
            email: adminEmail,
            password: hashedPassword,
            firstName: adminFirstName,
            lastName: adminLastName,
            displayName: adminDisplayName,
            isAdmin: true,
            isEmailVerified: true, // Auto-verify admin
            isActive: true,
        });

        await adminUser.save();

        console.log('✅ Admin user created successfully!');
        console.log('=====================================');
        console.log(`Email: ${adminEmail}`);
        console.log(`Password: ${adminPassword}`);
        console.log('=====================================');
        console.log('⚠️  IMPORTANT: Change the password after first login!');

        await mongoose.connection.close();
        console.log('✅ Database connection closed.');
        
    } catch (error) {
        console.error('❌ Error creating admin user:', error);
        process.exit(1);
    }
};

// Run the script
createAdminUser();
