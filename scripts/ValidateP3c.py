"""Static boundaries only; engine and fake-storage tests supply behavioral evidence."""
from pathlib import Path
import hashlib
import json
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
checks = []


def check(condition, label):
    assert condition, label
    checks.append(label)


saved = json.loads((root / 'docs/P3C-PRESERVED-SOURCE.json').read_text(encoding='utf-8'))
for path, digest in saved.items():
    if path.startswith(('src/server/World/', 'src/server/Simulation/', 'assets/')) or path in [
        'src/server/Domain/Economy.luau', 'src/server/Domain/ProfileSchema.luau',
        'src/server/Domain/ProfileSchema2.luau', 'src/server/Domain/ProfileLease.luau',
        'src/server/Domain/ProfileLease2.luau', 'src/server/Adapters/Schema2GameplayAdapter.luau',
        'src/server/Bootstrap.server.luau', 'src/client/Bootstrap.client.luau',
    ]:
        check(hashlib.sha256((root / path).read_bytes()).hexdigest() == digest, 'Preserved ' + path)

modules = ['ConstructionProject', 'ConstructionCountry', 'ProfileSchema3', 'ProfileMigrations3',
           'ProfileLease3', 'DistrictSolver', 'ConstructionQuotes', 'ConstructionTestService']
for name in modules:
    candidates = list((root / 'src/server').rglob(name + '.luau'))
    check(len(candidates) == 1, 'Unique server module ' + name)
    source = candidates[0].read_text(encoding='utf-8')
    check('GetDataStore(' not in source and 'DataStoreService' not in source and 'startReal' not in source,
          'No real storage path ' + name)

service = (root / 'src/server/Services/ConstructionTestService.luau').read_text(encoding='utf-8')
check('Run:IsStudio() and Run:IsServer() and game.GameId==10776833313' in service, 'Test host runtime guard')
check('FakeDataStoreAdapter' in service and 'Schema2GameplayAdapter' not in service, 'Fixed fake adapter')
coordinator = (root / 'src/server/Services/ProfileService.luau').read_text(encoding='utf-8')
check('(deps.adapter.mode=="Fake" or approvedConstruction) and Schema==' in coordinator and 'Schema3ConstructionAdapter).isApproved(deps.adapter)' in coordinator and 'REAL_CONSTRUCTION_PROOF_APPROVED=false' in (root/'src/server/Adapters/Schema3ConstructionAdapter.luau').read_text(), 'Critical barrier accepts only fake or closed private construction capability')
check('or e.critical' in coordinator and 'if e.critical then' in coordinator, 'Mutation/release uncertainty barriers')
adapter = (root / 'src/server/Adapters/Schema2GameplayAdapter.luau').read_text(encoding='utf-8')
check('REAL_ECONOMY_EXECUTION_APPROVED=false' in adapter and 'BOUNDED_P3B5_EXECUTION_APPROVED=false' in adapter,
      'Real economy gates remain closed')
for file in ['PowerState.rbxlx', 'PowerStateTests.rbxlx']:
    tree = ET.parse(root / '.build' / file)
    items = tree.findall('.//Item')
    names = [i.findtext('Properties/string[@name="Name"]') for i in items]
    for name in modules:
        check(names.count(name) == 1, file + ' contains ' + name)
    for name in ['P3c.spec', 'P3cSafety.spec', 'P3cAccounting.spec', 'P3cWorld.spec', 'P3cRegression.spec']:
        expected = (2 if name == 'P3c.spec' else 1) if file == 'PowerStateTests.rbxlx' else 0
        check(names.count(name) == expected, file + ' test isolation ' + name)
    check(not any(i.attrib.get('class') in ('RemoteEvent', 'RemoteFunction') for i in items), file + ' no serialized remotes')
print(json.dumps({'passed': len(checks), 'scope': 'Static/build boundaries only; no services', 'checks': checks}, indent=2))
