import type {ExtensionAPI, ExtensionContext} from "@earendil-works/pi-coding-agent";
import {McpHost} from "./src/host.ts";
import {bridgeConfig} from "./servers.ts";

/**
 * Pi MCP bridge.
 *
 * Pi has no built-in MCP (client-capabilities.md PI-E1/PI-E8), so MCP tools are
 * projected as native Pi tools here. Because they are registered through
 * `pi.registerTool`, every call passes through Pi's normal `tool_call` event
 * chain (and therefore any installed permission gate) instead of bypassing it.
 *
 * Processes are not started at extension load (docs/extensions.md: "Long-lived
 * resources and shutdown"). Servers connect on `session_start`, and every
 * connection is closed on `session_shutdown`, so unselected servers are never
 * spawned and disabled Pi emits no bridge at all.
 */
export default function piMcpBridge(pi: ExtensionAPI): void {
  const host = new McpHost(bridgeConfig);
  let ready: Promise<void> = Promise.resolve();

  pi.on("session_start", async (_event: {reason: string}, ctx: ExtensionContext) => {
    ready = (async () => {
      let tools;
      try {
        tools = await host.listTools();
      } catch (error) {
        ctx.ui.notify(`MCP bridge failed to initialize: ${describe(error)}`, "error");
        return;
      }

      for (const tool of tools) {
        pi.registerTool({
          name: tool.piName,
          label: `MCP ${tool.server}/${tool.name}`,
          description:
            tool.description ||
            `MCP tool "${tool.name}" provided by the "${tool.server}" server.`,
          promptSnippet: `Call the "${tool.name}" tool on the "${tool.server}" MCP server`,
          // `inputSchema` is already JSON Schema; Pi accepts non-TypeBox schemas
          // (pi-ai validateToolArguments handles the JSON-Schema path).
          parameters: tool.inputSchema as never,
          async execute(_toolCallId, params, signal) {
            return host.callTool(tool.piName, params as Record<string, unknown>, {signal});
          },
        });
      }

      const errors = host.serverErrors();
      const failed = Object.keys(errors);
      if (failed.length > 0) {
        ctx.ui.notify(
          `MCP bridge: ${failed.length} server(s) unavailable (${failed.join(", ")})`,
          "warning",
        );
      }
    })();
    await ready;
  });

  pi.registerCommand("mcp-status", {
    description: "List bridged MCP servers and tools",
    handler: async (_args: string, ctx: ExtensionContext) => {
      await ready;
      ctx.ui.notify(JSON.stringify(host.status()), "info");
    },
  });

  pi.on("session_shutdown", async () => {
    await host.close();
  });
}

function describe(error: unknown): string {
  if (error instanceof Error) {
    return error.message;
  }
  return String(error);
}
