const { OAuth2Client } = require('google-auth-library');

// Initialize Google OAuth clients for different platforms
const webClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID_WEB);
const androidClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID_ANDROID);
const iosClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID_IOS);

/**
 * Verify Google ID token from client
 * @param {string} idToken - The Google ID token to verify
 * @returns {Promise<Object>} - Verified user payload
 */
async function verifyGoogleToken(idToken) {
    try {
        // Try to verify with each client ID (web, android, ios)
        let ticket = null;
        let lastError = null;

        // Try web client
        try {
            ticket = await webClient.verifyIdToken({
                idToken,
                audience: process.env.GOOGLE_CLIENT_ID_WEB,
            });
        } catch (error) {
            lastError = error;
        }

        // Try android client if web failed
        if (!ticket && process.env.GOOGLE_CLIENT_ID_ANDROID) {
            try {
                ticket = await androidClient.verifyIdToken({
                    idToken,
                    audience: process.env.GOOGLE_CLIENT_ID_ANDROID,
                });
            } catch (error) {
                lastError = error;
            }
        }

        // Try iOS client if android failed
        if (!ticket && process.env.GOOGLE_CLIENT_ID_IOS) {
            try {
                ticket = await iosClient.verifyIdToken({
                    idToken,
                    audience: process.env.GOOGLE_CLIENT_ID_IOS,
                });
            } catch (error) {
                lastError = error;
            }
        }

        if (!ticket) {
            throw lastError || new Error('Unable to verify Google token');
        }

        const payload = ticket.getPayload();

        // Extract user information
        return {
            googleId: payload['sub'],
            email: payload['email'],
            emailVerified: payload['email_verified'],
            displayName: payload['name'],
            profilePicture: payload['picture'],
            givenName: payload['given_name'],
            familyName: payload['family_name'],
        };
    } catch (error) {
        console.error('Google token verification error:', error);
        throw new Error('Invalid Google token: ' + error.message);
    }
}

/**
 * Validate that required environment variables are set
 */
function validateConfig() {
    if (!process.env.GOOGLE_CLIENT_ID_WEB) {
        console.warn('⚠️ GOOGLE_CLIENT_ID_WEB is not set in environment variables');
    }
    if (!process.env.GOOGLE_CLIENT_ID_ANDROID) {
        console.warn('⚠️ GOOGLE_CLIENT_ID_ANDROID is not set in environment variables');
    }
    if (!process.env.GOOGLE_CLIENT_ID_IOS) {
        console.warn('⚠️ GOOGLE_CLIENT_ID_IOS is not set in environment variables');
    }
}

module.exports = {
    verifyGoogleToken,
    validateConfig,
};
