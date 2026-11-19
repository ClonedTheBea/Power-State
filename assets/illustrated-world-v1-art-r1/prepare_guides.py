"""Local illustration guides, not finished art or runtime geometry."""
from pathlib import Path
import json
from PIL import Image,ImageDraw
OUT=Path(__file__).resolve().parent
PATTERNS={12:'shore-n',5:'shore-e',3:'shore-s',10:'shore-w',4:'shore-convex-ne',1:'shore-convex-se',2:'shore-convex-sw',8:'shore-convex-nw',13:'shore-concave-ne',7:'shore-concave-se',11:'shore-concave-sw',14:'shore-concave-nw',9:'shore-diagonal-nw-se',6:'shore-diagonal-ne-sw'}
def main():
    dest=OUT/'sources'/'guides';dest.mkdir(exist_ok=True)
    for p,name in PATTERNS.items():
        im=Image.new('RGB',(1024,1024));d=ImageDraw.Draw(im)
        for q in range(4):
            x=(q%2)*512;y=(q//2)*512
            d.rectangle((x,y,x+511,y+511),fill='#6b8463' if p&(1<<q) else '#112a3c')
        im.save(dest/(name+'.png'))
    (dest/'patterns.json').write_text(json.dumps(PATTERNS,indent=2)+'\n')
if __name__=='__main__':main()
