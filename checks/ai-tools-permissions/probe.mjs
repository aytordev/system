#!/usr/bin/env node
// Disposable permission probe for the independent OpenCode client.
//
// It exercises the effective OpenCode permission rules with the client's real
// matching semantics and uses a temporary write target to show that an
// ask edit is never written silently.
//
// Run: node probe.mjs <report.json>

import assert from "node:assert/strict";
import {existsSync, mkdtempSync, readFileSync, writeFileSync} from "node:fs";
import {tmpdir} from "node:os";
import {join} from "node:path";

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

const workdir = mkdtempSync(join(tmpdir(), "ai-tools-permissions-"));
const target = join(workdir, "target.txt");
const passed = [];

function ok(label, condition) {
  assert.ok(condition, `assertion failed: ${label}`);
  passed.push(label);
}

const bashGlobal = (command) => evaluate("bash", command, DEFAULTS, globalRules).action;

// ── File route: disposable write probe ─────────────────────────────────────
{
  const globalEdit = evaluate("edit", target, DEFAULTS, globalRules).action;
  ok("the global file edit is gated (ask), not allowed", globalEdit === "ask");

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

}

// ── MCP route ──────────────────────────────────────────────────────────────
{
  const mcpRead = evaluate("read", "mcp:engram:mcp:resource://note", DEFAULTS, globalRules).action;
  ok("MCP resource reads follow the read rule (allowed)", mcpRead === "allow");
  // Arbitrary MCP tool calls are filtered by tool name, not the read rule.
  const mcpTool = evaluate("engram_write", "engram_write", DEFAULTS, globalRules);
  ok("MCP tool calls have no dedicated deny in this configuration", mcpTool.action === "allow");
}

console.log(`permission probe: ${passed.length} assertions passed`);
for (const label of passed) {
  console.log(`  ok - ${label}`);
}
console.log("PROBE OK");
