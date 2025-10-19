# Quick Deployment Script for Vercel
# Run this to commit and push your changes to GitHub
# Vercel will automatically deploy!

Write-Host "`n🚀 Vegobolt Backend - Quick Deploy to Vercel" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════`n" -ForegroundColor Cyan

# Check if we're in the right directory
if (!(Test-Path "package.json")) {
    Write-Host "❌ Error: Not in vegobolt-backend directory!" -ForegroundColor Red
    Write-Host "Please run: cd vegobolt-backend" -ForegroundColor Yellow
    exit 1
}

# Check for changes
Write-Host "📋 Checking for changes..." -ForegroundColor Yellow
$status = git status --porcelain

if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "✅ No changes to commit!" -ForegroundColor Green
    Write-Host "📦 Latest code is already on GitHub" -ForegroundColor Cyan
    exit 0
}

Write-Host "`n📝 Changes detected:" -ForegroundColor Green
git status --short

Write-Host "`n"
$commit = Read-Host "Enter commit message (or press Enter for default)"

if ([string]::IsNullOrWhiteSpace($commit)) {
    $commit = "Update backend - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
}

Write-Host "`n📦 Adding files..." -ForegroundColor Yellow
git add .

Write-Host "💾 Committing changes..." -ForegroundColor Yellow
git commit -m "$commit"

Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Yellow
git push origin main

Write-Host "`n✅ Done! Vercel will automatically deploy your changes." -ForegroundColor Green
Write-Host "📊 Check deployment status at: https://vercel.com" -ForegroundColor Cyan
Write-Host "`n⏱️  Deployment typically takes 1-2 minutes`n" -ForegroundColor Yellow
