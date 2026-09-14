# Package Diffing

Decide what actually changed between two builds: files, store paths, or
closures. Pin both operands (a locked flake ref, a store path, or a named
attribute) so a re-run compares the same thing.

## Bounded Manifest Report

`../scripts/package-diff-report.py` builds each installable with
`--no-link --no-update-lock-file --no-write-lock-file`, walks every output,
optionally hashes regular files, resolves recursive closures, bounds every list,
and emits stable JSON. It uses only the Python standard library.

```bash
python3 modules/common/ai-tools/skills/nix/scripts/package-diff-report.py \
  --repo . \
  --before 'nixpkgs#hello' \
  --after '.#hello'
```

Flags, matching the script:

- `--format text` prints a compact summary instead of JSON.
- `--no-file-hashes` compares metadata only (no content digests, faster).
- `--max-items N` caps each report list; `0` returns everything.
- `--repo <dir>` sets the working directory for `nix` (default: current).

If `python3` is not on `PATH`, supply it with
`nix shell nixpkgs#python3 -c 'python3 ...'`.

## Built-In Shortcuts

For routine comparisons the Nix CLI is enough:

```bash
nix store diff-closures .#before .#after    # grouped version/size drift
nix path-info -Sh .#before .#after          # direct output sizes
out="$(nix build --no-link --print-out-paths .#after)"
nix path-info -rSh "$out" | sort -h         # recursive closure, largest last
```

For deeper byte-level inspection, run `diffoscope` yourself on the two store
paths; the helper intentionally does not depend on it.

## Reading a Difference

- Identical file list, changed digests: content or generated metadata moved.
- Only the store hash changed: separate rebuild drift (timestamps, ordering)
  from a behavior change.
- Archive members differ only by timestamp: check `SOURCE_DATE_EPOCH` and member
  ordering before blaming the source.
- ELF binaries differ: compare closure and reference changes before assuming the
  source changed.
- Fonts, icons, wheels, jars: compare the generated index and archive order.

## Evidence to Report

- The two installables and the revisions/systems they resolve to.
- Whether file hashing ran (`--no-file-hashes` or not).
- Verdict: byte-identical, same files with new content, or structural change.
- The largest or riskiest changed paths.
- Closure path and size deltas.
