# Admin Account Setup Guide

## Overview

The Vegobolt app now has admin functionality that allows administrators to access a special dashboard and settings page with enhanced privileges.

## Admin Account Credentials

**Email:** `admin@vegobolt.com`  
**Password:** `Admin@123`

⚠️ **IMPORTANT:** Change this password after your first login!

## Features

### 1. Admin Dashboard (`/admin-dashboard`)

- View all machines and users in a data table
- Columns: Full Name, Machine, Location, Status, Control
- Status indicators with color coding:
  - 🟢 **Active** - Machine is running normally
  - ⚪ **Inactive** - Machine is offline
  - 🟠 **Maintenance** - Machine is under maintenance
- Control actions for each machine:
  - Restart Station
  - Shutdown Station
- Settings button in the top-right to access admin settings

### 2. Admin Settings (`/admin-settings`)

- Enable/disable notifications for critical events
- Toggle auto-refresh for dashboard data
- Access to account settings
- Logout functionality

## How It Works

### Authentication Flow

1. User logs in with credentials at the login page
2. Backend checks if user has `isAdmin` flag set to `true`
3. If admin:
   - Routes to `/admin-dashboard`
   - Can access admin-specific pages
4. If regular user:
   - Routes to `/dashboard`
   - Cannot access admin pages

### Backend Changes

- Added `isAdmin` boolean field to User model (default: `false`)
- Login endpoint now returns `isAdmin` status in response
- Created `create-admin.js` script to easily create/update admin users

### Frontend Changes

- Created `lib/Pages/admin/` folder for admin-specific pages
- `admin_dashboard.dart` - Main admin dashboard with data table
- `admin_settings.dart` - Admin-specific settings page
- Updated `auth_service.dart` to store admin status in secure storage
- Updated `Login.dart` to route based on admin status
- Added routes in `main.dart`:
  - `/admin-dashboard` → AdminDashboardPage
  - `/admin-settings` → AdminSettingsPage

## Creating Additional Admin Users

To create or update admin users, run the script:

```bash
cd vegobolt-backend
node create-admin.js
```

This will:

- Create a new admin user if one doesn't exist
- Update an existing user to admin if they already exist
- Set `isEmailVerified: true` and `isActive: true` automatically

## Manual Admin Setup

You can also manually update a user to admin in MongoDB:

```javascript
db.users.updateOne(
  { email: "user@example.com" },
  {
    $set: {
      isAdmin: true,
      isEmailVerified: true,
      isActive: true,
    },
  }
);
```

## Security Notes

1. The admin status is stored in:

   - **Backend:** MongoDB User document (`isAdmin` field)
   - **Frontend:** Flutter secure storage (`is_admin` key)

2. Currently, there's no backend middleware to prevent non-admins from accessing admin endpoints. Consider adding:

   ```javascript
   const requireAdmin = (req, res, next) => {
     if (!req.user.isAdmin) {
       return res.status(403).json({
         success: false,
         message: "Admin access required",
       });
     }
     next();
   };
   ```

3. The admin check is performed on the client side during login. For production:
   - Add server-side admin verification on protected routes
   - Implement role-based access control (RBAC)
   - Add admin activity logging

## Testing

1. Start the backend server:

   ```bash
   cd vegobolt-backend
   npm start
   ```

2. Run the Flutter app:

   ```bash
   cd vegobolt
   flutter run
   ```

3. Login with admin credentials:

   - Email: `admin@vegobolt.com`
   - Password: `Admin@123`

4. Verify you're redirected to the admin dashboard

5. Test the settings button and navigation

## Next Steps

Consider implementing:

- [ ] Backend middleware to protect admin routes
- [ ] Real-time data from backend instead of sample data
- [ ] User management features (create, edit, delete users)
- [ ] Machine management features (add, edit, delete machines)
- [ ] Activity logs and audit trail
- [ ] Role-based permissions (super admin, admin, moderator)
- [ ] Admin dashboard analytics (charts, graphs, statistics)
