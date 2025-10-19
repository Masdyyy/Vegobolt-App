# iOS Google Sign-In Configuration Template

## Add this to ios/Runner/Info.plist BEFORE the last </dict>

```xml
<!-- Google Sign-In Configuration -->
<!-- TODO: Replace YOUR-IOS-CLIENT-ID with your actual iOS Client ID from Google Cloud Console -->
<!-- Example: If your iOS Client ID is 123456789-abc.apps.googleusercontent.com -->
<!-- Then use: com.googleusercontent.apps.123456789-abc -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-IOS-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

## Steps to Configure:

1. Get your iOS Client ID from Google Cloud Console
   - Go to: https://console.cloud.google.com/apis/credentials
   - Find your iOS OAuth 2.0 Client ID
   - Copy the Client ID (format: xxxxx-yyy.apps.googleusercontent.com)

2. Create the reversed URL scheme
   - Take only the first part before .apps.googleusercontent.com
   - Example: 123456789-abc
   - Add prefix: com.googleusercontent.apps.123456789-abc

3. Edit ios/Runner/Info.plist
   - Open the file
   - Find the last </dict> tag (before </plist>)
   - Add the CFBundleURLTypes configuration BEFORE that </dict>
   - Replace YOUR-IOS-CLIENT-ID with your actual reversed client ID

4. Update backend .env
   - Add: GOOGLE_CLIENT_ID_IOS=your-full-client-id.apps.googleusercontent.com

5. Run flutter pub get and rebuild the iOS app

## Verification:

After editing, your Info.plist should look like:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    ... existing keys ...
    
    <!-- Google Sign-In Configuration -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.123456789-abc</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

## Notes:

- This configuration is REQUIRED for iOS Google Sign-In to work
- Without it, you'll get authorization errors
- Make sure the reversed client ID matches exactly
- No spaces or extra characters in the string
