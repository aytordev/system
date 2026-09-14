import type {WorkflowConfig} from "./src/workflow.ts";

/**
 * Placeholder config for local development. The Home Manager module overwrites
 * this file in the deployed extension with data generated from `aiTools.roles`
 * (phase commands, role -> native model, skills root, worker binary, engine
 * adapter). The deployed copy is immutable Nix output; runtime state lives in
 * Pi sessions via `pi.appendEntry`, never here.
 */
export const workflowConfig: WorkflowConfig = {
  envelopeVersion: "aytordev.sdd-result/v1",
  policy: {
    models: {},
    phaseRoles: {},
  },
  commands: [],
  skillsRoot: "",
  workerCommand: "pi",
  engine: null,
};
