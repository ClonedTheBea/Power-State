"""Freeze approved bytes and validate cosmetic placement; no runtime or upload operations."""
from pathlib import Path
import hashlib
import json
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(__file__).resolve().parent
SOURCE=ROOT.parent/'r36-study-v1'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
EXPECTED='baff92a631e89bbf9a1506f5401488e40fc2d5fe56a71399b1f410df5b05ff4e'
checks=[]
def check(name,value):
    assert value,name
    checks.append(name)
check('Accepted settlement atlas checksum',sha(SOURCE/'settlement-study-atlas.png')==EXPECTED)
target=ROOT/'power-state-settlements-proof-v1.png'
target.write_bytes((SOURCE/'settlement-study-atlas.png').read_bytes())
atlas=Image.open(target)
check('RGBA and dimensions',atlas.mode=='RGBA' and atlas.size==(512,256))
old=ROOT.parent/'r32-proof-v3/power-state-map-proof-v3.png'
check('Original six-motif atlas unchanged',sha(old)=='e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb')
entries=[]
for name,entity,rect,world,pivot,anchor,terminal,patch in [
 ('southbank','south',[8,8,240,240],130,[150,182],[685,590],[665,535],[635,555,100,70]),
 ('eastmere','east',[264,8,240,240],140,[120,160],[945,510],[930,455],[895,475,100,70]),
]:
    x,y,w,h=rect
    image=atlas.crop((x,y,x+w,y+h))
    check(name+' source rectangle in bounds',x>=0 and y>=0 and x+w<=512 and y+h<=256)
    check(name+' accepted motif exact pixels',image.tobytes()==Image.open(SOURCE/'sprites'/(name+'-candidate.png')).tobytes())
    check(name+' pivot in content',all(0<=v<240 for v in pivot))
    left=anchor[0]-pivot[0]*world/240;top=anchor[1]-pivot[1]*world/240
    check(name+' full canvas inside existing 64-unit overhang',left>=patch[0]-64 and top>=patch[1]-64 and left+world<=patch[0]+patch[2]+64 and top+world<=patch[1]+patch[3]+64)
    local=[pivot[j]+(terminal[j]-anchor[j])*240/world for j in range(2)]
    check(name+' terminal projects within painted silhouette',image.getpixel(tuple(round(v) for v in local))[3]>=240)
    cx=0 if name=='southbank' else 256
    check(name+' transparent 8px gutters',all(atlas.getpixel((xx,yy))[3]==0 for yy in range(256) for xx in range(cx,cx+256) if not(x<=xx<x+w and y<=yy<y+h)))
    for zoom in [.55,.72,1,1.2,1.8]:
        for ox,oy in [(0,0),(-450,90),(100,-300)]:
            projected=[ox+left*zoom+local[0]*world/240*zoom,oy+top*zoom+local[1]*world/240*zoom]
            check(f'{name} anchor transform z{zoom} pan{ox},{oy}',abs(projected[0]-(ox+terminal[0]*zoom))<1e-6 and abs(projected[1]-(oy+terminal[1]*zoom))<1e-6)
    entries.append(dict(artId=name,settlementId=entity,artRevision=1,placementRevision=2 if name=='southbank' else 1,sourceRect=rect,worldCanvasSize=[world,world],pivotPx=pivot,groundAnchorWorld=anchor,connectionAnchorWorld=terminal,worldBounds=[left,top,world,world],fallbackPatchId='art1:0:0:'+name,terminalInContentPx=local))
manifest=dict(status='Owner-accepted artwork; upload-ready, real-texture integration pending',atlasFile=target.name,atlasSha256=sha(target),size=[512,256],gutterPx=8,assetId=None,owner={'username':'missawfulname','userId':149564436,'type':'personal'},privacy='Restricted',testUniverseId=10776833313,productionUniverseIdDoNotModify=10776828545,provenance={'acceptedSource':'../r36-study-v1/manifest.json','prompts':'../r36-study-v1/prompts.json','production':'Byte-identical copy of accepted R3.6 atlas; no regeneration or colour/alpha changes','ownerAcceptance':'R3.7 request: both settlements accepted for isolated proof use','uploadOperator':'Owner only'},sprites=entries)
(ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
sheet=Image.new('RGBA',(1600,760),(24,36,45,255));d=ImageDraw.Draw(sheet)
font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',17)
d.text((20,15),'R3.7 placement review / exact accepted pixels / NOT a Studio screenshot',font=font,fill='white')
d.text((20,45),'Cyan: cosmetic pivot. Gold: unchanged electrical terminal. View at 100% for logical sizes.',font=font,fill='white')
for row,e in enumerate(entries):
    x,y,w,h=e['sourceRect'];im=atlas.crop((x,y,x+w,y+h));world=e['worldCanvasSize'][0]
    for col,z in enumerate([.55,.72,1,1.2,1.8]):
        xx=10+col*318;yy=85+row*330
        d.rectangle((xx,yy,xx+308,yy+315),fill=(107,132,99,255))
        size=round(world*z);px=xx+(308-size)//2;py=yy+30+(240-size)//2
        sheet.alpha_composite(im.resize((size,size),Image.Resampling.LANCZOS),(px,py))
        p=[px+e['pivotPx'][0]*size/240,py+e['pivotPx'][1]*size/240]
        t=[px+e['terminalInContentPx'][0]*size/240,py+e['terminalInContentPx'][1]*size/240]
        d.line((p[0]-4,p[1],p[0]+4,p[1]),fill='cyan');d.line((p[0],p[1]-4,p[0],p[1]+4),fill='cyan')
        d.ellipse((t[0]-4,t[1]-4,t[0]+4,t[1]+4),outline='#ffdd88',width=2)
        d.text((xx+10,yy+280),f"{e['artId']} / zoom {z:.2f}",font=font,fill='white')
sheet.save(ROOT/'alignment-five-zooms.png')
check('Byte-identical upload copy',sha(target)==EXPECTED)
(ROOT/'validation-results.json').write_text(json.dumps(dict(passed=len(checks),checks=checks,scope='Local pixel, geometry and packaging checks only; no engine validation'),indent=2)+'\n',encoding='utf-8')
print(f'{len(checks)} local checks passed; upload SHA-256 {sha(target)}')
