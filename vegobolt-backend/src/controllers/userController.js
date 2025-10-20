const User = require('../models/User');

/**
 * Get user profile by Firebase UID
 */
const getUserProfile = async (req, res) => {
    try {
        // req.user is set by authMiddleware
        const user = await User.findOne({ firebaseUid: req.user.uid });
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.status(200).json({
            success: true,
            data: { user }
        });
    } catch (error) {
        console.error('Get user profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching user profile',
            error: error.message
        });
    }
};

/**
 * Update user profile
 */
const updateUserProfile = async (req, res) => {
    try {
        const { firstName, lastName, displayName, phoneNumber, profilePicture } = req.body;
        
        // Find user by Firebase UID
        const user = await User.findOne({ firebaseUid: req.user.uid });
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Update allowed fields
        if (firstName) user.firstName = firstName;
        if (lastName) user.lastName = lastName;
        if (displayName) user.displayName = displayName;
        if (phoneNumber !== undefined) user.phoneNumber = phoneNumber;
        if (profilePicture !== undefined) user.profilePicture = profilePicture;
        
        await user.save();

        res.status(200).json({
            success: true,
            message: 'Profile updated successfully',
            data: { user }
        });
    } catch (error) {
        console.error('Update user profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Error updating user profile',
            error: error.message
        });
    }
};

/**
 * Delete user account
 */
const deleteUserAccount = async (req, res) => {
    try {
        // Find and delete user by Firebase UID
        const user = await User.findOneAndDelete({ firebaseUid: req.user.uid });
        
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.status(200).json({
            success: true,
            message: 'Account deleted successfully'
        });
    } catch (error) {
        console.error('Delete user account error:', error);
        res.status(500).json({
            success: false,
            message: 'Error deleting account',
            error: error.message
        });
    }
};

module.exports = {
    getUserProfile,
    updateUserProfile,
    deleteUserAccount
};