#!/usr/bin/env node
// Scripted proof for the Pi SDD workflow adapter (T05).
//
// Drives the real `src/workflow.ts` command surface with a fake Pi API and a
// scripted fake child worker. It proves:
//   1. commands are registered from the phase policy;
//   2. a phase command dispatches the expected worker with the resolved role
//      model and a native session id, and receives a validated envelope;
//   3. the role maps to a session-level `pi.setModel` binding;
//   4. failure (non-zero worker, malformed/missing output) is reported without
//      claiming phase success;
//   5. cancellation stops the worker and leaves no orphan process.
//
// The child `exec` uses the pinned Pi implementation when PI_EXEC_MODULE points
// at its `dist/core/exec.js`; otherwise a faithful local equivalent is used so
// the proof runs standalone. No model/network call is made.
//
// Run: node test/proof.mjs

import assert from "node:assert/strict";
import {spawn} from "node:child_process";
import {existsSync, mkdtempSync, readFileSync, writeFileSync} from "node:fs";
import {tmpdir} from "node:os";
import {dirname, join} from "node:path";
import {fileURLToPath} from "node:url";
import {
  BoundedWorkers,
  createPiWorkflow,
  parseReturnEnvelope,
  parseReviewArgs,
  resolvePhaseModel,
  runParallelReview,
} from "../src/workflow.ts";

const here = dirname(fileURLToPath(import.meta.url));
const fakeWorker = join(here, "fake-worker.mjs");
const workdir = mkdtempSync(join(tmpdir(), "pi-sdd-workflow-proof-"));
const logPath = join(workdir, "worker.log");
const pidPath = join(workdir, "worker.pid");
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const passed = [];

function ok(label, condition) {
  assert.ok(condition, `assertion failed: ${label}`);
  passed.push(label);
}

function localExec(command, args, options = {}) {
  return new Promise((resolve) => {
    const child = spawn(command, args, {
      cwd: options.cwd ?? process.cwd(),
      shell: false,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let stdout = "";
    let stderr = "";
    let killed = false;
    let timer;
    const kill = () => {
      if (!killed) {
        killed = true;
        child.kill("SIGTERM");
        const force = setTimeout(() => {
          try {
            child.kill("SIGKILL");
          } catch {
            // already gone
          }
        }, 5000);
        force.unref?.();
      }
    };
    if (options.signal) {
      if (options.signal.aborted) kill();
      else options.signal.addEventListener("abort", kill, {once: true});
    }
    if (options.timeout) timer = setTimeout(kill, options.timeout);
    child.stdout?.on("data", (data) => (stdout += data.toString()));
    child.stderr?.on("data", (data) => (stderr += data.toString()));
    child.on("close", (code) => {
      if (timer) clearTimeout(timer);
      resolve({stdout, stderr, code: code ?? 0, killed});
    });
    child.on("error", () => {
      if (timer) clearTimeout(timer);
      resolve({stdout, stderr, code: 1, killed});
    });
  });
}

let execSource = "local";

async function loadExec() {
  const modulePath = process.env.PI_EXEC_MODULE;
  if (modulePath) {
    const mod = await import(modulePath);
    if (typeof mod.execCommand !== "function") {
      throw new Error(`PI_EXEC_MODULE did not export execCommand: ${modulePath}`);
    }
    execSource = "pinned-pi";
    return (command, args, options) =>
      mod.execCommand(command, args, options?.cwd ?? process.cwd(), options);
  }
  return localExec;
}

function createFakePi(exec) {
  const commands = {};
  const handlers = {};
  const entries = [];
  const setModelCalls = [];
  let flagValue;
  const pi = {
    registerFlag(name, options) {
      if (name === "sdd-role" && flagValue === undefined) flagValue = options.default;
    },
    getFlag(name) {
      return name === "sdd-role" ? flagValue : undefined;
    },
    registerCommand(name, options) {
      commands[name] = options;
    },
    on(event, handler) {
      (handlers[event] ??= []).push(handler);
    },
    appendEntry(type, data) {
      entries.push({type, data});
    },
    exec,
    setModel(model) {
      setModelCalls.push(model);
      return Promise.resolve(true);
    },
  };
  return {pi, commands, handlers, entries, setModelCalls, setFlag: (value) => (flagValue = value)};
}

function createContext() {
  return {
    cwd: workdir,
    hasUI: true,
    signal: undefined,
    modelRegistry: {
      find(provider, modelId) {
        return {provider, id: modelId};
      },
    },
    ui: {
      notifications: [],
      notify(message, level) {
        this.notifications.push({message, level});
      },
    },
  };
}

function readLog() {
  if (!existsSync(logPath)) return [];
  return readFileSync(logPath, "utf8")
    .trim()
    .split("\n")
    .filter(Boolean)
    .map((line) => JSON.parse(line));
}

function pidAlive(pid) {
  try {
    process.kill(pid, 0);
    return true;
  } catch {
    return false;
  }
}

const exec = await loadExec();

const policy = {
  models: {
    "sdd-standard": "anthropic/claude-sonnet-4-6",
    "sdd-design": "anthropic/claude-opus-4-7",
    "sdd-archive": "anthropic/claude-haiku-4-5-20251001",
  },
  phaseRoles: {
    "sdd-design": "sdd-design",
    "sdd-apply": "sdd-standard",
  },
};

const designCommand = {
  name: "sdd-design",
  phase: "sdd-design",
  role: "sdd-design",
  description: "Run the sdd-design SDD phase",
  writePolicy: {mode: "workspace-write", allowEdit: true, allowBash: true},
};

const config = {
  envelopeVersion: "aytordev.sdd-result/v1",
  policy,
  commands: [designCommand],
  skillsRoot: join(workdir, "skills"),
  workerCommand: process.execPath,
  workerArgsPrefix: [fakeWorker],
  workerTimeoutMs: 30_000,
  engine: null,
};

const fake = createFakePi(exec);
const workflow = createPiWorkflow(fake.pi, config);

// 0. Policy resolution ---------------------------------------------------------
{
  const resolved = resolvePhaseModel(policy, "sdd-design");
  ok("resolves the design phase to the design role", resolved.role === "sdd-design");
  ok("resolves the design model from the policy", resolved.model === "anthropic/claude-opus-4-7");
  let threw = false;
  try {
    resolvePhaseModel(policy, "sdd-missing");
  } catch {
    threw = true;
  }
  ok("unknown phase fails with a named error", threw);
}

// 1. Registration --------------------------------------------------------------
ok("registers the phase command", typeof fake.commands["sdd-design"]?.handler === "function");
ok("registers the cancel command", typeof fake.commands["sdd-cancel"]?.handler === "function");
ok("omits the status command when no engine is configured", fake.commands["sdd-status"] === undefined);

process.env.FAKE_WORKER_LOG = logPath;

// 2. Dispatch + result ---------------------------------------------------------
{
  process.env.FAKE_WORKER_MODE = "ok";
  writeFileSync(logPath, "");
  const ctx = createContext();
  const result = await fake.commands["sdd-design"].handler("implement tasks 1.1-1.3", ctx);

  const log = readLog();
  ok("dispatched exactly one worker", log.length === 1);
  ok("worker received the resolved role", log[0].role === "sdd-design");
  ok("worker received the resolved model on argv", log[0].argModel === "anthropic/claude-opus-4-7");
  ok("worker received the resolved model in context", log[0].model === "anthropic/claude-opus-4-7");
  ok("worker received a native session id", /^[0-9a-f-]{36}$/.test(log[0].sessionId ?? ""));
  ok("returns a successful result", result.ok === true && result.status === "success");
  ok("parses the return envelope", result.envelope?.artifacts?.[0] === "fake/artifact");
  ok("reports success to the UI", ctx.ui.notifications.some((n) => n.level === "info"));

  const dispatch = fake.entries.find((entry) => entry.type === "sdd-dispatch");
  const recorded = fake.entries.filter((entry) => entry.type === "sdd-result").at(-1);
  ok("persists the dispatch with the native session id", dispatch?.data?.sessionId === log[0].sessionId);
  ok("persists the result entry", recorded?.data?.status === "success" && recorded?.data?.ok === true);
}

// 3. Role -> session-level model binding --------------------------------------
{
  fake.setFlag("sdd-design");
  const ctx = createContext();
  await fake.handlers["session_start"][0]({reason: "startup"}, ctx);
  ok(
    "session_start applies the role model with pi.setModel",
    fake.setModelCalls.length === 1 &&
      fake.setModelCalls[0]?.provider === "anthropic" &&
      fake.setModelCalls[0]?.id === "claude-opus-4-7",
  );
  const sessionEntry = fake.entries.filter((entry) => entry.type === "sdd-session").at(-1);
  ok("records the session binding", sessionEntry?.data?.applied === true);
  fake.setFlag(undefined);
}

// 4. Failure is reported without claiming success -----------------------------
{
  process.env.FAKE_WORKER_MODE = "fail";
  writeFileSync(logPath, "");
  const ctx = createContext();
  const result = await fake.commands["sdd-design"].handler("this must fail", ctx);
  ok("non-zero worker does not succeed", result.ok === false);
  ok("non-zero worker is not reported as success", result.status !== "success");
  ok("failure is reported to the UI as an error", ctx.ui.notifications.some((n) => n.level === "error"));
  const recorded = fake.entries.filter((entry) => entry.type === "sdd-result").at(-1);
  ok("persisted result does not claim success", recorded?.data?.ok === false && recorded?.data?.status !== "success");
}

// 4b. Missing worker / malformed envelope -------------------------------------
{
  process.env.FAKE_WORKER_MODE = "ok";
  const broken = createFakePi(exec);
  createPiWorkflow(broken.pi, {
    ...config,
    workerArgsPrefix: [join(here, "missing-worker.mjs")],
    workerTimeoutMs: 5_000,
  });
  const ctx = createContext();
  const result = await broken.commands["sdd-design"].handler("", ctx);
  ok("a missing worker binary fails without success", result.ok === false && result.status === "error");

  let rejected = false;
  try {
    parseReturnEnvelope("not an envelope", "aytordev.sdd-result/v1");
  } catch {
    rejected = true;
  }
  ok("rejects a malformed envelope", rejected);
}

// 5. Cancellation leaves no orphan process ------------------------------------
{
  process.env.FAKE_WORKER_MODE = "slow";
  process.env.FAKE_WORKER_PID_FILE = pidPath;
  const ctx = createContext();
  const running = fake.commands["sdd-design"].handler("long running", ctx);

  let pid = null;
  for (let attempt = 0; attempt < 100; attempt++) {
    if (existsSync(pidPath)) {
      pid = Number(readFileSync(pidPath, "utf8").trim());
      break;
    }
    await sleep(20);
  }
  ok("slow worker started", Number.isInteger(pid) && pid > 0);
  ok("worker is alive before cancellation", pidAlive(pid));

  workflow.cancelAll();
  const result = await running;
  ok("cancellation is reported", result.cancelled === true && result.ok === false);
  ok("cancelled status is explicit", result.status === "cancelled");
  ok("worker pool is empty after cancellation", workflow.workers.activeCount === 0);

  let aliveAfter = true;
  for (let attempt = 0; attempt < 100; attempt++) {
    if (!pidAlive(pid)) {
      aliveAfter = false;
      break;
    }
    await sleep(20);
  }
  ok("cancellation leaves no orphan worker", !aliveAfter);
}

// 6. Parallel blind review (judgment-day) -------------------------------------
{
  const reviewPolicy = {
    ...policy,
    models: {...policy.models, "sdd-review": "anthropic/claude-opus-4-7"},
  };
  const reviewConfig = {...config, policy: reviewPolicy};
  const calls = [];
  const captureExec = async (_command, args) => {
    calls.push(args);
    const result = {
      schema: "aytordev.sdd-result/v1",
      status: "success",
      executive_summary: "judge complete",
      artifacts: [],
      next_recommended: "none",
      risks: "None",
      skill_resolution: "paths-injected",
    };
    const event = {
      type: "message_end",
      message: {role: "assistant", content: [{type: "text", text: JSON.stringify(result)}]},
    };
    return {stdout: `${JSON.stringify(event)}\n`, stderr: "", code: 0, killed: false};
  };
  const workers = new BoundedWorkers(captureExec, reviewConfig);
  const parsed = parseReviewArgs("src/foo.ts --revision=deadbeef");
  ok(
    "parses the review target and revision",
    parsed?.target === "src/foo.ts" && parsed?.revision === "deadbeef",
  );
  const review = await runParallelReview(workers, reviewConfig, parsed);
  ok("dispatches exactly two judges", calls.length === 2 && review.judges.length === 2);
  const envelopeOf = (args) => args[args.length - 1];
  ok("both judges receive an identical target envelope", envelopeOf(calls[0]) === envelopeOf(calls[1]));
  ok("the shared envelope pins the revision", envelopeOf(calls[0]).includes("Revision: deadbeef"));
  const sessionOf = (args) => args[args.indexOf("--session-id") + 1];
  ok("judges use distinct native session ids", sessionOf(calls[0]) !== sessionOf(calls[1]));
  ok("review resolves only after both judges finish", review.complete === true && review.judges.every((j) => j.ok));

  // One failing judge must not suppress the other result.
  const failCalls = [];
  const failExec = async (_command, args) => {
    const index = failCalls.length;
    failCalls.push(args);
    if (index === 0) {
      return {stdout: "", stderr: "judge exploded", code: 2, killed: false};
    }
    const event = {
      type: "message_end",
      message: {role: "assistant", content: [{type: "text", text: JSON.stringify({
        schema: "aytordev.sdd-result/v1",
        status: "success",
        executive_summary: "surviving judge",
        artifacts: [],
        next_recommended: "none",
        risks: "None",
        skill_resolution: "paths-injected",
      })}]},
    };
    return {stdout: `${JSON.stringify(event)}\n`, stderr: "", code: 0, killed: false};
  };
  const failWorkers = new BoundedWorkers(failExec, reviewConfig);
  const partial = await runParallelReview(failWorkers, reviewConfig, {target: "x", revision: "r"});
  ok("a failed judge is reported and does not hide the other", partial.judges.length === 2 && partial.complete === false);
}

console.log(`exec: ${execSource}`);
console.log(`proof: ${passed.length} assertions passed`);
for (const label of passed) {
  console.log(`  ok - ${label}`);
}
console.log("PROOF OK");
