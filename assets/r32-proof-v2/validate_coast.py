"""Local seam comparisons and preservation checks; no runtime or artwork painting."""
from pathlib import Path
import hashlib,json,math
from PIL import Image,ImageDraw,ImageFont

ROOT=Path(__file__).resolve().parent
OLD=ROOT.parent/'r32-proof-v1'
current=json.loads((ROOT/'manifest.json').read_text(encoding='utf-8'))
previous=json.loads((OLD/'manifest.json').read_text(encoding='utf-8'))
checks=[]
def check(name,condition):
    assert condition,name
    checks.append(name)
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def resize(im,size): return im.convert('RGBa').resize(size,Image.Resampling.LANCZOS).convert('RGBA')
for new,old in zip(current['sprites'],previous['sprites']):
    for key in ('sourceRect','cell','worldCanvasSize','pivotPx','groundAnchorWorld','visualBounds','renderOrder','fallbackPatchIds'):
        check(new['artId']+' unchanged '+key,new[key]==old[key])
    if new['artId']!='coast-headland':
        check(new['artId']+' original export bytes',digest(ROOT/new['exportFile'])==digest(OLD/old['exportFile']))
        check(new['artId']+' original source bytes',digest(ROOT/new['sourceFile'])==digest(OLD/old['sourceFile']))

S=4
def world_sprite(folder):
    im=Image.new('RGBA',(1200*S,800*S))
    sprite=Image.open(folder/'sprites/coast-headland.png')
    im.alpha_composite(resize(sprite,(248*S,248*S)),(374,954)) # exact 93.5,238.5
    return im
def boundary(y):
    cy=365 # capsule's western semicircle centre
    return 350-math.sqrt(175**2-(y-cy)**2)
native=(107,132,99)
def error(im):
    # Fixed central join probe; not a perceptual or whole-coast acceptance metric.
    values=[]
    for y in range(340,386):
        x=boundary(y)-2
        pixel=im.getpixel((round(x*S),y*S))
        check('No transparent hole at central join probe '+str(y),pixel[3]>0)
        # Compare displayed colour over ocean, including the preserved source alpha.
        rgb=[pixel[i]*pixel[3]/255+(43,83,92)[i]*(1-pixel[3]/255) for i in range(3)]
        values.append(sum(abs(rgb[i]-native[i]) for i in range(3))/3)
    return sum(values)/len(values)
old_sprite=world_sprite(OLD); new_sprite=world_sprite(ROOT)
old_error=error(old_sprite); new_error=error(new_sprite)
check('Central seam colour error reduced',new_error<old_error)

join_records=[]
for y in (299,429):
    x=boundary(y)
    # Interior band starts 1 world unit past native boundary, spans 16 world units.
    alphas=[new_sprite.getpixel((round((x+1+i/4)*S),y*S))[3] for i in range(65)]
    tangent=((y-365)/175,math.sqrt(175**2-(y-365)**2)/175)
    join_records.append(dict(worldPoint=[x,y],localWorldPoint=[x-93.5,y-238.5],
        nativeNorthToSouthTangent=list(tangent),testedOverlapWorldUnits=16,minimumAlpha=min(alphas),strictOpaqueOverlapPass=min(alphas)==255,
        status='Measured native-boundary probe, not artist-approved cliff tangent'))

# Detect internal zero-alpha holes in the fully inland rectangular sample.
a=Image.open(ROOT/'sprites/coast-headland.png').getchannel('A')
inland_alpha=a.crop((220,170,460,320)).getextrema()
check('No zero-alpha holes in inland content sample x220..460 y170..320',inland_alpha[0]>0)

def composite(sprite,bg):
    base=Image.new('RGBA',sprite.size,bg)
    base.alpha_composite(sprite)
    # Same pass order as approved plan, antialiased through 4x proxy sampling.
    ImageDraw.Draw(base).rounded_rectangle((700,760,2380,2160),radius=700,fill='#6B8463')
    return base.crop((70*S,220*S,410*S,500*S))
font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',18)
sheet=Image.new('RGBA',(1440,1900),'#17232C'); d=ImageDraw.Draw(sheet)
d.text((20,10),'R3.2a / native coast proxy: before (left) and refined (right)',font=font,fill='white')
d.text((20,38),'Exact pivot + shore-before-meadow order. Local proxy only; no Studio integration.',font=font,fill='white')
for n,z in enumerate((.55,.72,1,1.2,1.8)):
    y=80+n*360
    for col,sp in enumerate((old_sprite,new_sprite)):
        im=resize(composite(sp,'#2B535C'),(round(340*z),round(280*z)))
        # Upper zoom 1.8 uses 504px height; place final row below other rows.
        sheet.alpha_composite(im,(20+col*720,y+28))
        d.text((20+col*720,y),f'{"Before" if col==0 else "Refined"} / zoom {z}',font=font,fill='white')
# Expand canvas so final 1.8 image is not clipped.
expanded=Image.new('RGBA',(1440,2100),'#17232C'); expanded.alpha_composite(sheet)
for col,sp in enumerate((old_sprite,new_sprite)):
    expanded.alpha_composite(resize(composite(sp,'#2B535C'),(612,504)),(20+col*720,1548))
expanded.save(ROOT/'coast-comparison-zooms.png')
pair=Image.new('RGBA',(1380,600),'#17232C'); pd=ImageDraw.Draw(pair)
for i,sp in enumerate((old_sprite,new_sprite)):
    pair.alpha_composite(resize(composite(sp,'#2B535C'),(680,560)),(i*690,40))
    pd.text((i*690+12,8),'Before' if i==0 else 'Refined — local review candidate',font=font,fill='white')
pair.save(ROOT/'coast-before-after.png')
# Standalone coast on both representative backgrounds at every supported test zoom.
bg_sheet=Image.new('RGBA',(1200,1700),'#17232C'); bd=ImageDraw.Draw(bg_sheet)
for n,z in enumerate((.55,.72,1,1.2,1.8)):
    y=[0,200,440,740,1110][n]
    for col,bg in enumerate(('#6B8463','#2B535C')):
        size=round(248*z); tile=Image.new('RGBA',(size,size),bg)
        tile.alpha_composite(resize(Image.open(ROOT/'sprites/coast-headland.png'),(size,size)))
        bg_sheet.alpha_composite(tile,(20+col*600,y+40))
        bd.text((20+col*600,y+8),f'Coast / zoom {z} / {bg}',font=font,fill='white')
bg_sheet.save(ROOT/'coast-background-zooms.png')
result=dict(passed=len(checks),checks=checks,centralJoinProbe=dict(beforeMeanRgbAbsoluteError=old_error,
    refinedMeanRgbAbsoluteError=new_error,reductionPercent=100*(1-new_error/old_error),
    definition='Mean absolute RGB channel distance to native sage; 46 points, y340..385, 2 world units outside native boundary; 4x local proxy; not perceptual acceptance'),
    joins=join_records,inlandAlphaRange=list(inland_alpha),strictOpaqueInteriorPass=inland_alpha==(255,255),
    ownerAcceptance='Pending for refined coast',runtimeValidation='Not run')
(ROOT/'coast-validation-results.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:result[k] for k in ('passed','centralJoinProbe','joins')}))
