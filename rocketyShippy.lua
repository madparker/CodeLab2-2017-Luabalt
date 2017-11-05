rocketyShippy = {  

  upperLimit = 109,
  lowerLimit = 739,

  x = 0,
  y = 0,
  width = 255/2,
  height = 118/2,
  body,
  shape
} -- the table representing the class, which will double as the metatable for the instances

rocketyShippy.__index = rocketyShippy -- failed table lookups on the instances should fallback to the class table, to get methods

--function rocketyShippy:makerocketyShippy(x, y, tileSize) --makes rocketyShippy
function rocketyShippy:makerocketyShippy(x)
 
  local self = setmetatable({}, rocketyShippy) --set the metatable for the given table

  --self:setuprocketyShippy(x, y, tileSize) --calls setuprocketyShippy
  self:setuprocketyShippy(x)

  return self
end

function rocketyShippy:setuprocketyShippy(x) --makes rocketyShippy

  --self.tileSize = tileSize --sets size, and positions
  self.x = x + love.math.random() * 100
  self.y = love.math.random() * (lowerLimit - upperLimit) + upperLimit

  --self.width = math.ceil((love.math.random( ) * 10) + 50) --sets width and height randomly
  --self.height = math.ceil(5 + love.math.random( ) * 7)
  --self.height = 7
  self.body = love.physics.newBody(world, 0, 0, "static") --sets stuff for physics, physics styuffs
  self.shape = love.physics.newRectangleShape(self.x, self.y, 
                                              self.width, 
                                              self.height)

  fixture = love.physics.newFixture(self.body, self.shape)
  fixture:setFriction(0)
  fixture:setUserData("rocketyShippy")
end

function rocketyShippy:update(body, dt)

  if self.x + self.width/2 < body:getX() - 20 then 
      self:setuprocketyShippy(
          other_rocketyShippy.x + other_rocketyShippy.width, 
          other_rocketyShippy.y,
          16)
  end
end

function rocketyShippy:draw(rocketyShippyImage)
  x1, y1 = self.shape:getPoints()

  love.graphics.draw(rocketyShippyImage, x1, y1, 0, 0.5, 0.5, 0, 0)
end
