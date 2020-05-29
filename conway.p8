pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
new_state={}
old_state={}
tings=0
function build_world()
 for x=0,127 do
   new_state[x]={}
   old_state[x]={}
  for y=0,127 do
   new_state[x][y]=nil
   old_state[x][y]=nil
  end
 end
end

function _init()
rectfill(0,0,128,128,0)
build_world()
rectfill(53,53,54,54,11)
rectfill(03,03,24,24,8)

pset(60,60,7)
pset(62,60,8)
pset(61,61,8)
pset(62,61,7)
pset(61,62,7)

end

function _update()
tings=0
 for y=0,127 do
  for x=0,127 do
  tings+=1
   px=pget(x,y)
   local n_cnt=count_neighbours(x,y)
   if (n_cnt>0) then 
   end
   local alive=nil
   if (n_cnt==2) then 
    alive=(px!=0)
   elseif (n_cnt==3) then 
    alive=true 
   else 
    alive=nil
   end
   new_state[x][y]=alive
  end
 end
end

neybs={
  {x=0-1,y=0-1},
  {x=0,y=0-1},
  {x=0+1,y=0-1},
  {x=0-1,y=0},
  {x=0+1,y=0},
  {x=0-1,y=0+1},
  {x=0,y=0+1},
  {x=0+1,y=0+1},
 }

function count_neighbours(x,y)
 local cnt=0
 for neyb in all(neybs) do
  if (pget(neyb.x+x,neyb.y+y) !=0) then
   cnt+=1
  end
 end
 return cnt
end

function _draw()
 rectfill(0,0,128,128,0)
 for y=0,127 do
  for x=0,127 do
   if new_state[x][y] then
    pset(x,y,9)
   else
    pset(x,y,0)
   end
  end
 end
  printh(stat(1)) --ctrl-p ftw!
 printh(tings)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
