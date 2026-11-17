"""Build/authority/preservation checks; engine tests are separate."""
from pathlib import Path
import subprocess,xml.etree.ElementTree as ET,json
root=Path(__file__).resolve().parents[1]
checks=[]
def check(label,value):
 assert value,label
 checks.append(label)
for variant in ['PowerState','PowerStateTests']:
 tree=ET.parse(root/'.build'/f'{variant}.rbxlx')
 for name in ['NetworkModel','GridSolver','Country','IntentHandler','SimulationService']:
  items=[item for item in tree.findall('.//Item') if item.findtext('Properties/string[@name="Name"]')==name]
  check(variant+' has '+name,len(items)==1)
  server=tree.find('.//Item[@class="ServerScriptService"]')
  check(variant+' keeps '+name+' server-only',any(item is items[0] for item in server.iter()))
 check(variant+' no saved remotes',not tree.findall('.//Item[@class="RemoteEvent"]'))
 check(variant+' keeps test sender isolated',('P2aRemote.spec' in (root/'.build'/f'{variant}.rbxlx').read_text())==(variant=='PowerStateTests'))
for path in ['src/server/Bootstrap.server.luau','src/client/Bootstrap.client.luau','src/server/Simulation/SimulationService.luau','src/client/Simulation/SimulationClient.luau']:
 text=(root/path).read_text()
 check(path+' isolated Test guard','IsStudio()' in text and '10776833313' in text)
for path in ['src/client/PreviewData.luau','src/client/Views/Map/MapFixture.luau','src/client/Views/Map/SpriteManifest.luau','assets/r32-proof-v3/power-state-map-proof-v3.png','assets/r37-settlements-v1/power-state-settlements-proof-v1.png']:
 before=subprocess.check_output(['git','show','HEAD:'+path],cwd=root);after=(root/path).read_bytes()
 if path.endswith('.luau'): before=before.replace(b'\r\n',b'\n');after=after.replace(b'\r\n',b'\n')
 check(path+' unchanged',before==after)
check('No persistent APIs',not any('GetDataStore(' in p.read_text(encoding='utf-8') for p in (root/'src').rglob('*.luau')))
print(json.dumps({'passed':len(checks),'checks':checks,'scope':'local static and built mappings only'}))
