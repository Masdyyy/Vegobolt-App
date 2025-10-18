const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true,
    },
    password: {
        type: String,
        required: true,
    },
    displayName: {
        type: String,
        required: true,
        trim: true,
    },
    phoneNumber: {
        type: String,
        default: null,
    },
    profilePicture: {
        type: String,
        default: null,
    },
    isActive: {
        type: Boolean,
        default: true,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
    updatedAt: {
        type: Date,
        default: Date.now,
    },
});

// Update the updatedAt timestamp before saving
userSchema.pre('save', function(next) {
    this.updatedAt = Date.now();
    next();
});

// Method to find a user by email
userSchema.statics.findByEmail = function(email) {
    return this.findOne({ email: email.toLowerCase() });
};

// Method to create a new user
userSchema.statics.createUser = function(userData) {
    const user = new this(userData);
    return user.save();
};

// Method to exclude password from JSON responses
userSchema.methods.toJSON = function() {
    const user = this.toObject();
    delete user.password;
    return user;
};

const User = mongoose.model('User', userSchema);

module.exports = User;