"""Off-grid and near-lattice probes complement the regular 2D climate sweep."""
import sys
sys.dont_write_bytecode = True
from ValidateP2bClimate import climate
from pathlib import Path
import hashlib
import json
import math

seeds = [bytes.fromhex(s) for s in (
    "df307a52185f423288df5749229f0808", "dfff043298824c4da9e3e4e45da85bc6",
    "00000000000040008000000000000000", "ffffffffffff4fffbfffffffffffffff")]
seeds += [hashlib.sha256(f"PS-P2b-offset:{i}".encode()).digest()[:16] for i in range(128)]
result = {"kind": "Independent Python reference; integer positions offset from the regular 64-unit grid",
          "seeds": len(seeds), "outerRadius": 4608, "pairs": 0, "passed": False,
          "maxTemperaturePer64C": 0, "maxRainfallPer64Mm": 0, "failure": None,
          "sampling": "32 angular spokes; radii 1984..4672 step64; paired jitter -1/31/63; X/Y and both diagonals"}
path = Path(__file__).resolve().parents[1] / "docs/P2B-CLIMATE-OFFSETS-GATE.json"
for seed in seeds:
    for angle in range(32):
        for radius in range(1984, 4673, 64):
            for jitter in (-1, 31, 63):
                x = 512 + round(math.cos(angle * math.tau / 32) * radius) + jitter
                y = 512 + round(math.sin(angle * math.tau / 32) * radius) - jitter
                a = climate(seed, x, y)
                for dx, dy in ((64, 0), (0, 64), (64, 64), (-64, 64)):
                    b = climate(seed, x + dx, y + dy)
                    dt = abs(a["temperatureCentiC"] - b["temperatureCentiC"])
                    dr = abs(a["rainfallMm"] - b["rainfallMm"])
                    d2 = dx * dx + dy * dy
                    result["pairs"] += 1
                    result["maxTemperaturePer64C"] = max(result["maxTemperaturePer64C"], dt / 100 * 64 / math.sqrt(d2))
                    result["maxRainfallPer64Mm"] = max(result["maxRainfallPer64Mm"], dr * 64 / math.sqrt(d2))
                    if dt * dt * 4096 > 200 * 200 * d2 or dr * dr * 4096 > 150 * 150 * d2:
                        result["failure"] = {"seed": seed.hex(), "a": a, "b": b}
                        path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf8")
                        print(json.dumps(result));raise SystemExit(1)
result["passed"] = True
path.write_text(json.dumps(result, indent=2) + "\n", encoding="utf8")
print(json.dumps(result, indent=2))
