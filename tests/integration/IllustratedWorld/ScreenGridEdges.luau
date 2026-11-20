--!strict
-- Round a shared world boundary once in the unscaled common parent space.
-- floor(v+.5) is intentional for negative coordinates as well as positive ones.
local Edges={}
function Edges.axis(origin:number,zoom:number,count:number,step:number):{number}
 assert(origin==origin and math.abs(origin)<1e7 and zoom>0 and zoom<10,"Finite bounded screen transform")
 assert(count>=1 and count<=256 and count%1==0 and step>0,"Bounded grid")
 local result:{number}={}
 for i=0,count do result[i+1]=math.floor(origin+i*step*zoom+.5) end
 return result
end
return table.freeze(Edges)
