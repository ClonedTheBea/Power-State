"""Deterministic local packing/inspection only. Requires already-installed Pillow.
Run from any directory; generated originals are preserved. No Roblox operations.
"""
from pathlib import Path
import hashlib, json, shutil, zipfile, struct
from xml.etree.ElementTree import Element, SubElement, tostring
from PIL import Image, ImageDraw, ImageFont, ImageCms

ROOT = Path(__file__).resolve().parent
INPUT = json.loads((ROOT / 'production-inputs.json').read_text(encoding='utf-8'))
SPECS = [
 ('coast-headland', (0,0,512,512), (248,248), (248,248), (217.5,362.5), 'west-cape'),
 ('mountain-ridge', (512,0,512,256), (248,120), (248,120), (587.5,180), 'highlands'),
 ('forest-cluster', (512,256,256,256), (150,150), (120,120), (290,422.5), 'wood-west'),
 ('agriculture', (768,256,256,256), (160,160), (120,120), (772.5,430), 'fields'),
 ('settlement', (0,512,256,256), (150,150), (120,160), (755,300), 'newford'),
 ('gas-station', (256,512,256,256), (150,150), (120,160), (340,345), 'industry'),
]
PROFILE = ImageCms.ImageCmsProfile(ImageCms.createProfile('sRGB')).tobytes()
# LittleCMS stamps creation time; freeze it so repeated PNG exports hash identically.
PROFILE = PROFILE[:24] + struct.pack('>6H',2026,11,15,0,0,0) + PROFILE[36:]
def save(im, path):
    im.save(path, icc_profile=PROFILE)
def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
def resize(im, size):
    return im.convert('RGBa').resize(size, Image.Resampling.LANCZOS).convert('RGBA')
def dilate_rgb(im, steps=8):
    # Propagate nearest available colour into zero-alpha texels; alpha never changes.
    original = im.getchannel('A')
    known = original.point(lambda a: 255 if a else 0)
    rgb = im.convert('RGB')
    for _ in range(steps):
        next_known, next_rgb = known.copy(), rgb.copy()
        for dx,dy in ((1,0),(-1,0),(0,1),(0,-1)):
            shifted_mask = Image.new('L', im.size)
            shifted_mask.paste(known,(dx,dy))
            from PIL import ImageChops
            fresh = ImageChops.subtract(shifted_mask,next_known)
            shifted = Image.new('RGB',im.size)
            shifted.paste(rgb,(dx,dy))
            next_rgb.paste(shifted,(0,0),fresh)
            next_known = ImageChops.lighter(next_known,shifted_mask)
        known,rgb = next_known,next_rgb
    rgb.putalpha(original)
    return rgb

for d in ('sources','sprites'):
    (ROOT/d).mkdir(exist_ok=True)
atlas = Image.new('RGBA',(1024,1024))
entries=[]
for spec, record in zip(SPECS, INPUT['records']):
    art_id, cell, world, pivot, anchor, patch = spec
    assert art_id == record['id']
    source = ROOT/'sources'/f'{art_id}-generated.png'
    if not source.exists():
        shutil.copy2(record['source'],source)
    raw=Image.open(source).convert('RGBA')
    bbox=raw.getchannel('A').getbbox()
    crop=raw.crop(bbox)
    x,y,w,h=cell
    cw,ch=w-16,h-16
    factor=min((cw-16)/crop.width,(ch-16)/crop.height)
    size=(round(crop.width*factor),round(crop.height*factor))
    offset=((cw-size[0])//2,(ch-size[1])//2)
    sprite=Image.new('RGBA',(cw,ch))
    sprite.paste(resize(crop,size),offset)
    sprite=dilate_rgb(sprite)
    export=ROOT/'sprites'/f'{art_id}.png'
    save(sprite,export)
    atlas.paste(sprite,(x+8,y+8))
    top=[anchor[i]-pivot[i]*world[i]/(cw,ch)[i] for i in (0,1)]
    entries.append(dict(artId=art_id,artRevision=1,cell=list(cell),sourceRect=[x+8,y+8,cw,ch],
        worldCanvasSize=list(world),pivotPx=list(pivot),groundAnchorWorld=list(anchor),
        visualBounds=[*top,*world],fallbackPatchIds=['art1:0:0:'+patch],
        renderOrder='shore-base-before-native-meadows' if art_id=='coast-headland' else 'terrain',
        sourceFile=str(source.relative_to(ROOT)).replace('\\','/'),sourceSha256=digest(source),
        exportFile=str(export.relative_to(ROOT)).replace('\\','/'),exportSha256=digest(export),
        sourceAlphaCrop=list(bbox),uniformFitSize=list(size),contentPlacement=list(offset),
        edgeProfile={'status':'Local review only; coast join not approved' if art_id=='coast-headland' else 'Isolated organic silhouette; no tiling contract'}))
save(atlas,ROOT/'power-state-map-proof-v1.png')
manifest=dict(schemaVersion=1,atlasRevision=1,atlasKey='power-state-map-proof-v1',
    atlasFile='power-state-map-proof-v1.png',atlasSha256=digest(ROOT/'power-state-map-proof-v1.png'),
    size=[1024,1024],format='8-bit RGBA PNG, straight alpha, embedded sRGB',gutterPx=8,
    processing='Alpha-bounds crop; uniform premultiplied-alpha Lanczos fit; centred inside unchanged content canvas; 8-step RGB edge dilation without alpha expansion',
    provenance=dict(date=INPUT['date'],tool=INPUT['tool'],model=INPUT['model'],references=INPUT['references'],
        promptRecord='production-inputs.json',rightsStatus='AI-generated local proof; no third-party input art. No legal or exclusivity assurance; owner rights/destination review pending before upload.',
        ownerVisualAcceptance='Pending',uploadApproval=False,robloxAssetId=None),sprites=entries)
(ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')

# Contact sheet uses exact logical projected sizes, not enlarged thumbnail claims.
sheet=Image.new('RGBA',(1440,1250),'#17232C')
draw=ImageDraw.Draw(sheet)
font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',19)
small=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',15)
draw.text((24,12),'POWER STATE / R3.2 local artwork proof — no runtime integration',font=font,fill='white')
draw.text((24,42),'Each panel: land at zoom 1.0 / ocean at zoom 0.55. View image at 100% for logical-pixel sizes.',font=small,fill='#BBCBCB')
for n,e in enumerate(entries):
    ox=(n%3)*480; oy=80+(n//3)*580
    draw.text((ox+18,oy+8),e['artId'],font=font,fill='white')
    for j,(zoom,bg) in enumerate(((1,'#6B8463'),(.55,'#2B535C'))):
        by=oy+44+j*260
        draw.rectangle((ox+12,by,ox+467,by+246),fill=bg)
        sprite=Image.open(ROOT/e['exportFile'])
        size=tuple(round(v*zoom) for v in e['worldCanvasSize'])
        rendered=resize(sprite,size)
        sheet.alpha_composite(rendered,(ox+240-size[0]//2,by+124-size[1]//2))
        draw.text((ox+22,by+220),f'zoom {zoom:.2f} / canvas {size[0]} x {size[1]} px',font=small,fill='white')
save(sheet,ROOT/'contact-sheet.png')

# Layered OpenRaster: editable placement/paint per motif, not vector object sources.
root=Element('image',w='1024',h='1024',name='Power State R3.2 proof')
stack=SubElement(root,'stack')
with zipfile.ZipFile(ROOT/'power-state-map-proof-v1.ora','w') as z:
    z.writestr('mimetype','image/openraster',compress_type=zipfile.ZIP_STORED)
    for e in reversed(entries):
        x,y,w,h=e['sourceRect']; name=e['artId']; dest=f'data/{name}.png'
        SubElement(stack,'layer',name=name,src=dest,x=str(x),y=str(y),opacity='1.0',visibility='visible',**{'composite-op':'svg:src-over'})
        z.write(ROOT/e['exportFile'],dest)
    z.writestr('stack.xml',tostring(root,encoding='utf-8'))
    z.write(ROOT/'power-state-map-proof-v1.png','mergedimage.png')

# Local native coast proxy at 2 display pixels per world unit; geometry only.
coast=Image.new('RGBA',(1200,800),'#2B535C')
e=entries[0]; left,top,ww,wh=e['visualBounds']
coast.alpha_composite(resize(Image.open(ROOT/e['exportFile']),(ww,wh)),(round(left),round(top)))
cd=ImageDraw.Draw(coast)
cd.rounded_rectangle((175,190,595,540),radius=175,fill='#6B8463')
crop=coast.crop((70,220,410,500)).resize((680,560),Image.Resampling.NEAREST)
save(crop,ROOT/'coast-join-check.png')

# Pivot diagnostic: crosses are inspection overlays only, never packed into art.
pivots=Image.new('RGBA',(960,640),'#2B535C')
pd=ImageDraw.Draw(pivots)
for n,e in enumerate(entries):
    ox=(n%3)*320; oy=(n//3)*320
    im=Image.open(ROOT/e['exportFile'])
    ww,wh=e['worldCanvasSize']; sw,sh=im.size
    px=ox+(320-ww)//2; py=oy+52
    pivots.alpha_composite(resize(im,(ww,wh)),(px,py))
    cx=px+e['pivotPx'][0]*ww/sw; cy=py+e['pivotPx'][1]*wh/sh
    pd.line((cx-7,cy,cx+7,cy),fill='cyan',width=1)
    pd.line((cx,cy-7,cx,cy+7),fill='cyan',width=1)
    pd.text((ox+10,oy+10),e['artId'],font=small,fill='white')
save(pivots,ROOT/'pivot-check.png')

checks=[]
def check(name, value):
    assert value,name
    checks.append(name)
check('Atlas dimensions and RGBA',atlas.size==(1024,1024) and atlas.mode=='RGBA')
occupied=Image.new('L',(1024,1024))
od=ImageDraw.Draw(occupied)
for e in entries:
    x,y,w,h=e['cell']; sx,sy,sw,sh=e['sourceRect']
    check(e['artId']+' bounds',0<=x<x+w<=1024 and 0<=y<y+h<=1024)
    check(e['artId']+' nonoverlap',occupied.crop((x,y,x+w,y+h)).getbbox() is None)
    od.rectangle((x,y,x+w-1,y+h-1),fill=255)
    a=atlas.crop((x,y,x+w,y+h)).getchannel('A')
    a.paste(0,(8,8,w-8,h-8))
    check(e['artId']+' transparent gutters',a.getbbox() is None)
    sprite=Image.open(ROOT/e['exportFile'])
    check(e['artId']+' exact atlas content',atlas.crop((sx,sy,sx+sw,sy+sh)).tobytes()==sprite.tobytes())
    hist=sprite.getchannel('A').histogram()
    check(e['artId']+' transparent opaque and antialiased alpha',hist[0]>0 and hist[255]>0 and sum(hist[1:255])>0)
    for zoom in (.55,.72,1,1.2,1.8):
        check(e['artId']+f' pivot roundtrip {zoom}',all(abs(e['visualBounds'][i]*zoom+e['pivotPx'][i]*e['worldCanvasSize'][i]/(sw,sh)[i]*zoom-e['groundAnchorWorld'][i]*zoom)<1e-8 for i in (0,1)))
from PIL import ImageChops
check('Unused atlas allocation transparent',ImageChops.subtract(atlas.getchannel('A'),occupied).getbbox() is None)
check('Embedded sRGB',bool(Image.open(ROOT/'power-state-map-proof-v1.png').info.get('icc_profile')))
patch_bounds=[(125,295,185,135),(485,120,205,120),(225,375,130,95),(700,380,145,100),(705,255,110,95),(285,290,125,110)]
for e,(px,py,pw,ph) in zip(entries,patch_bounds):
    x,y,w,h=e['visualBounds']
    check(e['artId']+' 64-unit overhang',x>=px-64 and y>=py-64 and x+w<=px+pw+64 and y+h<=py+ph+64)
with zipfile.ZipFile(ROOT/'power-state-map-proof-v1.ora') as z:
    check('OpenRaster archive integrity',z.testzip() is None and len([n for n in z.namelist() if n.startswith('data/')])==6)
report=dict(passed=len(checks),checks=checks,notTested=['Roblox loading/filtering/performance','Owner visual acceptance','Physical-device readability'],visualReview='See docs/R32-LOCAL-ART-VALIDATION.md')
(ROOT/'validation-results.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'passed':len(checks),'atlasSha256':manifest['atlasSha256'],'outputs':str(ROOT)}))
