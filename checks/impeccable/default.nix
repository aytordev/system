# Upstream byte fidelity and offline sibling-engine selection; no onboarding.
{
  lib,
  pkgs,
  inputs,
  ...
}: let
  available = pkgs.aytordev ? impeccable-engine && pkgs.aytordev ? impeccable-skills;
  engine = pkgs.aytordev.impeccable-engine;
  skills = pkgs.aytordev.impeccable-skills;
  expectedAssets = {
    aarch64-darwin = {
      platform = "darwin-arm64";
      hash = "efa0860cce03382e4d384709529b9892eaaa20dd49c3e5fcf73e680abc6d7574";
    };
    x86_64-linux = {
      platform = "linux-x64";
      hash = "19dbe233b82acb5d8b8ae2cb37621f23f950cba258cfc62313a3fa50e557930c";
    };
  };
  catalog = import ../../modules/common/ai-tools/catalog.nix;
  engineRecipe = ../../modules/common/ai-tools/upstream/impeccable/engine.nix;
  skillRecipe = ../../modules/common/ai-tools/upstream/impeccable/skill.nix;
  engineAdapter = ../../packages/impeccable-engine/package.nix;
  skillAdapter = ../../packages/impeccable-skills/package.nix;
  # Direct imports preserve callPackage's argument introspection; args: wrappers do not.
  thinAdapters =
    lib.trim (builtins.readFile engineAdapter)
    == "import ../../modules/common/ai-tools/upstream/impeccable/engine.nix"
    && lib.trim (builtins.readFile skillAdapter) == "import ../../modules/common/ai-tools/upstream/impeccable/skill.nix";
  recipeArgs =
    builtins.functionArgs (import engineRecipe)
    == {
      lib = false;
      stdenvNoCC = false;
      fetchurl = false;
    }
    && builtins.functionArgs (import skillRecipe)
    == {
      lib = false;
      stdenvNoCC = false;
      fetchFromGitHub = false;
      impeccable-engine = false;
    }
    && builtins.functionArgs (import engineAdapter) == builtins.functionArgs (import engineRecipe)
    && builtins.functionArgs (import skillAdapter) == builtins.functionArgs (import skillRecipe);
  candidates =
    lib.mapAttrs (system: _: let
      targetPkgs = import inputs.nixpkgs {inherit system;};
      adapterEngine = targetPkgs.callPackage engineAdapter {};
      privateEngine = targetPkgs.callPackage engineRecipe {};
    in {
      inherit adapterEngine privateEngine;
      adapterSkill = targetPkgs.callPackage skillAdapter {impeccable-engine = adapterEngine;};
      privateSkill = targetPkgs.callPackage skillRecipe {impeccable-engine = privateEngine;};
    })
    expectedAssets;
  identity = package: {
    inherit (package) version;
    derivation = package.drvPath;
    output = package.outPath;
    source = {
      derivation = package.src.drvPath;
      output = package.src.outPath;
    };
  };
  recipeParity = lib.all (candidate:
    identity candidate.adapterEngine
    == identity candidate.privateEngine
    && identity candidate.adapterSkill == identity candidate.privateSkill)
  (builtins.attrValues candidates);
  engines = lib.mapAttrs (_: candidate: candidate.adapterEngine) candidates;
  # Fetch cross-platform bytes with the host's fetcher, not a foreign builder.
  releaseSources = lib.mapAttrs (_: candidate:
    pkgs.fetchurl {
      inherit (candidate.src) url;
      sha256 = candidate.src.outputHash;
    })
  engines;
  pinsMatch = lib.all (system: let
    candidate = engines.${system};
    expected = expectedAssets.${system};
  in
    candidate.version
    == "0.1.6"
    && candidate.releasePlatform == expected.platform
    && candidate.src.url == "https://github.com/pbakaus/impeccable/releases/download/engine-v0.1.6/impeccable-${expected.platform}"
    && candidate.src.outputHash == expected.hash
    && candidate.meta.platforms == builtins.attrNames expectedAssets)
  (builtins.attrNames expectedAssets);
in
  if !available
  then
    pkgs.runCommand "impeccable-missing-bundle" {} ''
      echo "FAIL: pinned impeccable-engine and faithful impeccable-skills packages are required" >&2
      exit 1
    ''
  else
    assert lib.assertMsg thinAdapters "Impeccable package entry points must be direct private-recipe imports";
    assert lib.assertMsg recipeArgs "Private recipes must retain standalone callPackage arguments without config or Home Manager";
    assert lib.assertMsg recipeParity "Adapter/private package identities must match on both platforms";
    assert lib.assertMsg (
      catalog.impeccable.source.owner
      == "pbakaus"
      && catalog.impeccable.source.repo == "impeccable"
      && catalog.impeccable.source.version == "4.4.0"
      && catalog.impeccable.source.rev == "114ea1d3838fca73b253af45f873b9c4f5f213c8"
      && catalog.impeccable.source.hash == "sha256-CGIBrg4dvbY592/BdgsjbNpNBTxvMRrjBAW4JumI5HM="
      && catalog.impeccable.source.payloadPath == ".pi/skills/impeccable"
      && catalog.impeccable.tracking == null
      && catalog.impeccable.engine.release
      == {
        tagPrefix = "engine-v";
        revision = "d446ed6411522d6379ea86a0cc3a0955bc1251b2";
      }
      && catalog.impeccable.engine.version == "0.1.6"
      && catalog.impeccable.engine.assets == expectedAssets
    ) "Catalog must own the unchanged skill and engine pins";
    assert lib.assertMsg pinsMatch "Impeccable engine version/platform/hash mapping drifted";
    assert lib.assertMsg (
      skills.version
      == "4.4.0"
      && skills.upstreamRev == "114ea1d3838fca73b253af45f873b9c4f5f213c8"
      && skills.src.rev == skills.upstreamRev
      && skills.src.outputHash == "sha256-CGIBrg4dvbY592/BdgsjbNpNBTxvMRrjBAW4JumI5HM="
    ) "Impeccable skill source identity drifted";
      pkgs.runCommand "impeccable-upstream-check" {
        nativeBuildInputs = [pkgs.python3 pkgs.file];
      } ''
        # Inspect both raw releases, but execute only the host platform below.
        file ${releaseSources.aarch64-darwin} ${releaseSources.x86_64-linux}
        python3 - <<'PY'
        import hashlib
        import os
        from pathlib import Path
        import shutil
        import subprocess
        import tempfile

        source = Path("${skills.src}")
        payload = source / ".pi/skills/impeccable"
        bundle = Path("${skills}/share/impeccable")
        engine = Path("${engine}/bin/impeccable")
        sibling = Path("scripts/bin/${engine.releasePlatform}/impeccable")
        expected_hash = "${expectedAssets.${pkgs.stdenv.hostPlatform.system}.hash}"

        def files(root):
            return {p.relative_to(root) for p in root.rglob("*") if p.is_file()}

        originals = files(payload)
        assert len(originals) == 54, len(originals)
        assert len(list(payload.glob("reference/**/*.md"))) == 42
        additions = {sibling, Path("LICENSE"), Path("NOTICE.md")}
        assert files(bundle) == originals | additions, "missing payload or unexpected additions"
        assert not (bundle / "metadata.json").exists()
        for path in originals:
            assert (bundle / path).read_bytes() == (payload / path).read_bytes(), path
        for notice in ("LICENSE", "NOTICE.md"):
            assert (bundle / notice).read_bytes() == (source / notice).read_bytes()
        assert (bundle / "scripts/impeccable").read_bytes().startswith(b"#!/bin/sh\n")
        assert (bundle / "scripts/VERSION").read_text().strip() == "0.1.6"
        assert "version: 4.4.0\n" in (bundle / "SKILL.md").read_text()
        assert hashlib.sha256(engine.read_bytes()).hexdigest() == expected_hash
        assert (bundle / sibling).read_bytes() == engine.read_bytes()
        assert os.access(bundle / sibling, os.X_OK)

        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            home = root / "empty-home"
            home.mkdir()
            traps = root / "fallback-traps"
            traps.mkdir()
            marker = root / "fallback-used"
            # Any launcher network/PATH fallback is a hard failure, not a download.
            for command in ("curl", "wget", "impeccable"):
                trap = traps / command
                trap.write_text(f'#!/bin/sh\necho {command} >> "{marker}"\nexit 97\n')
                trap.chmod(0o755)
            env = {"HOME": str(home), "PATH": f"{traps}:${pkgs.coreutils}/bin"}
            isolated = root / "isolated skill"
            shutil.copytree(bundle, isolated, symlinks=False)
            # copytree retains read-only store directory modes; the disposable
            # copy must permit fixture replacement and temporary cleanup.
            for directory in [isolated] + [p for p in isolated.rglob("*") if p.is_dir()]:
                directory.chmod(0o755)
            assert not any(p.is_symlink() for p in isolated.rglob("*"))
            assert files(isolated) == files(bundle)
            for path in files(bundle):
                assert (isolated / path).read_bytes() == (bundle / path).read_bytes(), path

            # Both store publication and a fully dereferenced copy work from an
            # unrelated cwd, with no cache, engine override, or ambient PATH.
            for skill in (bundle, isolated):
                result = subprocess.run(
                    [str(skill / "scripts/impeccable"), "engine-probe"],
                    cwd=root, env=env, text=True, capture_output=True, check=True,
                )
                assert result.stdout.strip() == "impeccable-engine 0.1.6", result
                assert not marker.exists(), "launcher attempted fallback"
                assert not list(home.iterdir()), "launcher populated HOME/cache"

            # A disposable sibling fixture exposes the unmodified launcher's
            # resource exports; do not run browser/init/update commands.
            fixture = isolated / sibling
            fixture.unlink()
            fixture.write_text(
                '#!/bin/sh\n[ "$1" = engine-probe ] || exit 98\n'
                'printf "%s\\n" "$IMPECCABLE_SKILL_DIR" "$IMPECCABLE_SELF"\n'
            )
            fixture.chmod(0o755)
            result = subprocess.run(
                [str(isolated / "scripts/impeccable"), "engine-probe"],
                cwd=root, env=env, text=True, capture_output=True, check=True,
            )
            resource_dir, launcher = result.stdout.splitlines()
            assert Path(resource_dir) == isolated
            assert Path(launcher) == isolated / "scripts/impeccable"
            resources = [Path("scripts/command-metadata.json"), Path("scripts/data/font-index.json"),
                         Path("scripts/data/font-index-failures.json"), Path("scripts/modern-screenshot.umd.js")]
            resources += list(Path("scripts") / name for name in (
                "live-browser.js", "live-browser-session.js", "live-browser-dom.js", "live-browser-ignores.js"))
            resources += [p for p in originals if p.parts[0] == "reference"]
            for path in resources:
                assert (Path(resource_dir) / path).read_bytes() == (payload / path).read_bytes(), path
            assert not marker.exists()
            assert not list(home.iterdir())
        print("PASS: 54 upstream files, 42 references, exact additions, pins and offline isolated launcher")
        PY
        touch "$out"
      ''
