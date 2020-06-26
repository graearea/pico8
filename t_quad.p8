pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
function tquad(xa, ya, xb, yb, xc, yc, xd, yd, mx, my, w, h)

 w=sgn(w)*(abs(w)-0x.0001)
 h=sgn(h)*(abs(h)-0x.0001)
 local sxa, sya = mx, my
 local sxb, syb = mx+w, my
 local sxc, syc = mx+w, my+h
 local sxd, syd = mx, my+h
 
 while ya>yb or ya>yc or ya>yd do
  xa, ya, sxa, sya, xb, yb, sxb, syb, xc, yc, sxc, syc, xd, yd, sxd, syd = xb, yb, sxb, syb, xc, yc, sxc, syc, xd, yd, sxd, syd, xa, ya, sxa, sya
 end

 
 local x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6 = xa, ya
 local sx1, sy1, sx2, sy2, sx3, sy3, sx4, sy4, sx5, sy5, sx6, sy6 = sxa, sya
 local d
 
 if yc >= yb and yc >= yd then
  x6, y6, sx6, sy6 = xc, yc, sxc, syc
 
  if yb <= yd then
   x2, y2, sx2, sy2 = xb, yb, sxb, syb
   x4, y4, sx4, sy4 = xd, yd, sxd, syd
   
   d = (yb-ya)/(yd-ya)
   x3 = xa + d*(xd-xa)
   sx3 = sxa + d*(sxd-sxa)
   sy3 = sya + d*(syd-sya)
   
   d = (yd-yb)/(yc-yb)
   x5 = xb + d*(xc-xb)
   sx5 = sxb + d*(sxc-sxb)
   sy5 = syb + d*(syc-syb)
  else
   x2, y2, sx2, sy2 = xd, yd, sxd, syd
   x4, y4, sx4, sy4 = xb, yb, sxb, syb
   
   d = (yd-ya)/(yb-ya)
   x3 = xa + d*(xb-xa)
   sx3 = sxa + d*(sxb-sxa)
   sy3 = sya + d*(syb-sya)
   
   d = (yb-yd)/(yc-yd)
   x5 = xd + d*(xc-xd)
   sx5 = sxd + d*(sxc-sxd)
   sy5 = syd + d*(syc-syd)
  end

 else
  if yb >= yd then
   x6, y6, sx6, sy6 = xb, yb, sxb, syb
   
   x2, y2, sx2, sy2 = xd, yd, sxd, syd
   x5, y4, sx5, sy5 = xc, yc, sxc, syc
   
   d = (yd-ya)/(yb-ya)
   x3 = xa + d*(xb-xa)
   sx3 = sxa + d*(sxb-sxa)
   sy3 = sya + d*(syb-sya)
   
   d = (yc-ya)/(yb-ya)
   x4 = xa + d*(xb-xa)
   sx4 = sxa + d*(sxb-sxa)
   sy4 = sya + d*(syb-sya)
  else
   x6, y6, sx6, sy6 = xd, yd, sxd, syd
   
   x2, y2, sx2, sy2 = xb, yb, sxb, syb
   x5, y4, sx5, sy5 = xc, yc, sxc, syc
   
   d = (yb-ya)/(yd-ya)
   x3 = xa + d*(xd-xa)
   sx3 = sxa + d*(sxd-sxa)
   sy3 = sya + d*(syd-sya)
   
   d = (yc-ya)/(yd-ya)
   x4 = xa + d*(xd-xa)
   sx4 = sxa + d*(sxd-sxa)
   sy4 = sya + d*(syd-sya)
  end
 end
 
 if y1 then
  local yk2, xk2, xk3 = y2-y1, x2-x1, x3-x1
  local sxk2, sxk3 = sx2-sx1, sx3-sx1
  local syk2, syk3 = sy2-sy1, sy3-sy1
 
  for yy = y1, y2 do
   local n = (yy-y1)/yk2
     
   local xx2 = x1+n*xk2
   local xx3 = x1+n*xk3
   local d = abs(xx3-xx2)
     
   local sxx2 = sx1+n*sxk2
   local syy2 = sy1+n*syk2
   local sxx3 = sx1+n*sxk3
   local syy3 = sy1+n*syk3
  
   tline(xx2, yy, xx3, yy, sxx2, syy2, (sxx3-sxx2)/d, (syy3-syy2)/d)
  end
 end

 local yk4, xk4, xk5 = y4-y2, x4-x3, x5-x2
 local sxk4, sxk5 = sx4-sx3, sx5-sx2
 local syk4, syk5 = sy4-sy3, sy5-sy2

 for yy = y2, y4 do
  local n = (yy-y2)/yk4
  
  local xx4 = x3+n*xk4
  local xx5 = x2+n*xk5
  local d = abs(xx5-xx4)
     
  local sxx4 = sx3+n*sxk4
  local syy4 = sy3+n*syk4
  local sxx5 = sx2+n*sxk5
  local syy5 = sy2+n*syk5
  
  tline(xx4, yy, xx5, yy, sxx4, syy4, (sxx5-sxx4)/d, (syy5-syy4)/d)
 end
 
 
 local yk6 = y6-y4
 
 if yk6 == 0 then return end
 
 local xk4, xk5 = x6-x4, x6-x5
 local sxk4, sxk5 = sx6-sx4, sx6-sx5
 local syk4, syk5 = sy6-sy4, sy6-sy5
 
 for yy = y4, y6 do
  local n = (yy-y4)/yk6
  
  local xx4 = x4+n*xk4
  local xx5 = x5+n*xk5
  local d = abs(xx5-xx4)
  
  local sxx4 = sx4+n*sxk4
  local syy4 = sy4+n*syk4
  local sxx5 = sx5+n*sxk5
  local syy5 = sy5+n*syk5
  
  tline(xx4, yy, xx5, yy, sxx4, syy4, (sxx5-sxx4)/d, (syy5-syy4)/d)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
