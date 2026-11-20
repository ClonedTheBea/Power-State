"""Local-only geometric feasibility. Does not implement a Roblox coastline contract."""
from pathlib import Path
import json, hashlib, math
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy import ndimage

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/evidence/illustrated-world-v13'
OUT.mkdir(exist_ok=True)
fixtures=json.loads((ROOT/'assets/illustrated-world-v12a-ground/fixtures.json').read_text())
FONT=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',18)
SMALL=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',14)

def occupancy(f):
    e=np.array([s['elevationM'] for s in f['world']['samples']]).reshape(17,17)
    return e[:-1,:-1]>0,e

def round_corners(mask,elevation=None,anchors=()):
    """Only isolated 1/3-land corners, 16..24-unit radius; diagonals/borders frozen."""
    raw=np.repeat(np.repeat(mask,64,0),64,1); result=raw.copy(); changes=[]
    for y in range(1,mask.shape[0]):
        for x in range(1,mask.shape[1]):
            q=mask[y-1:y+1,x-1:x+1]; n=int(q.sum())
            if n not in (1,3): continue
            vx,vy=x*64,y*64
            if any(math.hypot(vx-a,vy-b)<80 for a,b in anchors): continue
            minority=n==1
            iy,ix=np.argwhere(q==minority)[0]
            # Quiet elevation-derived relief only, not a new ownership threshold.
            r=24 if elevation is None else 16+min(8,int(abs(elevation[y,x]))//15)
            sx,sy=(-1 if ix==0 else 1),(-1 if iy==0 else 1)
            for dy in range(r):
                for dx in range(r):
                    if (r-dx-.5)**2+(r-dy-.5)**2>r*r:
                        px=vx+dx if sx>0 else vx-1-dx
                        py=vy+dy if sy>0 else vy-1-dy
                        result[py,px]=not minority
            changes.append(dict(x=vx,y=vy,radius=r,minorityLand=minority))
    return raw,result,changes

def verify(raw,new,changes,anchors):
    record={}
    for diagonal in (False,True):
        st=np.ones((3,3)) if diagonal else ndimage.generate_binary_structure(2,1)
        for value in (False,True):
            a,na=ndimage.label(raw==value,st);b,nb=ndimage.label(new==value,st)
            assert na==nb,(value,diagonal,na,nb)
            # Every original component's cell centres remain in one unique component.
            old_centres=a[32::64,32::64];new_centres=b[32::64,32::64]
            mapped=[]
            for component in range(1,na+1):
                dest=np.unique(new_centres[old_centres==component]);assert len(dest)==1 and dest[0]>0
                mapped.append(int(dest[0]))
            assert len(set(mapped))==len(mapped)
            record[f'{"land" if value else "water"}_{8 if diagonal else 4}connected']=na
    assert np.array_equal(raw[0],new[0]) and np.array_equal(raw[-1],new[-1])
    assert np.array_equal(raw[:,0],new[:,0]) and np.array_equal(raw[:,-1],new[:,-1])
    for a,b in anchors:
        x,y=int(a),int(b)
        assert np.array_equal(raw[max(0,y-32):y+33,max(0,x-32):x+33],new[max(0,y-32):y+33,max(0,x-32):x+33])
    changed=raw!=new
    edge=raw!=ndimage.binary_erosion(raw)
    edge|=(~raw)!=ndimage.binary_erosion(~raw)
    distances=ndimage.distance_transform_edt(~edge)
    record.update(changedPixels=int(changed.sum()),roundedCorners=len(changes),
        measuredChangedPixelDistanceWu=float(distances[changed].max()) if changed.any() else 0,
        analyticBoundaryHausdorffBoundWu=24*(math.sqrt(2)-1),
        conservativeChangeBandWu=24,protectedAnchorCount=len(anchors))
    return record

def render(mask,anchors=(),links=()):
    h,w=mask.shape;yy,xx=np.indices((h,w))
    # Source-derived material for feasibility, not new finished/upload artwork.
    material=np.asarray(Image.open(ROOT/'assets/illustrated-world-v12a-ground/temperate-ground-v12a.png').convert('RGB').resize((256,256)))
    rgb=material[yy%256,xx%256].astype(float)
    sea=np.zeros_like(rgb);sea[:]=[24,53,70]
    rgb=np.where(mask[:,:,None],rgb,sea)
    distance=ndimage.distance_transform_edt(mask)
    shore=(distance>0)&(distance<4)
    rgb[shore]=.5*rgb[shore]+.5*np.array([158,155,120])
    im=Image.fromarray(np.uint8(np.clip(rgb,0,255)))
    draw=ImageDraw.Draw(im)
    for a,b in links: draw.line((a,b),fill='#58e5d6',width=3)
    for x,y in anchors: draw.ellipse((x-5,y-5,x+5,y+5),fill='#58e5d6',outline='white')
    return im

cases=[]
for i,f in enumerate(fixtures):
    mask,e=occupancy(f);anchors=[(n['x'],n['y']) for n in f['nodes']]
    cases.append((('normal-and-known-diagonal' if i==0 else 'maximum-78'),mask,e,anchors,f['world']['seed'],'actual exported descriptor'))
cases.append(('built-district',*cases[1][1:4],cases[1][4],'same actual descriptor; district anchor protected, no purchase'))
synthetic={
 'narrow-channel':['111111','110111','110111','110111','000000','000000'],
 'isolated-islands':['000000','011000','011000','000010','000000','000000'],
 'diagonal-contacts':['000000','010000','001000','000100','000000','000000'],
 'narrow-headland':['000000','001000','001000','111111','111111','111111'],
 'enclosed-water':['111111','110011','110011','111111','111111','111111']}
for name,rows in synthetic.items(): cases.append((name,np.array([[c=='1' for c in row] for row in rows]),None,[],None,'synthetic adversarial, not a generated country'))
reports=[];previews=[]
rejected=[]
for name,mask,e,anchors,seed,provenance in cases:
    raw,new,changes=round_corners(mask,e,anchors);r=verify(raw,new,changes,anchors)
    links=[]
    if e is not None:
        f=fixtures[0 if name=='normal-and-known-diagonal' else 1]
        nodes={n['id']:(n['x'],n['y']) for n in f['nodes']}
        for link in f['links']:
            a,b=nodes[link['from']],nodes[link['to']]
            x0,x1=sorted((a[0],b[0]));y0,y1=sorted((a[1],b[1]))
            assert np.array_equal(raw[y0-16:y1+17,x0-16:x1+17],new[y0-16:y1+17,x0-16:x1+17])
            if len(links)<2 or name=='built-district': links.append((a,b))
        r['protectedRouteCorridors']=3
    r.update(name=name,seed=seed,provenance=provenance);reports.append(r)
    before,after=render(raw,anchors,links),render(new,anchors,links)
    width,height=before.size
    sheet=Image.new('RGB',(width*2+48,height+90),'#0b1420');d=ImageDraw.Draw(sheet)
    d.text((16,8),name+' | LOCAL GEOMETRY STUDY - NOT STUDIO',font=FONT,fill='white')
    d.text((16,39),'Existing ownership boundary',font=SMALL,fill='white')
    d.text((width+32,39),'Constrained curves (proposal only)',font=SMALL,fill='white')
    sheet.paste(before,(16,66));sheet.paste(after,(width+32,66));sheet.save(OUT/(name+'-comparison.png'))
    previews.append(sheet)
    if e is not None:
        yy,xx=np.indices(raw.shape,dtype=float)
        contour=ndimage.map_coordinates(e.astype(float),[(yy+.5)/64,(xx+.5)/64],order=1,mode='nearest')>0
        def components(m): return [ndimage.label(m,ndimage.generate_binary_structure(2,1))[1],ndimage.label(~m,ndimage.generate_binary_structure(2,1))[1]]
        rejected.append(dict(name=name,changedPixels=int((raw!=contour).sum()),nativeLandWaterComponents=components(raw),contourLandWaterComponents=components(contour)))
        reject=Image.new('RGB',(2096,1114),'#0b1420');rd=ImageDraw.Draw(reject)
        rd.text((16,8),'REJECTED: direct bilinear elevation-zero contour changes NW ownership',font=FONT,fill='#ff9999')
        rd.text((16,39),'Existing',font=SMALL,fill='white');rd.text((1056,39),'Unconstrained elevation contour - NOT approved',font=SMALL,fill='white')
        reject.paste(before,(16,66));reject.paste(render(contour,anchors),(1056,66));reject.save(OUT/(name+'-rejected-contour.png'))
    if name=='normal-and-known-diagonal':
        close=Image.new('RGB',(800,430),'#0b1420');cd=ImageDraw.Draw(close)
        cd.text((10,8),'Known diagonal at (192,640): exact contact retained',font=FONT,fill='white')
        for j,img in enumerate((before,after)):close.paste(img.crop((128,576,256,704)).resize((384,384)),(j*400,40))
        close.save(OUT/'diagonal-detail.png')
    (OUT/(name+'-geometry.json')).write_text(json.dumps(dict(report=r,corners=changes),indent=2)+'\n')

# Exhaust all 512 3x3 masks at full one-world-unit resolution, including every saddle.
for bits in range(512):
    m=np.array([bool(bits&(1<<i)) for i in range(9)]).reshape(3,3)
    a,b,c=round_corners(m);verify(a,b,c,[])

contact=Image.new('RGB',(1200,math.ceil(len(previews)/2)*340+45),'#0b1420');d=ImageDraw.Draw(contact)
d.text((16,8),'Local geometric feasibility, source-derived ground; NOT artwork/Roblox acceptance',font=FONT,fill='white')
for i,im in enumerate(previews):
    im.thumbnail((590,325));contact.paste(im,(5+(i%2)*600,45+(i//2)*340))
contact.save(OUT/'coast-study-contact.png')
report=dict(status='PASS local constrained geometry only',exhaustive3x3Masks=512,cases=reports,
    sourceSha256=hashlib.sha256((ROOT/'assets/illustrated-world-v12a-ground/fixtures.json').read_bytes()).hexdigest(),
    rejectedUnconstrainedContours=rejected,
    boundaryContract='NW categorical mask; 16..24 radius isolated minority corner fillets; diagonal/border unchanged',
    limitation='Not unrestricted contour reconstruction. Most straight stair edges remain. No runtime geometry approval or integration.')
(OUT/'geometry-validation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
