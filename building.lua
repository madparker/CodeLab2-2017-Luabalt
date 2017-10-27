building = { 
  tileSize = 16,

  screen_height,

  x = 0,
  y = 0,
  width = 0,
  height = 0,
  body,
  shape
} -- the table representing the class, which will double as the metatable for the instances

building.__index = building -- failed table lookups on the instances should fallback to the class table, to get methods

function building:makeBuilding(x, y, tileSize)


  local self = setmetatable({}, building)

  self:setupBuilding(x, y, tileSize)

  return self
end

function building:setupBuilding(x, tileSize)

  self.tileSize = tileSize
  self.x = x
  self.y = 300

  self.width  = math.ceil((love.math.random( ) * 10) + 20)
  self.height = math.ceil(5 + love.math.random( ) * 7)
  --self.height = 7
  self.body = love.physics.newBody(world, 0, 0, "static")
  self.shape = love.physics.newRectangleShape(self.x, self.y, 
                                              self.tileSize * self.width, 
                                              self.tileSize * self.height)
  fixture = love.physics.newFixture(self.body, self.shape)
  fixture:setUserData("Building")
end

function building:update(body, dt, other_building)

  if self.x + self.width/2 * self.tileSize < body:getX() then
      self:setupBuilding(
          other_building.x + other_building.width  * self.tileSize + 150, 
          16)
  end
end

function building:draw(tilesetBatch, tileQuads)
  x1, y1 = self.shape:getPoints()

  tilesetBatch:add(tileQuads[0], self.x, self.y, 0)
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
