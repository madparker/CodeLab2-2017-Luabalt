local anim8 = require 'anim8'
require 'building'

tileQuads = {} -- parts of the tileset used for different tiles

local time = 0

playerMoveSpeed = 100
shootTime = 0.5

t = 0
shakeDuration = -1
shakeMagnitude = 0

function love.load()
  -- Set the width and height of the window (in pixels)
  width = 700
  height = 700
  
  love.window.setMode(width, height, {resizable=false})
  love.window.setTitle("Luabalt")

  -- One meter is 32px in physics engine
  love.physics.setMeter(15)
  -- Create a world 0 gravity (top down)
  world = love.physics.newWorld(0, 0, true)

  background=love.graphics.newImage('media/iPadMenu_atlas0.png')
  --Make nearest neighbor, so pixels are sharp
  background:setFilter("nearest", "nearest")

  --Get Tile Image
  tilesetImage=love.graphics.newImage('media/play1_atlas0.png')
  --Make nearest neighbor, so pixels are sharp
  tilesetImage:setFilter("nearest", "nearest") -- this "linear filter" removes some artifacts if we were to scale the tiles
  tileSize = 16
 
 -- load spritesheet for walker
  walkerImg = love.graphics.newImage("media/images/walker2.png")

  local g = anim8.newGrid(walkerImg:getWidth()/6, walkerImg:getHeight()/2, walkerImg:getWidth(), walkerImg:getHeight())
  idleAnim = anim8.newAnimation(g('1-1',1),1)
  walkAnim = anim8.newAnimation(g('1-6',1), 0.1)
  shootAnim = anim8.newAnimation(g('1-6',2), 0.1)

  currentAnim1 = idleAnim

  shooting1 = false
  
  player1_body = love.physics.newBody(world, 400, 100, "dynamic")
  player1_box = love.physics.newRectangleShape(28, 28, 30, 30)
  fixture1 = love.physics.newFixture(player1_body, player1_box)
  fixture1:setUserData("Player1")
  player1_body:setMassData(player1_box:computeMass( 1 ))
  player1_body:setFixedRotation(true)

  player1Orientation = 1
 
  tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, 1500)

shootTime1 = shootTime
shootTime2 = shootTime
 
  -- Set the collision callback.
  world:setCallbacks(beginContact,endContact)

  love.graphics.setNewFont("media/Flixel.ttf", 14)
  love.graphics.setBackgroundColor(155,155,155)


 --AUDIO
 -- Cache the audio
  

  shape = love.physics.newRectangleShape(450, 500, 100, 100)

  player1_velX = 0
  player1_velY = 0
end



function love.update(dt)

  player1_velX = 0
  player1_velY = 0

  currentAnim1:update(dt)
  
  world:update(dt)
  

if love.keyboard.isDown( "w" ) and shooting1 == false then
   player1_velY = -playerMoveSpeed
end

if love.keyboard.isDown( "a" ) and shooting1 == false then
   player1_velX = -playerMoveSpeed
   player1Orientation = 1
end

if love.keyboard.isDown( "s" ) and shooting1 == false then
   player1_velY = playerMoveSpeed
end

if love.keyboard.isDown( "d" ) and shooting1 == false then
   player1_velX = playerMoveSpeed
   player1Orientation = -1
end

if shooting1 then
  Shooting(dt)
  end

if shooting1 == true then
  currentAnim1 = shootAnim
elseif (player1_velX ~= 0 or player1_velY ~= 0) then
  currentAnim1 = walkAnim
  else
    currentAnim1 = idleAnim
end


player1_body:setLinearVelocity(player1_velX, player1_velY)
 
  updateTilesetBatch()
 
  --Checking shake duration time and ending shake
  if t < shakeDuration then 
    t = t + dt
  end

end

function Shooting(dt)

  if shootTime1 > 0 then
  shootTime1 = shootTime1-dt
  
else
  shooting1 = false
  shootTime1 = shootTime
  

  end
end

function love.draw()

  --Draw screen shake
  if t < shakeDuration then
    local dx = love.math.random(-shakeMagnitude, shakeMagnitude)
    local dy = love.math.random(-shakeMagnitude, shakeMagnitude)
    love.graphics.translate(dx, dy)
    print ("SHAKE DRAW: " .. dx)
  end

  -- Sets up the level and player sprites / tilesets
  love.graphics.draw(background, 0, 0, 0, 1.78, 1.56, 0, 200)

  

  currentAnim1:draw(walkerImg, player1_body:getX(), player1_body:getY(), player1_body:getAngle(), player1Orientation, 1,90,0)

  
  love.graphics.setColor(255, 0, 255)
if shooting1 then
  love.graphics.rectangle("line", player1_body:getX() - player1Orientation * 60, player1_body:getY(), 60, 50 )
end
love.graphics.setColor(255, 255, 0)
love.graphics.rectangle("line", player1_body:getX(), player1_body:getY(), 30, 30 )
   
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(tilesetBatch, 0, 0, 0, 1, 1)

end

function startShake(duration, magnitude)
    t, shakeDuration, shakeMagnitude = 0, duration or 1, magnitude or 5
end

function updateTilesetBatch()
  tilesetBatch:clear()


  tilesetBatch:flush()
end

-- Called when key pressed. Takes input key and condition for executing code
function love.keypressed( key, isrepeat )
  if key == "space" and shooting1 == false then
    shootAnim:gotoFrame(1)
    shooting1 = true
    startShake(0.5,2)
  end
   
end



-- Checks if game window is active and selected (in focus) 
function love.focus(f)
  if not f then
    print("LOST FOCUS")
  else
    print("GAINED FOCUS")
  end
end

-- Prints message when the game window is closed.
function love.quit()
  print("Thanks for playing! Come back soon!")
end