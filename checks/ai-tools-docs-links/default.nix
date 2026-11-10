{
  lib,
  pkgs,
  ...
}: let
  # Repository-relative markdown links in the knowledge/context surface must
  # point at paths that exist. The scope is deliberate: some other skill trees
  # use `references/...` links as illustrative templates rather than real
  # repository paths, so they are not scanned here.
  aiTools = ../../modules/common/ai-tools;
  # The AI-tools plan/proposal/evidence records live under docs/ai-tools; they
  # cross-link heavily, so they are link-checked too.
  docsTree = ../../docs/ai-tools;
  # Top-level docs are listed explicitly so the scan does not recurse into
  # `skills/` and pick up other owners' illustrative template links.
  rootFiles = [
    (aiTools + "/README.md")
    (aiTools + "/AGENTS.md")
  ];
  trees = [
    (aiTools + "/skills/nix")
    (aiTools + "/skills/dotfiles-coder")
    (aiTools + "/skills/skill-registry")
    (aiTools + "/skills/aytordev-pen-ops")
    (aiTools + "/skills/functional")
    (aiTools + "/skills/typescript-strict")
    (aiTools + "/skills/ci-debugging")
    (aiTools + "/skills/expectations")
    (aiTools + "/skills/refactoring")
    (aiTools + "/skills/tdd")
    (aiTools + "/skills/testing")
    (aiTools + "/skills/characterisation-tests")
    (aiTools + "/skills/mutation-testing")
    (aiTools + "/skills/test-design-reviewer")
    (aiTools + "/skills/acceptance-review")
    (aiTools + "/skills/double-check")
    (aiTools + "/skills/evaluate-existing-solutions")
    (aiTools + "/skills/find-gaps")
    (aiTools + "/skills/front-end-testing")
    (aiTools + "/skills/panel-review")
    (aiTools + "/skills/react-testing")
    (aiTools + "/skills/codebase-design")
    (aiTools + "/skills/finding-seams")
    (aiTools + "/skills/folder-structure")
    (aiTools + "/skills/graph-engineering")
    (aiTools + "/skills/improve-codebase-architecture")
    (aiTools + "/skills/reduce-system-complexity")
    (aiTools + "/skills/structure-codebase")
    (aiTools + "/skills/twelve-factor")
    (aiTools + "/skills/api-design")
    (aiTools + "/skills/bff-design")
    (aiTools + "/skills/bff-entry-points")
    (aiTools + "/skills/domain-driven-design")
    (aiTools + "/skills/event-sourcing")
    (aiTools + "/skills/secure-oauth-oidc")
    (aiTools + "/skills/ubiquitous-language")
    (aiTools + "/skills/xstate")
    (aiTools + "/skills/cli-design")
    (aiTools + "/skills/debugging")
    (aiTools + "/skills/diagrams")
    (aiTools + "/skills/observability")
    (aiTools + "/skills/production-parity-skill-builder")
    (aiTools + "/skills/teach-me")
    (aiTools + "/skills/technical-writing")
    (aiTools + "/skills/wtf")
    (aiTools + "/skills/find-skills")
    (aiTools + "/skills/hexagonal-architecture")
    (aiTools + "/skills/planning")
    (aiTools + "/skills/react-performance")
    (aiTools + "/skills/render-code-shape")
    (aiTools + "/skills/specification")
    (aiTools + "/skills/stack-pull-requests")
    (aiTools + "/skills/story-splitting")
    (aiTools + "/skills/storyboard")
  ];

  markdownFiles = dir: let
    entries = builtins.readDir dir;
    step = name: type:
      if type == "directory"
      then markdownFiles (dir + "/${name}")
      else if type == "regular" && lib.hasSuffix ".md" name
      then [(dir + "/${name}")]
      else [];
  in
    lib.concatLists (lib.mapAttrsToList step entries);

  files = lib.unique (rootFiles ++ lib.concatMap markdownFiles trees ++ (markdownFiles docsTree));
  repoRoot = builtins.dirOf (builtins.dirOf docsTree);
  rel = file: lib.removePrefix (toString repoRoot + "/") (toString file);

  # `builtins.split` returns alternating strings and capture-group lists. The
  # `[]]` class is required because `\]` is rejected by Nix's regex engine.
  linkTargets = text:
    lib.concatMap
    (piece:
      if builtins.isList piece
      then [(lib.head piece)]
      else [])
    (builtins.split "[]]\\(([^)]+)\\)" text);

  trimBrackets = target: builtins.replaceStrings ["<" ">"] ["" ""] (lib.trim target);

  # External URLs, in-page anchors, absolute paths, and mailto links are not
  # repository-relative targets.
  isExternal = target:
    target
    == ""
    || lib.hasPrefix "#" target
    || lib.hasPrefix "/" target
    || lib.hasInfix "://" target
    || lib.hasPrefix "mailto:" target;

  # Drop any `#anchor` from a relative target before resolving it.
  stripAnchor = target: lib.head (lib.splitString "#" target);

  linkProblems = file: let
    text = builtins.readFile file;
    targets = map (t: stripAnchor (trimBrackets t)) (linkTargets text);
    checked = builtins.filter (t: !(isExternal t)) targets;
    dir = builtins.dirOf file;
  in
    builtins.map
    (target: "  - ${rel file}: link target does not exist: ${target}")
    (builtins.filter (target: !(builtins.pathExists (dir + "/${target}"))) checked);

  problems = lib.concatMap linkProblems files;
in
  if problems == []
  then
    pkgs.runCommand "ai-tools-docs-links-check" {} ''
      touch "$out"
    ''
  else
    throw (lib.concatStringsSep "\n" (
      ["Broken repository-relative links in modules/common/ai-tools documentation/skills:"]
      ++ problems
      ++ ["Fix the path or update the scope in checks/ai-tools-docs-links."]
    ))
