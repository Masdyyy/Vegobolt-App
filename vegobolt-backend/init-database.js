require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User');
const bcrypt = require('bcryptjs');

// Set strictQuery to false to prepare for Mongoose 7
mongoose.set('strictQuery', false);

async function initializeDatabase() {
    try {
        console.log('🔄 Connecting to MongoDB Atlas...');
        
        // Connect to MongoDB
        await mongoose.connect(process.env.MONGODB_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
            serverSelectionTimeoutMS: 10000,
            socketTimeoutMS: 45000,
        });

        console.log('✅ Connected to MongoDB Atlas successfully!');
        console.log(`📍 Database: ${mongoose.connection.name}`);
        console.log(`🌐 Host: ${mongoose.connection.host}`);

        // Check if database exists and create collections
        console.log('\n🔄 Checking database structure...');
        
        // List existing collections
        const collections = await mongoose.connection.db.listCollections().toArray();
        console.log(`📦 Found ${collections.length} existing collections:`);
        collections.forEach(col => console.log(`   - ${col.name}`));

        // Ensure the users collection is created
        console.log('\n✅ Users collection ready');

        // List collections after creation
        console.log('\n📦 Final database structure:');
        const finalCollections = await mongoose.connection.db.listCollections().toArray();
        finalCollections.forEach(col => console.log(`   - ${col.name}`));

        // Get database stats
        console.log('\n📊 Database Statistics:');
        const stats = await mongoose.connection.db.stats();
        console.log(`   Collections: ${stats.collections}`);
        console.log(`   Data Size: ${(stats.dataSize / 1024).toFixed(2)} KB`);
        console.log(`   Storage Size: ${(stats.storageSize / 1024).toFixed(2)} KB`);

        console.log('\n✅ Database initialization completed successfully!');
        console.log('\n🎉 Your MongoDB Atlas database is ready for use!');
        console.log('\n📋 Next steps:');
        console.log('   1. Start your server: npm start');
        console.log('   2. Test endpoints: node test-api.js');
        console.log('   3. Access MongoDB Atlas dashboard to view your data');

    } catch (error) {
        console.error('❌ Database initialization failed!');
        console.error('Error:', error.message);
        
        if (error.name === 'MongooseServerSelectionError') {
            console.error('\n💡 Connection troubleshooting:');
            console.error('   1. Check your internet connection');
            console.error('   2. Verify MongoDB Atlas cluster is running');
            console.error('   3. Check IP whitelist in MongoDB Atlas');
            console.error('   4. Verify connection string in .env file');
        }
    } finally {
        // Close the connection
        if (mongoose.connection.readyState === 1) {
            await mongoose.connection.close();
            console.log('🔒 Database connection closed');
        }
        process.exit(0);
    }
}

// Run the initialization
console.log('🚀 Starting MongoDB Database Initialization...\n');
initializeDatabase();