/**
 * Migration script to convert existing users from displayName to firstName/lastName
 * This script updates all users in the database that have displayName but no firstName/lastName
 */

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User');

const migrateUsers = async () => {
    try {
        // Connect to MongoDB
        console.log('🔄 Connecting to MongoDB...');
        await mongoose.connect(process.env.MONGODB_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log('✅ Connected to MongoDB\n');

        // Find all users that need migration (have displayName but no firstName)
        const usersToMigrate = await User.find({
            displayName: { $exists: true },
            firstName: { $exists: false }
        });

        console.log(`📊 Found ${usersToMigrate.length} users to migrate\n`);

        if (usersToMigrate.length === 0) {
            console.log('✅ No users need migration. All users already have firstName/lastName fields.');
            await mongoose.connection.close();
            return;
        }

        let successCount = 0;
        let errorCount = 0;

        // Migrate each user
        for (const user of usersToMigrate) {
            try {
                const displayName = user.displayName || '';
                const nameParts = displayName.trim().split(' ');
                
                // Parse first and last name
                const firstName = nameParts[0] || 'User';
                const lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : '';

                // Update user
                user.firstName = firstName;
                user.lastName = lastName;
                // Keep displayName as is for backward compatibility
                
                await user.save();
                
                console.log(`✅ Migrated: ${user.email}`);
                console.log(`   Display Name: "${displayName}"`);
                console.log(`   → First Name: "${firstName}", Last Name: "${lastName}"\n`);
                successCount++;
            } catch (error) {
                console.error(`❌ Error migrating user ${user.email}:`, error.message);
                errorCount++;
            }
        }

        console.log('\n📊 Migration Summary:');
        console.log(`   ✅ Successfully migrated: ${successCount}`);
        console.log(`   ❌ Errors: ${errorCount}`);
        console.log(`   📝 Total: ${usersToMigrate.length}`);

        // Close connection
        await mongoose.connection.close();
        console.log('\n✅ Database connection closed');

    } catch (error) {
        console.error('❌ Migration error:', error);
        await mongoose.connection.close();
        process.exit(1);
    }
};

// Run migration
console.log('🚀 Starting user migration...\n');
migrateUsers();
