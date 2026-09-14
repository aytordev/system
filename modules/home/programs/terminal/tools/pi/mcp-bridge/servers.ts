import type {BridgeConfig} from "./src/host.ts";

// Inert default so the bridge package loads on its own. The Nix module rewrites
// this file with the catalog servers selected for Pi (`selection.pi`), so a
// deployed bridge only ever contains the chosen subset.
export const bridgeConfig: BridgeConfig = {servers: {}};
