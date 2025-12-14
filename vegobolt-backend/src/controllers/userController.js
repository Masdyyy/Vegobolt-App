const User = require('../models/User');

/**
 * List all users (admin)
 */
const listUsers = async (req, res) => {
    try {
        const users = await User.find().select('-password');
        res.status(200).json({ success: true, data: users });
    } catch (error) {
        console.error('List users error:', error);
        res.status(500).json({ success: false, message: 'Error listing users', error: error.message });
    }
};

/**
 * Admin: delete user by id
 */
const adminDeleteUser = async (req, res) => {
    try {
        const { id } = req.params;
        const user = await User.findByIdAndDelete(id);
        if (!user) return res.status(404).json({ success: false, message: 'User not found' });
        res.status(200).json({ success: true, message: 'User deleted' });
    } catch (error) {
        console.error('Admin delete user error:', error);
        res.status(500).json({ success: false, message: 'Error deleting user', error: error.message });
    }
};

/**
 * Admin: set user active/inactive
 */
const setUserActive = async (req, res) => {
    try {
        const { id } = req.params;
        const { active } = req.body;
        const user = await User.findById(id);
        if (!user) return res.status(404).json({ success: false, message: 'User not found' });
        user.isActive = !!active;
        await user.save();
        res.status(200).json({ success: true, data: user });
    } catch (error) {
        console.error('Set user active error:', error);
        res.status(500).json({ success: false, message: 'Error updating user', error: error.message });
    }
};

/**
 * Get user profile by Firebase UID
 */
const getUserProfile = async (req, res) => {
    try {
        // req.user is set by authMiddleware
        const user = await User.findById(req.user.id);
        
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
        const { firstName, lastName, displayName, phoneNumber, address, profilePicture } = req.body;
        
        // Find user by user ID from auth middleware
        const user = await User.findById(req.user.id);
        
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
        if (address !== undefined) user.address = address;
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
        // Find and delete user by user ID
        const user = await User.findByIdAndDelete(req.user.id);
        
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
    deleteUserAccount,
    listUsers,
    adminDeleteUser,
    setUserActive
};