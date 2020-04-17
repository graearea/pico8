pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
 -- mole 3d engine
 -- by alistair sheehy hutton

 --a column vector, lh co-ord 3d engine

 vm_solid = 0
 vm_wire = 1
 vm_points = 2
 vm_mixed = 3

 --shade selection based on 
 --incidene of angle between 
 --light and normal (in range -1 to 1)
 --each entry in the colour pair is value 
 --to be memset to create dithering effect
 --the reverse for each line to alternate 
 --the pattern 
 shading_white = {
  thresholds = {-0.9,-0.5,0.0,0.2,0.4,0.6,0.7,1.0},
  colours = {{0x05,0x50},{0x55,0x55},{0xd5,0x5d}, {0xdd,0xdd}, {0x6d,0xd6}, {0x66,0x66}, {0x76,0x67}, {0x77,0x77}}
 }

 shading_brown = {
  thresholds = {0.2,0.5,0.75,1.0},
  colours = {{0x54,0x45},{0x24,0x42},{0x44,0x44},{0x94,0x49}}
 }

 shading_green = {
  thresholds = {0.0,0.5,0.9,1.0},
  colours = {{0x35,0x53},{0xb3,0x3b},{0xbb,0xbb},{0xab,0xba}}
 }

 shading_red = {
  thresholds = {},
  colours = {}
 }

 function dot(a,b)
  return a[1]*b[1] + a[2]*b[2] + a[3]*b[3]
 end

 function cot(a)
  return cos(a)/sin(a)
 end

 function sort(a)
  --insertion sort based on z axis
  for i=1,#a do
   local j = i
   while j > 1 and a[j-1].pos[3] < a[j].pos[3] do
    a[j],a[j-1] = a[j-1],a[j]
    j = j - 1
   end
  end
 end

 function vec_sub(v1,v2)
  return {
   v1[1] - v2[1],
   v1[2] - v2[2],
   v1[3] - v2[3],
  }
 end

 function cross(a,b)
  return {
   a[2]*b[3] - a[3]*b[2],
   a[3]*b[1] - a[1]*b[3],
   a[1]*b[2] - a[2]*b[1]
  }
 end

 scale = 1.0
 rotation = 0
 light_pos={15,5,5,1}


 --a bunch of meshes, select 
 --the one you want by truing
 --the approriate if
 --tree selected at the moment
 --the _init code adds w(=1) to 
 --the points so no need to 
 --specify it even though i 
 --have for some meshes
 if false then
 --cobra mkiii
 points = {
 {0.25,0.0,0.59375},{-0.25,0.0,0.59375},{0.0,0.203125,0.1875},{-0.9375,-0.02375,-0.0625},{0.9375,-0.02375,-0.0625},{-0.6875,0.125,-0.3125},{0.6875,0.125,-0.3125},{1.0,-0.0625,-0.3125},{-1.0,-0.0625,-0.3125},{0.0,0.203125,-0.3125},{-0.25,-0.1875,-0.3125},{0.25,-0.1875,-0.3125},{-0.28125,0.0625,-0.34375},{-0.0625,0.09375,-0.34375},{0.0625,0.09375,-0.34375},{0.28125,0.0625,-0.34375},{0.28125,-0.09375,-0.34375},{0.0625,-0.125,-0.34375},{-0.0625,-0.125,-0.34375},{-0.28125,-0.09375,-0.34375},{-0.0125,-0.0125,0.59375},{-0.0125,-0.0125,0.703125},{-0.625,-0.046875,-0.34375},{-0.625,0.046875,-0.34375},{-0.6875,0.0,-0.34375},{0.625,0.046875,-0.34375},{0.6875,0.0,-0.34375},{0.625,-0.046875,-0.34375},{0.0125,-0.0125,0.59375},{0.0125,-0.0125,0.703125},{0.0125,0.0125,0.59375},{0.0125,0.0125,0.703125},{-0.0125,0.0125,0.59375},{-0.0125,0.0125,0.703125}
 }

 faces = {
 {3,2,1},{1,2,11,12},{7,3,1},{1,5,7},{1,12,8,5},{2,3,6},{6,4,2},{2,4,9,11},{6,3,10},{3,7,10},{6,9,4},{8,7,5},{10,7,8,12,11,9,6},{15,16,17,18},{13,14,19,20},{26,27,28},{25,24,23},{22,30,29,21},{32,30,29,31},{33,31,32,34},{22,34,33,21},{21,30,32,34}
 }
 end
 if true then
 --traditional cube
 points = {
  {-1,-1,1,1},
  {-1,1,1,1},
  {1,-1,1,1},
  {1,1,1,1},
  {-1,-1,-1,1},
  {-1,1,-1,1},
  {1,-1,-1,1},
  {1,1,-1,1},
  {0,0,-1.8,1}, --middle
  {0,0,1.8,1},
  {0,-1.8,0,1},
  {0,1.8,0,1}
 }
 bob={
 {3,4,2,1},
 {5,6,8,7},
 {7,3,1,5},
 {6,2,4,8}
 }

 faces = {
 {2,6,5,1},--
 {8,4,3,7},--
 
 {4,10,3},--
 {1,10,2},--
 {2,10,4},--
 {3,10,1},--
 
 {9,8,7},--
 {9,5,6},--
 {9,6,8},--
 {9,7,5},--

 {12,6,2},--
 {12,2,4},--
 {12,8,6},--
 {12,4,8},--

 {11,3,1},--
 {11,7,3},--
 {11,5,7},--
 {11,1,5},--

 }
 end

 if false then
 --tree
 points = {
  {-0.25,0,0.25,1},
  {-0.25,2,0.25,1},
  {0.25,0,0.25,1},
  {0.25,2,0.25,1},
  {-0.25,0,-0.25,1},
  {-0.25,2,-0.25,1},
  {0.25,0,-0.25,1},
  {0.25,2,-0.25,1},
  {0,4,0,1},
  {-1.0,2,1.0,1},
  {1.0,2,1.0,1},
  {-1.0,2,-1.0,1},
  {1.0,2,-1.0,1},
 }

 faces = {
 {10,12,13,11},
 {3,4,2,1},
 {2,6,5,1},
 {5,6,8,7},
 {7,3,1,5},
 {8,4,3,7},
 {10,11,9},
 {10,9,12},
 {12,9,13},
 {13,9,11}
 }

 face_colours = {
  shading_green,
  shading_brown,
  shading_brown,
  shading_brown,
  shading_brown,
  shading_brown,
  shading_green,
  shading_green,
  shading_green,
  shading_green,
 }
 end

 --backface and bounds culling
 function clockwise_and_in_view(sc,f,view)
  
  local sum = 0
  local in_bounds = false
  for i=1,#f do
   local first,second = i, (i%#f)+1
   local p1,p2 = sc[f[first]], sc[f[second]]
   sum += (p2[1]-p1[1])*(p2[2]+p1[2])
   if p1[1] > view.xpos and p1[1] < view.xmax and p1[2] > view.ypos and p1[2] < view.ymax then
    if p1[3] >= 0.0 and p1[3] <= 1.0  and p2[3] >= 0 and p2[3] <= 1 then
     in_bounds = true
    end
   end
  end
  
  return in_bounds and sum < 0.0
 end

 --define and arbitary sized and
 --positioned viewport to draw
 --into
 function c_viewport(width, height, xpos, ypos, colour, mode)
  local view = {
   ["width"]=width,
   ["height"]=height,
   ["ar"]=height/width,
   ["xpos"]=xpos,
   ["ypos"]=ypos,
   ["xmax"]=xpos+width-1,
   ["ymax"]=ypos+height-1,
   ["colour"]=colour,
   ["proj_m"]=proj_m(0.125,1.0,100.0,height/width)
  }
  
  if mode == nil then
   view.mode = "solid"
  else
   view.mode = mode
  end
  
  --the magic happens here.
  function view:render(models)
   clip(self.xpos,self.ypos,self.width,self.height)
   rectfill(self.xpos, self.ypos, self.xpos+self.width, self.ypos+self.height, self.colour)
      sort(models)
      
      local cam_transform = cam:view_transform()
      for model in all(models) do

    --cheekily set to world transform
    --matrix at the same time, 
    --yay side effects
       local wc = model:world_cords()  
       
          local dp = {}
         
       local t = mm(
         self.proj_m,
         mm(
          cam_transform,
          model:world_transform()
         )
        )
    
          for p in all(model.v) do         
           local tr = tp(t,p)
           local x = (tr[1]/tr[4])*self.width+self.width/2.0 + self.xpos
           local y = (-tr[2]/tr[4])*self.height+self.height/2.0 + self.ypos
           local z = tr[3]/tr[4]
           local w = tr[4]/tr[4]
           add(dp, {x,y,z})
          end

          --setup for diagnostics
          cursor(0,0)
       
       --for each face (and associated normal)
       --draw on screen if visible
       for fi=1,#(model.f) do
           local f = model.f[fi]
           local n = model.wn[fi]
           local shading = model.shading         

           if model.mesh.face_shading != nil then           
            shading = model.mesh.face_shading[fi]
           end
    
           if clockwise_and_in_view(dp,f,self) then
            local mode = self.mode
            if model.view_mode != nil then
             mode =model.view_mode
            end
            if mode == vm_points or mode == vm_mixed then
             draw_points(f,dp)
            end
            if mode == vm_solid or mode == vm_mixed then
             draw_poly(f, dp, n, wc, shading, self)
            end
            if mode == vm_wire or mode == vm_mixed then
             wireframe(f,dp)
            end
           end
          end
      end
      clip()
  end
  
  return view
 end

 --a camera object
 --based on rotations 
 --so the actual camera space 
 --matrix is exciting inverse
 --http://ksimek.github.io/2012/08/22/extrinsic/
 function c_camera() 
  local cam = {
   ["pos"] = {0,0,0,1},
   ["x_rot"] = 0,
   ["y_rot"] = 0,
   ["z_rot"] = 0,
   ["recalc"] = true
  }
  
  function cam:view_transform()
   if self.recalc then
    self.cached = mm(
        rot_z_m(self.z_rot),
           mm(
               rot_y_m(self.y_rot),
               rot_x_m(self.x_rot)
           )
       )
       self.cached = transpose(self.cached)
       local loc = tp(self.cached, self.pos)
       self.cached[4] = -loc[1]
       self.cached[8] = -loc[2]
       self.cached[12] = -loc[3]
   
       self.recalc = false
   end
   return self.cached
  end
  
  function cam:transform_point(point, proj_m)
   local tr = tp(mm(proj_m,self.cached),point)
   return tr
  end
  
  function cam:set_rot(x,y,z)
   self.x_rot = x
   self.y_rot = y
   self.z_rot = z
   self.recalc = true
  end
  
  function cam:set_pos(x,y,z)
   self.pos = {x,y,z,1}
   self.recalc=true
  end
  
  return cam
 end


 function c_mesh(v,faces, shading, face_shading)
  for vertex in all(v) do
   vertex[4] = 1
  end
  
  local m = {
   ["v"] = v,
   ["f"] = faces,
   ["shading"] = shading,
   ["face_shading"] = face_shading
  }
  local normals = {}
     for f in all(faces) do
   local v1 = vec_sub(v[f[1]], v[f[2]])
      local v2 = vec_sub(v[f[1]], v[f[3]])
      local n = cross(v1,v2)
      local m = sqrt(n[1]*n[1]+n[2]*n[2]+n[3]*n[3])
      n[1] = n[1] / m
      n[2] = n[2] / m
      n[3] = n[3] / m
      n[4] = 1
      add(normals, n)      
     end
    
     m.n = normals
  return m
 end

 function c_model(mesh, pos, scale, x_rot, y_rot, z_rot, view_mode)
  local model = {
   ["v"]=mesh.v,
   ["f"]=mesh.f,
   ["n"]=mesh.n,
   ["mesh"] = mesh,
   ["pos"] = pos,
   ["scale"] = scale,
   ["x_rot"] = x_rot,
   ["y_rot"] = y_rot,
   ["z_rot"] = z_rot,
   ["recalc"] = true,
   ["rt"] = nil,
   ["t"] = nil,
   ["wc"] = {},
   ["wn"] = {},
   ["view_mode"] = view_mode,
   ["shading"] = mesh.shading
  }
  
  function model:world_cords()
   if self.recalc then
    local t = self:world_transform()
    for index=1,#(self.v) do
     local p = self.v[index]
     self.wc[index] = tp(t,p)
    end

    for index=1,#(self.n) do
    local n = self.n[index]
     self.wn[index] = tp(self.rt,n)
    end
    
    self.recalc = false
   end

   return self.wc
  end
  
  function model:world_transform() 
   if self.recalc then
       self.rt = mm(
        rot_z_m(self.z_rot),
        mm(
         rot_y_m(self.y_rot),
         rot_x_m(self.x_rot)
        )
       )
   
          self.t = mm(
           translate_m(self.pos[1], self.pos[2], self.pos[3]),
           self.rt
          )
         end
   return self.t
  end
  
  function model:set_rot(x,y,z)
   self.x_rot = x
   self.y_rot = y
   self.z_rot = z
   self.recalc = true
  end
  
  function model:set_pos(x,y,z)
   self.pos = {x,y,z}
   self.recalc=true
  end
  
  return model
 end

 ship_mesh = c_mesh(
  points, 
  faces, 
  shading_white,
  face_colours --get rid of this for non-tree meshes
 )


 --lets create a scene
 rot_ship = c_model(
  ship_mesh, 
  {0,0,20}, 
  1.0, 0.0, 0.0, 0.0)

 models = {
    rot_ship,
    c_model(ship_mesh, {3,0,20}, 0.8, 0, 0.125, 0),    
    c_model(ship_mesh, {-3,0,20}, 0.8, 0, 0.125, 0),
    c_model(ship_mesh, {6,0,20}, 0.8, 0, 0.125, 0),
    c_model(ship_mesh, {-6,0,20}, 0.8, 0, 0.125, 0),
    c_model(ship_mesh, {9,0,20}, 0.8, 0, 0.125, 0),
    c_model(ship_mesh, {-9,0,20}, 0.8, 0, 0.125, 0),
    c_model(ship_mesh, {3,0,30}, 0.8, 0, 0.125, 0),    
    c_model(ship_mesh, {-3,0,30}, 0.8, 0, 0.125, 0),
    c_model(ship_mesh, {6,0,30}, 0.8, 0, 0.125, 0),
    c_model(ship_mesh, {-6,0,30}, 0.8, 0, 0.125, 0),
    c_model(ship_mesh, {9,0,30}, 0.8, 0, 0.125, 0),
    c_model(ship_mesh, {-9,0,30}, 0.8, 0, 0.125, 0),
 }

 other_models = {
  c_model(ship_mesh, {0,-2,10}, 1.0, 0.02, 0.02, 0.02),
 }

 function transpose(m)
  return {
   m[1],m[5],m[9],m[13],
   m[2],m[6],m[10],m[14],
   m[3],m[7],m[11],m[15],
   m[4],m[8],m[12],m[16]
  }
 end

 function rot_x_m(amount)
  return {
   1,0,0,0,
   0,cos(amount),sin(-amount),0,
   0,-sin(-amount),cos(amount),0,
   0,0,0,1
  }
 end

 function rot_y_m(amount)
  return {
   cos(amount),0,-sin(-amount),0,
   0,1,0,0,
   sin(-amount),0,cos(amount),0,
   0,0,0,1 
  }
 end

 function rot_z_m(amount)
  return {
   cos(amount),sin(-amount),0,0,
   -sin(-amount),cos(amount),0,0,
   0,0,1,0,
   0,0,0,1
  }
 end

 function scale_m(x,y,z)
  return {
   x,0,0,0,
   0,y,0,0,
   0,0,z,0,
   0,0,0,1
  }
 end

 function translate_m(x,y,z)
  return {
   1,0,0,x,
   0,1,0,y,
   0,0,1,z,
   0,0,0,1  
  }
 end 

 function identity()
  return {
   1,0,0,0,
   0,1,0,0,
   0,0,1,0,
   0,0,0,1
  }
 end

 function proj_m(a,n,f,ar)
  local h = cos(a/2)/sin(-a/2)
  local w = h*ar
  return {
   w,0,0,0,
   0,h,0,0,
   0,0,(f/(f-n)),(n*-f/(f-n)),
   0,0,1,0
   }
 end

 function mm(a,b)
  return {
   a[1]*b[1]+a[2]*b[5]+a[3]*b[9]+a[4]*b[13],
   a[1]*b[2]+a[2]*b[6]+a[3]*b[10]+a[4]*b[14],
   a[1]*b[3]+a[2]*b[7]+a[3]*b[11]+a[4]*b[15],
   a[1]*b[4]+a[2]*b[8]+a[3]*b[12]+a[4]*b[16],
   
   a[5]*b[1]+a[6]*b[5]+a[7]*b[9]+a[8]*b[13],
   a[5]*b[2]+a[6]*b[6]+a[7]*b[10]+a[8]*b[14],
   a[5]*b[3]+a[6]*b[7]+a[7]*b[11]+a[8]*b[15],
   a[5]*b[4]+a[6]*b[8]+a[7]*b[12]+a[8]*b[16],
   
   a[9]*b[1]+a[10]*b[5]+a[11]*b[9]+a[12]*b[13],
   a[9]*b[2]+a[10]*b[6]+a[11]*b[10]+a[12]*b[14],
   a[9]*b[3]+a[10]*b[7]+a[11]*b[11]+a[12]*b[15],
   a[9]*b[4]+a[10]*b[8]+a[11]*b[12]+a[12]*b[16],
   
   a[13]*b[1]+a[14]*b[5]+a[15]*b[9]+a[16]*b[13],
   a[13]*b[2]+a[14]*b[6]+a[15]*b[10]+a[16]*b[14],
   a[13]*b[3]+a[14]*b[7]+a[15]*b[11]+a[16]*b[15],
   a[13]*b[4]+a[14]*b[8]+a[15]*b[12]+a[16]*b[16],
  }
 end

 function tp(m,p)
  return {
   m[1]*p[1]+m[2]*p[2]+m[3]*p[3]+m[4]*p[4],
   m[5]*p[1]+m[6]*p[2]+m[7]*p[3]+m[8]*p[4],     
   m[9]*p[1]+m[10]*p[2]+m[11]*p[3]+m[12]*p[4],
   m[13]*p[1]+m[14]*p[2]+m[15]*p[3]+m[16]*p[4]
  }
 end

 --you know, for debugging
 function str_screen_point(p)
  local out = ""
  for i=1,2 do
   out = out..p[i]..","
  end
  return out
 end

 function str_point(p)
  local out = ""
  for i=1,4 do
   out = out..p[i]..","
  end
  return out
 end

 function str_matrix(m)
  local out = ""
  for i=1,16 do
   out = out..m[i]..","
   if i % 4 == 0 then
    out = out.."\n"
   end
  end
  return out
 end

 function _update()
  total_scan_lines = 0
  if btn(0) then
   rot_ship:set_rot(rot_ship.x_rot+0.01, rot_ship.y_rot, rot_ship.z_rot)
  end
  
   if btn(1) then
   rot_ship:set_rot(rot_ship.x_rot-0.01, rot_ship.y_rot, rot_ship.z_rot)
  end
  
   if btn(2) then
   rot_ship:set_rot(rot_ship.x_rot, rot_ship.y_rot+0.01, rot_ship.z_rot)
  end
  
   if btn(3) then
   rot_ship:set_rot(rot_ship.x_rot, rot_ship.y_rot-0.01, rot_ship.z_rot)
  end
  
  if btn(4) then
   rot_ship:set_rot(rot_ship.x_rot, rot_ship.y_rot, rot_ship.z_rot+0.01)
  end
  
   if btn(5) then
   rot_ship:set_rot(rot_ship.x_rot, rot_ship.y_rot, rot_ship.z_rot-0.01)
  end
  
  if btn(0,1) then
   cam:set_rot(cam.x_rot+0.005, cam.y_rot, cam.z_rot)
  end
   if btn(1,1) then
   cam:set_rot(cam.x_rot-0.005 , cam.y_rot, cam.z_rot)
  end
  if btn(2,1) then
   cam:set_rot(cam.x_rot, cam.y_rot+0.005, cam.z_rot)
  end
  if btn(3,1) then
   cam:set_rot(cam.x_rot, cam.y_rot-0.005, cam.z_rot)
  end
  cam.x_rot = min(max(cam.x_rot,-0.5),0.5)
  if btnp(4,1) then
  cam:set_pos(60,20,0)
  end
 end

 function wireframe(f, dp)
  for p=0,#f-1 do
   local s = f[p+1]
   local e = f[(p+1)%#f+1]
   line(
    dp[s][1],dp[s][2],
    dp[e][1],dp[e][2],
    0
   )
  end
 end

 function scan_line(y, pa, pb, pc, pd, draw_colour, shade_colour, minx,maxx,miny,maxy)

  total_scan_lines += 1
  if y <miny or y > maxy then return end
  local gradient1, gradient2 = 1,1
  
  if pa[2] != pb[2] then
   gradient1 = (y-pa[2])/(pb[2]-pa[2])
  end
  if pc[2] != pd[2] then
   gradient2 = (y-pc[2])/(pd[2]-pc[2])
  end
  
  local sx = flr(pa[1] + (pb[1] - pa[1])*max(0,min(gradient1,1)))
  local ex = flr(pc[1] + (pd[1] - pc[1])*max(0,min(gradient2,1)))

  local mem_base = 0x6000
  if not ((sx < minx and ex < minx) or (sx > maxx and ex > maxx)) then
   
   sx = max(minx,min(sx,maxx))
      ex = max(minx,min(ex,maxx))
      if ex < sx then
       sx,ex = ex,sx
      end
      local sos = sx % 2
      local eos = ex % 2
      local yind = y*64+0x6000
      local ctu = -1
      if y%2 == 0 then
       ctu = draw_colour
      else
       ctu = shade_colour
      end
   if sos == 1 then
    sx -= 1
    if(yind+sx/2 < 0x6000) then
     --it's all gone horribly wrong
     printh(sx)
     printh(yind+sx/2)
     dsgdfs()
    end       
    poke(yind+sx/2, bor(band(peek(yind+sx/2),0x0f), band(0xf0,ctu)))       
    sx += 2
   end 
   
   if eos == 0 then              
    poke(yind+flr(ex/2), bor(band(peek(yind+ex/2),0xf0),band(0x0f, ctu)))
    ex -= 1
   end
   
   memset(yind +sx/2,ctu, (ex/2-sx/2)+1)
     end
 end

 function vert_light_angle(vertex, normal, light_pos)
  local lv = vec_sub(light_pos, vertex)
  local m = sqrt(lv[1]*lv[1]+lv[2]*lv[2]+lv[3]*lv[3])
  lv[1] = lv[1] / m
  lv[2] = lv[2] / m
  lv[3] = lv[3] / m
  return max(-1, normal[1]*lv[1] + normal[2]*lv[2] + normal[3]*lv[3])
 end

 --turn a >3 vertex poly into a triangle fan for drawing
 function draw_poly(f, dp, n, cs, shading, view)
  local start_p = 1
  local tot_ps = #f
  fill_tri(f, dp, n, cs, shading, view)
  start_p += 3
  while start_p <= #f do
   local newf = {f[1],f[start_p-1],f[start_p]}
   fill_tri(newf, dp, n, cs, shading, view)
   start_p += 1
  end
 end

 --this fill_tri code comes wholesale from
 --https://www.davrous.com/2013/06/21/tutorial-part-4-learning-how-to-write-a-3d-software-engine-in-c-ts-or-js-rasterization-z-buffering/
 --can't help but feel there are lots of optimisations i could do
 function fill_tri(f, dp, n, cs, shading, view)
      local  intensity = min(1.0,vert_light_angle(cs[f[1]],n,light_pos))
      local draw_colour = 0
      local shade_colour = 0
      for index=1,#shading.colours do
       if intensity <= shading.thresholds[index] then
        draw_colour = shading.colours[index][1]
        shade_colour = shading.colours[index][2]
        break
       end
      end
  local minx = view.xpos
  local miny = view.ypos
  local maxx = view.xmax
  local maxy = view.ymax
  local x,y = 1,2
  local p1,p2,p3 = dp[f[1]], dp[f[2]], dp[f[3]]
  if p1[y] > p2[y] then p1,p2 = p2,p1 end
  if p2[y] > p3[y] then p2,p3 = p3,p2 end
  if p1[y] > p2[y] then p1,p2 = p2,p1 end
  
  local dp1p2 = 0.0
  if p2[y] - p1[y] > 0 then
   dp1p2 = (p2[x] - p1[x])/(p2[y]-p1[y])
  end
  
  local dp1p3 = 0.0
  if p3[y] - p3[y] > 0 then
   dp1p3 = (p3[x] - p1[x])/(p3[y]-p1[y])
  end
  
  if dp1p2 > dp1p3 then
   for yy=flr(p1[y]),flr(p3[y]) do
    if yy < p2[y] then
     scan_line(yy,p1,p3,p1,p2,draw_colour, shade_colour, minx,maxx,miny,maxy)
    else
     scan_line(yy,p1,p3,p2,p3,draw_colour, shade_colour, minx,maxx,miny,maxy)
    end
   end
  else
   for yy=flr(p1[y]),flr(p3[y]) do
    if yy < p2[y] then
     scan_line(yy,p1,p2,p1,p3,draw_colour, shade_colour, minx,maxx,miny,maxy)
    else
     scan_line(yy,p2,p3,p1,p3,draw_colour, shade_colour, minx,maxx,miny,maxy)
    end
   end
  end
 end

 function draw_points(f, pts)
  for i in all(f) do
   pset(pts[i][1],pts[i][2],7)
  end
 end

 function _draw()   
  cls()
  view1:render(models) 
  view2:render(other_models)
  print(stat(1),0,0,7)
  print(total_scan_lines,0,8,7)
 end

 function _init()
  
  --create 2 seperate view ports just to show i can
  --they do both share the same camera with is a bit poo 
  view1 = c_viewport(128,88,0,0,12,vm_solid)
  view2 = c_viewport(40,40,88,88,1,vm_wire)
  
  cam = c_camera()
  cls()
 end
