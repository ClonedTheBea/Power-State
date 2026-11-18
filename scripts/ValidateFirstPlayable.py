"""Local integration isolation checks; no Roblox or service access."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
checks=[]
def check(value,label):
    assert value,label
    checks.append(label)
server=(root/'src/server/Bootstrap.server.luau').read_text(encoding='utf-8')
client=(root/'src/client/Bootstrap.client.luau').read_text(encoding='utf-8')
for s in [server,client]:
    check('IsStudio()' in s and '10776833313' in s,'Studio Test startup guard')
    check('RunRegressionTests' in s,'Explicit legacy regression mode')
check('ConstructionTestService).start()' in server,'Normal fake host')
check('ConstructionClient).mount(playerGui)' in client,'Normal integrated GUI')
config=json.loads((root/'test.project.json').read_text())
check(config['tree']['ReplicatedStorage']['$attributes']['RunRegressionTests'] is False,'Regression defaults off')
for f in ['tests/Run.server.luau','tests/integration/Run.client.luau']:
    check('GetAttribute("RunRegressionTests")~=true then return end' in (root/f).read_text(),'Opt-in runner '+f)
for f in ['src/server/Services/ConstructionTestService.luau','src/server/Services/ConstructionControls.luau','src/client/Simulation/ConstructionClient.luau','src/client/Simulation/PlayablePresentation.luau']:
    s=(root/f).read_text(encoding='utf-8')
    for forbidden in ['GetDataStore','DataStoreService','PostBuildProofAdapter','Schema3ConstructionAdapter']:
        check(forbidden not in s,'No real execution '+f+' '+forbidden)
    check('Â' not in s and 'â€' not in s,'UTF-8 text '+f)
s=(root/'src/server/Services/ConstructionControls.luau').read_text()
check('Codec.copy(state)' in s and 'Intent.handle' in s and 'Solver.solve' in s,'Atomic copied control and retained gates')
check('Economy.settle' not in s and 'Country.advance' not in s,'Control never bills')
s=(root/'src/client/Simulation/ConstructionClient.luau').read_text(encoding='utf-8')
check('Connected · saved in this Test server' in s,'Completed wording')
check('Unsubscribe' in s and 'Destroying:Once(cleanup)' in s,'Transport lifecycle cleanup')
print(json.dumps({'passed':len(checks),'checks':checks}))
