pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
 target={x=80, y=80,speed=3}
 rectfill(0,0,128,128,9)
 curr_elem=1
 bgc=6
 build_world()
 add_test_particles1()
 frame=10000
 pushed_count=10000
end
LEFT=-1
RIGHT=1
bob=""
world={}
function build_world()
 for strata=1,128 do --y axis
  world[strata]={} --x axis
 end
end


function _draw()
 printh("pushed " .. pushed_count)
 pushed_count=10001
 rectfill(0,0,128,128,6)
 print(elements[curr_elem].name,100,80,black)
 print(bob,100,90,black)
 print(#particles,0,0,black)
 -- print(stat(1),0,10,black) --CTRL-P FTW!
 local x=target.x
 local y=target.y
 line(x-3,y,x-2,y,7)
 line(x+3,y,x+2,y,7)
 line(x,y-3,x,y-2,7)
 line(x,y+2,x,y+3,7)
 draw_particles()
end

function _update()
 frame+=1
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
  hard={
   move=function(x,y) 
    return {{y=y+1,x=x}}
   end
  },
  soft={
   move=function(x,y) 
    return {
     {y=y+1,x=x},
     {y=y+1,x=x+1},
     {y=y+1,x=x-1}
    }    
   end
  },
  liquid={
   move=function(x,y) 
    return {
     {y=y+1,x=x},
     {y=y+1,x=x+1},
     {y=y+1,x=x-1},
    }    
   end,
   pushed=function(x,y) 
    return {
     {y=y,x=x+1},
     {y=y,x=x-1},
     {y=y-1,x=x},
     {y=y-1,x=x+1},
     {y=y-1,x=x-1},
    }    
   end

  }

}
elements={
 {name="stone",colour=5,state=states.hard,weight=10},
 {name="sand",colour=15,state=states.soft,weight=10},
 {name="water",colour=12,state=states.liquid,weight=5},
}

function surroundings(x,y,dir) 
  return {
   {y=y,x=x+dir},
   {y=y,x=x-dir},
   {y=y-1,x=x},
   {y=y-1,x=x+dir},
   {y=y-1,x=x-dir},
   {y=y+1,x=x}, --are these needed?
   {y=y+1,x=x+dir},
   {y=y+1,x=x-dir},
  }    
end

function lowest_pressure_neighbour(x,y,curr_weight,dir)
 local best =curr_weight
 local surr=surroundings(x,y,dir)
 for _,neigh in pairs(surr) do
  ralf = get_world(neigh.x,neigh.y)
  local weight =ralf.weight
  if(ralf == nil or weight<best) then
   if ralf == nil then
   else best = ralf
   end
  end
 end
 return best
end

function sprinkle()
 local rndx=rnd(4)-2
 local rndy=rnd(4)-2
 new_particle(flr(target.x+rndx),flr(target.y+rndy))
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


function set_world(x,y,obj)
 world[y][x]=obj
end

function get_world(x,y)
 return world[y][x]
end

-->8
--particles
function apply_gravity()
  
 for strata=1,128 do
  --printh(strata .. " strata: " .. #world[strata])
  for j,p in pairs(world[strata]) do
   --printh("weight=" ..p:calc_weight())
  end
 end
 for p in all(particles) do
  p:fall()
 end
end

function draw_particles()
printh("drawing")
 for p in all(particles) do
  pset(p.x,p.y,p.element.colour)
 end
end
	
function new_particle(x,y)
 local par = particle(x,y,elements[curr_elem])
 set_world(x,y,par)
 add(particles, par)
 return par
end

function particle(x,y,element)
 return {
  x=x, 
  y=y, 
  element=element,
  weight=element.weight,
  frame_completed=0,
  fall=function(self)
   local moves=element.state.move(self.x,self.y)
   for move in all(moves) do

    if not in_world(move.x,move.y) then break end
    
    if is_clear(move.x,move.y) then
     self:move_to(move.x,move.y)
     break
    end
    
    local thing= get_world(move.x,move.y)
    if  can_squash(thing,self.element.weight) then
     if thing:push(RIGHT) then
      self:move_to(move.x,move.y)
      break
     elseif thing:push(LEFT) then
      self:move_to(move.x,move.y)
      break 
     end          
    end
   end
  end,
  push=function(self,direction)
   if (self.frame_completed==frame) then return end
   pushed_count+=1
   --lowest_pressure_neighbour(self.x,self.y,self.weight,direction)
   --local locn={y=self.y,x=self.x+direction}
   if is_pushed(self.x+direction,self.y,self.element.weight,direction) then
    self:move_to(self.x+direction,self.y)
    self.frame_completed=frame
    return true
   end
    
   self.frame_completed=frame
   return false
  end,
  move_to=function(self,dx,dy)
   set_world(self.x,self.y,nil)
   self.x=dx
   self.y=dy
   set_world(self.x,self.y,self)

  end,
  calc_weight=function(self)
   local above_weight
   local above =get_world(self.x,self.y-1)
   if above == nil then above_weight=0 else above_weight = above.weight end
   self.weight=above_weight+self.element.weight
   return self.weight
  end
 }
end

function is_pushed(x,y, curr_weight,direction)
 local thing= get_world(x,y)
 return thing==nil or (can_squash(thing,curr_weight) and thing:push(direction))
end

function in_world(x,y)
 return y<128 and y>0 and x>0 and x<128
end

function can_squash(thing,weight)  
 return (in_world(thing.x,thing.y) and thing.element.weight<=weight and thing.element.state==states.liquid)
end

function is_clear(x,y,weight)
 bob= x .. y  
 return in_world(x,y) and get_world(x,y)==nil
end

function move_target(dx,dy,obj)
 if dx==0 and dy==0 then return {dx=0,dy=0} end
 obj.x=obj.x+dx
 obj.y=obj.y+dy
 return {dx=new_dx,dy=new_dy}
end
-->8
--testicles
function add_test_particles1()
 curr_elem=1
 new_particle(60,127)
 new_particle(60,126)
 new_particle(70,127)
 new_particle(70,126)
 new_particle(80,127)
 new_particle(80,126)
 new_particle(80,125)
 new_particle(55,127)
 new_particle(55,126)
 new_particle(55,125)
 curr_elem=3
 for y = 100,50,-1 do
  new_particle(62,y)
 end
-- for y = 100,50,-1 do
--  new_particle(68,y)
-- end
 
 -- world[60][127]=new_particle(60,127)
end
 function add_test_particles2()
 curr_elem=1
 new_particle(60,127)
 new_particle(60,126)
 new_particle(64,127)
 new_particle(64,126)
 curr_elem=3
 for y = 105,100,-1 do
  new_particle(61,y)
 end
-- for y = 100,50,-1 do
--  new_particle(68,y)
-- end
 
 -- world[60][127]=new_particle(60,127)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
