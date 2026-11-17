--!strict
-- Versioned test balance. No weather randomness, economic state or per-person rounding.
local Demand={}
Demand.VERSION=1
Demand.RESIDENTIAL=table.freeze({800,800,800,800,800,800,1000,1100,1200,1000,1000,1000,1000,1000,1000,1000,1100,1200,1200,1200,1200,1200,1000,800})
Demand.COMMERCIAL=table.freeze({800,800,800,800,800,800,900,1000,1200,1200,1200,1200,1200,1200,1200,1200,1200,1200,1100,1000,900,800,750,750})
local function finite(n:number,lo:number,hi:number)
 assert(n==n and n>=lo and n<=hi,"Demand input bounds")
end
function Demand.curve(values:{number},minute:number):number
 finite(minute,0,1440)
 local hour=math.floor(minute/60)%24;local fraction=(minute%60)/60
 return (values[hour+1]+(values[(hour+1)%24+1]-values[hour+1])*fraction)/1000
end
function Demand.temperature(meanCentiC:number,minute:number):number
 finite(meanCentiC,-4000,4000);finite(minute,0,1440)
 local t=(minute-240)%1440
 local anomaly=if t<=720 then -500+t*1000/720 else 500-(t-720)*1000/720
 return (meanCentiC+anomaly)/100
end
function Demand.components(population:number,temperature:number,residential:number,commercial:number)
 finite(population,0,10000);assert(population%1==0,"Population integer")
 finite(temperature,-50,50);finite(residential,0,1.2);finite(commercial,0,1.2)
 local r=population*.0024*residential;local b=.60*commercial
 local h=population*.00008*math.max(0,18-temperature)
 local c=population*.00006*math.max(0,temperature-24)
 local total=r+b+h+c
 assert(total<=10,"Demand design cap exceeded")
 local kw=math.floor(total*1000+.5)
 return {residentialMW=r,commercialMW=b,heatingMW=h,coolingMW=c,rawMW=total,
  demandMW=kw/1000,quantizationMW=kw/1000-total,temperatureC=temperature}
end
function Demand.atStep(step:number,meanCentiC:number,population:number)
 finite(step,0,1000000000);assert(step%1==0,"Step integer")
 finite(meanCentiC,-4000,4000);assert(meanCentiC%1==0,"Integer climate")
 finite(population,0,10000);assert(population%1==0,"Integer population")
 -- Common denominator preserves exact component sums before the one kW rounding.
 local twice=(1440+step*2+1)%2880;local minute=twice/2
 local hour=math.floor(twice/120);local fraction=twice%120
 local function factor(values:{number}):number
  return values[hour+1]*120+(values[(hour+1)%24+1]-values[hour+1])*fraction
 end
 local t=(twice-480)%2880
 local anomaly=if t<=1440 then -720000+t*1000 else 720000-(t-1440)*1000
 local temperatureNumerator=meanCentiC*1440+anomaly
 local denominator=14400000000
 local r=population*24*factor(Demand.RESIDENTIAL)*12
 local b=factor(Demand.COMMERCIAL)*72000
 local h=population*8*math.max(0,18*144000-temperatureNumerator)
 local c=population*6*math.max(0,temperatureNumerator-24*144000)
 local total=r+b+h+c;assert(total<=10*denominator,"Demand design cap exceeded")
 local mw=math.floor((total*1000+denominator/2)/denominator)/1000
 local result={residentialMW=r/denominator,commercialMW=b/denominator,heatingMW=h/denominator,
  coolingMW=c/denominator,rawMW=total/denominator,demandMW=mw,
  quantizationMW=mw-total/denominator,temperatureC=temperatureNumerator/144000}
 return result,minute
end
return table.freeze(Demand)
