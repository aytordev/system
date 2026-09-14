# Closure and Dependency Analysis

Explain what an output needs at runtime and why. Nix defines a path's *closure*
as everything reachable through the *references* relation. That is not the
derivation's build-input list: a `buildInputs` entry appears in the output
closure only if the produced files reference its store path (an ELF RPATH, a
store path embedded in a script). See the
[Nix glossary](https://nix.dev/manual/nix/2.35/glossary#gloss-closure) and
[output closure](https://nix.dev/manual/nix/2.35/glossary#gloss-output-closure).
The authoring rule lives in
[performance-closure.md](../rules/performance-closure.md).

## Size an Output

```bash
out="$(nix build --no-link --print-out-paths .#package)"
nix path-info -Sh "$out"                 # this output only
nix path-info -rSh "$out" | sort -h      # whole closure, largest last
```

`-r` follows references, `-S` reports closure size, `-h` is human-readable. For
a `./result` symlink, pass `result` instead.

## Rank the Biggest Members

```bash
nix path-info --json --json-format 1 --recursive --closure-size "$out" |
  jq 'to_entries | sort_by(.value.closureSize) | reverse | .[:20][] |
      {path: .key, closureSize: .value.closureSize, narSize: .value.narSize}'
```

## Which Reference Pulls a Path In

```bash
nix why-depends .#target .#dependency
nix why-depends --derivation .#target .#dependency   # build-time edge
nix why-depends --all .#target .#dependency          # every path, not the shortest
```

`--derivation` finds a path that exists only in the build graph. Use `--all`
only after the shortest chain is understood.

Direct references, the local reverse index, and the full closure:

```bash
nix-store -q --references result | sort
nix-store -q --referrers result | sort   # local store only; absence is not proof
nix-store -q --requisites result | sort  # the closure (same set as path-info -r)
```

## Compare Two Revisions

```bash
nix path-info -r .#before | sort > before.paths
nix path-info -r .#after  | sort > after.paths
diff -u before.paths after.paths
nix store diff-closures .#before .#after
```

`nix store diff-closures` groups by package name and version, which reads better
in review; the raw path diff still catches outputs renamed without a version
change.

## Embedded Store Paths

A path can be retained without appearing in `ldd` output. Search binaries and
text alike:

```bash
out="$(nix build --no-link --print-out-paths nixpkgs#hello)"
strings "$out/bin/hello" | rg '/nix/store'
ldd "$out/bin/hello"                  # ELF
rg -a '/nix/store' "$out" | head      # scripts, wrappers, pkg-config, desktop files
```

## Growing Closures

1. The direct output grew: measure with `nix path-info -Sh`.
2. Only the recursive closure grew: inspect the paths added in step 1.
3. A path exists only in the derivation graph: treat it as build-time until a
   runtime reference proves otherwise.
4. Multi-output package: compare the exact output, not the package name.

Frequent causes: `propagatedBuildInputs` used where `buildInputs` /
`nativeBuildInputs` would do; a wrapper embedding a tool for an optional code
path; `makeWrapper` / `substituteAll` capturing a whole package path;
build-time metadata (`.pc`, CMake, Python, GI, Qt, desktop files) retaining a
reference.

## Evidence to Report

- Closure size before and after.
- The largest added or removed paths.
- Whether the change is in the direct output or in its closure.
- Any follow-up needed to narrow the reference.
