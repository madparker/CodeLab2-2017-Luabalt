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

function human:setUpHuman(x,  tileSize, crateYes)

	self.x = x
  	self.y = 320

  	self.width = 30
  	self.height = 30

  	self.body = love.physics.newBody(world, 200, 200, "dynamic")
  	--self.body:setMassData(self.body:computeMass(1))
  	self.body:setFixedRotation(true)
	self.shape = love.physics.newRectangleShape(self.x, self.y, self.width, self.height)

	fixture = love.physics.newFixture(self.body, self.shape)
  	fixture:setUserData("Human")

  	self.image = love.graphics.newImage("media/player2.png")
  	local g = anim8.newGrid(self.image:getWidth()/19, self.image:getHeight()/2, self.image:getWidth(), self.image:getHeight())
  	runAnim = anim8.newAnimation(g('1-19',1),1)
    jumpAnim = anim8.newAnimation(g('1-9',2), 0.1)

    currentAnim1 = idleAnim

 end

 function human:draw()

 	currentAnim1:draw(self.image, self.body:getX()+self.width/2, self.body:getY()-60, self.body:getAngle(), 1, 1,90,0)
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