local anim8 = require 'anim8'

human = {
  x = 0,
  y = 0,
  width = 0,
  height = 0,
  body,
  shape,
  image,
}

human.__index = human

function human:makeHuman(x,y)

	local self = setmetatable({},human)

	self:setUpHuman(x,y)

	return self
end

function human:setupHuman(x,y)

  self.x = x
  self.y = y

  self.width = 30
  self.height = 30

  self.body = love.physics.newBody(world, self.x, self.y, "dynamic")
  self.shape = love.physics.newRectangleShape(self.width/2, self.height/2, self.width, self.height)

  self.body:setMassData(self.shape:computeMass(2))
  self.body:setFixedRotation(true)

  fixture = love.physics.newFixture(self.body, self.shape)
  fixture:setUserData("Human")
 

  self.image = love.graphics.newImage("media/player2.png")
  local g = anim8.newGrid(self.image:getWidth()/19, self.image:getHeight()/2, self.image:getWidth(), self.image:getHeight())
  runAnim = anim8.newAnimation(g('1-16',1),0.05)
  jumpAnim = anim8.newAnimation(g('1-9',2), 0.1)

  currentAnim2 = runAnim

 end
  function human:update(dt)
 	
 	currentAnim2:update(dt)
 end

 function human:draw()

 	currentAnim2:draw(self.image, self.body:getX(), self.body:getY(), self.body:getAngle(), 1, 1)

  
  love.graphics.rectangle("line", self.body:getX(), self.body:getY(), self.width, self.height )
 end




-- function CreateHuman()
-- 	nrHumans +=1
-- 	humanBody = love.physics.newBody(world, 200, 200, "dynamic")
-- 	humanBox = love.physics.newRectangleShape(humanSize/2, humanSize/2, humanSize, humanSize)
-- 	humanFixture = love.physics.newFixture(humanBody, humanBox)
-- 	humanFixture:setUserData("human"..nrHumans)
-- 	humanBody:setMassData(humanBody:computeMass( 1 ))
-- 	humanBody:setFixedRotation(true)
-- end