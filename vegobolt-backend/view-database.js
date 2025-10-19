require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User');

// Set strictQuery to false to prepare for Mongoose 7
mongoose.set('strictQuery', false);

async function viewDatabase() {
    try {
        console.log('🔍 Connecting to view database...\n');
        
        // Connect to MongoDB
        await mongoose.connect(process.env.MONGODB_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
            serverSelectionTimeoutMS: 10000,
            socketTimeoutMS: 45000,
        });

        console.log('✅ Connected to MongoDB Atlas');
        console.log(`📍 Database: ${mongoose.connection.name}`);
        console.log(`🌐 Host: ${mongoose.connection.host}\n`);

        // Show database statistics
        console.log('📊 Database Statistics:');
        const stats = await mongoose.connection.db.stats();
        console.log(`   Database Name: ${stats.db}`);
        console.log(`   Collections: ${stats.collections}`);
        console.log(`   Documents: ${stats.objects}`);
        console.log(`   Data Size: ${(stats.dataSize / 1024).toFixed(2)} KB`);
        console.log(`   Storage Size: ${(stats.storageSize / 1024).toFixed(2)} KB\n`);

        // List all collections
        console.log('📦 Collections:');
        const collections = await mongoose.connection.db.listCollections().toArray();
        collections.forEach(col => {
            console.log(`   - ${col.name} (Type: ${col.type})`);
        });

        // Show users collection data
        console.log('\n👥 Users Collection:');
        const users = await User.find({}).select('-password');
        console.log(`   Total Users: ${users.length}\n`);
        
        if (users.length > 0) {
            users.forEach((user, index) => {
                console.log(`   ${index + 1}. ${user.displayName} (${user.email})`);
                console.log(`      User ID: ${user._id}`);
                console.log(`      Firebase UID: ${user.firebaseUid}`);
                console.log(`      Active: ${user.isActive}`);
                console.log(`      Admin: ${user.isAdmin || false}`);
                console.log(`      Email Verified: ${user.isEmailVerified}`);
                console.log(`      Created: ${user.createdAt.toISOString()}`);
                console.log(`      Updated: ${user.updatedAt.toISOString()}\n`);
            });
        } else {
            console.log('   No users found in the database.\n');
        }

        // Show indexes
        console.log('🔍 Database Indexes:');
        const indexes = await User.collection.getIndexes();
        Object.keys(indexes).forEach(indexName => {
            console.log(`   - ${indexName}: ${JSON.stringify(indexes[indexName])}`);
        });

        console.log('\n✅ Database view completed!');

    } catch (error) {
        console.error('❌ Error viewing database:', error.message);
    } finally {
        // Close the connection
        if (mongoose.connection.readyState === 1) {
            await mongoose.connection.close();
            console.log('\n🔒 Database connection closed');
        }
        process.exit(0);
    }
}

// Run the database viewer
viewDatabase();