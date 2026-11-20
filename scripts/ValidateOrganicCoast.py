"""v1.4 independent geometry gate; never changes saved terrain or historical evidence."""
from pathlib import Path
import importlib.util, json, math, time, sys
import numpy as np
from scipy import ndimage
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'docs/evidence/illustrated-world-v14'
OUT.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('grammar',ROOT/'assets/illustrated-world-v1-art-r1/validate_grammar.py')
g=importlib.util.module_from_spec(s);s.loader.exec_module(g)

def records(mask,e=None,anchors=(),boxes=(),radius=None):
    result=[]
    for y in range(1,len(mask)):
        for x in range(1,len(mask[0])):
            q=mask[y-1:y+1,x-1:x+1];n=int(q.sum())
            if n not in (1,3):continue
            vx,vy=x*64,y*64
            if any((vx-a)**2+(vy-b)**2<80**2 for a,b in anchors):continue
            r=radius or 16+min(8,int(abs(e[y,x]))//15)
            iy,ix=np.argwhere(q==(n==1))[0];sx,sy=2*ix-1,2*iy-1
            x0,x1=sorted((vx,vx+sx*r));y0,y1=sorted((vy,vy+sy*r))
            if any(x0<=b[2] and x1>=b[0] and y0<=b[3] and y1>=b[1] for b in boxes):continue
            result.append((vx,vy,r,int(sx),int(sy),n==1))
    return result

def raster(mask,corners,scale=1):
    raw=np.repeat(np.repeat(mask,64//scale,0),64//scale,1);new=raw.copy()
    for vx,vy,r,sx,sy,minority in corners:
        for dy in range(math.ceil(r/scale)):
            for dx in range(math.ceil(r/scale)):
                a,b=(dx+.5)*scale,(dy+.5)*scale
                if a<r and b<r and (r-a)**2+(r-b)**2>r*r:
                    px=vx//scale+dx if sx>0 else vx//scale-1-dx
                    py=vy//scale+dy if sy>0 else vy//scale-1-dy
                    new[py,px]=not minority
    return raw,new

def verify(raw,new,cell):
    assert np.array_equal(raw[0],new[0]) and np.array_equal(raw[-1],new[-1])
    assert np.array_equal(raw[:,0],new[:,0]) and np.array_equal(raw[:,-1],new[:,-1])
    for diagonal in (False,True):
        st=np.ones((3,3)) if diagonal else ndimage.generate_binary_structure(2,1)
        for value in (False,True):
            a,na=ndimage.label(raw==value,st);b,nb=ndimage.label(new==value,st)
            assert na==nb,(value,diagonal,na,nb)
            ac=a[cell//2::cell,cell//2::cell];bc=b[cell//2::cell,cell//2::cell]
            mapped=[]
            for c in range(1,na+1):
                target=np.unique(bc[ac==c]);assert len(target)==1 and target[0]>0
                mapped.append(int(target[0]))
            assert len(set(mapped))==len(mapped)

def main():
    start=time.perf_counter();count=0
    # Every supported integer radius, not only the previous study's radius24.
    for bits in range(512):
        mask=np.array([bool(bits&(1<<i)) for i in range(9)]).reshape(3,3)
        for radius in range(16,25):
            raw,new=raster(mask,records(mask,radius=radius));verify(raw,new,64);count+=1
    print('PASS',count,'full-resolution local mask/radius combinations',flush=True)
    maximum=0;corners=0
    for i in range(1,10001):
        seed=''.join(f'{g.fnv(f"seed-{tag}:{i}".encode()):08x}' for tag in 'abcd')
        base=g.base(bytes.fromhex(seed))
        for rotation in range(4):
            e=np.array(g.descriptor(base,rotation)).reshape(17,17);mask=e[:-1,:-1]>0
            anchors=[g.rotate(x,y,rotation) for x,y in ((320,512),(512,512),(704,512),(704,704))]
            boxes=[(x-32,y-32,x+32,y+32) for x,y in anchors]
            for a,b in zip(anchors,anchors[1:]):boxes.append((min(a[0],b[0])-16,min(a[1],b[1])-16,max(a[0],b[0])+16,max(a[1],b[1])+16))
            c=records(mask,e,anchors,boxes);maximum=max(maximum,len(c));corners+=len(c)
            # Corpus component graph at 8WU. Full1WU local rewrite and disjoint
            # supports above establish its finer topology; no filtering claim.
            raw,new=raster(mask,c,8);verify(raw,new,8)
            for x,y in anchors:
                assert np.array_equal(raw[(y-32)//8:(y+32)//8+1,(x-32)//8:(x+32)//8+1],new[(y-32)//8:(y+32)//8+1,(x-32)//8:(x+32)//8+1])
        if i%1000==0:print(i,flush=True)
    report=dict(status='PASS local independent geometry gate; not Luau/Studio/filtering acceptance',fullResolutionLocalCombinations=count,seeds=10000,rotations=4,corpusRasterWorldUnits=8,acceptedCorners=corners,maximumCorners=maximum,analyticDeviation=24*(math.sqrt(2)-1),seconds=time.perf_counter()-start)
    (OUT/'geometry-corpus.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report),flush=True)
if __name__=='__main__':main()
