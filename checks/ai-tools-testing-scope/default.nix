{
  lib,
  pkgs,
  ...
}: let
  # Executable reference for the testing-scope contract in
  # `skills/sdd-init/rules/execution-detect-testing.md` and
  # `execution-strict-tdd-resolution.md`. The mixed fixture proves that roots and
  # commands stay separate and that an explicit Strict TDD request without
  # coverage is reported as blocked instead of downgraded.
  fixture = ./fixtures/mixed-nix-ts;

  # --- Discovery -----------------------------------------------------------

  # A directory is a project root when it contains at least one manifest. A root
  # may hold several manifests (e.g. a flake plus a package.json).
  markers = [
    "flake.nix"
    "package.json"
    "pyproject.toml"
    "pytest.ini"
    "go.mod"
    "Cargo.toml"
    "Makefile"
  ];

  discover = dir: rel: let
    entries = builtins.readDir dir;
    names = builtins.attrNames entries;
    manifests = builtins.filter (m: builtins.hasAttr m entries && entries.${m} == "regular") markers;
    here = lib.optional (manifests != []) {
      path = rel;
      inherit manifests;
    };
    subdirs = builtins.filter (name: entries.${name} == "directory") names;
    childPath = name:
      if rel == "."
      then name
      else "${rel}/${name}";
    children = lib.concatMap (name: discover (dir + "/${name}") (childPath name)) subdirs;
  in
    here ++ children;

  roots = discover fixture ".";

  # --- Command classification ----------------------------------------------

  parseJson = file: let
    attempt =
      if builtins.pathExists file
      then builtins.tryEval (builtins.fromJSON (builtins.readFile file))
      else {
        success = false;
        value = null;
      };
  in
    if attempt.success && builtins.isAttrs attempt.value
    then attempt.value
    else {};

  # A runtime runner is declared by the manifest, never guessed from a stack.
  runnerOf = pkg: let
    deps = (pkg.devDependencies or {}) // (pkg.dependencies or {});
    candidates = builtins.filter (name: builtins.hasAttr name deps) ["vitest" "jest" "mocha" "ava"];
  in
    if candidates == []
    then null
    else builtins.head candidates;

  # `covers` is the root itself unless the manifest declares workspace scope.
  # `covers_workspace` records that declared evidence.
  commandsForRoot = root: let
    dir = fixture + "/${root.path}";
    hasManifest = m: builtins.elem m root.manifests;
    isFlake = hasManifest "flake.nix";
    isPackage = hasManifest "package.json";
    pkg =
      if isPackage
      then parseJson (dir + "/package.json")
      else {};
    runner = runnerOf pkg;
    testScript = pkg.scripts.test or null;
    workspace = builtins.hasAttr "workspaces" pkg;
    covers =
      if workspace
      then ["workspace"]
      else [root.path];
    nixWorkspace = root.path == ".";

    nixCommands = lib.optionals isFlake [
      {
        inherit (root) path;
        working_dir = root.path;
        surface = "nix-eval";
        command = "nix flake check";
        runner = null;
        covers = [root.path];
        covers_workspace = nixWorkspace;
      }
      {
        inherit (root) path;
        working_dir = root.path;
        surface = "nix-build";
        command = "nix build";
        runner = null;
        covers = [root.path];
        covers_workspace = nixWorkspace;
      }
    ];

    runtimeCommands = lib.optional (runner != null || testScript != null) {
      inherit (root) path;
      working_dir = root.path;
      surface = "runtime";
      command =
        if testScript != null
        then "npm test"
        else runner;
      inherit runner;
      inherit covers;
      inherit workspace;
      covers_workspace = workspace;
    };
  in
    nixCommands ++ runtimeCommands;

  capability = lib.concatMap commandsForRoot roots;

  runtimeChecks = builtins.filter (c: c.surface == "runtime") capability;

  # --- Resolution (the schema the SDD rules must produce) ------------------
  # `requested` is the policy; `capability` is measured; `effective` is the
  # result. An explicit request without workspace-wide runtime coverage is
  # blocked, never downgraded.
  resolve = {
    requested,
    checks,
  }: let
    workspace = builtins.filter (c: c.surface == "runtime" && c.covers_workspace) checks;
  in
    if requested == "false"
    then {
      effective = "disabled";
      blocker = null;
      reason = "explicitly disabled";
    }
    else if requested == "true"
    then
      if workspace != []
      then {
        effective = "enabled";
        blocker = null;
        reason = "explicit request with workspace-wide runtime coverage";
      }
      else {
        effective = "blocked";
        blocker = "strict-tdd-requested-without-coverage";
        reason = "no workspace-wide runtime check covers the change scope";
      }
    else if workspace != []
    then {
      effective = "enabled";
      blocker = null;
      reason = "unset request auto-enabled from evidenced coverage";
    }
    else {
      effective = "disabled";
      blocker = null;
      reason = "no workspace-wide runtime check";
    };

  isPrefix = root: unit: root == unit || lib.hasPrefix (root + "/") unit;

  # Per-unit applicability: workspace-wide runtime checks plus those whose covered
  # targets contain the unit path. Never a sibling root's runner.
  applicableRuntime = checks: unit:
    builtins.filter
    (c: c.surface == "runtime" && (c.covers_workspace || lib.any (target: isPrefix target unit) c.covers))
    checks;

  # --- Fixtures and assertions ---------------------------------------------

  syntheticWorkspace =
    runtimeChecks
    ++ [
      {
        path = ".";
        working_dir = ".";
        surface = "runtime";
        command = "npm test --workspaces";
        runner = "vitest";
        covers = ["workspace"];
        covers_workspace = true;
      }
    ];

  expect = condition: message:
    if condition
    then true
    else throw message;

  rootPaths = builtins.sort builtins.lessThan (map (r: r.path) roots);
  runtimeWorkingDirs = builtins.sort builtins.lessThan (map (c: c.working_dir) runtimeChecks);
  surfaces = builtins.sort builtins.lessThan (lib.unique (map (c: c.surface) capability));

  scopeTests = [
    (expect (rootPaths == ["." "packages/core" "packages/web"]) "mixed fixture roots were not discovered separately: ${lib.concatStringsSep ", " rootPaths}")
    (expect (builtins.length runtimeChecks == 2) "expected one runtime check per package, got ${toString (builtins.length runtimeChecks)}")
    (expect (runtimeWorkingDirs == ["packages/core" "packages/web"]) "runtime commands are not associated with their own working directories: ${lib.concatStringsSep ", " runtimeWorkingDirs}")
    (expect (lib.all (c: !c.covers_workspace) runtimeChecks) "a per-package runner was treated as workspace-wide")
    (expect (surfaces == ["nix-build" "nix-eval" "runtime"]) "runtime and Nix surfaces were not kept distinct: ${lib.concatStringsSep ", " surfaces}")
    (expect (lib.all (c: c.surface != "runtime") (builtins.filter (c: c.path == ".") capability)) "a Nix surface on the flake root was counted as a runtime/unit check")
    (expect (map (c: c.working_dir) (applicableRuntime capability "packages/core/src/index.ts") == ["packages/core"]) "the core unit resolved to the wrong per-unit check")
    (expect (map (c: c.working_dir) (applicableRuntime capability "packages/web/src/app.tsx") == ["packages/web"]) "the web unit resolved to the wrong per-unit check")
    (expect ((resolve {
        requested = "true";
        checks = capability;
      }).effective
      == "blocked") "an explicit strict request without workspace coverage must be blocked")
    (expect ((resolve {
        requested = "true";
        checks = capability;
      }).blocker
      != null) "a blocked strict request must carry a blocker reason")
    (expect ((resolve {
        requested = "true";
        checks = capability;
      }).effective
      != "disabled") "a blocked strict request was downgraded to disabled")
    (expect ((resolve {
        requested = "false";
        checks = capability;
      }).effective
      == "disabled") "an explicitly disabled request was not honored")
    (expect ((resolve {
        requested = "unset";
        checks = capability;
      }).effective
      == "disabled") "an unset request without workspace coverage must stay disabled")
    (expect ((resolve {
        requested = "true";
        checks = syntheticWorkspace;
      }).effective
      == "enabled") "an explicit request with workspace coverage must enable")
    (expect ((resolve {
        requested = "unset";
        checks = syntheticWorkspace;
      }).effective
      == "enabled") "an unset request with workspace coverage must enable")
  ];

  # --- Contract markers in the prose the agents follow ---------------------

  skillsDir = ../../modules/common/ai-tools/skills;
  detectTesting = builtins.readFile (skillsDir + "/sdd-init/rules/execution-detect-testing.md");
  strictResolution = builtins.readFile (skillsDir + "/sdd-init/rules/execution-strict-tdd-resolution.md");
  detectMode = builtins.readFile (skillsDir + "/sdd-apply/rules/execution-detect-mode.md");

  containsAll = text: needles: lib.all (needle: lib.hasInfix needle text) needles;

  contractTests = [
    (expect (containsAll detectTesting ["project root" "working directory" "covered targets" "nix-eval" "nix-build" "runtime"]) "execution-detect-testing.md no longer documents per-root, per-surface discovery")
    (expect (containsAll strictResolution ["requested" "effective" "blocked" "explicitly disabled" "workspace-wide" "never silently downgrade"]) "execution-strict-tdd-resolution.md no longer separates requested from effective with a blocker")
    (expect (containsAll detectMode ["applicable" "per-unit" "effective" "strict-tdd.md"]) "execution-detect-mode.md no longer resolves per-unit checks and gates the strict module")
  ];

  tests = scopeTests ++ contractTests;
in
  builtins.deepSeq tests (
    pkgs.runCommand "ai-tools-testing-scope-check" {} ''
      touch "$out"
    ''
  )
