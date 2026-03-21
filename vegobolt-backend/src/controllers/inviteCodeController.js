const crypto = require('crypto');
const InviteCode = require('../models/InviteCode');
const connectDB = require('../config/mongodb');

function generateReadableCode(length = 10) {
    // Uppercase letters + digits, skip ambiguous chars
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    const bytes = crypto.randomBytes(length);
    let out = '';
    for (let i = 0; i < length; i++) {
        out += alphabet[bytes[i] % alphabet.length];
    }
    return out;
}

/**
 * Admin: generate a new invite/admin signup code
 * POST /api/invite-codes
 */
const generateInviteCode = async (req, res) => {
    try {
        await connectDB();

        const length = Number(req.body?.length) || 10;
        const expiresInDays = req.body?.expiresInDays;

        const normalizedLength = Math.min(Math.max(length, 6), 32);

        let expiresAt = null;
        if (expiresInDays !== undefined && expiresInDays !== null && expiresInDays !== '') {
            const days = Number(expiresInDays);
            if (!Number.isFinite(days) || days <= 0) {
                return res.status(400).json({
                    success: false,
                    message: 'expiresInDays must be a positive number'
                });
            }
            expiresAt = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
        }

        // Try a few times to avoid rare collisions
        for (let attempt = 0; attempt < 10; attempt++) {
            const code = generateReadableCode(normalizedLength);
            try {
                const invite = await InviteCode.create({
                    code,
                    createdBy: req.user?.id || null,
                    expiresAt,
                });

                return res.status(201).json({
                    success: true,
                    message: 'Invite code generated',
                    data: {
                        code: invite.code,
                        expiresAt: invite.expiresAt,
                        createdAt: invite.createdAt,
                    }
                });
            } catch (err) {
                // Duplicate key -> retry
                if (err && err.code === 11000) continue;
                throw err;
            }
        }

        return res.status(500).json({
            success: false,
            message: 'Failed to generate a unique code. Please try again.'
        });

    } catch (error) {
        console.error('Generate invite code error:', error);
        return res.status(500).json({
            success: false,
            message: 'Error generating invite code',
            error: error.message,
        });
    }
};

module.exports = {
    generateInviteCode,
};
