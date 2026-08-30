#!/usr/bin/env python3
"""Split a nixosOptionsDoc markdown file into per-category pages for mdbook.

The option namespace is `aytordev.<category>.<subcategory>.<item>.<option>`.
This splits the flat `## `-headed options doc into:

- one page per `<category>` (e.g. `programs`, `suites`, `theme`)
- within each page, a real option **tree**: options are grouped by their
  enclosing sub-namespace, every namespace becomes a `##`/`###` header, and
  options render as `####` leaf blocks. The page therefore reads as a nested
  tree instead of a flat list.
- a SUMMARY.md fragment listing the category pages.

Usage:
  split-options.py <in.md> <out-dir> <prefix-label>
"""

import os
import re
import sys


def unescape(name: str) -> str:
    return name.replace("\\.", ".")


class Node:
    __slots__ = ("name", "children", "options")

    def __init__(self, name: str):
        self.name = name
        self.children = {}
        self.options = {}  # full path -> body

    def child(self, part: str) -> "Node":
        if part not in self.children:
            self.children[part] = Node(part)
        return self.children[part]


def build_tree(options: list) -> Node:
    """Build a namespace tree from flat (path, body) option entries."""
    root = Node("root")
    for full, body in options:
        segments = full.split(".")
        node = root
        # `aytordev.<category>.` are given by the page, drop first two.
        for part in segments[2:-1]:
            node = node.child(part)
        node.options[full] = body
    return root


def prereorder(node: Node):
    """Sort children by name for a deterministic diffable tree."""
    node.children = {
        name: node.children[name] for name in sorted(node.children)
    }
    node.options = {
        name: node.options[name] for name in sorted(node.options)
    }
    for child in node.children.values():
        prereorder(child)


def render(node: Node, depth: int, out) -> None:
    """Emit a namespace as a header, then children then leaf options."""
    if depth > 1:
        out.write(f"{'#' * min(depth, 4)} {node.name}\n\n")
    for child in node.children.values():
        render(child, depth + 1, out)
    for full, body in node.options.items():
        out.write(f"{'#' * min(depth + 1, 4)} {full}\n{body}\n")


def main() -> int:
    if len(sys.argv) != 4:
        print(__doc__, file=sys.stderr)
        return 2

    in_path, out_dir, prefix = sys.argv[1], sys.argv[2], sys.argv[3]
    os.makedirs(out_dir, exist_ok=True)

    with open(in_path, encoding="utf-8") as fh:
        text = fh.read()

    parts = re.split(r"^## ", text, flags=re.MULTILINE)
    categories = {}  # category -> list of (full_path, body)

    for part in parts[1:]:
        nl = part.find("\n")
        raw_name = part[:nl].rstrip() if nl != -1 else part.rstrip()
        name = unescape(raw_name.split()[0])
        body = part[nl:] if nl != -1 else part[nl:] if nl != -1 else ("\n" if nl == -1 else "")
        body = part[nl:] if nl != -1 else ""
        segments = name.split(".")
        if segments[0] != "aytordev":
            continue
        category = segments[1] if len(segments) > 1 else "other"
        categories.setdefault(category, []).append((name, body.rstrip() + "\n"))

    summary_lines = [f"# {prefix}", ""]
    for category in sorted(categories):
        summary_lines.append(f"- [{category}](./{category}.md)")
        gpath = os.path.join(out_dir, f"{category}.md")
        with open(gpath, "w", encoding="utf-8") as fh:
            fh.write(f"# {category}\n\n")
            tree = build_tree(categories[category])
            prereorder(tree)
            render(tree, depth=1, out=fh)

    with open(os.path.join(out_dir, f"SUMMARY.{prefix}"), "w", encoding="utf-8") as fh:
        fh.write("\n".join(summary_lines) + "\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())