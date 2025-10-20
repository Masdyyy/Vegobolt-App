const { OAuth2Client } = require('google-auth-library');

// Accept multiple client IDs (Android, iOS, Web) separated by commas in env
const rawClientIds = process.env.GOOGLE_CLIENT_IDS || process.env.GOOGLE_CLIENT_ID || '';
const CLIENT_IDS = rawClientIds
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

let oauthClient;
function getClient() {
  if (!oauthClient) {
    oauthClient = new OAuth2Client();
  }
  return oauthClient;
}

/**
 * Verify a Google ID token from client (Flutter google_sign_in).
 * Returns the token payload if valid, else throws.
 * @param {string} idToken
 */
async function verifyGoogleIdToken(idToken) {
  if (!idToken) {
    throw new Error('Missing Google ID token');
  }
  if (!CLIENT_IDS.length) {
    throw new Error('GOOGLE_CLIENT_IDS is not configured');
  }

  const client = getClient();

  // Try verification against all configured client IDs (audiences)
  let lastErr;
  for (const aud of CLIENT_IDS) {
    try {
      const ticket = await client.verifyIdToken({ idToken, audience: aud });
      const payload = ticket.getPayload();
      if (!payload || !payload.email) {
        throw new Error('Invalid Google token payload');
      }
      return payload; // contains email, name, picture, sub, email_verified, etc.
    } catch (e) {
      lastErr = e;
    }
  }
  throw new Error(`Google token verification failed: ${lastErr?.message || 'unknown error'}`);
}

module.exports = { verifyGoogleIdToken, CLIENT_IDS };
