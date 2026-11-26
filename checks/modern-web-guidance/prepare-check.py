"""Exercise package preparation against telemetry drift in the pinned npm input."""

from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest


PREPARE, SOURCE, VERSION = sys.argv[1:]
CLI = Path("skills/modern-web-guidance/modern-web.mjs")
SITE = '      await getLogger().logSearchResult("", 0, false, []);\n'
STARTUP = "ensureNodeVersion();\n"


class PrepareCheck(unittest.TestCase):
    def test_rejects_telemetry_drift(self):
        for case, original, replacement in (
            ("missing call", SITE, ""),
            ("extra call", SITE, SITE * 2),
            ("reformatted call", SITE, SITE.replace("getLogger().", "getLogger() .")),
            ("startup call outside main", STARTUP,
             STARTUP + 'await new ClearcutLogger({ skillVersion: null }).logSearchResult("", 0, false, []);\n'),
        ):
            with self.subTest(case=case), tempfile.TemporaryDirectory(prefix="mwg prepare ") as tmp:
                root = Path(tmp)
                source = root / "source"
                shutil.copytree(SOURCE, source)
                cli = source / CLI
                text = cli.read_text(encoding="utf-8")
                self.assertEqual(text.count(original), 1, "fixture needs the pinned CLI text")
                cli.write_text(text.replace(original, replacement), encoding="utf-8")
                out = root / "out"
                result = subprocess.run(
                    [sys.executable, PREPARE, str(out), VERSION], cwd=source,
                    text=True, capture_output=True, timeout=30,
                )
                self.assertEqual((result.returncode, result.stdout), (1, ""), result)
                self.assertEqual(
                    result.stderr.splitlines()[-1],
                    "ValueError: Pinned upstream CLI changed; review the entire CLI before updating its digest",
                )
                self.assertFalse(out.exists(), "drift must not produce a partial install")


if __name__ == "__main__":
    unittest.main(argv=[sys.argv[0]])
