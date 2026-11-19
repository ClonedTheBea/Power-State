"""Design-only arithmetic for the existing Operations radial scenario. No Roblox access.
This analytical total-dispatch calculation is not a replacement for FleetSolver.
Prices, wind hash, demand, floor rounding and minute indexing mirror v1.
"""
import json
from pathlib import Path


def wind(step):
    def knot(hour):
        h = 21
        for ch in "operations.wind.v1|coastal-training":
            h = (h * 48271 + ord(ch)) % 2147483647
        h = (h + hour * 104729) % 2147483647
        for _ in range(3):
            h = h * 48271 % 2147483647
        return h % 801
    hour, part = divmod(step, 60)
    return ((knot(hour) * (60-part) + knot(hour+1) * part) // 60) * 2


def demand(step):
    phase = step % 240
    total = 3000 + phase*50 if phase <= 60 else 6000 if phase <= 120 else 6000-(phase-120)*50 if phase <= 180 else 3000
    east = 3500 if 90 <= phase <= 120 else total // 2
    return total-east, east


def replay(capacity, minutes, policy="ready"):
    energy = [0, 0, 0]
    online = [0, 0, 0]
    delivered = requested = 0
    first_affordable = 0
    bank = 100000
    for step in range(minutes):
        north, east = demand(step)
        potential = wind(step)
        # Policies match across comparisons; no automatic control is proposed.
        peak_on = policy == "ready" or (policy == "responsive" and north+east > 5000+potential)
        available = 5000+potential+(2000 if peak_on else 0)
        flow = min(available, north+min(east, capacity))
        w = min(potential, flow)
        g = min(5000, flow-w)
        peak = flow-w-g
        assert 0 <= peak <= (2000 if peak_on else 0)
        for i, v in enumerate((g, w, peak)):
            energy[i] += v
        online[0] += 1
        online[1] += 1
        online[2] += int(peak_on)
        delivered += flow
        requested += north+east
        sales = delivered*12000//60000
        variable = sum(e*r//60000 for e,r in zip(energy,(8000,0,11000)))
        fixed = sum(t*1000*r//60000 for t,r in zip(online,(1000,600,200)))
        bank = 100000+sales-variable-fixed
        if bank >= 75000 and first_affordable is None:
            first_affordable = step+1
    return dict(minutes=minutes,capacityKW=capacity,policy=policy,requestedMWh=requested/60000,
        deliveredMWh=delivered/60000,sourceMWh=[v/60000 for v in energy],salesMinor=sales,
        variableMinor=variable,fixedMinor=fixed,netMinor=sales-variable-fixed,bankMinor=bank,
        energyReliability=delivered/requested,first750CreditsStep=first_affordable)


def main():
    assert [wind(s) for s in (0,60,120,180,240)] == [1150,64,580,1096,1124]
    assert demand(90) == (2500,3500)
    results=[]
    for minutes in (120,240,1440,10080):
        for policy in ("ready","off","responsive"):
            base=replay(3000,minutes,policy)
            for cap in (3500,4000):
                upgraded=replay(cap,minutes,policy)
                gain=upgraded["netMinor"]-base["netMinor"]
                results.append(dict(base=base,reinforced=upgraded,
                    extraMWh=upgraded["deliveredMWh"]-base["deliveredMWh"],incrementalNetMinor=gain,
                    extrapolated500CreditPaybackSimHours=(50000/gain*minutes/60 if gain>0 else None)))
    output=Path(__file__).resolve().parents[1]/"docs/NATIONAL-GRID-REINFORCEMENT-CALCULATIONS.json"
    output.write_text(json.dumps({"method":"Analytical radial design replay, not engine/solver acceptance", "proposedPriceCredits":500,"results":results},indent=2)+"\n",encoding="utf-8")
    for r in results:
        if r["reinforced"]["capacityKW"]==4000:
            print(r["base"]["minutes"],r["base"]["policy"],"extra MWh",round(r["extraMWh"],6),"extra Credits",r["incrementalNetMinor"]/100,"payback hours",r["extrapolated500CreditPaybackSimHours"],"base net",r["base"]["netMinor"]/100)

if __name__ == "__main__":
    main()
