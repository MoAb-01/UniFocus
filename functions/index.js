const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");
const { AccessToken } = require("livekit-server-sdk");

admin.initializeApp();

// Declare secrets managed via Google Cloud / Firebase Secret Manager
const livekitApiKey = defineSecret("LIVEKIT_API_KEY");
const livekitApiSecret = defineSecret("LIVEKIT_API_SECRET");

/**
 * Cloud Function to securely generate LiveKit participant tokens.
 *
 * Security:
 * - Backed by Firebase Secret Manager (LIVEKIT_API_KEY & LIVEKIT_API_SECRET)
 * - Requires Authorization: Bearer <Firebase_ID_Token>
 * - Extracts caller's identity (UID) directly from verified Firebase token
 * - Signs LiveKit JWT using server-side LIVEKIT_API_SECRET
 * - API secret is never exposed to client or APK
 */
exports.getLiveKitToken = onRequest(
  {
    cors: true,
    secrets: [livekitApiKey, livekitApiSecret],
  },
  async (req, res) => {
    // Only accept POST
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method Not Allowed. Use POST." });
      return;
    }

    try {
      // 1. Authenticate the caller via Firebase Auth
      const authHeader = req.headers.authorization || "";
      if (!authHeader.startsWith("Bearer ")) {
        res.status(401).json({
          error: "Unauthorized: Missing or invalid Authorization header.",
        });
        return;
      }

      const idToken = authHeader.split("Bearer ")[1].trim();
      let decodedToken;
      try {
        decodedToken = await admin.auth().verifyIdToken(idToken);
      } catch (authErr) {
        res.status(401).json({
          error: "Unauthorized: Invalid Firebase ID token.",
          details: authErr.message,
        });
        return;
      }

      // Authenticated Firebase UID is the immutable participant identity
      const uid = decodedToken.uid;
      const displayName =
        decodedToken.name || req.body.displayName || "Student";

      // 2. Validate request parameters
      const roomId = req.body.roomId || req.body.room;
      if (!roomId || typeof roomId !== "string") {
        res.status(400).json({ error: "Missing required string field: roomId" });
        return;
      }

      // 3. Read secrets securely from Firebase Secret Manager
      const apiKey = livekitApiKey.value() || process.env.LIVEKIT_API_KEY;
      const apiSecret = livekitApiSecret.value() || process.env.LIVEKIT_API_SECRET;

      if (!apiKey || !apiSecret) {
        console.error(
          "[LiveKit Token] LIVEKIT_API_KEY or LIVEKIT_API_SECRET is not configured in Firebase Secret Manager."
        );
        res.status(500).json({
          error:
            "Server configuration error: LiveKit credentials not found in Firebase Secret Manager.",
        });
        return;
      }

      // 4. Generate the real LiveKit Access Token
      const at = new AccessToken(apiKey, apiSecret, {
        identity: uid,
        name: displayName,
        ttl: "6h",
      });

      at.addGrant({
        roomJoin: true,
        room: roomId,
        canPublish: true,
        canSubscribe: true,
        canPublishData: true,
      });

      const jwt = await at.toJwt();

      res.status(200).json({
        token: jwt,
        identity: uid,
        room: roomId,
      });
    } catch (err) {
      console.error("[LiveKit Token] Error generating token:", err);
      res.status(500).json({
        error: "Internal Server Error",
        message: err.message,
      });
    }
  }
);
