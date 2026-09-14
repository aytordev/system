#!/usr/bin/env node
// Minimal fake MCP stdio server used to prove the Pi MCP bridge.
//
// It deliberately does NOT use the MCP SDK: it is test scaffolding, not part of
// the bridge. It speaks just enough of the JSON-RPC/MCP stdio protocol to let
// the real SDK client discover and call it.
//
// Framing: newline-delimited JSON on stdin/stdout, matching MCP stdio.
//
// Tools:
//   echo     -> text + structuredContent round-trip
//   snapshot -> image content block
//   fail     -> MCP error result (isError: true)
//   slow     -> never answers within the test window (cancellation target)

import {appendFileSync} from "node:fs";

const pidFile = process.env.FAKE_PID_FILE;
const mark = (line) => {
  if (pidFile) {
    appendFileSync(pidFile, `${line}\n`);
  }
};

mark(`pid:${process.pid}`);

const TOOLS = [
  {
    name: "echo",
    description: "Echo text back",
    inputSchema: {
      type: "object",
      properties: {text: {type: "string", description: "Text to echo"}},
      required: ["text"],
      additionalProperties: false,
    },
    outputSchema: {
      type: "object",
      properties: {echoed: {type: "string"}},
      required: ["echoed"],
    },
  },
  {
    name: "snapshot",
    description: "Return a tiny PNG image",
    inputSchema: {type: "object", properties: {}, additionalProperties: false},
  },
  {
    name: "fail",
    description: "Always fails",
    inputSchema: {type: "object", properties: {}, additionalProperties: false},
  },
  {
    name: "slow",
    description: "Sleeps forever",
    inputSchema: {type: "object", properties: {}, additionalProperties: false},
  },
];

const send = (message) => {
  process.stdout.write(`${JSON.stringify(message)}\n`);
};

const result = (id, value) => send({jsonrpc: "2.0", id, result: value});
const error = (id, code, message) =>
  send({jsonrpc: "2.0", id, error: {code, message}});

function callTool(id, params) {
  const name = params?.name;
  const args = params?.arguments ?? {};
  switch (name) {
    case "echo": {
      const text = String(args.text ?? "");
      result(id, {
        content: [{type: "text", text: `echo:${text}`}],
        structuredContent: {echoed: text},
      });
      return;
    }
    case "snapshot": {
      // 1x1 transparent PNG.
      const png =
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";
      result(id, {
        content: [{type: "image", data: png, mimeType: "image/png"}],
      });
      return;
    }
    case "fail": {
      result(id, {
        content: [{type: "text", text: "boom"}],
        isError: true,
      });
      return;
    }
    case "slow": {
      // Intentionally never responds; the client aborts and closes the
      // transport. If the bridge failed to cancel/clean up, the test would
      // hang or leave this process alive.
      return;
    }
    default: {
      error(id, -32602, `unknown tool ${name}`);
    }
  }
}

function handle(message) {
  if (message.method === "initialize") {
    const requested = message.params?.protocolVersion ?? "2025-06-18";
    result(message.id, {
      protocolVersion: requested,
      capabilities: {tools: {}},
      serverInfo: {name: "fake-mcp", version: "1.0.0"},
    });
    return;
  }
  if (message.method === "tools/list") {
    result(message.id, {tools: TOOLS});
    return;
  }
  if (message.method === "tools/call") {
    callTool(message.id, message.params);
    return;
  }
  if (message.method === "ping") {
    result(message.id, {});
    return;
  }
  if (message.id !== undefined) {
    error(message.id, -32601, `method not found: ${message.method}`);
  }
  // Notifications (e.g. notifications/initialized, notifications/cancelled)
  // carry no id and expect no response.
}

let buffer = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  buffer += chunk;
  for (;;) {
    const newline = buffer.indexOf("\n");
    if (newline === -1) {
      break;
    }
    const line = buffer.slice(0, newline).trim();
    buffer = buffer.slice(newline + 1);
    if (!line) {
      continue;
    }
    try {
      handle(JSON.parse(line));
    } catch (parseError) {
      mark(`parse-error:${parseError.message}`);
    }
  }
});

const shutdown = () => {
  mark(`exited:${process.pid}`);
  process.exit(0);
};

// The SDK closes stdin first; this is the normal cleanup path.
process.stdin.on("end", shutdown);
process.stdin.on("close", shutdown);
process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
