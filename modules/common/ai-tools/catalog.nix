# Pure ownership data, not a module or runtime discovery registry.
# Frontmatter/metadata and the linked provenance documents remain canonical.
# tracking = null means no configured branch/channel/feed, not an update policy.
{
  aytordev-pen-ops = {
    kind = "adapted";
    source.path = ./skills/aytordev-pen-ops;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/Nisus74/pencil-skill";
      path = "skills/pencil-design/SKILL.md";
      baseline = {
        role = "concept-adaptation";
        revision = "28ec61cefe3000a59bdac6b98b83168dbacca9c8";
      };
      originalImportRevision = null;
      lastSyncRevision = null;
    };
    provenance = ./skills/aytordev-pen-ops/references/provenance.md;
  };
  ci-debugging = {
    kind = "adapted";
    source.path = ./skills/ci-debugging;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/ci-debugging/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/ci-debugging/references/provenance.md;
  };
  dotfiles-coder = {
    kind = "local";
    source.path = ./skills/dotfiles-coder;
    update = "manual-local";
    tracking = null;
    origin = null;
    provenance = ./skills/dotfiles-coder/SKILL.md;
  };
  # Adaptation whose imported revision is known exactly, unlike the historical
  # comparison baselines below: originalImportRevision and lastSyncRevision are
  # the bytes this package was authored from, not an inferred synchronization.
  expectations = {
    kind = "adapted";
    source.path = ./skills/expectations;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/expectations/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "618665cb465edbead0b83befd9e96839a58b4dbe";
      };
      originalImportRevision = "618665cb465edbead0b83befd9e96839a58b4dbe";
      lastSyncRevision = "618665cb465edbead0b83befd9e96839a58b4dbe";
    };
    provenance = ./skills/expectations/references/provenance.md;
  };
  functional = {
    kind = "adapted";
    source.path = ./skills/functional;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/functional/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    provenance = ./skills/functional/references/provenance.md;
  };
  impeccable = {
    kind = "upstream";
    source = {
      package = "impeccable-skills";
      subdir = "share/impeccable";
      payloadPath = ".pi/skills/impeccable";
      owner = "pbakaus";
      repo = "impeccable";
      version = "4.4.0";
      rev = "114ea1d3838fca73b253af45f873b9c4f5f213c8";
      hash = "sha256-CGIBrg4dvbY592/BdgsjbNpNBTxvMRrjBAW4JumI5HM=";
    };
    update = "manual-pinned";
    tracking = null;
    provenance = ./README.md;
    # The upstream launcher requires this separately pinned sibling executable.
    dependencies = ["impeccable-engine"];
    engine = {
      package = "impeccable-engine";
      version = "0.1.6";
      # Same repository as source; release tag is tagPrefix + engine.version.
      release = {
        tagPrefix = "engine-v";
        revision = "d446ed6411522d6379ea86a0cc3a0955bc1251b2";
      };
      assets = {
        aarch64-darwin = {
          platform = "darwin-arm64";
          hash = "efa0860cce03382e4d384709529b9892eaaa20dd49c3e5fcf73e680abc6d7574";
        };
        x86_64-linux = {
          platform = "linux-x64";
          hash = "19dbe233b82acb5d8b8ae2cb37621f23f950cba258cfc62313a3fa50e557930c";
        };
      };
    };
  };
  nix = {
    kind = "local";
    source.path = ./skills/nix;
    update = "manual-local";
    tracking = null;
    # No external update source: independent, not a synchronizable derivative.
    origin = null;
    # Independent implementation; behavior-level inspiration is recorded here.
    provenance = ./skills/nix/SKILL.md;
  };
  # Historical comparison baseline, NOT original-import or last-synchronized pins.
  # Those adaptation baselines are unknown; do not infer them from the audit.
  refactoring = {
    kind = "adapted";
    source.path = ./skills/refactoring;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/refactoring/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    provenance = ./skills/refactoring/references/provenance.md;
  };
  skill-creator = {
    kind = "adapted";
    source.path = ./skills/skill-creator;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/Gentleman-Programming/gentle-ai";
      path = "internal/assets/skills/skill-creator/SKILL.md";
      baseline = {
        role = "historical-comparison";
        revision = "be49554794917ae92a6dc9dbfa2eb3db5cf70084";
      };
      originalImportRevision = null;
      lastSyncRevision = null;
    };
    provenance = ../../../docs/ai-tools/upstream-sources.md;
  };
  skill-registry = {
    kind = "adapted";
    source.path = ./skills/skill-registry;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/Gentleman-Programming/gentle-ai";
      path = "internal/assets/skills/skill-registry/SKILL.md";
      baseline = {
        role = "historical-comparison";
        revision = "be49554794917ae92a6dc9dbfa2eb3db5cf70084";
      };
      originalImportRevision = null;
      lastSyncRevision = null;
    };
    provenance = ../../../docs/ai-tools/upstream-sources.md;
  };
  tdd = {
    kind = "adapted";
    source.path = ./skills/tdd;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/tdd/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      };
      originalImportRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      lastSyncRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
    };
    provenance = ./skills/tdd/references/provenance.md;
  };
  testing = {
    kind = "adapted";
    source.path = ./skills/testing;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/testing/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      };
      originalImportRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      lastSyncRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
    };
    provenance = ./skills/testing/references/provenance.md;
  };
  characterisation-tests = {
    kind = "adapted";
    source.path = ./skills/characterisation-tests;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/characterisation-tests/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      };
      originalImportRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      lastSyncRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
    };
    provenance = ./skills/characterisation-tests/references/provenance.md;
  };
  mutation-testing = {
    kind = "adapted";
    source.path = ./skills/mutation-testing;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/mutation-testing/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      };
      originalImportRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      lastSyncRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
    };
    provenance = ./skills/mutation-testing/references/provenance.md;
  };
  test-design-reviewer = {
    kind = "adapted";
    source.path = ./skills/test-design-reviewer;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/test-design-reviewer/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/test-design-reviewer/references/provenance.md;
  };
  acceptance-review = {
    kind = "adapted";
    source.path = ./skills/acceptance-review;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/acceptance-review/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/acceptance-review/references/provenance.md;
  };
  double-check = {
    kind = "adapted";
    source.path = ./skills/double-check;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/double-check/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "89225f6ecb4b702fdc6a21b35e0ba83526d692de";
      };
      originalImportRevision = "89225f6ecb4b702fdc6a21b35e0ba83526d692de";
      lastSyncRevision = "89225f6ecb4b702fdc6a21b35e0ba83526d692de";
    };
    provenance = ./skills/double-check/references/provenance.md;
  };
  evaluate-existing-solutions = {
    kind = "adapted";
    source.path = ./skills/evaluate-existing-solutions;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/evaluate-existing-solutions/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/evaluate-existing-solutions/references/provenance.md;
  };
  find-gaps = {
    kind = "adapted";
    source.path = ./skills/find-gaps;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/find-gaps/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/find-gaps/references/provenance.md;
  };
  front-end-testing = {
    kind = "adapted";
    source.path = ./skills/front-end-testing;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/front-end-testing/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      };
      originalImportRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      lastSyncRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
    };
    provenance = ./skills/front-end-testing/references/provenance.md;
  };
  panel-review = {
    kind = "adapted";
    source.path = ./skills/panel-review;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/panel-review/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
      };
      originalImportRevision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
      lastSyncRevision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
    };
    provenance = ./skills/panel-review/references/provenance.md;
  };
  react-testing = {
    kind = "adapted";
    source.path = ./skills/react-testing;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/react-testing/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      };
      originalImportRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      lastSyncRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
    };
    provenance = ./skills/react-testing/references/provenance.md;
  };
  codebase-design = {
    kind = "adapted";
    source.path = ./skills/codebase-design;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/codebase-design/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    provenance = ./skills/codebase-design/references/provenance.md;
  };
  finding-seams = {
    kind = "adapted";
    source.path = ./skills/finding-seams;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/finding-seams/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      };
      originalImportRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      lastSyncRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
    };
    provenance = ./skills/finding-seams/references/provenance.md;
  };
  folder-structure = {
    kind = "adapted";
    source.path = ./skills/folder-structure;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/folder-structure/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "5f2d0602765f522ddc14b405885174d11320e4fb";
      };
      originalImportRevision = "5f2d0602765f522ddc14b405885174d11320e4fb";
      lastSyncRevision = "5f2d0602765f522ddc14b405885174d11320e4fb";
    };
    provenance = ./skills/folder-structure/references/provenance.md;
  };
  graph-engineering = {
    kind = "adapted";
    source.path = ./skills/graph-engineering;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/graph-engineering/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
      };
      originalImportRevision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
      lastSyncRevision = "bcfb33203eea2653f6e6aecac41f8583e38089fb";
    };
    provenance = ./skills/graph-engineering/references/provenance.md;
  };
  improve-codebase-architecture = {
    kind = "adapted";
    source.path = ./skills/improve-codebase-architecture;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/improve-codebase-architecture/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/improve-codebase-architecture/references/provenance.md;
  };
  reduce-system-complexity = {
    kind = "adapted";
    source.path = ./skills/reduce-system-complexity;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/reduce-system-complexity/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    provenance = ./skills/reduce-system-complexity/references/provenance.md;
  };
  structure-codebase = {
    kind = "adapted";
    source.path = ./skills/structure-codebase;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/structure-codebase/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    provenance = ./skills/structure-codebase/references/provenance.md;
  };
  twelve-factor = {
    kind = "adapted";
    source.path = ./skills/twelve-factor;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/twelve-factor/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      };
      originalImportRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      lastSyncRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
    };
    provenance = ./skills/twelve-factor/references/provenance.md;
  };
  api-design = {
    kind = "adapted";
    source.path = ./skills/api-design;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/api-design/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      };
      originalImportRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      lastSyncRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
    };
    provenance = ./skills/api-design/references/provenance.md;
  };
  bff-design = {
    kind = "adapted";
    source.path = ./skills/bff-design;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/bff-design/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fb59fa34f43401e1fc4fcefd360e64aa3449ea08";
      };
      originalImportRevision = "fb59fa34f43401e1fc4fcefd360e64aa3449ea08";
      lastSyncRevision = "fb59fa34f43401e1fc4fcefd360e64aa3449ea08";
    };
    provenance = ./skills/bff-design/references/provenance.md;
  };
  bff-entry-points = {
    kind = "adapted";
    source.path = ./skills/bff-entry-points;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/bff-entry-points/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    provenance = ./skills/bff-entry-points/references/provenance.md;
  };
  domain-driven-design = {
    kind = "adapted";
    source.path = ./skills/domain-driven-design;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/domain-driven-design/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "618665cb465edbead0b83befd9e96839a58b4dbe";
      };
      originalImportRevision = "618665cb465edbead0b83befd9e96839a58b4dbe";
      lastSyncRevision = "618665cb465edbead0b83befd9e96839a58b4dbe";
    };
    provenance = ./skills/domain-driven-design/references/provenance.md;
  };
  event-sourcing = {
    kind = "adapted";
    source.path = ./skills/event-sourcing;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/event-sourcing/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/event-sourcing/references/provenance.md;
  };
  secure-oauth-oidc = {
    kind = "adapted";
    source.path = ./skills/secure-oauth-oidc;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/secure-oauth-oidc/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      };
      originalImportRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      lastSyncRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
    };
    provenance = ./skills/secure-oauth-oidc/references/provenance.md;
  };
  ubiquitous-language = {
    kind = "adapted";
    source.path = ./skills/ubiquitous-language;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/ubiquitous-language/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/ubiquitous-language/references/provenance.md;
  };
  xstate = {
    kind = "adapted";
    source.path = ./skills/xstate;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/xstate/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      };
      originalImportRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      lastSyncRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
    };
    provenance = ./skills/xstate/references/provenance.md;
  };
  cli-design = {
    kind = "adapted";
    source.path = ./skills/cli-design;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/cli-design/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      };
      originalImportRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
      lastSyncRevision = "bc59bd65ca710e0afe388069e552a6f688ae5c0d";
    };
    provenance = ./skills/cli-design/references/provenance.md;
  };
  debugging = {
    kind = "adapted";
    source.path = ./skills/debugging;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/debugging/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/debugging/references/provenance.md;
  };
  diagrams = {
    kind = "adapted";
    source.path = ./skills/diagrams;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/diagrams/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/diagrams/references/provenance.md;
  };
  observability = {
    kind = "adapted";
    source.path = ./skills/observability;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/observability/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "fd017e2008465b8ba4d95a0312c112150c836116";
      };
      originalImportRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
      lastSyncRevision = "fd017e2008465b8ba4d95a0312c112150c836116";
    };
    provenance = ./skills/observability/references/provenance.md;
  };
  production-parity-skill-builder = {
    kind = "adapted";
    source.path = ./skills/production-parity-skill-builder;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/production-parity-skill-builder/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/production-parity-skill-builder/references/provenance.md;
  };
  teach-me = {
    kind = "adapted";
    source.path = ./skills/teach-me;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/teach-me/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/teach-me/references/provenance.md;
  };
  technical-writing = {
    kind = "adapted";
    source.path = ./skills/technical-writing;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/technical-writing/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "315ab6fc9a74794cd6b12964b70d036b53947681";
      };
      originalImportRevision = "315ab6fc9a74794cd6b12964b70d036b53947681";
      lastSyncRevision = "315ab6fc9a74794cd6b12964b70d036b53947681";
    };
    provenance = ./skills/technical-writing/references/provenance.md;
  };
  wtf = {
    kind = "adapted";
    source.path = ./skills/wtf;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/wtf/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/wtf/references/provenance.md;
  };
  find-skills = {
    kind = "adapted";
    source.path = ./skills/find-skills;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/find-skills/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "640a334d3f233e7569586ed5e7d2251aab212788";
      };
      originalImportRevision = "640a334d3f233e7569586ed5e7d2251aab212788";
      lastSyncRevision = "640a334d3f233e7569586ed5e7d2251aab212788";
    };
    provenance = ./skills/find-skills/references/provenance.md;
  };
  hexagonal-architecture = {
    kind = "adapted";
    source.path = ./skills/hexagonal-architecture;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/hexagonal-architecture/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "618665cb465edbead0b83befd9e96839a58b4dbe";
      };
      originalImportRevision = "618665cb465edbead0b83befd9e96839a58b4dbe";
      lastSyncRevision = "618665cb465edbead0b83befd9e96839a58b4dbe";
    };
    provenance = ./skills/hexagonal-architecture/references/provenance.md;
  };
  planning = {
    kind = "adapted";
    source.path = ./skills/planning;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/planning/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "89225f6ecb4b702fdc6a21b35e0ba83526d692de";
      };
      originalImportRevision = "89225f6ecb4b702fdc6a21b35e0ba83526d692de";
      lastSyncRevision = "89225f6ecb4b702fdc6a21b35e0ba83526d692de";
    };
    provenance = ./skills/planning/references/provenance.md;
  };
  react-performance = {
    kind = "adapted";
    source.path = ./skills/react-performance;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/react-performance/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      };
      originalImportRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
      lastSyncRevision = "08c3dae2b3dac766ed4dc839df163bcb5dbe3d80";
    };
    provenance = ./skills/react-performance/references/provenance.md;
  };
  render-code-shape = {
    kind = "adapted";
    source.path = ./skills/render-code-shape;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/render-code-shape/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "96cdd38632b4ef523aa7c445059d97e960de43ce";
      };
      originalImportRevision = "96cdd38632b4ef523aa7c445059d97e960de43ce";
      lastSyncRevision = "96cdd38632b4ef523aa7c445059d97e960de43ce";
    };
    provenance = ./skills/render-code-shape/references/provenance.md;
  };
  specification = {
    kind = "adapted";
    source.path = ./skills/specification;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/specification/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/specification/references/provenance.md;
  };
  stack-pull-requests = {
    kind = "adapted";
    source.path = ./skills/stack-pull-requests;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/stack-pull-requests/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/stack-pull-requests/references/provenance.md;
  };
  story-splitting = {
    kind = "adapted";
    source.path = ./skills/story-splitting;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/story-splitting/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/story-splitting/references/provenance.md;
  };
  storyboard = {
    kind = "adapted";
    source.path = ./skills/storyboard;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/storyboard/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      };
      originalImportRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
      lastSyncRevision = "8f1ebbc67094ecfe47f49a474eeaf87becd8114f";
    };
    provenance = ./skills/storyboard/references/provenance.md;
  };
  typescript-strict = {
    kind = "adapted";
    source.path = ./skills/typescript-strict;
    update = "manual-adaptation";
    tracking = null;
    origin = {
      repository = "https://github.com/citypaul/.dotfiles";
      path = "claude/.claude/skills/typescript-strict/SKILL.md";
      baseline = {
        role = "import-baseline";
        revision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      };
      originalImportRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
      lastSyncRevision = "63a85bef3505f3446ec5c9421fcd84a4bf57dad8";
    };
    provenance = ./skills/typescript-strict/references/provenance.md;
  };
}
