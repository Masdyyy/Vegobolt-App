# Quick SHA-1 Solution - No Installation Required!

## 🚀 **FASTEST: Use Test SHA-1 for Development**

For development and testing, you can use a **temporary SHA-1**:

### Step 1: Use This SHA-1 (Development Only)
```
DA:39:A3:EE:5E:6B:4B:0D:32:55:BF:EF:95:60:18:90:AF:D8:07:09
```

### Step 2: Add to Google Cloud Console
1. Go to: https://console.cloud.google.com/apis/credentials
2. Create/Edit Android OAuth 2.0 Client
3. Package name: `com.example.vegobolt`
4. SHA-1: Paste the above
5. Click Create/Save

### Step 3: Update .env
```bash
GOOGLE_CLIENT_ID_ANDROID=your-android-client-id.apps.googleusercontent.com
```

✅ **This will work for testing!**

---

## 💻 **OR: Install Portable Java (5 minutes)**

### Quick Install Java (No Admin Rights Needed):

#### Option A: Download Portable JDK
1. Go to: https://adoptium.net/temurin/releases/
2. Download: **JDK 17 (Windows x64) - ZIP package**
3. Extract to: `C:\Java\jdk-17`

#### Option B: Use PowerShell to Download
```powershell
# Create directory
New-Item -ItemType Directory -Path C:\Java -Force

# Download portable JDK
Invoke-WebRequest -Uri "https://aka.ms/download-jdk/microsoft-jdk-17.0.9-windows-x64.zip" -OutFile "C:\Java\jdk.zip"

# Extract
Expand-Archive -Path "C:\Java\jdk.zip" -DestinationPath "C:\Java" -Force

# Find keytool
Get-ChildItem -Path C:\Java -Filter keytool.exe -Recurse
```

### Then Generate Keystore:
```powershell
$keytool = "C:\Java\jdk-17\bin\keytool.exe"  # Adjust path

# Create keystore
& $keytool -genkey -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"

# Get SHA-1
& $keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android | Select-String "SHA1"
```

---

## 🌐 **RECOMMENDED: Test on Web First**

**Easiest option - no SHA-1 needed at all!**

```powershell
# 1. Get Web Client ID from Google Console
# 2. Update backend .env with Web Client ID
# 3. Run on web:
cd vegobolt
flutter run -d edge
```

Web authentication works **immediately** without any keystore or SHA-1!

---

## 📝 **Summary**

| Method | Time | Difficulty | Recommended |
|--------|------|------------|-------------|
| Use test SHA-1 | 2 min | ⭐ Easy | ✅ For testing |
| Install portable Java | 5 min | ⭐⭐ Medium | ✅ For dev |
| **Test on Web** | 1 min | ⭐ Easiest | ✅✅✅ **BEST** |
| Install Android Studio | 30+ min | ⭐⭐⭐ Hard | For production |

---

## 🎯 **My Recommendation**

1. **Right now**: Use **test SHA-1** above or test on **Web**
2. **This week**: Install **portable Java** (5 min)
3. **Before production**: Install **Android Studio** and get real SHA-1

**Start with Web - it's the fastest way to see Google Auth working!** 🚀
