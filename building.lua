building = { 
  tileSize = 16,

  screen_height,

  x = 0,
  y = 0,
  width = 0,
  height = 0,
  body,
  shape,
  crate_body,
  crate_box
} -- the table representing the class, which will double as the metatable for the instances 1

building.__index = building -- failed table lookups on the instances should fallback to the class table, to get methods

function building:makeBuilding(x, y, tileSize, crateYes)

  local self = setmetatable({}, building)

-- Calls the building setup function, passing coordinates and a tile size
  self:setupBuilding(x, y, tileSize, crateYes)

  return self
end

function building:setupBuilding(x,  tileSize, crateYes)

  self.tileSize = tileSize
  self.x = x
  self.y = 320
  self.crateYes = crateYes

  self.width  = math.ceil((love.math.random( ) * 10) + 50)
  self.height = math.ceil(5 + love.math.random( ) * 7)
  --self.height = 7
  self.body = love.physics.newBody(world, 0, 0, "static")
  self.shape = love.physics.newRectangleShape(self.x, self.y, 
                                              self.tileSize * self.width, 
                                              self.tileSize * self.height)
  fixture = love.physics.newFixture(self.body, self.shape)
  fixture:setUserData("Building")

  
  
  -- Create a Body for the crate.
  if self.crateYes then
  	self.crate_body = love.physics.newBody(world, self.x+love.math.random(-200,200), self.y-(self.tileSize *(self.height-5)), "dynamic")
  	self.crate_box = love.physics.newRectangleShape(9, 9, 18, 18)

  
  fixture = love.physics.newFixture(self.crate_body, self.crate_box)
  fixture:setUserData("Crate") -- Set a string userdata
 -- self.crate_body:setMassData(crate_box:computeMass( 2 ))
  end

end

function building:update(body, dt, other_building)

  if self.x + self.width/2 * self.tileSize < body:getX() then
      self:setupBuilding(
          other_building.x + other_building.width  * self.tileSize + 230, 
          16, self.crateYes)
  end
end

function building:draw(tilesetBatch, tileQuads)
  x1, y1 = self.shape:getPoints()
if (self.crateYes==true) then
	tilesetBatch:add(tileQuads[0], self.crate_body:getX(), self.crate_body:getY(),self.crate_body:getAngle())
end

  for x=self.width - 1, 0, -1 do 
    for y=0,self.height - 1, 1 do
      if x == 0 and y == 0 then
        tilesetBatch:add(tileQuads[1], x1 + x * tileSize, y1 + y * tileSize, 0)
      else
        if y == 0 and x == self.width - 1 then
          tilesetBatch:add(tileQuads[3], x1 + x * tileSize, y1 + y * tileSize, 0)
        else 
          if y == 0 then
            tilesetBatch:add(tileQuads[2], x1 + x * tileSize, y1 + y * tileSize, 0)
          else 
            num = math.floor(x + y + x1 + y1)
            if (num)%5 == 0 then
              --tilesetBatch:add(tileQuads[5], x1 + x * tileSize, y1 + y * tileSize, 0)
            else
              tilesetBatch:add(tileQuads[4], x1 + x * tileSize, y1 + y * tileSize, 0)
            end
          end
        end
      end
    end
  end
end
