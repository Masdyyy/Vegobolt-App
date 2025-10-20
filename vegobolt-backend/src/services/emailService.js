const nodemailer = require('nodemailer');
const crypto = require('crypto');

/**
 * Create email transporter based on environment configuration
 */
const createTransporter = () => {
    // For development, you can use a service like Ethereal (test email)
    // For production, use a real email service like Gmail, SendGrid, etc.
    
    if (process.env.EMAIL_SERVICE === 'gmail') {
        return nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASSWORD, // Use App Password for Gmail
            },
        });
    } else if (process.env.EMAIL_SERVICE === 'smtp') {
        return nodemailer.createTransport({
            host: process.env.SMTP_HOST,
            port: process.env.SMTP_PORT || 587,
            secure: process.env.SMTP_SECURE === 'true', // true for 465, false for other ports
            auth: {
                user: process.env.SMTP_USER,
                pass: process.env.SMTP_PASSWORD,
            },
        });
    } else {
        // For development/testing - use Ethereal test account
        return new Promise((resolve, reject) => {
            // Create Ethereal test account
            nodemailer.createTestAccount().then(testAccount => {
                const transporter = nodemailer.createTransport({
                    host: 'smtp.ethereal.email',
                    port: 587,
                    secure: false,
                    auth: {
                        user: testAccount.user,
                        pass: testAccount.pass,
                    },
                });
                resolve(transporter);
            }).catch(reject);
        });
    }
};

/**
 * Generate a random verification token
 */
const generateVerificationToken = () => {
    return crypto.randomBytes(32).toString('hex');
};

/**
 * Send email verification email
 * @param {string} email - User's email address
 * @param {string} token - Verification token
 * @param {string} displayName - User's display name
 */
const sendVerificationEmail = async (email, token, displayName) => {
    try {
        const transporter = createTransporter();
        
        // Construct verification URL
        const verificationUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/api/auth/verify-email/${token}`;
        
        const mailOptions = {
            from: process.env.EMAIL_FROM || '"Vegobolt" <noreply@vegobolt.com>',
            to: email,
            subject: 'Verify Your Email - Vegobolt',
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f4f4f4;">
                    <div style="background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                        <h1 style="color: #4CAF50; text-align: center; margin-bottom: 30px;">Welcome to Vegobolt!</h1>
                        
                        <p style="font-size: 16px; color: #333; line-height: 1.6;">
                            Hello <strong>${displayName}</strong>,
                        </p>
                        
                        <p style="font-size: 16px; color: #333; line-height: 1.6;">
                            Thank you for signing up with Vegobolt! To complete your registration and activate your account, 
                            please verify your email address by clicking the button below:
                        </p>
                        
                        <div style="text-align: center; margin: 30px 0;">
                            <a href="${verificationUrl}" 
                               style="background-color: #4CAF50; 
                                      color: white; 
                                      padding: 15px 40px; 
                                      text-decoration: none; 
                                      border-radius: 5px; 
                                      font-size: 16px; 
                                      font-weight: bold;
                                      display: inline-block;">
                                Verify Email Address
                            </a>
                        </div>
                        
                        <p style="font-size: 14px; color: #666; line-height: 1.6;">
                            Or copy and paste this link into your browser:
                        </p>
                        <p style="font-size: 12px; color: #888; word-break: break-all; background-color: #f9f9f9; padding: 10px; border-radius: 5px;">
                            ${verificationUrl}
                        </p>
                        
                        <p style="font-size: 14px; color: #666; line-height: 1.6; margin-top: 30px;">
                            This verification link will expire in <strong>24 hours</strong>.
                        </p>
                        
                        <p style="font-size: 14px; color: #666; line-height: 1.6;">
                            If you didn't create an account with Vegobolt, you can safely ignore this email.
                        </p>
                        
                        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
                        
                        <p style="font-size: 12px; color: #999; text-align: center;">
                            © ${new Date().getFullYear()} Vegobolt. All rights reserved.
                        </p>
                    </div>
                </div>
            `,
            text: `
                Welcome to Vegobolt!
                
                Hello ${displayName},
                
                Thank you for signing up with Vegobolt! To complete your registration and activate your account, 
                please verify your email address by clicking the link below:
                
                ${verificationUrl}
                
                This verification link will expire in 24 hours.
                
                If you didn't create an account with Vegobolt, you can safely ignore this email.
                
                © ${new Date().getFullYear()} Vegobolt. All rights reserved.
            `,
        };

        const info = await transporter.sendMail(mailOptions);
        
        console.log('✅ Verification email sent:', info.messageId);
        
        // For development with Ethereal, always log the preview URL
        if (process.env.NODE_ENV === 'development') {
            console.log('📧 Preview URL:', nodemailer.getTestMessageUrl(info));
            // In development, we'll simulate success without actually sending emails
            return { success: true, messageId: info.messageId, previewUrl: nodemailer.getTestMessageUrl(info) };
        }
        
        return { success: true, messageId: info.messageId };
        
    } catch (error) {
        console.error('❌ Error sending verification email:', error);
        throw new Error('Failed to send verification email');
    }
};

/**
 * Send password reset email
 * @param {string} email - User's email address
 * @param {string} token - Reset token
 * @param {string} displayName - User's display name
 */
const sendPasswordResetEmail = async (email, token, displayName) => {
    try {
        const transporter = createTransporter();
        
        const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password/${token}`;
        
        const mailOptions = {
            from: process.env.EMAIL_FROM || '"Vegobolt" <noreply@vegobolt.com>',
            to: email,
            subject: 'Password Reset Request - Vegobolt',
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f4f4f4;">
                    <div style="background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                        <h1 style="color: #FF9800; text-align: center; margin-bottom: 30px;">Password Reset Request</h1>
                        
                        <p style="font-size: 16px; color: #333; line-height: 1.6;">
                            Hello <strong>${displayName}</strong>,
                        </p>
                        
                        <p style="font-size: 16px; color: #333; line-height: 1.6;">
                            We received a request to reset your Vegobolt account password. 
                            Click the button below to create a new password:
                        </p>
                        
                        <div style="text-align: center; margin: 30px 0;">
                            <a href="${resetUrl}" 
                               style="background-color: #FF9800; 
                                      color: white; 
                                      padding: 15px 40px; 
                                      text-decoration: none; 
                                      border-radius: 5px; 
                                      font-size: 16px; 
                                      font-weight: bold;
                                      display: inline-block;">
                                Reset Password
                            </a>
                        </div>
                        
                        <p style="font-size: 14px; color: #666; line-height: 1.6;">
                            Or copy and paste this link into your browser:
                        </p>
                        <p style="font-size: 12px; color: #888; word-break: break-all; background-color: #f9f9f9; padding: 10px; border-radius: 5px;">
                            ${resetUrl}
                        </p>
                        
                        <p style="font-size: 14px; color: #666; line-height: 1.6; margin-top: 30px;">
                            This password reset link will expire in <strong>1 hour</strong>.
                        </p>
                        
                        <p style="font-size: 14px; color: #d32f2f; line-height: 1.6;">
                            If you didn't request a password reset, please ignore this email and your password will remain unchanged.
                        </p>
                        
                        <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
                        
                        <p style="font-size: 12px; color: #999; text-align: center;">
                            © ${new Date().getFullYear()} Vegobolt. All rights reserved.
                        </p>
                    </div>
                </div>
            `,
        };

        const info = await transporter.sendMail(mailOptions);
        console.log('✅ Password reset email sent:', info.messageId);
        
        return { success: true, messageId: info.messageId };
        
    } catch (error) {
        console.error('❌ Error sending password reset email:', error);
        throw new Error('Failed to send password reset email');
    }
};

module.exports = {
    generateVerificationToken,
    sendVerificationEmail,
    sendPasswordResetEmail,
};
