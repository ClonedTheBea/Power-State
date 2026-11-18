"""Static preparation/isolation checks. No Roblox service access."""
from pathlib import Path
import json

root = Path(__file__).resolve().parents[1]
def source(path):
    return (root/path).read_text(encoding='utf-8')
a = source('src/server/Adapters/Schema3ConstructionAdapter.luau')
p = source('src/server/Domain/ConstructionProofPlan.luau')
r = source('src/server/Services/ConstructionProofRunner.luau')
s = source('src/server/Services/ProfileService.luau')
checks = []
def check(label, value):
    assert value, label
    checks.append(label)

for token in ['local REAL_CONSTRUCTION_PROOF_APPROVED=false', 'not run:IsRunning()',
              'game.GameId==10776833313', 'game.CreatorId==149564436', 'Enum.CreatorType.User',
              'GetUserId()==149564436', 'GetDataStore("PowerStateProfilesP3aTest")',
              'options.UseCache=false', 'C.encode(initial,scalar)==reviewedCanonical',
              'return nextValue,info:GetUserIds(),info:GetMetadata()', 'assert(#records<65',
              'assert(not attempted', 'd846d13a398113d1442ff1e0a3feeccbf2397fdf286cad88583f635524c75a65']:
    check(token, token in a)
check('Gate precedes all service access', a.index('assert(REAL_CONSTRUCTION_PROOF_APPROVED') < a.index('GetService('))
check('Stage B denied before service access', a.index('assert(phase=="Fund"') < a.index('GetService('))
check('Preimage retention precedes update', a.index('assert(preimageRetained') < a.index('store:UpdateAsync'))
check('Bounded platform audit capture', 'initialPlatform=C.copy(initialPlatform)' in a and 'latestPlatform=C.copy(latestPlatform)' in a)
check('Request budgets recorded', 'readBudget=service:GetRequestBudgetForRequestType' in a and 'writeBudget=service:GetRequestBudgetForRequestType' in a)
for token in ['MAX_INTERVALS=128', 'KEY="u:149564436"', 'COUNTRY_ID="55e35a88-e3b9-4f72-9e69-d9024e7730a4"',
              'calls<64', 'reads<24', 'writes<40', 'No post-build simulation authority',
              'Only reviewed acquisition', 'Release only confirmed country', 'Only exact reviewed purchase']:
    check(token, token in p)
for token in ['then 240 else 90', 'deps.mono()-start<30', 'deps.wait(1)', 'i%30==0',
              'state.bank.balanceMinor>=125000', 'not e.critical', 'quoteState=="Built" and state.step==before',
              'Uncached financial/build confirmation required', 'Uncached release confirmation required']:
    check(token, token in r)
check('Runner has no service access or heartbeat connection', 'GetService(' not in r and ':Connect(' not in r)
check('Coordinator uses private capability', 'Schema3ConstructionAdapter' in s and 'isApproved' in s)
for file in [root/'src/server/Bootstrap.server.luau', *list((root/'src/client').rglob('*.luau')), root/'tests/Run.server.luau']:
    check('No automatic execution: '+str(file.relative_to(root)), 'ConstructionProofExecution' not in file.read_text() and 'Schema3ConstructionAdapter' not in file.read_text())
check('Prior real economy gate closed', 'local REAL_ECONOMY_EXECUTION_APPROVED=false' in source('src/server/Adapters/Schema2GameplayAdapter.luau'))
check('Legacy P3a real gate closed', 'local LIVE_ACCESS_APPROVED=false' in source('src/server/Adapters/DataStoreAdapter.luau'))
check('Bounded prior economy gate closed', 'local BOUNDED_P3B5_EXECUTION_APPROVED=false' in source('src/server/Adapters/Schema2GameplayAdapter.luau'))
check('Prior migration gate closed', 'local EXECUTION_APPROVED=false' in source('src/server/Adapters/Schema3MigrationAdapter.luau'))
check('Original schema validation retained', (root/'tests/unit/P3a.spec.luau').exists())
check('New fake integration coverage retained', 'Historical capture untouched' in source('tests/unit/P3c3.spec.luau'))
print(json.dumps({'passed': len(checks), 'scope': 'local static isolation only'}, indent=2))
