-- octopico
-- dynamic charging 
-- start with 1 car, charge it
-- next night 2 cars
-- every failure hitler gets a sale 
-- move octopus to see what the
-- charge is and stop the charging
-- in time
function _init()
  octo = new_octo()
  time = 0
  cars = {}
    for i=1,16 do
        new_car(i)
    end
end

function _update()
    time = time + 1
    octo:update()
    for car in all(cars) do
        car:update()
    end
end

function _draw()
    cls(1)
    print(time_str(), 0, 0, 0)
    palt(15, true)
    palt(0, false)
    draw_parking_spots()
    for car in all(cars) do
        car:draw()
    end
    octo:draw()
end

function new_octo()
  return {
    x = 100,
    y = 0,
    update = function(self)
      if btn(⬆️) then
        self.y = self.y - 2
      end
      if btn(⬇️) then
        self.y = self.y + 2
      end
    end,

    draw = function(self)
      palt(0, true)
      spr(5, self.x, self.y)
    end
  }
    end

function draw_parking_spots()
  for i = 1, 16 do
    spr(55, 128 - 16, i * 8)
    spr(56, 128 - 8, i * 8)
  end
end

function charge_cars()
  for car in all(cars) do
    car:charge()
  end
end
function spawn_cars()
  if rnd(10 ) < 1 then
    add(cars, new_car(#cars))
  end
end

function time_str()
  --time is 30/second
  secs = time / 10
  return flr((secs / 6) % 24) .. ":" .. flr(secs % 6) .. 0
end
-->8
-- cars

arriving="arriving"
charging="charging"
leaving="leaving"
burning="burning"

function new_car(slot)
  car= {
    slot = slot,
    x = -16,
    y = slot * 8,
    soc = rnd(30),
    colour = set_colour(),
    state = arriving,
    draw = function(self)
      pal(8, self.colour)
      spr(0, self.x, self.y)
      spr(1, self.x + 8, self.y)
      if self.is_on_fire then
        pal(8, 8)
        sp = flr(rnd(2))
        spr(17 + sp, self.x, self.y)
        spr(17 + sp, self.x + 8, self.y)
      end
    end,
    arriving=function(self)
      if self.x < (128 - 16) then
        self.x = self.x + 1
      end
    end,
    update = function(self)
      if self.state==arriving then
        self:arriving()
      end
      self.soc = self.soc + 1
      if self.soc > 100 then
        self.is_on_fire = true
      end
    end,

    complete = function(self)
      if self.soc > 80 then
        self.leaving = true
      end
    end,
    leaving = false,
    leave = function(self)
      if leaving then
        self.x = self.x + 1
        if self.x > 130 then
          score = score + self.soc
          del(cars, self)
        end
      end
    end
  }
    add(cars,car)
    return car
end
score = 0

function set_colour()
  col = flr(rnd(15))
  if col == 1 then
    return 3
  else
    return col
  end
end