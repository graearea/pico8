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
  for i = 1, 16 do
    new_car(i)
  end
  score=0
end
log = ""

function _update()
  time = time + 1
  octo:update()
  for car in all(cars) do
    car:update()
  end
end

function _draw()
  cls(1)
  print(flr(score), 0, 0, 0)
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
    x = 64 - 20,
    y = 0,
    update = function(self)
      if btn(⬆️) then
        self.y = self.y - 2
      end
      if btn(⬇️) then
        self.y = self.y + 2
      end
      if btnp(❎) then
        self.zapping = true
        row = flr(self.y / 8)
        log = row
        cars[row]:zap()
      else
        self.zapping = false
      end


    end,
    zapping = false,
    draw = function(self)
      palt(0, true)
      spr(5, self.x, self.y)
      if self.zapping then
        spr(6, self.x + 8, self.y)
      end
    end
  }
end

function draw_parking_spots()
  for i = 1, 16 do
    spr(55, 64 - 8, i * 8)
    spr(56, 64 - 0, i * 8)
  end
end

function time_str()
  --time is 30/second
  secs = time / 10
  return flr((secs / 6) % 24) .. ":" .. flr(secs % 6) .. 0
end
-->8
-- cars

arriving = "arriving"
charging = "charging"
leaving = "leaving"
burning = "burning"
parked = "parked"

function new_car(slot)
  car = {
    slot = slot,
    x = -16,
    y = slot * 8,
    soc = rnd(30),
    colour = set_colour(),
    state = arriving,
    draw = function(self)
      pal(11, self.colour)
      spr(0, self.x, self.y)
      spr(1, self.x + 8, self.y)
      pal(11, 11)
      if self.state == burning then
        sp = flr(rnd(2))
        spr(17 + sp, self.x, self.y)
        spr(17 + sp, self.x + 8, self.y)
      elseif self.state == charging or self.state == parked then
        rect(self.x + 20, self.y, self.x + 60, self.y + 8, 12)
        rectfill(self.x + 20, self.y, self.x + 20 + to_bar(self.soc), self.y + 8, colour_for_charge(self.soc))
      end
    end,
    arriving = function(self)
      if self.x < (64 - 8) then
        self.x = self.x + 1
      else
        self.state = parked
      end
    end,
    update = function(self)
      if self.state == arriving then
        self:arriving()
      elseif self.state == charging then
        self.soc = self.soc + 1
        if self.soc > 100 then
          self.state = burning
        end
      elseif self.state == burning then
      elseif self.state == leaving then
        self:leave()
      end
    end,

    complete = function(self)
      if self.soc > 80 then
        self.leaving = true
      end
    end,
    leave = function(self)
      self.x = self.x + 1
      if self.x > 130 then
        score = score + self.soc
        add(cars,new_car(slot),slot)
        del(cars, self)
      end
    end,
    zap = function(self)
      if self.state == parked then
        self.state = charging
      elseif self.state == charging then
        self.state = leaving
      end
    end
  }
  add(cars, car)
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

function to_bar(perc)
  return 40 / 100 * perc
end

function colour_for_charge(charge)
  if charge > 90 then
    return 8
  elseif charge > 30 then
    return 12
  else
    return 10
  end
end