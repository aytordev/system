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
  dotfiles-coder = {
    kind = "local";
    source.path = ./skills/dotfiles-coder;
    update = "manual-local";
    tracking = null;
    origin = null;
    provenance = ./skills/dotfiles-coder/SKILL.md;
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
}
