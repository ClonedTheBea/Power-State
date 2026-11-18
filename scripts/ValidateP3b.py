"""Read-only local checks. Does not contact Roblox or enable economic storage."""
from pathlib import Path
import hashlib
import json
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
checks = []


def check(label, passed):
    assert passed, label
    checks.append(label)


baseline = json.loads((root / "docs/P3B-PRESERVED-SOURCE.json").read_text(encoding="utf-8"))
for path, digest in baseline.items():
    if path.startswith(("src/server/Simulation/", "src/server/World/", "assets/")) or path in {
        "src/server/Domain/ProfileSchema.luau", "src/server/Domain/ProfileLease.luau",
        "src/server/Domain/ProfileCountry.luau", "src/server/Domain/ProfileMigrations.luau",
    }:
        check("Preserved " + path, hashlib.sha256((root / path).read_bytes()).hexdigest() == digest)

adapter = (root / "src/server/Adapters/DataStoreAdapter.luau").read_text()
check("Real adapter validates v1 write candidates", "Schema.validate(updated,owner,scalar)" in adapter)
check("Existing exact real key retained", 'key=="u:149564436"' in adapter)
service = (root / "src/server/Services/ProfileService.luau").read_text()
check("Economic coordinator requires fake adapter", 'assert(not deps.schema or tostring(deps.adapter.mode)=="Fake"' in service)
proof = (root / "src/server/Services/PersistentTestService.luau").read_text()
check("Economic entry injects fake only", "function Service.startEconomy()start(Fake.create(),true)end" in proof)
check("Proof guards Studio Test", 'Run:IsStudio() and Run:IsServer() and game.GameId==10776833313' in proof)
check("Migration identity excluded from clients", "value.finance.economy.activationOperationId=nil" in proof)
for entry in ("src/server/Bootstrap.server.luau", "src/client/Bootstrap.client.luau"):
    check("No automatic economy " + entry, "P3b" not in (root / entry).read_text())
for name in ("PowerState", "PowerStateTests"):
    tree = ET.parse(root / f".build/{name}.rbxlx")
    modules = {node.findtext("Properties/string[@name='Name']") for node in tree.findall(".//Item[@class='ModuleScript']")}
    for module in ("Economy", "EconomicCountry", "ProfileSchema2", "ProfileLease2", "ProfileMigrations2", "BankPresentation"):
        check(name + " contains " + module, module in modules)
    check(name + " test suite isolation", ("P3b.spec" in modules) == (name == "PowerStateTests"))
    check(name + " no serialized remotes", not tree.findall(".//Item[@class='RemoteEvent']"))
print(json.dumps({"passed": len(checks), "scope": "source/build checks only; no services", "checks": checks}, indent=2))

for path in ["src/server/Bootstrap.server.luau","src/client/Bootstrap.client.luau"]:
    source=(root/path).read_text(encoding="utf-8")
    check("Integrated Test-only fake startup "+path, "IsStudio()" in source and "10776833313" in source and "RunRegressionTests" in source and ("ConstructionClient" in source or "ConstructionTestService" in source))
