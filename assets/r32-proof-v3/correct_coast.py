"""Owner-authorized R3.2b local raster correction; no generation or runtime changes.
Operate at the approved content resolution; never crop, rotate, or move the art.
"""
from pathlib import Path
import math,json,hashlib
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parent
OLD=ROOT.parent/'r32-proof-v2'
src=Image.open(OLD/'sprites/coast-headland.png').convert('RGBA')
out=src.copy(); mask=Image.new('L',src.size); protected=Image.new('L',src.size)
native=(107,132,99)
def edge(y): return 350-math.sqrt(175**2-(y-365)**2)
def smooth(t):
    t=max(0,min(1,t)); return t*t*(3-2*t)
changed=0; preserved=0
for py in range(496):
    wy=238.5+(py+.5)/2
    bx=edge(wy)
    for px in range(496):
        wx=93.5+(px+.5)/2; distance=wx-bx
        r,g,b,a=src.getpixel((px,py))
        # Conservative grass chroma selection. Neutral rock and teal water remain
        # untouched outside native meadow; all retained inputs are archived.
        grass=a>=240 and g-r>=5 and g-b>=8
        value=(r,g,b,a)
        if grass and distance>=-30:
            weight=smooth((distance+30)/26) # exact native colour from -4 units inland
            value=tuple(round(v*(1-weight)+n*weight) for v,n in zip((r,g,b),native))+(255,)
        # Fill exclusively below existing native meadow. Quarter-unit coverage
        # ramp follows its silhouette; 4-unit vertical feather is fully occluded.
        # This creates no new exterior shore and does not displace existing rocks.
        inside=smooth(distance/.25)
        vertical=smooth((wy-289)/4)*smooth((439-wy)/4)
        right=smooth((488-px)/4)
        coverage=inside*vertical*right
        if coverage>0:
            alpha=round(255*coverage)
            # Source-over of the correction grass, deliberately opaque on plateau.
            t=alpha/255
            result_alpha=alpha+value[3]*(1-t)
            if result_alpha:
                value=tuple(round((native[i]*alpha+value[i]*value[3]*(1-t))/result_alpha) for i in range(3))+(round(result_alpha),)
        out.putpixel((px,py),value)
        if value!=src.getpixel((px,py)):
            changed+=1; mask.putpixel((px,py),255)
        elif distance<0 and not grass and a>0:
            protected.putpixel((px,py),255); preserved+=1
out.save(ROOT/'sources/coast-corrected-content.png',icc_profile=src.info.get('icc_profile'))
mask.save(ROOT/'correction-mask.png');protected.save(ROOT/'preserved-coastal-pixels.png')
record=dict(authorization='R3.2b user request explicitly authorizes local raster compositing',
    input='../r32-proof-v2/sprites/coast-headland.png',inputSha256=hashlib.sha256((OLD/'sprites/coast-headland.png').read_bytes()).hexdigest(),
    method='Pillow deterministic fixed-canvas grass-only smoothstep blend plus occluded inland source-over fill',
    nativeColour=list(native),worldOrigin=[93.5,238.5],worldUnitsPerPixel=.5,
    nativeBoundary='x=350-sqrt(175^2-(y-365)^2)',grassCriteria='alpha>=240, G-R>=5, G-B>=8',
    blendWorldDistance=[-30,-4],fillWorldY=[289,439],fillFullyOpaqueWorldY=[293,435],
    fillFullyOpaqueDistanceInside=.25,changedContentPixels=changed,preservedNonGrassExteriorPixels=preserved,
    alphaChange='Grass corrected to 255; new coverage only under existing native meadow; exterior non-grass alpha preserved',
    geometryChange=False,artRevision=3,ownerVisualAcceptance='Pending',newGeneratedArtwork=False)
(ROOT/'correction-record.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
print(json.dumps(record))
