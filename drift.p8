pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()

car=car(64,64) 
blobs={}
end
	
function _update()
  if (btn(⬅️)) then car.angle-=10 end
  if (btn(➡️)) then car.angle+=10 end
  car:move()
end

function _draw()
  camera(car.x-58,car.y-58)
  rectfill(0,0,1024,1027,15)
  map(0, 0, 0, 0, 1024, 32)
  circfill(128,128,96,6)
   circfill(128,128,64,15)
  car:draw()
  
end
function printstatus(text)
 print(text)
end
function round(num,places)
  return flr(num*10^places)/10^places
 end
-->8
--car

function car(ix,iy)
	return {
	d_travel=0,
	angle=0,
	x=ix,
	y=iy,
	speed=3,
	skidmarks={},
	move=function(self,v)
	 delta_angle= self.d_travel-self.angle
	 self.d_travel= self.d_travel-delta_angle/40
		dx=(self.speed*cos(-self.d_travel/360))
  dy=(self.speed*sin(-self.d_travel/360))
  self.x=self.x+dx
  self.y=self.y+dy
  add(self.skidmarks,{x=self.x,y=self.y})
	end	,

	draw=function(self)
	 print("bob",self.x+64,self.y+120)
	 for sx,sy in pairs(self.skidmarks) do
	 	print(self.x,self.y)
		 circfill(sx,sy,1,4) 
	 end
	 spr_r(0,self.x,self.y,self.angle)
 end

	}
end


function spr_r(s,x,y,a)
  sw=(32)
  sh=(32)
  sx=(s%18)*18
  sy=flr(s/20)*20
  x0=flr(18)
  y0=flr(14)
  a=a/360
  sa=sin(a)
  ca=cos(a)
  for ix=0,sw-1 do
   for iy=0,sh-1 do
    dx=ix-x0
    dy=iy-y0
    xx=flr(dx*ca-dy*sa+x0)
    yy=flr(dx*sa+dy*ca+y0)
    if (xx>=0 and xx<sw and yy>=0 and yy<=sh) then
					sprite=sget(sx+xx,sy+yy)    
					if(sprite!=0) then
		     pset(x+ix,y+iy,sget(sx+xx,sy+yy))
     end
    end
   end
  end
 end
__gfx__
00000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000200000000000000a0000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000030000000000000200000000000000a00000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c0011110000000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c0ccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c08ccccccccc111cccc7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c08c11ccccc1111cccc7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000cc8c11ccccc1111cccc7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000cccc11ccccc1111cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000cccc11ccccc1111cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000cccc11ccccc1111cccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000cc8c11ccccc1111cccc7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c08c11ccccc1111cccc7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c08ccccccccc111cccc7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c0ccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c0011110000000011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000070700000000000000000000000000000000000000000500000000000000000000000000000000000000000000000500000000000000000000000000000
00000000000000005000000000000000000000000000000000000000000000000000000000005000000000000000000000000040000000000000000000000000
00000000007000000000000000000000005000000000400000000000000000000000000000000000000000000000000000000070000000000000000000005000
00000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000400000000000000000000000
00000000000000700000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000500000000000
00000000000000000000000000500000000000000000000000005000000000000000005000000000000000000000000000000000400000000000000000000000
00000000000000000000000000000000000000000040000000500000000000000000000000005000000050000050000050000000000000700000000000000050
00000000000000005000000000000000000000005000000000007000000000000000000000000000000000000000000050000000004050000000000000000000
00000000000000000000700000000000000000000000000000500000000000000000000000500000000000000000000050500000000000000000000000000000
00000000000000000000000000000000005000404000000000000000500000000000000000000000000000005000000000000000000000000000000050000000
00000000000000000000000000000000000000000000000000005000004040400040000040000000000000000000000000505000000000000000005000000000
00000000000000000000000000000000000000400000000000000000000000700000000000000000005000000000000000000000004040000000000000000000
00500000000000000000000000007000000000005040000000000040000000000000000000000000400000000000000000000000500000000000007000005000
00000000000000000000000000000000000040000000000000000000000000000070000000000000000000000000000000000000000040000000000000000000
00000000000000000000000000000000000000000000000000000050000000000000000000000000000000004000000040000000005000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000004000000000000000000000
00000000500000500000000000000000000000700000500000000000000000000000000050000000000000000000000000004040505000000000500000007000
00000000000000000000000000000000000040000000000000000000005000000000000000000050000000500000000000000040000000000000000000000000
00000000000000000000000000000000000000000000000050000000000000500000000000000000000000000000000000000040000000000000005000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000500040000000000000000000000000
70000000000000000000000000000000004000000000000000000000500000000000000000000000000000005000000040000000000000000000000000000000
00000000000000500000000000000000000040000000000000007000500000000050000000500050000000000000500050000040000000000000000000000000
00007000700000000000000000000000400000000000000000000000500000000000000000500000000000504050000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000005000000000500000000000000000405000000000000000000000
00000000007000000000000050000000404040404000000000000000000000000000000000000000404040000050000000000000000000000000000000000000
00000000000000500000000000000000000000000000000000000000700000000000000000000050000000000000000000000000000000000000000000000000
00000000000070000000000050000000000000000000400050000000005000500000000000004040000000505000005000500000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000005000000000400000000000000000005000
00005000500000707000000000000000000050000000004000000000000000000000005000004040000000000050000000000050000050005000000000000000
00000000000000005000000000000000000000000000000000000000000070000000004040000000000000000000000000005000000000000000500000000000
00000000505050000000000000500000005000000000004000000000000000500000000040400000504000000000000000000000000000005000000000000000
00000000000000005050500000000000000000000000000000000000000000000000400040000000000000000000000000000000400000005000000000000050
00000000000050000000000050000000005000000000000040400000000000000000500040000000500050500000000000000000000000005000000000000000
00000000000000005050500000004000000000000000000000000000000000007040404000000000005000000000000000000050000050000000000050000000
00500000005050005050505050000000000000000000000000004000000000000000404000000000500000504000000000000000000000000050000000000000
00000000000000000000000050000000000000000000005000000000000000004040400000000000000000000000000000000000000000000000000000000000
50505050000000000000000000000000000050000000000000000040000000000000005050505000005000000000000000000000000000000000500000000000
00000000000000000000000000000000000000000000500000004040004040404000700000000000000000000000000000000000004000000000000000000000
00000000000000000000000000000000000000000050000000000000004000004000400050000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000
00000000000000000000000000000000000000000000000000500000000040000000000000000000000000000000000000400000000000000000500000000000
00000000000000000000000040000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000050000000000000000000000070000050000000000000000050000000004000500000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000005000000000
00500000000000000000000000000000000000000000000000000000000000000000005040707000000000000000000000005000000040000050400000000000
00004000000000004000400000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000500000000000
00000000000000000000400000000000000000000000000000000000000000000000500000007070700050000000000000000000000000500050000000000000
00000000000040000000000000000000000000000000505000000000000000000000000000000000000000000000000000000050000040000000000000000000
00000000000000000040000000000000000000000000000000005000000000000000000000000040000000000000000000000000505050000000000050000000
00005000000000400040000000000000000000000000000050000000004000000000000000000000000000000000000000000000000000404050000000000000
00000000000000004000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000
00000000000000500000004000400000400040400000004000400040504040000040004000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005000000000000000000000000000000000000000004000000000500000404000000000000050000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000500000000000000000000000000000000000000000000040000000000000004000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000
00000000000050000000000000000000000000000000000000000000000000400000000000004000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000500000000000005000000000000000000050000000000000500000
00005000000000000000000000000000000000000000000000000000000000000040004000400000000000000000000000000000000000000000000000000000
__map__
0000000505050000000000070000000000000000000005000000000000050500050500050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000050000050000000000000700000000000000000000050000040000050000000000000000000000040000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005070707000500000000000007000505050000000000000500040000050000000707000505000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0005070000070700050707070707050000000000000000000000000000000000000007000005000000000004040400000000000000000000000000000000000000000000000000000000050005000005000005000500000500000005000000000500000000000000050000000000050000000500000505000000000000000000
0005050000000005050507000007070000000000000000000005000000000500000000000000050000000400000000000000000000000000000000000000000000000000000500050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000070005000505000700050000070000000000000000000004000000000000070004040404040404040000000000000000000000000000000000000000000000000000000500040000000000000000000000000000000000000000000000000000000000000000000000000000040404000000000000000000000000000000
0000000705050500000700000000070500000500050500000000000000040000000500000000000000000000000000000000000000000000000000000000000000000000000500040000000000000000000000000000000000000000000000000000000004000004000004000000000000000000000000000000000000000000
0000000705000005070000000000000000070000050500050000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000400040000040000000004000000000004000000000000000400040000000000000000000000000000000000000000000000000000000000
0000000707000707050005000404040404000000000505000004000000000700000000050000000000000000000000000000000000000000000000000000000000000000000500000007000000000000000000050505050500000000000000000004000005000700000000000000000000000000000000000000000000000000
0000000000000707070707070507070707000005050700050000000500000405050000050000000000000000000000000000000000000000000000000000000000000000000000050007000000000000000005050000000000000000000000000004000500000705000000000000000000000000000000000000000000000000
0000000000070000000000000005000000000405000000000000000705000000050000050000000000000000000000000000000000000000000000000000000000000000000000000000070000000000050005000000000000050000000000000000000004000007000000000000000000000000000000000000000000000000
0000000000000000000000000000050004040005000000000007040400000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000005000000000000000000000000000000000000000000070004000000000000000400000400040400000000000000
0000000700000000000400000000040500000505000000040000000707000005000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000705000700000000000000000000000004000000000000000007000004000000000000040000040400000000000000
0000000000000000000000000000000000000000000004000700000000000000000505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000700000007000000000000000000000000000000000000000000000000000000000000000000000000
0000000700000400000000040000000500000005000004000000000404050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700050005050000000000000000000007000000000700000007000000070507000000000500000000000000000000
0000000700000000000400000000000005000005000400000004000004040000050000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000500000000000000070000000707070707070700000000000000
0000040704000000000400000000000000000000000007000000000500040000000000000000000000000000000000000007070000000000000000000000000000000000000000000000000000000000000000000005050505000000000000000000000000000000000000000000000000000000000000000007070000000000
0000040704000404040000000000000000050005000700000000040000000000050000000004000004000004000004000000000007000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000050000000000
0000040707000000000000000000000000000707050000000005050000040000000000000000000000000000000000040000000000000700000000000000000000000005000000000000000000000000000000000000000005050705000000000000000000000000000000000000000000000000000000000000050000000000
0000000400000000000000000000000000070705050000050000040000000000000500000000000000000000000000040000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000007070000000000000000000000000000000007000000000000000000
0000000000070505050000000000000000000700050505050000000404000400000500000000000000000000000004000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000700000000000000000700000000000000000000000000000000000000050000000000
0000000000050000070000000500000000070700050505050505050404000000040500040000000404000004000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000700000000000000070007000400000000000000000000000007000000000000
0000000005000004000000000704000704070500050505000000000004040400000400000000000000000000040400000000000000000000000000000000000007000400000000000000000000000005000404000000000000000000000005000007000000000000000000000404070007000000000000000005000700000000
0000000005000000040000040400050000000000040500000005000000050004000000000000000000000000040000000000000000000000000000000000000000000000000000040000000400040504040004000404000000000000000500000500070000000000000000000000000000070007070707070700000000000000
0000000000000000000404000000000000000000000400000004000004000407070500000000000000000000040000000000000000000005000000000000000000000000000007000000000000000000050000000000000400000400000500000000000000000000000000000000040000000000000000000707070007000000
0000000500000000000500000000000000050500000000000000000000050000000700000000000000000000040000000000000000000000000000000000000000000000000000000000000500000000050000000000000000000000000004000400040700000000000000000000000000000000000000000000000000000000
0000000500050000000005000000000000050000000000000000000000000000040000070000000000000000000400000000000000000000000000000000000000000000000000000000000700000005000000000005000000000000000505000000000000070000000000000000000400000000000000000000000000070700
0000000000000000000000000000000005000000000000000000000000000000000004000007000000050000000004000000000000000000000000000000000000000000000000000005000005000000000000000000000000000005000500000000000000000007000000000000000000000000000000000500000000000700
0000000000000005000000000000000000000000000000000000000000000000000000000000000700000000000000040000050500000000000000000000000000000000000000000000000000000507000000000000000000000000000000000000000000050000070000000000000000040000000000000000000000000700
0000000000000000000000000000000400000404040400000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000500000000000000000000
0000000000000000000000000000000005000000000000000000000000000500000000000500000005000000000700000000000005000005000000000000000000000000000000000005000005000000000000000000000000000000000000000500000000000500000000000000000000000405000000000000000000000000
0000000700000000000000000000000000000000000400000000000000000000000000000000000000000000000000000700000000000000050000000005000000000000000000000000000000000000000000000007000000000000000000050000000000000000000500000005000000000000000000000000000000000000
