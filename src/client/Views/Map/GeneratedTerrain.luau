--!strict
-- Cosmetic raster of the server descriptor. No climate, legality or demand calculation.
local C=require(script.Parent.Parent.Components)
local T=require(script.Parent.Parent.Parent.Theme)
local Geometry=require(script.Parent.MapGeometry)
local Fixture=require(script.Parent.MapFixture)
local Terrain={}
function Terrain.create(parent:Instance,world:any)
 assert(world.width==1024 and world.height==1024 and #world.samples==289,"Generated descriptor bounds")
 local root=C.frame(parent,"GeneratedNativeTerrain");root.BackgroundTransparency=1
 root.Size=UDim2.fromOffset(1024,1024)
 local scale=Instance.new("UIScale");scale.Parent=root
 local cells:{GuiObject}={}
 for row=0,15 do for col=0,15 do
  local p=world.samples[row*17+col+1]
  local colour=if p.elevationM<=0 then T.map elseif p.elevationM<12 then T.coast
   else T.land:Lerp(T.hill,math.clamp((p.elevationM-40)/160,0,1))
  local tile=C.frame(root,"TerrainCell",colour)
  tile.Position=UDim2.fromOffset(col*64,row*64);tile.Size=UDim2.fromOffset(64,64)
  table.insert(cells,tile)
 end end
 -- Empty generated-art collections share the authored renderer's typed contract.
 local entries:{{root:Frame,detail:Frame,patch:Fixture.Patch}}={}
 local shores:{{root:Frame,patch:Fixture.Patch}}={}
 return {root=root,entries=entries,shores=shores,setReplacements=function(_value:{[string]:boolean})end,
  -- Presentation adapter hook; normal terrain remains Frames. The Test adapter
  -- replaces each slot once, keeping this culling closure bound to live objects.
  replaceCells=function(factory:(GuiObject,number)->GuiObject):{GuiObject}
   for i,old in cells do local replacement=factory(old,i);cells[i]=replacement;old:Destroy() end
   return cells
  end,
  render=function(x:number,y:number,zoom:number,size:Vector2)
   root.Position=UDim2.fromOffset(x,y);scale.Scale=zoom
   for i,tile in cells do
    local col=(i-1)%16;local row=math.floor((i-1)/16)
    tile.Visible=Geometry.intersects(x+col*64*zoom,y+row*64*zoom,64*zoom,64*zoom,size.X,size.Y,0)
   end
  end}
end
return table.freeze(Terrain)
