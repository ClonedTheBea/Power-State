"""LOCAL artwork simulation of exported Test descriptors, never a Studio render.
No procedural generation, anchor modification, asset upload or runtime adapter.
"""
from produce import *
import re,copy

catalog=(ROOT/'tests/integration/IllustratedWorld/IllustratedAtlasCatalog.luau').read_text()
motifs={}
for name,atlas,rect,pivot,size in re.findall(r'\["([^"]+)"\] = \{atlas="([^"]+)", rect=\{([^}]+)\}, pivot=\{([^}]+)\}, size=(\d+)\}',catalog):
    motifs[name]=dict(atlas=atlas,rect=list(map(int,rect.split(','))),pivot=list(map(int,pivot.split(','))),size=int(size))
paths={'main':ROOT/'assets/illustrated-world-v1-art-r1/power-state-terrain-edges-proof-v1.png',
 'diagonal':ROOT/'assets/illustrated-world-v1-art-r1/power-state-diagonal-shores-proof-v1.png',
 'original':ROOT/'assets/r32-proof-v3/power-state-map-proof-v3.png',
 'settlements':ROOT/'assets/r37-settlements-v1/power-state-settlements-proof-v1.png'}
atlases={k:Image.open(p).convert('RGBA') for k,p in paths.items()}
texture=Image.open(OUT/'temperate-ground-v12a.png').convert('RGB')
fixtures=json.loads((OUT/'fixtures.json').read_text())
WATER=np.array([17,42,60]);HILL=np.array([126,145,111]);COAST=np.array([157,155,119])
def smooth(t):return t*t*(3-2*t)
def interpolate(grid,x,y):
    # Same world coordinate gives exactly the same field value from either cell.
    ix=np.minimum(np.floor(x/64).astype(int),15);iy=np.minimum(np.floor(y/64).astype(int),15)
    u=smooth((x-ix*64)/64);v=smooth((y-iy*64)/64)
    return (grid[iy,ix]*(1-u)+grid[iy,ix+1]*u)*(1-v)+(grid[iy+1,ix]*(1-u)+grid[iy+1,ix+1]*u)*v
def fields(f):
    return {k:np.array([s[k] for s in f['world']['samples']]).reshape(17,17) for k in ('elevationM','rainfallMm','temperatureCentiC')}
def colour(field,x,y):
    e=interpolate(field['elevationM'],x,y)
    rain=interpolate(field['rainfallMm'],x,y);temp=interpolate(field['temperatureCentiC'],x,y)/100
    high=smooth(np.clip((e-30)/170,0,1))
    dry=np.clip((1000-rain)/1000+(temp-17)/60,-.15,.15)
    coast=smooth(np.clip((25-e)/25,0,1))*.35
    c=BASE+(HILL-BASE)*high[:,:,None]+dry[:,:,None]*np.array([9,3,-5])
    return c*(1-coast[:,:,None])+COAST*coast[:,:,None]
def terrain(f,proposed=False):
    field=fields(f);grid=field['elevationM'];mask=np.repeat(np.repeat(grid[:-1,:-1]>0,64,axis=0),64,axis=1)
    if proposed:
        y,x=np.mgrid[0:1024,0:1024].astype(float);x+=.5;y+=.5
        # 4 source texels/world unit, periodic phase; local downfilter only.
        mat=np.asarray(tile(texture,4).resize((1024,1024),Image.Resampling.LANCZOS)).astype(float)-BASE
        rgb=np.clip(np.rint(colour(field,x,y)+mat),0,255).astype('uint8')
    else:
        e=np.repeat(np.repeat(grid[:-1,:-1],64,axis=0),64,axis=1)
        t=np.clip((e-40)/160,0,1)
        rgb=np.rint(BASE+(HILL-BASE)*t[:,:,None]).astype('uint8');rgb[(e>0)&(e<12)]=COAST
    rgb[~mask]=WATER
    return Image.fromarray(rgb).convert('RGBA'),mask
def sprite(art):
    m=motifs[art];x,y,w,h=m['rect'];return atlases[m['atlas']].crop((x,y,x+w,y+h))
def render(f,mode,built):
    im,mask=terrain(f,mode=='proposed');d=f['composition'];selected=[]
    if mode!='native':
        for entry in d['shores']+d['assets']+d['decorations']:
            if entry.get('preview') and not built:continue
            if entry.get('link') and not built and entry['link']==len(f['links']):continue
            if len(selected)==92:break
            m=motifs[entry['art']];n=m['size'];p=m['pivot'];r=m['rect']
            pos=(round(entry['x']-p[0]*n/r[2]),round(entry['y']-p[1]*n/r[3]))
            im.alpha_composite(sprite(entry['art']).resize((n,n),Image.Resampling.LANCZOS),pos)
            selected.append(entry)
    draw=ImageDraw.Draw(im);nodes={n['id']:n for n in f['nodes']}
    for i,link in enumerate(f['links']):
        if i==len(f['links'])-1 and not built:continue
        a,b=nodes[link['from']],nodes[link['to']]
        draw.line((a['x'],a['y'],b['x'],b['y']),fill='#6bd8cf',width=3)
    for n in f['nodes']:
        if ':b:' in n['id'] and not built:continue
        x,y=n['x'],n['y'];draw.ellipse((x-6,y-6,x+6,y+6),fill='#142631',outline='#a9f5df',width=2)
        draw.text((x+10,y-16),n['name'],font=SMALL,fill='#f2fff4',stroke_width=2,stroke_fill='#18252e')
    return im,mask,selected
def main():
    original=copy.deepcopy(fixtures);results=[]
    cases=[('normal',0,False,None),('diagonal',0,False,(64,512,320,768)),
           ('maximum',1,False,None),('connected-district',1,True,None)]
    for name,index,built,crop in cases:
        f=fixtures[index];board=Image.new('RGB',(1840,710),'#18252e')
        label(board,(15,8),'LOCAL ARTWORK SIMULATION - same exported geometry/camera; not Studio, no purchase')
        label(board,(15,35),name+' / '+f['world']['seed']+' / '+f['world']['countryId'])
        masks=[];entries=[]
        for j,mode in enumerate(('native','illustrated','proposed')):
            im,mask,selected=render(f,mode,built);masks.append(mask);entries.append(selected)
            im.save(OUT/f'{name}-{mode}-full.png')
            if crop:im=im.crop(crop)
            board.paste(im.resize((600,600),Image.Resampling.LANCZOS),(15+j*610,95))
            label(board,(15+j*610,68),{'native':'Native terrain + schematic overlays','illustrated':'Current composition v2 (local)','proposed':'Corrected ground + continuous colour'}[mode])
        assert np.array_equal(masks[0],masks[1]) and np.array_equal(masks[0],masks[2])
        assert entries[1]==entries[2]
        board.save(OUT/f'country-{name}-comparison.png')
        field=fields(f);maxerr=0.
        # Explicit independently evaluated t=1 vs t=0 patch boundary samples.
        count=0
        for iy in range(16):
            for ix in range(15):
                for t in np.linspace(0,1,65):
                    v=smooth(t)
                    for grid in field.values():
                        left=(grid[iy,ix]*(1-1)+grid[iy,ix+1]*1)*(1-v)+(grid[iy+1,ix]*0+grid[iy+1,ix+1])*v
                        right=(grid[iy,ix+1]*1+grid[iy,ix+2]*0)*(1-v)+(grid[iy+1,ix+1]+grid[iy+1,ix+2]*0)*v
                        maxerr=max(maxerr,abs(left-right));count+=1
                        top=(grid[ix,iy]*(1-v)+grid[ix,iy+1]*v)*0+(grid[ix+1,iy]*(1-v)+grid[ix+1,iy+1]*v)
                        bottom=(grid[ix+1,iy]*(1-v)+grid[ix+1,iy+1]*v)*1+(grid[ix+2,iy]*(1-v)+grid[ix+2,iy+1]*v)*0
                        maxerr=max(maxerr,abs(top-bottom));count+=1
        assert maxerr==0
        proposed,mask=terrain(f,True);assembled=Image.new('RGBA',(1024,1024))
        for y in range(16):
            for x in range(16):assembled.paste(proposed.crop((x*64,y*64,(x+1)*64,(y+1)*64)),(x*64,y*64))
        assert assembled.tobytes()==proposed.tobytes()
        # All original water background pixels remain identical before approved overlays.
        assert np.all(np.asarray(proposed)[:,:,:3][~mask]==WATER)
        results.append(dict(case=name,seed=f['world']['seed'],countryId=f['world']['countryId'],builtPresentationOnly=built,
             crop=crop,viewport=[600,600],shoreCount=len(f['composition']['shores']),drawnMotifs=len(entries[2]),
             sharedEdgeComparisons=count,sharedEdgeMaximumError=maxerr,cellReassemblyExact=True,
             originalLandPixels=int(mask.sum()),maskExact=True,sameOverlayEntries=True))
    assert fixtures==original
    # Full motif compatibility swatches at the actual five supported zoom multipliers.
    arts=['shore-n','hill-low-a','forest','fields','town','gas','village','substation','pylon']
    sheet=Image.new('RGB',(2760,1570),'#18252e');label(sheet,(15,8),'LOCAL corrected material / approved motifs at map zooms; not a renderer or GPU test')
    bg=tile(texture.resize((256,256),Image.Resampling.LANCZOS),2)
    for row,z in enumerate((.55,.72,1,1.2,1.8)):
        y=45+row*300;label(sheet,(5,y),str(z)+'x')
        for col,art in enumerate(arts):
            x=65+col*298;patch=bg.crop((0,0,280,270)).convert('RGBA');n=round(motifs[art]['size']*z)
            patch.alpha_composite(sprite(art).resize((n,n),Image.Resampling.LANCZOS),((280-n)//2,(270-n)//2))
            sheet.paste(patch,(x,y));label(sheet,(x,y+272),art)
    sheet.save(OUT/'motif-five-zooms.png')
    record={'fixturesFileSha256':sha(OUT/'fixtures.json'),'cases':results,'fixturesUnchanged':True,
            'approvedAtlasHashes':{str(p.relative_to(ROOT)):sha(p) for p in paths.values()},
            'status':'Local geometry/colour proof only; runtime renderer not implemented',
            'texturePeriodWorldUnits':256,'sourcePixelsPerWorldUnit':4,'bufferPixelsPerWorldUnit':1}
    (OUT/'composite-validation.json').write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps(results,indent=2))
if __name__=='__main__':main()
