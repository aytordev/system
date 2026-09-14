#!/usr/bin/env python3
"""Report how two Nix installables differ in built outputs and closures.

The helper builds each installable with ``nix build --no-link`` (no ``result``
link, no lock-file writes), walks every returned store path into a
deterministic manifest, resolves each recursive closure with ``nix path-info``,
and prints either JSON or a compact text summary. Every list is bounded so a
large package cannot flood the report. Only the Python standard library is
used.

Design note: the documented method this helper follows -- build without
linking, compare deterministic output manifests and closures, bound the report
-- is behavior-level inspiration from the khanelinix ``nix-toolkit`` package
diff. This file is an independent implementation and shares no code, comments,
or identifiers with that toolkit.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import stat
import subprocess
import sys
from collections.abc import Callable, Iterable, Sequence
from pathlib import Path
from typing import Any

REPORT_SCHEMA = 2
DEFAULT_LIMIT = 50
_READ_BLOCK = 1 << 20

CommandRunner = Callable[[Sequence[str], Path, bool], subprocess.CompletedProcess[bytes]]


class DiffToolError(RuntimeError):
    """A comparison could not produce a trustworthy report."""


def text_of(raw: bytes) -> str:
    return raw.decode("utf-8", errors="surrogateescape")


def invoke(
    argv: Sequence[str],
    workdir: Path,
    required: bool = True,
) -> subprocess.CompletedProcess[bytes]:
    environment = {**os.environ, "LC_ALL": "C"}
    try:
        completed = subprocess.run(
            list(argv),
            cwd=workdir,
            check=False,
            capture_output=True,
            env=environment,
        )
    except OSError as error:
        raise DiffToolError(f"could not run {argv[0]}: {error}") from error
    if required and completed.returncode != 0:
        reason = text_of(completed.stderr).strip() or "no diagnostics"
        raise DiffToolError(f"{argv[0]} exited {completed.returncode}: {reason}")
    return completed


def resolve_root(repo: Path) -> Path:
    try:
        return repo.resolve(strict=True)
    except OSError as error:
        raise DiffToolError(f"repository path is unusable: {error}") from error


def build_installable(
    run: CommandRunner,
    repo: Path,
    installable: str,
) -> list[Path]:
    completed = run(
        [
            "nix",
            "build",
            "--no-link",
            "--print-out-paths",
            "--no-update-lock-file",
            "--no-write-lock-file",
            "--",
            installable,
        ],
        repo,
        True,
    )
    outputs: list[Path] = []
    for raw_line in text_of(completed.stdout).splitlines():
        candidate = raw_line.strip()
        if not candidate:
            continue
        path = Path(candidate)
        if path not in outputs:
            outputs.append(path)
    if not outputs:
        raise DiffToolError(f"{installable!r} returned no store outputs")

    absent = [str(path) for path in outputs if not path.exists()]
    if absent:
        raise DiffToolError(
            f"{installable!r} referenced missing store paths: {', '.join(absent)}"
        )
    return outputs


def digest_of(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        while True:
            block = handle.read(_READ_BLOCK)
            if not block:
                break
            digest.update(block)
    return digest.hexdigest()


def describe(path: Path, digest_files: bool) -> dict[str, Any]:
    info = path.lstat()
    mode = format(stat.S_IMODE(info.st_mode), "04o")
    if stat.S_ISLNK(info.st_mode):
        return {"type": "symlink", "mode": mode, "target": os.readlink(path)}
    if stat.S_ISDIR(info.st_mode):
        return {"type": "directory", "mode": mode}
    if stat.S_ISREG(info.st_mode):
        record: dict[str, Any] = {
            "type": "file",
            "mode": mode,
            "size_bytes": info.st_size,
        }
        if digest_files:
            record["sha256"] = digest_of(path)
        return record
    return {"type": "other", "mode": mode, "size_bytes": info.st_size}


def walk_output(root: Path, digest_files: bool) -> list[tuple[str, dict[str, Any]]]:
    entries: list[tuple[str, dict[str, Any]]] = [(".", describe(root, digest_files))]
    if not root.is_dir():
        return entries

    for current, subdirs, files in os.walk(root, topdown=True, followlinks=False):
        subdirs.sort()
        files.sort()
        base = Path(current)
        descend: list[str] = []
        for name in subdirs:
            child = base / name
            relative = child.relative_to(root).as_posix()
            entries.append((relative, describe(child, digest_files)))
            if not child.is_symlink():
                descend.append(name)
        subdirs[:] = descend
        for name in files:
            child = base / name
            relative = child.relative_to(root).as_posix()
            entries.append((relative, describe(child, digest_files)))
    return entries


def manifest(outputs: Sequence[Path], digest_files: bool) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for index, output in enumerate(outputs):
        for relative, record in walk_output(output, digest_files):
            records.append({"output": index, "path": relative, **record})
    records.sort(key=lambda item: (item["output"], item["path"]))
    return records


def clip(values: Iterable[Any], limit: int) -> dict[str, Any]:
    if limit < 0:
        raise DiffToolError("--max-items must be zero or greater")
    materialized = list(values)
    if limit == 0:
        shown = materialized
    else:
        shown = materialized[:limit]
    return {
        "total": len(materialized),
        "returned": len(shown),
        "omitted": len(materialized) - len(shown),
        "entries": shown,
    }


def label(record: dict[str, Any]) -> str:
    return f"output[{record['output']}]:{record['path']}"


def compare_manifests(
    before: Sequence[dict[str, Any]],
    after: Sequence[dict[str, Any]],
    limit: int,
) -> dict[str, Any]:
    before_map = {(item["output"], item["path"]): item for item in before}
    after_map = {(item["output"], item["path"]): item for item in after}

    added = sorted(label(after_map[key]) for key in set(after_map) - set(before_map))
    removed = sorted(label(before_map[key]) for key in set(before_map) - set(after_map))
    modified = sorted(
        (
            {
                "before": before_map[key],
                "after": after_map[key],
                "entry": label(after_map[key]),
            }
            for key in set(before_map) & set(after_map)
            if before_map[key] != after_map[key]
        ),
        key=lambda item: item["entry"],
    )

    return {
        "before_entries": len(before_map),
        "after_entries": len(after_map),
        "added": clip(added, limit),
        "removed": clip(removed, limit),
        "modified": clip(modified, limit),
    }


def collect_closure(
    run: CommandRunner,
    repo: Path,
    outputs: Sequence[Path],
) -> dict[str, Any]:
    completed = run(
        [
            "nix",
            "path-info",
            "--json",
            "--json-format",
            "1",
            "--recursive",
            "--closure-size",
            *(str(path) for path in outputs),
        ],
        repo,
        True,
    )
    try:
        payload = json.loads(text_of(completed.stdout))
    except json.JSONDecodeError as error:
        raise DiffToolError(f"nix path-info gave invalid JSON: {error}") from error
    if not isinstance(payload, dict):
        raise DiffToolError("nix path-info JSON must be an object")

    store_paths = sorted(payload)
    nar_bytes = 0
    for value in payload.values():
        if isinstance(value, dict) and isinstance(value.get("narSize"), int):
            nar_bytes += value["narSize"]
    return {"store_paths": store_paths, "nar_bytes": nar_bytes}


def compare_closures(
    before: dict[str, Any],
    after: dict[str, Any],
    limit: int,
) -> dict[str, Any]:
    before_paths = set(before["store_paths"])
    after_paths = set(after["store_paths"])
    return {
        "before": {
            "store_paths": len(before_paths),
            "nar_bytes": before["nar_bytes"],
        },
        "after": {
            "store_paths": len(after_paths),
            "nar_bytes": after["nar_bytes"],
        },
        "nar_bytes_delta": after["nar_bytes"] - before["nar_bytes"],
        "added": clip(sorted(after_paths - before_paths), limit),
        "removed": clip(sorted(before_paths - after_paths), limit),
    }


def collect_report(
    repo: Path,
    before_installable: str,
    after_installable: str,
    *,
    digest_files: bool = True,
    limit: int = DEFAULT_LIMIT,
    run: CommandRunner | None = None,
) -> dict[str, Any]:
    runner = run or invoke
    root = resolve_root(repo)

    before_outputs = build_installable(runner, root, before_installable)
    after_outputs = build_installable(runner, root, after_installable)

    before_manifest = manifest(before_outputs, digest_files)
    after_manifest = manifest(after_outputs, digest_files)

    before_closure = collect_closure(runner, root, before_outputs)
    after_closure = collect_closure(runner, root, after_outputs)

    return {
        "schema": REPORT_SCHEMA,
        "repository": str(root),
        "before": {
            "installable": before_installable,
            "store_paths": [str(path) for path in before_outputs],
        },
        "after": {
            "installable": after_installable,
            "store_paths": [str(path) for path in after_outputs],
        },
        "file_hashes": digest_files,
        "files": compare_manifests(before_manifest, after_manifest, limit),
        "closure": compare_closures(before_closure, after_closure, limit),
    }


def render_text(report: dict[str, Any]) -> str:
    files = report["files"]
    closure = report["closure"]
    lines = [
        f"repository: {report['repository']}",
        f"before: {report['before']['installable']} ({len(report['before']['store_paths'])} output(s))",
        f"after:  {report['after']['installable']} ({len(report['after']['store_paths'])} output(s))",
        f"file hashes: {'on' if report['file_hashes'] else 'off'}",
        (
            "files: "
            f"+{files['added']['total']} "
            f"-{files['removed']['total']} "
            f"~{files['modified']['total']}"
        ),
        (
            "closure: "
            f"{closure['before']['store_paths']} -> {closure['after']['store_paths']} paths, "
            f"{closure['nar_bytes_delta']:+d} bytes"
        ),
    ]

    for category in ("added", "removed", "modified"):
        for item in files[category]["entries"]:
            entry = item["entry"] if isinstance(item, dict) else item
            lines.append(f"  {category}: {entry}")
        omitted = files[category]["omitted"]
        if omitted:
            lines.append(f"  {category}: {omitted} more omitted")

    for category in ("added", "removed"):
        for store_path in closure[category]["entries"]:
            lines.append(f"  closure {category}: {store_path}")
        omitted = closure[category]["omitted"]
        if omitted:
            lines.append(f"  closure {category}: {omitted} more omitted")

    return "\n".join(lines) + "\n"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="package-diff-report.py",
        description=(
            "Build two Nix installables without result links or lock-file "
            "updates, then report bounded output and closure differences."
        ),
    )
    parser.add_argument(
        "--repo",
        type=Path,
        default=Path.cwd(),
        help="working directory for nix commands (default: current directory)",
    )
    parser.add_argument("--before", required=True, help="installable to compare against")
    parser.add_argument("--after", required=True, help="installable to evaluate")
    parser.add_argument(
        "--no-file-hashes",
        action="store_true",
        help="compare metadata only instead of hashing regular-file contents",
    )
    parser.add_argument(
        "--max-items",
        type=int,
        default=DEFAULT_LIMIT,
        help=f"maximum entries per report list, 0 for unlimited (default: {DEFAULT_LIMIT})",
    )
    parser.add_argument(
        "--format",
        choices=("json", "text"),
        default="json",
        help="report format (default: json)",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    arguments = build_parser().parse_args(argv)
    try:
        report = collect_report(
            arguments.repo,
            arguments.before,
            arguments.after,
            digest_files=not arguments.no_file_hashes,
            limit=arguments.max_items,
        )
    except DiffToolError as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    if arguments.format == "json":
        print(json.dumps(report, indent=2, sort_keys=True, ensure_ascii=False))
    else:
        sys.stdout.write(render_text(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
