"""Project the inspected npm artifact into the offline package (no npm execution)."""

import gzip
import hashlib
import json
import re
import shutil
import sys
from pathlib import Path


MOVING_COMMAND = "npx -y modern-web-guidance@latest"
LOCAL_COMMAND = "modern-web-guidance"
NOTICES = {
    "LICENSE": "cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30",
    "THIRD_PARTY_NOTICES": "25181107e30dfdd5f884f25fa2e3a9df762027954873a7d2c27808e645f26b9e",
}


def replace_once(text, original, replacement):
    if text.count(original) != 1:
        raise ValueError(f"Pinned text changed: {original!r}")
    return text.replace(original, replacement, 1)


def section(text, start, end, replacement=""):
    """Adapt a single uniquely anchored section without retaining removed examples."""
    if text.count(start) != 1 or text.count(end) != 1:
        raise ValueError(f"Pinned section changed: {start!r} … {end!r}")
    lo = text.index(start)
    hi = text.index(end, lo + len(start))
    return text[:lo] + replacement + text[hi:]


def write(path, text):
    notice = "Modified for the aytordev Nix distribution; see LOCAL_CHANGES.md."
    if path.name != "LOCAL_CHANGES.md" and path.suffix == ".md":
        text += f"\n> {notice}\n"
    elif path.suffix == ".mjs":
        text += f"\n// {notice}\n"
    path.write_text(text, encoding="utf-8")


def adapt_web_skill(path):
    text = path.read_text(encoding="utf-8").replace(MOVING_COMMAND, LOCAL_COMMAND)
    text = replace_once(text, "Run `modern-web-guidance` directly with `npx` using", "Run the Nix-provided `modern-web-guidance` on PATH using")
    text = replace_once(text, 'search "<query>" --skill-version 2026_11_16-268fb9ea', 'search "<query>"')
    text = replace_once(text, "- Do not run `legacy-scan`; it's for detecting legacy patterns to modernize, not this.\n", "")
    text = section(text, "## Alternative flow:", "## Guidelines", """## Offline CLI

The pinned Nix CLI reads bundled data without network access or telemetry.
If it is unavailable, say so and continue without claiming to have searched;
do not download a replacement or change tool permissions. This package does
not provide project scans, installers, or update commands.

""")
    write(path, text)


def adapt_extensions(root):
    refs = root / "references/extensions"
    skill = root / "SKILL.md"
    text = skill.read_text(encoding="utf-8")
    text = section(text, "#### 3. Code execution:", "#### 4. `tab.url`", """#### 3. Keep the extension CSP strict

Use packaged, reviewed scripts. Treat page content, remote responses, user input,
and messages as data, never code. Where isolation is needed for rendering, keep
that surface unprivileged and validate the sender, origin, and message schema
before any privileged handling. See `references/extensions/csp-sandbox.md`.

""")
    text = section(text, "#### 18. User scripts:", "#### 19. `chrome.windows`", """#### 18. Keep extension automation reviewable

Prefer packaged content scripts with narrow host access. Represent user-defined
automation as data selecting reviewed actions, not executable source code.
See `references/extensions/user-scripts.md`.

""")
    text = replace_once(text, "- [ ] Code execution uses sandbox/blob/srcdoc — no `eval()` in extension pages", "- [ ] Strict CSP, packaged code only, and validated messages across isolation boundaries")
    text = section(text, "- [ ] `chrome.userScripts` availability", "- [ ] `sidePanel.setPanelBehavior`", "- [ ] User-defined settings select reviewed actions, not executable source code\n")
    write(skill, text)

    write(refs / "csp-sandbox.md", """# Content Security Policy and isolation

Keep the Manifest V3 extension CSP strict. Run only packaged, reviewed code in
extension contexts: use external script files and register event listeners in
those files. Do not weaken policy to execute inline, remote, or user-supplied
code. Treat all external input as data.

Use a sandbox only to isolate untrusted content with the minimum capabilities
needed for rendering. Keep that context away from extension APIs and secrets;
leave scripting disabled for untrusted content. For required cross-context
messages, verify the expected sender and origin (or a dedicated channel bound to
the expected frame for opaque origins). An opaque `null` origin alone is not
identity. Validate each message's schema and allowed action before processing it,
limit what privileged handlers can do, and never interpret a message as code.

See [Message Passing](message-passing.md) for the messaging interfaces.
""")
    write(refs / "user-scripts.md", """# Reviewable extension automation

Use packaged content scripts in the isolated world with the narrowest host access
needed. Do not run source code supplied by users or remote services. Model
customization as validated data that selects among a finite set of reviewed
actions. Revalidate each request and its sender before using privileged APIs,
and reject unknown message shapes or actions. Keep the extension CSP strict.

See [Content Scripts](content-scripts.md) and [Content Security Policy and
isolation](csp-sandbox.md).
""")

    devtools = refs / "devtools.md"
    text = devtools.read_text(encoding="utf-8")
    text = section(text, "// Evaluate JS in the inspected page", "// Monitor network requests")
    text, count = re.subn(r"(?m)^- .*inspectedWindow\.eval.*\n?", "- Treat inspected page content and messages as untrusted data; do not evaluate them.\n", text)
    if count != 1:
        raise ValueError("Pinned DevTools notes changed")
    write(devtools, text)

    content = refs / "content-scripts.md"
    text = replace_once(content.read_text(encoding="utf-8"), "- The page's CSP does NOT restrict content script code", "- Keep the extension CSP strict and run only reviewed, packaged content scripts")
    write(content, text)


def adapt_cli(text):
    # Pin the original command body before stripping any branches. All Clearcut
    # call sites are here, so missing, added, and reformatted calls require review
    # on repin rather than silently changing what the removal below matches.
    bodies = re.findall(r"(?ms)^async function main\(\) \{\n(.*?)^function getCLISkillVersion\(\)", text)
    if len(bodies) != 1 or hashlib.sha256(bodies[0].encode()).hexdigest() != (
        "dcffa79c2937c2f70d8a99a282a88d23db9c42b45e4c955b4dc74b1220f9b4c0"
    ):
        raise ValueError("Pinned CLI telemetry call sites changed")

    # Keep upstream list, search, retrieval and read-only project feature gates.
    text = section(text, "// src/cli/set-allow-gate.ts\nimport * as readline", "// src/cli/version.ts")
    text = section(text, "// src/cli/telemetry/clearcut-logger.ts", "// src/cli/modern-web.ts\nensureNodeVersion();")
    text = section(text, "  legacy-scan [path]", "Options:\n", "\n")
    text = section(text, "  --skill-version <version>", "  -h, --help")
    text = section(text, '    choose: { type: "boolean" },', "  },\n  allowPositionals:")
    text = section(text, '  const skillVersion = typeof values["skill-version"]', "  if (values.help", "  const command = positionals[0];\n")
    text = section(text, "  maybeEmitUpdateMessage(skillVersion);", "  const arg = positionals")
    text = section(text, "      const searchItems = results.map", "      const jsonLines = results")
    text = re.sub(r"(?m)^ +(?:await getLogger\(\).*|const (?:startTime|latencyMs) = .*);\n", "", text)
    text = section(text, '  } else if (command === "install")', '  } else {\n    console.error(`Unknown command:')
    text = section(text, "function getCLISkillVersion()", "main().catch(")
    text = replace_once(text, 'import { spawnSync } from "node:child_process";\n', "")
    text = replace_once(text, 'import { join as join3, dirname as dirname3, basename }', 'import { join as join3 }')
    text = replace_once(text, 'fstatSync, readFileSync as readFileSync4, readdirSync, writeFileSync', 'fstatSync, writeFileSync')
    text = section(text, "function writeMwgrc(", "// src/core/paths.ts")
    text = section(text, "  const fullCommand =", "async function retrieveUseCase(", r'''  const policy = explicitOptOut ? "Project policy disables this guidance." : "This guidance requires explicit project opt-in.";
  return `> [!CAUTION]
> **${policy}** Guide \`${guideId}\` covers ${guideSummary}. Use a cross-browser approach instead unless the project owner has approved \`"${optInKey}": true\` in \`.mwgrc\`. Do not change project policy or read around this gate.`;
}
''')
    return text


def install(out, version):
    manifest = json.loads(Path("package.json").read_text(encoding="utf-8"))
    if (manifest["name"], manifest["version"], manifest["license"]) != ("modern-web-guidance", version, "Apache-2.0"):
        raise ValueError("Unexpected npm release manifest")
    for notice, digest in NOTICES.items():
        if hashlib.sha256(Path(notice).read_bytes()).hexdigest() != digest:
            raise ValueError(f"Unexpected upstream {notice}")

    skills = out / "share/modern-web-guidance/skills"
    web = skills / "modern-web-guidance"
    chrome = skills / "chrome-extensions"
    originals = Path("skills/modern-web-guidance")
    cli = adapt_cli((originals / "modern-web.mjs").read_bytes().decode("utf-8"))
    for folder in (web, chrome):
        source = Path("skills") / folder.name
        folder.mkdir(parents=True)
        for name in ("SKILL.md", "skill-version.txt"):
            shutil.copyfile(source / name, folder / name)
        for notice in NOTICES:
            shutil.copyfile(notice, folder / notice)
        write(folder / "LOCAL_CHANGES.md", (
            "Adapted from GoogleChrome Modern Web Guidance for this Nix distribution.\n"
            "Modern Web Guidance uses the bundled offline CLI rather than a package runner.\n"
            "Chrome Extensions guidance keeps CSP strict and restricts automation to reviewed code.\n"
        ))

    shutil.copytree(originals / "guides", web / "guides")
    shutil.copytree(Path("skills/chrome-extensions/references"), chrome / "references")
    adapt_web_skill(web / "SKILL.md")
    adapt_extensions(chrome)
    for guide in (web / "guides").rglob("*.md"):
        text = guide.read_text(encoding="utf-8")
        if MOVING_COMMAND in text:
            write(guide, text.replace(MOVING_COMMAND, LOCAL_COMMAND))

    runtime = out / "libexec/modern-web-guidance"
    (runtime / "gen").mkdir(parents=True)
    write(runtime / "LOCAL_CHANGES.md", "The CLI was adapted for offline use, source-map links were removed, and gen/guide-chunks.json.gz uses pinned CLI commands.\n")
    (runtime / "guides").symlink_to(web / "guides", target_is_directory=True)
    write(runtime / "package.json", json.dumps({"version": version}) + "\n")
    for asset in ("guides.json", "query-words.json", "guide-chunks.i8", "query-words.i8", "guide-chunks.scale.f32", "query-words.scale.f32"):
        shutil.copyfile(originals / "gen" / asset, runtime / "gen" / asset)
    # Search's textual chunks repeat the same commands. Preserve order and
    # vector assets; substitute only the identical moving invocation in the text.
    chunks = Path("gen/guide-chunks.json.gz")
    data = gzip.decompress((originals / chunks).read_bytes())
    (runtime / chunks).write_bytes(gzip.compress(data.replace(MOVING_COMMAND.encode(), LOCAL_COMMAND.encode()), mtime=0))
    write(runtime / "modern-web.mjs", cli)
    search = (originals / "search.mjs").read_text(encoding="utf-8")
    write(runtime / "search.mjs", replace_once(search, "//# sourceMappingURL=search.mjs.map\n", ""))


if __name__ == "__main__":
    install(Path(sys.argv[1]), sys.argv[2])
