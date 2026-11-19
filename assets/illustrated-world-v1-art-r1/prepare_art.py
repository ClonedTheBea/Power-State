"""Reproducible local raster preparation. Never imported by Roblox.

Illustrations originate in retained imagegen PNGs. Geometry masks constrain their
material ownership; they do not generate replacement geometric illustrations.
"""
from pathlib import Path
import json, hashlib, math, zipfile
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, __version__ as PIL_VERSION
from prepare_guides import PATTERNS
OUT=Path(__file__).resolve().parent
ROOT=OUT.parents[1]
N=240
LAND=(107,132,99);WATER=(17,42,60)
FONT=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',16)
SMALL=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',12)
Y,X=np.mgrid[:N,:N];PX=X+.5;PY=Y+.5
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def occupancy(p):return (p & (1 << ((Y>=120)*2+(X>=120))))!=0
def distance(p):
    # Four half-axis boundary segments; distance measured in content pixels.
    d=np.full((N,N),1000.0)
    q=[bool(p&(1<<i)) for i in range(4)]
    if q[0]!=q[1]:d=np.minimum(d,np.hypot(PX-120,np.maximum(PY-120,0)))
    if q[2]!=q[3]:d=np.minimum(d,np.hypot(PX-120,np.maximum(120-PY,0)))
    if q[0]!=q[2]:d=np.minimum(d,np.hypot(PY-120,np.maximum(PX-120,0)))
    if q[1]!=q[3]:d=np.minimum(d,np.hypot(PY-120,np.maximum(120-PX,0)))
    return d
def read(name):return np.array(Image.open(OUT/'sources'/f'{name}.png').convert('RGBA').resize((N,N),Image.Resampling.LANCZOS),dtype=float)
def shore(p,name):
    a=read(name);land=occupancy(p);d=distance(p);rgb=a[:,:,:3]
    # Preserve the actual painted pixels. Wrong-side generated material becomes
    # transparent, exposing the exact Native underlay; never extrude texture to
    # fill it. Soft confidence suppresses isolated neutral extraction fringes.
    land_score=np.minimum(rgb[:,:,0]-rgb[:,:,2],rgb[:,:,1]-rgb[:,:,2])
    water_score=np.minimum(rgb[:,:,2]-rgb[:,:,0],rgb[:,:,1]-rgb[:,:,0])
    score=np.where(land,land_score,water_score)
    confidence=np.clip((score-2)/9,0,1)
    alpha=a[:,:,3]*confidence*np.clip((30-d)/12,0,1)
    # Fill rejected water-side rock/grass pixels from the already painted
    # shallow-water band, sampled in its original north-up orientation. This
    # avoids both dark cut-out trenches and stretched nearest-colour columns.
    ref=read('shore-n')
    sx=8+(X%224);sy=106+np.minimum((d*.18).astype(int),6)
    water_paint=ref[sy,sx,:3]
    assert ((water_paint[:,:,2]>water_paint[:,:,0]+5)&(water_paint[:,:,1]>water_paint[:,:,0]+5))[~land].all()
    blend=np.clip((water_score-4)/18,0,1)*a[:,:,3]/255
    rgb[~land]=(rgb*blend[:,:,None]+water_paint*(1-blend[:,:,None]))[~land]
    alpha[~land]=(np.clip((30-d)/12,0,1)*185)[~land]
    rgb[~land]=rgb[~land]*.72+np.array(WATER)*.28
    out=np.dstack((rgb,alpha)).clip(0,255).astype('uint8')
    return out,dict(materialClippedPixels=int(((confidence<1)&(d<30)&(a[:,:,3]>0)).sum()),method='Exact Native land clipping; rejected water pixels filled from retained north-up painted shallow-water sample; premultiplied port blend; no geometry movement')
def port_key(bits):
    return tuple(bool(v) for v in bits)
def edge_profiles(prepared):
    # Same north-up source for matching ports. No rotation/mirroring of art.
    # Each end of a straight shares one averaged linear-light-agnostic RGBA
    # profile; 16px blend zone smooths the join into the authored interior.
    ports={}
    for p in [3,12,5,10]:
        a=prepared[PATTERNS[p]].astype(float);a[:,:,:3]*=a[:,:,3,None]/255
        if p in (3,12):ports[('v',bool(p&1),bool(p&4))]=(a[:,0]+a[:,-1])/2
        else:ports[('h',bool(p&1),bool(p&2))]=(a[0]+a[-1])/2
    return ports
def apply_ports(p,a,ports):
    a=a.astype(float);a[:,:,:3]*=a[:,:,3,None]/255;q=[bool(p&(1<<i)) for i in range(4)]
    for side,key in [('left',('v',q[0],q[2])),('right',('v',q[1],q[3])),('top',('h',q[0],q[1])),('bottom',('h',q[2],q[3]))]:
        target=ports.get(key,np.zeros((N,4)))
        for i in range(16):
            t=(1-i/16)**2
            if side=='left':a[:,i]=a[:,i]*(1-t)+target*t
            elif side=='right':a[:,-1-i]=a[:,-1-i]*(1-t)+target*t
            elif side=='top':a[i]=a[i]*(1-t)+target*t
            else:a[-1-i]=a[-1-i]*(1-t)+target*t
    # Alpha-zero RGB is populated later; semantic comparisons use premultiplied.
    a[:,:,:3]=np.divide(a[:,:,:3]*255,a[:,:,3,None],out=np.zeros_like(a[:,:,:3]),where=a[:,:,3,None]>0)
    return np.round(a).clip(0,255).astype('uint8')
def dilate(im,steps=8):
    a=np.array(im);rgb=a[:,:,:3].copy();known=a[:,:,3]>0
    for _ in range(steps):
        total=np.zeros_like(rgb,dtype=np.uint32);count=np.zeros(known.shape,dtype=np.uint16)
        for dx,dy in [(1,0),(-1,0),(0,1),(0,-1)]:
            kk=np.roll(known,(dy,dx),(0,1));rr=np.roll(rgb,(dy,dx),(0,1))
            if dx==1:kk[:,0]=False
            if dx==-1:kk[:,-1]=False
            if dy==1:kk[0]=False
            if dy==-1:kk[-1]=False
            total+=rr*kk[:,:,None];count+=kk
        fill=(~known)&(count>0)
        rgb[fill]=(total[fill]/count[fill,None]).round().astype('uint8');known|=fill
    a[:,:,:3]=rgb
    return Image.fromarray(a)
def object_sprite(name):
    src=Image.open(OUT/'sources'/f'{name}.png').convert('RGBA')
    # Ignore almost transparent generated fringe when choosing content extent.
    bbox=src.getchannel('A').point(lambda a:255 if a>=24 else 0).getbbox()
    crop=src.crop(bbox)
    # Fixed pivot is retained; ground contact bottom-centre lies at y184.
    scale=min(220/crop.width,176/crop.height)
    size=(round(crop.width*scale),round(crop.height*scale));crop=crop.resize(size,Image.Resampling.LANCZOS)
    im=Image.new('RGBA',(N,N));xy=(120-size[0]//2,184-size[1]);im.alpha_composite(crop,xy)
    return im,dict(sourceCrop=list(bbox),preparedSize=list(size),paste=list(xy),groundPivot=[120,184],note='Bottom-centre cosmetic ground contact; not an electrical connection point')
def tile_background(p):
    a=np.empty((N,N,4),dtype='uint8');a[:,:,:3]=np.where(occupancy(p)[:,:,None],LAND,WATER);a[:,:,3]=255
    return Image.fromarray(a)
def draw_label(d,xy,text,small=False):d.text(xy,text,font=SMALL if small else FONT,fill='#edf4f8')
def contact(sprites):
    names=list(PATTERNS.values())+['hill-low-a','hill-low-b','substation','pylon']
    inv={v:k for k,v in PATTERNS.items()}
    im=Image.new('RGB',(1200,1500),'#0b1420');d=ImageDraw.Draw(im)
    draw_label(d,(20,12),'Local prepared candidates — painted assets, not Studio or visual acceptance')
    for i,n in enumerate(names):
        x=20+i%4*295;y=50+i//4*286
        bg=tile_background(inv[n]) if n in inv else Image.new('RGBA',(N,N),(*LAND,255))
        bg.alpha_composite(sprites[n]);im.paste(bg,(x,y));draw_label(d,(x,y+244),n,True)
    im.save(OUT/'previews/contact-sheet.png')
def composite(mask,sprites,cell=64):
    h=len(mask);w=len(mask[0]);im=Image.new('RGBA',(w*cell,h*cell));d=ImageDraw.Draw(im)
    for y,row in enumerate(mask):
        for x,v in enumerate(row):d.rectangle((x*cell,y*cell,(x+1)*cell-1,(y+1)*cell-1),fill=(*LAND,255) if v else (*WATER,255))
    for y in range(1,h):
        for x in range(1,w):
            p=int(mask[y-1][x-1])+2*int(mask[y-1][x])+4*int(mask[y][x-1])+8*int(mask[y][x])
            if p in PATTERNS:im.alpha_composite(sprites[PATTERNS[p]].resize((cell,cell),Image.Resampling.LANCZOS),(x*cell-cell//2,y*cell-cell//2))
    return im
def previews(sprites):
    patterns={'Narrow headland':['00000','00100','00100','11111','11111'],'Narrow inlet':['11111','11011','11011','00000','00000'],'Isolated land':['00000','00000','00100','00000','00000'],'Lake':['11111','11111','11011','11111','11111'],'Diagonal land':['00000','01000','00100','00010','00000'],'Checkerboard':['10101','01010','10101','01010','10101'],'Stair coast':['10000','11000','11100','11110','11111'],'Disconnected':['11000','11000','00000','00011','00011']}
    im=Image.new('RGB',(1400,810),'#0b1420');d=ImageDraw.Draw(im);draw_label(d,(20,12),'Actual painted joins over exact masks — outer unknown context left Native')
    for i,(name,rows) in enumerate(patterns.items()):
        x=15+i%4*348;y=50+i//4*370;m=[[v=='1' for v in r] for r in rows]
        im.paste(composite(m,sprites),(x,y));draw_label(d,(x,y+325),name)
    im.save(OUT/'previews/painted-adversarial.png')
    im=Image.new('RGB',(1400,1260),'#0b1420');d=ImageDraw.Draw(im);draw_label(d,(20,12),'Actual-size local sprites at approved zooms — not device/engine evidence')
    names=['shore-diagonal-nw-se','shore-diagonal-ne-sw','hill-low-a','hill-low-b','substation','pylon']
    for row,n in enumerate(names):
        draw_label(d,(15,55+row*195),n,True)
        for col,z in enumerate([.55,.72,1,1.2,1.8]):
            world=64 if n.startswith('shore') else 96 if n.startswith('hill') else 80 if n=='substation' else 32
            size=round(world*z);x=220+col*230;y=55+row*195
            bg=tile_background(9 if n.endswith('nw-se') else 6) if n.startswith('shore') else Image.new('RGBA',(N,N),(*LAND,255));bg.alpha_composite(sprites[n])
            im.paste(bg.resize((size,size),Image.Resampling.LANCZOS),(x,y));draw_label(d,(x,y+178),f'{z:g}x / {size}px',True)
    im.save(OUT/'previews/five-zooms.png')
    examples=json.loads((OUT/'corpus-examples.json').read_text())
    im=Image.new('RGB',(1500,1140),'#0b1420');d=ImageDraw.Draw(im);draw_label(d,(20,12),'Painted accepted-corpus masks, fitted to sheet — representative diagonal cases, local composites')
    for i,e in enumerate(examples):
        x=15+i%3*495;y=50+i//3*535;picture=composite(e['mask'],sprites,30)
        im.paste(picture,(x,y));draw_label(d,(x,y+482),f"Corpus {e['index']} / rotation {e['rotation']} / display fit",True)
    im.save(OUT/'previews/corpus-painted.png')
    # Same mask and coordinates on both sides; all art placements illustrative,
    # not a proposal to move saved infrastructure or claim gameplay eligibility.
    m=examples[0]['mask']
    left=Image.new('RGBA',(1024,1024));ld=ImageDraw.Draw(left)
    for y,row in enumerate(m):
        for x,v in enumerate(row):ld.rectangle((x*64,y*64,x*64+63,y*64+63),fill=(*LAND,255) if v else (*WATER,255))
    right=composite(m,sprites)
    reused={n:Image.open(ROOT/'assets/r32-proof-v3/sprites'/f'{n}.png').convert('RGBA') for n in ['forest-cluster','agriculture','settlement','gas-station']}
    village=Image.open(ROOT/'assets/r37-settlements-v1/power-state-settlements-proof-v1.png').convert('RGBA').crop((8,8,248,248));reused['rural-village']=village
    # Surveyed decorative study positions only. No runtime coordinates changed.
    placements=[('forest-cluster',200,250,120),('forest-cluster',320,285,90),('agriculture',430,470,125),('settlement',560,520,120),('gas-station',320,580,115),('rural-village',710,530,85),('hill-low-a',660,330,120),('hill-low-b',780,300,130),('substation',450,570,80),('pylon',500,580,32)]
    for n,x,y,size in placements:
        s=reused.get(n,sprites.get(n));s=s.resize((size,size),Image.Resampling.LANCZOS);right.alpha_composite(s,(x-size//2,y-round(size*.77)))
    board=Image.new('RGB',(2088,1110),'#0b1420');bd=ImageDraw.Draw(board);board.paste(left,(10,50));board.paste(right,(1054,50));draw_label(bd,(10,12),'Same corpus38 mask — bare categorical ground');draw_label(bd,(1054,12),'Local art arrangement — existing gas/town/village/forest/fields reused')
    draw_label(bd,(10,1080),'Not a Studio render. Decorative placement study only; no saved anchors, infrastructure or terrain changed.')
    board.save(OUT/'previews/landscape-comparison.png')
def main():
    prepared={};corrections={};sprites={}
    for p,n in PATTERNS.items():prepared[n],corrections[n]=shore(p,n)
    ports=edge_profiles(prepared)
    for p,n in PATTERNS.items():sprites[n]=dilate(Image.fromarray(apply_ports(p,prepared[n],ports)))
    for n in ['hill-low-a','hill-low-b','substation','pylon']:sprites[n],corrections[n]=object_sprite(n);sprites[n]=dilate(sprites[n])
    for n,im in sprites.items():im.save(OUT/'sprites'/f'{n}-r1.png')
    template=json.loads((ROOT/'assets/illustrated-world-v1-handoff/proposed-manifest.json').read_text())
    entries=template['entries']
    for i,n in enumerate(['shore-diagonal-nw-se','shore-diagonal-ne-sw']):entries.append(dict(artId=n,revision=1,cell=[i*256,0,256,256],sourceRect=[i*256+8,8,240,240],pivotPx=[120,120],nominalWorldCanvas=[64,64],rotation=0,lighting='upper-left; short lower-right shadow',edgeFamily='orthogonal-sampled-coast-v1'))
    atlases=[]
    for atlas,names,size,file in [('main',list(sprites)[:12]+['hill-low-a','hill-low-b','substation','pylon'],(1024,1024),'power-state-terrain-edges-proof-v1.png'),('diagonal',['shore-diagonal-nw-se','shore-diagonal-ne-sw'],(512,256),'power-state-diagonal-shores-proof-v1.png')]:
        im=Image.new('RGBA',size)
        for e in entries:
            if e['artId'] not in names:continue
            x,y,w,h=e['sourceRect'];im.paste(sprites[e['artId']],(x,y));e.update(atlas=atlas,status='LOCAL CANDIDATE; owner visual review pending',spriteFile='sprites/'+e['artId']+'-r1.png',sha256=sha(OUT/'sprites'/f"{e['artId']}-r1.png"),preparation=corrections[e['artId']])
        im=dilate(im);im.save(OUT/file);atlases.append(dict(name=atlas,file=file,size=list(size),sha256=sha(OUT/file),assetId=None))
    manifest=dict(status='LOCAL ART CANDIDATES; no upload/runtime acceptance',revision=1,atlases=atlases,gutterPx=8,format='RGBA PNG straight alpha; RGB dilation with alpha-zero gutters; sRGB interpretation',entries=entries,patterns=PATTERNS,software={'Pillow':PIL_VERSION,'numpy':np.__version__},sourceHashes={p.name:sha(p) for p in sorted((OUT/'sources').glob('*.png'))},existingFrozenAtlases={str(p.relative_to(ROOT)):sha(p) for p in [ROOT/'assets/r32-proof-v3/power-state-map-proof-v3.png',ROOT/'assets/r37-settlements-v1/power-state-settlements-proof-v1.png']})
    (OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    contact(sprites);previews(sprites)
    print(json.dumps(atlases,indent=2))
if __name__=='__main__':main()

