"""Read-only existing-art audit; no pixels, frozen manifests or runtime code are written."""
from pathlib import Path
import hashlib,json
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
checks=[]
def check(name,value):
    assert value,name
    checks.append(name)
assets=[]
for directory,expected in [("r32-proof-v3","e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb"),("r37-settlements-v1","baff92a631e89bbf9a1506f5401488e40fc2d5fe56a71399b1f410df5b05ff4e")]:
    folder=ROOT/"assets"/directory
    m=json.loads((folder/"manifest.json").read_text())
    f=folder/m["atlasFile"]
    digest=hashlib.sha256(f.read_bytes()).hexdigest()
    check(directory+" approved SHA-256",digest==expected==m["atlasSha256"])
    im=Image.open(f)
    check(directory+" RGBA",im.mode=="RGBA")
    check(directory+" dimensions",list(im.size)==m["size"])
    rects=[]
    for sprite in m["sprites"]:
        name=sprite["artId"];x,y,w,h=sprite["sourceRect"]
        check(name+" rectangle bounds",0<=x<x+w<=im.width and 0<=y<y+h<=im.height)
        check(name+" pivot inside content",0<=sprite["pivotPx"][0]<=w and 0<=sprite["pivotPx"][1]<=h)
        for a,b,c,d in rects:
            check(name+" nonoverlap "+str((a,b)),x+w<=a or a+c<=x or y+h<=b or b+d<=y)
        rects.append((x,y,w,h))
        alpha=im.getchannel("A")
        check(name+" transparent gutters",all(alpha.crop(box).getextrema()[1]==0 for box in [(x-8,y-8,x+w+8,y),(x-8,y+h,x+w+8,y+h+8),(x-8,y,x,y+h),(x+w,y,x+w+8,y+h)]))
        for path_key,hash_key in [("sourceFile","sourceSha256"),("exportFile","exportSha256"),("correctionSource","correctionSourceSha256")]:
            if path_key in sprite:
                check(name+" "+path_key+" provenance hash",hashlib.sha256((folder/sprite[path_key]).read_bytes()).hexdigest()==sprite[hash_key])
    assets.append(dict(file=str(f.relative_to(ROOT)),sha256=digest,dimensions=im.size,sprites=len(rects)))
template=json.loads((ROOT/"assets/illustrated-world-v1-handoff/proposed-manifest.json").read_text())
check("Template has no fake asset ID/hash",template["assetId"] is None and template["atlasSha256"] is None)
check("Template sixteen bounded slots",len(template["entries"])==16)
occupied=set()
for entry in template["entries"]:
    x,y,w,h=entry["cell"];rx,ry,rw,rh=entry["sourceRect"]
    check(entry["artId"]+" template allocation",(x,y) not in occupied and 0<=x and 0<=y and x+w<=1024 and y+h<=1024 and [rx,ry,rw,rh]==[x+8,y+8,240,240])
    occupied.add((x,y))
result=dict(scope="Local existing pixels/provenance and proposed packing only; no new renderer or Roblox performance evidence",passed=len(checks),assets=assets,checks=checks)
(ROOT/"docs/illustrated-world-v1-audit-results.json").write_text(json.dumps(result,indent=2)+"\n",encoding="utf-8")
print(json.dumps(dict(passed=len(checks),scope=result["scope"])))
