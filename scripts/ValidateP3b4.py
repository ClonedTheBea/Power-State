"""P3b.4 preparation gates. Local source/build checks; no Roblox requests."""
from pathlib import Path
import json
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
checks = []
def check(label, passed):
    assert passed, label
    checks.append(label)
def read(path):
    return (root / path).read_text()
a = read('src/server/Adapters/Schema2GameplayAdapter.luau')
p = read('src/server/Domain/ExistingEconomyStore.luau')
l = read('src/server/Domain/ExistingEconomyLease.luau')
s = read('src/server/Services/ProfileService.luau')
t = read('src/server/Services/PersistentTestService.luau')
for token in ('local REAL_ECONOMY_EXECUTION_APPROVED=false', 'run:IsStudio() and run:IsServer()',
              'game.GameId==10776833313', 'game.CreatorId==149564436', 'game.CreatorType==Enum.CreatorType.User',
              'player.Parent==game:GetService("Players")', 'player.UserId==149564436',
              'GetDataStore("PowerStateProfilesP3aTest")', 'options.UseCache=false',
              'return nextValue,info:GetUserIds(),info:GetMetadata()', '#records==64', 'approved[adapter]=true'):
    check(token, token in a)
check('Disabled before service lookup', a.index('assert(REAL_ECONOMY_EXECUTION_APPROVED') < a.index('GetService("DataStoreService")'))
check('Authentication before access and after preflight', a.count('\n authenticate()') == 2 and a.index('\n authenticate()') < a.index('GetService("DataStoreService")') and a.rindex('\n authenticate()') > a.index('Policy.create('))
for token in ('KEY="u:149564436"', 'OWNER=149564436', 'COUNTRY_ID="55e35a88-e3b9-4f72-9e69-d9024e7730a4"',
              'Schema.validate(value,Policy.OWNER,scalar)', 'initial.lease.expiresAtUtcMs<=utcMs()',
              'encoded==baseline or encoded==firstResult', 'Codec.encode(value,scalar)==firstResult then first=false',
              'Economy.transition(value.country,updated.country,scalar)', 'updated.lastCommit.kind~="MigrateAcquire"'):
    check(token, token in p)
check('No migration or grant implementation', 'ProfileMigrations' not in p+l+a and 'Economy.open' not in p+l+a)
check('Existing lease validates before delegation', l.index('Schema.validate(current') < l.index('return Lease.apply'))
check('No arbitrary real schema injection', 'or approvedEconomy' in s and 'deps.lease==require(script.Parent.Parent.Domain.ExistingEconomyLease)' in s)
check('Existing restore avoids random initial candidate', 'profiles.prepared(handle,store.preflight.country)' in t)
check('Normal fake startup preserved', 'function Service.startEconomy()start(Fake.create(),true)end' in t)
for path in [root/'src/server/Bootstrap.server.luau', *list((root/'src/client').rglob('*.luau'))]:
    check('No real startup '+path.name, 'startRealEconomy' not in path.read_text() and 'Schema2GameplayAdapter' not in path.read_text())
for name in ('PowerState', 'PowerStateTests'):
    tree = ET.parse(root/'.build'/f'{name}.rbxlx')
    nodes = tree.findall('.//Item')
    names = [n.findtext('Properties/string[@name="Name"]') for n in nodes]
    server = next(n for n in nodes if n.get('class') == 'ServerScriptService')
    server_names = [n.findtext('Properties/string[@name="Name"]') for n in server.findall('.//Item')]
    for module in ('ExistingEconomyStore', 'ExistingEconomyLease', 'Schema2GameplayAdapter'):
        check(name+' server-only '+module, module in server_names and names.count(module)==1)
    check(name+' test isolation', names.count('P3b4.spec') == (1 if name=='PowerStateTests' else 0))
    check(name+' fixture isolation', names.count('P3b4Fixture') == (1 if name=='PowerStateTests' else 0))
print(json.dumps({'passed':len(checks), 'scope':'local disabled preparation only'}, indent=2))
