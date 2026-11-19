import importlib.util, pathlib, json, time, hashlib, sys
sys.dont_write_bytecode=True
p=pathlib.Path('assets/illustrated-world-v1-art-r1/validate_grammar.py').resolve()
s=importlib.util.spec_from_file_location('grammar',p);g=importlib.util.module_from_spec(s);s.loader.exec_module(g)
out=pathlib.Path('docs/evidence/illustrated-world-v1');start=time.perf_counter();maximum=None;allmax=0
for i in range(1,10001):
 text=''.join(f'{g.fnv(f"seed-{tag}:{i}".encode()):08x}' for tag in 'abcd');seed=bytes.fromhex(text);natural=g.keyed(seed,'start-layout',0,0,0)//1073741824;v=g.base(seed)
 for r in range(4):
  vals=g.descriptor(v,r);mask=g.native_mask(vals);vertices=g.vertices(mask);n=sum(p not in (0,15) for x,y,p in vertices);allmax=max(allmax,n)
  assert all(p in g.DIRECT for x,y,p in vertices)
  if r==natural and (maximum is None or n>maximum['shoreCount']):maximum=dict(seed=text,index=i,rotation=r,shoreCount=n,elevations=vals)
 if i%1000==0:print(i,flush=True)
report=dict(status='PASS independent Python grammar reference; not Studio performance',seeds=10000,reservationRotations=4,junctions=9000000,maximumNatural=maximum,maximumAllRotations=allmax,seconds=time.perf_counter()-start)
(out/'corpus.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:v for k,v in report.items() if k!='maximumNatural'}));print('MAXIMUM',maximum['seed'],maximum['index'],maximum['shoreCount'])
