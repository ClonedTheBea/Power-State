"""Read-only local artifact/profile/build checks. Does not claim engine or upload access."""
from pathlib import Path
import hashlib,json,xml.etree.ElementTree as ET
from PIL import Image
root=Path(__file__).resolve().parents[1]
checks=[]
def check(name,ok):
    assert ok,name
    checks.append(name)
art=root/'assets/r37-settlements-v1'
manifest=json.loads((art/'manifest.json').read_text())
check('Settlement SHA-256',hashlib.sha256((art/manifest['atlasFile']).read_bytes()).hexdigest()=='baff92a631e89bbf9a1506f5401488e40fc2d5fe56a71399b1f410df5b05ff4e')
image=Image.open(art/manifest['atlasFile'])
check('RGBA dimensions',image.mode=='RGBA' and image.size==(512,256))
profiles=(root/'tests/integration/SettlementProfiles.luau').read_text()
for e in manifest['sprites']:
    line=next(l for l in profiles.splitlines() if 'id="'+e['artId']+'"' in l)
    for lua,key in [('rect','sourceRect'),('pivot','pivotPx'),('anchor','groundAnchorWorld'),('world','worldCanvasSize')]:
        values=','.join(str(v) for v in e[key])
        check(e['artId']+' '+key,(lua+'={'+values+'}' if lua=='rect' else lua+'=Vector2.new('+values+')') in line)
    check(e['artId']+' fallback',e['fallbackPatchId'] in line)
modules=['SettlementProfiles','SettlementAtlas','SettlementRenderer','SettlementProof','R37.spec']
for variant in ['PowerState','PowerStateTests']:
    p=root/'.build'/f'{variant}.rbxlx'
    names=[n.text for n in ET.parse(p).findall('.//Item/Properties/string[@name="Name"]')]
    for name in modules: check(variant+' isolates '+name,(name in names)==(variant=='PowerStateTests'))
    check(variant+' image ID isolation',('90608851718773' in p.read_text())==(variant=='PowerStateTests'))
renderer=(root/'tests/integration/SettlementRenderer.luau').read_text()
check('Six-slot construction', 'for i=1,6 do' in renderer and renderer.count('Instance.new(')==1)
check('Test universe guard','game.GameId==10776833313' in renderer)
check('No new gameplay remotes',all('FireServer' not in (root/'tests/integration'/f'{n}.luau').read_text() for n in modules))
result={'passed':len(checks),'checks':checks,'scope':'local static/build checks only'}
(root/'.build/R37-local-validation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
