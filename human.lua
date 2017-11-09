local anim8 = require 'anim8'

human = {
  x = x,
  y = y,
  width = width,
  height = height,
  body,
  shape,
  image,
  fixture,
  
	
}

human.__index = human

function human:makeHuman(x,y)

	local self = setmetatable({},human)

	self:setUpHuman(x,y)

	return self
end

function human:setUpHuman()

	self.x = 100
  	self.y = 200

  	self.width = 30
  	self.height = 30

  	self.body = love.physics.newBody(world, 200, 200, "dynamic")
  	--self.body:setMassData(self.body:computeMass(1))
  	self.body:setFixedRotation(true)
	self.shape = love.physics.newRectangleShape(self.x, self.y, self.width, self.height)

	self.fixture = love.physics.newFixture(self.body, self.shape)
  	self.fixture:setUserData("Human")

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

 	currentAnim2:draw(self.image, self.x, self.y, self.body:getAngle(), 1, 1)
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