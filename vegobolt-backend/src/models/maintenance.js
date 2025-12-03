const mongoose = require('mongoose');

const maintenanceSchema = new mongoose.Schema({
    title: { type: String, required: true },
    machineId: { type: String, required: true },
    location: { type: String, default: null },
    scheduledDate: { type: Date, default: null },
    priority: { type: String, enum: ['Low', 'Medium', 'High'], default: 'Low' },
    status: { type: String, enum: ['Scheduled', 'Resolved', 'Canceled'], default: 'Scheduled' },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
}, { timestamps: true });

module.exports = mongoose.model('Maintenance', maintenanceSchema);
