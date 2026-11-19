"""Painted edge contact sheets, not schematic substitutes for finished art."""
import json
from PIL import Image,ImageDraw
from prepare_art import OUT,PATTERNS,tile_background,draw_label,composite
def main():
    sprites={n:Image.open(OUT/'sprites'/f'{n}-r1.png').convert('RGBA') for n in PATTERNS.values()}
    tiles={}
    for p in range(16):
        bg=tile_background(p)
        if p in PATTERNS:bg.alpha_composite(sprites[PATTERNS[p]])
        tiles[p]=bg
    sheet=Image.new('RGB',(1100,1220),'#0b1420');d=ImageDraw.Draw(sheet);draw_label(d,(15,10),'All16 occupancy cases — actual prepared art; homogeneous cases remain Native')
    for p in range(16):
        x=15+p%4*270;y=50+p//4*290;sheet.paste(tiles[p],(x,y));draw_label(d,(x,y+245),f"{p}: {PATTERNS.get(p,'water' if p==0 else 'land')}",True)
    sheet.save(OUT/'previews/all16-painted.png')
    pairs=set()
    for bits in range(512):
        g=[[bool(bits&(1<<(y*3+x))) for x in range(3)] for y in range(3)]
        def p(x,y):return int(g[y][x])+2*int(g[y][x+1])+4*int(g[y+1][x])+8*int(g[y+1][x+1])
        for y in range(2):pairs.add(('H',p(0,y),p(1,y)))
        for x in range(2):pairs.add(('V',p(x,0),p(x,1)))
    for page in range(2):
        sheet=Image.new('RGB',(1600,1680),'#0b1420');d=ImageDraw.Draw(sheet);draw_label(d,(15,10),f'Compatible painted edge pairs {page+1}/2 — all128 directed pairs from exhaustive3x3 masks')
        for i,(axis,p,q) in enumerate(sorted(pairs)[page*64:page*64+64]):
            x=15+i%8*198;y=50+i//8*200
            if axis=='H':
                pic=Image.new('RGBA',(480,240));pic.paste(tiles[p],(0,0));pic.paste(tiles[q],(240,0));pic=pic.resize((160,80),Image.Resampling.LANCZOS)
            else:
                pic=Image.new('RGBA',(240,480));pic.paste(tiles[p],(0,0));pic.paste(tiles[q],(0,240));pic=pic.resize((80,160),Image.Resampling.LANCZOS)
            sheet.paste(pic,(x,y));draw_label(d,(x,y+166),f'{axis}: {p} → {q}',True)
        sheet.save(OUT/f'previews/edge-pairs-{page+1}.png')
    arrangements={'Headland':['00000','00100','00100','11111','11111'],'Inlet':['11111','11011','11011','00000','00000'],'Island':['00000','00000','00100','00000','00000'],'Lake':['11111','11111','11011','11111','11111'],'Diagonal':['00000','01000','00100','00010','00000'],'Checker':['10101','01010','10101','01010','10101'],'Stair':['10000','11000','11100','11110','11111'],'Disconnected':['11000','11000','00000','00011','00011']}
    for z in [.55,.72,1,1.2,1.8]:
        size=round(320*z);column=max(size+25,210);height=size+80
        sheet=Image.new('RGB',(4*column,2*height+40),'#0b1420');d=ImageDraw.Draw(sheet);draw_label(d,(15,10),f'Painted adversarial arrangements at {z:g}x — one assembled image sampled locally')
        for i,(name,rows) in enumerate(arrangements.items()):
            m=[[v=='1' for v in row] for row in rows];pic=composite(m,sprites).resize((size,size),Image.Resampling.LANCZOS);x=10+i%4*column;y=45+i//4*height;sheet.paste(pic,(x,y));draw_label(d,(x,y+size+8),name,True)
        sheet.save(OUT/f'previews/joins-zoom-{z:g}.png')
    print('All16 painted cases,128 contact pairs and40 arrangement/zoom samples saved.')
if __name__=='__main__':main()
