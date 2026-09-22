"""Check bundled resource references in one isolated, dereferenced skill copy."""

import re
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
assert (root / "SKILL.md").is_file(), root
assert all(not path.is_symlink() for path in root.rglob("*")), root


def check_resource(path):
    resolved = path.resolve()
    assert resolved.is_relative_to(root), f"resource escapes skill folder: {path}"
    assert resolved.exists(), f"missing bundled resource: {path}"


for document in root.rglob("*.md"):
    # Fenced examples demonstrate authoring; they are not runtime dependencies.
    text = re.sub(r"(?ms)^```[^\n]*\n.*?^```[^\n]*$", "", document.read_text())
    for target in re.findall(r"\]\(([^)\s]+)\)", text):
        if "://" in target or target.startswith(("#", "mailto:")):
            continue
        check_resource(document.parent / target.split("#", 1)[0])
    # Bare operational paths use the skill root; Markdown links use their file.
    for target in re.findall(r"`((?:rules|references|scripts)/[\w/-]+\.(?:md|py))`", text):
        check_resource(root / target)
    if document.name == "SKILL.md":
        # Quick-reference rule names in these packages abbreviate rules/*.md.
        for rule in re.findall(r"(?m)^- `([a-z]+-[a-z-]+)` [—–-]", text):
            check_resource(root / "rules" / f"{rule}.md")

print(f"PASS isolated folder resources: {root.name}")
