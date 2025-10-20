# Database Migration Guide: Full Name to First/Last Name

## Overview
This migration updates the user schema from using a single `displayName` field to separate `firstName` and `lastName` fields.

## Changes Made

### Database Schema (User Model)
- **Added**: `firstName` (required) - User's first name
- **Added**: `lastName` (required) - User's last name  
- **Modified**: `displayName` (optional) - Now auto-generated from firstName + lastName
- **Pre-save hook**: Automatically generates `displayName` if not provided

### API Changes

#### Registration Endpoint (`POST /api/auth/register`)
**Before:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "displayName": "John Doe"
}
```

**After:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe"
}
```

#### Response Changes
All user objects in API responses now include:
```json
{
  "user": {
    "id": "...",
    "email": "...",
    "firstName": "John",
    "lastName": "Doe",
    "displayName": "John Doe",
    ...
  }
}
```

### Files Updated
1. `src/models/User.js` - Added firstName/lastName fields
2. `src/controllers/authController.js` - Updated register, login, googleLogin, verifyToken, getProfile
3. `src/controllers/userController.js` - Updated updateUserProfile
4. `test-registration.js` - Updated test data
5. `test-registration.json` - Updated test data

## Migration Steps

### 1. Backup Your Database
```bash
# If using MongoDB Atlas, create a backup first
# Or use mongodump for local databases
mongodump --uri="YOUR_MONGODB_URI" --out=./backup
```

### 2. Run the Migration Script
This script will update all existing users who have `displayName` but no `firstName`/`lastName`:

```bash
# Make sure your .env file has MONGODB_URI set
node migrate-users.js
```

The migration will:
- Split existing `displayName` into `firstName` and `lastName`
- First word becomes `firstName`
- Remaining words become `lastName`
- Preserve original `displayName` for backward compatibility

### 3. Update Your Frontend/Mobile App
Update your registration form to collect:
- First Name
- Last Name

Instead of:
- Display Name / Full Name

### 4. Test the Changes

#### Test Registration:
```bash
node test-registration.js
```

#### Test with PowerShell:
```powershell
# Registration
$body = @{
    email = "test@example.com"
    password = "Test123!"
    firstName = "John"
    lastName = "Doe"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/auth/register" -Method POST -Body $body -ContentType "application/json"
```

## Rollback Plan

If you need to rollback:

1. Restore from backup:
```bash
mongorestore --uri="YOUR_MONGODB_URI" --drop ./backup
```

2. Revert code changes using git:
```bash
git revert <commit-hash>
```

## Notes

- The `displayName` field is still present and automatically populated
- Google Sign-In will parse names from the Google profile
- Existing users will need to be migrated using the provided script
- The pre-save hook ensures `displayName` is always in sync with `firstName` and `lastName`

## Validation

After migration, verify:
1. New registrations work with firstName/lastName
2. Existing users can still log in
3. All API responses include the new fields
4. Google Sign-In still works correctly
