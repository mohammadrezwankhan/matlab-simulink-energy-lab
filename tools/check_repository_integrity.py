#!/usr/bin/env python3
"""Read-only, stdlib-only structural checks; NOT MATLAB or physical validation.

Run from any directory: python3 tools/check_repository_integrity.py
Errors exit nonzero. A PASS here does not imply MATLAB tests or safety passed.
"""
from __future__ import annotations

import csv
import json
import math
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHA_PIN = re.compile(r"^[^@\s]+@[0-9a-f]{40}$")
REQ_ID = re.compile(r"BESS-[A-Z]+-\d{3}")


def parse_catalog(source: str) -> tuple[list[str], list[bool]]:
    """Parse the explicit base catalog and Simulink flags, plus BESS entry."""
    try:
        entries_text = source.split("checks = [", 1)[1].split("];", 1)[0]
        flags_text = source.split("requiresSimulink = logical([", 1)[1].split("]);", 1)[0]
    except IndexError as exc:
        raise ValueError("Catalog layout changed: update the independent parser") from exc
    entries = re.findall(r'"([^"\n]+\.m)"', entries_text)
    flags = [item == "1" for item in re.findall(r"\b[01]\b", flags_text)]
    if not entries or len(entries) != len(flags) or len(set(entries)) != len(entries):
        raise ValueError("Base catalog is empty, duplicated, or out of sync with flags")
    extra = re.findall(
        r'checks\(end \+ 1\)\s*=\s*\.\.\.\s*"([^"\n]+\.m)"', source
    )
    if len(extra) != 1 or "requiresSimulink(end + 1) = true;" not in source:
        raise ValueError("Expected exactly one Simulink-only focused BESS entry")
    if extra[0] in entries:
        raise ValueError("Focused BESS entry is duplicated")
    return entries + extra, flags + [True]


def inspect_numeric_csv(text: str, filename: str) -> int:
    """Validate finite numeric fixture cells and any declared time/SOC axis."""
    rows = list(csv.reader(text.splitlines()))
    if len(rows) < 2 or not rows[0]:
        raise ValueError(f"{filename}: missing CSV header or data rows")
    header = rows[0]
    if len(set(header)) != len(header) or any(not item for item in header):
        raise ValueError(f"{filename}: duplicate or empty headers")
    values: list[list[float]] = []
    for index, row in enumerate(rows[1:], start=2):
        if len(row) != len(header) or any(not cell.strip() for cell in row):
            raise ValueError(f"{filename}:{index}: missing value or inconsistent width")
        try:
            parsed = [float(cell) for cell in row]
        except ValueError as exc:
            raise ValueError(f"{filename}:{index}: nonnumeric value") from exc
        if not all(math.isfinite(cell) for cell in parsed):
            raise ValueError(f"{filename}:{index}: nonfinite value")
        values.append(parsed)
    if "time_s" in header:
        axis = [row[header.index("time_s")] for row in values]
        if any(right <= left for left, right in zip(axis, axis[1:])):
            raise ValueError(f"{filename}: time_s must be strictly increasing")
    if "soc" in header:
        axis = [row[header.index("soc")] for row in values]
        if any(v < 0 or v > 1 for v in axis):
            raise ValueError(f"{filename}: SOC must remain in [0, 1]")
        if any(right < left for left, right in zip(axis, axis[1:])):
            raise ValueError(f"{filename}: SOC reference must be nondecreasing")
    return len(values)


def cff_field(text: str, name: str) -> str:
    match = re.search(r"(?m)^" + re.escape(name) + r':\s*"?([^"\n]+)"?\s*$', text)
    if not match:
        raise ValueError(f"CITATION.cff missing {name}")
    return match.group(1)


def validate_repository(root: Path) -> dict[str, int]:
    """Raise for a verifiable structural defect; never claim native test success."""
    stats: dict[str, int] = {}

    meta = json.loads((root / "codemeta.json").read_text(encoding="utf-8"))
    cff = (root / "CITATION.cff").read_text(encoding="utf-8")
    meta_yml = (root / "project-metadata.yml").read_text(encoding="utf-8")
    yml_version = re.search(r'(?m)^version:\s*"([^"]+)"\s*$', meta_yml)
    if not yml_version or len({meta["version"], cff_field(cff, "version"), yml_version.group(1)}) != 1:
        raise ValueError("CFF, CodeMeta, and project-metadata versions disagree")
    if meta.get("datePublished") != cff_field(cff, "date-released"):
        raise ValueError("CFF and CodeMeta publication dates disagree")
    if meta.get("codeRepository") != cff_field(cff, "repository-code"):
        raise ValueError("CFF and CodeMeta repository URLs disagree")
    stats["metadata_contracts"] = 3

    json_files = sorted(root.rglob("*.json"))
    for source in json_files:
        if any(part in {".git", "validation-artifacts", ".buildtool", "slprj"} for part in source.parts):
            continue
        json.loads(source.read_text(encoding="utf-8"))
    stats["json_parsed"] = len(json_files)

    catalog_source = (root / "examples/validation_check_catalog.m").read_text(encoding="utf-8")
    catalog, flags = parse_catalog(catalog_source)
    discovered = {
        source.relative_to(root / "examples").as_posix()
        for source in (root / "examples").rglob("check_*.m")
    }
    # Manifest contract is invoked separately by the catalog runner.
    discovered.discard("validation-manifest/check_validation_manifest.m")
    if set(catalog) != discovered:
        raise ValueError(f"Catalog mismatch: missing={sorted(discovered-set(catalog))}, "
                         f"stale={sorted(set(catalog)-discovered)}")
    if sum(flags) != 6 or len(catalog) != len(flags):
        raise ValueError("Simulink flags or six model/scenario checks drifted")
    stats["catalog_entries"] = len(catalog)

    req_dir = root / "examples/bess-unified-control/requirements"
    reqs = set(REQ_ID.findall((req_dir / "requirements.md").read_text(encoding="utf-8")))
    with (req_dir / "traceability.csv").open(encoding="utf-8", newline="") as stream:
        records = list(csv.DictReader(stream))
    ids = [row["requirement_id"] for row in records]
    if not ids or len(set(ids)) != len(ids) or set(ids) != reqs:
        raise ValueError("Requirement definitions and traceability rows disagree")
    with (req_dir / "source-ledger.csv").open(encoding="utf-8", newline="") as stream:
        known_sources = {row["source_id"] for row in csv.DictReader(stream)}
    known_assumptions = set(re.findall(
        r"ASM-\d{3}", (req_dir / "assumptions.md").read_text(encoding="utf-8")
    ))
    for row in records:
        if row["status"] not in {"PASS", "FAIL", "WARNING", "NOT_RUN", "BLOCKED", "INCONCLUSIVE"}:
            raise ValueError(f"Invalid declared status for {row['requirement_id']}")
        if row["classification"] not in {"DIRECT_SOURCE", "DERIVED", "PROJECT_ASSUMPTION"}:
            raise ValueError(f"Invalid provenance for {row['requirement_id']}")
        if not row["implementation"].strip() or not row["test"].strip():
            raise ValueError(f"Missing mapped implementation/test for {row['requirement_id']}")
        unknown = set(row["source_ids"].split(";")) - known_sources - known_assumptions
        if unknown:
            raise ValueError(f"Unknown source identifiers for {row['requirement_id']}: {unknown}")
    stats["traceability_rows"] = len(records)

    total_rows = 0
    fixtures = sorted((root / "examples").glob("*/data/**/*.csv"))
    for source in fixtures:
        total_rows += inspect_numeric_csv(
            source.read_text(encoding="utf-8"), source.relative_to(root).as_posix()
        )
    if not fixtures:
        raise ValueError("Numeric test fixtures missing")
    stats["numeric_fixtures"] = len(fixtures)
    stats["numeric_fixture_rows"] = total_rows

    workflows = sorted((root / ".github/workflows").glob("*.yml"))
    if not workflows:
        raise ValueError("GitHub Actions workflows missing")
    pinned = 0
    for source in workflows:
        content = source.read_text(encoding="utf-8")
        uses = re.findall(r"(?m)^\s*-?\s*uses:\s*([^\s#]+)", content)
        for action in uses:
            if not SHA_PIN.fullmatch(action):
                raise ValueError(f"Unpinned action in {source.name}: {action}")
            pinned += 1
        if not re.search(r"(?m)^permissions:\s*\n\s+contents:\s+read\s*$", content):
            raise ValueError(f"Missing least-privilege workflow default: {source.name}")
    stats["workflow_files"] = len(workflows)
    stats["pinned_action_references"] = pinned
    return stats


def main() -> int:
    try:
        stats = validate_repository(ROOT)
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as exc:
        print(f"FAIL: repository structural integrity: {exc}", file=sys.stderr)
        return 1
    print("PASS: read-only structural integrity; NOT a MATLAB simulation or safety sign-off")
    for key, value in stats.items():
        print(f"  {key}: {value}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
