"""Behavior tests: all roots are test-owned temporary directories; no network."""
import copy
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import socket
import subprocess
import tempfile
import unittest
from unittest.mock import MagicMock, patch

spec = importlib.util.spec_from_file_location("zed_updater", os.environ["ZED_UPDATER_SOURCE"])
u = importlib.util.module_from_spec(spec)
spec.loader.exec_module(u)

REV = "a" * 40
REV2 = "b" * 40


def encoded(value):
    return (json.dumps(value, sort_keys=True, indent=2, ensure_ascii=False, allow_nan=False) + "\n").encode()


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def verify_repository_snapshot(root):
    """Check the adopted profile, not inert upstream documents, for unsafe imports."""
    result = u.verify(root)
    forbidden_keys = {
        "agent", "agent_servers", "context_servers", "language_models", "provider",
        "tasks", "terminal", "session", "telemetry", "theme", "icon_theme",
    }
    forbidden_tokens = (
        "crofai", "opencode", "ollama", "codemux", "fff", "/users/", "/home/", "~/", "task::",
    )

    def check(value):
        if isinstance(value, dict):
            u.require(not forbidden_keys.intersection(value), "forbidden adopted setting")
            for key, child in value.items():
                check(key)
                check(child)
        elif isinstance(value, list):
            for child in value:
                check(child)
        elif isinstance(value, str):
            u.require(not any(token in value.lower() for token in forbidden_tokens), "forbidden adopted value")

    check(result["profile"])
    return result


class UpdaterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="zed-upstream-", dir=os.environ["TMPDIR"])
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.network = patch.object(socket, "create_connection", side_effect=AssertionError("network forbidden"))
        self.network.start()
        self.addCleanup(self.network.stop)
        self.raw = {
            "settings.json": b'{ // upstream\n "font_size": 14, "editor": {"tab_size": 2}, "inert": true, }\n',
            "keymap.json": encoded([
                {"context": "Editor", "bindings": {"ctrl-k": "editor::Up", "ctrl-j": "editor::Down"}},
                {"context": "Operator", "bindings": {"x": "one"}},
                {"context": "Operator", "bindings": {"x": "two"}},
                {"bindings": {"ctrl-q": "zed::Quit"}},
            ]),
            "tasks.json": b'[{"label":"never execute", "command":"touch forbidden"}]\n',
            "LICENSE": b"MIT license fixture\r\nExact bytes.\n",
        }
        self.policy = {
            "schema": 1,
            "target_version": "0.1-test",
            "settings": [{"path": ["editor", "tab_size"], "expected": 2}],
            "keymap": [{"context": "Editor", "chord": "ctrl-k", "expected": "editor::Up"}],
        }
        self.write_policy()
        self.sentinel = self.root / "preferences.nix"
        self.sentinel.write_bytes(b"human-owned sentinel\n")

    def write_policy(self):
        (self.root / "adoption.json").write_bytes(encoded(self.policy))

    def download(self, revision, name):
        self.assertIn(revision, [REV, REV2])
        return self.raw[name]

    def report(self, revision=REV, **kwargs):
        return u.refresh(self.root, revision, downloader=self.download, **kwargs)

    def apply(self, revision=REV):
        report = self.report(revision)
        return self.report(revision, apply=True, reviewed_report_sha256=report["report_sha256"])

    def generation(self):
        pointer = json.loads((self.root / "snapshot.json").read_bytes())
        return self.root / "snapshots" / pointer["generation"]

    def test_repository_check_rejects_selected_provider_and_personal_path(self):
        for value in [{"provider": "CrofAI"}, "/Users/example/bin/tool"]:
            with self.subTest(value=value):
                settings = {"editor": {"tab_size": 2}, "unsafe": value}
                self.raw["settings.json"] = encoded(settings)
                self.policy["settings"] = [{"path": ["unsafe"], "expected": value}]
                self.write_policy()
                self.apply()
                with self.assertRaisesRegex(u.UpdateError, "forbidden adopted"):
                    verify_repository_snapshot(self.root)

    def test_repository_check_rejects_selected_task_and_provider_bindings(self):
        for action in [["task::Spawn", {"task_name": "archived task"}], "ollama::Start",
                       ["workspace::Open", {"path": "/home/example/project"}]]:
            with self.subTest(action=action):
                self.raw["keymap.json"] = encoded([{"context": "Editor", "bindings": {"ctrl-k": action}}])
                self.policy["keymap"][0]["expected"] = action
                self.write_policy()
                self.apply()
                with self.assertRaisesRegex(u.UpdateError, "forbidden adopted"):
                    verify_repository_snapshot(self.root)

    def test_repository_check_allows_inert_unsafe_sources_and_archived_tasks(self):
        self.raw["settings.json"] = encoded({
            "editor": {"tab_size": 2}, "agent": {"provider": "CrofAI"},
            "terminal": {"shell": {"program": "/Users/example/bin/codemux"}},
        })
        self.raw["keymap.json"] = encoded([{
            "context": "Editor",
            "bindings": {"ctrl-k": "editor::Up", "ctrl-t": ["task::Spawn", {"task_name": "FFF"}]},
        }])
        self.apply()
        profile = verify_repository_snapshot(self.root)["profile"]
        self.assertEqual(profile["settings"], {"editor": {"tab_size": 2}})
        self.assertEqual(profile["keymap"], [{"context": "Editor", "bindings": {"ctrl-k": "editor::Up"}}])
        self.assertNotIn("tasks", profile)
        self.assertTrue((self.generation() / "normalized/tasks.json").is_file())
        self.assertFalse((self.root / "forbidden").exists())

    def test_parser_jsonc_and_array_order(self):
        self.assertEqual(u.parse_source(b'{// c\n"x":[3,1,2,],}', "settings.json"), {"x": [3, 1, 2]})

    def test_parser_rejects_duplicates_nonfinite_junk_utf8_and_shapes(self):
        for raw in [b'{"x":1,"x":2}', b'{"x":{"a":1,"a":2}}', b'{x:NaN}', b'{x:Infinity}',
                    b'{x:-Infinity}', b'{x:1e999}', b'{} garbage', b'\xff', b'[]']:
            with self.subTest(raw=raw), self.assertRaises(u.UpdateError):
                u.parse_source(raw, "settings.json")
        for name, raw in [("keymap.json", b'{}'), ("keymap.json", b'[{bindings:[]}]'),
                          ("keymap.json", b'[{context:1,bindings:{}}]'), ("tasks.json", b'{}'),
                          ("keymap.json", b'[{bindings:{x:"one",x:"two"}}]'),
                          ("keymap.json", b'[{bindings:{x:{action:"invalid"}}}]'),
                          ("tasks.json", b'["not a task object"]')]:
            with self.subTest(name=name, raw=raw), self.assertRaises(u.UpdateError):
                u.parse_source(raw, name)

    def test_bootstrap_report_is_stable_and_read_only(self):
        before = sorted(p.name for p in self.root.iterdir())
        report = self.report()
        self.assertEqual(report, self.report())
        self.assertEqual(sorted(p.name for p in self.root.iterdir()), before)
        self.assertEqual(report["report_sha256"], digest(encoded(report["report"])))
        self.assertIn(["font_size"], [entry["path"] for entry in report["report"]["settings"]["added"]])
        self.assertFalse((self.root / "snapshot.json").exists())

    def test_apply_archives_exact_bytes_and_only_explicit_adoption(self):
        self.apply()
        generation = self.generation()
        for name, raw in self.raw.items():
            self.assertEqual((generation / "raw" / name).read_bytes(), raw)
        profile = json.loads((generation / "profile.json").read_bytes())
        self.assertEqual(profile, {"schema": 1, "target_version": "0.1-test", "settings": {"editor": {"tab_size": 2}},
                                   "keymap": [{"context": "Editor", "bindings": {"ctrl-k": "editor::Up"}}]})
        self.assertNotIn("tasks", profile)
        self.assertEqual(self.sentinel.read_bytes(), b"human-owned sentinel\n")
        self.assertEqual(u.verify(self.root)["generation"], generation.name)

    def test_unreviewed_apply_refused(self):
        for token in [None, "0" * 64]:
            with self.subTest(token=token), self.assertRaises(u.UpdateError):
                self.report(apply=True, reviewed_report_sha256=token)
        self.assertFalse((self.root / "snapshot.json").exists())

    def test_selected_change_and_removal_require_policy_update(self):
        self.apply()
        pointer = (self.root / "snapshot.json").read_bytes()
        for settings in [{"editor": {"tab_size": 4}}, {"editor": {}}]:
            self.raw["settings.json"] = encoded(settings)
            report = self.report(REV2)
            self.assertTrue(report["report"]["policy_errors"])
            with self.assertRaises(u.UpdateError):
                self.report(REV2, apply=True, reviewed_report_sha256=report["report_sha256"])
            self.assertEqual((self.root / "snapshot.json").read_bytes(), pointer)
        self.raw["settings.json"] = encoded({"editor": {"tab_size": 4}})
        self.policy["settings"][0]["expected"] = 4
        self.write_policy()
        self.apply(REV2)
        self.assertEqual(u.verify(self.root)["profile"]["settings"]["editor"]["tab_size"], 4)

    def test_stale_source_policy_and_pointer_digest_refused(self):
        original = self.report()
        self.raw["LICENSE"] += b"changed\n"
        with self.assertRaises(u.UpdateError):
            self.report(apply=True, reviewed_report_sha256=original["report_sha256"])
        original = self.report()
        self.policy["target_version"] = "0.2-test"
        self.write_policy()
        with self.assertRaises(u.UpdateError):
            self.report(apply=True, reviewed_report_sha256=original["report_sha256"])
        original = self.report()
        self.apply(REV2)
        with self.assertRaises(u.UpdateError):
            self.report(apply=True, reviewed_report_sha256=original["report_sha256"])

    def test_semantic_delta_removals_changes_additions_and_reorder(self):
        self.apply()
        self.raw["settings.json"] = encoded({"editor": {"tab_size": 2}, "font_size": 16, "new": [2, 1]})
        keymap = json.loads(self.raw["keymap.json"])
        keymap[0]["bindings"].pop("ctrl-j")
        keymap[0]["bindings"]["ctrl-n"] = "editor::New"
        keymap[1]["bindings"]["x"] = "changed"
        keymap.reverse()
        self.raw["keymap.json"] = encoded(keymap)
        report = self.report(REV2)["report"]
        self.assertEqual(report["settings"]["removed"], [{"path": ["inert"], "before": True}])
        self.assertEqual(report["settings"]["changed"], [{"path": ["font_size"], "before": 14, "after": 16}])
        self.assertEqual(report["settings"]["added"], [{"path": ["new"], "after": [2, 1]}])
        self.assertTrue(report["keymap"]["ordering_changed"])
        self.assertEqual(report["keymap"]["removed"][0]["chord"], "ctrl-j")
        self.assertEqual(report["keymap"]["added"][0]["chord"], "ctrl-n")
        self.assertEqual(report["keymap"]["changed"][0]["context"], "Operator")
        self.apply(REV2)
        self.assertNotIn("new", u.verify(self.root)["profile"]["settings"])

    def test_ambiguous_and_overlapping_policy_refused_but_inert_duplicates_allowed(self):
        self.apply()  # Duplicate Operator/x entries are inert, not globally rejected.
        policies = []
        overlap = copy.deepcopy(self.policy)
        overlap["settings"].append({"path": ["editor"], "expected": {"tab_size": 2}})
        policies.append(overlap)
        duplicate = copy.deepcopy(self.policy)
        duplicate["keymap"] *= 2
        policies.append(duplicate)
        ambiguous = copy.deepcopy(self.policy)
        ambiguous["keymap"] = [{"context": "Operator", "chord": "x", "expected": "one"}]
        policies.append(ambiguous)
        for policy in policies:
            self.policy = policy
            self.write_policy()
            with self.subTest(policy=policy), self.assertRaises(u.UpdateError):
                self.apply(REV2)

    def test_download_and_parse_failures_do_not_publish(self):
        self.apply()
        before = (self.root / "snapshot.json").read_bytes()
        def failing(revision, name):
            if name == "tasks.json":
                raise OSError("injected download failure")
            return self.raw[name]
        with self.assertRaises(u.UpdateError):
            u.refresh(self.root, REV2, downloader=failing)
        self.raw["tasks.json"] = b"[broken"
        with self.assertRaises(u.UpdateError):
            self.report(REV2)
        self.assertEqual((self.root / "snapshot.json").read_bytes(), before)
        u.verify(self.root)

    def test_verify_detects_corrupt_artifacts(self):
        self.apply()
        for name in ["manifest.json", "profile.json", "raw/settings.json", "raw/LICENSE", "normalized/keymap.json", "adoption.json"]:
            path = self.generation() / name
            original = path.read_bytes()
            path.write_bytes(original + b"corrupt")
            with self.subTest(name=name), self.assertRaises(u.UpdateError):
                u.verify(self.root)
            path.write_bytes(original)
        u.verify(self.root)

    def test_offline_verify_missing_snapshot_is_clear(self):
        with self.assertRaisesRegex(u.UpdateError, "snapshot"):
            u.verify(self.root)

    def test_identical_generation_reused_and_history_preserved(self):
        self.apply()
        first = self.generation()
        stat = (first / "manifest.json").stat()
        self.apply()
        self.assertEqual(self.generation(), first)
        self.assertEqual((first / "manifest.json").stat().st_mtime_ns, stat.st_mtime_ns)
        self.apply(REV2)
        self.assertTrue(first.is_dir())

    def test_fixed_revision_and_size_bounds(self):
        for rev in ["main", "a" * 39, "A" * 40, "../" + "a" * 40]:
            with self.subTest(rev=rev), self.assertRaises(u.UpdateError):
                self.report(rev)
        self.raw["LICENSE"] = b"x" * (u.MAX_BYTES + 1)
        with self.assertRaises(u.UpdateError):
            self.report()

    def test_pointer_traversal_and_symlinks_rejected(self):
        self.apply()
        pointer_path = self.root / "snapshot.json"
        original = pointer_path.read_bytes()
        pointer = json.loads(original)
        pointer["generation"] = "../../outside"
        pointer_path.write_bytes(encoded(pointer))
        with self.assertRaises(u.UpdateError):
            u.verify(self.root)
        pointer_path.write_bytes(original)
        path = self.generation() / "profile.json"
        path.rename(self.root / "saved-profile")
        path.symlink_to(self.root / "saved-profile")
        with self.assertRaises(u.UpdateError):
            u.verify(self.root)

    def test_write_failure_keeps_previous_pointer_and_owned_file(self):
        self.apply()
        before = (self.root / "snapshot.json").read_bytes()
        reviewed = self.report(REV2)
        original_write = u.write_new
        def fail_profile(path, raw):
            if path.name == "profile.json":
                raise OSError("injected disk failure")
            return original_write(path, raw)
        with patch.object(u, "write_new", side_effect=fail_profile), self.assertRaises(u.UpdateError):
            self.report(REV2, apply=True, reviewed_report_sha256=reviewed["report_sha256"])
        self.assertEqual((self.root / "snapshot.json").read_bytes(), before)
        self.assertEqual(self.sentinel.read_bytes(), b"human-owned sentinel\n")
        u.verify(self.root)
        self.assertTrue(any(p.name.startswith(".pending-") for p in (self.root / "snapshots").iterdir()))
        self.apply(REV2)  # A failed staging directory does not prevent retry.

    def test_atomic_pointer_failure_leaves_complete_unreferenced_generation(self):
        self.apply()
        before = (self.root / "snapshot.json").read_bytes()
        reviewed = self.report(REV2)
        with patch.object(u.os, "replace", side_effect=OSError("injected rename failure")), self.assertRaises(u.UpdateError):
            self.report(REV2, apply=True, reviewed_report_sha256=reviewed["report_sha256"])
        self.assertEqual((self.root / "snapshot.json").read_bytes(), before)
        unreferenced = self.root / "snapshots" / reviewed["report"]["candidate"]["generation"]
        self.assertTrue((unreferenced / "manifest.json").is_file())
        u.verify(self.root)
        self.apply(REV2)
        self.assertEqual(self.generation(), unreferenced)

    def test_pointer_is_published_only_after_offline_generation_validation(self):
        self.apply()
        before = (self.root / "snapshot.json").read_bytes()
        original_verify = u.verify_generation
        calls = []
        def observe(directory, generation, checksum):
            calls.append(directory.name)
            self.assertEqual((self.root / "snapshot.json").read_bytes(), before)
            return original_verify(directory, generation, checksum)
        with patch.object(u, "verify_generation", side_effect=observe):
            self.apply(REV2)
        self.assertTrue(any(name.startswith(".pending-") for name in calls))
        self.assertNotEqual((self.root / "snapshot.json").read_bytes(), before)

    def test_concurrent_refresh_lock_refuses_publication(self):
        reviewed = self.report()
        with u.publication_lock(self.root), self.assertRaisesRegex(u.UpdateError, "lock"):
            self.report(apply=True, reviewed_report_sha256=reviewed["report_sha256"])
        self.assertFalse((self.root / "snapshot.json").exists())
        self.apply()

    def test_pointer_or_policy_mutation_during_download_is_refused(self):
        self.apply()
        original_pointer = (self.root / "snapshot.json").read_bytes()
        original_policy = (self.root / "adoption.json").read_bytes()
        for target, original in [("snapshot.json", original_pointer), ("adoption.json", original_policy)]:
            def mutate(revision, name):
                (self.root / target).write_bytes(original + b"\n")
                return self.raw[name]
            with self.subTest(target=target), self.assertRaisesRegex(u.UpdateError, "changed during refresh"):
                u.refresh(self.root, REV2, downloader=mutate)
            (self.root / target).write_bytes(original)
        u.verify(self.root)

    def test_selected_binding_changes_and_removals_are_gated(self):
        self.apply()
        original = json.loads(self.raw["keymap.json"])
        for action in [None, "editor::Other"]:
            keymap = copy.deepcopy(original)
            if action is None:
                keymap[0]["bindings"].pop("ctrl-k")
            else:
                keymap[0]["bindings"]["ctrl-k"] = action
            self.raw["keymap.json"] = encoded(keymap)
            report = self.report(REV2)
            self.assertTrue(report["report"]["policy_errors"])
            with self.assertRaises(u.UpdateError):
                self.report(REV2, apply=True, reviewed_report_sha256=report["report_sha256"])
        self.policy["keymap"][0]["expected"] = "editor::Other"
        self.write_policy()
        self.apply(REV2)
        self.assertEqual(u.verify(self.root)["profile"]["keymap"][0]["bindings"]["ctrl-k"], "editor::Other")

    def test_selected_binding_order_tracks_upstream_not_policy(self):
        self.policy["keymap"].insert(0, {"context": None, "chord": "ctrl-q", "expected": "zed::Quit"})
        self.write_policy()
        self.apply()
        profile = u.verify(self.root)["profile"]
        self.assertEqual(profile["keymap"][0]["context"], "Editor")
        self.assertNotIn("context", profile["keymap"][1])
        keymap = json.loads(self.raw["keymap.json"])
        # Move selected blocks without changing inert collision precedence.
        keymap[0], keymap[-1] = keymap[-1], keymap[0]
        self.raw["keymap.json"] = encoded(keymap)
        report = self.report(REV2)["report"]
        self.assertTrue(report["keymap"]["ordering_changed"])
        self.assertFalse(any(report["keymap"][kind] for kind in ["added", "changed", "removed"]))
        self.apply(REV2)
        self.assertNotIn("context", u.verify(self.root)["profile"]["keymap"][0])

    def test_policy_is_exact_and_strict_not_python_equality(self):
        self.raw["settings.json"] = encoded({"editor": {"tab_size": True}})
        self.policy["settings"][0]["expected"] = 1
        self.write_policy()
        self.assertTrue(self.report()["report"]["policy_errors"])
        for raw in [b'{"schema":1,"schema":1}', b'{schema:1}', b'{"schema":NaN}', encoded(self.policy | {"import_all": True})]:
            (self.root / "adoption.json").write_bytes(raw)
            with self.subTest(raw=raw), self.assertRaises(u.UpdateError):
                self.report()

    def test_object_selection_cannot_silently_adopt_new_children(self):
        self.policy["settings"] = [{"path": ["editor"], "expected": {"tab_size": 2}}]
        self.write_policy()
        self.apply()
        self.raw["settings.json"] = encoded({"editor": {"tab_size": 2, "unreviewed": True}})
        self.assertTrue(self.report(REV2)["report"]["policy_errors"])
        with self.assertRaises(u.UpdateError):
            self.apply(REV2)

    def test_task_license_policy_and_effective_profile_changes_are_reported(self):
        self.apply()
        self.raw["tasks.json"] = b'[{"command":"never execute new task"}]'
        self.raw["LICENSE"] += b"license changed"
        self.policy["target_version"] = "next-version"
        self.policy["settings"].append({"path": ["font_size"], "expected": 14})
        self.write_policy()
        report = self.report(REV2)["report"]
        self.assertNotEqual(report["source"]["before"]["hashes"]["tasks.json"], report["source"]["after"]["hashes"]["tasks.json"])
        for field in ["license", "policy", "target_version", "effective_profile"]:
            self.assertNotEqual(report[field]["before"], report[field]["after"])
        self.apply(REV2)
        self.assertNotIn("tasks", u.verify(self.root)["profile"])
        self.assertFalse((self.root / "forbidden").exists())

    def test_report_digest_covers_generated_artifacts(self):
        reviewed = self.report()
        original_encode = u.encode
        def altered(value):
            raw = original_encode(value)
            if isinstance(value, dict) and set(value) == {"schema", "target_version", "settings", "keymap"} and isinstance(value["settings"], dict):
                return raw + b"\n"
            return raw
        with patch.object(u, "encode", side_effect=altered), self.assertRaisesRegex(u.UpdateError, "digest"):
            self.report(apply=True, reviewed_report_sha256=reviewed["report_sha256"])
        self.assertFalse((self.root / "snapshot.json").exists())

    def test_recomputed_hashes_do_not_hide_inconsistent_generated_profile(self):
        self.apply()
        generation = self.generation()
        profile = generation / "profile.json"
        profile.write_bytes(encoded({"schema": 1, "target_version": "0.1-test", "settings": {"injected": True}, "keymap": []}))
        manifest_path = generation / "manifest.json"
        manifest = json.loads(manifest_path.read_bytes())
        manifest["artifacts"]["profile.json"] = digest(profile.read_bytes())
        manifest_path.write_bytes(encoded(manifest))
        checksum = digest(manifest_path.read_bytes())
        name = f"{REV}-{checksum}"
        generation.rename(generation.parent / name)
        (self.root / "snapshot.json").write_bytes(encoded({"schema": 1, "generation": name, "manifest_sha256": checksum}))
        with self.assertRaisesRegex(u.UpdateError, "inconsistent"):
            u.verify(self.root)

    def test_manifest_paths_are_allowlisted_before_file_access(self):
        self.apply()
        generation = self.generation()
        manifest_path = generation / "manifest.json"
        manifest = json.loads(manifest_path.read_bytes())
        manifest["artifacts"]["../../preferences.nix"] = digest(self.sentinel.read_bytes())
        manifest_path.write_bytes(encoded(manifest))
        checksum = digest(manifest_path.read_bytes())
        name = f"{REV}-{checksum}"
        generation.rename(generation.parent / name)
        (self.root / "snapshot.json").write_bytes(encoded({"schema": 1, "generation": name, "manifest_sha256": checksum}))
        with self.assertRaisesRegex(u.UpdateError, "allow-list"):
            u.verify(self.root)

    def test_snapshot_policy_and_lock_symlinks_cannot_escape_root(self):
        outside = self.root / "outside"
        outside.mkdir()
        (self.root / "snapshots").symlink_to(outside, target_is_directory=True)
        with self.assertRaises(u.UpdateError):
            self.apply()
        self.assertEqual(list(outside.iterdir()), [])
        (self.root / "snapshots").unlink()  # Test-owned fixture only.
        (self.root / "adoption.json").rename(outside / "adoption.json")
        (self.root / "adoption.json").symlink_to(outside / "adoption.json")
        with self.assertRaises(u.UpdateError):
            self.report()
        (self.root / "adoption.json").unlink()
        self.write_policy()
        (self.root / ".updater.lock").unlink()
        (self.root / ".updater.lock").symlink_to(self.sentinel)
        with self.assertRaises(u.UpdateError):
            self.apply()
        self.assertEqual(self.sentinel.read_bytes(), b"human-owned sentinel\n")

    def test_corrupt_existing_unreferenced_generation_is_never_overwritten(self):
        self.apply()
        old_generation = self.generation()
        self.apply(REV2)
        (old_generation / "profile.json").write_bytes(b"corrupt historical profile")
        before = (self.root / "snapshot.json").read_bytes()
        with self.assertRaises(u.UpdateError):
            self.apply(REV)
        self.assertEqual((old_generation / "profile.json").read_bytes(), b"corrupt historical profile")
        self.assertEqual((self.root / "snapshot.json").read_bytes(), before)
        u.verify(self.root)

    def test_checkout_root_resolves_only_module_and_live_root_is_refused(self):
        checkout = self.root / "checkout"
        module = checkout / "modules/home/programs/desktop/editors/zed"
        module.mkdir(parents=True)
        (module / "adoption.json").write_bytes(encoded(self.policy))
        report = u.refresh(checkout, REV, downloader=self.download)
        u.refresh(checkout, REV, downloader=self.download, apply=True, reviewed_report_sha256=report["report_sha256"])
        self.assertTrue((module / "snapshot.json").is_file())
        self.assertFalse((checkout / "snapshot.json").exists())
        self.assertEqual(u.verify(checkout), u.verify(module))
        config = self.root / "config"
        live = config / "zed"
        live.mkdir(parents=True)
        (live / "adoption.json").write_bytes(encoded(self.policy))
        with patch.dict(os.environ, {"XDG_CONFIG_HOME": str(config)}), self.assertRaisesRegex(u.UpdateError, "live Zed"):
            u.refresh(live, REV, downloader=self.download)
        self.assertEqual([p.name for p in live.iterdir()], ["adoption.json"])

    def test_offline_verify_uses_archived_policy_not_pending_owned_policy(self):
        self.apply()
        original = u.verify(self.root)
        (self.root / "adoption.json").write_bytes(b"pending human edit")
        self.assertEqual(u.verify(self.root), original)
        with self.assertRaises(u.UpdateError):
            self.report(REV2)

    def test_normalized_output_is_strict_deterministic_and_preserves_arrays(self):
        self.raw["settings.json"] = b'{// comment\n editor:{tab_size:2}, list:[3,1,2,],}'
        self.apply()
        normalized = self.generation() / "normalized/settings.json"
        self.assertEqual(normalized.read_bytes(), encoded({"editor": {"tab_size": 2}, "list": [3, 1, 2]}))
        self.assertEqual((self.generation() / "normalized/tasks.json").read_bytes(), encoded([
            {"label": "never execute", "command": "touch forbidden"}
        ]))
        self.assertEqual((self.generation() / "raw/settings.json").read_bytes(), self.raw["settings.json"])
        self.assertEqual(list(self.root.rglob("__pycache__")), [])

    def test_bootstrap_identity_does_not_depend_on_root_or_timestamps(self):
        before = self.report()
        other = self.root / "independent"
        other.mkdir()
        (other / "adoption.json").write_bytes(encoded(self.policy))
        after = u.refresh(other, REV, downloader=self.download)
        self.assertEqual(before, after)

    def test_downloader_uses_only_pinned_https_source_and_bounds(self):
        response = MagicMock()
        response.__enter__.return_value = response
        response.status = 200
        response.read.return_value = b"fixture license"
        opener = MagicMock()
        opener.open.return_value = response
        with patch.object(u.urllib.request, "build_opener", return_value=opener), \
                patch.object(u.ssl, "create_default_context") as context, \
                patch.dict(os.environ, {"SSL_CERT_FILE": "/test-only-pinned-ca.pem"}):
            self.assertEqual(u.download(REV, "LICENSE"), b"fixture license")
            context.assert_called_once_with(cafile="/test-only-pinned-ca.pem")
            opener.open.assert_called_once_with(
                f"https://raw.githubusercontent.com/jellydn/zed-101-setup/{REV}/LICENSE", timeout=30
            )
            response.read.assert_called_once_with(u.MAX_BYTES + 1)
            response.read.return_value = b"x" * (u.MAX_BYTES + 1)
            with self.assertRaises(u.UpdateError):
                u.download(REV, "LICENSE")
            with self.assertRaises(u.UpdateError):
                u.download(REV, "../untrusted")
        with self.assertRaisesRegex(u.UpdateError, "redirect"):
            u.NoRedirect().redirect_request(None, None, 302, "redirect", {}, "http://untrusted")

    def test_malformed_license_does_not_change_active_pointer(self):
        self.apply()
        before = (self.root / "snapshot.json").read_bytes()
        for raw in [b"", b"\xff"]:
            self.raw["LICENSE"] = raw
            with self.subTest(raw=raw), self.assertRaises(u.UpdateError):
                self.report(REV2)
        self.assertEqual((self.root / "snapshot.json").read_bytes(), before)

    def test_cli_offline_verify_and_required_root(self):
        self.apply()
        command = [os.environ["ZED_UPDATER_BIN"], "verify", "--root", str(self.root)]
        result = subprocess.run(command, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)["generation"], self.generation().name)
        result = subprocess.run([os.environ["ZED_UPDATER_BIN"], "verify"], capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)


class RepositorySnapshotTests(unittest.TestCase):
    def test_active_snapshot_rebuilds_offline_from_stored_bytes(self):
        root = Path(os.environ["ZED_SNAPSHOT_ROOT"])
        with patch.object(socket, "create_connection", side_effect=AssertionError("network forbidden")), \
                patch.object(u, "download", side_effect=AssertionError("download forbidden")):
            active = verify_repository_snapshot(root)
            generation = root / "snapshots" / active["generation"]
            with tempfile.TemporaryDirectory(prefix="zed-rebuild-", dir=os.environ["TMPDIR"]) as temporary:
                independent = Path(temporary)
                (independent / "adoption.json").write_bytes((generation / "adoption.json").read_bytes())
                report = u.refresh(independent, active["generation"][:40],
                                   downloader=lambda revision, name: (generation / "raw" / name).read_bytes())
                self.assertEqual(report["report"]["candidate"]["generation"], active["generation"])
                self.assertEqual(report["report"]["candidate"]["hashes"]["manifest.json"], active["manifest_sha256"])
                self.assertEqual(report["report"]["effective_profile"]["after"], active["profile"])
                self.assertFalse((independent / "snapshot.json").exists())
        self.assertEqual(set(active["profile"]), {"schema", "target_version", "settings", "keymap"})


if __name__ == "__main__":
    unittest.main(verbosity=2)
