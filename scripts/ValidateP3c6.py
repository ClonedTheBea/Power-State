"""Preparation-only boundary checks; never accesses Roblox or private profile data."""
from pathlib import Path
import json

root = Path(__file__).resolve().parents[1]
suite = (root / 'tests/unit/P3c6.spec.luau').read_text(encoding='utf-8')
checks = []
def check(label, value):
    assert value, label
    checks.append(label)

for forbidden in ['DataStoreService', 'Schema3ConstructionAdapter', 'ConstructionProofExecution', 'Heartbeat', 'GetAsync', 'UpdateAsync']:
    check('No real path: ' + forbidden, forbidden not in suite)
for token in ['Fake.create', 'session(3)', 'session(2)', 'time+=86400', 'BeforeWrite', 'AfterWrite', 'CallbackReplay',
              'Stale/foreign owner rejected', 'Malformed profile rejected', 'Duplicate cursor rejected',
              'Original reliability history preserved', 'Independent integer billing oracle', 'No capital or infrastructure mutation']:
    check('Retained proof coverage: ' + token, token in suite)
for filename, tokens in {
    'DataStoreAdapter.luau': ['local LIVE_ACCESS_APPROVED=false'],
    'Schema2GameplayAdapter.luau': ['local REAL_ECONOMY_EXECUTION_APPROVED=false', 'local BOUNDED_P3B5_EXECUTION_APPROVED=false'],
    'Schema3MigrationAdapter.luau': ['local EXECUTION_APPROVED=false'],
    'Schema3ConstructionAdapter.luau': ['local REAL_CONSTRUCTION_PROOF_APPROVED=false', 'local REAL_BUILD_PROOF_APPROVED=false'],
}.items():
    source = (root / 'src/server/Adapters' / filename).read_text(encoding='utf-8')
    for token in tokens:
        check('Closed gate: ' + token, token in source)
forecast = json.loads((root / 'docs/P3C6-FORECAST.json').read_text(encoding='utf-8'))
check('Exactly five reference intervals', [r['startStep'] for r in forecast['rows']] == list(range(242, 247)))
check('Exact independent forecast', forecast['finalBankMinor'] == 26328 and forecast['totalKwMinutes'] == 21115)
print(json.dumps({'passed': len(checks), 'scope': 'local preparation/static only'}))

# Real implementation remains closed; only the exact manual PostBuild capability is recognized.
a = (root/'src/server/Adapters/PostBuildProofAdapter.luau').read_text()
check('PostBuild closed before service', 'local REAL_POSTBUILD_PROOF_APPROVED=false' in a and a.index('assert(REAL_POSTBUILD_PROOF_APPROVED') < a.index('GetService("DataStoreService")'))
for token in ['game.GameId==10776833313','GetUserId()==149564436','game.CreatorId==149564436','not run:IsRunning()', 'options.UseCache=false', 'Protected preimage retention required', 'Fresh complete platform mismatch']:
    check('PostBuild guard: '+token,token in a)
for p in list((root/'src').rglob('*Bootstrap*'))+list((root/'src/client').rglob('*.luau')):
    check('No automatic PostBuild: '+p.name, 'PostBuildProof' not in p.read_text(encoding='utf-8'))
print(json.dumps({'postBuildTotal':len(checks)}))
