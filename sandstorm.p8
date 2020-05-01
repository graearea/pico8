pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
 target={x=80, y=80,speed=3}
 rectfill(0,0,128,128,9)
 curr_elem=1
 bgc=6
end

function _draw()
 rectfill(0,0,128,128,6)
 print(elements[curr_elem].name,100,80,black)
 local x=target.x
 local y=target.y
 line(x-3,y,x-2,y,7)
 line(x+3,y,x+2,y,7)
 line(x,y-3,x,y-2,7)
 line(x,y+2,x,y+3,7)
 draw_particles()
end

function _update()
 local dx=0
 local dy=0
 if (btn(⬅️)) then dx=-1 end
 if (btn(➡️)) then dx=1 end
 if (btn(⬆️)) then dy=-1 end
 if (btn(⬇️)) then dy=1 end   
 if (btn(❎)) then sprinkle() end
 if (btn(🅾️)) then change() else btn_up() end
 
 vector=move_target(dx,dy,target)
 apply_gravity()
end

particles={}

states={
  solid={
   move=function(x,y) 
    return {{y=y+1,x=x}}
   end
  },
  liquid={
   move=function(x,y) 
    return {
     {y=y+1,x=x},
     {y=y+1,x=x+1},
     {y=y+1,x=x-1}
    }    
   end
  }
}
elements={
 {name="sand",colour=15,state=states.solid},
 {name="water",colour=12,state=states.liquid},
}


function sprinkle()
 local rndx=rnd(4)-2
 local rndy=rnd(4)-2
 add(particles, new_particle(target.x+rndx,target.y+rndy))
end

btndown=false

function change()
 if not btndown then
  curr_elem=((curr_elem)%#elements)+1
  btndown=true
 end
end

function btn_up()
 btndown=false
end

-->8
--particles
function apply_gravity()
 for p in all(particles) do
  p:fall()
 end
end

function draw_particles()
 for p in all(particles) do
  pset(p.x,p.y,p.element.colour)
 end
end
	
function new_particle(x,y)
 return particle(x,y,elements[curr_elem])
end

function particle(x,y,element)
 return {
  x=x, 
  y=y, 
  element=element,
  fall=function(self)
   moves=element.state.move(self.x,self.y)
   for move in all(moves) do
    if is_clear(move.x,move.y) then
      self.x=move.x
      self.y=move.y
      break
    end
   end
  end
 }

end

function is_clear(x,y)
 return pget(x,y)==bgc or pget(x,y+1)==7
end

function move_target(dx,dy,obj)
 if dx==0 and dy==0 then return {dx=0,dy=0} end
 obj.x=obj.x+dx
 obj.y=obj.y+dy
 return {dx=new_dx,dy=new_dy}
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
