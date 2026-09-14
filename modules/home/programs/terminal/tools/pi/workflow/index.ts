import type {ExtensionAPI} from "@earendil-works/pi-coding-agent";
import {workflowConfig} from "./config.ts";
import {createPiWorkflow, type PiLike} from "./src/workflow.ts";

/**
 * Pi SDD workflow extension entry point (T05).
 *
 * The real behavior lives in `src/workflow.ts`, which is free of Pi imports so
 * it can be exercised by a scripted Node proof. This file only bridges the
 * pinned `ExtensionAPI` into that module.
 */
export default function piSddWorkflow(pi: ExtensionAPI): void {
  createPiWorkflow(pi as unknown as PiLike, workflowConfig);
}
