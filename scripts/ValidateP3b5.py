"""Bounded P3b.5 source/build gates; never contacts Roblox."""
from pathlib import Path
import json
import xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[1]
def read(p): return (root/p).read_text(encoding='utf-8')
checks=[]
def check(label,condition):
    assert condition,label
    checks.append(label)
a=read('src/server/Adapters/Schema2GameplayAdapter.luau')
p=read('src/server/Domain/BoundedEconomyPlan.luau')
r=read('src/server/Services/BoundedEconomyRunner.luau')
entry=read('src/server/Services/BoundedEconomyProof.luau')
check('Ordinary real execution disabled','local REAL_ECONOMY_EXECUTION_APPROVED=false' in a and 'Ordinary real economy startup remains disabled' in a)
check('Bounded gate before service access',a.index('assert(BOUNDED_P3B5_EXECUTION_APPROVED')<a.index('GetService("DataStoreService")'))
for token in ['game.GameId==10776833313','game.CreatorId==149564436','player.UserId==149564436','options.UseCache=false','GetDataStore("PowerStateProfilesP3aTest")','return nextValue,info:GetUserIds(),info:GetMetadata()','sha==previousSHA','1441a4d819354af7b306ef8797931e15','Rowanbridge']:
    check(token,token in a)
for token in ['e.activationStep==113','100574','100766','113 else 117','117 else 118','Only next planned checkpoint','Release only confirmed final country','Replay changed record']:
    check(token,token in p)
for token in ['completed<plan.maxIntervals and state.step<118','state=nextState;completed+=1','entry.status=="Live"','EC.handle','svc.checkpoint(entry)','svc.close(entry)','equal(final,released)','No Heartbeat advancement']:
    check(token,token in r)
check('No heartbeat or remote driver',all(t not in r+entry for t in ['Heartbeat:Connect','OnServerEvent','FireServer','PersistentTestService']))
check('One attempt per session','assert(not attempted' in entry and 'attempted=true' in entry)
check('Running authenticated server required','run:IsServer() and run:IsRunning()' in entry and 'player.UserId==149564436' in entry)
check('No migration/grant',all(t not in p+r+entry for t in ['ProfileMigrations','Economy.open','MigrateAcquire']))
for file in [root/'src/server/Bootstrap.server.luau',*list((root/'src/client').rglob('*.luau'))]:
    check('No automatic caller '+file.name,all(t not in file.read_text(encoding='utf-8') for t in ['BoundedEconomyProof','createBounded']))
for name in ['PowerState','PowerStateTests']:
    tree=ET.parse(root/'.build'/f'{name}.rbxlx');nodes=tree.findall('.//Item')
    names=[n.findtext('Properties/string[@name="Name"]') for n in nodes]
    server=next(n for n in nodes if n.get('class')=='ServerScriptService')
    sn=[n.findtext('Properties/string[@name="Name"]') for n in server.findall('.//Item')]
    for module in ['BoundedEconomyPlan','BoundedEconomyRunner','BoundedEconomyProof']:
        check(name+' server-only '+module,module in sn and names.count(module)==1)
    check(name+' test isolation',names.count('P3b5.spec')==(1 if name=='PowerStateTests' else 0))
print(json.dumps({'passed':len(checks),'scope':'local bounded source/build validation only'},indent=2))
