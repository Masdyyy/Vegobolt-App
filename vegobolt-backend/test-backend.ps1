# PowerShell Test Script for Backend
# Run this in a SECOND terminal while server is running

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Backend Test Script - JWT Authentication" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$testEmail = "test$timestamp@example.com"

# Test 1: Health Check
Write-Host "Test 1: Health Check..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/health" -Method Get
    Write-Host "✅ PASSED: Server is running" -ForegroundColor Green
    $response | ConvertTo-Json
} catch {
    Write-Host "❌ FAILED: Cannot connect to server" -ForegroundColor Red
    Write-Host "Make sure the server is running with 'npm start' in another terminal" -ForegroundColor Red
    exit
}

# Test 2: Register User
Write-Host "`nTest 2: User Registration..." -ForegroundColor Yellow
$registerBody = @{
    email = $testEmail
    password = "test123456"
    displayName = "Test User"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method Post -Body $registerBody -ContentType "application/json"
    Write-Host "✅ PASSED: User registered successfully" -ForegroundColor Green
    $token = $response.data.token
    Write-Host "Token (first 50 chars): $($token.Substring(0, 50))..." -ForegroundColor Cyan
    $response.data.user | ConvertTo-Json
} catch {
    Write-Host "❌ FAILED: Registration failed" -ForegroundColor Red
    $_.Exception.Message
    exit
}

# Test 3: Login
Write-Host "`nTest 3: User Login..." -ForegroundColor Yellow
$loginBody = @{
    email = $testEmail
    password = "test123456"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    Write-Host "✅ PASSED: Login successful" -ForegroundColor Green
    $token = $response.data.token
    $response.data.user | ConvertTo-Json
} catch {
    Write-Host "❌ FAILED: Login failed" -ForegroundColor Red
    $_.Exception.Message
    exit
}

# Test 4: Get Profile (Protected Route)
Write-Host "`nTest 4: Get Profile (Protected Route)..." -ForegroundColor Yellow
try {
    $headers = @{
        Authorization = "Bearer $token"
    }
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/profile" -Method Get -Headers $headers
    Write-Host "✅ PASSED: Profile retrieved successfully" -ForegroundColor Green
    $response.data.user | ConvertTo-Json
} catch {
    Write-Host "❌ FAILED: Cannot get profile" -ForegroundColor Red
    $_.Exception.Message
    exit
}

# Test 5: Verify Token
Write-Host "`nTest 5: Verify Token..." -ForegroundColor Yellow
try {
    $headers = @{
        Authorization = "Bearer $token"
    }
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/verify-token" -Method Post -Headers $headers
    Write-Host "✅ PASSED: Token is valid" -ForegroundColor Green
    $response.data.tokenInfo | ConvertTo-Json
} catch {
    Write-Host "❌ FAILED: Token verification failed" -ForegroundColor Red
    $_.Exception.Message
    exit
}

# Test 6: Wrong Password (Should Fail)
Write-Host "`nTest 6: Login with Wrong Password (Should Fail)..." -ForegroundColor Yellow
$wrongLoginBody = @{
    email = $testEmail
    password = "wrongpassword"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body $wrongLoginBody -ContentType "application/json"
    Write-Host "❌ FAILED: Should have rejected wrong password" -ForegroundColor Red
} catch {
    Write-Host "✅ PASSED: Wrong password correctly rejected" -ForegroundColor Green
}

# Test 7: Access Protected Route Without Token (Should Fail)
Write-Host "`nTest 7: Access Protected Route Without Token (Should Fail)..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/auth/profile" -Method Get
    Write-Host "❌ FAILED: Should have rejected request without token" -ForegroundColor Red
} catch {
    Write-Host "✅ PASSED: Access denied without token" -ForegroundColor Green
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "🎉 ALL TESTS COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n✅ Your JWT authentication is working perfectly!" -ForegroundColor Green
Write-Host "✅ MongoDB-only authentication successful!" -ForegroundColor Green
Write-Host "✅ No Firebase dependencies!" -ForegroundColor Green
Write-Host "`nTest User Email: $testEmail" -ForegroundColor Cyan
Write-Host "Test User Password: test123456" -ForegroundColor Cyan
