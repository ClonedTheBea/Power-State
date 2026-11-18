"""Read-only source/build isolation checks; never calls Roblox or a DataStore."""
from pathlib import Path
import hashlib
import json
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
checks = []


def check(label, passed):
    assert passed, label
    checks.append(label)


for name, digest in json.loads((root / "docs/P3A-PRESERVED-SOURCE.json").read_text()).items():
    check(f"Preserved {name}", hashlib.sha256((root / name).read_bytes()).hexdigest() == digest)

adapter = (root / "src/server/Adapters/DataStoreAdapter.luau").read_text()
check("Legacy live access closed", "local LIVE_ACCESS_APPROVED=false" in adapter)
check("Exact authenticated account and key", all(x in adapter for x in ('player.UserId==149564436','key=="u:149564436"','game.CreatorId==149564436')))
check("Studio only", "run:IsStudio()" in adapter)
check("Preflight protects first atomic update", "Profile changed since preflight; stop" in adapter and "Unexpected existing country; stop" in adapter)
check("Approval guard precedes service access", adapter.index("assert(LIVE_ACCESS_APPROVED") < adapter.index('GetService("DataStoreService")'))
check("Test universe only", "game.GameId==10776833313" in adapter)
check("Approved store only", 'GetDataStore("PowerStateProfilesP3aTest")' in adapter)
check("Uncached reconciliation read", "options.UseCache=false" in adapter)
check("No destructive persistence methods", not any(x in adapter for x in (":SetAsync(", ":RemoveAsync(", ":IncrementAsync(")))
proof = (root / "src/server/Services/PersistentTestService.luau").read_text()
check("Default proof remains fake", "function Service.start()start(Fake.create())end" in proof)
check("Real proof requires explicit start", "function Service.startReal(player:Player,expectedCountryId:string?)" in proof)
check("Proof Studio/server/Test guard", all(x in proof for x in ("Run:IsStudio()", "Run:IsServer()", "10776833313")))
check("Proof not auto-started", "PersistentTestService" not in (root / "src/server/Bootstrap.server.luau").read_text())
for file in (root / "src").rglob("*.luau"):
    text = file.read_text(encoding="utf-8")
    if "GetDataStore(" in text:
        check("Only explicitly approved guarded adapters reference DataStore", file.relative_to(root).as_posix() in {"src/server/Adapters/DataStoreAdapter.luau", "src/server/Adapters/Schema2MigrationAdapter.luau", "src/server/Adapters/Schema3MigrationAdapter.luau", "src/server/Adapters/Schema3ConstructionAdapter.luau", "src/server/Adapters/Schema2GameplayAdapter.luau"})
        if file.name == "Schema2GameplayAdapter.luau":
            check("Economy adapter remains disabled before service access", "local REAL_ECONOMY_EXECUTION_APPROVED=false" in text and text.index("assert(REAL_ECONOMY_EXECUTION_APPROVED") < text.index('GetService("DataStoreService")'))
        if file.name in {"Schema2MigrationAdapter.luau", "Schema3MigrationAdapter.luau"}:
            check("Migration adapter exact stopped Test guard", all(v in text for v in ("not run:IsRunning()", "game.GameId==10776833313", "GetUserId()==149564436", "sha(package.preimage)==PREIMAGE_SHA")))

modules = {"ProfileCodec", "ProfileSchema", "ProfileCountry", "ProfileMigrations", "ProfileLease", "ProfileService", "PersistentTestService", "FakeDataStoreAdapter", "DataStoreAdapter"}
for variant in ("PowerState", "PowerStateTests"):
    tree = ET.parse(root / ".build" / f"{variant}.rbxlx")
    names = [item.findtext('Properties/string[@name="Name"]') for item in tree.findall('.//Item')]
    for module in modules:
        check(f"{variant} contains {module}", module in names)
    server = next(item for item in tree.findall('.//Item') if item.get("class") == "ServerScriptService")
    server_names = [item.findtext('Properties/string[@name="Name"]') for item in server.findall('.//Item')]
    check(f"{variant} persistence modules server-only", modules.issubset(server_names) and all(names.count(n) == 1 for n in modules))
    check(f"{variant} P3a suites isolated", names.count("P3a.spec") == (2 if variant == "PowerStateTests" else 0))
    check(f"{variant} no serialized remotes", not any(i.get("class") in ("RemoteEvent", "RemoteFunction") for i in tree.findall('.//Item')))
print(json.dumps({"passed": len(checks), "scope": "local static/build evidence only; real adapter requires explicit authenticated Test start", "checks": checks}, indent=2))
