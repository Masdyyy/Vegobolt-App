# 🔧 Quick Fix Script for Google Sign-In Web Popup Issue
# This script guides you through fixing the popup_closed error

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Google Sign-In Web Popup Fix Guide                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "❌ Issue: Google Sign-In popup closes with 'popup_closed' error" -ForegroundColor Red
Write-Host ""
Write-Host "✅ Solution: Add Flutter web URLs to Google OAuth configuration" -ForegroundColor Green
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

Write-Host "📋 Step 1: Copy the required URLs" -ForegroundColor Yellow
Write-Host ""
Write-Host "Copy these URLs to add to Google Console:" -ForegroundColor White
Write-Host ""

$urls = @(
    "http://localhost:52438",
    "http://127.0.0.1:52438",
    "http://localhost:8080",
    "http://127.0.0.1:8080",
    "http://localhost:3000"
)

foreach ($url in $urls) {
    Write-Host "  $url" -ForegroundColor Cyan
}

Write-Host ""
$copyUrls = Read-Host "📎 Copy these URLs to clipboard? (Y/N)"

if ($copyUrls -eq "Y" -or $copyUrls -eq "y") {
    $urls -join "`n" | Set-Clipboard
    Write-Host "✅ URLs copied to clipboard!" -ForegroundColor Green
    Write-Host ""
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

Write-Host "🌐 Step 2: Open Google Cloud Console" -ForegroundColor Yellow
Write-Host ""
Write-Host "Opening Google Cloud Console in your browser..." -ForegroundColor White

$consoleUrl = "https://console.cloud.google.com/apis/credentials"
Start-Process $consoleUrl

Start-Sleep -Seconds 2

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

Write-Host "📝 Step 3: Update OAuth Client Configuration" -ForegroundColor Yellow
Write-Host ""
Write-Host "In the Google Cloud Console:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Find your Web Client:" -ForegroundColor Cyan
Write-Host "     • Client ID: 445716724471-0emjir8iu0ff8arpcujegfp559ka4rc6" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Click the pencil icon (✏️) to edit" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Scroll to 'Authorized JavaScript origins'" -ForegroundColor Cyan
Write-Host ""
Write-Host "  4. Click '+ ADD URI' for each URL:" -ForegroundColor Cyan
foreach ($url in $urls) {
    Write-Host "     • $url" -ForegroundColor Gray
}
Write-Host ""
Write-Host "  5. Click 'SAVE' at the bottom" -ForegroundColor Cyan
Write-Host ""
Write-Host "  6. Wait 5-10 minutes for changes to take effect" -ForegroundColor Cyan
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

$openDoc = Read-Host "📖 Open detailed fix guide? (Y/N)"

if ($openDoc -eq "Y" -or $openDoc -eq "y") {
    $docPath = Join-Path $PSScriptRoot "FIX_GOOGLE_SIGNIN_WEB_POPUP.md"
    if (Test-Path $docPath) {
        Start-Process $docPath
        Write-Host "✅ Guide opened!" -ForegroundColor Green
    } else {
        Write-Host "❌ Guide not found at: $docPath" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

Write-Host "⏳ Have you completed the steps above?" -ForegroundColor Yellow
$completed = Read-Host "   Continue to test? (Y/N)"

if ($completed -eq "Y" -or $completed -eq "y") {
    Write-Host ""
    Write-Host "🚀 Starting Flutter Web Server..." -ForegroundColor Green
    Write-Host ""
    Start-Sleep -Seconds 1
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "🧪 Testing Instructions:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. Wait for Flutter web to fully load" -ForegroundColor White
    Write-Host "  2. Navigate to the Login page" -ForegroundColor White
    Write-Host "  3. Click 'Log in with Google' button" -ForegroundColor White
    Write-Host "  4. Select your Google account" -ForegroundColor White
    Write-Host "  5. ✅ Should work without popup closing!" -ForegroundColor White
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host ""
    
    # Navigate to vegobolt directory
    $vegoboltPath = Join-Path $PSScriptRoot "vegobolt"
    if (Test-Path $vegoboltPath) {
        Set-Location $vegoboltPath
        Write-Host "📂 Changed directory to: $vegoboltPath" -ForegroundColor Green
        Write-Host ""
        
        # Run Flutter web
        & "$vegoboltPath\start-web.ps1"
    } else {
        Write-Host "❌ Could not find vegobolt directory" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please run manually:" -ForegroundColor Yellow
        Write-Host "  cd vegobolt" -ForegroundColor Cyan
        Write-Host "  .\start-web.ps1" -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "📌 Remember to:" -ForegroundColor Yellow
    Write-Host "  1. Add the URLs to Google Console" -ForegroundColor White
    Write-Host "  2. Wait 5-10 minutes for changes to propagate" -ForegroundColor White
    Write-Host "  3. Run this script again or start manually:" -ForegroundColor White
    Write-Host ""
    Write-Host "     cd vegobolt" -ForegroundColor Cyan
    Write-Host "     .\start-web.ps1" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Tip: If still not working, clear browser cache and try again!" -ForegroundColor Blue
Write-Host ""
