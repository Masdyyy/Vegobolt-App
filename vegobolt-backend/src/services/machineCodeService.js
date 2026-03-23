const Counter = require('../models/Counter');
const User = require('../models/User');

const MACHINE_COUNTER_KEY = 'machine';

async function getNextMachineCode() {
    // Try a few times in case existing data already contains VB-000X codes.
    for (let attempt = 0; attempt < 10; attempt += 1) {
        const doc = await Counter.findOneAndUpdate(
            { key: MACHINE_COUNTER_KEY },
            { $inc: { seq: 1 } },
            { new: true, upsert: true }
        );

        const seq = Number(doc?.seq || 1);
        const code = `VB-${String(seq).padStart(4, '0')}`;

        const exists = await User.exists({ machine: code });
        if (!exists) return code;
    }

    throw new Error('Failed to allocate a unique machine code');
}

module.exports = {
    getNextMachineCode,
};
