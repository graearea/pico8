pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--internal
local doggle
local butcher
local cnt=0
function _update()
 cnt+=1
 doggle:move()
 if (cnt%2==0) then
  butcher:move()
 end
end

function _draw()
  frame=(doggle.walk%10)%2
  rectfill(0,0,127,127,3)
  sspr(frame*8,0,8,8,
   doggle.x,doggle.y,
   8,8,doggle.goingleft)
  sspr(5*8,0,8,8,
   butcher.x,butcher.y,
   8,8,butcher.goingleft)
end

function _init()
 doggle=doggle()
 butcher=butcher(doggle)
end

-->8
--doggle
function doggle()
 return {
 goingleft=false,
 walk=0,
	x = 64,  
	y = 64,
 move = function(self)

  if (btn(0)) then 
	  self.x=self.x-1
	  self.goingleft=true 
	  self.walk+=1
  end

  if (btn(1)) then 
	  self.x=self.x+1 
	  self.goingleft=false
	  self.walk+=1
  end

  if (btn(2)) then 
	  self.y=self.y-1 
	  self.walk+=1
  end

  if (btn(3)) then 
		 self.y=self.y+1 
  	self.walk+=1
  end  

 end
 }
end
-->8
--butcher
function butcher(doggle)
 return {
  goingleft=false,
  walk=0,
	 x = 64,  
	 y = 64,
	 move=function(self)
	  if(doggle.x<self.x) then
	   self.x=self.x-1
	   goingleft=true
	  else
	   self.x=self.x+1
	   goingleft=false
	  end
	  if(doggle.y<self.y) then
	   self.y=self.y-1
	  else
	   self.y=self.y+1
	  end
	 end
 }
end
__gfx__
00000f0000000f0000000f0f00040000000400000770000007700000000099000000000000000000000000000000000000000000000000000000000000000000
00000ff000000ff0000008f000fff00000fff0007777000077770000000944000000000000000000000000000000000000000000000000000000000000000000
f0000ff4f0000ff4f0ffffff000f0000000f0000f0f00000f0f06800000440000000000000000000000000000000000000000000000000000000000000000000
0fffff000fffff000ffffff800ff0000000ff0000fff00000fff6800000440000000000000000000000000000000000000000000000000000000000000000000
0fffff000fffff000ff8ff0000fff00000fff0000770000007706600000440000000000000000000000000000000000000000000000000000000000000000000
0f4444000f4444000f80ff0000fff00000fff0000777466607774000000449000000000000000000000000000000000000000000000000000000000000000000
f0000f000f0000f00f80fff0000ff00000ff00000770068807700000000044000000000000000000000000000000000000000000000000000000000000000000
400004000400000408f00ff000f000000000f0000707000000770000000000000000000000000000000000000000000000000000000000000000000000000000
