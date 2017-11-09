local anim8 = require 'anim8'

monster = { 
  tileSize = 16,

  screen_height,

  
  x = 0,
  y = 0,
  width = 0,
  height = 0,
  body,
  shape
} -- the table representing the class, which will double as the metatable for the instances

monster.__index = monster

function monster:makeMonster(x)

  local self = setmetatable({}, monster)

  self:setupMonster(x)

  return self
  
end

function monster:setupMonster(x)

  --self.tileSize = tileSize
  self.x = x
  self.y = 300

  self.width  = 300
  self.height = 300
  --self.height = 7
  self.body = love.physics.newBody(world, 100, 0, "static")
  self.shape = love.physics.newRectangleShape(200, 0, 400, 500)
  fixture = love.physics.newFixture(self.body, self.shape)
  fixture:setUserData("monster")
end

function monster:update(dt)

  if self.x + self.width/2 > 200 then
      
  end

end

function monster:draw(monsterAnim, monsterImage)
  --x1, y1 = self.shape:getPoints()

  --monsterAnim:draw(monsterImage, self.body:getX(), self.body:getY(), self.body:getAngle())

  
end