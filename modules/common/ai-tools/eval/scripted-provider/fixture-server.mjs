// Deterministic loopback OpenAI-compatible fixture for the T16 scripted-provider
// evaluation. It serves the minimal Chat Completions surface that both clients
// consume and records every request body it receives, so the runner can assert
// that the real client actually reached the fixture (transport) and forwarded
// the expected command/delegation input.
//
// No paid API call and no external network: it binds 127.0.0.1 on an ephemeral
// port. The port is printed to stdout as `FIXTURE_PORT=<port>`.
//
// NOTE: this cannot run inside a Nix build on aarch64-darwin because the
// sandbox seatbelt profile denies `listen` with EPERM. It is a developer-run
// evaluation harness (see README.md).

import {createServer} from "node:http";

export const SCRIPTED_ENVELOPE = {
  schema: "aytordev.sdd-result/v1",
  status: "success",
  executive_summary: "scripted-provider fixture response",
  artifacts: ["scripted-provider/artifact"],
  next_recommended: "none",
  risks: "None",
  skill_resolution: "paths-injected",
};

function readBody(req) {
  return new Promise((resolve) => {
    let data = "";
    req.on("data", (chunk) => (data += chunk.toString()));
    req.on("end", () => resolve(data));
  });
}

function sseChunk(model, delta, finishReason) {
  return `data: ${JSON.stringify({
    id: "chatcmpl-scripted",
    object: "chat.completion.chunk",
    created: 0,
    model,
    choices: [{index: 0, delta, finish_reason: finishReason}],
  })}\n\n`;
}

/**
 * Start the fixture. Returns {port, requests, close}. `requests` is a live
 * array of parsed request bodies in arrival order.
 */
export async function startFixture() {
  const requests = [];
  const server = createServer(async (req, res) => {
    const url = req.url ?? "";
    if (req.method === "POST" && url.endsWith("/chat/completions")) {
      const raw = await readBody(req);
      const body = JSON.parse(raw || "{}");
      requests.push({url, body});
      const text = JSON.stringify(SCRIPTED_ENVELOPE);
      res.writeHead(200, {"Content-Type": "text/event-stream", "Cache-Control": "no-cache"});
      res.write(sseChunk(body.model ?? "scripted-model", {role: "assistant"}, null));
      res.write(sseChunk(body.model ?? "scripted-model", {content: text}, null));
      res.write(sseChunk(body.model ?? "scripted-model", {}, "stop"));
      res.write("data: [DONE]\n\n");
      res.end();
      return;
    }
    if (req.method === "GET" && url.endsWith("/models")) {
      res.writeHead(200, {"Content-Type": "application/json"});
      res.end(JSON.stringify({object: "list", data: [{id: "scripted-model", object: "model"}]}));
      return;
    }
    res.writeHead(404, {"Content-Type": "application/json"});
    res.end(JSON.stringify({error: {message: `no fixture route for ${req.method} ${url}`}}));
  });

  await new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(0, "127.0.0.1", resolve);
  });
  const port = server.address().port;
  return {
    port,
    requests,
    close: () => new Promise((resolve) => server.close(resolve)),
  };
}

if (process.argv[1] && import.meta.url === new URL(`file://${process.argv[1]}`).href) {
  const fixture = await startFixture();
  console.log(`FIXTURE_PORT=${fixture.port}`);
}
