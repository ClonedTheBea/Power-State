"""Build isolation checks for the R3.5 Test-only experiment; not engine validation."""
from pathlib import Path
import json
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
checks = []
for variant in ("PowerState", "PowerStateTests"):
    place = ET.parse(root / ".build" / f"{variant}.rbxlx")
    names = [n.text for n in place.findall('.//Item/Properties/string[@name="Name"]')]
    for name in ("HybridPresentation", "R35.spec"):
        assert (name in names) == (variant == "PowerStateTests"), (variant, name)
        checks.append(f"{variant} isolates {name}")
result = {"passed": len(checks), "checks": checks, "scope": "Build isolation; engine evidence separate"}
(root / ".build/R35-local-validation.json").write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps(result))
