"""Local packaging/contact-sheet layout only. Does not repaint source artwork or touch runtime."""
from pathlib import Path
import hashlib
import json
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
OLD = ROOT.parent / 'r32-proof-v3'
EXPECTED = 'e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(OLD / 'power-state-map-proof-v3.png') == EXPECTED
font_path = 'C:/Windows/Fonts/segoeui.ttf'
def font(n): return ImageFont.truetype(font_path, n)
LAND = (107,132,99,255)
OCEAN = (43,80,91,255)
BG = (24,36,45,255)
atlas = Image.new('RGBA', (512,256))
records = []
for i, (name, world, anchor, terminal, patch) in enumerate([
    ('southbank',130,[685,590],[665,535],'art1:0:0:southbank'),
    ('eastmere',140,[945,510],[930,455],'art1:0:0:eastmere'),
]):
    source = ROOT / 'sources' / (name+'-generated.png')
    im = Image.open(source).convert('RGBA')
    bounds = im.getchannel('A').getbbox()
    fitted = im.crop(bounds)
    fitted.thumbnail((224,224),Image.Resampling.LANCZOS)
    export = Image.new('RGBA',(240,240))
    pos = ((240-fitted.width)//2,(240-fitted.height)//2)
    export.alpha_composite(fitted,pos)
    export.save(ROOT/'sprites'/f'{name}-candidate.png')
    atlas.alpha_composite(export,(i*256+8,8))
    records.append(dict(artId=name+'-candidate',revision=1,sourceFile=str(source.relative_to(ROOT)).replace('\\','/'),sourceSha256=sha(source),sourceAlphaBounds=bounds,sourceFitSize=list(fitted.size),sourceFitOffset=list(pos),sourceRect=[i*256+8,8,240,240],cell=[i*256,0,256,256],pivotPx=[120,160],worldCanvasSize=[world,world],proposedGroundAnchorWorld=anchor,unchangedConnectionAnchorWorld=terminal,fallbackPatchIds=[patch],status='Local proposal; pivot and placement require Studio review'))
atlas.save(ROOT/'settlement-study-atlas.png')
manifest = dict(schemaVersion=1,status='LOCAL STUDY ONLY; not the frozen runtime manifest',atlasFile='settlement-study-atlas.png',size=[512,256],gutterPx=8,atlasSha256=sha(ROOT/'settlement-study-atlas.png'),approvedAtlasPreservedSha256=EXPECTED,provenance=dict(tool='Built-in OpenAI image_gen',model='Not exposed',date='2026-11-16',reference='Project-owned approved Newford sprite and approved motif contact sheet',prompts='prompts.json',rights='AI-generated candidates from project references; no exclusivity or legal clearance asserted; owner review required',uploadApproval=False),sprites=records)
(ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')

# Exact approved exports are used only as comparison inputs, never overwritten.
items = [('Southbank candidate',ROOT/'sprites/southbank-candidate.png',(130,130)),('Eastmere candidate',ROOT/'sprites/eastmere-candidate.png',(140,140)),('Newford approved',OLD/'sprites/settlement.png',(150,150)),('Forest approved',OLD/'sprites/forest-cluster.png',(150,150)),('Fields approved',OLD/'sprites/agriculture.png',(160,160)),('Ridge approved',OLD/'sprites/mountain-ridge.png',(248,120))]
sheet = Image.new('RGBA',(1440,1000),BG)
d = ImageDraw.Draw(sheet)
d.text((24,16),'POWER STATE / R3.6 — local artwork candidates',font=font(24),fill='white')
d.text((24,53),'Review only. View at 100% for logical sizes. Native meadow #6B8463; ocean is a diagnostic background.',font=font(17),fill='#bdcbd0')
for i,(label,path,size) in enumerate(items):
    x=16+(i%3)*476; y=100+(i//3)*440
    d.text((x+8,y),label,font=font(20),fill='white')
    im=Image.open(path).convert('RGBA')
    for j,(z,bg) in enumerate([(1,LAND),(.55,OCEAN)]):
        yy=y+34+j*187
        d.rectangle((x,yy,x+460,yy+177),fill=bg)
        dims=tuple(round(v*z) for v in size)
        thumb=im.resize(dims,Image.Resampling.LANCZOS)
        sheet.alpha_composite(thumb,(x+(460-dims[0])//2,yy+(145-dims[1])//2))
        d.text((x+10,yy+151),f'zoom {z:.2f} / canvas {dims[0]} × {dims[1]} px',font=font(15),fill='white')
sheet.save(ROOT/'contact-sheet.png')

# Five zooms on actual native meadow; pivots/terminals annotate copies only.
sheet=Image.new('RGBA',(1600,760),BG);d=ImageDraw.Draw(sheet)
d.text((20,15),'R3.6 / five zooms — proposed pivots, unchanged connection anchors',font=font(23),fill='white')
d.text((20,50),'Cyan cross = cosmetic ground pivot; gold circle = existing electrical terminal. Not an in-game screenshot.',font=font(17),fill='#bdcbd0')
for row,r in enumerate(records):
    im=Image.open(ROOT/'sprites'/(r['artId']+'.png'))
    for col,z in enumerate([.55,.72,1,1.2,1.8]):
        x=10+col*318;y=90+row*330;w=r['worldCanvasSize'][0]
        d.rectangle((x,y,x+308,y+315),fill=LAND)
        size=round(w*z);px=x+(308-size)//2;py=y+40+(240-size)//2
        sheet.alpha_composite(im.resize((size,size),Image.Resampling.LANCZOS),(px,py))
        pivot=(px+size/2,py+size*160/240)
        dx=r['unchangedConnectionAnchorWorld'][0]-r['proposedGroundAnchorWorld'][0]
        dy=r['unchangedConnectionAnchorWorld'][1]-r['proposedGroundAnchorWorld'][1]
        tx,ty=pivot[0]+dx*z,pivot[1]+dy*z
        d.line((pivot[0]-5,pivot[1],pivot[0]+5,pivot[1]),fill='cyan',width=1)
        d.line((pivot[0],pivot[1]-5,pivot[0],pivot[1]+5),fill='cyan',width=1)
        d.ellipse((tx-4,ty-4,tx+4,ty+4),outline='#ffdd88',width=2)
        d.text((x+10,y+280),f"{r['artId']} / {z:.2f}",font=font(15),fill='white')
sheet.save(ROOT/'zoom-pivot-review.png')

checks=[]
def check(name,value):
    assert value,name
    checks.append(name)
check('Approved atlas exact SHA-256',sha(OLD/'power-state-map-proof-v3.png')==EXPECTED)
check('Study atlas RGBA',atlas.mode=='RGBA')
check('Study atlas size',atlas.size==(512,256))
for r in records:
    x,y,w,h=r['sourceRect'];cx,cy,cw,ch=r['cell']
    check(r['artId']+' rectangle bounds',x>=0 and y>=0 and x+w<=512 and y+h<=256)
    check(r['artId']+' pivot within rectangle',0<=r['pivotPx'][0]<w and 0<=r['pivotPx'][1]<h)
    check(r['artId']+' transparent gutter',all(atlas.getpixel((xx,yy))[3]==0 for yy in range(cy,cy+ch) for xx in range(cx,cx+cw) if not(x<=xx<x+w and y<=yy<y+h)))
    alpha=atlas.crop((x,y,x+w,y+h)).getchannel('A')
    check(r['artId']+' transparent and opaque pixels',alpha.getextrema()==(0,255))
    check(r['artId']+' antialiased alpha',len(set(alpha.getdata()))>2)
check('Nonoverlapping cells',records[0]['cell'][0]+256<=records[1]['cell'][0])
results=dict(passed=len(checks),checks=checks,notEstablished=['Roblox filtering or permissions','Visual acceptance','Seamless tile compatibility','Physical-device readability or performance'],files={p.name:sha(p) for p in ROOT.glob('*.png')})
(ROOT/'validation-results.json').write_text(json.dumps(results,indent=2)+'\n',encoding='utf-8')
print(f'{len(checks)} local packaging checks passed; no runtime tests performed.')
