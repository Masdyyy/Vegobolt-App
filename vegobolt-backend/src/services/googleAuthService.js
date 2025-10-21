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

// Decode JWT payload without verifying the signature (for diagnostics only)
function decodeJwtPayload(idToken) {
  try {
    const parts = idToken.split('.');
    if (parts.length !== 3) return null;
    const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString('utf8'));
    return payload;
  } catch (_) {
    return null;
  }
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

  try {
    // Verify against any of the configured audiences in one shot
    const ticket = await client.verifyIdToken({ idToken, audience: CLIENT_IDS });
    const payload = ticket.getPayload();
    if (!payload || !payload.email) {
      throw new Error('Invalid Google token payload');
    }
    return payload; // contains email, name, picture, sub, email_verified, etc.
  } catch (e) {
    // Enhance error with diagnostics (what audience the token was minted for)
    const decoded = decodeJwtPayload(idToken) || {};
    const aud = decoded.aud;
    const iss = decoded.iss;
    const azp = decoded.azp; // authorized party (Web client ID on some flows)
    const msg = `Google token verification failed: ${e?.message || 'unknown error'} | token.aud=${aud} token.azp=${azp} token.iss=${iss} | expected one of: ${CLIENT_IDS.join(', ')}`;
    throw new Error(msg);
  }
}

module.exports = { verifyGoogleIdToken, CLIENT_IDS };
