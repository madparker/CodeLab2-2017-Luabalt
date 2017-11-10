local anim8 = require 'anim8'

human = {
  x = 0,
  y = 0,
  width = 0,
  height = 0,
  body,
  shape,
  image,
  orientation,
  fixture
}

human.__index = human

function human:makeHuman(x,y)

	local self = setmetatable({},human)

	self:setupHuman(x,y)


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

  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setUserData("Human")
  self.fixture:setFilterData(1,1,-1)
 

  self.image = love.graphics.newImage("media/player2.png")
  local g = anim8.newGrid(self.image:getWidth()/19, self.image:getHeight()/2, self.image:getWidth(), self.image:getHeight())
  runAnim = anim8.newAnimation(g('1-16',1),0.05)
  jumpAnim = anim8.newAnimation(g('1-9',2), 0.1)

  currentAnim0 = runAnim


  if self.x > 0 then
    self.orientation = -1
  else 
    self.orientation = 1
  end

end

function human:update(body,dt)
 	
 	--currentAnim0:update(dt)
  self.body:setLinearVelocity((love.math.random(2000,4000)* self.orientation) * dt,0)

end

function human:draw()

 currentAnim0:draw(self.image, self.body:getX(), self.body:getY(), self.body:getAngle(), self.orientation, 1,self.width/2, 0)

  
  --love.graphics.rectangle("line", self.body:getX(), self.body:getY(), self.width, self.height )
end

function human:deathCheck()
	if self.fixture:isDestroyed() then 
	--print("DEAD")
  return true
  else return false

	end
end
