bound = { 
  tileSize = 16, 

  screen_height,

  x = 0,
  y = 0,
  width = 570,
  height = 64,
  body,
  shape
} -- the table representing the class, which will double as the metatable for the instances

bound.__index = bound -- failed table lookups on the instances should fallback to the class table, to get methods

--function bound:makebound(x, y, tileSize) --makes bound
function bound:makebound(x, y, tileSize)
 
  local self = setmetatable({}, bound) --set the metatable for the given table

  --self:setupbound(x, y, tileSize) --calls setupbound
  self:setupbound(x, y, tileSize)

  return self
end

function bound:setupbound(x, y, tileSize) --makes bound

  self.tileSize = tileSize --sets size, and positions
  self.x = x
  self.y = y

  --self.width = math.ceil((love.math.random( ) * 10) + 50) --sets width and height randomly
  --self.height = math.ceil(5 + love.math.random( ) * 7)
  --self.height = 7
  self.body = love.physics.newBody(world, 0, 0, "static") --sets stuff for physics, physics styuffs
  self.shape = love.physics.newRectangleShape(self.x, self.y, 
                                              self.width, 
                                              self.height)

  fixture = love.physics.newFixture(self.body, self.shape)
  fixture:setFriction(0)
  fixture:setUserData("bound")
end

function bound:update(body, dt, other_bound)

  if self.x + self.width/2 < body:getX() - 20 then 
      self:setupbound(
          other_bound.x + other_bound.width, 
          other_bound.y,
          16)
  end
end

function bound:draw(floorImage)
  x1, y1 = self.shape:getPoints()

  love.graphics.draw(floorImage, x1, y1, 0, 2, 2, 0, 0)
end
