const mongoose = require('mongoose');
const User = require('../models/User');
const mongodbConfig = require('../config/mongodb');

// Connect to MongoDB
mongoose.connect(mongodbConfig.connectionString, mongodbConfig.options)
    .then(() => console.log('MongoDB connected'))
    .catch(err => console.error('MongoDB connection error:', err));

// Function to create a new user
const createUser = async (userData) => {
    const user = new User(userData);
    return await user.save();
};

// Function to find a user by ID
const findUserById = async (userId) => {
    return await User.findById(userId);
};

// Function to find a user by email
const findUserByEmail = async (email) => {
    return await User.findOne({ email });
};

// Function to update a user by ID
const updateUserById = async (userId, updateData) => {
    return await User.findByIdAndUpdate(userId, updateData, { new: true });
};

// Function to delete a user by ID
const deleteUserById = async (userId) => {
    return await User.findByIdAndDelete(userId);
};

module.exports = {
    createUser,
    findUserById,
    findUserByEmail,
    updateUserById,
    deleteUserById
};