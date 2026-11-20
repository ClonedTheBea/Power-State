--!strict
-- Seven scanlines, not a permanent sector mask. Ground colours remain world aligned.
local Ribbon={}
function Ribbon.rows(coast:any,startX:number,startY:number)
 local rows:{buffer}={};local origin=startY-3
 local function fill(row:buffer,y:number)
  for i=0,519 do buffer.writeu8(row,i,if coast.sample(startX+i-3+.5,y+.5) then 1 else 0)end
 end
 for y=origin,origin+6 do local row=buffer.create(520);fill(row,y);table.insert(rows,row)end
 return function(py:number,px:number):(boolean,number)
  local y=startY+py
  if y-3>origin then
   assert(y-3==origin+1,"Sequential row composition")
   local row=table.remove(rows,1);origin+=1;fill(row,origin+6);table.insert(rows,row)
  end
  local i=px+3;local land=buffer.readu8(rows[4],i)==1
  if not land then return false,0 end
  for d=1,3 do
   if buffer.readu8(rows[4],i-d)==0 or buffer.readu8(rows[4],i+d)==0
    or buffer.readu8(rows[4-d],i)==0 or buffer.readu8(rows[4+d],i)==0 then return true,d end
  end
  return true,0
 end
end
-- Restrained sand/stone colour family of the approved shore artwork; no new art ID.
-- The ribbon is entirely land-side. No foam/alpha expansion changes the water mask.
function Ribbon.colour(distance:number,grain:number,r:number,g:number,b:number):(number,number,number)
 if distance==0 then return r,g,b end
 local strength=if distance==1 then .88 elseif distance==2 then .65 else .25
 local light=if distance==1 then -14 elseif distance==2 then 10 else 0
 return r*(1-strength)+(157+light+grain)*strength,
  g*(1-strength)+(155+light+grain)*strength,b*(1-strength)+(119+light+grain)*strength
end
return table.freeze(Ribbon)
