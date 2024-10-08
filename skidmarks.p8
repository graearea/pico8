pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- main
bob=""
started=false
ended=false
printed=false
sound=false
timer_start=0
game_length=60
drawmode="2d"
players=2
--try coroutines for game state

function _init()
lap_count=0
laps={}
blobs={}
window_x=0
window_y=0
handbrake=false
timer=0
dust={}
ghost={}
play_ghost=false
start=42
finish=41
tyres=add_tyres()
ended=false
camera_location={}
ghost_car=car(110,64)
car1=car(70,64) 

if players==2 then
 car2=car(70,80) 
end
--sfx(10,1)
print_skids(skids_l)
menuitem(1,"toggle 3d", function()
 if drawmode=="3d" then
  drawmode="2d"
 else
  drawmode="3d"
 end
end)
end

score=0	
function _update60()
 --do something 
 if car1.skidding then
  current_score=(abs(car1.angle)*car1.speed)/1000
  score+=current_score
 end
 if((started==false or ended==true) and btn(❎)) then
  started=true
  timer_start=time()
  return
 end
  if (time()-timer_start>game_length) then
   ended=true
   started=true
  end
  if (btnp(6)) then
   if drawmode=="3d" then
    drawmode="2d"
   else
    drawmode="3d"
   end
  end

  if(started) then
    timer+=1
    steer(car1,0)  
    car1:move()
    if car2!=nil then 
      steer(car2,1)  
      car2:move()
    end


  
  if players==1 then add(ghost,car1:pos()) end
  for d in all(dust) do
   d:update()
  end
  record_lap()
 end
end

function _draw()
  rectfill(-200,-200,1024,1027,3)
  if drawmode=="3d" then
    local car=car1  
    draw_rotated(car.x/8-2*cos(car.angle/360),car.y/8+2*sin(car.angle/360),1-car.angle/360)
    print("car:" ..car.x..":"..car.y.." bob" .. car.x/8+2*cos(1-car.angle/360).." "..car.y/8-2*sin(1-car.angle/360).." "..1-car.angle/360, 0,0,7)
    print(stat(1),0,10,black) --CTRL-P FTW!

  elseif (ended) then
    drawend()

  elseif (not started) then
   drawstart()

  else 
    if car2==nil then
      window_x=car1.x-58
      window_y=car1.y-58
    else
      window_x=(car1.x+car2.x)/2-58
      window_y=(car1.y+car2.y)/2-58
    end
    camera(window_x,window_y)
    rectfill(-200,-200,1024,1027,3)
    map(0, 0, 0, 0, 1024, 64)
    rectfill(-200,-200,200,16,3)
    --track skids
    draw_skids(skids_l)
    draw_skids(skids_r)
    draw_skids(skids_fl)
    draw_skids(skids_fr)
    
    car1:draw_skids()    
    if car2!=nil then car2:draw_skids()  end
        
    draw_tyres()

    for d in all(dust) do
    d:draw()
    end
    
--    draw_ghost()
    
    car1:draw()
    if car2!=nil then car2:draw()  end
    
    draw_speedo(0)
    print(flr(score),window_x+100,window_y+120,7)
    --print(stat(1),window_x+0,window_y+10,black) --CTRL-P FTW!
    print("lap:"..lap_count.." :"..flr(game_length-(time()-timer_start)), window_x+80,window_y,black)
    print(#lap_scores,window_x+0,window_y+10,black) --CTRL-P FTW!
    
    for lap in all(lap_scores) do
    if lap != nil then
    print("lap:"..lap.count.." :".. lap.score, window_x+80,window_y+7*lap.count,black)
    end
    end
     print(flr(game_length-(time()-timer_start)), window_x+40,window_y,black)
     bob="cpu" ..stat(1) .." ".. stat(7)

    if bob!="" then print(bob,window_x+10,window_y+10) end
  end 
  
end

function steer(car,player)
  if car==nil then return end
  if (btn(0,player)) then 
   car.steer=clamp(car.steer-0.5,-5,5)  
  elseif (btn(1,player)) then 
   car.steer=clamp(car.steer+0.5,-5,5)
  else
   if(car.steer>0) then car.steer-=0.5 end
   if(car.steer<0) then car.steer+=0.5 end
  end
  
  if (btn(5,player)) then 
   car.handbrake=true  
  else
   car.handbrake=false
  end
  if (btn(2,player)) then
   car.accelerate=true
  else
   car.accelerate=false
  end
end

function draw_rotated(mx,my,a)
  cls(13)
  camera(0,0)
  rectfill(0,64,127,127,3)
  rectfill(0,60,127,64,6)
  -- loop map outside of 8x8
  --poke(0x5f38, 8)
   --poke(0x5f39, 8)
 
  -- player direction
  local sty=sin(a)
  local stx=cos(a)
  
  -- camera direction
  local msy=cos(a)
  local msx=-sin(a)
 
  -- not bothering with
  -- 64..71 - too noisy
  for y=64,128 do  
   local tx=mx*sin(a)-my*cos(a)
   local ty=mx*cos(a)+my*sin(a)
   
   local dist=(128/(2*y-128+1))
 
   --printh(">"..msx.." "..msy)
   
   local dby4=dist/1
   
   local d16=dby4/64
   
   tline(
    0,y,127,y,
    
    mx+(-msx+stx)*dby4,
    my+(-msy+sty)*dby4,
    
    d16*msx,d16*msy
    -- after every pixel *drawn*
    -- not texel!!!!
   ) 

   draw_billboard_sprite(
    {x=car1.x/8,y=car1.y/8,tex_x=0,tex_y=32,width=16,height=8,z=100},
    mx,my, -- cam position
    stx,sty,
    msx,msy
  )
   --draw_speedo(-10)
  end
end

function new_lap(now,cnt)
add(lap_scores,{count=cnt-1,score=flr(score)})
return {
 start=now,
 finish=0,
 count=cnt
 
}
end

lap_scores={}


function record_lap()
 sprite=mget(car1.x/8,car1.y/8)

 if sprite==start and (this_lap()==nil or timer-this_lap().start>20) do 
  lap_count+=1
  local curr_lap=new_lap(timer,lap_count)
  add(laps,curr_lap)
		this_lap().start=timer
 end   

 if(sprite==finish and this_lap()!=nil and (timer-this_lap().finish) >20) do 
  if lap_count!=0 then 
 		this_lap().finish=timer
   play_ghost=true
  end   
 end
end

function this_lap()
  return laps[lap_count]
end
function to_pos(xx,yy)
 return {x=xx,y=yy}
end

function round(num,places)
  return flr(num*10^places)/10^places
 end
 
function clamp(v,mn,mx)
 return max(mn,min(v,mx))
end
	
function drawstart()
  cls(11)
  print("it's dorifto time!",25,30,1)
  print("press x to start ",27,40,1)
  print("hold x for handbrake",20,50,1)
end
  
function drawend()
  cls(8)
  camera()
  print("You're done!",25,30,1)
  print("your score is " .. score,27,40,1)
  print("press x to start again",20,50,1)
end

function car_colour()
  local clr=flr(rnd(16))
  if (clr==3 or clr==13) then clr=9 end
  return clr
end

-->8
-- car
v_wall=60


function draw_px(x,y,colour)
 pset(x,y,colour)
end

function car(ix,iy)
	return {
	d_travel=0,
	angle=0,
	steer=0,
	x=ix,
	y=iy,
	new_dx=ix,
	new_dy=iy,
	speed=5,
 dx=0,
 dy=0,
 acc=0.2,
 max_dx=2,
 max_dy=2,
 handbrake=false,
 accelerate=false,
 skidding=false,
 front_skids=false,
 skids_l={},
 skids_r={},
 skids_fl={},
 skids_fr={},
 colour=car_colour(),
 alternate=0,
 r_wheels={{y=6,x=7,l="br"},{y=-6,x=7,l="bl"},{y=6,x=-7,l="fr"},{y=-6,x=-7,l="fl"}},
 
 pos=function(self)
  return {x=self.x,y=self.y,angle=self.angle}
 end,
 
 would_hit_wall=function(self,dx,dy,wall)
   for wheel in all(self.r_wheels) do
    local wheel_pos={x=self.x+wheel.x,y=self.y+wheel.y}
    local locn=self:rotate_wheel_posn(wheel)

 		 sprite=mget(locn.x/8,locn.y/8)
			 if(sprite==wall) do   
			  return true
			 end
   end   
   return false
 end,

 would_hit_other_car=function(self,dx,dy,wall)
   for wheel in all(self.r_wheels) do
    local wheel_pos={x=self.x+wheel.x,y=self.y+wheel.y}
    local locn=self:rotate_wheel_posn(wheel)

 		 sprite=mget(locn.x/8,locn.y/8)
			 if(sprite==wall) do   
			  return true
			 end
   end   
   return false
 end,

 hit_tyre=function(self,dx,dy)
  for tyre in all(tyres) do
    if (abs(self.x-tyre.x)<3) then
      if (abs(self.y-tyre.y)<3) then
        return true
      end
    end
   end
  return false
  --return self.x >200 and self.x <220 
 end,

	move=function(self,v)
  self.angle=self.angle+self.steer

	 local dx=self.dx
  local dy=self.dy
		local max_dx=3
  local max_dy=3

		self.new_dx=(3*cos(-self.angle/360))
  self.new_dy=(3*sin(-self.angle/360))
  
		local delta_dx=(self.new_dx-dx)/50
		local delta_dy=(self.new_dy-dy)/50
  if (not self.handbrake and self.accelerate) do
 		dx=dx+delta_dx
 		dy=dy+delta_dy
  else
  dx=dx*0.99
  dy=dy*0.99
  end
  dx=clamp(dx,-max_dx,max_dx)
  dy=clamp(dy,-max_dy,max_dy)

  if self:would_hit_wall(dx,dy,h_wall) then
   dy=clamp(dy,0,10)
  elseif self:would_hit_wall(dx,dy,v_wall) then
   dx=clamp(dx,0,10)
  end
  
  if self:hit_tyre(dx,dy) then
    dx=dx*0.2
    dy=dy*0.2
  end
   
  self.x=self.x+dx
  self.y=self.y+dy 
  self.speed =flr(speed_of(dx,dy)*30)

  
  local angle=self.angle%360
  local dangle=(flr(atan2(self.dy,self.dx)*360)+90)%360
  local diffangle = abs(dangle-angle)
  self.front_skids=false

  if (diffangle>90) then
   self.skidding=true
   self.front_skids=true
  elseif (diffangle>40) then
   self.skidding=true
   if (sound) then
    sfx(8,2)
    sfx(12,1)
   end
  elseif (diffangle>20) then
   self.skidding=true
   if (sound) then
    sfx(8,2)
    sfx(12,1)
   end
  else 
   self.skidding=false
   
  end
  
  self.dx=dx
  self.dy=dy  
		-- add skids
    self:add_skids()
	end,	
  
	add_skids=function(self)
	 if (self.x==70.06 and self.y==64) then return end
		if(self/alternate%4==0) then
    if self.accelerate then self:create_smoke_on_wheels() end
 		if (self.skidding) then
 	  self:add_skid(self.skids_r,self.r_wheels[1],true,true)
 	  self:add_skid(self.skids_l,self.r_wheels[2],true,true)	  
	   --add_new_dust
	   self.was_skidding=true
		 else 
		  if (self.was_skidding) then
 	   self:add_skid(self.skids_r,self.r_wheels[1],false,true)
     self:add_skid(self.skids_l,self.r_wheels[2],false,true)
    end
    self.was_skidding=false
		 end

 		if (self.front_skids) then
 	  self:add_skid(self.skids_fr,self.r_wheels[3],true,false)
 	  self:add_skid(self.skids_fl,self.r_wheels[4],true,false)	  
	   --add_new_dust
	   self.was_f_skidding=true
		 else 
		  if (self.was_f_skidding) then
 	   self:add_skid(self.skids_fr,self.r_wheels[3],false,false)
     self:add_skid(self.skids_fl,self.r_wheels[4],false,false)
    end
    self.was_f_skidding=false
		 end
		end
  self.alternate+=1
	end, 
  draw_skids=function(self)
    draw_skids(self.skids_l)
    draw_skids(self.skids_r)
--    draw_skids(self.skids_fl)
--    draw_skids(self.skids_fr)
  end,

	draw=function(self)
    pal(1,0)
    
    pal(9,self.colour)
    pal(4,5)
    pal(5,1)
    rotate_sprite(self.x,self.y,self.angle,14)--wheels
    rotate_sprite(self.x,self.y-1,self.angle,5)
    rotate_sprite(self.x,self.y-2,self.angle,0)
    rotate_sprite(self.x,self.y-3,self.angle,19 )
    rotate_sprite(self.x,self.y-4,self.angle,10)--roof
    pal()
 end,
 
 rotate_wheel_posn=function(self,pos)
	 local dx=pos.y
	 local dy=pos.x
	 local tx=self.x
	 local ty=self.y
	 local ca=sin(self.angle/360)
	 local sa=cos(self.angle/360)
	 local xx=flr(dx*ca-dy*sa+tx)--transofrmed val
	 local yy=flr(dx*sa+dy*ca+ty)
		return {x=xx,y=yy}
 end,
 
	add_skid=function(self,skids,pos,add_it, add_smoke)
	 local skd=self.rotate_wheel_posn(self,pos)
	 if(add_it) then
  	 add(skids,skd)
	 else
	  add(skids,{x=nil,y=nil})
	 end
	end,
  create_smoke_on_wheels=function(self)   
 	 local skd=self.rotate_wheel_posn(self,self.r_wheels[1])
   local skd2=self.rotate_wheel_posn(self,self.r_wheels[2])
   if (self.new_dx>10) then
    local dir=calc_vector(self.angle,0.5)
    create_smoke(skd,dir) 
    create_smoke(skd2,dir) 
   else 
    create_smoke(skd,to_pos(self.new_dx/2,self.new_dy/2)) 
 	  create_smoke(skd2,to_pos(self.new_dx/2,self.new_dy/2)) 
   end
  end

	}
end

function calc_vector(angle,speed)
 new_dx=(speed*cos(-angle/360))
 new_dy=(speed*sin(-angle/360))
 return {x=new_dx,y=new_dy}
end

function speed_of(x,y)
  return sqrt(x*x+y*y)
end

function rotate_sprite(x,y,a,sprite_offset)
sw_rot=a/360
mx=-0.0+sprite_offset
my=-0.6
r=3
local cs, ss = cos(sw_rot), -sin(sw_rot)    
local ssx, ssy, cx, cy = mx - 0.5, my - 0.5, mx+r/2, my+r/2

 ssy -=cy
 ssx -=cx

 local delta_px = -ssx*8

 for py = y-delta_px, y+delta_px-1 do
  local sx, sy = cs * ssx + cx + ss * ssy, 
                -ss * ssx + cy + cs * ssy

  tline(x-delta_px, py, x+delta_px-1, py, sx, sy, cs/8, -ss/8)
  ssy+=1/8
 end
end

-->8
--draw fun
skids_l={{x=198,y=62},{x=207,y=65},{x=217,y=67},{x=227,y=69},{x=237,y=71},{x=249,y=74},{x=262,y=76},{x=275,y=77},{x=288,y=77},{x=301,y=76},{x=313,y=74},{x=324,y=72},{x=334,y=69},{x=343,y=66},{x=351,y=63},{x=359,y=62},{x=365,y=61},{x=372,y=62},{x=nil,y=nil},{x=387,y=66},{x=395,y=69},{x=405,y=71},{x=415,y=71},{x=425,y=69},{x=434,y=67},{x=444,y=65},{x=454,y=62},{x=463,y=59},{x=nil,y=nil},{x=495,y=42},{x=507,y=38},{x=520,y=38},{x=532,y=38},{x=543,y=39},{x=553,y=39},{x=562,y=39},{x=572,y=39},{x=581,y=39},{x=591,y=39},{x=601,y=41},{x=609,y=44},{x=616,y=46},{x=623,y=50},{x=629,y=54},{x=635,y=59},{x=641,y=64},{x=646,y=70},{x=650,y=77},{x=654,y=83},{x=658,y=91},{x=662,y=98},{x=665,y=106},{x=669,y=114},{x=673,y=123},{x=677,y=134},{x=681,y=145},{x=684,y=156},{x=686,y=167},{x=689,y=176},{x=692,y=184},{x=695,y=192},{x=698,y=201},{x=699,y=209},{x=699,y=216},{x=699,y=222},{x=698,y=228},{x=696,y=233},{x=693,y=238},{x=690,y=242},{x=686,y=245},{x=680,y=249},{x=674,y=252},{x=668,y=255},{x=660,y=257},{x=653,y=258},{x=647,y=258},{x=640,y=258},{x=633,y=257},{x=625,y=256},{x=nil,y=nil},{x=568,y=231},{x=560,y=225},{x=552,y=220},{x=543,y=217},{x=535,y=216},{x=527,y=216},{x=519,y=215},{x=512,y=215},{x=504,y=215},{x=496,y=215},{x=488,y=215},{x=480,y=215},{x=472,y=215},{x=464,y=214},{x=455,y=212},{x=445,y=212},{x=437,y=214},{x=429,y=217},{x=424,y=220},{x=421,y=224},{x=419,y=228},{x=417,y=233},{x=417,y=238},{x=418,y=243},{x=nil,y=nil},{x=421,y=272},{x=418,y=281},{x=413,y=289},{x=408,y=295},{x=403,y=300},{x=398,y=304},{x=393,y=307},{x=387,y=309},{x=381,y=311},{x=374,y=313},{x=367,y=314},{x=358,y=315},{x=350,y=316},{x=342,y=315},{x=333,y=315},{x=324,y=313},{x=315,y=311},{x=306,y=308},{x=298,y=305},{x=291,y=301},{x=284,y=297},{x=277,y=292},{x=nil,y=nil},{x=255,y=268},{x=249,y=260},{x=242,y=252},{x=234,y=245},{x=227,y=239},{x=219,y=233},{x=211,y=228},{x=204,y=222},{x=195,y=215},{x=187,y=211},{x=180,y=208},{x=174,y=207},{x=167,y=206},{x=160,y=205},{x=154,y=206},{x=149,y=209},{x=144,y=212},{x=140,y=215},{x=136,y=220},{x=132,y=224},{x=127,y=229},{x=124,y=234},{x=123,y=241},{x=122,y=247},{x=121,y=254},{x=121,y=262},{x=nil,y=nil},{x=128,y=289},{x=129,y=300},{x=129,y=311},{x=128,y=321},{x=126,y=331},{x=124,y=339},{x=124,y=347},{x=124,y=355},{x=124,y=362},{x=124,y=370},{x=123,y=377},{x=121,y=383},{x=119,y=388},{x=117,y=391},{x=115,y=393},{x=113,y=395},{x=111,y=395},{x=108,y=395},{x=105,y=394},{x=102,y=392},{x=99,y=389},{x=95,y=386},{x=91,y=381},{x=87,y=377},{x=nil,y=nil},{x=65,y=339},{x=61,y=331},{x=58,y=322},{x=55,y=313},{x=52,y=304},{x=51,y=295},{x=50,y=286},{x=49,y=277},{x=49,y=268},{x=nil,y=nil},{x=51,y=229},{x=51,y=217},{x=52,y=205},{x=54,y=193},{x=55,y=183},{x=55,y=173},{x=56,y=164},{x=58,y=153},{x=59,y=142},{x=60,y=132},{x=62,y=122},{x=64,y=111},{x=65,y=102},{x=68,y=94},{x=71,y=87},{x=75,y=81},{x=79,y=75},{x=84,y=70},{x=90,y=65},{x=96,y=61},{x=103,y=57},{x=112,y=53},{x=120,y=51},{x=128,y=50},{x=135,y=49},{x=142,y=49},{x=150,y=50},{x=158,y=51},{x=165,y=53},{x=nil,y=nil},{x=183,y=65},{x=190,y=69},{x=199,y=72},{x=207,y=73},{x=216,y=73},{x=225,y=73},{x=234,y=72},{x=243,y=70},{x=252,y=68},{x=nil,y=nil}}
skids_r={{x=200,y=74},{x=213,y=75},{x=224,y=76},{x=236,y=76},{x=248,y=76},{x=261,y=75},{x=273,y=73},{x=284,y=70},{x=295,y=67},{x=304,y=65},{x=312,y=62},{x=319,y=61},{x=326,y=60},{x=332,y=61},{x=339,y=62},{x=347,y=65},{x=356,y=68},{x=365,y=72},{x=nil,y=nil},{x=388,y=78},{x=400,y=80},{x=412,y=80},{x=423,y=79},{x=433,y=78},{x=443,y=76},{x=452,y=74},{x=462,y=71},{x=471,y=68},{x=nil,y=nil},{x=493,y=53},{x=501,y=49},{x=511,y=45},{x=521,y=43},{x=531,y=42},{x=541,y=41},{x=551,y=41},{x=560,y=41},{x=570,y=41},{x=579,y=41},{x=589,y=42},{x=597,y=44},{x=604,y=46},{x=611,y=50},{x=617,y=54},{x=623,y=59},{x=629,y=64},{x=634,y=70},{x=638,y=77},{x=642,y=84},{x=646,y=91},{x=650,y=98},{x=653,y=106},{x=657,y=114},{x=661,y=122},{x=666,y=129},{x=672,y=137},{x=679,y=146},{x=684,y=155},{x=688,y=164},{x=691,y=172},{x=694,y=180},{x=697,y=189},{x=700,y=197},{x=701,y=204},{x=701,y=210},{x=699,y=216},{x=698,y=221},{x=695,y=226},{x=691,y=230},{x=687,y=233},{x=683,y=238},{x=678,y=241},{x=673,y=244},{x=667,y=247},{x=661,y=249},{x=654,y=249},{x=647,y=249},{x=640,y=248},{x=633,y=246},{x=nil,y=nil},{x=565,y=219},{x=554,y=215},{x=543,y=212},{x=533,y=210},{x=525,y=210},{x=517,y=210},{x=509,y=210},{x=501,y=209},{x=493,y=209},{x=485,y=209},{x=477,y=209},{x=469,y=209},{x=461,y=209},{x=452,y=209},{x=443,y=211},{x=434,y=215},{x=426,y=220},{x=420,y=225},{x=416,y=229},{x=413,y=233},{x=410,y=237},{x=409,y=242},{x=408,y=246},{x=408,y=248},{x=nil,y=nil},{x=413,y=263},{x=414,y=270},{x=413,y=277},{x=411,y=284},{x=407,y=289},{x=402,y=292},{x=397,y=295},{x=391,y=298},{x=385,y=300},{x=378,y=301},{x=371,y=303},{x=364,y=305},{x=357,y=305},{x=349,y=305},{x=341,y=306},{x=333,y=305},{x=325,y=304},{x=317,y=303},{x=309,y=299},{x=301,y=296},{x=294,y=291},{x=287,y=285},{x=nil,y=nil},{x=255,y=256},{x=245,y=249},{x=235,y=242},{x=225,y=237},{x=217,y=231},{x=210,y=226},{x=202,y=220},{x=194,y=215},{x=184,y=211},{x=176,y=207},{x=169,y=205},{x=162,y=204},{x=155,y=204},{x=148,y=205},{x=142,y=207},{x=137,y=209},{x=132,y=212},{x=128,y=216},{x=124,y=221},{x=120,y=226},{x=116,y=233},{x=114,y=240},{x=112,y=246},{x=111,y=253},{x=110,y=260},{x=111,y=267},{x=nil,y=nil},{x=117,y=284},{x=121,y=291},{x=124,y=300},{x=127,y=309},{x=129,y=319},{x=130,y=329},{x=131,y=338},{x=131,y=345},{x=131,y=353},{x=132,y=360},{x=132,y=369},{x=131,y=376},{x=130,y=381},{x=128,y=385},{x=126,y=388},{x=124,y=389},{x=122,y=390},{x=119,y=389},{x=116,y=388},{x=113,y=386},{x=110,y=383},{x=106,y=381},{x=102,y=378},{x=98,y=374},{x=nil,y=nil},{x=77,y=338},{x=73,y=331},{x=70,y=324},{x=66,y=316},{x=64,y=308},{x=62,y=299},{x=61,y=290},{x=61,y=281},{x=60,y=272},{x=nil,y=nil},{x=62,y=234},{x=61,y=225},{x=59,y=215},{x=58,y=204},{x=59,y=194},{x=59,y=185},{x=60,y=175},{x=60,y=165},{x=60,y=154},{x=61,y=144},{x=61,y=134},{x=61,y=123},{x=63,y=114},{x=65,y=106},{x=69,y=99},{x=72,y=92},{x=77,y=87},{x=82,y=82},{x=87,y=77},{x=93,y=73},{x=99,y=68},{x=105,y=63},{x=112,y=60},{x=120,y=58},{x=127,y=58},{x=134,y=58},{x=142,y=59},{x=149,y=60},{x=157,y=62},{x=nil,y=nil},{x=184,y=76},{x=195,y=80},{x=205,y=82},{x=215,y=83},{x=223,y=83},{x=232,y=82},{x=241,y=81},{x=250,y=80},{x=260,y=78},{x=nil,y=nil}}
skids_fl={{x=212,y=59},{x=219,y=58},{x=227,y=58},{x=236,y=58},{x=243,y=59},{x=250,y=60},{x=258,y=63},{x=266,y=66},{x=276,y=69},{x=287,y=73},{x=299,y=76},{x=311,y=78},{x=324,y=79},{x=337,y=78},{x=350,y=77},{x=nil,y=nil},{x=401,y=64},{x=408,y=63},{x=nil,y=nil},{x=509,y=44},{x=nil,y=nil},{x=673,y=170},{x=675,y=177},{x=678,y=185},{x=681,y=194},{x=684,y=201},{x=685,y=208},{x=685,y=214},{x=685,y=221},{x=nil,y=nil},{x=443,y=226},{x=438,y=227},{x=434,y=230},{x=nil,y=nil},{x=196,y=233},{x=190,y=228},{x=184,y=224},{x=177,y=222},{x=nil,y=nil},{x=113,y=327},{x=112,y=333},{x=112,y=339},{x=113,y=346},{x=113,y=354},{x=113,y=361},{x=113,y=367},{x=113,y=372},{x=112,y=376},{x=111,y=379},{x=109,y=381},{x=107,y=382},{x=nil,y=nil},{x=76,y=123},{x=77,y=114},{x=79,y=105},{x=81,y=97},{x=85,y=90},{x=88,y=83},{x=93,y=78},{x=98,y=73},{x=103,y=68},{x=109,y=64},{x=116,y=62},{x=124,y=61},{x=131,y=60},{x=138,y=59},{x=145,y=59},{x=nil,y=nil},{x=196,y=62},{x=203,y=63},{x=210,y=64},{x=219,y=65},{x=228,y=65},{x=nil,y=nil},{x=nil,y=nil}}
skids_fr={{x=214,y=71},{x=225,y=69},{x=235,y=67},{x=245,y=66},{x=254,y=64},{x=262,y=61},{x=269,y=60},{x=276,y=59},{x=283,y=60},{x=290,y=61},{x=298,y=64},{x=306,y=67},{x=316,y=70},{x=327,y=73},{x=338,y=76},{x=nil,y=nil},{x=402,y=76},{x=413,y=74},{x=nil,y=nil},{x=507,y=56},{x=nil,y=nil},{x=670,y=158},{x=674,y=165},{x=677,y=173},{x=680,y=182},{x=683,y=189},{x=686,y=196},{x=687,y=203},{x=687,y=209},{x=nil,y=nil},{x=433,y=232},{x=429,y=235},{x=426,y=239},{x=nil,y=nil},{x=186,y=227},{x=179,y=224},{x=172,y=221},{x=165,y=219},{x=nil,y=nil},{x=116,y=316},{x=118,y=322},{x=119,y=329},{x=120,y=337},{x=120,y=344},{x=121,y=352},{x=122,y=359},{x=123,y=365},{x=122,y=369},{x=121,y=373},{x=120,y=375},{x=117,y=377},{x=nil,y=nil},{x=75,y=135},{x=75,y=126},{x=77,y=117},{x=79,y=109},{x=82,y=102},{x=86,y=95},{x=90,y=89},{x=95,y=84},{x=101,y=80},{x=107,y=76},{x=112,y=73},{x=117,y=71},{x=123,y=69},{x=130,y=68},{x=137,y=67},{x=nil,y=nil},{x=198,y=74},{x=208,y=74},{x=217,y=74},{x=226,y=74},{x=235,y=74},{x=nil,y=nil},{x=nil,y=nil}}h_wall=59


function draw_ghost()
 if not play_ghost then return end
 local lap
 if lap_count==1 then
  lap=this_lap()
 else
  lap=laps[lap_count-1]
 end
 
 local pos =ghost[timer-(lap.finish-lap.start)]
 if pos!=nil then
  ghost_car.angle=pos.angle
  if(alternate%4==0) then ghost_car:create_smoke_on_wheels() end

  ghost_car:draw()
 
  ghost_car.x=pos.x
  ghost_car.y=pos.y
 end
end

function draw_tyres()
  palt(0,false)
  palt(3,true)
 for tyre in all(tyres) do
  spr(43,tyre.x*8,tyre.y*8)
 end
 palt()
end

function add_tyres()
  return {
  {x=27,y=8},
  {x=6,y=11},
  {x=11,y=18},
  {x=12,y=16},
  {x=13,y=14},
  {x=14,y=13},
  {x=16,y=12},
  {x=18,y=11},
  {x=62,y=11},
  {x=65,y=11},
  {x=67,y=11},
  {x=69,y=11},
  {x=71,y=12},
  {x=73,y=14},
  {x=80,y=21},
  {x=82,y=23},
  {x=83,y=25},
  {x=82,y=27},
  {x=80,y=28},
  {x=78,y=27},
  {x=76,y=25},
  {x=70,y=33},
  {x=68,y=31},
  {x=66,y=30},
  {x=64,y=29},
  {x=61,y=29},
  {x=59,y=30},
  {x=57,y=31},
  {x=44,y=30},
  {x=42,y=32},
  {x=39,y=32},
  {x=29,y=36},
  {x=27,y=34},
  {x=25,y=32},
  {x=23,y=32},
  {x=22,y=33},
  {x=21,y=35},
  {x=20,y=37},
  {x=12,y=42},
  {x=12,y=40},
  {x=11,y=35}
  }
end

function draw_skids(skiddies)
 local ops=0
 local prevx=nil 
 local prevy=nil
 for skid in all(skiddies) do
 	if(prevx != nil and skid.x !=nil ) do 
   if (window_x-10<skid.x and window_x+138>skid.x) then
    if (window_y-10<skid.y and window_y+138>skid.y) then
     ops+=1
     local strt=pget(prevx,prevy)
     local fin=pget(skid.x,skid.y)
     if(fin==3 or fin==4 or strt==3) then
      line(prevx,prevy,skid.x,skid.y,4)
     else
      line(prevx,prevy,skid.x,skid.y,1)
     end
    end
   end
  end
	 prevx=skid.x
	 prevy=skid.y
 end  
-- bob=#skiddies .. " " ..ops
end

function print_skids(skidlist)
 for skd in all(skidlist) do
   if (skd.x!=nil and skd.y~=nil) then
    printh("{x=" ..skd.x ..",y="..skd.y.."},")
   else
    printh("{x=nil,y=nil},")
   end
 end
end

function print_all_skids()
 printh("!!!!!")
 printh("skids_l={")
 print_skids(skids_l) 
 printh("{x=nil,y=nil}}")
 printh("skids_r={")
 print_skids(skids_r) 
 printh("{x=nil,y=nil}}")
 printh("skids_fl={")
 print_skids(skids_fl) 
 printh("{x=nil,y=nil}}")
 printh("skids_fr={")
 print_skids(skids_fr) 
 printh("{x=nil,y=nil}}")

end

function draw_speedo(adj)
local rad=20
local spdo_x=window_x+20
local spdo_y=window_y+128+adj
 circ(spdo_x,spdo_y+10,rad+1,1)
 circfill(spdo_x,spdo_y+10,rad,6)
 draw_taco(car1.speed,spdo_x,spdo_y)
end

function draw_taco(speed,x,y)
 print(speed,x+4,y-6,8)
 circfill(x-5,y,8,0)
 local taco=calc_taco(speed) 
 line(x-5,y,x-5+taco.x,y+taco.y,8)
end

function calc_taco(speed)
if (speed>50) then
 new_speed=20+speed%10
else
 new_speed=speed%30
end
 local xx=-cos(new_speed*6/360)*5
 local yy=sin(new_speed*6/360)*5 
 --printh(speed .. " " ..xx .. " " ..yy)
 return {x=xx,y=yy}
 
end

-->8
function create_smoke(pos,direction)
 add_new_dust(pos.x,pos.y,direction.x+rnd(0.6)-0.3,direction.y,10,rnd(2)+2,0.0,7)
end

function add_new_dust(_x,_y,_dx,_dy,_l,_s,_g,_f)
    add(dust, {
     x=_x,
     y=_y,
     dx=-_dx,
     dy=-_dy,
     life=_l,
     orig_life=_l,
     rad=_s,
     col=7, --set to color
     grav=0,
     fade=_f,
     draw=function(self)
      if self.life>4 then
       fillp() 
      elseif self.life%2==0 then
       fillp(0b0101101001011010.1) 
      else 
       fillp(0b1010010110100101.1) 
			end
      circfill(self.x,self.y,self.rad,6)
      circfill(self.x,self.y,self.rad-1,self.col)
      fillp()
     end,
     update=function(self)
      self.x+=self.dx*0.7
      self.y+=self.dy*0.7
      self.dy+=self.grav
        
      self.rad*=1.1
      self.life-=1
        
      self.col=self.fade            
      if self.life<0 then
        del(dust,self)
      end
     end
 })
end


-->8
-- todo
-- support for tiled mapsections
-- create track that can be created 
-- ghost car that can be followed
-- accelerator and brake
-- buttons for small big turns that match small big corners?
-- how to deal with >360< problem
-- what should accelerator do?
-- drift angle directly function of accelerator
-- direction of travel just down to steering
-- move pivot point of car forward

-->8
-- s needs a tex_x,tex_y (spritesheet coord)
-- width, height - sprite w,h in pixels
-- x, y
function draw_billboard_sprite(
  s,
  posx,
  posy,
  drx,
  dry,
  camx,
  camy)
  
  local invdet=1/(camx*dry-camy*drx)
  local tex_x=s.tex_x
  local tex_y=s.tex_y
  local t_w=s.width
  local t_h=s.height
  local s_x=s.x-posx
  local s_y=s.y-posy
  
  local s_dist=
   sqrt(s_x*s_x+s_y*s_y)
  local t_x=invdet*(
   dry*s_x-
   drx*s_y
  )
  local t_y=invdet*(
  -camy*s_x+
   camx*s_y
  )
  
  local sscr_x=flr(64*(1+t_x/t_y))
  local sc_y=flr(abs(128/t_y))
  local s_height=sc_y*0.3
  local s_width=sc_y*0.6
  local s_width2=s_width/2
  local ds_y=-sc_y/2+64+(s.z/t_y)
  
  local ds_x=-s_width2+sscr_x
  if(ds_x<0) ds_x=0
  
  local de_x=s_width2+sscr_x
  if (de_x>=128) de_x=127
  
  if t_y>0 and t_y<128 then
   for i=ds_x,de_x do
    local texx=(
     i-(-s_width2+sscr_x))*t_w/s_width
     
    sspr(tex_x+texx,tex_y,1,t_h,i,ds_y,1,s_height)
   end
  end
 end

__gfx__
000000000000000000000000000000000000000000000000000000000000000000000000000000000055dddddddddddddddd55005000000005dddddddddddd50
00000000000000000000000000000000000000000000000000000000000000000000000000000000000055dddddddddddd550000d5000000005dddddddddd500
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000055dddddddd55000000dd5000000005dddddddd5000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055dddddd00000000ddd5000000005dddddd50000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055dddd00000000dddd5000000005dddd500000
000000000000000000099990999900000030000000000090000000000000dddddd5500000000000000000000000055dd00000000ddddd5000000005dd5000000
000000000000000000099990999900000000000000000000000000a00000dddd5500000000000000000000000000005500000000dddddd500000000550000000
000000000000000000099990999900000000000000000000000000000000dd550000000000000000000000000000000000000000ddddddd50000000000000000
0000000000000000000999909999030000000000000200000900000000a055000000000000000000000005dd05dddddddd500000000005dddd50000000000000
000000000000000000099990999900000000000000009000000000000000000000000000000000000000005d05dddddddd500000000005dddd50000000000005
000000000000000000099990999900000000dddddddd00005dddddd50000dddddd50dd500000000000000005005dddddd50000000000005dd50000000000005d
000000000000000000099990999900000000dddddddd00005dddddd50000dddddd50d5000000000000000000005dddddd50000000000005dd5000000000005dd
000000000000000000099990999900000000dddddddd00005dddddd50000ddddd500500000000000000000000005dddd50000000000000055000000000005ddd
0000000000000000000999909999000000005555555500005dddddd50000ddddd500000000000000000000000005dddd5000000000000005500000000005dddd
0000000000000000000999909999555555550000000000005dddddd50000dddd50000000000000000000000000005ddd000000000000000000000000005ddddd
0000000000000000000011101110dddddddd0000000000005dddddd50000dddd50000000000000000000000000005ddd00000000000000000000000005dddddd
0000000000000000000000101000dddddddd0000000000005dddddd50000ddd50000000000000000dd77dd773333333311111111000000000000000000000000
0000000000000000000000000000dddddddd0000000000005dddddd50000ddd50000000000000000dd77dd773300003311111111000000000000000000000000
000000000000000000000000000000000000000000555500000000000000dddddddd77dd77000000dddd77dd3000000311111111000000000000000000000000
000000000000000000000000000000000000000055dddd55000000000000dddddddd77dd77000000dddd77dd0003300011111111000000000000000000000000
0000000000000000000000000000000000000055dddddddd550000000000dddddddddd77dd000000dd77dd770033330011111111000000000000000000000000
00000009110000000000000000000000000055dddddddddddd5500000000dddddddddd77dd000000dd77dd770003300011111111000000000000000000000000
000000091111000000000000000000000055dddddddddddddddd55000000dddddddd77dd77000000dddd77dd3000000311111111000000000000000000000000
0000000911110000000000000000000055dddddddddddddddddddd550000dddddddd77dd77000000dddd77dd3300003311111111000000000000000000000000
00000009111100000000000000000055dddddddddddddddddddddddd5500dddddddddd77dd000000dddddddd0000000000000157dddd50000005dddd00000000
000000091111000000000000000055dddddddddddddddddddddddddddd55dddddddddd77dd000000dddddddd0000000000000155dddd50000005dddd00000000
0000000911110000000000000000000000000005dddddddd50005000000050000005dddddd000000dddddddd1111111100000157ddddd500005ddddd00000000
0000000911110000000000000000000000050005dddddddd50005000000050000005dd5ddd000000dddddddd5555555500000155ddddd500005ddddd00000000
00000009111100000000000000000000005d005dddddddddd500d500000050000005dddddd000000dddddddd5757575700000157dddddd5005dddddd00000000
00000009110000000000000000000000005d005dddddddddd500d500000050000005dddddd000000dddddddd6666666600000155dddddd5005dddddd00000000
0000000000000000000000000000000005dd05dddddddddddd50dd500000d500005ddddddd000000dddddddd5555555500000157ddddddd55ddddddd00000000
0000000000000000000000000000000005dd05dddddddddddd50dd500000d500005ddddddd000000dddddddd5555555500000155ddddddd55ddddddd00000000
000000000000000000000000000000005ddd5dddddddddddddd5ddd50000dd5005dddddddd000000000000000000000000000000000000000000000000000000
000000000000000000000000000000005ddd5dddddddddddddd5ddd50000ddd55ddddddddd000000000000000b00001bbbbb1100000000000000000000000000
00000009990000000000009999999999990000000000000000000000000000000000000000000000888888000bbbb11bbbbb1111bbbbbb000000000000000000
0000000090000000000000090000000090000900000000000000000000000800001888881100000088888a000b08b11bbbbb1111bbbbba000000000000000000
00000009990000000000009999999999990009999999999999999999990008888118888811000000888887000b08b11bbbbb1111bbbbb7000000000000000000
00000008890000000000009889999998890009099911111111919999990008088118888811000000888887000b08b11bbbbb1111bbbbb7000000000000000000
00000009999000000000099999999999999009099111111119119999990008088118888811000000888888000b0bb11bbbbb1111bbbbbb000000000000000000
00000009999100000000199999999999999109099111111111119999990008088118888811000000888888000b0bb11bbbbb1111bbbbbb000000000000000000
00000009999100000000199999999999999109099111111111119999990008088118888811000000888888000b0bb11bbbbb1111bbbbbb000000000000000000
00000000011100000000111000000000011109099111111111119999990008088118888811000000888887000b08b11bbbbb1111bbbbb7000000000000000000
00000000000000000000000000000000000009099111111111119999990008088118888811000000888887000b08bbbb1111bb11bbbbb7000000000000000000
00000000000000000000000000000000000009099111111111119999990008088118888811000000888887000b08bb11111111b1bbbbb7000000000000000000
00000000000000000000000000000000000009099111111119119999990008088888111188000000888888000bbbbbbbbbbbbbbbbbbbbb000000000000000000
00000000000000000000000000000000000009099911111111919999990008088811111111000000111188000b0b1111bbbbbbbb1111bb000000000000000000
00000000000000000000000000000000000009999999999999999999990008888888888888000000111144000004111144444444111144000000000000000000
00000000000000000000000000000000000009000000000000000000000008081111888888000000111100000000111100000000111100000000000000000000
00000000000000000000000000000000000000000000000000000000000000041111444444000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000001111000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000cccccc000000000000000000000000000000000000000000
0000000000001111000000000000000000000000000000000000000000000c00001ccccc11000000ccccca000000000000000000000000000000000000000000
0000000444441551400000000000000000000009111199999999111199000cccc11ccccc11000000ccccc7000000000000000000000000000000000000000000
000000000000000009000000099911111100000899999999999999999a000c0cc11ccccc11000000ccccc7000000000000000000000000000000000000000000
0000000000000000090000000111111111110008999999999999999997000c0cc11ccccc11000000cccccc000000000000000000000000000000000000000000
0000000000000000090000000111111111110008999999999999999997000c0cc11ccccc11000000cccccc000000000000000000000000000000000000000000
0000000000000000090000000111111111110009999999999999999991000c0cc11ccccc11000000cccccc000000000000000000000000000000000000000000
0000000000000000090000000111111111110009999999999999999991000c0cc11ccccc11000000ccccc7000000000000000000000000000000000000000000
0000000000000000090000000111111111110009999999999999999991000c0cc11ccccc11000000ccccc7000000000000000000000000000000000000000000
0000000000000000090000000111111111110008999999999999999997000c0cc11ccccc11000000ccccc7000000000000000000000000000000000000000000
0000000000000000090000000111111110110008999999999999999997000c0ccccc111111000000cccccc000000000000000000000000000000000000000000
000000000000000009000000099911111100000899999999999999999a000c0ccc111111110000001111cc000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000111144000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000111100000000111100000000000000000000000000000000000000000000
000000c300a3a3a3a3a3a3000043a3a393a3a3a3a3a3f0b200b2e0a3a3a3a3a3a3a3a3a3a3a3d0b20000b2f1a3a3a3a3a3a3a3a3a3a3a3f00000000000000000
000000000000e0a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3f000000000000000000000c200000000000000000000400000000000000000000000000000
000060c300a3a3a3a3a3a3000053a3a3a3a3a3a3a381b200000000e0a3a3a3a3a3a3a3a3a3a3a362724252a3a3a3a3a393a3a3a3a3a3f0000000000060000000
004000000000b2e0a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3f00000000000000000000000c200000000500070000000000000700000000000000000000000
000000c300a3a3a3a393a30000a3a3a3a3a3a3a3a3c10000000000b2e0a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3f000000000000000000000
0000000070000000e0a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3f0000000000000000000000000c200000000000000000000000000000000000000004000000000
000000c300a3a3a3a3a3a3b200a3a3a3a3a3a3a381b200000000000000e0a3a3a3a3a3a3a3a39393a3a3a3a3a3a3a3a3a3a3a3a3f00000000000000000000000
000000000000000000e0a3a3a3a3a3a3a3a3a3a3a3a3a3a3f000000000000000000000000000c200000000000000000000000000000000000000000000000000
000000c300a3a3a3a3a3a37300a3a3a3a3a3a3a3c10000000050000000b2e0a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3f0000000000000000000000000
00000000000000000040e0a3a3a3a3a3a3a3a3a3a3a380c00000000000500000000000000060c200000000000000000000000000005000000000000000000000
000000c300a393a393a3a37100a3a3a3a3a3a381b200000000000000000000e0a3a3a3a3a3a3a3a3a3a3a3a3a393a3a3a3a3f000006000000000000000000000
0000000000500000000000a0b0a3a3a3a3a3a3a3809040007000000000000000000000000000c200004000000000000000000000000000000000000000000000
000000c300a3a3a3a3a3a37100a3a3a3a3a3a371000000000000000000000000e0a3a3a393a3a3a3a3a3a3a3a3a3a3a3a3f00000000000000040000000000000
0000000000000000000000400000000000000000000000000000000000000000000000000000c200000000000000000000000000000000000000000000000000
500000c300a3a3a3a3a3a37100a3a393a3a3a37100400000000000000070000000e0a3a3a3a3a3a3a3a3a3a3a3a3a3a3f0000000000000000000000000000000
0000000000000000000000000000000050000000000000000000000000000000000000000000c200000000000000000000400000000000000070000000000000
000000c300a3a3a3a3a3a363b2a3a3a3a3a3a3710000000000000000000000000000e0a3a3a3a3a3a3a3a3a3a3a3a3f000000000000000000000000000000000
0040000000000000007000000000000000000000000000000000000000000000000000407000c200005000000000000000000000000000000000000000000000
000000c300a3a3a3a3a3a3a300a3a3a3a3a3a371000000000000005000000000000000e0a3a393a3a3a3a3a3a3a3f00000000040700000000050000000000000
0000000000000000000000000000000000000000000000000000000000000060000000000000c200000000000000000000000000000000500000000000000000
000060c300a3a393a3a3a3a3b2a3a3a3a393a37100000000000000000000000000400000e0a3a3a3a3a3a3a38090006000000000000000000000000000000000
0000000000000050000000000000000000006000000000000000000000000000000000000000c200000000000000600000000000000000000000000000400000
000000c300a3a3a3a3a3a3a383a3a3a3a3a3a3710000000000000000000000000000000000a0b0a3a3a380900000000000000000000000000000000000006000
0000000000000000000000000040000000000000000000000000000000000000000000000000c200000000000000000000000000000000000000000000000000
000000c300a3a3a393a3a3a3a3a3a3a3a3a3a3710000000000000000000000000000007000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000006000000000000000000000000000c200000000000000000000000000000000000000000000000070
000000c300a3a3a3a393a393a3a3a3a393a3a3710000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000007000000000000000000050007000000040000000000000c200000000004000000000000000500000000000000000000000
000000c300a3a3a3a3a3a3a3a3a3a3a3a3a3a3e10070000000000000000000000000000000000000000000000000004000000000000000000000000040000000
0000000050000000000000000000000000000000000000000000000000000000000000005000c200000000000000000000700000000000000000000000000000
000000c300b1a3a393a3a3a3a3a3a3a3a3a381000000000000000040000060000000000000000040000000000000000000000000500000000000000000000000
0070000000000000000000000000000000000000000000006000000000000000000000000000c200000000000000000000000000000000400000600000000000
000000c300d1a3a3a3a3a3a3a3a3a393a3a3e1000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000
0000000000000040000060000000000000000040000000000000000000000000000000000000c200000000000000000000000000000000000000000000005000
000000c30000e0a3a3a3a3a3a3a3a3a3a3f000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000500000000000000000000000000000000060700000000000c200000000600000000000600000000000000000000000000000
000000c3000000a0b0a3a3a3a3a3a380900000000000000000000000000000000000000000000000000000000000006070000000000000000000006000000000
00600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000600000000000000000400000c200000000000000004000000000000000000000000000000000
000000c3000000004000000000000000000000000000000000000000000000000000000000607000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000c200005000000000000000000000600000000000000040000000
000050c3000000000000000000000000000000000000400000007000006000000000000000000000000000000000000000400000000000000000000000400000
0000000000000000000000000000000000000000000040000000000000000000000000000000c200000000000000000000000000000000000000000000000060
000000c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c270004000000000000000000000000000000000000000000000
00000000000000000000000000500000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000
00000000000000000000000000600000000060000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000
00000000000000006000000000000000000000000000000000004000000000005000000000000000000000000000000000000000007000400000000000000000
00000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000500070000000000000700000000000
00000000000000000000000000000000000000000000000000000000006000000000600000000000000000000000000000000000000000000000000000000000
00000000004000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00400000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000050
00700000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000040000000000000000000000000000000006000000000000000000000000000000000000000000000000000
00000000000000000000000000000040000000000000000000000000000000000000005000000000000000600000000000000000000000000000005000000000
00000000000000000000000040007000000000500000000070000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000500000000000000060000000000000
00000000000000000050000000000000000000000000000000004000700000000050000000000000000000000000000000000000000000000000000000000000
00000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000070
00000000000000000000000000000000000000000000000000500000000000000000000000000000000040007000000000000000000000000000000000000000
00000000000000000000000000000000000000005000000000000000000000000000000000000000004070000000005000000000000000000000000000000000
__label__
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33339333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333a33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
333333333333333333333333333333333a3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
3333333333333333333333333333333333333a333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
00000555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
75757000057575757575750000000000057575757575757575757575757575757575757575757575757575757575757575757575757575757575757575757575
ddddddddd00dddddd77d007dddddddddd0000000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddd000ddd700d77ddddddddddddddddd0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddd0000d77ddddddddddddddddddddddd0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddd0000d77ddddddddddddddddddddddddddd000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddd0ddd700d77dddddddddddddddddddddddddddd0000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddd0dddd77d007dddddddddddddddddddddddddddddddd000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddd00ddddddd77d00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddd0ddddddddd77ddd00dddddddd0ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
0ddddddd0dddddddd77dd77ddd00dddd00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d0000000ddddddd00000000000dd0d00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddd0d00000000dddd77ddddd040000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddd0dddddd0000000077ddd444dddd00000000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dd00ddddd00dddddd7700444dddddddd0dddddd00000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d0dddddd0dddddddd444477d00ddddddd00ddddddddd00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
0dddddd0ddddddd44dd77ddddd00ddddddd4dddddddddd00dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
0dd000000000000000077ddddddd00dddddd4ddddddddddd00d1111ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddd0dddddddddd77000000ddddd0ddddd4dddddddddddd9999999999dddd1111dd9dddddddddddddddddddd000000000000000ddddddddddddddddddddddd
ddddd0ddddddddddd77dd77dd0040dd0ddddd4ddddddddddd799999111999999999999dddddddddddddddd0000ddddddddddddddd000000ddddddddddddddddd
dddd0dddddddddddddd77dddd44dd00000dddd4dddddddddd7999991111999999998d9ddddddddddddd00000000000000dddddddddddddd00ddddddddddddddd
ddd0ddddddddddddddd77dd44dddddddd0000dd4ddddddddd7999991111999991198d9ddddddddd0044dddddddddddddd0000dddddddddddd00ddddddddddddd
ddd0ddddddddddddd77dd44dddddddddddd0d004ddddddddd9999991111999991198d9ddddd000044dddddddddddddddddddd0000dddddddddd00ddddddddddd
dd0dddddddddddddd77d077ddddddddddddd0dd00dddddddd9999991111999991199d9dd000dd44dddddddddddddddddddd0ddddd44dddddddddd0dddddddddd
dd0ddddddddddd00000000000000dddddddd0dddd00ddddd99999911111999991199d900ddd44ddddddddddddddddddddddd00444dd440dddddddd00dddddddd
d0ddddddd00000ddd0d77ddddddd000dddddd0ddd0d00ddd799999111199999119909dddd44dddddddddddddddddddddddd00d00dddddd00dddddddd0ddddddd
d0dd00000ddddddd077dd77dddddddd000ddd0dddd0dd0007999991111999991198d9dd00ddddddddddddddddddddddd000ddddd00dddddd0dddddddd0dddddd
0000ddddddddddd0d77dd77ddddddddddd000d0dddd0dddd7999991119999991198d900dddddddddddddddddd5dddd00dddddddddd00ddddd0dddddddd0ddddd
4ddddddddddddd0dddd77dddddddddddddddd00dddd0dddd999999999999999999809ddddddddddddddddddddddd00dddddddddddddd00dddd0ddddddd0ddddd
ddddddddddddddddddd77dddddddddddddddddd00ddd4ddddd11110ddd99999999999ddddddddddddddddddd0000dddddddddddddddddd0dddd0dddddddddddd
ddddddddddddddddd77dd77dddddddddddddddd0d04dd4ddddddddd000dddd1111dd9ddddddddddddddddddd00d00000ddddddddddddddd00ddd0ddddddddddd
ddddddddddddddddd77dd77dddddddddddddddd0ddd444dddddddd00d0ddddd0ddddddddddddddddddddddd0dddddddd0000ddddddddddddd0dd0ddddddddddd
ddddddddddddddddddd77ddddddddddddddddddd0dddd44ddddd00dddd0ddd0ddddddddddddddddddddddd0dddddd5dddddd000ddddddddddd0dd0dddddddddd
ddddddddddddddddddd77ddddddddddddddddddd0ddddd4dddd0ddddddd000ddddddddddddddddd0000000ddddddddddddddddd000ddddddddd0d0dddddddddd
ddddddddddddddddd77dd77ddd000000000000040dddddd44d0dddddddd000dddddddddd0000000dddd0dd00000000000ddddddddd000ddddddd000ddddddddd
ddddddddddddddddd77d040000000ddddddddddd04400000000000dddd0ddd00dddd0000dddddddddd0dddddddddddddd0000dddd00dd00ddddddd0ddddddddd
dddddddddddddddddd044dddddddd000dddd00000ddd00d0dd00dd00004444dd0000dddddddddddd00ddddddddddddddddddd0000d0dddd000ddddd0dddddddd
dddddddddddddddd04477ddddddddddd0000ddddd0dddd0d0ddd0ddd0ddddd44400dddddddddddd0dddddddddddddddddddddddddddddddddd00ddd00ddddddd
dddddddddddddd00477dd77dddddd000dd0dddddd0ddd040000dd0d0dddddddddd000ddddddddd0ddddddddddddddddddddddddddddddddddddd00d0d0dddddd
dddddddddddd00d4d77dd77dddd00dddddd0ddddd04444dd0dd00000dddddddddddd000ddddd00dddddddddddddddddddddddddddddddddddddddd0d0d0ddddd
ddddddddddd0dd4dddd77dddd00ddddddddd0ddd400dddddd0ddd0d00dddddddddddd0d00d00ddddddddddddddddddddddddddddddddddddddddddd0ddd0dddd
ddddddddd00dd4ddddd77dd00dddddddddddd000d0ddddddd00dd0ddd00ddddddddddd00d00ddddddddddddddddddddddddddddddddddddddddddddd00dd0ddd
dddddddd0ddd4dddd77dd70ddddddddddddd000dd0ddddddd0d00ddddd000dddddddddd44dd0dddddddddddddddddddddddddddddddddddddddddddddd0dd0dd
ddddddd0ddd0ddddd77d007ddddddddddd00ddd000ddddddd0d00dddd5dd000dddddd44dd0dd00ddddddddddddddddddddddddddddddddddddddddddddd0dd0d
dddddd0ddd0ddddddd007dddddddddddd0ddddddd0d000000d0dd0ddddddd0d0dddd4ddddd4ddd00dddddddddddddddddddddddddddddddddddddddddddd4dd4
dddddd0ddd0dddddd0d77ddd0044ddd00ddddddd000dddddd0000d0ddddddd4d00d0ddddddd4dddd4dddddddddddddddddddddddddddddddddddddddddddd4dd
ddddd0ddd0dddddd077dd000dddd4400dddddd00d4d0dddd0d4dd000ddddddd44000dddddddd4dddd4dddddddddddddddddddddddddddddddddddddddddddd4d
4ddd0ddd0dddddd0d77d077dddd00ddd000d00ddd4dd0ddd0d4dddd000dddddd04dd4dddddddd4dddd4ddddddddddddddddddddddddddddddddddddddddddd4d
d0d0ddd0dddddd0ddd007dddd00ddddddd000dddd4ddd4d0dd4ddddd0dddd5d0dd4dd4dddddddd4dddd4ddddddddddddddddddddddddddddddddddddddddddd4
dd0dddd0ddddd0ddd0d77dd04dddddddd0ddddddd4dddd40dd4dddddd4ddddddddd44d44ddddddd4dddd4ddddddddddddddddddddddddddddddddddddddddddd
33003303333303330333334433333330033333333433330344343333343333333333343343333333433334333333333333333333333333333333333333333333
30330003333033330333443333333303333333333433303333443333334333333344444444333333343333433333333333333333333333333333333333333333
30333003333033303344343333333433333333333433344333343333334344444433333343444444334333343333333333333333333333333333333333333333
03333030330333033433433333334333333333444444444444444444444433333333333334444333443433334333333333333333333333333333333333333333
43330333003333444333433333343333444444444433333333343444344443333333333344444433334433333433333333333333333333333333333333333333
33334333044334433334333333433344333344334333333333344443333344444333444433333444444344333343333333333333333333333333333333333333
43343334333443433334333334344433334433334333333333444444444444444444333333333344433444443334333333333333333333333333333333333333
34343334333444333343333344433333443333334333334444433333433344444444443333333334343333444433433333333333333333333333333333333333
33443343334334443343444433333344333333334344443443433333433444333333344433333333444433434344343333333333333333333333333333333333
33433343343334334444334333333433333333334433344333433333344324333333333444333333334343343443443333333333333333333333333333333333
33443433433333444443333333334333333444444444444433433333444333433344444444443333333434334334344333333333333333333333333333333333
33434333433344334334333333443334444443334334333344433334334333434433333334444333333343443433434433333333333333333333333333333333
34334434334433334333443334334443344333343343333333443343333433443333333333344433333334334433434343333333333333333333333333333333
34343344443333343333334443443334433333343433333333434433333444343333333333333443333333433443343443333333333333333333333333333333
43343344433333343333333444333443333333344333333333443344344443243333333333333334333333433343343344333333333333333333333333333333
43433443343333433333334433334333333333343333333334433344443343343333333333333333433333343334334334333333333333333333333333333333
43444433334433433333443333443333333333443333333343433333334443343333333333333333343333334334434333433333333333333333333333333333
34433433333344333344433344333333333a33443333334434333333333343343333333333344333344333333433444333433333333333333333333333333333
44333433333334334433434433333333333334433333343334333333333334343333333333333443334333333433434333343333333333333333333333333333
43333433333334343334443333333333333343433333433334333333444444444433333333333333333433333343343433344333333333333333333333333333
433343333333434333443333333333333a3433433344333334333333333334334444433333333333333443333334343443334333333333333333333333333333
33334333333344344433333333333333333433444444444443333333333334444334333333333333333434333334343434334433333333333333333333333333
33334333333444433333333333333333344444434333333343333333333344334333433333333333333433433333443434334433333333333333333333333333
33334333334433333333333333333444434333434333333344333333334433434333343333333333333343343333434433433443333333333333333333333333
33343333444333333333333333444333343333443333333434333333443333434333334333333343333343344333344433433443333333333333333333333333
33343344343333333333333344333333343334343333333433433344333333434333334333333343333343334333344433343434333393333333333333333333
33343433433333333333334433333333433334433333333433433433333333434333333433333334333343333433334433343344333333333333333333333333
33344334333333333333443333333333433334433333333433434333333333434333333343333334333343333433334433334344393333333333333333333333
34443443333333333334333333333333433334433333334333343333333333443333333334333333433334333343334433334344333333333333333333333333
43334333333333333443333333333333433334433333334333343333333333443333333333433333433334333343334433333434333333333333333333333333
33334333333333344333333333333334333334433333334333343333333333443333333333343333433334333334334433333434333393333333333333333333
33334333333333433333333333333334333334433333434333343333333333443333333333343333343334333334334433333434333333333333333333333333
43334333333344333333333333333334333334443333344333343333333333433333333333334333343334333334334443333434333333333333333333333333
43334333334433333333333333333334333343434333343433343333333333433333333333333333334334333334334443333344333333333333333333333333
43334333343333333333333333333334333343443333343343343333333334433333333333333333334334333334334343333344433333333333333333333333
34334333433333333333333333333334333343434333344334443333333334433333333333333333334334333334334343333344433333333333333333333333
34334333433333333333333333333334333303433444433333343333333344333333333333333333334343333334334343333344433333333333333333333333
33433434333333333333333333333334343303433333433333344333333344333333333333333333334343333334334343333443433333333333333333333333
33433443333333333333333333333334334033343333433333443443333443333333333333333333334433333334334343333443433333333333333333333333
33433433333333333333333333333334333043343333433333333334334343333333333333333333334433333334334343333443433333333333333333333333
33343433333333333333333333333334330334334334333333333333434433333333333333333333334333333334334343333443433333333333333333333333
33344433333333333333333333333334330393444334333333333333344333333333333333333333334333333334334343333433433333333333333333333333
43334343333333333333333333333334303333334334333333333333434433333333333333333333344333333334334434333433343333333333333333333333
43333443333333333333333333333334343333333443333333333333443344333333333333333333434333333334334434334433343333333333333333333333

__map__
4546470000656667000020210100606162000063640000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000
5556570000757677000030310000707172000073740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000
0000000000000000000000000000000000000000000000000007000400000000000000000000000006000000000000000000000700040000000000000000000000000000000000000600000000000000000000070004000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000003b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b2c00000000000000000000000400000000000000050000000000
0000003c3a3a3a3a3a3a3a3a3a3a3a28282828292828282a28282828282828282828282828282828282828282828282828282828282828282828282828283a3a3a3a3a393a3a3a3a3a3a3a2627000000000000000000000000000000000500070000000000002c00000005000000000000000000000000070000000000000000
4b4c4d3c3a3a3a3a3a3a3a3a3a3a2828282828292828282a28282828282828282828282828282839282828282828282839282828282828282828282828283a3a3a3a3a3a3a3a3a3a3a3a3a3a3a0d0000000000000000060000000000000000000000000000002c00000000000000000000000000000000000000000000040000
5b5c5d3c3a3a3a3a3a3a3a3a28282828392828292828282a28282828282828282828282828282828282828282828282828282828282828282828282828283a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a0d00000000000000000000000000060000000000000000002c00000000000000000000000000000000000000000000000000
48494a3c3a3a3a3a3a3a3a3a28282828282828292828282a28282828282828283928282828282828282828282828282828282828282828282828282828283a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a0d000000000000000000000000000000000000000000062c00000000000000000000060000000000060000000000000000
58595a3c3a3a3a3a3a3a3a3928282828282828292828282a282828282828282828282828282828282828392828282828282828282828283928282828393a3a3a3a3a393a3a3a3a3a3a3a3a393a3a3a3a0d0000000000000000000000000000000000000000002c00000000000000000000000000000000000000000000000000
0000003c3a3a3a3a3a3a3a3a3a283928282828292828282a282828283928282828282828282828282828282828282828282828282828282828282828283a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a0d00000000000000000000000000000000000000002c00000000060000000000000000000000000000000000000000
48494a3c00002b353a3a3a3a3a3a3a3a08092b000000000000000000000000000000000000000007000000000000000000050007000000000000000000002b00002b002b002b0a0b3a3a3a3a3a3a3a393a3a0d000000000000000000000006000000000000002c00000000040000000000000000000000000000000000000000
58595a3c0000343a393a3a3a3a3a08092b3300000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000002b0e3a3a3a3a3a3a3a3a3a3a0d0000000400000000000000000000000000002c00000000000000000000000000000000000400000007000006
0600003c0000353a3a3a3a393a0f2b000000000000000000000700000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000e3a3a3a3a393a3a3a3a3a0d00000000000000000000000000000000052c00000000000000000000070000050000000000000000000000
4b4c4d3c00343a3a3a3a3a3a182b00000000000006000000000000000000000400000600000000000000000400000000000000000000000607000000000000060000000000060000002b0e3a3a3a3a3a3a3a3a3a3a0d000000000000000000000000000000002c00000000000000000000000000000000000000000000000000
5b5c5d3c00353a3a3a3a3a3a1c00000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000e3a3a3a3a3a3a3a3a3a3a0d0000000500000000000000000000002c00000000000000000000000000000000000000000000000000
0000003c003a3a3a393a3a182b0000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e3a3a3a3a3a3a3a3a3a3a0d00000000000000000000000000002c00000000000000000000000000000000000000000000000000
0000003c00393a3a3a3a3a1c00000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000e3a3a3a3a3a3a3a3a3a3a0d000000000000000000000000002c00000000000000000000000000000000000000000000000000
0000003c003a3a3a3a3a3a2b0000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000070000060e3a3a3a3a3a3a3a3a3a3a0d0000000000000000000004002c00000000000000000000040000000000000005000000000000
0000003c003a393a3a3a3a00000000000000000000000000000004000000000000000000000000000000000600000000000000000000070004000000000000000000000000000007000000000000000e3a3a3a3a3a3a3a3a3a3a3700000006000000000000002c00000500000000000000000000000007000000000000000000
0000003c003a3a3a3a3a3a0000000000000000000500070000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000e3a3a3a3a3a3a3a3a3a3d00000000000000000000002c00000000000000000000000000000000000000000004000006
0000003c003a3a3a3a3a3a000000000000000000000000000000000000000000000000000400000000000000000000000000000000000024253a3a3a3a3a3a3a3a3a26270000000000000000000000002b0e3a3a3a3a3a3a3a3a3a37000000000000000000002c00000000000000000000000000000000000000000000000000
0000003c073a3a3a3a3a3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000024253a3a3a3a3a3a3a3a3a3a3a3a3a3a262706000000000000000000000e3a3a3a3a3a3a3a3a3d000000000000000006072c00000000000000000006000000000006000000000000000000
0000003c003a3a3a3a3a3a000000000000000024253a3a3a3a3a3a262700000000000000000000000000000000000000000000001f3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a26270000000000000000002b1b3a3a3a3a3a3a3a3a370000000600000000002c00000000000000000000000000000000000000000000000000
0000003c003a3a3a3a393a000000000000001f3a3a3a3a3a3a3a3a3a3a262700000000000000000600000000000000000000001f3a3a3a3a3a3a393a3a3a3a3a3a3a3a3a3a3a3a3a3a262700000000000000001d3a3a3a3a3a3a3a3a3d0000000000000000002c00000006000000000000000000000000000000000000000000
0000003c003a3a3a3a393a0000000000001f3a3a3a3a3a3a3a3a3a3a3a3a3a0d0000040000000000000000000000000006001f3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a0d2b0000000000002b3a3a3a3a3a3a3a3a3a0000000000000000002c00000004000000000000000000000000000000000000000000
0000003c003a3a3a3a3a3a0000000000343a3a3a3a3a3a3a3a3a3a3a3a3a3a3a0d000000000000000000000000000000001f3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a0d000000000000343a3a3a3a3a3a3a3a3a0000000000000000002c00000000000000000000000000000000040000000700000600
0000003c003a3a3a3a3a3a0000000000353a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a0d00000700000000000000000000001f3a3a3a3a3a3a3a3a393a3a3a3a3a3a3a3a393a3a3a3a3a3a3a3a3a3a0d2b0000002b3e3a3a3a3a3a3a3a3a3a0000000000000000002c00000000000000000000000000000000000000000000000000
0004003c003a3a3a3a3a3a00070000343a3a3a3a3a3a3a3a3a393a3a3a3a3a3a3a3a0d0000000000000000000000001f3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a393a3a3a3a3a3a0d002b001f3a3a3a3a3a3a3a3a3a3a0400000000000000002c00000400000000000000000000000000000000000000000000
0000003c003a3a393a3a3a00000000353a3a3a3a3a3a393a3a3a3a3a3a3a3a3a3a3a3a0d000000000000000000001f3a3a3a3a3a3a3a3a3a3a3a3a08092b00002b0a0b3a3a3a3a393a3a3a3a3a3a3a2614253a393a3a3a3a3a3a3a3a3a0000000000000500002c00000000000000060000000000000004000000000005000000
0000003c003a3a3a3a3a3a000000343a3a3a3a3a3a3a3a3a3a3a3a3a393a3a393a3a3a3a0d000000040000002b1f3a3a3a3a3a3a3a393a3a3a08092b0000000000002b0a0b3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a180000000000000000002c00000000000000000000000000000000000006000000000600
0000003c003a3a393a3a3a000000353a3a3a3a3a3a3a3a08150b3a3a3a3a3a3a3a3a3a3a3a0d0000000000001f3a3a3a3a3a3a3a3a3a3a3a0f2b000000000000000000002b0e3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a1c0000000007000400002c00000000000000000000000000000000000000000000000000
__sfx__
00010000000000000014050140503633015050333502a050190503c1501c050380503435033350333503335033350333500b35017350250500000000000000000000000000000000000000000000000000000000
011000030015400154001540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000030215402154021540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f00030415404154041540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00030515405154051540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000030715407154071540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000915409154091540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000030b1540b1540b1540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000253502e450253502d450253502e4500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000253202e420253202d420253202e4200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000003350083500c3501035014350193501b35001300193501a3400135005350093500d350103501435017350193501b35000300183501a3500a3000435006350093500e3501235016350193501b35000000
010600002765032650366503a6503f6503f6003d6503f6503f6003d6503f650006003d6503f650006003d6503f650006003d6503f650006003d6503f650006003d6503f650006003d6503f650006003d6503f650
00060006193501b35000000193501b350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 01424344

