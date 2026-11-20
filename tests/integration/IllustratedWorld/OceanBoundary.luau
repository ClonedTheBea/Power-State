--!strict
-- Cosmetic water colour only. Never samples or assigns land ownership.
local Ocean={}
Ocean.DEEP=Color3.fromRGB(24,53,70)
function Ocean.weight(x:number,y:number):number
 -- A one-cell shoulder inside known data; zero at/outside the finite boundary.
 local t=math.clamp(math.min(x,y,1024-x,1024-y)/64,0,1)
 return t*t*(3-2*t)
end
function Ocean.colour(x:number,y:number,shallow:number,grain:number):(number,number,number)
 local w=Ocean.weight(x,y)
 return 24+(7*shallow+grain)*w,53+(25*shallow+grain)*w,70+(20*shallow+grain)*w
end
return table.freeze(Ocean)
