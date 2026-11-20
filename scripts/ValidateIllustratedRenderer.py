from pathlib import Path
import json,hashlib,re,xml.etree.ElementTree as ET
root=Path('.')
checks=[]
def check(name,condition):
 assert condition,name
 checks.append(name)
manifest=json.loads((root/'assets/illustrated-world-v1-art-r1/manifest.json').read_text())
cat=(root/'tests/integration/IllustratedWorld/IllustratedAtlasCatalog.luau').read_text()
for atlas in manifest['atlases']:
 check(atlas['name']+' frozen PNG',hashlib.sha256((root/'assets/illustrated-world-v1-art-r1'/atlas['file']).read_bytes()).hexdigest()==atlas['sha256'])
for e in manifest['entries']:
 text=re.search(r'\["'+e['artId']+r'"\] = \{([^\n]+)',cat)[1]
 check(e['artId']+' exact rectangle','rect={'+','.join(map(str,e['sourceRect']))+'}' in text)
 check(e['artId']+' exact pivot','pivot={'+','.join(map(str,e['pivotPx']))+'}' in text)
 check(e['artId']+' atlas',f'atlas="{e["atlas"]}"' in text)
for name in ['PowerState','PowerStateTests']:
 tree=ET.parse(root/'.build'/f'{name}.rbxlx')
 names=[e.text for e in tree.findall('.//Item/Properties/string[@name="Name"]')]
 source='\n'.join(e.text or '' for e in tree.findall('.//Properties/*[@name="Source"]'))
 for module in ['IllustratedAtlasCatalog','IllustratedSectorDescriptor','IllustratedSectorRenderer','IllustratedAtlasSession','IllustratedController','IllustratedRun','ContinuousGround','ContinuousGround.spec','ScreenGridEdges','GroundCapability','OceanBoundary','FrameInvestigation','OrganicCoast','OrganicCoast.spec','OrganicRibbon','OrganicGround.spec','OrganicSoak','OrganicFilterProbe']:
  check(name+' isolation '+module,(module in names)==(name=='PowerStateTests'))
 for asset in ['96236605552471','133413370857301','82421581539732']:
  check(name+' ID isolation '+asset,(asset in source)==(name=='PowerStateTests'))
for p in (root/'tests/integration/IllustratedWorld').glob('*.luau'):
 s=p.read_text()
 check(p.name+' cosmetic only',all(x not in s for x in ['FireServer','GetDataStore','DataStoreService','InvokeServer']))
check('fixed 96 images','Catalog.POOL_SIZE = 96' in cat and 'Catalog.DRAW_SLOTS = 92' in cat)
record={'passed':len(checks),'scope':'Local frozen art/catalog/build/security checks; actual engine evidence separate','checks':checks}
(root/'docs/evidence/illustrated-world-v1/static-validation.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({'passed':len(checks)}))
