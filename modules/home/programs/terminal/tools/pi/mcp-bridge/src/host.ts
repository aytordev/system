import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import {
  StdioClientTransport,
} from "@modelcontextprotocol/sdk/client/stdio.js";
import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";

/**
 * Transport-level bridge between Pi and selected MCP stdio servers.
 *
 * This module owns process lifecycle and MCP <-> Pi conversion. It is
 * deliberately free of Pi imports so it can be exercised by a plain Node test
 * harness (see `test/proof.mjs`) against a fake stdio server.
 */

export const BRIDGE_NAME = "aytordev-pi-mcp-bridge";
export const BRIDGE_VERSION = "0.1.0";

export const DEFAULT_CONNECT_TIMEOUT_MS = 15_000;
export const DEFAULT_REQUEST_TIMEOUT_MS = 60_000;
export const MAX_TOOL_NAME_LENGTH = 64;

export interface ServerDefinition {
  command: string;
  args?: string[];
  env?: Record<string, string | {file: string}>;
}

export interface BridgeConfig {
  servers: Record<string, ServerDefinition>;
  connectTimeoutMs?: number;
  requestTimeoutMs?: number;
}

export interface McpToolDefinition {
  /** Catalog server name this tool belongs to. */
  server: string;
  /** Raw tool name as advertised by the MCP server. */
  name: string;
  /** Sanitized, unique name exposed to Pi. */
  piName: string;
  description: string;
  /** MCP `inputSchema` (already JSON Schema). */
  inputSchema: Record<string, unknown>;
}

export type PiToolContent =
  | {type: "text"; text: string}
  | {type: "image"; data: string; mimeType: string};

export interface PiToolResult {
  content: PiToolContent[];
  details: Record<string, unknown>;
}

export class McpBridgeError extends Error {
  server: string | undefined;
  tool: string | undefined;

  constructor(message: string, options: {server?: string; tool?: string} = {}) {
    super(message);
    this.name = "McpBridgeError";
    this.server = options.server;
    this.tool = options.tool;
  }
}

interface ServerConnection {
  client: Client;
  transport: StdioClientTransport;
}

function describeError(error: unknown): string {
  if (error instanceof Error) {
    return error.message || error.name;
  }
  return String(error);
}

function sanitizeToolName(name: string): string {
  return name.replace(/[^A-Za-z0-9_-]/g, "_");
}

function toPiToolName(server: string, tool: string): string {
  const base = `mcp_${sanitizeToolName(server)}_${sanitizeToolName(tool)}`;
  if (base.length <= MAX_TOOL_NAME_LENGTH) {
    return base;
  }
  const digest = createHash("sha1").update(`${server}\u0000${tool}`).digest("hex").slice(0, 8);
  return `${base.slice(0, MAX_TOOL_NAME_LENGTH - digest.length - 1)}_${digest}`;
}

async function resolveEnvironment(
  env: ServerDefinition["env"],
): Promise<Record<string, string>> {
  const resolved: Record<string, string> = {};
  for (const [key, value] of Object.entries(env ?? {})) {
    if (typeof value === "string") {
      resolved[key] = value;
      continue;
    }
    try {
      resolved[key] = (await readFile(value.file, "utf8")).trim();
    } catch (error) {
      throw new McpBridgeError(
        `failed to read MCP environment file for ${key} (${value.file}): ${describeError(error)}`,
      );
    }
  }
  return resolved;
}

export class McpHost {
  #config: BridgeConfig;
  #connectTimeoutMs: number;
  #requestTimeoutMs: number;
  #connections = new Map<string, ServerConnection>();
  #tools = new Map<string, McpToolDefinition>();
  #errors = new Map<string, string>();
  #closed = false;

  constructor(config: BridgeConfig) {
    this.#config = config;
    this.#connectTimeoutMs = config.connectTimeoutMs ?? DEFAULT_CONNECT_TIMEOUT_MS;
    this.#requestTimeoutMs = config.requestTimeoutMs ?? DEFAULT_REQUEST_TIMEOUT_MS;
  }

  serverNames(): string[] {
    return Object.keys(this.#config.servers).sort();
  }

  serverErrors(): Record<string, string> {
    return Object.fromEntries(this.#errors);
  }

  /** Names of the tools currently exposed to Pi. */
  toolNames(): string[] {
    return [...this.#tools.keys()].sort();
  }

  private async connect(name: string): Promise<ServerConnection> {
    if (this.#closed) {
      throw new McpBridgeError("MCP bridge is closed");
    }
    const existing = this.#connections.get(name);
    if (existing) {
      return existing;
    }
    const definition = this.#config.servers[name];
    if (!definition) {
      throw new McpBridgeError(`unknown MCP server "${name}"`);
    }

    const env = await resolveEnvironment(definition.env);
    const transport = new StdioClientTransport({
      command: definition.command,
      args: definition.args ?? [],
      env,
      stderr: "inherit",
    });
    // A dead server must not be reused: drop the cached connection so the next
    // call reconnects, and surface the failure to the tool caller.
    transport.onclose = () => {
      if (this.#connections.get(name)?.transport === transport) {
        this.#connections.delete(name);
      }
    };
    transport.onerror = (error) => {
      this.#errors.set(name, describeError(error));
    };

    const client = new Client(
      {name: BRIDGE_NAME, version: BRIDGE_VERSION},
      {capabilities: {}},
    );

    try {
      await client.connect(transport, {timeout: this.#connectTimeoutMs});
    } catch (error) {
      try {
        await transport.close();
      } catch {
        // best effort
      }
      throw new McpBridgeError(
        `failed to connect MCP server "${name}": ${describeError(error)}`,
        {server: name},
      );
    }

    const connection = {client, transport};
    this.#connections.set(name, connection);
    return connection;
  }

  /**
   * Connect every configured server, list its tools, and refresh the Pi tool
   * index. A server that fails to start is reported but does not prevent the
   * remaining selected servers from working.
   */
  async listTools(options: {signal?: AbortSignal} = {}): Promise<McpToolDefinition[]> {
    const tools = new Map<string, McpToolDefinition>();
    for (const name of this.serverNames()) {
      try {
        const connection = await this.connect(name);
        const result = await connection.client.listTools(undefined, {
          signal: options.signal,
          timeout: this.#requestTimeoutMs,
        });
        this.#errors.delete(name);
        for (const tool of result.tools) {
          const piName = this.#uniqueToolName(tools, name, tool.name);
          tools.set(piName, {
            server: name,
            name: tool.name,
            piName,
            description: tool.description ?? "",
            inputSchema: (tool.inputSchema ?? {type: "object"}) as Record<string, unknown>,
          });
        }
      } catch (error) {
        this.#errors.set(name, describeError(error));
      }
    }
    this.#tools = tools;
    return [...tools.values()];
  }

  #uniqueToolName(
    tools: Map<string, McpToolDefinition>,
    server: string,
    tool: string,
  ): string {
    const base = toPiToolName(server, tool);
    if (!tools.has(base)) {
      return base;
    }
    for (let suffix = 2; ; suffix++) {
      const candidate = `${base.slice(0, MAX_TOOL_NAME_LENGTH - String(suffix).length - 1)}_${suffix}`;
      if (!tools.has(candidate)) {
        return candidate;
      }
    }
  }

  /** Call a bridged tool and convert the MCP result into Pi content. */
  async callTool(
    piName: string,
    args: Record<string, unknown>,
    options: {signal?: AbortSignal} = {},
  ): Promise<PiToolResult> {
    const definition = this.#tools.get(piName);
    if (!definition) {
      throw new McpBridgeError(`unknown MCP tool "${piName}"`);
    }
    const connection = await this.connect(definition.server);
    try {
      const result = await connection.client.callTool(
        {name: definition.name, arguments: args},
        undefined,
        {signal: options.signal, timeout: this.#requestTimeoutMs},
      );
      return this.#toPiResult(definition, result);
    } catch (error) {
      if (error instanceof McpBridgeError) {
        throw error;
      }
      throw new McpBridgeError(
        `MCP tool ${definition.server}/${definition.name} failed: ${describeError(error)}`,
        {server: definition.server, tool: definition.name},
      );
    }
  }

  #toPiResult(definition: McpToolDefinition, rawResult: unknown): PiToolResult {
    const result = rawResult as {
      content?: Array<Record<string, unknown>>;
      structuredContent?: Record<string, unknown>;
      isError?: boolean;
    };
    const content: PiToolContent[] = [];
    for (const block of result.content ?? []) {
      const type = block.type;
      if (type === "text" && typeof block.text === "string") {
        content.push({type: "text", text: block.text});
      } else if (type === "image" && typeof block.data === "string") {
        content.push({
          type: "image",
          data: block.data,
          mimeType: typeof block.mimeType === "string" ? block.mimeType : "application/octet-stream",
        });
      } else if (type === "audio") {
        content.push({type: "text", text: `[audio ${String(block.mimeType ?? "unknown")} omitted]`});
      } else if (type === "resource") {
        content.push({type: "text", text: renderResource(block.resource)});
      } else if (type === "resource_link") {
        content.push({
          type: "text",
          text: `[resource ${String(block.uri ?? "")}] ${String(block.name ?? "")}`.trim(),
        });
      }
    }
    if (result.structuredContent) {
      content.push({type: "text", text: JSON.stringify(result.structuredContent, null, 2)});
    }

    const details = {
      server: definition.server,
      tool: definition.name,
      isError: result.isError === true,
    };

    if (result.isError) {
      const text = content
        .filter((block): block is {type: "text"; text: string} => block.type === "text")
        .map((block) => block.text)
        .join("\n");
      throw new McpBridgeError(
        `MCP tool ${definition.server}/${definition.name} reported an error: ${text || "(no message)"}`,
        {server: definition.server, tool: definition.name},
      );
    }

    if (content.length === 0) {
      content.push({type: "text", text: "(MCP tool returned no content)"});
    }

    return {content, details};
  }

  /** Human/JSON summary used by the diagnostics command. */
  status(): Record<string, unknown> {
    return {
      servers: this.serverNames().map((name) => ({
        name,
        connected: this.#connections.has(name),
        error: this.#errors.get(name) ?? null,
      })),
      tools: this.toolNames(),
    };
  }

  async close(): Promise<void> {
    if (this.#closed) {
      return;
    }
    this.#closed = true;
    const connections = [...this.#connections.values()];
    this.#connections.clear();
    this.#tools.clear();
    await Promise.all(
      connections.map(async ({client, transport}) => {
        try {
          await client.close();
        } catch {
          // each transport is closed below; ignore client-level errors
        }
        try {
          await transport.close();
        } catch {
          // best effort
        }
      }),
    );
  }
}

function renderResource(resource: unknown): string {
  if (resource && typeof resource === "object") {
    const record = resource as Record<string, unknown>;
    const uri = typeof record.uri === "string" ? record.uri : "";
    if (typeof record.text === "string") {
      return uri ? `${uri}\n${record.text}` : record.text;
    }
    if (typeof record.blob === "string") {
      return `[binary resource ${uri} (${record.blob.length} base64 chars)]`;
    }
    return `[resource ${uri}]`;
  }
  return "[resource]";
}
