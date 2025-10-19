#!/usr/bin/env node

/**
 * Interactive setup script for email verification
 * Run with: node setup-email.js
 */

const readline = require('readline');
const fs = require('fs');
const path = require('path');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const question = (query) => new Promise((resolve) => rl.question(query, resolve));

async function setupEmail() {
    console.log('\n╔═══════════════════════════════════════════════════╗');
    console.log('║   Vegobolt Email Verification Setup              ║');
    console.log('╚═══════════════════════════════════════════════════╝\n');

    try {
        // Read existing .env if it exists
        let envContent = '';
        const envPath = path.join(__dirname, '.env');
        const envExamplePath = path.join(__dirname, '.env.example');

        if (fs.existsSync(envPath)) {
            envContent = fs.readFileSync(envPath, 'utf8');
            console.log('✅ Found existing .env file\n');
        } else if (fs.existsSync(envExamplePath)) {
            envContent = fs.readFileSync(envExamplePath, 'utf8');
            console.log('📋 Creating new .env file from template\n');
        }

        console.log('Choose your email service:\n');
        console.log('1. Gmail (Quick setup)');
        console.log('2. Custom SMTP (SendGrid, AWS SES, etc.)');
        console.log('3. Development Mode (Console logging only)\n');

        const choice = await question('Enter your choice (1-3): ');

        let newEnvLines = [];

        if (choice === '1') {
            console.log('\n📧 Gmail Setup\n');
            console.log('To use Gmail, you need to:');
            console.log('1. Enable 2-Factor Authentication on your Google account');
            console.log('2. Generate an App Password (Security → 2-Step Verification → App passwords)\n');

            const email = await question('Enter your Gmail address: ');
            const password = await question('Enter your App Password (16 characters): ');

            newEnvLines.push('EMAIL_SERVICE=gmail');
            newEnvLines.push(`EMAIL_USER=${email}`);
            newEnvLines.push(`EMAIL_PASSWORD=${password}`);
            newEnvLines.push('EMAIL_FROM="Vegobolt <noreply@vegobolt.com>"');

        } else if (choice === '2') {
            console.log('\n🔧 Custom SMTP Setup\n');

            const host = await question('SMTP Host (e.g., smtp.sendgrid.net): ');
            const port = await question('SMTP Port (default 587): ') || '587';
            const secure = await question('Use TLS? (yes/no, default no): ');
            const user = await question('SMTP Username: ');
            const password = await question('SMTP Password: ');

            newEnvLines.push('EMAIL_SERVICE=smtp');
            newEnvLines.push(`SMTP_HOST=${host}`);
            newEnvLines.push(`SMTP_PORT=${port}`);
            newEnvLines.push(`SMTP_SECURE=${secure.toLowerCase() === 'yes'}`);
            newEnvLines.push(`SMTP_USER=${user}`);
            newEnvLines.push(`SMTP_PASSWORD=${password}`);
            newEnvLines.push('EMAIL_FROM="Vegobolt <noreply@vegobolt.com>"');

        } else if (choice === '3') {
            console.log('\n🧪 Development Mode\n');
            console.log('Emails will be logged to the console only.\n');

            newEnvLines.push('# EMAIL_SERVICE not set - using development mode');
            newEnvLines.push('EMAIL_USER=test@ethereal.email');
            newEnvLines.push('EMAIL_PASSWORD=test123');
            newEnvLines.push('EMAIL_FROM="Vegobolt Dev <noreply@vegobolt.com>"');
        }

        const frontendUrl = await question('\nFrontend URL (default http://localhost:3000): ') || 'http://localhost:3000';
        newEnvLines.push(`FRONTEND_URL=${frontendUrl}`);

        // Update .env content
        const emailConfigSection = '\n# Email Configuration\n' + newEnvLines.join('\n');
        
        // Remove old email config if exists
        envContent = envContent.replace(/# Email Configuration[\s\S]*?(?=\n# |$)/g, '');
        
        // Add new email config before Server Configuration
        if (envContent.includes('# Server Configuration')) {
            envContent = envContent.replace('# Server Configuration', emailConfigSection + '\n\n# Server Configuration');
        } else {
            envContent += emailConfigSection;
        }

        // Write to .env file
        fs.writeFileSync(envPath, envContent);

        console.log('\n✅ Email configuration saved to .env file!\n');
        console.log('Next steps:');
        console.log('1. Review your .env file');
        console.log('2. Start your server: npm start');
        console.log('3. Test registration with email verification');
        console.log('4. Check EMAIL_VERIFICATION_SETUP.md for more details\n');

    } catch (error) {
        console.error('\n❌ Setup failed:', error.message);
    } finally {
        rl.close();
    }
}

setupEmail();
