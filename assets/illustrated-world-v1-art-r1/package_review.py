"""Local review documents, masks, OpenRaster layers and additional previews."""
from pathlib import Path
import json, io, zipfile, xml.etree.ElementTree as ET
import numpy as np
from PIL import Image,ImageDraw
from prepare_art import OUT,ROOT,PATTERNS,occupancy,distance,sha,composite,draw_label,LAND,WATER,tile_background
from validate_grammar import base,descriptor
def png(im):
    b=io.BytesIO();im.save(b,format='PNG');return b.getvalue()
def main():
    manifest=json.loads((OUT/'manifest.json').read_text());sprites={e['artId']:Image.open(OUT/e['spriteFile']).convert('RGBA') for e in manifest['entries']}
    masks=OUT/'sources/masks';masks.mkdir(exist_ok=True)
    for p,n in PATTERNS.items():
        Image.fromarray((occupancy(p)*255).astype('uint8')).save(masks/f'{n}-land.png')
        Image.fromarray((np.clip((30-distance(p))/12,0,1)*255).astype('uint8')).save(masks/f'{n}-rim.png')
    # Editable allocation layers; raw illustrations themselves are flattened.
    for atlas in manifest['atlases']:
        w,h=atlas['size'];root=ET.Element('image',w=str(w),h=str(h),name='Power State local review');stack=ET.SubElement(root,'stack')
        with zipfile.ZipFile(OUT/f"{atlas['name']}-layers.ora",'w') as z:
            z.writestr('mimetype','image/openraster',compress_type=zipfile.ZIP_STORED)
            for e in manifest['entries']:
                if e['atlas']!=atlas['name']:continue
                name=e['artId'];x,y,_,_=e['sourceRect'];path=f'data/{name}.png'
                z.writestr(path,png(sprites[name]));ET.SubElement(stack,'layer',name=name,src=path,x=str(x),y=str(y),opacity='1.0',visibility='visible',**{'composite-op':'svg:src-over'})
            z.writestr('stack.xml',ET.tostring(root));z.writestr('mergedimage.png',(OUT/atlas['file']).read_bytes())
            thumb=Image.open(OUT/atlas['file']).convert('RGBA');thumb.thumbnail((256,256));z.writestr('Thumbnails/thumbnail.png',png(thumb))
    # All 18 motifs, all five sizes; each page contains six actual-size rows.
    inv={v:k for k,v in PATTERNS.items()}
    for page in range(3):
        sheet=Image.new('RGB',(1500,1250),'#0b1420');d=ImageDraw.Draw(sheet);draw_label(d,(20,10),f'All motif zoom review {page+1}/3 — local raster samples, not Roblox')
        for row,e in enumerate(manifest['entries'][page*6:page*6+6]):
            n=e['artId'];draw_label(d,(15,50+row*195),n,True)
            for col,z in enumerate([.55,.72,1,1.2,1.8]):
                size=round(e['nominalWorldCanvas'][0]*z);x=240+col*245;y=50+row*195
                bg=tile_background(inv[n]) if n in inv else Image.new('RGBA',(240,240),(*LAND,255));bg.alpha_composite(sprites[n]);sheet.paste(bg.resize((size,size),Image.Resampling.LANCZOS),(x,y));draw_label(d,(x,y+178),f'{z:g}x, {size}px',True)
        sheet.save(OUT/f'previews/all-motifs-zooms-{page+1}.png')
    # Show the real elevation-colour rule, rather than hiding sampled blocks
    # under a flat meadow swatch. Same generated reference values both sides.
    example=json.loads((OUT/'corpus-examples.json').read_text())[0];values=descriptor(base(bytes.fromhex(example['seed'])),example['rotation'])
    terrain=Image.new('RGBA',(1024,1024));d=ImageDraw.Draw(terrain)
    for row in range(16):
        for col in range(16):
            e=values[row*17+col];t=max(0,min(1,(e-40)/160));colour=WATER if e<=0 else (157,155,119) if e<12 else tuple(round(a+(b-a)*t) for a,b in zip(LAND,(126,145,111)))
            d.rectangle((col*64,row*64,col*64+63,row*64+63),fill=(*colour,255))
    painted=terrain.copy();mask=example['mask']
    for y in range(1,16):
        for x in range(1,16):
            p=int(mask[y-1][x-1])+2*int(mask[y-1][x])+4*int(mask[y][x-1])+8*int(mask[y][x])
            if p in PATTERNS:painted.alpha_composite(sprites[PATTERNS[p]].resize((64,64),Image.Resampling.LANCZOS),(x*64-32,y*64-32))
    # Borrow only the transparent motifs from the established source files.
    placements=[('forest-cluster',200,250,120),('forest-cluster',320,285,90),('agriculture',430,470,125),('settlement',560,520,120),('gas-station',320,580,115),('hill-low-a',660,330,120),('hill-low-b',780,300,130),('substation',450,570,80),('pylon',500,580,32)]
    for n,x,y,size in placements:
        s=sprites.get(n)
        if s is None:s=Image.open(ROOT/'assets/r32-proof-v3/sprites'/f'{n}.png').convert('RGBA')
        s=s.resize((size,size),Image.Resampling.LANCZOS);painted.alpha_composite(s,(x-size//2,y-round(size*.77)))
    s=Image.open(ROOT/'assets/r37-settlements-v1/power-state-settlements-proof-v1.png').convert('RGBA').crop((8,8,248,248)).resize((85,85),Image.Resampling.LANCZOS);painted.alpha_composite(s,(667,465))
    board=Image.new('RGB',(2088,1110),'#0b1420');d=ImageDraw.Draw(board);board.paste(terrain,(10,50));board.paste(painted,(1054,50));draw_label(d,(10,12),'Same corpus38 — current Native elevation-colour rule, local reconstruction');draw_label(d,(1054,12),'Same samples + candidate artwork; block colours intentionally retained');draw_label(d,(10,1080),'Art study only; not Studio, saved asset placement, terrain eligibility, or a runtime renderer.');board.save(OUT/'previews/native-colour-comparison.png')
    # Source-resolution diagonal centres and difficult corners enlarged without
    # smoothing, so reviewers can inspect single-pass coverage and clipping.
    sheet=Image.new('RGB',(1280,760),'#0b1420');d=ImageDraw.Draw(sheet);draw_label(d,(15,10),'Diagonal centre pixels — authored once, exact Native quadrants, no stacked corners')
    for i,p in enumerate([6,9]):
        bg=tile_background(p);bg.alpha_composite(sprites[PATTERNS[p]]);crop=bg.crop((96,96,144,144)).resize((576,576),Image.Resampling.NEAREST);sheet.paste(crop,(20+i*630,60));draw_label(d,(20+i*630,650),PATTERNS[p]);draw_label(d,(20+i*630,680),'48x48 source pixels shown at 12x; filtered display still needs engine testing',True)
    sheet.save(OUT/'previews/diagonal-centres.png')
    # Ground pivot review crosshairs are diagnostics, never baked into sprites.
    sheet=Image.new('RGB',(1100,330),'#0b1420');d=ImageDraw.Draw(sheet);draw_label(d,(15,10),'Ground pivots (120,184), unchanged content coordinates — no electrical-anchor movement')
    for i,n in enumerate(['hill-low-a','hill-low-b','substation','pylon']):
        bg=Image.new('RGBA',(240,240),(*LAND,255));bg.alpha_composite(sprites[n]);x=15+i*270;y=50;sheet.paste(bg,(x,y));d.line((x+110,y+184,x+130,y+184),fill='cyan',width=1);d.line((x+120,y+174,x+120,y+194),fill='cyan',width=1);draw_label(d,(x,y+245),n,True)
    sheet.save(OUT/'previews/pivots.png')
    # Sanity-check the layer source ZIP and source hashes without claiming a
    # painting application was used to author editable brush strokes.
    result={'openRasterLayers':{},'individualSpriteCount':len(sprites),'zoomSamples':90,'sourceImageCount':len(list((OUT/'sources').glob('*.png')))}
    for atlas in manifest['atlases']:
        with zipfile.ZipFile(OUT/f"{atlas['name']}-layers.ora") as z:
            assert z.read('mimetype')==b'image/openraster';tree=ET.fromstring(z.read('stack.xml'));result['openRasterLayers'][atlas['name']]=len(tree.find('stack'));assert z.read('mergedimage.png')==(OUT/atlas['file']).read_bytes()
    (OUT/'review-package-results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
if __name__=='__main__':main()
