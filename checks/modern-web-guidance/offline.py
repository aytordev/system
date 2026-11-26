"""Exercise the pinned public CLI and the two packaged skill directories."""

import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile


USAGE = """
Usage: modern-web-guidance <command> [args]

Commands:
  search <query>            Search use cases by English query
  list                      List all available use cases
  retrieve <ids>            Retrieve use case(s) by ID(s), comma-separated

Options:
  -h, --help                Show this help
  -v, --version             Show version

"""
NOTICE_DIGESTS = {
    "LICENSE": "cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30",
    "THIRD_PARTY_NOTICES": "25181107e30dfdd5f884f25fa2e3a9df762027954873a7d2c27808e645f26b9e",
}


def run(bin_path, skills):
    with tempfile.TemporaryDirectory(prefix="modern web guidance ") as tmp:
        root = Path(tmp)
        for subdir in ("home", "project", "temp"):
            (root / subdir).mkdir()
        tripwire = root / "offline.cjs"
        tripwire.write_text('''
const fs = require('node:fs');
if (process.env.DISABLE_TELEMETRY !== '1' || process.env.ENABLE_FILE_LOGGING !== 'false') {
  throw new Error('Telemetry and logging must be disabled by the CLI');
}
const deny = () => {
  fs.writeFileSync(process.env.NETWORK_MARKER, 'unexpected side effect');
  throw new Error('Network calls and child processes are disabled in this check');
};
globalThis.fetch = deny;
require('node:net').Socket.prototype.connect = deny;
require('node:dns').lookup = deny;
for (const command of ['spawn', 'spawnSync', 'exec', 'execSync', 'execFile', 'execFileSync', 'fork']) {
  require('node:child_process')[command] = deny;
}
require('node:module').syncBuiltinESMExports();
''', encoding="utf-8")
        env = {
            "PATH": str(root / "missing-path"),
            "HOME": str(root / "home"),
            "XDG_CONFIG_HOME": str(root / "home/config"),
            "XDG_CACHE_HOME": str(root / "home/cache"),
            "XDG_DATA_HOME": str(root / "home/data"),
            "TMPDIR": str(root / "temp"),
            "DISABLE_TELEMETRY": "0",
            "ENABLE_FILE_LOGGING": "true",
            "NETWORK_MARKER": str(root / "network-attempt"),
            "NODE_OPTIONS": f'--require "{tripwire}"',
        }

        def call(*args, stdout=subprocess.PIPE):
            return subprocess.run([bin_path, *args], cwd=root / "project", env=env,
                                  text=True, stdout=stdout, stderr=subprocess.PIPE, timeout=30)

        def output(args, code, stdout, stderr=""):
            result = call(*args)
            assert (result.returncode, result.stdout, result.stderr) == (code, stdout, stderr), result

        output(["--version"], 0, "1.0.2\n")
        output(["--help"], 0, USAGE)
        output(["search"], 1, "", "No search query provided.\n")
        output(["retrieve"], 1, "", "No IDs provided for retrieve.\n")
        for command in ("install", "uninstall", "update", "legacy-scan", "set-allow-origin-trials"):
            output([command], 1, USAGE, f"Unknown command: {command}\n")

        result = call("search", "light dismiss dialog")
        assert result.returncode == 0 and result.stderr == "", result
        results = json.loads(result.stdout)
        guide_id = "light-dismiss-a-dialog"
        assert all(set(item) == {"id", "description"} and item["description"] for item in results), results
        assert guide_id in {item["id"] for item in results}, results

        result = call("list")
        assert result.returncode == 0 and result.stderr == "", result
        assert guide_id in {item["id"] for item in json.loads(result.stdout)}

        # Redirect as documented by the CLI to keep even a large guide on stdout.
        retrieved = root / "retrieved.md"
        with retrieved.open("w", encoding="utf-8") as handle:
            result = call("retrieve", guide_id, stdout=handle)
        assert result.returncode == 0 and result.stderr == "", result
        guide = (skills / f"modern-web-guidance/guides/ui-behaviors/{guide_id}.md").read_text(encoding="utf-8")
        assert retrieved.read_text(encoding="utf-8") == f"\n--- Guide for {guide_id} ---\n{guide}\n"
        project = root / "project"
        assert not list(project.iterdir())
        policy = project / ".mwgrc"
        gated_id = "language-detection"
        gated_guide = (skills / f"modern-web-guidance/guides/built-in-ai/{gated_id}.md").read_text(encoding="utf-8")
        denied = (
            "> [!CAUTION]\n"
            f"> **Project policy disables this guidance.** Guide `{gated_id}` covers a volatile feature "
            '(languagedetector). Use a cross-browser approach instead unless the project owner has approved '
            '`"allowVolatileFeatures": true` in `.mwgrc`. Do not change project policy or read around this gate.\n'
        )
        for contents, code, stdout, stderr in (
            (b'{ "allowVolatileFeatures": false }\n', 1, "", denied),
            (b'{ "allowVolatileFeatures": true }\n', 0, f"\n--- Guide for {gated_id} ---\n{gated_guide}\n", ""),
        ):
            policy.write_bytes(contents)
            mtime = policy.stat().st_mtime_ns
            output(["retrieve", gated_id], code, stdout, stderr)
            assert (policy.read_bytes(), policy.stat().st_mtime_ns) == (contents, mtime)

        assert not (root / "network-attempt").exists()
        assert list(project.iterdir()) == [policy]
        for directory in ("home", "temp"):
            assert not list((root / directory).iterdir()), directory


def check_skills(skills):
    assert {p.name for p in skills.iterdir()} == {"chrome-extensions", "modern-web-guidance"}
    for folder in skills.iterdir():
        assert (folder / "SKILL.md").read_text(encoding="utf-8").startswith(f"---\nname: {folder.name}\n")
        assert not any(p.suffix in {".mjs", ".js", ".sh"} for p in folder.rglob("*"))
        for notice, digest in NOTICE_DIGESTS.items():
            assert hashlib.sha256((folder / notice).read_bytes()).hexdigest() == digest, (folder, notice)
        for path in folder.rglob("*.md"):
            text = path.read_text(encoding="utf-8")
            assert not re.search(r"\b(?:npx|pnpx)\b.*modern-web-guidance", text), path

    extensions = skills / "chrome-extensions"
    strict_files = [extensions / "SKILL.md", extensions / "references/extensions/csp-sandbox.md",
                    extensions / "references/extensions/user-scripts.md"]
    for document in strict_files:
        text = document.read_text(encoding="utf-8")
        assert "strict" in text.lower() and "CSP" in text, document
        assert not re.search(r"\beval\s*\(|new\s+Function\(|unsafe-eval|srcdoc|createObjectURL", text), document


skills = Path(sys.argv[2])
check_skills(skills)
run(sys.argv[1], skills)
print("PASS: packaged skills, notices, offline search/list/retrieve, read-only opt-out and opt-in, no runtime side effects")
