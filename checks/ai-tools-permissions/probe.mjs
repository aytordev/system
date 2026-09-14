#!/usr/bin/env node
// Disposable permission probe for T10.
//
// It exercises the effective OpenCode permission rules with the client's real
// matching semantics and uses a temporary write target to show that an
// ask/deny edit is never written silently. It also loads the Pi workflow
// adapter to prove the two blind judges receive an identical target envelope
// and isolated sessions, and it asserts the configured Pi deny rules while
// reporting that Pi enforcement is unverified (the third-party gate is not
// provisioned by Nix — client-capabilities.md blocker 1).
//
// Run: node probe.mjs <report.json>
// Env: WORKFLOW_DIR points at the Pi workflow source being tested.

import assert from "node:assert/strict";
import {existsSync, mkdtempSync, mkdirSync, readFileSync, writeFileSync} from "node:fs";
import {tmpdir} from "node:os";
import {join} from "node:path";
import {pathToFileURL} from "node:url";

// ── OpenCode matching semantics ────────────────────────────────────────────
// Copied from the pinned OpenCode 1.18.30 source
// (`@opencode-ai/core/util/wildcard` + `Permission.evaluate`). The evaluator
// uses `findLast`, so the last matching rule wins; Home Manager serializes the
// permission attrset in sorted key order.

function wildcardMatch(input, pattern) {
  const normalized = input.replaceAll("\\", "/");
  let escaped = pattern
    .replaceAll("\\", "/")
    .replace(/[.+^${}()|[\]\\]/g, "\\$&")
    .replace(/\*/g, ".*")
    .replace(/\?/g, ".");
  if (escaped.endsWith(" .*")) escaped = escaped.slice(0, -3) + "( .*)?";
  return new RegExp("^" + escaped + "$", "s").test(normalized);
}

function fromConfig(permission) {
  const ruleset = [];
  for (const [key, value] of Object.entries(permission)) {
    if (typeof value === "string") {
      ruleset.push({permission: key, action: value, pattern: "*"});
      continue;
    }
    ruleset.push(...Object.entries(value).map(([pattern, action]) => ({permission: key, pattern, action})));
  }
  return ruleset;
}

// The built-in defaults always precede the global and agent rulesets, and
// include a catch-all `allow` (verified in the shipped binary).
const DEFAULTS = fromConfig({"*": "allow"});

function evaluate(permission, pattern, ...rulesets) {
  return (
    rulesets
      .flat()
      .findLast((rule) => wildcardMatch(permission, rule.permission) && wildcardMatch(pattern, rule.pattern)) ?? {
      action: "ask",
      permission,
      pattern: "*",
    }
  );
}

const data = JSON.parse(readFileSync(process.argv[2], "utf8"));
const globalRules = fromConfig(data.opencode.global);
const reviewRules = fromConfig(data.opencode.reviewAgent);
const standardRules = fromConfig(data.opencode.standardAgent ?? {});

const workdir = mkdtempSync(join(tmpdir(), "ai-tools-permissions-"));
const target = join(workdir, "target.txt");
const passed = [];

function ok(label, condition) {
  assert.ok(condition, `assertion failed: ${label}`);
  passed.push(label);
}

const bashGlobal = (command) => evaluate("bash", command, DEFAULTS, globalRules).action;
const bashReview = (command) => evaluate("bash", command, DEFAULTS, globalRules, reviewRules).action;

// ── File route: disposable write probe ─────────────────────────────────────
{
  const globalEdit = evaluate("edit", target, DEFAULTS, globalRules).action;
  ok("the global file edit is gated (ask), not allowed", globalEdit === "ask");

  const reviewEdit = evaluate("edit", target, DEFAULTS, globalRules, reviewRules).action;
  ok("the reviewer role denies file edits", reviewEdit === "deny");

  // Mirror the client's blocking gate: a probe only writes when the resolved
  // action is `allow`. An `ask`/`deny` must leave the temp target untouched.
  let writes = 0;
  const attemptWrite = (action) => {
    if (action === "allow") {
      writeFileSync(target, "silent write");
      writes += 1;
    }
  };
  attemptWrite(globalEdit);
  attemptWrite(reviewEdit);
  ok("an ask/deny edit is not silently performed", writes === 0 && !existsSync(target));

  // A read is allowed and observes content.
  writeFileSync(target, "review-me");
  const readAction = evaluate("read", target, DEFAULTS, globalRules).action;
  ok("a read is allowed", readAction === "allow");
  ok("a read observes the target", readFileSync(target, "utf8") === "review-me");
}

// ── Shell route: read-only allowed, mutating gated ─────────────────────────
{
  const readOnly = [
    "git status",
    "git log --oneline -5",
    "git diff HEAD",
    "git show HEAD",
    "git branch -a",
    "git branch --show-current",
    "git remote -v",
    "git remote show origin",
    "git config --get user.name",
    "git config --list",
    "git tag --list",
    "ls -la",
    "cat target.txt",
    "rg needle",
  ];
  ok("read-only shell commands are allowed", readOnly.every((c) => bashGlobal(c) === "allow"));

  const mutating = [
    "git branch -D feature",
    "git branch new-branch",
    "git remote add origin url",
    "git remote set-url origin url",
    "git config user.name someone",
    "git config --global user.name someone",
    "git commit -m change",
    "git add .",
    "git tag v1",
    "git push",
    "git reset --hard",
    "rm -rf build",
    "mkdir new-dir",
    "chmod +x script.sh",
    "mv a b",
    "cp a b",
    "touch new-file",
  ];
  ok("mutating shell commands are gated (ask)", mutating.every((c) => bashGlobal(c) === "ask"));

  ok("the reviewer shell is denied", bashReview("git status") === "deny" && bashReview("ls") === "deny");
}

// ── MCP route ──────────────────────────────────────────────────────────────
{
  const mcpRead = evaluate("read", "mcp:engram:mcp:resource://note", DEFAULTS, globalRules).action;
  ok("MCP resource reads follow the read rule (allowed)", mcpRead === "allow");
  // Arbitrary MCP tool calls are filtered by tool name against the merged
  // ruleset and were not traced to a dedicated key (blocker 7). The review
  // role only hardens `edit`/`bash`, so an MCP tool call is not guaranteed
  // read-only — documented residual risk, asserted here for visibility.
  const mcpTool = evaluate("engram_write", "engram_write", DEFAULTS, globalRules, reviewRules);
  ok("MCP tool calls have no dedicated deny in this configuration", mcpTool.action === "allow");
}

// ── Pi configured rules and residual risk ──────────────────────────────────
{
  const pi = data.pi.permission;
  ok("Pi denies secret reads", pi.path_read["~/.ssh/*"] === "deny" && pi.path_read["*.key"] === "deny");
  ok("Pi denies secret writes", pi.path_write["~/.ssh/*"] === "deny" && pi.path_write["*.pem"] === "deny");
  ok("Pi denies lockfile writes", pi.path_write["package-lock.json"] === "deny" && pi.path_write["pnpm-lock.yaml"] === "deny");
  ok(
    "Pi denies destructive shell",
    pi.bash["sudo *"] === "deny" && pi.bash["rm -rf *"] === "deny" && pi.bash["git push --force *"] === "deny",
  );
  ok("Pi still falls back to allow for unlisted actions", pi.path_write["*"] === "allow" && pi.bash["*"] === "allow");
  console.log(
    "residual risk: Pi permission enforcement is the third-party @gotgenes/pi-permission-system, whose code is not provisioned by Nix; the deny rules above are asserted, not executed. A Pi judge is therefore advisory read-only, not an enforced one.",
  );
}

// ── Two blind judges receive identical targets (Pi adapter) ─────────────────
{
  const workflow = await import(pathToFileURL(join(process.env.WORKFLOW_DIR, "src/workflow.ts")).href);
  const calls = [];
  const fakeExec = async (_command, args) => {
    calls.push(args);
    const envelope = {
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
      message: {role: "assistant", content: [{type: "text", text: JSON.stringify(envelope)}]},
    };
    return {stdout: `${JSON.stringify(event)}\n`, stderr: "", code: 0, killed: false};
  };
  const reviewConfig = {
    envelopeVersion: "aytordev.sdd-result/v1",
    policy: {models: {"sdd-review": "anthropic/claude-opus-4-7"}, phaseRoles: {}},
    commands: [],
    skillsRoot: join(workdir, "skills"),
    workerCommand: process.execPath,
    workerTimeoutMs: 5000,
    engine: null,
  };
  const workers = new workflow.BoundedWorkers(fakeExec, reviewConfig);
  const target = {target: "src/example.ts", revision: "abc123def"};
  const result = await workflow.runParallelReview(workers, reviewConfig, target);
  ok("exactly two judges are dispatched", calls.length === 2 && result.judges.length === 2);
  const envelopeOf = (args) => args[args.length - 1];
  ok(
    "both judges receive an identical target and revision",
    envelopeOf(calls[0]) === envelopeOf(calls[1])
      && envelopeOf(calls[0]).includes("Target: src/example.ts")
      && envelopeOf(calls[0]).includes("Revision: abc123def"),
  );
  const sessionOf = (args) => args[args.indexOf("--session-id") + 1];
  ok("judges are isolated behind distinct native session ids", sessionOf(calls[0]) !== sessionOf(calls[1]));
  ok("review resolves only after both judges settle", result.complete === true);

  // Bounded failure: a failing judge does not suppress the survivor.
  const failCalls = [];
  const failExec = async (_command, args) => {
    failCalls.push(args);
    if (failCalls.length === 1) {
      return {stdout: "", stderr: "judge failed", code: 2, killed: false};
    }
    const event = {
      type: "message_end",
      message: {role: "assistant", content: [{type: "text", text: JSON.stringify({
        schema: "aytordev.sdd-result/v1",
        status: "success",
        executive_summary: "survivor",
        artifacts: [],
        next_recommended: "none",
        risks: "None",
        skill_resolution: "paths-injected",
      })}]},
    };
    return {stdout: `${JSON.stringify(event)}\n`, stderr: "", code: 0, killed: false};
  };
  const failWorkers = new workflow.BoundedWorkers(failExec, reviewConfig);
  const partial = await workflow.runParallelReview(failWorkers, reviewConfig, {target: "x", revision: "r"});
  ok("a failed judge is reported without hiding the other", partial.judges.length === 2 && partial.complete === false);
}

console.log(`permission probe: ${passed.length} assertions passed`);
for (const label of passed) {
  console.log(`  ok - ${label}`);
}
console.log("PROBE OK");
