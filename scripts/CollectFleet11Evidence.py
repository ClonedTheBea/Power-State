"""Collect bounded fake-Test output and unchanged-contract source evidence."""
import hashlib
import json
import os
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[1]
out = root / "docs/evidence/national-fleet-expansion-v11"
out.mkdir(parents=True, exist_ok=True)
logs = Path(os.environ["LOCALAPPDATA"]) / "Roblox/logs"
source = logs / "0.748.0.7481526_20261121T094807Z_Studio_C174D_last.log"
lines = [x for x in source.read_text(encoding="utf-8", errors="replace").splitlines()
         if "FLog::CreatorOutput" in x or "FLog::CreatorError" in x]
(out / "studio-output.txt").write_text("\n".join(lines) + "\n", encoding="utf-8")
records = []
for line in lines:
    if " > " in line:
        continue
    for marker in ("FLEET11_PHASE ", "FLEET11_PRICE ", "FLEET11_SIZE_BREAKDOWN ",
                   "FLEET11_STORAGE_STUDY ", "OWNED_FLEET_PERFORMANCE "):
        if marker in line and "{" in line:
            prefix, payload = line.split("{", 1)
            try:
                records.append({"timestamp": line[:24], "label": prefix.split(marker)[-1].strip(),
                                "kind": marker.strip(), "data": json.loads("{" + payload)})
            except json.JSONDecodeError:
                pass  # Full raw output retained; do not fabricate truncated records.
            break
(out / "measurements.json").write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
paths = ["src/server/Domain/" + n + ".luau" for n in (
    "ProfileSchema", "ProfileSchema2", "ProfileSchema3", "ProfileSchema4", "ProfileMigrations4",
    "ProfileLease", "ProfileLease2", "ProfileLease3", "ProfileLease4", "WindProject", "ConstructionProject",
    "FleetEconomy", "CountryFleetSeed", "CountryFleetNetwork")]
paths += ["src/server/Operations/" + n + ".luau" for n in ("FleetSolver", "FleetJobScheduler", "OperationsWind")]
paths += ["src/server/World/" + n + ".luau" for n in ("WorldGenerator", "DemandModel", "ClimateModel")]
audit = []
for name in paths:
    data = (root / name).read_bytes()
    old = subprocess.check_output(["git", "show", "HEAD:" + name], cwd=root)
    assert data.replace(b"\r\n", b"\n") == old.replace(b"\r\n", b"\n"), name
    audit.append({"file": name, "unchangedFromAcceptedHead": True, "sha256": hashlib.sha256(data).hexdigest()})
production = (root / "default.project.json").read_text(encoding="utf-8")
assert "RunFleet11" not in production and "NationalFleetProof" not in production
(out / "source-audit.json").write_text(json.dumps(audit, indent=2) + "\n", encoding="utf-8")
print(f"PASS: {len(audit)} unchanged contracts; {len(records)} complete measurement records; raw output retained")
