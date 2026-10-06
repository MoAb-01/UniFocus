const http = require("http");
const { AccessToken } = require("livekit-server-sdk");

const port = process.env.PORT || 8080;
const apiKey = process.env.LIVEKIT_API_KEY;
const apiSecret = process.env.LIVEKIT_API_SECRET;

const server = http.createServer(async (req, res) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    res.writeHead(204);
    res.end();
    return;
  }

  // Health check endpoint for Render and uptime monitors
  if (req.method === "GET") {
    const isConfigured = Boolean(apiKey && apiSecret);
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(
      JSON.stringify({
        status: "healthy",
        service: "UniFocus LiveKit Token Server",
        configured: isConfigured,
      })
    );
    return;
  }

  // Token generation endpoint
  if (req.method === "POST") {
    if (!apiKey || !apiSecret) {
      console.error("[Token Server] Missing LIVEKIT_API_KEY or LIVEKIT_API_SECRET environment variables.");
      res.writeHead(500, { "Content-Type": "application/json" });
      res.end(
        JSON.stringify({
          error: "Server configuration error: LIVEKIT_API_KEY and LIVEKIT_API_SECRET must be set as environment variables.",
        })
      );
      return;
    }

    let body = "";
    req.on("data", (chunk) => {
      body += chunk;
    });

    req.on("end", async () => {
      try {
        const data = JSON.parse(body || "{}");
        const roomId = data.roomId || "study_room";
        const userId = data.userId || `user_${Date.now()}`;
        const displayName = data.displayName || "Student";

        const at = new AccessToken(apiKey, apiSecret, {
          identity: userId,
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
        console.log(`[Token Server] Generated token for ${userId} in ${roomId}`);
        res.writeHead(200, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ token: jwt, identity: userId, room: roomId }));
      } catch (err) {
        console.error("[Token Server] Error generating token:", err);
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(JSON.stringify({ error: err.message }));
      }
    });
    return;
  }

  res.writeHead(404, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ error: "Not Found" }));
});

server.listen(port, "0.0.0.0", () => {
  console.log(`LiveKit Token Server running on port ${port}`);
});
