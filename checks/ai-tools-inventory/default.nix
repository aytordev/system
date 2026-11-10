{
  lib,
  pkgs,
  ...
}: let
  root = ../../modules/common/ai-tools;
  entries = builtins.readDir (root + "/skills");
  names = builtins.attrNames entries;
  # Only authored folders carry our metadata contract; upstream is packaged.
  expected = ["acceptance-review" "api-design" "aytordev-pen-ops" "bff-design" "bff-entry-points" "characterisation-tests" "ci-debugging" "codebase-design" "domain-driven-design" "dotfiles-coder" "double-check" "evaluate-existing-solutions" "event-sourcing" "expectations" "find-gaps" "finding-seams" "folder-structure" "front-end-testing" "functional" "graph-engineering" "improve-codebase-architecture" "mutation-testing" "nix" "panel-review" "react-testing" "reduce-system-complexity" "refactoring" "secure-oauth-oidc" "skill-creator" "skill-registry" "structure-codebase" "tdd" "test-design-reviewer" "testing" "twelve-factor" "typescript-strict" "ubiquitous-language" "xstate"];
  published = lib.sort builtins.lessThan (expected ++ ["impeccable"]);
  catalog = import (root + "/catalog.nix");
  expectedKinds = {
    aytordev-pen-ops = "adapted";
    characterisation-tests = "adapted";
    ci-debugging = "adapted";
    dotfiles-coder = "local";
    expectations = "adapted";
    functional = "adapted";
    impeccable = "upstream";
    mutation-testing = "adapted";
    nix = "local";
    refactoring = "adapted";
    skill-creator = "adapted";
    skill-registry = "adapted";
    tdd = "adapted";
    test-design-reviewer = "adapted";
    testing = "adapted";
    typescript-strict = "adapted";
    acceptance-review = "adapted";
    double-check = "adapted";
    evaluate-existing-solutions = "adapted";
    find-gaps = "adapted";
    front-end-testing = "adapted";
    panel-review = "adapted";
    react-testing = "adapted";
    codebase-design = "adapted";
    finding-seams = "adapted";
    folder-structure = "adapted";
    graph-engineering = "adapted";
    improve-codebase-architecture = "adapted";
    reduce-system-complexity = "adapted";
    structure-codebase = "adapted";
    twelve-factor = "adapted";
    api-design = "adapted";
    bff-design = "adapted";
    bff-entry-points = "adapted";
    domain-driven-design = "adapted";
    event-sourcing = "adapted";
    secure-oauth-oidc = "adapted";
    ubiquitous-language = "adapted";
    xstate = "adapted";
  };
  # Independent expectations: comparison evidence never becomes a sync baseline.
  expectedOrigins = {
    aytordev-pen-ops = {
      repository = "https://github.com/Nisus74/pencil-skill";
      path = "skills/pencil-design/SKILL.md";
      baseline = {
        role = "concept-adaptation";
        revision = "28ec61cefe3000a59bdac6b98b83168dbacca9c8";
      };
      originalImportRevision = null;
      lastSyncRevision = null;
    };
    ci-debugging = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/ci-debugging/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    characterisation-tests = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/characterisation-tests/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      };
      originalImportRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      lastSyncRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
    };
    dotfiles-coder = null;
    expectations = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/expectations/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "618665cb465edbead0b83befd9e96839a58b4dbe";
      };
      originalImportRevision = "618665cb465edbead0b83befd9e96839a58b4dbe";
      lastSyncRevision = "618665cb465edbead0b83befd9e96839a58b4dbe";
    };
    functional = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/functional/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    refactoring = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/refactoring/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    mutation-testing = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/mutation-testing/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      };
      originalImportRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      lastSyncRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
    };
    nix = null;
    skill-creator = {
      repository = "https://github.com/Gentleman-Programming/gentle-ai";
      path = "internal/assets/skills/skill-creator/SKILL.md";
      baseline = {
        role = "historical-comparison";
        revision = "be49554794917ae92a6dc9dbfa2eb3db5cf70084";
      };
      originalImportRevision = null;
      lastSyncRevision = null;
    };
    skill-registry = {
      repository = "https://github.com/Gentleman-Programming/gentle-ai";
      path = "internal/assets/skills/skill-registry/SKILL.md";
      baseline = {
        role = "historical-comparison";
        revision = "be49554794917ae92a6dc9dbfa2eb3db5cf70084";
      };
      originalImportRevision = null;
      lastSyncRevision = null;
    };
    tdd = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/tdd/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      };
      originalImportRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      lastSyncRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
    };
    testing = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/testing/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      };
      originalImportRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      lastSyncRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
    };
    test-design-reviewer = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/test-design-reviewer/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    typescript-strict = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/typescript-strict/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      };
      originalImportRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      lastSyncRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
    };
    acceptance-review = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/acceptance-review/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    double-check = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/double-check/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "89225f6ecb4b702fdc6a21b35e0ba83526d692de";
      };
      originalImportRevision = "89225f6ecb4b702fdc6a21b35e0ba83526d692de";
      lastSyncRevision = "89225f6ecb4b702fdc6a21b35e0ba83526d692de";
    };
    evaluate-existing-solutions = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/evaluate-existing-solutions/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    find-gaps = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/find-gaps/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    front-end-testing = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/front-end-testing/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      };
      originalImportRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      lastSyncRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
    };
    panel-review = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/panel-review/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
      };
      originalImportRevision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
      lastSyncRevision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
    };
    react-testing = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/react-testing/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      };
      originalImportRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      lastSyncRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
    };
    codebase-design = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/codebase-design/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    finding-seams = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/finding-seams/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      };
      originalImportRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      lastSyncRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
    };
    folder-structure = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/folder-structure/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "5f2d0602765f522ddc14b405885174d11320e4fb";
      };
      originalImportRevision = "5f2d0602765f522ddc14b405885174d11320e4fb";
      lastSyncRevision = "5f2d0602765f522ddc14b405885174d11320e4fb";
    };
    graph-engineering = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/graph-engineering/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
      };
      originalImportRevision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
      lastSyncRevision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
    };
    improve-codebase-architecture = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/improve-codebase-architecture/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    reduce-system-complexity = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/reduce-system-complexity/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    structure-codebase = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/structure-codebase/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    twelve-factor = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/twelve-factor/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      };
      originalImportRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      lastSyncRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
    };
    api-design = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/api-design/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      };
      originalImportRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      lastSyncRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
    };
    bff-design = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/bff-design/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fb59fa34f43401e1fc4fcefd360e64aa3449ea08";
      };
      originalImportRevision = "fb59fa34f43401e1fc4fcefd360e64aa3449ea08";
      lastSyncRevision = "fb59fa34f43401e1fc4fcefd360e64aa3449ea08";
    };
    bff-entry-points = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/bff-entry-points/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    domain-driven-design = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/domain-driven-design/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "618665cb465edbead0b83befd9e96839a58b4dbe";
      };
      originalImportRevision = "618665cb465edbead0b83befd9e96839a58b4dbe";
      lastSyncRevision = "618665cb465edbead0b83befd9e96839a58b4dbe";
    };
    event-sourcing = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/event-sourcing/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    secure-oauth-oidc = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/secure-oauth-oidc/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      };
      originalImportRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      lastSyncRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
    };
    ubiquitous-language = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/ubiquitous-language/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    xstate = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/xstate/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      };
      originalImportRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      lastSyncRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
    };
  };
  # Data only: no module arguments, derivations, functions, or store contexts.
  pureData = value:
    if builtins.isAttrs value
    then !(value ? type && value.type == "derivation") && lib.all pureData (builtins.attrValues value)
    else if builtins.isList value
    then lib.all pureData value
    else if builtins.isString value
    then !(builtins.hasContext value)
    else value == null || builtins.isPath value;
  keysAre = keys: value: builtins.isAttrs value && builtins.attrNames value == lib.sort builtins.lessThan keys;
  validEntry = name: entry:
    keysAre (["kind" "source" "update" "tracking" "provenance"]
      ++ (
        if name == "impeccable"
        then ["engine" "dependencies"]
        else ["origin"]
      ))
    entry
    && entry.kind == expectedKinds.${name}
    && entry.tracking == null
    && builtins.isPath entry.provenance
    && builtins.pathExists entry.provenance
    && (
      if name == "impeccable"
      then
        keysAre ["package" "subdir" "payloadPath" "owner" "repo" "version" "rev" "hash"] entry.source
        && entry.source.package == "impeccable-skills"
        && entry.source.subdir == "share/impeccable"
        && entry.update == "manual-pinned"
        && entry.dependencies == ["impeccable-engine"]
        && entry.source.payloadPath == ".pi/skills/impeccable"
        && keysAre ["package" "version" "assets" "release"] entry.engine
        && entry.engine.package == "impeccable-engine"
      else
        keysAre ["path"] entry.source
        && entry.origin == expectedOrigins.${name}
        && entry.source.path == root + "/skills/${name}"
        && builtins.pathExists (entry.source.path + "/SKILL.md")
        && entry.update
        == (
          if entry.kind == "adapted"
          then "manual-adaptation"
          else "manual-local"
        )
    );
  catalogShape = value:
    keysAre published value
    && pureData value
    && lib.all (name: validEntry name value.${name}) published;
  doc = builtins.readFile (root + "/AGENTS.md");
  rows = lib.filter (line: lib.hasPrefix "| " line && !(lib.hasPrefix "| Name " line)) (lib.splitString "\n" doc);
  documented = map (row: lib.trim (builtins.elemAt (lib.splitString "|" row) 1)) rows;
in
  assert lib.assertMsg (builtins.pathExists (root + "/catalog.nix")) "AI skill ownership requires a pure sixteen-entry catalog";
  assert lib.assertMsg (catalogShape catalog) "AI skill catalog ownership, structured origins/tracking, payload location, or pure-data shape drifted";
  # Triangulation: reject plausible ownership/metadata mistakes, not just omissions.
  assert lib.assertMsg (lib.all (value: !(catalogShape value)) [
    (builtins.removeAttrs catalog ["nix"])
    (catalog // {extra = catalog.nix;})
    (catalog // {nix = catalog.nix // {kind = "adapted";};})
    (catalog // {nix = catalog.nix // {description = "duplicated frontmatter";};})
    (catalog // {nix = catalog.nix // {source = {path = root + "/skills/dotfiles-coder";};};})
    (catalog // {impeccable = catalog.impeccable // {dependencies = [];};})
    (catalog // {nix = catalog.nix // {update = _: "automatic";};})
    (catalog // {skill-creator = catalog.skill-creator // {tracking = "main";};})
    (catalog // {skill-creator = catalog.skill-creator // {origin = catalog.skill-creator.origin // {lastSyncRevision = catalog.skill-creator.origin.baseline.revision;};};})
    (catalog // {nix = catalog.nix // {origin = catalog.skill-creator.origin;};})
    (catalog // {impeccable = catalog.impeccable // {source = catalog.impeccable.source // {payloadPath = "skills/impeccable";};};})
  ]) "Catalog shape must reject invalid ownership fixtures";
  assert lib.assertMsg (names == expected) "Expected exactly fifteen authored skill packages";
  assert lib.assertMsg (lib.sort builtins.lessThan documented == published) "Expected the fifteen authored skills plus upstream impeccable in the documented inventory";
  assert lib.all (path: !(builtins.pathExists (root + "/${path}"))) ["default.nix" "agents.nix" "commands.nix" "roles.nix" "registry.nix" "base.md"];
    pkgs.runCommand "ai-tools-inventory-check" {} ''
      touch "$out"
    ''
