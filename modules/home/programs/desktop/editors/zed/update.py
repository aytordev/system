"""Pinned, reviewed Zed snapshots. Hashes provide integrity, not authenticity.

CLI: verify --root MODULE_OR_CHECKOUT
     refresh --root MODULE_OR_CHECKOUT --rev FULL_COMMIT
     refresh --root MODULE_OR_CHECKOUT --rev FULL_COMMIT --apply \
         --reviewed-report-sha256 DIGEST

adoption.json (strict JSON) owns schema=1, target_version (review context, not
GUI validation), settings=[{path: [object keys...], expected: JSON value}], and
keymap=[{context: string|null, chord: string, expected: action}]. Null context
selects a block with no context. Settings paths may select entire objects, but
any changed child then requires a new expected value. Prefix-overlapping paths,
repeated selectors and selected context/chord collisions are rejected. Inert
collisions remain archived and appear as ordered occurrences in the report.
Tasks are archived, never selected. Keymap block order follows upstream.

profile.json is {schema:1, target_version, settings:object, keymap:array}.
Consumers compose these selected values with their independently owned data.
Generations contain raw/{settings,keymap,tasks}.json, raw/LICENSE,
normalized/{settings,keymap,tasks}.json, adoption.json, profile.json and
manifest.json. snapshot.json names revision-SHA256(manifest) and its hash.
No timestamps enter content identity. Failed publication can leave unreferenced
.pending-* directories; there is deliberately no historical garbage collection.
"""
import sys

sys.dont_write_bytecode = True

import argparse
from contextlib import contextmanager
import fcntl
import hashlib
import json
import math
import os
from pathlib import Path
import re
import ssl
import stat
import tempfile
import urllib.error
import urllib.request

import json5
REPOSITORY = "jellydn/zed-101-setup"
FILES = ("settings.json", "keymap.json", "tasks.json", "LICENSE")
MAX_BYTES = 2 * 1024 * 1024
MAX_ARTIFACT_BYTES = 32 * 1024 * 1024
TIMEOUT = 30
MODULE = Path("modules/home/programs/desktop/editors/zed")
REVISION = re.compile(r"[0-9a-f]{40}")
HASH = re.compile(r"[0-9a-f]{64}")
GENERATION = re.compile(r"[0-9a-f]{40}-[0-9a-f]{64}")


class UpdateError(ValueError):
    """Rejected input, stale review, or unsuccessful publication."""


def require(condition, message):
    if not condition:
        raise UpdateError(message)


def encode(value):
    try:
        return (json.dumps(value, sort_keys=True, indent=2, ensure_ascii=False, allow_nan=False) + "\n").encode("utf-8")
    except (ValueError, UnicodeError, RecursionError) as error:
        raise UpdateError(f"not finite UTF-8 JSON: {error}") from error


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, f"duplicate JSON key: {key}")
        result[key] = value
    return result


def finite(value):
    if isinstance(value, float):
        require(math.isfinite(value), "nonfinite JSON number")
    elif isinstance(value, dict):
        for child in value.values():
            finite(child)
    elif isinstance(value, list):
        for child in value:
            finite(child)


def decode(raw, *, jsonc=False):
    require(isinstance(raw, bytes) and len(raw) <= MAX_ARTIFACT_BYTES, "invalid or oversized JSON bytes")
    try:
        text = raw.decode("utf-8", errors="strict")
        if jsonc:
            value = json5.loads(text, allow_duplicate_keys=False, consume_trailing=True)
        else:
            value = json.loads(text, object_pairs_hook=unique_object)
        finite(value)
        encode(value)  # Also rejects escaped lone surrogates.
        return value
    except (ValueError, UnicodeError, RecursionError) as error:
        raise UpdateError(f"invalid JSON: {error}") from error


def action(value):
    return value is None or isinstance(value, str) or (
        isinstance(value, list) and len(value) == 2 and isinstance(value[0], str)
    )


def parse_source(raw, name):
    require(name in FILES and name != "LICENSE", "unknown JSON source")
    require(isinstance(raw, bytes) and len(raw) <= MAX_BYTES, f"{name}: source size limit")
    value = decode(raw, jsonc=True)
    if name == "settings.json":
        require(isinstance(value, dict), "settings must be an object")
    elif name == "tasks.json":
        require(isinstance(value, list) and all(isinstance(v, dict) for v in value), "tasks must be an array of objects")
    else:
        require(isinstance(value, list), "keymap must be an array")
        for block in value:
            require(isinstance(block, dict) and set(block) <= {"context", "bindings"}, "invalid keymap block")
            require("context" not in block or isinstance(block["context"], str), "context must be a string")
            require(isinstance(block.get("bindings"), dict), "bindings must be an object")
            require(all(key and action(v) for key, v in block["bindings"].items()), "invalid chord/action")
    return value


def policy_from(raw):
    policy = decode(raw)
    require(isinstance(policy, dict) and set(policy) == {"schema", "target_version", "settings", "keymap"}, "invalid adoption policy fields")
    require(type(policy["schema"]) is int and policy["schema"] == 1, "unsupported policy schema")
    require(isinstance(policy["target_version"], str) and policy["target_version"].strip(), "target_version is required")
    require(isinstance(policy["settings"], list) and isinstance(policy["keymap"], list), "policy selections must be arrays")
    paths = []
    for item in policy["settings"]:
        require(isinstance(item, dict) and set(item) == {"path", "expected"}, "invalid setting selector")
        path = item["path"]
        require(isinstance(path, list) and path and all(isinstance(k, str) and k for k in path), "setting path must be nonempty object keys")
        for other in paths:
            require(path[:len(other)] != other and other[:len(path)] != path, "overlapping setting selectors")
        paths.append(path)
    selectors = set()
    for item in policy["keymap"]:
        require(isinstance(item, dict) and set(item) == {"context", "chord", "expected"}, "invalid keymap selector")
        require(item["context"] is None or isinstance(item["context"], str), "invalid selector context")
        require(isinstance(item["chord"], str) and item["chord"] and action(item["expected"]), "invalid selector chord/action")
        selector = (item["context"], item["chord"])
        require(selector not in selectors, "duplicate keymap selector")
        selectors.add(selector)
    return policy


def bindings(keymap):
    entries = {}
    for block in keymap:
        for chord, value in block["bindings"].items():
            entries.setdefault((block.get("context"), chord), []).append(value)
    return entries


def select_profile(documents, policy):
    settings, keymap, errors = {}, [], []
    for item in policy["settings"]:
        path = item["path"]
        value = documents["settings.json"]
        for key in path:
            if not isinstance(value, dict) or key not in value:
                errors.append({"path": path, "reason": "selected setting missing"})
                break
            value = value[key]
        else:
            if encode(value) != encode(item["expected"]):
                errors.append({"path": path, "reason": "selected setting changed", "expected": item["expected"], "actual": value})
                continue
            target = settings
            for key in path[:-1]:
                target = target.setdefault(key, {})
            target[path[-1]] = value
    entries = bindings(documents["keymap.json"])
    selected = set()
    for item in policy["keymap"]:
        selector = (item["context"], item["chord"])
        matches = entries.get(selector, [])
        if len(matches) != 1 or encode(matches[0]) != encode(item["expected"]):
            errors.append({"context": selector[0], "chord": selector[1], "reason": "selected binding missing, ambiguous or changed", "actual": matches, "expected": item["expected"]})
        else:
            selected.add(selector)
    for block in documents["keymap.json"]:
        adopted = {k: v for k, v in block["bindings"].items() if (block.get("context"), k) in selected}
        if adopted:
            keymap.append(({"context": block["context"]} if "context" in block else {}) | {"bindings": adopted})
    profile = {"schema": 1, "target_version": policy["target_version"], "settings": settings, "keymap": keymap}
    return profile, errors


def build_generation(raw, policy, revision):
    documents = {}
    for name in FILES:
        require(isinstance(raw[name], bytes) and 0 < len(raw[name]) <= MAX_BYTES, f"{name}: empty or oversized source")
        if name != "LICENSE":
            documents[name] = parse_source(raw[name], name)
        else:
            try:
                raw[name].decode("utf-8", errors="strict")
            except UnicodeError as error:
                raise UpdateError("LICENSE: invalid UTF-8") from error
    profile, errors = select_profile(documents, policy)
    artifacts = {f"raw/{name}": value for name, value in raw.items()}
    artifacts.update({f"normalized/{name}": encode(value) for name, value in documents.items()})
    artifacts.update({"adoption.json": encode(policy), "profile.json": encode(profile)})
    manifest = {"schema": 1, "source": {"repository": REPOSITORY, "revision": revision},
                "target_version": policy["target_version"], "artifacts": {name: sha(value) for name, value in artifacts.items()}}
    artifacts["manifest.json"] = encode(manifest)
    generation = f"{revision}-{sha(artifacts['manifest.json'])}"
    return generation, artifacts, documents, profile, errors


def safe_path(root, relative):
    path = Path(relative)
    require(not path.is_absolute() and path.parts and all(p not in (".", "..") for p in path.parts), "unsafe relative path")
    current = root
    for part in path.parts:
        current = current / part
        require(not current.is_symlink(), f"symlink not allowed: {current}")
    return current


def explicit_root(value):
    root = Path(os.path.abspath(value))
    # Reject symlink aliases, including an explicit root pointing at live config.
    current = Path(root.anchor)
    for part in root.parts[1:]:
        current /= part
        require(not current.is_symlink(), f"symlink root component: {current}")
    require(root.is_dir(), "--root must be an existing module or checkout directory")
    module = safe_path(root, MODULE)
    if module.is_dir():
        root = module
    # This tool must not be used as a live Zed configuration updater.
    live = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "zed"
    forbidden = [live.resolve(), (Path.home() / ".config/zed").resolve()]
    require(not any(root == path or path in root.parents for path in forbidden), "live Zed configuration is not an allowed root")
    return root


def read_file(root, relative, limit=MAX_ARTIFACT_BYTES):
    path = safe_path(root, relative)
    flags = os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK
    try:
        with os.fdopen(os.open(path, flags), "rb") as stream:
            require(stat.S_ISREG(os.fstat(stream.fileno()).st_mode), f"not a regular file: {relative}")
            value = stream.read(limit + 1)
        require(len(value) <= limit, f"oversized file: {relative}")
        return value
    except OSError as error:
        raise UpdateError(f"cannot read {relative}: {error}") from error


def active_pointer(root):
    path = safe_path(root, "snapshot.json")
    if not path.exists():
        return None
    return read_file(root, "snapshot.json")


def verify_generation(directory, generation, manifest_sha256):
    manifest_raw = read_file(directory, "manifest.json")
    require(sha(manifest_raw) == manifest_sha256, "manifest hash mismatch")
    manifest = decode(manifest_raw)
    require(isinstance(manifest, dict) and set(manifest) == {"schema", "source", "target_version", "artifacts"}, "invalid manifest")
    source = manifest["source"]
    require(isinstance(source, dict) and set(source) == {"repository", "revision"} and source["repository"] == REPOSITORY, "invalid source repository")
    revision = source["revision"]
    require(isinstance(revision, str) and REVISION.fullmatch(revision), "invalid source revision")
    require(generation == f"{revision}-{manifest_sha256}", "generation identity mismatch")
    expected = {f"raw/{name}" for name in FILES} | {f"normalized/{name}" for name in FILES if name != "LICENSE"} | {"profile.json", "adoption.json"}
    hashes = manifest["artifacts"]
    require(isinstance(hashes, dict) and set(hashes) == expected, "manifest artifact allow-list mismatch")
    stored = {}
    for name, checksum in hashes.items():
        require(isinstance(checksum, str) and HASH.fullmatch(checksum), "invalid artifact checksum")
        stored[name] = read_file(directory, name)
        require(sha(stored[name]) == checksum, f"artifact hash mismatch: {name}")
    policy = policy_from(stored["adoption.json"])
    raw = {name: stored[f"raw/{name}"] for name in FILES}
    _, rebuilt, documents, profile, errors = build_generation(raw, policy, revision)
    require(not errors, "archived policy no longer selects exact values")
    require(rebuilt == stored | {"manifest.json": manifest_raw}, "noncanonical or inconsistent generated artifacts")
    return {"generation": generation, "manifest_sha256": manifest_sha256, "profile": profile,
            "documents": documents, "policy": policy, "manifest": manifest}


def verify_active(root, pointer_raw):
    require(pointer_raw is not None, "snapshot.json is missing; bootstrap with a reviewed refresh")
    pointer = decode(pointer_raw)
    require(isinstance(pointer, dict) and set(pointer) == {"schema", "generation", "manifest_sha256"}, "invalid snapshot pointer")
    require(type(pointer["schema"]) is int and pointer["schema"] == 1, "invalid pointer schema")
    name, checksum = pointer["generation"], pointer["manifest_sha256"]
    require(isinstance(name, str) and GENERATION.fullmatch(name), "unsafe snapshot generation")
    require(isinstance(checksum, str) and HASH.fullmatch(checksum), "invalid manifest hash")
    return verify_generation(safe_path(root, f"snapshots/{name}"), name, checksum)


def verify(root):
    root = explicit_root(root)
    result = verify_active(root, active_pointer(root))
    return {key: result[key] for key in ("generation", "manifest_sha256", "profile")}


def setting_entries(value, path=()):
    result = {}
    for key, child in value.items():
        child_path = path + (key,)
        if isinstance(child, dict) and child:
            result.update(setting_entries(child, child_path))
        else:
            result[child_path] = child
    return result


def delta(before, after, selector):
    result = {"added": [], "changed": [], "removed": []}
    for key in sorted(set(before) | set(after), key=lambda k: encode(list(k))):
        if key not in before:
            result["added"].append(selector(key) | {"after": after[key]})
        elif key not in after:
            result["removed"].append(selector(key) | {"before": before[key]})
        elif encode(before[key]) != encode(after[key]):
            result["changed"].append(selector(key) | {"before": before[key], "after": after[key]})
    return result


def keymap_order(keymap):
    return [{"context": block.get("context"), "chords": sorted(block["bindings"])} for block in keymap]


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise UpdateError("source redirects are not allowed")


def download(revision, name):
    require(REVISION.fullmatch(revision) and name in FILES, "invalid fixed source request")
    url = f"https://raw.githubusercontent.com/{REPOSITORY}/{revision}/{name}"
    # No environment proxies, redirects or alternative URL knobs. TLS uses the
    # wrapper's pinned CA bundle; callers can inject bytes only through Python.
    context = ssl.create_default_context(cafile=os.environ.get("SSL_CERT_FILE"))
    opener = urllib.request.build_opener(
        urllib.request.ProxyHandler({}), NoRedirect(),
        urllib.request.HTTPSHandler(context=context),
    )
    with opener.open(url, timeout=TIMEOUT) as response:
        require(response.status == 200, "unexpected source response")
        raw = response.read(MAX_BYTES + 1)
    require(len(raw) <= MAX_BYTES, f"{name}: download size limit")
    return raw


@contextmanager
def publication_lock(root):
    path = safe_path(root, ".updater.lock")
    descriptor = os.open(path, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW | os.O_NONBLOCK, 0o600)
    try:
        require(stat.S_ISREG(os.fstat(descriptor).st_mode), "lock must be a regular file")
        try:
            fcntl.flock(descriptor, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise UpdateError("another refresh holds the publication lock") from error
        yield
    finally:
        os.close(descriptor)  # Persistent lock inode: never unlink a shared lock.


def write_new(path, raw):
    with path.open("xb") as stream:
        stream.write(raw)
        stream.flush()
        os.fsync(stream.fileno())


def publish(root, generation, artifacts, pointer_before, policy_before):
    with publication_lock(root):
        require(active_pointer(root) == pointer_before, "active pointer changed during refresh")
        require(read_file(root, "adoption.json") == policy_before, "policy changed during refresh")
        snapshots = safe_path(root, "snapshots")
        snapshots.mkdir(exist_ok=True)
        destination = safe_path(root, f"snapshots/{generation}")
        manifest_hash = sha(artifacts["manifest.json"])
        if destination.exists():
            verify_generation(destination, generation, manifest_hash)
        else:
            # Incomplete work is never named by the active pointer. Retain failed
            # staging directories for diagnosis rather than deleting history.
            stage = Path(tempfile.mkdtemp(prefix=".pending-", dir=snapshots))
            (stage / "raw").mkdir()
            (stage / "normalized").mkdir()
            for name, value in artifacts.items():
                write_new(stage / name, value)
            verify_generation(stage, generation, manifest_hash)
            os.rename(stage, destination)
        require(active_pointer(root) == pointer_before, "active pointer changed before publication")
        require(read_file(root, "adoption.json") == policy_before, "policy changed before publication")
        pointer = encode({"schema": 1, "generation": generation, "manifest_sha256": manifest_hash})
        fd, temporary = tempfile.mkstemp(prefix=".snapshot-", dir=root)
        with os.fdopen(fd, "wb") as stream:
            stream.write(pointer)
            stream.flush()
            os.fsync(stream.fileno())
        # Check again after writing the temporary pointer; cooperative updaters
        # hold this same lock. Root is trusted against hostile local writers.
        require(active_pointer(root) == pointer_before, "active pointer changed before atomic replace")
        require(read_file(root, "adoption.json") == policy_before, "policy changed before atomic replace")
        os.replace(temporary, safe_path(root, "snapshot.json"))


def refresh(root, revision, *, apply=False, reviewed_report_sha256=None, downloader=None):
    require(isinstance(revision, str) and REVISION.fullmatch(revision), "--rev requires a full lowercase 40-character commit")
    require(apply or reviewed_report_sha256 is None, "review digest requires --apply")
    if apply:
        require(isinstance(reviewed_report_sha256, str) and HASH.fullmatch(reviewed_report_sha256), "--apply requires --reviewed-report-sha256")
    root = explicit_root(root)
    pointer_raw = active_pointer(root)
    old = verify_active(root, pointer_raw) if pointer_raw is not None else None
    policy_raw = read_file(root, "adoption.json")
    policy = policy_from(policy_raw)
    try:
        fetch = downloader or download
        raw = {name: fetch(revision, name) for name in FILES}
        generation, artifacts, documents, profile, errors = build_generation(raw, policy, revision)
        old_documents = old["documents"] if old else {"settings.json": {}, "keymap.json": [], "tasks.json": []}
        keymap_delta = delta(bindings(old_documents["keymap.json"]), bindings(documents["keymap.json"]),
                             lambda key: {"context": key[0], "chord": key[1]})
        old_order, new_order = keymap_order(old_documents["keymap.json"]), keymap_order(documents["keymap.json"])
        keymap_delta.update({"ordering_changed": old_order != new_order, "order_before": old_order, "order_after": new_order})
        source = {"repository": REPOSITORY, "revision": revision, "hashes": {name: sha(raw[name]) for name in FILES}}
        old_source = None if old is None else old["manifest"]["source"] | {
            "hashes": {name: old["manifest"]["artifacts"][f"raw/{name}"] for name in FILES}}
        report = {
            "schema": 1, "active_pointer_sha256": sha(pointer_raw) if pointer_raw is not None else None,
            "source": {"before": old_source, "after": source},
            "license": {"before": old_source["hashes"]["LICENSE"] if old else None, "after": sha(raw["LICENSE"])},
            "policy": {"input_sha256": sha(policy_raw), "before": old["policy"] if old else None, "after": policy},
            "target_version": {"before": old["profile"]["target_version"] if old else None, "after": policy["target_version"]},
            "settings": delta(setting_entries(old_documents["settings.json"]), setting_entries(documents["settings.json"]), lambda key: {"path": list(key)}),
            "keymap": keymap_delta, "policy_errors": errors,
            "effective_profile": {"before": old["profile"] if old else None, "after": profile if not errors else None},
            "candidate": {"generation": generation, "hashes": {name: sha(value) for name, value in artifacts.items()}},
        }
        result = {"report": report, "report_sha256": sha(encode(report))}
        require(active_pointer(root) == pointer_raw, "active pointer changed during refresh")
        require(read_file(root, "adoption.json") == policy_raw, "policy changed during refresh")
        if apply:
            require(result["report_sha256"] == reviewed_report_sha256, "reviewed report digest is stale or does not match")
            require(not errors, "adoption policy requires explicit expected-value updates; inspect policy_errors")
            publish(root, generation, artifacts, pointer_raw, policy_raw)
        return result
    except (OSError, urllib.error.URLError, RecursionError) as error:
        raise UpdateError(f"refresh failed without publishing an active pointer: {error}") from error


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command", required=True)
    for name in ("verify", "refresh"):
        command = commands.add_parser(name)
        command.add_argument("--root", required=True, type=Path)
        if name == "refresh":
            command.add_argument("--rev", required=True)
            command.add_argument("--apply", action="store_true")
            command.add_argument("--reviewed-report-sha256")
    args = parser.parse_args()
    try:
        if args.command == "verify":
            result = verify(args.root)
        else:
            result = refresh(args.root, args.rev, apply=args.apply, reviewed_report_sha256=args.reviewed_report_sha256)
        sys.stdout.buffer.write(encode(result))
        return 0
    except (UpdateError, OSError) as error:
        print(f"zed-upstream: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
