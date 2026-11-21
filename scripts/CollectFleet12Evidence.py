"""Collect only this fake-Test sprint's actual outputs; never query Roblox services."""
import hashlib
import json
import os
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[1]
out = root / "docs/evidence/national-fleet-expansion-v12"
out.mkdir(parents=True, exist_ok=True)
log = Path(os.environ["LOCALAPPDATA"]) / "Roblox/logs/0.748.0.7481526_20261121T094807Z_Studio_C174D_last.log"
lines = [line for line in log.read_text(encoding="utf-8", errors="replace").splitlines()
         if line[:23] >= "2026-11-21T10:46:00.000" and
         ("FLog::CreatorOutput" in line or "FLog::CreatorError" in line)]
(out / "studio-output.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")
records = []
for line in lines:
    if " > " in line or "{" not in line:
        continue
    for marker in ("FLEET11_PHASE ", "FLEET12_PHASE ", "FLEET12_STORAGE_SIZE ",
                   "FLEET12_NORMAL_AFFORDABILITY ", "OWNED_FLEET_PERFORMANCE ",
                   "FLEET12_COMPACT_RECONNECT_PASS ", "[Owned fleet host soak] PASS "):
        if marker not in line:
            continue
        prefix, payload = line.split("{", 1)
        try:
            records.append({"timestamp": line[:24], "kind": marker.strip(),
                            "label": prefix.split(marker)[-1].strip(), "data": json.JSONDecoder().raw_decode("{" + payload)[0]})
        except json.JSONDecodeError:
            pass  # Engine-truncated output remains raw evidence, never guessed.
        break
(out / "measurements.json").write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
paths = ["src/server/Domain/" + n + ".luau" for n in (
    "ProfileSchema", "ProfileSchema2", "ProfileSchema3", "ProfileMigrations4",
    "ProfileLease", "ProfileLease2", "ProfileLease3", "ConstructionProject", "FleetEconomy",
    "CountryFleetSeed", "CountryFleetNetwork")]
paths += ["src/server/Operations/" + n + ".luau" for n in ("FleetSolver", "FleetJobScheduler", "OperationsWind")]
paths += ["src/server/World/" + n + ".luau" for n in ("WorldGenerator", "DemandModel", "ClimateModel")]
audit = []
for path in paths:
    data = (root / path).read_bytes()
    old = subprocess.check_output(["git", "show", "HEAD:" + path], cwd=root)
    assert data.replace(b"\r\n", b"\n") == old.replace(b"\r\n", b"\n"), path
    audit.append({"file": path, "sha256": hashlib.sha256(data).hexdigest(), "unchangedFromHead": True})
for path in ("default.project.json", "test.project.json"):
    source = (root / path).read_text(encoding="utf-8")
    assert "Fleet12Proof" not in source and "RunFleet12" not in source, "Opt-in flags cannot become repository defaults"
(out / "source-audit.json").write_text(json.dumps(audit, indent=2) + "\n", encoding="utf-8")
print(f"PASS: {len(audit)} pinned contracts unchanged; {len(records)} complete measurements; raw failures retained")
