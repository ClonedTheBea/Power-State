"""Local source/mapping contracts. Engine behavior is tested separately in Studio."""
from pathlib import Path
import json
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
checks = []


def check(label, condition):
    assert condition, label
    checks.append(label)


for variant in ("PowerState", "PowerStateTests"):
    tree = ET.parse(root / ".build" / f"{variant}.rbxlx")
    server = tree.find('.//Item[@class="ServerScriptService"]')
    for name in ("IntegerField", "ClimateModel", "StarterValidator", "WorldGenerator", "DemandModel", "GeneratedService", "GenerationScheduler"):
        items = [i for i in tree.findall('.//Item') if i.findtext('Properties/string[@name="Name"]') == name]
        check(f"{variant}: {name} server-only", len(items) == 1 and any(i is items[0] for i in server.iter()))
    check(f"{variant}: no saved remotes", not tree.findall('.//Item[@class="RemoteEvent"]'))
    names = [i.findtext('Properties/string[@name="Name"]') for i in tree.findall('.//Item')]
    check(f"{variant}: generated terrain present", "GeneratedTerrain" in names)
    check(f"{variant}: P2b suites isolated", ("P2bWorld.spec" in names) == (variant == "PowerStateTests"))
    for name in ("P2b1.spec", "P2b1Probe", "P2b1Multiplayer.spec", "P2b1Scheduler.spec"):
        check(f"{variant}: {name} test-only", (name in names) == (variant == "PowerStateTests"))

service = (root / "src/server/World/GeneratedService.luau").read_text(encoding="utf-8")
check("Generated service guards Test and Studio", "Run:IsStudio() and game.GameId==10776833313" in service)
check("Only existing strict intent authority used", "Handler.handle" in service)
check("No client-selected seed", 'payload.seed' not in service and 'GenerateGUID(false)' in service)
check("Bounded country list", "#order>=8" in service)
check("Fixed P2a fixture preserved", 'local network=generated or Model.starter()' in (root / "src/server/Simulation/Country.luau").read_text(encoding="utf-8"))
climate = (root / "src/server/World/ClimateModel.luau").read_text(encoding="utf-8")
check("Amended outer radius", "Climate.OUTER_RADIUS=4608" in climate)
check("Inner protected radius retained", "2048^2" in climate)
gate = json.loads((root / "docs/P2B-CLIMATE-2D-GATE.json").read_text(encoding="utf-8"))
check("Broader reference gate passed unchanged limits", gate["passed"] and gate["maxTemperaturePer64C"] <= 2 and gate["maxRainfallPer64Mm"] <= 150)
check("Reference includes diagonal and adversarial coverage", gate["diagonalPairs"] > 0 and len(gate["adversarialSeeds"]) >= 6)
check("No future persistence", not any("GetDataStore(" in p.read_text(encoding="utf-8") for p in (root / "src").rglob("*.luau")))
print(json.dumps({"passed": len(checks), "scope": "local source/mapping checks only", "checks": checks}, indent=2))
