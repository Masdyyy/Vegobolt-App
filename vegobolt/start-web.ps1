# Flutter Web Start Script
# Runs Flutter web on a fixed port (52438) for Google OAuth

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "   Flutter Web Server Starting" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Port: http://localhost:52438" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  IMPORTANT: Google OAuth Configuration" -ForegroundColor Yellow
Write-Host ""
Write-Host "Make sure these origins are added to your Google OAuth client:" -ForegroundColor Yellow
Write-Host "  • http://localhost:52438" -ForegroundColor White
Write-Host "  • http://127.0.0.1:52438" -ForegroundColor White
Write-Host ""
Write-Host "📝 To add origins, visit:" -ForegroundColor Cyan
Write-Host "   https://console.cloud.google.com/apis/credentials" -ForegroundColor Blue
Write-Host ""
Write-Host "   Then edit your Web client and add the URLs above to" -ForegroundColor White
Write-Host "   'Authorized JavaScript origins'" -ForegroundColor White
Write-Host ""
Write-Host "Starting server..." -ForegroundColor Green
Write-Host ""

flutter run -d edge --web-port=52438
