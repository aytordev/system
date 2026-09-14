/**
 * Pi SDD workflow adapter (T05).
 *
 * Pi has no native subagents, background delegation, or per-agent model
 * (client-capabilities.md PI-E1/E4). This module implements those through the
 * supported extension APIs only:
 *
 *   - `pi.registerCommand`   phase entry points (one per `aiTools.roles.phases`)
 *                            plus `judgment-day`, which runs two blind judges
 *   - `pi.exec`              bounded child worker (a real, isolated Pi process)
 *   - `pi.setModel`          role -> session-level model (no per-agent model)
 *   - `pi.appendEntry`       active session state, separate from Nix config
 *   - `ctx.signal`/`abort`   cancellation of the enclosing turn
 *   - `session_shutdown`     cancel every in-flight worker
 *
 * The module is deliberately free of Pi imports and network/model calls so a
 * plain Node harness can drive it with a scripted fake worker (see
 * `test/proof.mjs`). `index.ts` is the thin Pi wiring.
 *
 * It does NOT implement a state engine: artifact readiness and phase
 * transitions come from the `aytordev-sdd` adapter (T27) via `/sdd-status`.
 */

export interface ModelRef {
  provider?: string;
  model: string;
}

export interface RolePolicy {
  /** role name -> resolved native model id, e.g. `anthropic/claude-opus-4-7`. */
  models: Record<string, string>;
  /** ordered phase name -> role name. */
  phaseRoles: Record<string, string>;
}

export interface WritePolicy {
  mode: "read-only" | "artifacts-only" | "workspace-write";
  allowEdit: boolean;
  allowBash: boolean;
}

export interface WorkflowCommand {
  name: string;
  phase: string;
  role: string;
  description: string;
  writePolicy: WritePolicy;
}

export interface WorkflowConfig {
  envelopeVersion: string;
  policy: RolePolicy;
  commands: WorkflowCommand[];
  /** Pi skills root, e.g. `~/.pi/agent/skills`. */
  skillsRoot: string;
  /** Absolute path to the child-worker executable (the pinned `pi` binary). */
  workerCommand: string;
  /** Optional argv prefix, used to substitute a fake worker in tests. */
  workerArgsPrefix?: string[];
  workerTimeoutMs?: number;
  /** `aytordev-sdd` adapter path, or null when the engine is not enabled. */
  engine?: string | null;
}

export interface SddEnvelope {
  schema: string;
  status: "success" | "partial" | "blocked";
  executive_summary: string;
  artifacts: string[];
  next_recommended: string;
  risks: string;
  skill_resolution: string;
  detailed_report?: string;
}

export type DispatchStatus = SddEnvelope["status"] | "cancelled" | "error";

export interface DispatchResult {
  ok: boolean;
  phase: string;
  role: string;
  model: string;
  sessionId: string;
  status: DispatchStatus;
  envelope: SddEnvelope | null;
  error: string | null;
  exitCode: number | null;
  cancelled: boolean;
}

export interface WorkerExecResult {
  stdout: string;
  stderr: string;
  code: number;
  killed: boolean;
}

export type WorkerExec = (
  command: string,
  args: string[],
  options?: {signal?: AbortSignal; timeout?: number; cwd?: string},
) => Promise<WorkerExecResult>;

/** Minimal structural view of the Pi extension API this adapter consumes. */
export interface PiLike {
  registerFlag(
    name: string,
    options: {description?: string; type: "string"; default?: string},
  ): void;
  getFlag(name: string): boolean | string | undefined;
  registerCommand(
    name: string,
    options: {description?: string; handler: (args: string, ctx: CommandContext) => Promise<unknown> | unknown},
  ): void;
  on(event: string, handler: (event: unknown, ctx: CommandContext) => unknown): void;
  appendEntry(customType: string, data?: unknown): void;
  exec(command: string, args: string[], options?: {signal?: AbortSignal; timeout?: number; cwd?: string}): Promise<WorkerExecResult>;
  setModel(model: unknown): Promise<boolean>;
}

export interface CommandContext {
  cwd: string;
  signal?: AbortSignal;
  hasUI: boolean;
  ui: {notify(message: string, level: "info" | "warning" | "error"): void};
  modelRegistry: {find(provider: string, modelId: string): unknown};
}

export const DEFAULT_WORKER_TIMEOUT_MS = 10 * 60 * 1000;
const ENVELOPE_FENCE = /```(?:json)?\s*([\s\S]*?)```/i;

export class PolicyError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "PolicyError";
  }
}

export class EnvelopeError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "EnvelopeError";
  }
}

/** Split a native `provider/model` id; a bare id keeps its provider unset. */
export function splitNativeModelId(nativeId: string): ModelRef {
  const slash = nativeId.indexOf("/");
  if (slash <= 0 || slash === nativeId.length - 1) {
    return {model: nativeId};
  }
  return {provider: nativeId.slice(0, slash), model: nativeId.slice(slash + 1)};
}

/**
 * Resolve a phase to its role and native model using the shared policy
 * (`aiTools.roles`). `overrides` is `{role: nativeModelId}` as accepted by
 * `roles.resolveAll`. Unknown phases/roles/models fail with a named error; no
 * model is silently substituted.
 */
export function resolvePhaseModel(
  policy: RolePolicy,
  phase: string,
  overrides: Record<string, string> = {},
): {role: string; model: string} {
  const role = policy.phaseRoles[phase];
  if (!role) {
    throw new PolicyError(`ai-tools role policy: no role mapped for phase '${phase}'`);
  }
  const model = overrides[role] ?? policy.models[role];
  if (!model) {
    throw new PolicyError(`ai-tools role policy: no model resolved for role '${role}'`);
  }
  return {role, model};
}

export interface EnvelopeContext {
  scope: string;
  role: string;
  model: string;
  schema: string;
  skillsRoot: string;
  engine: string | null;
}

/** Build the isolated child context injected as the worker's prompt. */
export function buildChildEnvelope(command: WorkflowCommand, context: EnvelopeContext): string {
  const skillBase = context.skillsRoot.replace(/\/+$/, "");
  const skillPaths = [
    `${skillBase}/${command.phase}/SKILL.md`,
    `${skillBase}/_shared/skill-loading.md`,
    `${skillBase}/_shared/persistence-contract.md`,
    `${skillBase}/_shared/sdd-phase-common.md`,
    `${skillBase}/_shared/return-envelope.md`,
  ];
  const edit = command.writePolicy.allowEdit ? "allowed" : "denied";
  const bash = command.writePolicy.allowBash ? "allowed" : "denied";
  const engine = context.engine ?? "not configured — do not attempt engine calls";

  return [
    `# SDD phase: ${command.phase}`,
    "",
    "## Deployment context",
    "",
    `- schema: ${context.schema}`,
    `- role: ${context.role}`,
    `- model: ${context.model}`,
    `- artifact store engine: ${engine}`,
    "",
    "## Task scope",
    "",
    context.scope.length > 0 ? context.scope : "No explicit scope — operate on the active change.",
    "",
    "## Skills to load before work",
    "",
    "Read these exact files before reading, writing, reviewing, testing, or creating artifacts.",
    "Follow the index-first protocol in `_shared/skill-loading.md`; these paths are injected, so",
    "do not substitute registry summaries for the originals:",
    "",
    ...skillPaths.map((path) => `- ${path}`),
    "",
    "## Write policy",
    "",
    `- mode: ${command.writePolicy.mode}`,
    `- edit: ${edit}`,
    `- shell: ${bash}`,
    "",
    "## Evidence requirements",
    "",
    "- Run each relevant focused check and report the exact command and observed result.",
    "- Tie results to the files/artifacts changed in this invocation; a previous pass is not evidence.",
    "- Do not claim a step succeeded unless it was actually executed and observed.",
    "- Report a blocker or partial result honestly; never report `success` for unverified work.",
    "",
    "## Return envelope (required)",
    "",
    "End your final message with exactly one fenced json object and no trailing prose:",
    "",
    "```json",
    JSON.stringify(
      {
        schema: context.schema,
        status: "success|partial|blocked",
        executive_summary: "1-3 sentence summary",
        artifacts: ["artifact keys/paths written"],
        next_recommended: "sdd-<phase>|none",
        risks: "risks, or None",
        skill_resolution: "paths-injected|fallback-registry|fallback-path|none",
        detailed_report: "optional full output",
      },
      null,
      2,
    ),
    "```",
    "",
    "You are an executor, not an orchestrator: do not launch other agents. The parent owns the",
    "workflow lifecycle and the phase transition.",
  ].join("\n");
}

function describeError(error: unknown): string {
  if (error instanceof Error) {
    return error.message || error.name;
  }
  return String(error);
}

function renderMessageText(message: unknown): string | null {
  if (!message || typeof message !== "object") {
    return null;
  }
  const content = (message as {content?: unknown}).content;
  if (typeof content === "string") {
    return content;
  }
  if (Array.isArray(content)) {
    const parts = content
      .filter((block): block is {type: string; text: string} =>
        Boolean(block) &&
        typeof block === "object" &&
        (block as {type?: unknown}).type === "text" &&
        typeof (block as {text?: unknown}).text === "string",
      )
      .map((block) => block.text);
    return parts.length > 0 ? parts.join("\n") : null;
  }
  return null;
}

/**
 * Extract the worker's final assistant text from `pi --mode json` output, or
 * fall back to raw stdout for scripted workers that print the envelope directly.
 */
export function extractAssistantText(stdout: string): string | null {
  const events: unknown[] = [];
  for (const line of stdout.split("\n")) {
    const trimmed = line.trim();
    if (!trimmed.startsWith("{")) {
      continue;
    }
    try {
      events.push(JSON.parse(trimmed));
    } catch {
      // Partial/non-JSON line — ignore and keep scanning.
    }
  }

  let text: string | null = null;
  for (const event of events) {
    const record = event as {type?: unknown; message?: unknown};
    if (record.type === "message_end") {
      const message = record.message as {role?: unknown} | undefined;
      if (message?.role === "assistant") {
        const rendered = renderMessageText(message);
        if (rendered) {
          text = rendered;
        }
      }
    }
  }
  if (text) {
    return text;
  }

  for (const event of events) {
    const record = event as {type?: unknown; messages?: unknown};
    if (record.type === "agent_end" && Array.isArray(record.messages)) {
      for (const message of record.messages) {
        if ((message as {role?: unknown})?.role === "assistant") {
          const rendered = renderMessageText(message);
          if (rendered) {
            text = rendered;
          }
        }
      }
    }
  }
  if (text) {
    return text;
  }

  const raw = stdout.trim();
  return raw.length > 0 ? raw : null;
}

function extractJsonObject(text: string): unknown {
  const fenced = text.match(ENVELOPE_FENCE);
  const candidate = fenced ? fenced[1] : text;
  try {
    return JSON.parse(candidate.trim());
  } catch {
    // Fall back to the last brace-delimited object in the message.
  }
  const start = candidate.lastIndexOf("{");
  const end = candidate.lastIndexOf("}");
  if (start >= 0 && end > start) {
    try {
      return JSON.parse(candidate.slice(start, end + 1));
    } catch {
      // fall through to the named error
    }
  }
  throw new EnvelopeError("worker output does not contain a parseable JSON envelope");
}

/** Parse and validate the versioned return envelope. */
export function parseReturnEnvelope(text: string, schema: string): SddEnvelope {
  const parsed = extractJsonObject(text);
  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
    throw new EnvelopeError("return envelope is not a JSON object");
  }
  const envelope = parsed as Record<string, unknown>;
  if (envelope.schema !== schema) {
    throw new EnvelopeError(`return envelope schema '${String(envelope.schema)}' does not match '${schema}'`);
  }
  const status = envelope.status;
  if (status !== "success" && status !== "partial" && status !== "blocked") {
    throw new EnvelopeError(`return envelope status '${String(status)}' is not success|partial|blocked`);
  }
  if (typeof envelope.executive_summary !== "string" || envelope.executive_summary.length === 0) {
    throw new EnvelopeError("return envelope is missing 'executive_summary'");
  }
  if (!Array.isArray(envelope.artifacts)) {
    throw new EnvelopeError("return envelope is missing 'artifacts'");
  }
  if (typeof envelope.next_recommended !== "string") {
    throw new EnvelopeError("return envelope is missing 'next_recommended'");
  }
  if (typeof envelope.risks !== "string") {
    throw new EnvelopeError("return envelope is missing 'risks'");
  }
  if (typeof envelope.skill_resolution !== "string") {
    throw new EnvelopeError("return envelope is missing 'skill_resolution'");
  }
  return {
    schema,
    status,
    executive_summary: envelope.executive_summary,
    artifacts: envelope.artifacts.map(String),
    next_recommended: envelope.next_recommended,
    risks: envelope.risks,
    skill_resolution: envelope.skill_resolution,
    detailed_report:
      typeof envelope.detailed_report === "string" ? envelope.detailed_report : undefined,
  };
}

function combineSignals(signals: (AbortSignal | undefined)[]): AbortSignal {
  const list = signals.filter((signal): signal is AbortSignal => Boolean(signal));
  if (list.length === 0) {
    return new AbortController().signal;
  }
  if (list.length === 1) {
    return list[0];
  }
  const anySignal = (AbortSignal as unknown as {any?: (signals: AbortSignal[]) => AbortSignal}).any;
  if (typeof anySignal === "function") {
    return anySignal(list);
  }
  const controller = new AbortController();
  for (const signal of list) {
    if (signal.aborted) {
      controller.abort();
      break;
    }
    signal.addEventListener("abort", () => controller.abort(), {once: true});
  }
  return controller.signal;
}

export interface DispatchSpec {
  phase: string;
  role: string;
  model: string;
  sessionId: string;
  envelope: string;
  cwd?: string;
}

/**
 * Bounded child-worker pool. Every dispatch owns one abort controller so
 * `/sdd-cancel` and `session_shutdown` can terminate all in-flight workers;
 * the enclosing turn's `ctx.signal` is combined in for Esc cancellation.
 */
export class BoundedWorkers {
  readonly #exec: WorkerExec;
  readonly #config: WorkflowConfig;
  readonly #active = new Map<string, AbortController>();

  constructor(exec: WorkerExec, config: WorkflowConfig) {
    this.#exec = exec;
    this.#config = config;
  }

  get activeCount(): number {
    return this.#active.size;
  }

  activeSessions(): string[] {
    return [...this.#active.keys()];
  }

  async dispatch(spec: DispatchSpec, externalSignal?: AbortSignal): Promise<DispatchResult> {
    const controller = new AbortController();
    this.#active.set(spec.sessionId, controller);
    const signal = combineSignals([externalSignal, controller.signal]);
    const base = {
      phase: spec.phase,
      role: spec.role,
      model: spec.model,
      sessionId: spec.sessionId,
    };
    const args = [
      ...(this.#config.workerArgsPrefix ?? []),
      "--print",
      "--mode",
      "json",
      // Initial session model (Pi is session-scoped, not per-agent). Passing it
      // here makes an unavailable model a named startup error instead of a
      // silent fallback; the child also re-applies it with `pi.setModel` from
      // the `--sdd-role` flag, which is how the role policy reaches the session.
      "--model",
      spec.model,
      "--sdd-role",
      spec.role,
      "--session-id",
      spec.sessionId,
      spec.envelope,
    ];

    try {
      const result = await this.#exec(this.#config.workerCommand, args, {
        signal,
        timeout: this.#config.workerTimeoutMs ?? DEFAULT_WORKER_TIMEOUT_MS,
        cwd: spec.cwd,
      });

      if (signal.aborted || (result.killed && signal.aborted)) {
        return {
          ...base,
          ok: false,
          status: "cancelled",
          envelope: null,
          error: "worker cancelled",
          exitCode: result.code ?? null,
          cancelled: true,
        };
      }
      if (result.killed) {
        return {
          ...base,
          ok: false,
          status: "error",
          envelope: null,
          error: "worker was terminated before returning a result (timeout or external signal)",
          exitCode: result.code ?? null,
          cancelled: false,
        };
      }
      if (result.code !== 0) {
        const detail = result.stderr.trim();
        return {
          ...base,
          ok: false,
          status: "error",
          envelope: null,
          error: `worker exited with code ${result.code}${detail ? `: ${detail}` : ""}`,
          exitCode: result.code,
          cancelled: false,
        };
      }

      const text = extractAssistantText(result.stdout);
      if (!text) {
        throw new EnvelopeError("worker produced no assistant output");
      }
      const envelope = parseReturnEnvelope(text, this.#config.envelopeVersion);
      const ok = envelope.status === "success";
      return {
        ...base,
        ok,
        status: envelope.status,
        envelope,
        error: ok ? null : `phase reported '${envelope.status}'`,
        exitCode: result.code,
        cancelled: false,
      };
    } catch (error) {
      return {
        ...base,
        ok: false,
        status: "error",
        envelope: null,
        error: describeError(error),
        exitCode: null,
        cancelled: false,
      };
    } finally {
      this.#active.delete(spec.sessionId);
    }
  }

  cancel(sessionId: string): void {
    this.#active.get(sessionId)?.abort();
  }

  cancelAll(): void {
    for (const controller of [...this.#active.values()]) {
      controller.abort();
    }
  }
}

/** The shared role the `judgment-day` command resolves its judges to. */
export const REVIEW_ROLE = "sdd-review";

export interface ReviewTarget {
  /** What the judges review (files, feature, or architecture). */
  target: string;
  /** Pinned revision both judges review. Identical for both judges. */
  revision: string;
  /** Optional custom criteria, injected into both judges identically. */
  criteria?: string;
}

export interface ParallelReviewResult {
  target: string;
  revision: string;
  /** Exactly two judge results; both settle before this resolves. */
  judges: DispatchResult[];
  /** False when either judge reported a transport/parse error (no verdict). */
  complete: boolean;
}

/** Parse `/judgment-day <target...> [--revision=<rev>]`. */
export function parseReviewArgs(args: string): ReviewTarget | null {
  const tokens = args.trim().split(/\s+/).filter(Boolean);
  if (tokens.length === 0) {
    return null;
  }
  let revision = "HEAD";
  const positional: string[] = [];
  for (const token of tokens) {
    if (token.startsWith("--revision=")) {
      revision = token.slice("--revision=".length) || revision;
    } else {
      positional.push(token);
    }
  }
  const target = positional.join(" ");
  return target.length > 0 ? {target, revision} : null;
}

/**
 * Build the byte-identical envelope handed to both blind judges. Target and
 * revision are identical; the only per-judge value (the native session id) is
 * passed on argv by `BoundedWorkers.dispatch`, never inside the envelope, so a
 * judge cannot see or reach the other judge's context.
 */
export function buildJudgeEnvelope(
  target: ReviewTarget,
  context: Omit<EnvelopeContext, "scope">,
): string {
  const custom =
    target.criteria && target.criteria.trim().length > 0
      ? `\n## Custom criteria\n\n${target.criteria.trim()}\n`
      : "";
  return buildChildEnvelope(
    {
      name: "judgment-day",
      phase: "judgment-day",
      role: context.role,
      description: "Blind adversarial judge",
      writePolicy: {mode: "read-only", allowEdit: false, allowBash: false},
    },
    {...context, scope: `Target: ${target.target}\nRevision: ${target.revision}${custom}`},
  );
}

/**
 * Launch two independent blind judges over the same target and revision and
 * wait for BOTH to settle before returning. A judge receives no other judge's
 * findings; the caller synthesizes. Pi has no built-in subagents, so the two
 * judges are bounded child workers with distinct native session ids. Failure
 * is bounded: a failed/timed-out judge becomes an error result and never
 * blocks the surviving judge from settling.
 */
export async function runParallelReview(
  workers: BoundedWorkers,
  config: WorkflowConfig,
  target: ReviewTarget,
  externalSignal?: AbortSignal,
): Promise<ParallelReviewResult> {
  const model = config.policy.models[REVIEW_ROLE];
  if (!model) {
    throw new PolicyError(`ai-tools role policy: no model resolved for role '${REVIEW_ROLE}'`);
  }
  const envelope = buildJudgeEnvelope(target, {
    role: REVIEW_ROLE,
    model,
    schema: config.envelopeVersion,
    skillsRoot: config.skillsRoot,
    engine: config.engine ?? null,
  });
  const dispatches = [crypto.randomUUID(), crypto.randomUUID()].map((sessionId) =>
    workers.dispatch(
      {phase: "judgment-day", role: REVIEW_ROLE, model, sessionId, envelope},
      externalSignal,
    ),
  );
  const settled = await Promise.allSettled(dispatches);
  const judges: DispatchResult[] = settled.map((entry, index) =>
    entry.status === "fulfilled"
      ? entry.value
      : {
          ok: false,
          phase: "judgment-day",
          role: REVIEW_ROLE,
          model,
          sessionId: `judge-${index + 1}`,
          status: "error",
          envelope: null,
          error: describeError(entry.reason),
          exitCode: null,
          cancelled: false,
        },
  );
  return {
    target: target.target,
    revision: target.revision,
    judges,
    complete: judges.every((judge) => judge.status !== "error" && judge.status !== "cancelled"),
  };
}

export interface SessionModelBinding {
  role: string;
  model: string | null;
  applied: boolean;
  error: string | null;
}

/**
 * Apply a role's model to the *current* session with `pi.setModel`. Pi has no
 * per-agent model (PI-E4), so the child worker re-applies its role here at
 * `session_start` from the `--sdd-role` flag.
 */
export async function applySessionRole(
  pi: PiLike,
  ctx: CommandContext,
  policy: RolePolicy,
  role: string,
): Promise<SessionModelBinding> {
  const model = policy.models[role] ?? null;
  if (!model) {
    return {role, model: null, applied: false, error: `ai-tools role policy: unknown role '${role}'`};
  }
  const reference = splitNativeModelId(model);
  if (!reference.provider) {
    return {role, model, applied: false, error: `model '${model}' is missing a provider prefix`};
  }
  const found = ctx.modelRegistry.find(reference.provider, reference.model);
  if (!found) {
    return {role, model, applied: false, error: `model '${model}' is unavailable in the Pi model registry`};
  }
  const applied = await pi.setModel(found);
  return {
    role,
    model,
    applied,
    error: applied ? null : `no authentication configured for '${model}'`,
  };
}

export interface PiWorkflow {
  commands: string[];
  workers: BoundedWorkers;
  cancelAll(): void;
}

export interface PhaseRunOptions {
  scope: string;
  cwd?: string;
  signal?: AbortSignal;
}

/**
 * Register the Pi SDD workflow surface. Returns the registered command names
 * and the worker pool so tests and shutdown handlers can drive/cancel it.
 */
export function createPiWorkflow(pi: PiLike, config: WorkflowConfig): PiWorkflow {
  const workers = new BoundedWorkers(pi.exec.bind(pi), config);

  pi.registerFlag("sdd-role", {
    description: "Run this session as the named ai-tools SDD role (sets the session model).",
    type: "string",
  });

  pi.on("session_start", async (_event, ctx) => {
    const role = pi.getFlag("sdd-role");
    if (typeof role !== "string" || role.length === 0) {
      return;
    }
    const binding = await applySessionRole(pi, ctx, config.policy, role);
    pi.appendEntry("sdd-session", binding);
  });

  pi.on("session_shutdown", () => {
    workers.cancelAll();
  });

  const runPhase = async (
    command: WorkflowCommand,
    args: string,
    ctx: CommandContext,
  ): Promise<DispatchResult> => {
    const {role, model} = resolvePhaseModel(config.policy, command.phase);
    const sessionId = crypto.randomUUID();
    const envelope = buildChildEnvelope(command, {
      scope: args.trim(),
      role,
      model,
      schema: config.envelopeVersion,
      skillsRoot: config.skillsRoot,
      engine: config.engine ?? null,
    });

    pi.appendEntry("sdd-dispatch", {
      phase: command.phase,
      role,
      model,
      sessionId,
      scope: args.trim(),
      writePolicy: command.writePolicy,
    });

    const result = await workers.dispatch(
      {phase: command.phase, role, model, sessionId, envelope, cwd: ctx.cwd},
      ctx.signal,
    );

    pi.appendEntry("sdd-result", {
      phase: command.phase,
      role,
      model,
      sessionId,
      ok: result.ok,
      status: result.status,
      cancelled: result.cancelled,
      error: result.error,
      artifacts: result.envelope?.artifacts ?? [],
      next_recommended: result.envelope?.next_recommended ?? null,
    });

    if (ctx.hasUI) {
      if (result.cancelled) {
        ctx.ui.notify(`${command.phase}: cancelled`, "warning");
      } else if (result.ok) {
        const summary = result.envelope?.executive_summary ?? "completed";
        ctx.ui.notify(`${command.phase}: ${result.status} — ${summary}`, "info");
      } else {
        ctx.ui.notify(`${command.phase} failed: ${result.error ?? result.status}`, "error");
      }
    }

    return result;
  };

  for (const command of config.commands) {
    pi.registerCommand(command.name, {
      description: command.description,
      handler: (args: string, ctx: CommandContext) => runPhase(command, args, ctx),
    });
  }

  // Two blind read-only judges over one pinned target revision. The correction
  // lane is a separate delegation; this command never writes.
  pi.registerCommand("judgment-day", {
    description:
      "Run two independent blind read-only judges over the same target revision and return both results.",
    handler: async (args: string, ctx: CommandContext) => {
      const target = parseReviewArgs(args);
      if (!target) {
        if (ctx.hasUI) {
          ctx.ui.notify("judgment-day: provide a target, e.g. /judgment-day src/foo.ts --revision=HEAD", "warning");
        }
        return {ok: false, error: "missing review target"};
      }
      pi.appendEntry("sdd-review-start", target);
      let result: ParallelReviewResult;
      try {
        result = await runParallelReview(workers, config, target, ctx.signal);
      } catch (error) {
        const message = describeError(error);
        pi.appendEntry("sdd-review-result", {target: target.target, revision: target.revision, complete: false, error: message});
        if (ctx.hasUI) {
          ctx.ui.notify(`judgment-day failed: ${message}`, "error");
        }
        return {ok: false, error: message};
      }
      pi.appendEntry("sdd-review-result", {
        target: result.target,
        revision: result.revision,
        complete: result.complete,
        judges: result.judges.map((judge) => ({
          sessionId: judge.sessionId,
          status: judge.status,
          ok: judge.ok,
          summary: judge.envelope?.executive_summary ?? null,
        })),
      });
      if (ctx.hasUI) {
        if (!result.complete) {
          ctx.ui.notify("judgment-day: a judge failed; both settled — synthesis needs manual review", "error");
        } else {
          ctx.ui.notify(`judgment-day: both judges finished for ${result.target}@${result.revision}`, "info");
        }
      }
      return result;
    },
  });

  if (config.engine) {
    const engine = config.engine;
    pi.registerCommand("sdd-status", {
      description: "Read SDD artifact/phase status from the aytordev-sdd engine adapter.",
      handler: async (args: string, ctx: CommandContext) => {
        const change = args.trim();
        const engineArgs = change.length > 0 ? ["status", change, "--json"] : ["status", "--json"];
        const result = await pi.exec(engine, engineArgs, {
          signal: ctx.signal,
          cwd: ctx.cwd,
        });
        if (result.code !== 0) {
          if (ctx.hasUI) {
            ctx.ui.notify(`sdd-status failed: ${result.stderr.trim() || `exit ${result.code}`}`, "error");
          }
          return {ok: false, output: result.stderr};
        }
        if (ctx.hasUI) {
          ctx.ui.notify(result.stdout.trim() || "(no status)", "info");
        }
        return {ok: true, output: result.stdout};
      },
    });
  }

  pi.registerCommand("sdd-cancel", {
    description: "Cancel every in-flight SDD child worker.",
    handler: (_args: string, ctx: CommandContext) => {
      const count = workers.activeCount;
      workers.cancelAll();
      if (ctx.hasUI) {
        ctx.ui.notify(`Cancelled ${count} SDD worker(s)`, "warning");
      }
      return {cancelled: count};
    },
  });

  return {
    commands: config.commands.map((command) => command.name),
    workers,
    cancelAll: () => workers.cancelAll(),
  };
}
