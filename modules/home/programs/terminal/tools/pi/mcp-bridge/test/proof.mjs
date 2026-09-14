#!/usr/bin/env node
// Fake-server proof for the Pi MCP bridge (T07).
//
// Exercises the real @modelcontextprotocol/sdk client inside `src/host.ts`
// against `test/fake-server.mjs` and asserts discovery, call/result conversion,
// failure, cancellation, and process cleanup.
//
// Run: node test/proof.mjs

import assert from "node:assert/strict";
import {mkdtemp, readFile} from "node:fs/promises";
import {tmpdir} from "node:os";
import {dirname, join} from "node:path";
import {fileURLToPath} from "node:url";
import {McpHost, McpBridgeError} from "../src/host.ts";

const here = dirname(fileURLToPath(import.meta.url));
const fakeServer = join(here, "fake-server.mjs");
const workdir = await mkdtemp(join(tmpdir(), "pi-mcp-bridge-proof-"));
const pidFile = join(workdir, "fake.pid");

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const passed = [];

function ok(label, condition) {
  assert.ok(condition, `assertion failed: ${label}`);
  passed.push(label);
}

async function readMarks() {
  try {
    return (await readFile(pidFile, "utf8")).trim().split("\n").filter(Boolean);
  } catch {
    return [];
  }
}

const config = {
  servers: {
    fake: {
      command: process.execPath,
      args: [fakeServer],
      env: {FAKE_PID_FILE: pidFile},
    },
  },
  connectTimeoutMs: 5000,
  requestTimeoutMs: 30000,
};

const host = new McpHost(config);

// 1. Discovery -----------------------------------------------------------------
const tools = await host.listTools();
const names = tools.map((tool) => tool.piName).sort();
ok("discovers all fake tools", JSON.stringify(names) === JSON.stringify([
  "mcp_fake_echo",
  "mcp_fake_fail",
  "mcp_fake_slow",
  "mcp_fake_snapshot",
]));
ok("preserves MCP input schema", tools.find((t) => t.name === "echo")?.inputSchema.type === "object");

const marksAfterConnect = await readMarks();
ok("spawned exactly one fake server", marksAfterConnect.filter((m) => m.startsWith("pid:")).length === 1);
const firstPid = Number((marksAfterConnect.find((m) => m.startsWith("pid:")) ?? "").split(":")[1]);

// 2. Call / result conversion --------------------------------------------------
const echoed = await host.callTool("mcp_fake_echo", {text: "hi"});
const echoText = echoed.content.find((block) => block.type === "text");
ok("maps text content", echoText?.text === "echo:hi");
ok("includes structured content", JSON.stringify(echoed.details) === JSON.stringify({server: "fake", tool: "echo", isError: false}));
ok(
  "appends structuredContent as text",
  echoed.content.some((block) => block.type === "text" && block.text.includes('"echoed": "hi"')),
);

const snapshot = await host.callTool("mcp_fake_snapshot", {});
const image = snapshot.content.find((block) => block.type === "image");
ok("maps image content", image?.type === "image" && image.mimeType === "image/png" && image.data.length > 0);

// 3. Failure -------------------------------------------------------------------
let failure = null;
try {
  await host.callTool("mcp_fake_fail", {});
} catch (error) {
  failure = error;
}
ok("surfaces MCP isError as a bridge error", failure instanceof McpBridgeError && /boom/.test(failure.message));
ok("failure carries server/tool context", failure?.server === "fake" && failure?.tool === "fail");

// 3b. Reconnect after the server exits ----------------------------------------
process.kill(firstPid, "SIGKILL");
await sleep(300);
const toolsAfterReconnect = await host.listTools();
ok("reconnects after the server exits", toolsAfterReconnect.some((t) => t.piName === "mcp_fake_echo"));
const marksAfterReconnect = await readMarks();
ok(
  "reconnect spawned a replacement server",
  marksAfterReconnect.filter((m) => m.startsWith("pid:")).length === 2,
);

// 4. Cancellation --------------------------------------------------------------
const controller = new AbortController();
const cancelStart = Date.now();
const slowCall = host.callTool("mcp_fake_slow", {}, {signal: controller.signal});
setTimeout(() => controller.abort(), 150);
let cancelled = null;
try {
  await slowCall;
} catch (error) {
  cancelled = error;
}
const cancelElapsed = Date.now() - cancelStart;
ok("cancels an in-flight call", cancelled !== null);
ok("cancellation is prompt", cancelElapsed < 5000);
ok("cancellation does not surface as a tool error", !(cancelled instanceof McpBridgeError) || !/reported an error/.test(cancelled.message));

// 5. Cleanup -------------------------------------------------------------------
await host.close();
let exited = false;
for (let attempt = 0; attempt < 100; attempt++) {
  if ((await readMarks()).some((m) => m.startsWith("exited:"))) {
    exited = true;
    break;
  }
  await sleep(50);
}
ok("closing the bridge stops the child process", exited);

const pids = (await readMarks())
  .filter((m) => m.startsWith("pid:"))
  .map((m) => Number(m.split(":")[1]));
const lastPid = pids[pids.length - 1];
let alive = true;
try {
  process.kill(lastPid, 0);
} catch {
  alive = false;
}
ok("child process is not alive after close", !alive);

// 6. Empty configuration is inert ---------------------------------------------
const marksBeforeEmpty = await readMarks();
const emptyHost = new McpHost({servers: {}});
ok("empty config exposes no servers", emptyHost.serverNames().length === 0);
ok("empty config lists no tools", (await emptyHost.listTools()).length === 0);
await emptyHost.close();
ok("empty config does not spawn a process", JSON.stringify(await readMarks()) === JSON.stringify(marksBeforeEmpty));

console.log(`proof: ${passed.length} assertions passed`);
for (const label of passed) {
  console.log(`  ok - ${label}`);
}
console.log("PROOF OK");
