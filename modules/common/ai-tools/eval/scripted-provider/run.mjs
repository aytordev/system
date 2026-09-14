// T16 scripted-provider evaluation runner.
//
// Exercises real client command/transport paths against the loopback
// OpenAI-compatible fixture in `fixture-server.mjs`, with no paid calls and no
// external network. Three scenarios:
//
//   1. pi-direct             real `pi --print --mode json` reaches the fixture
//                            through a custom `openai-completions` provider;
//   2. pi-workflow-delegation real Pi SDD workflow `BoundedWorkers.dispatch`
//                            spawns a real `pi` child worker that reaches the
//                            fixture and returns a parsed `sdd-result/v1`;
//   3. opencode-direct       real `opencode run` reaches the fixture through a
//                            custom `@ai-sdk/openai-compatible` provider.
//
// Run (from anywhere):
//   node modules/common/ai-tools/eval/scripted-provider/run.mjs [--out FILE]
//
// Env overrides: PI_BIN, OPENCODE_BIN. Defaults resolve `pi`/`opencode` on PATH.
// This is a developer/evaluation harness, not a Nix check: the aarch64-darwin
// Nix build sandbox denies `listen` with EPERM (see README.md).

import {spawn} from "node:child_process";
import {randomUUID} from "node:crypto";
import {cpSync, mkdirSync, mkdtempSync, readFileSync, writeFileSync} from "node:fs";
import {tmpdir} from "node:os";
import {dirname, join, resolve} from "node:path";
import {fileURLToPath, pathToFileURL} from "node:url";
import {SCRIPTED_ENVELOPE, startFixture} from "./fixture-server.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(here, "../../../../..");
const workflowDir = join(repoRoot, "modules/home/programs/terminal/tools/pi/workflow");
const workflowTs = join(workflowDir, "src/workflow.ts");

const PI_BIN = process.env.PI_BIN ?? "pi";
const OPENCODE_BIN = process.env.OPENCODE_BIN ?? "opencode";

const results = [];
let failures = 0;

function record(scenario, detail, ok) {
  results.push({scenario, ok, ...detail});
  if (!ok) failures += 1;
  console.log(`[${ok ? "ok" : "FAIL"}] ${scenario}: ${JSON.stringify(detail)}`);
}

function run(command, args, {cwd, env = {}, timeoutMs = 120_000} = {}) {
  return new Promise((resolvePromise) => {
    const child = spawn(command, args, {
      cwd,
      env: {...process.env, ...env},
      stdio: ["ignore", "pipe", "pipe"],
    });
    let stdout = "";
    let stderr = "";
    const timer = setTimeout(() => child.kill("SIGKILL"), timeoutMs);
    child.stdout.on("data", (d) => (stdout += d.toString()));
    child.stderr.on("data", (d) => (stderr += d.toString()));
    child.on("close", (code) => {
      clearTimeout(timer);
      resolvePromise({code: code ?? 0, stdout, stderr});
    });
    child.on("error", (error) => {
      clearTimeout(timer);
      resolvePromise({code: 127, stdout, stderr: `${stderr}\n${error.message}`});
    });
  });
}

function writePiConfig(agentDir, baseUrl) {
  mkdirSync(agentDir, {recursive: true});
  writeFileSync(
    join(agentDir, "models.json"),
    JSON.stringify({
      providers: {
        scripted: {
          baseUrl,
          api: "openai-completions",
          apiKey: "scripted",
          compat: {supportsDeveloperRole: false, supportsReasoningEffort: false},
          models: [
            {id: "scripted-model", name: "Scripted", contextWindow: 100000, maxTokens: 8000},
            {id: "scripted-role", name: "Scripted Role", contextWindow: 100000, maxTokens: 8000},
          ],
        },
      },
    }),
  );
  writeFileSync(
    join(agentDir, "settings.json"),
    JSON.stringify({defaultProvider: "scripted", defaultModel: "scripted-model", enableInstallTelemetry: false}),
  );
}

// Deploy the real Pi SDD workflow extension into the fixture agent dir so the
// child worker accepts `--sdd-role` (registered by the extension). This mirrors
// what the Home Manager module writes to `~/.pi/agent/extensions/sdd-workflow`.
function installWorkflowExtension(agentDir) {
  const extDir = join(agentDir, "extensions/sdd-workflow");
  mkdirSync(join(extDir, "src"), {recursive: true});
  cpSync(join(workflowDir, "index.ts"), join(extDir, "index.ts"));
  cpSync(join(workflowDir, "package.json"), join(extDir, "package.json"));
  cpSync(workflowTs, join(extDir, "src/workflow.ts"));
  const config = `import type {WorkflowConfig} from "./src/workflow.ts";
export const workflowConfig: WorkflowConfig = {
  envelopeVersion: "aytordev.sdd-result/v1",
  policy: {models: {"sdd-design": "scripted/scripted-role", "sdd-review": "scripted/scripted-role"},
           phaseRoles: {"sdd-design": "sdd-design"}},
  commands: [],
  skillsRoot: ${JSON.stringify(join(agentDir, "skills"))},
  workerCommand: ${JSON.stringify(PI_BIN)},
  workerTimeoutMs: 120000,
  engine: null,
} as WorkflowConfig;
`;
  writeFileSync(join(extDir, "config.ts"), config);
}

function writeOpencodeConfig(configDir, baseUrl) {
  mkdirSync(join(configDir, "opencode"), {recursive: true});
  writeFileSync(
    join(configDir, "opencode", "opencode.json"),
    JSON.stringify({
      $schema: "https://opencode.ai/config.json",
      provider: {
        scripted: {
          npm: "@ai-sdk/openai-compatible",
          name: "Scripted",
          options: {baseURL: baseUrl, apiKey: "scripted"},
          models: {"scripted-model": {name: "Scripted"}},
        },
      },
    }),
  );
}

function containsEnvelope(text) {
  return text.includes("aytordev.sdd-result/v1") && text.includes("status");
}

async function main() {
  const piVersion = (await run(PI_BIN, ["--version"], {timeoutMs: 30_000})).stdout.trim();
  const opencodeVersion = (await run(OPENCODE_BIN, ["--version"], {timeoutMs: 60_000})).stdout.trim();
  console.log(`clients: pi=${piVersion} opencode=${opencodeVersion}`);

  const fixture = await startFixture();
  const baseUrl = `http://127.0.0.1:${fixture.port}/v1`;
  console.log(`fixture listening on ${baseUrl}`);

  // --- 1. Pi direct command/transport -------------------------------------
  {
    const work = mkdtempSync(join(tmpdir(), "sp-pi-direct-"));
    const agentDir = join(work, "agent");
    writePiConfig(agentDir, baseUrl);
    const before = fixture.requests.length;
    const runResult = await run(
      PI_BIN,
      ["--print", "--mode", "json", "--provider", "scripted", "--model", "scripted-model", "Reply with the scripted envelope."],
      {cwd: work, env: {PI_CODING_AGENT_DIR: agentDir, PI_OFFLINE: "1", PI_TELEMETRY: "0"}, timeoutMs: 120_000},
    );
    const requests = fixture.requests.slice(before);
    const sentPrompt = requests.some((r) => JSON.stringify(r.body?.messages ?? []).includes("Reply with the scripted envelope."));
    record(
      "pi-direct",
      {
        exit: runResult.code,
        requests: requests.length,
        sentPrompt,
        returnedEnvelope: containsEnvelope(runResult.stdout),
      },
      runResult.code === 0 && requests.length >= 1 && sentPrompt && containsEnvelope(runResult.stdout),
    );
  }

  // --- 2. Pi workflow delegation through a real child worker ---------------
  {
    const work = mkdtempSync(join(tmpdir(), "sp-pi-workflow-"));
    const agentDir = join(work, "agent");
    writePiConfig(agentDir, baseUrl);
    installWorkflowExtension(agentDir);
    process.env.PI_CODING_AGENT_DIR = agentDir;
    process.env.PI_OFFLINE = "1";
    process.env.PI_TELEMETRY = "0";

    const {BoundedWorkers, buildChildEnvelope} = await import(pathToFileURL(workflowTs).href);
    const config = {
      envelopeVersion: "aytordev.sdd-result/v1",
      policy: {
        models: {"sdd-design": "scripted/scripted-role"},
        phaseRoles: {"sdd-design": "sdd-design"},
      },
      commands: [],
      skillsRoot: join(work, "skills"),
      workerCommand: PI_BIN,
      workerTimeoutMs: 120_000,
      engine: null,
    };
    const command = {
      name: "sdd-design",
      phase: "sdd-design",
      role: "sdd-design",
      description: "scripted design",
      writePolicy: {mode: "read-only", allowEdit: false, allowBash: false},
    };
    const envelope = buildChildEnvelope(command, {
      scope: "scripted-provider evaluation",
      role: "sdd-design",
      model: "scripted/scripted-role",
      schema: config.envelopeVersion,
      skillsRoot: config.skillsRoot,
      engine: null,
    });
    const exec = (cmd, args, options) => run(cmd, args, {cwd: options?.cwd, timeoutMs: options?.timeout ?? 120_000});
    const workers = new BoundedWorkers(exec, config);
    const before = fixture.requests.length;
    const result = await workers.dispatch({
      phase: "sdd-design",
      role: "sdd-design",
      model: "scripted/scripted-role",
      sessionId: randomUUID(),
      envelope,
      cwd: work,
    });
    const requests = fixture.requests.slice(before);
    const delegatedInput = requests.some((r) => JSON.stringify(r.body?.messages ?? []).includes("# SDD phase: sdd-design"));
    record(
      "pi-workflow-delegation",
      {
        requests: requests.length,
        delegatedInput,
        status: result.status,
        ok: result.ok,
        error: result.error,
        parsedEnvelope: result.envelope?.schema === "aytordev.sdd-result/v1",
      },
      result.ok === true && result.envelope?.schema === "aytordev.sdd-result/v1" && delegatedInput,
    );
  }

  // --- 3. OpenCode direct command/transport --------------------------------
  {
    const work = mkdtempSync(join(tmpdir(), "sp-oc-direct-"));
    const home = join(work, "home");
    const configHome = join(home, ".config");
    const dataHome = join(home, ".local/share");
    writeOpencodeConfig(configHome, baseUrl);
    const before = fixture.requests.length;
    const runResult = await run(
      OPENCODE_BIN,
      ["run", "-m", "scripted/scripted-model", "Reply with the scripted envelope."],
      {
        cwd: work,
        env: {
          HOME: home,
          XDG_CONFIG_HOME: configHome,
          XDG_DATA_HOME: dataHome,
          OPENCODE_DISABLE_AUTOUPDATE: "1",
        },
        timeoutMs: 180_000,
      },
    );
    const requests = fixture.requests.slice(before);
    const sentPrompt = requests.some((r) => JSON.stringify(r.body?.messages ?? []).includes("Reply with the scripted envelope."));
    record(
      "opencode-direct",
      {
        exit: runResult.code,
        requests: requests.length,
        sentPrompt,
        returnedEnvelope: containsEnvelope(runResult.stdout),
      },
      runResult.code === 0 && requests.length >= 1 && sentPrompt && containsEnvelope(runResult.stdout),
    );
  }

  await fixture.close();

  const summary = {
    schema: "ai-tools-scripted-provider/v1",
    clients: {pi: piVersion, opencode: opencodeVersion},
    scriptedResult: SCRIPTED_ENVELOPE,
    ok: failures === 0,
    failures,
    scenarios: results,
  };
  const outIndex = process.argv.indexOf("--out");
  if (outIndex >= 0 && process.argv[outIndex + 1]) {
    writeFileSync(process.argv[outIndex + 1], `${JSON.stringify(summary, null, 2)}\n`);
  }
  console.log(JSON.stringify(summary, null, 2));
  if (failures > 0) {
    process.exit(1);
  }
  console.log("SCRIPTED-PROVIDER OK");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
