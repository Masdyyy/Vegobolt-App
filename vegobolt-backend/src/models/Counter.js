const mongoose = require('mongoose');

const counterSchema = new mongoose.Schema(
    {
        key: {
            type: String,
            required: true,
            unique: true,
            trim: true,
        },
        seq: {
            type: Number,
            required: true,
            default: 0,
        },
    },
    { timestamps: true }
);

const Counter = mongoose.model('Counter', counterSchema);

module.exports = Counter;
