"""Broader amended-radius reference gate. No runtime generation or Roblox claims."""
import sys
sys.dont_write_bytecode = True
from ValidateP2bClimate import climate, keyed
from pathlib import Path
import hashlib
import json
import argparse


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--seeds',type=int,default=256)
    args=parser.parse_args()
    assert 1 <= args.seeds <= 10000
    special=['df307a52185f423288df5749229f0808','dfff043298824c4da9e3e4e45da85bc6',
             '00000000000040008000000000000000','ffffffffffff4fffbfffffffffffffff',
             'aaaaaaaaaaaa4aaa8aaaaaaaaaaaaaaa','55555555555545559555555555555555']
    seeds=[bytes.fromhex(s) for s in special]
    for i in range(args.seeds):
        b=bytearray(hashlib.sha256(f'PowerState-P2b-climate-2d:{i}'.encode()).digest()[:16])
        b[6]=(b[6]&15)|64;b[8]=(b[8]&63)|128;seeds.append(bytes(b))
    result={'kind':'Python integer reference only; amended v1 outer radius 4608',
            'outerRadius':4608,'requestedRandomSeeds':args.seeds,'adversarialSeeds':special,
            'sampling':'Global 64-unit 2D grid over transition annulus, radii 1984..4736; X/Y and both diagonals. Diagonal threshold scales with Euclidean distance, checked with exact squared integers.',
            'seedsCompleted':0,'points':0,'pairs':0,'diagonalPairs':0,
            'maxTemperaturePer64C':0,'maxRainfallPer64Mm':0,'passed':False,
            'failure':None,'referenceChecks':[], 'amendedVectors':[]}
    for h in special[:2]:
        for x,y in [(512,-2752),(512,-2816),(0,0),(-1024,-64),(512,512)]:
            a=climate(bytes.fromhex(h),x,y)
            assert a==climate(bytes.fromhex(h),x,y)
            sx,lx=divmod(x,1024);sy,ly=divmod(y,1024)
            assert a==climate(bytes.fromhex(h),sx*1024+lx,sy*1024+ly)
            result['amendedVectors'].append({'seed':h,**a})
    result['referenceChecks']=['Repeated coordinate parity','Negative coordinate floor/local reconstruction']
    path=Path(__file__).resolve().parents[1]/'docs/P2B-CLIMATE-2D-GATE.json'
    def save():path.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    offsets=[(64,0),(0,64),(64,64),(-64,64)]
    for index,seed in enumerate(seeds):
        cache={}
        def sample(x,y):
            key=(x,y)
            if key not in cache:cache[key]=climate(seed,x,y);result['points']+=1
            return cache[key]
        for y in range(-4224,5249,64):
            for x in range(-4224,5249,64):
                r2=(x-512)**2+(y-512)**2
                if not 1984**2 <= r2 <= 4736**2:continue
                a=sample(x,y)
                for dx,dy in offsets:
                    b=sample(x+dx,y+dy);dt=abs(a['temperatureCentiC']-b['temperatureCentiC']);dr=abs(a['rainfallMm']-b['rainfallMm'])
                    dist2=dx*dx+dy*dy
                    result['pairs']+=1;result['diagonalPairs']+=int(dx!=0 and dy!=0)
                    result['maxTemperaturePer64C']=max(result['maxTemperaturePer64C'],dt/100*64/dist2**.5)
                    result['maxRainfallPer64Mm']=max(result['maxRainfallPer64Mm'],dr*64/dist2**.5)
                    if dt*dt*4096>200*200*dist2 or dr*dr*4096>150*150*dist2:
                        result['failure']={'seedIndex':index,'seed':seed.hex(),'a':a,'b':b,'dx':dx,'dy':dy,'deltaCentiC':dt,'deltaRainfallMm':dr}
                        save();print(json.dumps(result['failure'],indent=2));print('FAIL',result['pairs'],'pairs before first violation');return 1
        result['seedsCompleted']+=1
        if index%8==0:print('Completed',result['seedsCompleted'],'seeds;',result['pairs'],'pairs',flush=True)
    result['passed']=True;save();print(json.dumps({k:result[k] for k in ['passed','seedsCompleted','pairs','diagonalPairs','maxTemperaturePer64C','maxRainfallPer64Mm']},indent=2));return 0

if __name__=='__main__':raise SystemExit(main())
