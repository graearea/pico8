pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
 target={x=80, y=80,speed=3}
 rectfill(0,0,128,128,9)
 curr_elem=0
end

function _update()
 local dx=0
 local dy=0
 if (btn(⬅️)) then dx=-1 end
 if (btn(➡️)) then dx=1 end
 if (btn(⬆️)) then dy=1 end
 if (btn(⬇️)) then dy=-1 end   
 if (btn(❎)) then sprinkle() end
 if (btn(🅾️)) then change() end
 vector=move_target(dx,dy,target)
end

particles={}

function draw_particles()
 for p in all(particles) do
  pset(p.x,p.y,p.elem)
 end
end

function sprinkle()
 add(particles, new_particle(target.x,target.y))
end

function change()
 print(curr_elem,100,80,black)
 curr_elem=((curr_elem+1)%4)+1
end

function new_particle(x,y)
 return {x=x, y=y, element=curr_elem}
end

function _draw()
 rectfill(0,0,128,128,1)
 print(angle,100,100,black)
 print((vector.dx) .. "," .. (vector.dy) ,100,90,black)
 local x=target.x
 local y=target.y
 line(x-3,y,x-2,y,7)
 line(x+3,y,x+2,y,7)
 line(x,y-3,x,y-2,7)
 line(x,y+2,x,y+3,7)
 draw_particles()
end

function move_target(dx,dy,obj)
 if dx==0 and dy==0 then return {dx=0,dy=0} end
 angle=  ((atan2(dx,dy)*360))%360
 new_dx=(obj.speed*cos(-angle/360))
 new_dy=(obj.speed*sin(-angle/360))
 obj.x=obj.x+new_dx
 obj.y=obj.y+new_dy
 return {dx=new_dx,dy=new_dy}
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
