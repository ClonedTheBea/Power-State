"""Stage A diagnostic only. No finished artwork or Roblox/runtime mutation.

Reuses the existing independent integer reference, checks the full stored golden
sector, then inspects the exact 10,000-seed test corpus plus all four reservations.
"""
from pathlib import Path
import sys, re, json, hashlib, time
from collections import Counter
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
from ValidateP2bClimate import fnv, keyed, field, smooth, lerp
from PIL import Image, ImageDraw, ImageFont
OUT = Path(__file__).resolve().parent
FONT = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 18)
SMALL = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', 14)
LAND, WATER, INK = '#6b8463', '#112a3c', '#edf4f8'
# NW, NE, SW, SE. Homogeneous vertices need no shoreline sprite.
STRAIGHT = {3:'shore-s', 12:'shore-n', 5:'shore-e', 10:'shore-w'}
CONVEX = {1:'convex-SE', 2:'convex-SW', 4:'convex-NE', 8:'convex-NW'}
CONCAVE = {14:'concave-NW', 13:'concave-NE', 11:'concave-SW', 7:'concave-SE'}
DIRECT = {0:'water', 15:'land', **STRAIGHT, **CONVEX, **CONCAVE}

def pattern(a,b,c,d): return int(a)+2*int(b)+4*int(c)+8*int(d)
def vertices(mask):
    return [(x,y,pattern(mask[y-1][x-1],mask[y-1][x],mask[y][x-1],mask[y][x]))
            for y in range(1,len(mask)) for x in range(1,len(mask[0]))]
def rotate(x,y,r):
    for _ in range(r): x,y=1024-y,x
    return x,y
def weight(x,y,r):
    x,y=rotate(x,y,(-r)%4)
    distance=min(max(a-x,0,x-c,b-y,0,y-d) for a,b,c,d in
                 [(-128,448,1152,576),(256,448,384,768),(640,448,768,768)])
    return 4096-smooth(max(0,min(4096,distance*4096//64)))
WEIGHTS = [[weight(x,y,r) for y in range(0,1025,64) for x in range(0,1025,64)] for r in range(4)]
def base(seed):
    return [60+field(seed,'elevation-coarse',x,y,512,-160,160)+field(seed,'elevation-fine',x,y,128,-40,40)
            for y in range(0,1025,64) for x in range(0,1025,64)]
def descriptor(values,r): return [lerp(e,40,w) for e,w in zip(values,WEIGHTS[r])]
def native_mask(values):
    # Matches GeneratedTerrain exactly: NW of each 64-square cell, not bilinear sign.
    return [[values[y*17+x]>0 for x in range(16)] for y in range(16)]
def draw_mask(draw,mask,x,y,cell=22):
    for row,line in enumerate(mask):
        for col,value in enumerate(line):
            draw.rectangle((x+col*cell,y+row*cell,x+(col+1)*cell-1,y+(row+1)*cell-1),fill=LAND if value else WATER)
    for vx,vy,p in vertices(mask):
        if p in (6,9):
            xx,yy=x+vx*cell,y+vy*cell
            draw.ellipse((xx-4,yy-4,xx+4,yy+4),outline='#ff7777',width=2)

def sheets(examples):
    im=Image.new('RGB',(1200,880),'#0b1420');d=ImageDraw.Draw(im)
    d.text((20,12),'STAGE A: topology diagnostics only — NOT finished artwork or Studio evidence',font=FONT,fill=INK)
    for p in range(16):
        x=20+(p%4)*295;y=65+(p//4)*200
        mask=[[bool(p&1),bool(p&2)],[bool(p&4),bool(p&8)]]
        draw_mask(d,mask,x,y,65)
        d.text((x,y+136),f'{p:02d}  '+DIRECT.get(p,'DIAGONAL: paired corners'),font=SMALL,fill='#ff9999' if p in (6,9) else INK)
        d.text((x,y+157),'bits NW,NE,SW,SE = '+''.join('1' if p&(1<<i) else '0' for i in range(4)),font=SMALL,fill=INK)
    im.save(OUT/'grammar-16-patterns.png')
    arrangements={
        'One-cell headland': ['00000','00100','00100','11111','11111'],
        'One-cell inlet':['11111','11011','11011','00000','00000'],
        'Isolated island':['00000','00000','00100','00000','00000'],
        'Isolated lake':['11111','11111','11011','11111','11111'],
        'Diagonal land contacts':['00000','01000','00100','00010','00000'],
        'Checkerboard':['10101','01010','10101','01010','10101'],
        'Stair coastline':['10000','11000','11100','11110','11111'],
        'Disconnected components':['11000','11000','00000','00011','00011']}
    im=Image.new('RGB',(1200,650),'#0b1420');d=ImageDraw.Draw(im)
    d.text((20,12),'Adversarial arrangements — exact Native masks; red marks diagonal contacts',font=FONT,fill=INK)
    for i,(name,rows) in enumerate(arrangements.items()):
        x=20+(i%4)*295;y=65+(i//4)*280
        draw_mask(d,[[v=='1' for v in row] for row in rows],x,y,40)
        d.text((x,y+211),name,font=SMALL,fill=INK)
    im.save(OUT/'adversarial-arrangements.png')
    im=Image.new('RGB',(1200,950),'#0b1420');d=ImageDraw.Draw(im)
    d.text((20,12),'Accepted-corpus reference masks — not engine renders; red = diagonal junction',font=FONT,fill=INK)
    for i,e in enumerate(examples[:6]):
        x=20+(i%3)*395;y=65+(i//3)*435
        draw_mask(d,e['mask'],x,y,22)
        d.text((x,y+359),f"Corpus {e['index']} / natural rotation {e['rotation']}",font=SMALL,fill=INK)
        d.text((x,y+380),e['seed'],font=SMALL,fill=INK)
    im.save(OUT/'corpus-mask-contact-sheet.png')
    # Nearest-neighbour preserves categorical occupancy. This is an exact-mask
    # diagnostic, not a claim about Roblox's filtered artwork sampling.
    im=Image.new('RGB',(1200,820),'#0b1420');d=ImageDraw.Draw(im)
    d.text((20,12),'Actual-size mask checks at five zooms — schematic, not painted-art readability',font=FONT,fill=INK)
    for row,p in enumerate((6,9)):
        tile=Image.new('RGB',(64,64));td=ImageDraw.Draw(tile)
        for q in range(4):
            x=(q%2)*32;y=(q//2)*32
            td.rectangle((x,y,x+31,y+31),fill=LAND if p&(1<<q) else WATER)
        for col,z in enumerate((.55,.72,1,1.2,1.8)):
            x=25+col*235;y=75+row*210;size=round(64*z)
            im.paste(tile.resize((size,size),Image.Resampling.NEAREST),(x,y))
            d.text((x,y+130),f'mask {p}, zoom {z:g}, {size}px',font=SMALL,fill=INK)
    d.text((20,520),'No new painted sprites exist yet. Alpha/halos/colour/readability acceptance remains blocked.',font=FONT,fill=INK)
    d.text((20,555),'Native land occupancy stays orthogonal. Shading can soften its appearance, not change topology.',font=FONT,fill=INK)
    im.save(OUT/'five-zoom-mask-check.png')

def overlap_diagnostic():
    # Paired convex NW/SE land quadrants. Water-side 8-unit bands overlap in
    # the two water quadrants. A native land/water clip cannot separate them.
    n=240;c=n//2;rim=30;overlap=0;wrong_land=0
    im=Image.new('RGB',(1000,430),'#0b1420');d=ImageDraw.Draw(im)
    d.text((16,12),'Paired convex corner diagnostic: 64-world-unit canvas; 8-unit water bands',font=FONT,fill=INK)
    a=Image.new('RGB',(n,n));b=Image.new('RGB',(n,n));ap=a.load();bp=b.load()
    for y in range(n):
        for x in range(n):
            px=x+.5-c;py=y+.5-c
            land=(px<0 and py<0) or (px>0 and py>0)
            nw=max(px,0)**2+max(py,0)**2<=rim**2
            se=max(-px,0)**2+max(-py,0)**2<=rim**2
            nw=nw and not land;se=se and not land
            overlap+=nw and se
            ap[x,y]=(107,132,99) if land else (242,80,110) if nw and se else (65,165,190) if nw or se else (17,42,60)
            wrong_land += (ap[x,y] == (107,132,99)) != land
            # Under a homogeneous alpha=.5 test strip source-over overlap is .75.
            alpha=1-(1-.5*int(nw))*(1-.5*int(se))
            bp[x,y]=(107,132,99) if land else tuple(round(v*(1-alpha)+w*alpha) for v,w in zip((17,42,60),(180,210,215)))
    im.paste(a,(20,70));im.paste(b,(350,70))
    d.text((20,325),'Pink: two water passes own the same pixels',font=SMALL,fill=INK)
    d.text((350,348),'Alpha test: 0.50 becomes 0.75 at overlap',font=SMALL,fill=INK)
    d.text((620,90),'Land mask stays unchanged.',font=FONT,fill=INK)
    d.text((620,125),'Mask clipping alone does not',font=FONT,fill=INK)
    d.text((620,155),'define which water pass owns',font=FONT,fill=INK)
    d.text((620,185),'the shared diagonal junction.',font=FONT,fill=INK)
    im.save(OUT/'paired-corner-overlap.png')
    return dict(waterOverlapPixels=overlap,contentPixels=n*n,bandWorldUnits=8,
                singleAlpha=.5,overlapAlpha=.75,maskChangedPixels=wrong_land,
                limitation='Controlled alpha test, not a claim about nonexistent painted sprites')

def main():
    started=time.perf_counter()
    golden=(ROOT/'tests/unit/P2bGolden.luau').read_text()
    seed=re.search(r'seed="([0-9a-f]+)"',golden)[1]
    rotation=int(re.search(r'rotation=(\d)',golden)[1])
    expected=[int(v) for v in re.search(r'elevations=\{([^}]+)\}',golden)[1].split(',')]
    assert descriptor(base(bytes.fromhex(seed)),rotation)==expected, '289 golden elevations'
    assert descriptor(base(bytes.fromhex(seed)),rotation)==expected, 'Golden repeat'
    exhaustive=Counter()
    for bits in range(512):
        m=[[bool(bits&(1<<(y*3+x))) for x in range(3)] for y in range(3)]
        exhaustive.update(p for _,_,p in vertices(m))
    assert set(exhaustive)==set(range(16))
    assert set(DIRECT)==set(range(16))-{6,9}
    histogram=Counter();all_rotations=Counter();rotations=Counter();examples=[];fail_countries=0;first=None
    for i in range(1,10001):
        text=''.join(f'{fnv(f"seed-{tag}:{i}".encode()):08x}' for tag in 'abcd')
        seed=bytes.fromhex(text);natural=keyed(seed,'start-layout',0,0,0)//1073741824
        rotations[natural]+=1;values=base(seed)
        for r in range(4):
            m=native_mask(descriptor(values,r));counts=Counter(p for _,_,p in vertices(m))
            all_rotations.update(counts)
            if r==natural:
                histogram.update(counts)
                if counts[6]+counts[9]:
                    fail_countries+=1
                    record=dict(index=i,seed=text,rotation=r,mask=m,diagonals=[dict(x=x*64,y=y*64,pattern=p) for x,y,p in vertices(m) if p in (6,9)])
                    if first is None:first=record
                    if len(examples)<6:examples.append(record)
        if i%1000==0: print(f'{i}/10000; diagonal countries={fail_countries}',flush=True)
    sheets(examples)
    result=dict(status='REVIEW: direct vocabulary missing diagonal classes; paired-corner clipping contract incomplete',
      scope='Independent Python reference; not a new Luau generation/fairness or Studio proof',
      goldenElevationChecks=len(expected),exhaustive3x3Masks=512,exhaustiveJunctions=sum(exhaustive.values()),
      approvedCorpusSeedCount=10000,corpusDefinition='P2bWorld.spec seed-a/b/c/d FNV hex concatenation, indices1..10000; candidate0 as historically accepted corpus',
      naturalRotations=dict(rotations),naturalPatternCounts=dict(histogram),allFourReservationPatternCounts=dict(all_rotations),
      naturalCountriesWithDiagonalContacts=fail_countries,firstDiagonalCountry=first,
      directMissingPatterns=[6,9],pairedCorner=overlap_diagnostic(),elapsedSeconds=time.perf_counter()-started,
      acceptanceGatePassed=False,
      boundaryScope='Interior 15x15 junctions per sector. Ownership edges are clipped, never assumed ocean. Neighbour-sector seam art needs actual neighbour context, not fabricated padding.',
      sourceHashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [ROOT/'src/server/World/IntegerField.luau',ROOT/'src/server/World/ClimateModel.luau',ROOT/'src/server/World/StarterValidator.luau',ROOT/'src/server/World/WorldGenerator.luau',ROOT/'src/client/Views/Map/GeneratedTerrain.luau',ROOT/'tests/unit/P2bGolden.luau']})
    (OUT/'grammar-results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ['status','goldenElevationChecks','naturalCountriesWithDiagonalContacts','naturalRotations','elapsedSeconds']}))
    raise SystemExit(0 if result['acceptanceGatePassed'] else 2)
if __name__=='__main__':main()
