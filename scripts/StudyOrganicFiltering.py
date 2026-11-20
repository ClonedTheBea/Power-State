"""v1.4a bounded reference study, NOT a Roblox renderer or acceptance pass.

Two candidate families only: conservative inset alpha; supersampled area alpha.
Current cropped cells span 64 world units with rounded integer screen edges.
All possible cell width/height outcomes cover fractional translation phases.
We test pixels fully inside a quarter-circle patch; counterexamples suffice to
reject a global bound, but reported maxima are not whole-map global maxima.
"""
from pathlib import Path
import hashlib
import json
import math
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'docs/evidence/illustrated-world-v14a'
ZOOMS = [.55, .6, .72, .837, .937, 1, 1.2, 1.337, 1.8]

def raster(radius, kind, parameter):
    # One-unit gutters; centre and subpixel coordinates are world aligned.
    q = np.arange(-1, 65, dtype=float)
    x, y = np.meshgrid(q, q)
    if kind == 'inset-alpha':
        distance = np.hypot(x+.5-radius, y+.5-radius)-radius
        alpha = np.clip(.5-distance-parameter, 0, 1)
    else:
        alpha = np.zeros((66, 66))
        for sy in range(parameter):
            for sx in range(parameter):
                alpha += np.hypot(x+(sx+.5)/parameter-radius,
                                  y+(sy+.5)/parameter-radius) <= radius
        alpha /= parameter**2
    return np.floor(alpha*255+.5)/255

def display(source, width, height):
    x = (np.arange(width)+.5)*64/width+.5
    y = (np.arange(height)+.5)*64/height+.5
    ix, iy = np.floor(x).astype(int), np.floor(y).astype(int)
    u, v = x-ix, y-iy
    result = ((source[iy[:,None],ix]*(1-u)+source[iy[:,None],ix+1]*u)*(1-v[:,None])
              +(source[iy[:,None]+1,ix]*(1-u)+source[iy[:,None]+1,ix+1]*u)*v[:,None])
    # Model framebuffer quantization, not a chosen visibility threshold.
    return np.floor(result*255+.5)

def distances(radius, width, height):
    x0,y0=np.meshgrid(np.arange(width)*64/width,np.arange(height)*64/height)
    x1,y1=x0+64/width,y0+64/height
    valid=(x1<=radius)&(y1<=radius)
    near=np.hypot(radius-x1,radius-y1)-radius
    far=np.hypot(radius-x0,radius-y0)-radius
    return valid,near,far

def main():
    OUT.mkdir(exist_ok=True)
    variants=[('inset-alpha',v) for v in [0,.25,.5,.75,1]]+[('supersampled',v) for v in [4,8]]
    summaries=[];lower={'value':0};cases=0
    for kind,parameter in variants:
        worst={'value':0};failures=0
        for r in range(16,25):
            source=raster(r,kind,parameter)
            for z in ZOOMS:
                sizes=sorted({math.floor(64*z),math.ceil(64*z)})
                for w in sizes:
                    for h in sizes:
                        valid,near,far=distances(r,w,h)
                        alpha=display(source,w,h)
                        outward=float(np.max(np.where(valid&(alpha>0),far,0)))
                        inward=float(np.max(np.where(valid&(alpha<255),-near,0)))
                        value=max(outward,inward)
                        failures+=value>1;cases+=1
                        if value>worst['value']:
                            worst=dict(value=value,radius=r,zoom=z,width=w,height=h,
                                       outward=outward,inward=inward)
                        bound=np.where(valid,np.minimum(far,-near),0)
                        yy,xx=np.unravel_index(np.argmax(bound),bound.shape)
                        if bound[yy,xx]>lower['value']:
                            lower=dict(value=float(bound[yy,xx]),radius=r,zoom=z,width=w,height=h,
                                       pixel=[int(xx),int(yy)],nearest=float(near[yy,xx]),farthest=float(far[yy,xx]))
                        # Four orientations and land/water complement are exact
                        # reflection/complement symmetries, checked numerically.
                        for orient in range(4):
                            transformed=np.rot90(alpha,orient)
                            ow,oh=(h,w) if orient%2 else (w,h)
                            rotated=display(np.rot90(source,orient),ow,oh)
                            complemented=display(1-np.rot90(source,orient),ow,oh)
                            # Quantizing a half-level tie in opposite directions
                            # can differ by one byte; this is not an opacity cutoff.
                            assert np.max(np.abs(rotated-transformed))<=1
                            assert np.max(np.abs(complemented-(255-transformed)))<=1
        summaries.append(dict(candidate=kind,parameter=parameter,failingRasterCases=failures,worstLocalFootprintWU=worst))
    # Use the *actual* v1.4 minimum-zoom PNG's cell and one indivisible pixel.
    path=ROOT/'docs/evidence/illustrated-world-v14/filter-r17-055-nearest.png'
    im=Image.open(path).convert('RGB')
    # Cell x=683,y=427; screenshot y offset58; 36x36 extent.
    # Pixel712,485 corresponds to reflected local quarter-patch pixel6,0.
    near=math.hypot(17-7*64/36,17-64/36)-17
    far=math.hypot(17-6*64/36,17)-17
    witness=dict(image=str(path.relative_to(ROOT)),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                 pngPixel=[712,485],rgb=im.getpixel((712,485)),radius=17,width=36,height=36,
                 signedDistanceRangeWU=[near,far],unavoidableBestBinaryErrorWU=min(-near,far))
    assert near < -1 and far > 1
    assert all(s['failingRasterCases']>0 for s in summaries)
    record=dict(status='Neither candidate passes; no runtime correction',
                convention='Any nonzero land/water contribution occupies its full displayed pixel; both sides constrained',
                referenceOnly=True,zooms=ZOOMS,radii=list(range(16,25)),rasterCases=cases,
                orientationComplementChecks=cases*8,candidates=summaries,
                sampledUnavoidableLowerBound=lower,retainedActualPixelWitness=witness,
                limitations=['Local quarter-circle interior only; not global worst-case',
                             'Reference bilinear RGBA model, not new Roblox candidate measurements',
                             'No full geography, channel, crop, protected-site or engine acceptance claimed'])
    (OUT/'filter-study.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(record,indent=2))

if __name__=='__main__':
    main()
