"""Local art derivative only. Deterministic periodic synthesis, no runtime edits.
Existing Pillow/numpy; run from any directory. Source files never overwritten.
"""
from pathlib import Path
import hashlib,json
import numpy as np
from PIL import Image,ImageDraw,ImageFont
OUT=Path(__file__).resolve().parent
ROOT=OUT.parents[1]
FONT=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',18)
SMALL=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',14)
BASE=np.array([107.,132.,99.])
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def label(im,xy,text):ImageDraw.Draw(im).text(xy,text,font=FONT,fill='#edf4f8')
def tile(im,n):
    out=Image.new(im.mode,(im.width*n,im.height*n))
    for y in range(n):
        for x in range(n):out.paste(im,(x*im.width,y*im.height))
    return out
def metric(a):
    a=np.asarray(a).astype(float)
    def stat(v):return {'mean':float(v.mean()),'p95':float(np.percentile(v,95)),'max':float(v.max())}
    return {'wrapX':stat(abs(a[:,0]-a[:,-1])),'wrapY':stat(abs(a[0]-a[-1])),
            'internalX':stat(abs(np.diff(a,axis=1))),'internalY':stat(abs(np.diff(a,axis=0)))}
def periodic_blur(a,sigma):
    fy=np.fft.fftfreq(a.shape[0])[:,None];fx=np.fft.fftfreq(a.shape[1])[None,:]
    f=np.exp(-2*np.pi**2*sigma*sigma*(fx*fx+fy*fy))
    return np.fft.ifft2(np.fft.fft2(a,axes=(0,1))*f[:,:,None],axes=(0,1)).real
def produce():
    source=ROOT/'assets/illustrated-world-v12-ground-study/candidate-edit.png'
    source2=ROOT/'assets/illustrated-world-v12-ground-study/candidate-new.png'
    assert sha(source)=='52794fb984fa6d89a2da90f9c7baaac0a6119b0f20886f1a126bf82f04963712'
    assert sha(source2)=='40141e82eb999ea2e6dd9735b32f3972e58ddb00dbb8a28e40888e464deabaa3'
    a=np.asarray(Image.open(source).convert('RGB').resize((1024,1024),Image.Resampling.LANCZOS)).astype(float)
    b=np.asarray(Image.open(source2).convert('RGB').resize((1024,1024),Image.Resampling.LANCZOS)).astype(float)
    # Two measured source power spectra; remove inherited diagonal low-frequency structure.
    fy=np.fft.fftfreq(1024)[:,None]*1024;fx=np.fft.fftfreq(1024)[None,:]*1024
    radius=np.sqrt(fx*fx+fy*fy);bins=np.rint(radius).astype(int)
    lum=(a.mean(axis=2)+b.mean(axis=2))*.5
    power=abs(np.fft.fft2(lum-lum.mean()))**2
    radial=np.bincount(bins.ravel(),weights=power.ravel())/np.maximum(1,np.bincount(bins.ravel()))
    spectrum=np.sqrt(.92*radial[bins]+.08*power)
    highpass=1-np.exp(-(radius/14)**4)
    lowpass=np.exp(-(radius/330)**4)
    rng=np.random.default_rng(120019)
    noise=np.fft.fft2(rng.normal(size=(1024,1024)))
    unit=noise/np.maximum(abs(noise),1e-12)
    grain=np.fft.ifft2(unit*spectrum*highpass*lowpass).real
    grain=grain/grain.std()*1.9
    # Quiet non-directional periodic meadow variation; no recognizable features.
    broad=periodic_blur(rng.normal(size=(1024,1024,1)),18)[:,:,0]
    broad=broad/broad.std()*1.05
    value=grain+broad
    rgb=np.clip(np.rint(BASE+value[:,:,None]*np.array([1,.95,.85])),0,255).astype('uint8')
    im=Image.fromarray(rgb).convert('RGBA');im.save(OUT/'temperate-ground-v12a.png')
    tile(im,2).save(OUT/'repeat-2x2-full.png')
    tile(im,4).save(OUT/'repeat-4x4-full.png')
    board=Image.new('RGB',(1560,850),'#18252e')
    label(board,(15,12),'LOCAL ART STUDY - before / periodic processed derivative; no Roblox filtering claim')
    for x,name,src in [(15,'Retained source (2x2)',Image.open(source).convert('RGBA')),(795,'Corrected material (4x4)',im)]:
        label(board,(x,45),name)
        board.paste(tile(src,2 if x==15 else 4).resize((750,750),Image.Resampling.LANCZOS),(x,80))
    board.save(OUT/'before-after-repeat.png')
    # Wrapped offsets move real joins to centre for magnified inspection.
    wrapped=np.roll(np.roll(rgb,512,axis=0),512,axis=1)
    edge=Image.fromarray(wrapped).crop((464,464,560,560))
    board=Image.new('RGB',(1200,690),'#18252e')
    label(board,(15,12),'True wrapping junction at centre - 96px enlarged 6x; no edge copying')
    board.paste(edge.resize((576,576),Image.Resampling.NEAREST),(15,60))
    filtered=periodic_blur(rgb,1.5)
    filtered=np.roll(np.roll(filtered,512,axis=0),512,axis=1)
    board.paste(Image.fromarray(np.clip(np.rint(filtered),0,255).astype('uint8')).crop((464,464,560,560)).resize((576,576),Image.Resampling.NEAREST),(610,60))
    label(board,(15,643),'Unfiltered pixels');label(board,(610,643),'Periodic Gaussian 1.5px - local diagnostic')
    board.save(OUT/'edge-examination.png')
    crop=Image.new('RGBA',(1024,1024))
    for y in range(4):
        for x in range(4):crop.paste(im.crop((x*256,y*256,(x+1)*256,(y+1)*256)),(x*256,y*256))
    assert crop.tobytes()==im.tobytes()
    crop.save(OUT/'crop-256-reassembly.png')
    results={'approaches':1,'dimensions':im.size,'mode':im.mode,'sha256':sha(OUT/'temperate-ground-v12a.png'),
        'sources':[{'path':str(p.relative_to(ROOT)),'sha256':sha(p)} for p in (source,source2)],
        'seed':120019,'provenance':'Processed derivative of retained AI-generated source experiments; no new generation',
        'steps':['Lanczos resample both source candidates to1024','Average luminance source power spectrum',
                 '92% radial /8% original directional power; smooth highpass radius14 and lowpass330 cycles/tile',
                 'Seeded Hermitian phase synthesis on a1024 torus; grain standard deviation1.9',
                 'Independent periodic Gaussian18px meadow variation standard deviation1.05',
                 'Base RGB107/132/99; channel texture weights1/.95/.85; round to8-bit opaque RGBA'],
        'raw':metric(rgb),'filtered1_5':metric(periodic_blur(rgb,1.5)),
        'filtered4':metric(periodic_blur(rgb,4)),'crop256ReassemblyExact':True,
        'meanRGB':rgb.mean(axis=(0,1)).tolist(),'stdRGB':rgb.std(axis=(0,1)).tolist(),
        'sourceIntegrity':all(sha(ROOT/r['path'])==r['sha256'] for r in [{'path':str(p.relative_to(ROOT)),'sha256':sha(p)} for p in (source,source2)]),
        'runtimeAcceptance':False}
    (OUT/'material-validation.json').write_text(json.dumps(results,indent=2)+'\n')
    print(json.dumps(results,indent=2))
if __name__=='__main__':produce()
