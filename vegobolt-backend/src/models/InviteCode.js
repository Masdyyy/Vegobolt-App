const mongoose = require('mongoose');

const inviteCodeSchema = new mongoose.Schema({
    code: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        uppercase: true,
        index: true,
    },
    isActive: {
        type: Boolean,
        default: true,
    },
    isUsed: {
        type: Boolean,
        default: false,
    },
    // Who generated this code
    createdBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        default: null,
    },
    // Claim info
    usedByUserId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        default: null,
    },
    usedByEmail: {
        type: String,
        default: null,
        trim: true,
        lowercase: true,
    },
    usedAt: {
        type: Date,
        default: null,
    },
    // Optional expiration
    expiresAt: {
        type: Date,
        default: null,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

inviteCodeSchema.statics.isValidForSignupQuery = function (code) {
    const now = new Date();
    return {
        code: String(code || '').trim().toUpperCase(),
        isActive: true,
        isUsed: false,
        $or: [{ expiresAt: null }, { expiresAt: { $gt: now } }],
    };
};

const InviteCode = mongoose.model('InviteCode', inviteCodeSchema);

module.exports = InviteCode;
