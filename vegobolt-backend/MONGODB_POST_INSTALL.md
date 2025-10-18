# MongoDB Local Installation - Post-Install Check

After installing MongoDB, run these commands to verify:

## Check if MongoDB service is installed
```powershell
Get-Service -Name MongoDB
```

Expected output:
```
Status   Name               DisplayName
------   ----               -----------
Running  MongoDB            MongoDB
```

## Check if MongoDB is listening on port 27017
```powershell
netstat -ano | Select-String ":27017"
```

Expected output (should see LISTENING):
```
TCP    0.0.0.0:27017    0.0.0.0:0    LISTENING    [PID]
```

## Test MongoDB connection
```powershell
# If mongosh (MongoDB Shell) is installed:
mongosh --eval "db.version()"
```

## Start MongoDB (if not running)
```powershell
net start MongoDB
```

## Stop MongoDB (if needed)
```powershell
net stop MongoDB
```

## Your .env configuration should be:
```env
MONGODB_URI=mongodb://localhost:27017/vegobolt
```

This is already configured correctly in your .env file!

## After MongoDB is running, test your backend:
```powershell
npm start
```

You should see:
```
MongoDB Connected: localhost
🚀 Server is running on port 3000
```
