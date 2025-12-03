const Maintenance = require('../models/maintenance');

// Create a maintenance entry
const createMaintenance = async (req, res, next) => {
    try {
        const { title, machineId, location, scheduledDate, priority } = req.body;

        const maintenance = new Maintenance({
            title,
            machineId,
            location,
            scheduledDate: scheduledDate ? new Date(scheduledDate) : null,
            priority: priority || 'Low',
            createdBy: req.user?.id || null,
        });

        const saved = await maintenance.save();
        res.status(201).json({ success: true, data: saved, message: 'Maintenance scheduled' });
    } catch (error) {
        next(error);
    }
};

// List all maintenance entries (optionally filter by status)
const listMaintenance = async (req, res, next) => {
    try {
        const { status } = req.query;
        const filter = {};
        if (status) filter.status = status;

        const items = await Maintenance.find(filter).sort({ scheduledDate: -1 });
        res.json({ success: true, data: items });
    } catch (error) {
        next(error);
    }
};

// Update maintenance entry
const updateMaintenance = async (req, res, next) => {
    try {
        const { id } = req.params;
        const updates = req.body;
        if (updates.scheduledDate) updates.scheduledDate = new Date(updates.scheduledDate);

        const updated = await Maintenance.findByIdAndUpdate(id, updates, { new: true });
        if (!updated) return res.status(404).json({ success: false, message: 'Not found' });
        res.json({ success: true, data: updated });
    } catch (error) {
        next(error);
    }
};

// Delete maintenance entry
const deleteMaintenance = async (req, res, next) => {
    try {
        const { id } = req.params;
        const deleted = await Maintenance.findByIdAndDelete(id);
        if (!deleted) return res.status(404).json({ success: false, message: 'Not found' });
        res.json({ success: true, message: 'Deleted' });
    } catch (error) {
        next(error);
    }
};

// Mark as resolved
const resolveMaintenance = async (req, res, next) => {
    try {
        const { id } = req.params;
        const updated = await Maintenance.findByIdAndUpdate(id, { status: 'Resolved' }, { new: true });
        if (!updated) return res.status(404).json({ success: false, message: 'Not found' });
        res.json({ success: true, data: updated });
    } catch (error) {
        next(error);
    }
};

module.exports = {
    createMaintenance,
    listMaintenance,
    updateMaintenance,
    deleteMaintenance,
    resolveMaintenance,
};
