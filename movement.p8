pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
 target={x=80, y=80,speed=3}
 rectfill(0,0,128,128,9)
 chase={x=60,y=60,speed=1}
end

function _update()
 local dx=0
 local dy=0
 if (btn(⬅️)) then dx=-1 end
 if (btn(➡️)) then dx=1 end
 if (btn(⬆️)) then dy=1 end
 if (btn(⬇️)) then dy=-1 end   
 vector=move_target(dx,dy,target)
 move_chase(chase,target)
end

function move_chase(chase,target)
 chase_angle=calc_dir(target.x-chase.x,chase.y-target.y)
 chase_vector=calc_vector(chase_angle,chase.speed)
 chase.x=chase.x+chase_vector.x
 chase.y=chase.y+chase_vector.y
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


function _draw()
 rectfill(0,0,128,128,9)
 circfill(target.x,target.y,10,10)
 circfill(chase.x,chase.y,10,11)
 print(angle,100,100,black)
 print((vector.dx) .. "," .. (vector.dy) ,100,90,black)
 
end

function move_full(dx,dy)
    angle=calc_dir(dx,dy)
    if angle==nil then return end
    local vector=calc_vector(angle,3)
    x=x+vector.x
    y=y+vector.y
   end
   
function calc_dir(diff_x,diff_y)
 if diff_x==0 and diff_y==0 then return nil end
 return ((atan2(diff_x,diff_y)*360))%360
end

function calc_vector(angle,speed)
 new_dx=(speed*cos(-angle/360))
 new_dy=(speed*sin(-angle/360))
 return {x=new_dx,y=new_dy}
end


__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
