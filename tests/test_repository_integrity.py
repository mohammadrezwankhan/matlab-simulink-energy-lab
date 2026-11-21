"""Regression tests for the read-only engineering integrity checker."""
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from check_repository_integrity import inspect_numeric_csv, parse_catalog


class IntegrityContractsTest(unittest.TestCase):
    def test_catalog_has_explicit_simulink_flags_and_focused_entry(self):
        text = ('checks = [\n"a/check_one.m"\n];\n'
                'requiresSimulink = logical([1]);\n'
                'checks(end + 1) = ...\n"b/check_two.m";\n'
                'requiresSimulink(end + 1) = true;\n')
        paths, flags = parse_catalog(text)
        self.assertEqual(paths, ["a/check_one.m", "b/check_two.m"])
        self.assertEqual(flags, [True, True])

    def test_catalog_rejects_flag_drift(self):
        text = ('checks = [\n"a/check_one.m";\n"b/check_two.m"\n];\n'
                'requiresSimulink = logical([1]);\n'
                'checks(end + 1) = ...\n"c/check_three.m";\n'
                'requiresSimulink(end + 1) = true;\n')
        with self.assertRaises(ValueError):
            parse_catalog(text)

    def test_numeric_fixtures_are_finite_and_monotonic(self):
        self.assertEqual(inspect_numeric_csv("time_s,current_A\n0,1\n1,2\n", "test.csv"), 2)
        for payload in (
            "time_s,current_A\n0,1\n0,2\n",
            "time_s,current_A\n0,1\n1,NaN\n",
            "time_s,current_A\n0,1\n1,\n",
            "time_s,current_A\n0,1\n1,abc\n",
        ):
            with self.subTest(payload=payload):
                with self.assertRaises(ValueError):
                    inspect_numeric_csv(payload, "test.csv")

    def test_soc_reference_has_physical_bounds(self):
        self.assertEqual(inspect_numeric_csv("soc,voltage_V\n0,3.2\n0.5,3.6\n1,4\n", "soc.csv"), 3)
        for payload in ("soc,v\n0.5,3\n0.4,4\n", "soc,v\n0,3\n1.1,4\n"):
            with self.assertRaises(ValueError):
                inspect_numeric_csv(payload, "soc.csv")


if __name__ == "__main__":
    unittest.main()
