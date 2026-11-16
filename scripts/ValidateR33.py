"""Read-only atlas/provenance and proof-mapping validation; not a Luau type checker."""
from pathlib import Path
import hashlib,json,re,xml.etree.ElementTree as ET
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'assets/r32-proof-v3'
manifest=json.loads((ART/'manifest.json').read_text(encoding='utf-8'))
source=(ROOT/'src/client/Views/Map/SpriteManifest.luau').read_text(encoding='utf-8')
checks=[]
def check(name,value):
    assert value,name
    checks.append(name)
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
check('Approved atlas checksum',digest(ART/manifest['atlasFile'])==manifest['atlasSha256'])
check('Luau atlas checksum pinned',manifest['atlasSha256'] in source)
atlas=Image.open(ART/manifest['atlasFile'])
check('RGBA atlas',atlas.mode=='RGBA' and atlas.size==(1024,1024))
for e in manifest['sprites']:
    line=next(line for line in source.splitlines() if 'id = "'+e['artId']+'"' in line)
    check(e['artId']+' revision',f'revision = {e["artRevision"]},' in line)
    check(e['artId']+' native mapping',e['fallbackPatchIds'][0] in line)
    for key,field in [('rect','sourceRect'),('cell','cell')]:
        parsed=[float(n) for n in re.search(key+r' = \{([^}]+)\}',line).group(1).split(',')]
        check(e['artId']+' '+key,parsed==e[field])
    for key,field in [('world','worldCanvasSize'),('pivot','pivotPx'),('anchor','groundAnchorWorld')]:
        parsed=[float(n) for n in re.search(key+r' = Vector2.new\(([^)]+)\)',line).group(1).split(',')]
        check(e['artId']+' '+key,parsed==e[field])
    for file,sha in [('sourceFile','sourceSha256'),('exportFile','exportSha256')]:
        check(e['artId']+' '+file,digest(ART/e[file])==e[sha])
    x,y,w,h=e['sourceRect']
    check(e['artId']+' packed content',atlas.crop((x,y,x+w,y+h)).tobytes()==Image.open(ART/e['exportFile']).tobytes())
    if e['artId']=='coast-headland':check('Corrected coast source hash',digest(ART/e['correctionSource'])==e['correctionSourceSha256'])
for file in ['correction-record.json','production-inputs.json','refinement-history.json']:
    check(file+' readable provenance',bool(json.loads((ART/file).read_text(encoding='utf-8'))))
for variant in ['PowerState','PowerStateTests']:
    place=ET.parse(ROOT/'.build'/f'{variant}.rbxlx')
    names=[n.text for n in place.findall('.//Item/Properties/string[@name="Name"]')]
    check(variant+' manifest included','SpriteManifest' in names)
    check(variant+' loader included','SpriteAtlasLoader' in names)
    check(variant+' renderer included','SpriteTerrainRenderer' in names)
    check(variant+' isolated test mapping',('HybridProof' in names)==(variant=='PowerStateTests'))
    check(variant+' isolated regression mapping',('R33.spec' in names)==(variant=='PowerStateTests'))
for name in ['SpriteManifest','SpriteAtlasLoader','SpriteTerrainRenderer']:
    text=(ROOT/f'src/client/Views/Map/{name}.luau').read_text(encoding='utf-8')
    check(name+' no asset ID',re.search(r'rbxassetid://\d+',text) is None)
    check(name+' no network fetch','PreloadAsync' not in text and 'GetAsync' not in text)
result={'passed':len(checks),'checks':checks,'atlasSha256':manifest['atlasSha256'],'scope':'Local source/art mapping only; engine evidence separate'}
(ROOT/'.build/R33-local-validation.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'passed':len(checks),'atlasSha256':manifest['atlasSha256']}))
