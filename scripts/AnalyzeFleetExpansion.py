"""Local design arithmetic only. No runtime changes, services or real profile input.
Radial nonbinding-route analytical dispatch; future FleetSolver acceptance remains required.
"""
import json,statistics
from pathlib import Path
R=[800]*6+[1000,1100,1200,1000,1000,1000,1000,1000,1000,1000,1100,1200,1200,1200,1200,1200,1000,800]
C=[800]*6+[900,1000,1200,1200,1200,1200,1200,1200,1200,1200,1200,1200,1100,1000,900,800,750,750]
def demand(step,district=True):
 twice=(1440+step*2+1)%2880;hour,part=divmod(twice,120)
 def factor(v):return v[hour]*120+(v[(hour+1)%24]-v[hour])*part
 t=(twice-480)%2880;anomaly=-720000+t*1000 if t<=1440 else 720000-(t-1440)*1000
 temperature=1700*1440+anomaly
 total=1000*24*factor(R)*12+factor(C)*72000+1000*8*max(0,18*144000-temperature)+1000*6*max(0,temperature-24*144000)
 kw=(total*1000+7200000000)//14400000000
 return kw+((kw+2)//4 if district else 0)
def seed_for(hexseed):
 h=2166136261
 for b in b'PSFLEET\x00v1\x00'+bytes.fromhex(hexseed):h=((h^b)*16777619)%4294967296
 return h%2147483647

def wind(seed,step):
 def knot(hour):
  h=seed+1
  for ch in 'operations.wind.v1|starter-0-0':h=(h*48271+ord(ch))%2147483647
  h=(h+hour*104729)%2147483647
  for _ in range(3):h=h*48271%2147483647
  return h%801
 hour,part=divmod(step,60)
 return ((knot(hour)*(60-part)+knot(hour+1)*part)//60)*2

def replay(seed,minutes,district=True,cap=2000,connected=True):
 requested=wind_meter=gas_meter=0
 for step in range(minutes):
  kw=demand(step,district);requested+=kw
  w=min(kw,cap,wind(seed,step)) if connected else 0
  wind_meter+=w;gas_meter+=kw-w
 sales=requested*12000//60000
 gas_variable=gas_meter*8000//60000;gas_fixed=minutes*1000000//60000;wind_fixed=minutes*600000//60000
 base_variable=requested*8000//60000
 gain=base_variable-gas_variable-wind_fixed
 return dict(minutes=minutes,requestedMWh=requested/60000,windMWh=wind_meter/60000,gasMWh=gas_meter/60000,salesCredits=sales/100,gasVariableCredits=gas_variable/100,gasFixedCredits=gas_fixed/100,windFixedCredits=wind_fixed/100,baseNetCredits=(sales-base_variable-gas_fixed)/100,windNetCredits=(sales-gas_variable-gas_fixed-wind_fixed)/100,incrementalCredits=gain/100,paybackHours=400000/gain*minutes/60 if gain>0 else None)
seeds=[seed_for(f'{n:032x}') for n in range(32)]
rows=[dict(seedIndex=i,**replay(seed,10080))for i,seed in enumerate(seeds)]
summary={k:{'min':min(r[k]for r in rows),'median':statistics.median(r[k]for r in rows),'max':max(r[k]for r in rows)}for k in ['windMWh','incrementalCredits','paybackHours']}
ref=seeds[0]
examples={str(days):replay(ref,1440*days)for days in [1,7]}
examples['noDistrict']=replay(ref,1440,False)
examples['cap500']=replay(ref,1440,cap=500)
examples['disconnectedOn']=replay(ref,1440,connected=False)
summary['fund4000From250Hours']=4000/(examples['1']['baseNetCredits']/24)
result={'method':'Analytical proposal; 1000 residents/17C, district built, gas On, wind On, zero starting financial carries; synthetic seeds only; no real records','proposedPriceCredits':4000,'seedMappingProposal':'FNV1a(PSFLEET NUL v1 NUL + 16 decoded seed bytes) modulo2147483647; frozen version1; OperationsWind v1 region starter-0-0','cohort':rows,'summary':summary,'examples':examples}
Path('docs/NATIONAL-FLEET-EXPANSION-CALCULATIONS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'summary':summary,'examples':examples},indent=2))
