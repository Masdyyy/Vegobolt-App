/**
 * Backfill missing machine codes for existing users.
 *
 * Usage:
 *   node backfill-machine-codes.js
 *   node backfill-machine-codes.js --dry-run
 *
 * Notes:
 * - Assigns VB-0001, VB-0002, ... in createdAt order
 * - Starts after the max of:
 *   - current Counter("machine").seq
 *   - highest existing VB-xxxx already present in users
 * - Updates the Counter so future registrations continue correctly.
 */

const mongoose = require('mongoose');
require('dotenv').config();

const User = require('./src/models/User');
const Counter = require('./src/models/Counter');

const MACHINE_COUNTER_KEY = 'machine';

function parseArgs(argv) {
    const args = new Set(argv.slice(2));
    return {
        dryRun: args.has('--dry-run') || args.has('-n'),
    };
}

function parseMachineNumber(machine) {
    const match = /^VB-(\d+)$/.exec(String(machine || '').trim().toUpperCase());
    if (!match) return null;
    const n = Number(match[1]);
    return Number.isFinite(n) ? n : null;
}

function formatMachineCode(n) {
    return `VB-${String(n).padStart(4, '0')}`;
}

async function connect() {
    const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/vegobolt';
    const conn = await mongoose.connect(uri, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        serverSelectionTimeoutMS: 30000,
        connectTimeoutMS: 30000,
        socketTimeoutMS: 60000,
        maxPoolSize: 5,
    });
    return conn;
}

async function getHighestExistingMachineNumber() {
    const users = await User.find({ machine: { $regex: /^VB-\d+$/i } })
        .select('machine')
        .lean();

    let max = 0;
    for (const u of users) {
        const n = parseMachineNumber(u.machine);
        if (n != null && n > max) max = n;
    }
    return max;
}

async function main() {
    const { dryRun } = parseArgs(process.argv);

    console.log('🔧 Backfill machine codes');
    console.log(`Mode: ${dryRun ? 'DRY RUN' : 'WRITE'}`);

    await connect();

    const counterDoc = await Counter.findOne({ key: MACHINE_COUNTER_KEY }).lean();
    const counterSeq = Number(counterDoc?.seq || 0);

    const highestExisting = await getHighestExistingMachineNumber();
    let nextSeq = Math.max(counterSeq, highestExisting);

    const missingUsers = await User.find({
        $or: [
            { machine: null },
            { machine: '' },
            { machine: { $exists: false } },
        ],
    })
        .sort({ createdAt: 1, _id: 1 })
        .select('_id email createdAt')
        .lean();

    console.log(`Existing Counter seq: ${counterSeq}`);
    console.log(`Highest existing VB-xxxx: ${highestExisting}`);
    console.log(`Users missing machine: ${missingUsers.length}`);

    if (missingUsers.length === 0) {
        console.log('✅ Nothing to do.');
        await mongoose.connection.close();
        return;
    }

    const ops = [];
    for (const u of missingUsers) {
        nextSeq += 1;
        const code = formatMachineCode(nextSeq);

        ops.push({
            updateOne: {
                filter: { _id: u._id, $or: [{ machine: null }, { machine: '' }, { machine: { $exists: false } }] },
                update: { $set: { machine: code } },
            },
        });

        if (ops.length <= 5) {
            console.log(`- ${u.email || u._id.toString()} => ${code}`);
        }
    }

    if (missingUsers.length > 5) {
        console.log(`...and ${missingUsers.length - 5} more`);
    }

    if (dryRun) {
        console.log('🧪 Dry run complete (no changes written).');
        await mongoose.connection.close();
        return;
    }

    const result = await User.bulkWrite(ops, { ordered: true });
    console.log(`✅ Updated users: ${result.modifiedCount}`);

    await Counter.updateOne(
        { key: MACHINE_COUNTER_KEY },
        { $set: { seq: nextSeq } },
        { upsert: true }
    );
    console.log(`✅ Counter updated: ${nextSeq}`);

    await mongoose.connection.close();
    console.log('✅ Done.');
}

main().catch(async (err) => {
    console.error('❌ Backfill failed:', err);
    try {
        await mongoose.connection.close();
    } catch (_) {}
    process.exit(1);
});
