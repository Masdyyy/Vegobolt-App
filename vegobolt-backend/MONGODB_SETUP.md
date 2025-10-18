# MongoDB Setup Guide for Vegobolt Backend

## 🎯 Current Status
- ❌ MongoDB is NOT installed locally
- ✅ Firebase is configured and working
- ✅ Backend code is ready

## Options for MongoDB

### Option 1: MongoDB Atlas (Cloud) - ⭐ RECOMMENDED

**Pros:**
- ✅ No local installation needed
- ✅ Free tier available (512MB storage)
- ✅ Automatic backups
- ✅ Works from anywhere
- ✅ Production-ready

**Steps:**

1. **Create MongoDB Atlas Account**
   - Go to: https://www.mongodb.com/cloud/atlas/register
   - Sign up for free

2. **Create a Free Cluster**
   - Click "Build a Database"
   - Select "FREE" tier (M0)
   - Choose your region (closest to you)
   - Click "Create"

3. **Create Database User**
   - Go to "Database Access" (left sidebar)
   - Click "Add New Database User"
   - Choose "Password" authentication
   - Username: `vegobolt_admin`
   - Password: Generate a secure password (save it!)
   - Database User Privileges: "Read and write to any database"
   - Click "Add User"

4. **Whitelist Your IP Address**
   - Go to "Network Access" (left sidebar)
   - Click "Add IP Address"
   - Click "Allow Access from Anywhere" (for development)
   - Or add your current IP address
   - Click "Confirm"

5. **Get Connection String**
   - Go to "Database" (left sidebar)
   - Click "Connect" on your cluster
   - Click "Connect your application"
   - Copy the connection string (looks like):
     ```
     mongodb+srv://vegobolt_admin:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
     ```

6. **Update Your .env File**
   Replace the MongoDB URI in your `.env`:
   ```env
   MONGODB_URI=mongodb+srv://vegobolt_admin:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/vegobolt?retryWrites=true&w=majority
   ```
   - Replace `<password>` with your actual password
   - Replace `cluster0.xxxxx` with your actual cluster address
   - Add `/vegobolt` before the `?` to specify database name

---

### Option 2: Local MongoDB Installation

**Pros:**
- Works offline
- Faster for local development
- Full control

**Steps:**

#### Windows Installation:

1. **Download MongoDB Community Server**
   - Go to: https://www.mongodb.com/try/download/community
   - Select: Windows
   - Version: Latest
   - Package: MSI
   - Click "Download"

2. **Install MongoDB**
   - Run the downloaded `.msi` file
   - Choose "Complete" installation
   - ✅ Check "Install MongoDB as a Service"
   - ✅ Check "Install MongoDB Compass" (GUI tool)
   - Click "Install"

3. **Verify Installation**
   ```powershell
   # Check if MongoDB service is running
   Get-Service -Name MongoDB
   
   # Should show: Status = Running
   ```

4. **Start MongoDB (if not running)**
   ```powershell
   net start MongoDB
   ```

5. **Your connection string is ready!**
   ```env
   MONGODB_URI=mongodb://localhost:27017/vegobolt
   ```

---

### Option 3: Docker (Advanced)

If you have Docker installed:

```bash
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

Then use:
```env
MONGODB_URI=mongodb://localhost:27017/vegobolt
```

---

## 🚀 Quick Setup (MongoDB Atlas - 5 minutes)

I recommend **MongoDB Atlas** because:
1. No installation needed
2. Ready in 5 minutes
3. Works immediately
4. Free forever (for small projects)
5. Production-ready

### Quick Steps:
```
1. Sign up → https://www.mongodb.com/cloud/atlas/register
2. Create FREE cluster (M0)
3. Add database user (save password!)
4. Allow access from anywhere
5. Get connection string
6. Update .env file
7. Start server!
```

---

## After MongoDB Setup

Once you've set up MongoDB (Atlas or Local):

1. **Test the connection:**
   ```powershell
   npm start
   ```

2. **You should see:**
   ```
   MongoDB Connected: cluster0.xxxxx.mongodb.net (Atlas)
   # or
   MongoDB Connected: localhost (Local)
   🚀 Server is running on port 3000
   ```

3. **Test the API:**
   ```powershell
   # Health check
   curl http://localhost:3000/health
   
   # Register a user
   node test-api.js
   ```

---

## Troubleshooting

### MongoDB Atlas Issues

**"Cannot connect to MongoDB"**
- Check your IP is whitelisted (or use "Allow from Anywhere")
- Verify username/password are correct
- Check connection string format

**"Authentication failed"**
- Make sure you created a database user (not just an Atlas account user)
- Verify the password in your connection string matches

### Local MongoDB Issues

**"MongoDB service not found"**
- MongoDB might not be installed
- Reinstall with "Install as Service" option checked

**"Connection refused on port 27017"**
- MongoDB service is not running
- Start it: `net start MongoDB`

---

## Which Option Should You Choose?

| Feature | Atlas (Cloud) | Local Install |
|---------|---------------|---------------|
| Setup Time | 5 minutes | 15-20 minutes |
| Internet Required | Yes | No |
| Free Storage | 512MB | Unlimited |
| Backup | Automatic | Manual |
| **Recommended for** | **Getting started** | Production/Offline work |

**My recommendation: Start with MongoDB Atlas** 🎯

It's faster to set up and you can always switch to local installation later!
