#!/usr/bin/env node
// Scripted fake SDD child worker for the Pi workflow proof (T05).
//
// It stands in for a `pi --print --mode json` child so the proof never makes a
// paid model call. Modes are selected through FAKE_WORKER_MODE:
//   ok   - emit one message_end event whose assistant text is a valid envelope
//   fail - exit non-zero with a stderr message
//   slow - stay alive until terminated (for the cancellation proof)
//
// It records the role, session id, resolved model, and pid it received so the
// proof can assert what the parent dispatched.

import {appendFileSync, writeFileSync} from "node:fs";

const args = process.argv.slice(2);
const flag = (name) => {
  const index = args.indexOf(name);
  return index >= 0 ? args[index + 1] : undefined;
};

const role = flag("--sdd-role") ?? null;
const sessionId = flag("--session-id") ?? null;
const argModel = flag("--model") ?? null;
const envelope = args[args.length - 1] ?? "";
const model = (envelope.match(/^- model:\s*(\S+)/m) ?? [])[1] ?? null;
const mode = process.env.FAKE_WORKER_MODE ?? "ok";

const record = {pid: process.pid, role, sessionId, argModel, model, mode};
if (process.env.FAKE_WORKER_LOG) {
  appendFileSync(process.env.FAKE_WORKER_LOG, `${JSON.stringify(record)}\n`);
}
if (process.env.FAKE_WORKER_PID_FILE) {
  writeFileSync(process.env.FAKE_WORKER_PID_FILE, String(process.pid));
}

if (mode === "fail") {
  process.stderr.write("fake worker failed intentionally\n");
  process.exit(2);
}

if (mode === "slow") {
  // Stay alive; the parent must cancel and reap this process.
  setInterval(() => {}, 1000);
} else {
  const result = {
    schema: "aytordev.sdd-result/v1",
    status: "success",
    executive_summary: "fake phase complete",
    artifacts: ["fake/artifact"],
    next_recommended: "none",
    risks: "None",
    skill_resolution: "paths-injected",
  };
  const event = {
    type: "message_end",
    message: {
      role: "assistant",
      content: [{type: "text", text: JSON.stringify(result)}],
    },
  };
  process.stdout.write(`${JSON.stringify(event)}\n`);
  process.exit(0);
}
