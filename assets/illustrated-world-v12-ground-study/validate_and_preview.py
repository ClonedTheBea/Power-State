"""Read-only candidate analysis and requested local diagnostic contact sheets.
Does not correct, resample or overwrite candidate artwork. Preview resizes only.
Run from any directory with the already-installed Pillow and numpy.
"""
from pathlib import Path
import hashlib, json
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
rows = []

def stats(v):
    return dict(mean=float(v.mean()), p95=float(np.percentile(v,95)), maximum=int(v.max()))

def wrap_metrics(a):
    return dict(horizontal=stats(np.abs(a[:,0]-a[:,-1])),
                vertical=stats(np.abs(a[0]-a[-1])),
                internalHorizontal=stats(np.abs(np.diff(a,axis=1))),
                internalVertical=stats(np.abs(np.diff(a,axis=0))))

for name in ('candidate-edit.png','candidate-new.png'):
    p=HERE/name
    im=Image.open(p).convert('RGB'); a=np.asarray(im).astype(np.int16)
    w,h=im.size
    # Original-size repetition is the seam evidence; no pixel correction.
    repeat=Image.new('RGB',(w*2,h*2))
    for y in (0,h):
        for x in (0,w): repeat.paste(im,(x,y))
    repeat.save(HERE/(p.stem+'-repeat-actual.png'))
    blur=im.filter(ImageFilter.GaussianBlur(4))
    row=dict(file=name,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),
             dimensions=[w,h],mode=im.mode,meanRGB=a.mean(axis=(0,1)).tolist(),
             exact1024=im.size==(1024,1024),raw=wrap_metrics(a),
             filteredRadius4=wrap_metrics(np.asarray(blur).astype(np.int16)),
             filteredMethod='Each source tile Gaussian radius4 before repetition; not Roblox filtering')
    # 256px subdivision assembly retains source pixels; wrong-size remainder is explicit.
    crop=im.crop((0,0,1024,1024)); assembled=Image.new('RGB',(1024,1024))
    for y in range(4):
        for x in range(4): assembled.paste(crop.crop((x*256,y*256,(x+1)*256,(y+1)*256)),(x*256,y*256))
    row['diagnosticTopLeft1024CropOnly']={'internalAssemblyIdentical':bool(np.array_equal(np.asarray(crop),np.asarray(assembled))),
        'wrap':wrap_metrics(np.asarray(crop).astype(np.int16)), 'notAFinalAsset':True}
    assembled.save(HERE/(p.stem+'-256-subdivision-diagnostic.png'))
    sheet=Image.new('RGB',(1100,680),'#18252e');d=ImageDraw.Draw(sheet)
    d.text((20,15),'LOCAL REJECTED-CANDIDATE DIAGNOSTIC - not Roblox, not upload-ready',fill='white')
    sheet.paste(repeat.resize((600,600),Image.Resampling.LANCZOS),(20,45))
    d.text((650,45),f'{name}: {w} x {h}',fill='white')
    d.text((650,70),'2x2 full-source repeat at left',fill='white')
    d.text((650,100),'Top-left 1024 crop / 4x4 subdivisions',fill='white')
    sheet.paste(assembled.resize((400,400),Image.Resampling.LANCZOS),(650,125))
    d.text((650,545),'Crop is diagnostic only; omits source remainder.',fill='white')
    d.text((650,570),'Resizing for display does not fix wrapping.',fill='white')
    sheet.save(HERE/(p.stem+'-contact.png'))
    rows.append(row)

# Compatibility sheet uses unchanged approved atlas crops, not new artwork assets.
candidate=Image.open(HERE/'candidate-edit.png').convert('RGB')
old=Image.open(ROOT/'assets/r32-proof-v3/power-state-map-proof-v3.png').convert('RGBA')
main=Image.open(ROOT/'assets/illustrated-world-v1-art-r1/power-state-terrain-edges-proof-v1.png').convert('RGBA')
motifs=[('shore',main,(8,8,248,248),64),('hill',main,(8,776,248,1016),96),
        ('forest',old,(520,264,760,504),120),('fields',old,(776,264,1016,504),120),
        ('town',old,(8,520,248,760),130),('station',old,(264,520,504,760),140)]
sheet=Image.new('RGB',(1860,1690),'#18252e');d=ImageDraw.Draw(sheet)
d.text((15,12),'LOCAL MATERIAL STUDY ONLY - rejected candidate; no generated-country or runtime claim',fill='white')
for row,z in enumerate((.55,.72,1,1.2,1.8)):
    y=45+row*300;d.text((10,y),f'{z}x',fill='white')
    for col,(name,atlas,rect,worldsize) in enumerate(motifs):
        x=65+col*295
        bg=candidate.crop((0,0,256,256)).resize((280,270),Image.Resampling.LANCZOS).convert('RGBA')
        # This is a material/motif swatch, not exact world-aligned ground sampling.
        n=round(worldsize*z); art=atlas.crop(rect).resize((n,n),Image.Resampling.LANCZOS)
        bg.alpha_composite(art,((280-n)//2,(270-n)//2))
        sheet.paste(bg.convert('RGB'),(x,y));d.text((x,y+272),name,fill='white')
d.text((15,1560),'Low / higher elevation: proposed uniform swatches only, NOT a continuous-shading proof',fill='white')
for x,colour,label in [(20,(107,132,99),'base'),(260,(116,137,105),'higher')]:
    a=np.asarray(candidate.resize((220,90))).astype(float)
    a=np.clip(a*(np.array(colour)/np.array([107,132,99])),0,255).astype('uint8')
    sheet.paste(Image.fromarray(a),(x,1590));d.text((x,1680),label,fill='white')
sheet.save(HERE/'motif-zoom-contact.png')
(HERE/'validation.json').write_text(json.dumps({'status':'STOP: neither source meets required dimensions; seam acceptance failed',
    'sources':rows,'previewOnly':True},indent=2)+'\n',encoding='utf-8')
print(json.dumps([{'file':r['file'],'dimensions':r['dimensions'],'meanRGB':r['meanRGB'],'raw':r['raw']} for r in rows],indent=2))
