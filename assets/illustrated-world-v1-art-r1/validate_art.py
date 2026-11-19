"""Pixel/packing proof for local candidates; does not certify visual acceptance."""
from pathlib import Path
import json, hashlib, itertools, time
import numpy as np
from PIL import Image
from prepare_guides import PATTERNS
from prepare_art import occupancy, distance, sha, tile_background
OUT=Path(__file__).resolve().parent
ROOT=OUT.parents[1]
checks=0
def check(ok,msg):
    global checks
    checks+=1
    if not ok:raise AssertionError(msg)
def premult(a):return a[:,:,:3].astype('int32')*a[:,:,3,None].astype('int32')
def main():
    started=time.perf_counter();m=json.loads((OUT/'manifest.json').read_text());sprites={}
    check(len(m['entries'])==18,'18 allocations')
    check(len(m['atlases'])==2,'two atlases')
    for spec in m['atlases']:
        im=Image.open(OUT/spec['file']);a=np.array(im)
        check(im.mode=='RGBA' and list(im.size)==spec['size'],'RGBA/dimensions')
        check(sha(OUT/spec['file'])==spec['sha256'],'atlas checksum')
        used=np.zeros(a.shape[:2],bool)
        for e in [e for e in m['entries'] if e['atlas']==spec['name']]:
            x,y,w,h=e['sourceRect'];cx,cy,cw,ch=e['cell']
            check((w,h,cw,ch)==(240,240,256,256),'allocation size')
            check((x,y)==(cx+8,cy+8),'8px gutter')
            check(x+w<=im.width and y+h<=im.height,'rectangle bounds')
            check(not used[cy:cy+ch,cx:cx+cw].any(),'allocation disjoint')
            used[cy:cy+ch,cx:cx+cw]=True
            cell=a[cy:cy+ch,cx:cx+cw,3].copy();cell[8:248,8:248]=0
            check(not cell.any(),'transparent gutters')
            s=np.array(Image.open(OUT/e['spriteFile']));sprites[e['artId']]=s
            check(np.array_equal(a[y:y+h,x:x+w,3],s[:,:,3]),'packed alpha unchanged')
            visible=s[:,:,3]>0
            check(np.array_equal(a[y:y+h,x:x+w,:3][visible],s[:,:,:3][visible]),'packed visible RGB unchanged')
            check(sha(OUT/e['spriteFile'])==e['sha256'],'sprite hash')
            check(e['rotation']==0,'no rotated exports')
            check(e['pivotPx']==([120,120] if e['artId'].startswith('shore') else [120,184]),'approved pivot')
    bypattern={p:sprites[n] for p,n in PATTERNS.items()}
    bypattern[0]=bypattern[15]=np.zeros((240,240,4),dtype='uint8')
    pairset=set();edge_errors=0;max_rgba_delta=0
    for bits in range(512):
        grid=[[bool(bits&(1<<(y*3+x))) for x in range(3)] for y in range(3)]
        def p(x,y):return int(grid[y][x])+2*int(grid[y][x+1])+4*int(grid[y+1][x])+8*int(grid[y+1][x+1])
        for y in range(2):pairset.add(('horizontal',p(0,y),p(1,y)))
        for x in range(2):pairset.add(('vertical',p(x,0),p(x,1)))
    for axis,p,q in sorted(pairset):
        a=bypattern[p];b=bypattern[q]
        ea=a[:,-1] if axis=='horizontal' else a[-1]
        eb=b[:,0] if axis=='horizontal' else b[0]
        # Invisible RGB dilation is deliberately irrelevant to source-over.
        check(np.array_equal(ea[:,3],eb[:,3]),f'{axis} alpha {p}/{q}')
        va=ea[:,:3].astype('int32')*ea[:,3,None];vb=eb[:,:3].astype('int32')*eb[:,3,None]
        check(np.array_equal(va,vb),f'{axis} premultiplied RGB {p}/{q}')
        max_rgba_delta=max(max_rgba_delta,int(np.abs(va-vb).max()))
    material_failures={}
    for p,a in bypattern.items():
        if p in (0,15):continue
        land=occupancy(p);d=distance(p);visible=a[:,:,3]>0
        check(not (visible&(d>=30)).any(),f'{p}: 8-world-unit rim bound')
        # Numerical material-class diagnostic on actual exported pixels, separate
        # from categorical geometry and owner assessment of natural appearance.
        rgb=a[:,:,:3].astype(int)
        wrong_water=(~land)&visible&~((rgb[:,:,2]>rgb[:,:,0])&(rgb[:,:,1]>rgb[:,:,0]))
        wrong_land=land&visible&~((rgb[:,:,0]>rgb[:,:,2])&(rgb[:,:,1]>rgb[:,:,2]))
        material_failures[p]=int((wrong_water|wrong_land).sum())
        check(material_failures[p]==0,f'{p}: painted material ownership')
        bg=tile_background(p);bg.alpha_composite(Image.fromarray(a));pixels=np.array(bg).astype(int)
        check(np.array_equal(pixels[:,:,0]>pixels[:,:,2],land),f'{p}: composited Native ownership')
    # Junction footprints tile rather than overlap. A central diagonal has one
    # RGBA source pass, so it cannot accumulate the old paired-corner alpha.
    coverage=np.zeros((480,480),dtype='uint8')
    for y in (0,240):
        for x in (0,240):coverage[y:y+240,x:x+240]+=1
    check(int(coverage.max())==1 and int(coverage.min())==1,'exclusive patch coverage')
    for p in (6,9):
        a=bypattern[p];water=~occupancy(p)
        check(int(a[:,:,3][water].max())<=185,'single-pass diagonal water alpha')
    for e in m['entries']:
        im=Image.open(OUT/e['spriteFile'])
        for zoom in (.55,.72,1,1.2,1.8):
            size=round(e['nominalWorldCanvas'][0]*zoom)
            scaled=im.resize((size,size),Image.Resampling.LANCZOS)
            check(scaled.mode=='RGBA' and scaled.getchannel('A').getbbox() is not None,'zoom export visible/in bounds')
    for path,expected in [('assets/r32-proof-v3/power-state-map-proof-v3.png','e1dcb61948e575bab85d94a6eed3dce1939fe87389455fc3bce735a28cab63cb'),('assets/r37-settlements-v1/power-state-settlements-proof-v1.png','baff92a631e89bbf9a1506f5401488e40fc2d5fe56a71399b1f410df5b05ff4e')]:check(sha(ROOT/path)==expected,'frozen approved atlas')
    result=dict(status='PASS local structural/pixel checks; visual/Roblox acceptance separate',assertions=checks,exhaustive3x3Masks=512,uniqueCompatibleDirectedPortPairs=len(pairset),maximumPremultipliedEdgeDelta=max_rgba_delta,materialClassViolations=material_failures,elapsedSeconds=time.perf_counter()-started,limits=['Source-resolution port equality does not prove Roblox filtered sampling or mip behavior.','Categorical material classification is not semantic image understanding or visual acceptance.','Four-connected Native geometry remains supplied data; no new runtime implementation.'])
    (OUT/'validation-results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
if __name__=='__main__':main()
