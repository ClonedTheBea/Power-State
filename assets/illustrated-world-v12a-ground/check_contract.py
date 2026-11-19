"""Independent local contract checks; no Roblox runtime claims."""
from composite import *
checks=0
def check(v,m):
    global checks
    assert v,m
    checks+=1
im=Image.open(OUT/'temperate-ground-v12a.png')
check(im.size==(1024,1024) and im.mode=='RGBA','Exact upload dimensions/format')
check(im.getchannel('A').getextrema()==(255,255),'Opaque alpha')
validation=json.loads((OUT/'material-validation.json').read_text())
check(sha(OUT/'temperate-ground-v12a.png')==validation['sha256'],'Exact derivative hash')
for row in validation['sources']:check(sha(ROOT/row['path'])==row['sha256'],'Source preserved')
for group in ('raw','filtered1_5','filtered4'):
    m=validation[group]
    for axis in ('X','Y'):
        # Investigation diagnostic, not a replacement for visual acceptance.
        check(m['wrap'+axis]['mean']<m['internal'+axis]['mean']*1.3,'No exceptional seam mean')
        check(m['wrap'+axis]['max']<=m['internal'+axis]['max'],'No exceptional seam maximum')
rgba=np.asarray(im)
for x,y in [(-1024,-1024),(-257,-1),(-1,255),(0,0),(256,256),(1024,1024),(2047,-2049)]:
    # A crop from a neighbouring tile has identical world phase including negative positions.
    sx=x%1024;sy=y%1024
    block=np.array([[rgba[(y+j)%1024,(x+i)%1024] for i in range(256)] for j in range(256)])
    reference=np.asarray(tile(im,2).crop((sx,sy,sx+256,sy+256)))
    check(np.array_equal(block,reference),'World crop phase')
for y in range(4):
    for x in range(4):
        block=rgba[y*256:(y+1)*256,x*256:(x+1)*256]
        check(np.array_equal(block,np.asarray(im.crop((x*256,y*256,(x+1)*256,(y+1)*256)))),'256 crop position')
# Existing fixture climate is intentionally constant. Exercise proposed cosmetic
# climate weighting separately with a labelled synthetic colour ramp, not a country.
yy,xx=np.mgrid[0:17,0:17]
synthetic={'elevationM':xx*8+yy*2,'rainfallMm':700+xx*30,'temperatureCentiC':1200+yy*60}
y,x=np.mgrid[0:1024,0:1024].astype(float);x+=.5;y+=.5
c=colour(synthetic,x,y)
check(np.isfinite(c).all() and c.min()>=0 and c.max()<=255,'Bounded cosmetic climate colour')
Image.fromarray(np.rint(c).astype('uint8')).save(OUT/'synthetic-colour-ramp.png')
max_delta=0
for edge in range(64,1024,64):
    for a in (c[:,edge]-c[:,edge-1],c[edge]-c[edge-1]):
        max_delta=max(max_delta,float(abs(a).max()))
check(max_delta<.01,'Synthetic colour shared-boundary continuity')
result={'checks':checks,'status':'PASS local raster/crop/colour checks only',
        'syntheticColourBoundaryMaxAdjacentDifference':max_delta,
        'thresholds':'Seam mean <=1.3x interior and max <=interior are local diagnostics, not owner/Roblox acceptance'}
(OUT/'contract-checks.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
