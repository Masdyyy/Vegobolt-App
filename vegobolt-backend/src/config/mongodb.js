const mongoose = require('mongoose');

// Set strictQuery to false to prepare for Mongoose 7
mongoose.set('strictQuery', false);

// Cache the connection for serverless functions
let cachedConnection = null;

const connectDB = async () => {
    // If we already have a cached connection, reuse it
    if (cachedConnection && mongoose.connection.readyState === 1) {
        console.log('Using cached MongoDB connection');
        return cachedConnection;
    }

    try {
        // Check if MONGODB_URI is set
        if (!process.env.MONGODB_URI) {
            console.error('❌ MONGODB_URI is not set in environment variables');
            throw new Error('MONGODB_URI is not configured');
        }

        const conn = await mongoose.connect(process.env.MONGODB_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
            serverSelectionTimeoutMS: 10000,
            socketTimeoutMS: 45000,
        });
        
        console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
        cachedConnection = conn;
        return conn;
    } catch (error) {
        console.error(`❌ MongoDB Connection Error: ${error.message}`);
        console.error('Please check your internet connection and MongoDB Atlas settings');
        
        // In serverless, don't exit the process - just throw the error
        if (process.env.NODE_ENV === 'production') {
            throw error;
        } else {
            process.exit(1);
        }
    }
};

module.exports = connectDB;