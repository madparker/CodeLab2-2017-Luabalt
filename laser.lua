laser = {
  x = 0,
  y = 0,
  width = 0,
  height = 0,
  body,
  shape,
  fixture,
  
}

laser.__index = laser

function laser:makeLaser(x,y)

	local self = setmetatable({},laser)

	self:setupLaser(x,y)


	return self
end

function laser:setupLaser(x,y)


  self.x = x
  self.y = y

  self.width = 80
  self.height = 40

  self.body = love.physics.newBody(world, self.x, self.y, "static")
  self.shape = love.physics.newRectangleShape(self.width/2, self.height/2, self.width, self.height)


  self.fixture = love.physics.newFixture(self.body, self.shape)
  --self.fixture:setSensor(true)
  self.fixture:setUserData("laser")
  --fixture:setFilterData(1,1,-1)

end

function laser:draw()

	love.graphics.rectangle("line", self.x,self.y, self.width, self.height)
end


function laser:destroyTable()
	print("test")
	setmetatable(self,nil)
end
