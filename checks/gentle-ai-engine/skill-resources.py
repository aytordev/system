"""Reject symlinks in a canonical packaged skill, before publication is copied."""

from pathlib import Path
import sys


root = Path(sys.argv[1])
link = root if root.is_symlink() else min(
    (path for path in root.rglob("*") if path.is_symlink()), default=None
)
if link is not None:
    sys.exit(f"unexpected symlink in canonical skill: {link.relative_to(root)}")
