"""Local isolation checks only: never contacts Roblox."""
from pathlib import Path
import hashlib, json
root = Path(__file__).resolve().parents[1]
a = (root/'src/server/Adapters/Schema3MigrationAdapter.luau').read_text()
r = (root/'src/server/Services/MigrationRunner3.luau').read_text()
g = (root/'src/server/Domain/ReviewedMigration3.luau').read_text()
checks = []
def check(label, value):
    assert value, label
    checks.append(label)
for label, token in {
    'Stopped Studio only': 'run:IsStudio() and not run:IsRunning()',
    'Exact Test universe': 'game.GameId==10776833313',
    'Personal creator': 'game.CreatorType==Enum.CreatorType.User and game.CreatorId==149564436',
    'Authenticated Studio account': 'GetUserId()==149564436',
    'Exact fixed key': 'local KEY="u:149564436"',
    'Exact store/default scope': 'GetDataStore("PowerStateProfilesP3aTest")',
    'Uncached reads': 'options.UseCache=false',
    'Reviewed full checksum': 'dcc3b32a12b48032f4d1f3ac2ea3536da68e7412ea3fbdba12c43a04dd504bd2',
    'Reviewed operation candidate checksum': '46bef9243589c03ef7c70338354e46912b079f2f40ff20326302d74b1b608faa',
    'Reviewed metadata checksum': 'f59087ec73c306143110f33f820ff9e34e03b9583ce2c4350bb209efd982016e',
    'Preserve user associations and metadata': 'return nextValue,info:GetUserIds(),info:GetMetadata()',
    'Exact migrated country only': 'Codec.encode(nextValue.country,scalar)==Codec.encode(candidate.country,scalar)',
    'Sequential invocation guard': 'assert(not attempted',
    'Request cap': 'assert(#records<9',
}.items(): check(label, token in a)
check('Identity/package checks precede DataStore service', a.index('sha(package.metadata)==METADATA_SHA') < a.index('GetService("DataStoreService")'))
check('No generic adapter update API', 'function Adapter.update' not in a and 'function Adapter.create' not in a)
check('Only migration and release writes', 'deps.update("MigrateAcquire"' in r and 'deps.update("Release"' in r and r.count('deps.update(')==2)
check('Ambiguous response requires read confirmation', 'verifyRead(guard.verifyAcquired' in r and 'verifyRead(guard.verifyReleased' in r)
check('Bounded reconciliation', 'for attempt=1,3 do' in r and '>=30' in r)
check('Full reviewed preimage comparison', 'Codec.encode(current,scalar)==encoded' in g)
check('No force release', 'now<current.lease.expiresAtUtcMs' in g)
check('Existing real adapter remains v1-only', 'local Schema=require(script.Parent.Parent.Domain.ProfileSchema)' in (root/'src/server/Adapters/DataStoreAdapter.luau').read_text())
check('Real economy execution remains disabled', 'Economic profiles are fake-storage only' in (root/'src/server/Services/ProfileService.luau').read_text() and 'local REAL_ECONOMY_EXECUTION_APPROVED=false' in (root/'src/server/Adapters/Schema2GameplayAdapter.luau').read_text())
for entry in [root/'src/server/Bootstrap.server.luau',root/'src/client/Bootstrap.client.luau',*list((root/'src/client').rglob('*.luau'))]:
    check('No migration caller '+str(entry.relative_to(root)), 'Schema3MigrationAdapter' not in entry.read_text() and 'MigrationRunner3' not in entry.read_text())
for f in [root/'src/server/Domain/ReviewedMigration3.luau',root/'src/server/Services/MigrationRunner3.luau']:
    check('Injected service boundary '+f.name, 'GetService(' not in f.read_text())
print(json.dumps({'passed':len(checks),'scope':'local static isolation only'},indent=2))
