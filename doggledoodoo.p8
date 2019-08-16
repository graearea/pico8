pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
x = 64  y = 64
goingleft=false
function _update()
  if (btn(0)) then 
  x=x-1
  goingleft=true 
  walk+=1
  end
  if (btn(1)) then 
  x=x+1 
  goingleft=false
  walk+=1
  end
  if (btn(2)) then 
  y=y-1 
  walk+=1
  end
  if (btn(3)) then 
  y=y+1 
  walk+=1
  end
  
end

walk=0
function _draw()
  frame=(walk%10)%2
  rectfill(0,0,127,127,3)
  sspr(frame*8,0,8,8,x,y,8,8,goingleft)
end
__gfx__
00000f0000000f0000000f0f0000990000000f000770000007700000000000000000000000000000000000000000000000000000000000000000000000000000
00000ff000000ff0000008f00009440000000ff07777000077770000000000000000000000000000000000000000000000000000000000000000000000000000
f0000ffff0000ffff0ffffff00044000f0000ffff0f00000f0f06800000000000000000000000000000000000000000000000000000000000000000000000000
0fffff000fffff000ffffff8000440000fffff000fff00000fff6800000000000000000000000000000000000000000000000000000000000000000000000000
0fffff000fffff000ff8ff00000440000fffff000770000007706600000000000000000000000000000000000000000000000000000000000000000000000000
0f4444000f4444000f80ff00000449000f4444000777466607774000000000000000000000000000000000000000000000000000000000000000000000000000
f0000f000f0000f00f80fff000004400f0000f000770068807700000000000000000000000000000000000000000000000000000000000000000000000000000
400004000400000408f00ff000000000400004000707000000770000000000000000000000000000000000000000000000000000000000000000000000000000
