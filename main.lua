local anim8 = require 'anim8'
require 'building'
require 'human'
--require 'laser'


tileQuads = {} -- parts of the tileset used for different tiles
humans = {}
local time = 0

playerMoveSpeed = 150
shootTime = 0.5

t = 0
shakeDuration = -1
shakeMagnitude = 0

playerWidth = 50
playerHeight = 20
shootWidth = 80
shootHeight =40

--humanSize = 20

--Set how many humans we want spawned when the game starts
nrHumans = 8


function love.load()
  width = 700
  height = 700
  
  love.window.setMode(width, height, {resizable=false})
  love.window.setTitle("Luabalt")

  love.physics.setMeter(15)
  -- create world without gravity ( top down)
  world = love.physics.newWorld(0, 0, true)

  background=love.graphics.newImage('media/iPadMenu_atlas0.png')
  background:setFilter("nearest", "nearest")

  --Get Tile Image for ground tiles?
  tilesetImage=love.graphics.newImage('media/play1_atlas0.png')
  tilesetImage:setFilter("nearest", "nearest") -- this "linear filter" removes some artifacts if we were to scale the tiles
  tileSize = 16

  -- grey ground tiles
  tileQuads[0] = love.graphics.newQuad(100, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())

  -- brick ground tiles
  tileQuads[1] = love.graphics.newQuad(116, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())

	
  tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, 1500)

  -- load spritesheet for walker
  walkerImg = love.graphics.newImage("media/images/walker2.png")

  local g = anim8.newGrid(walkerImg:getWidth()/6, walkerImg:getHeight()/2, walkerImg:getWidth(), walkerImg:getHeight())
  idleAnim = anim8.newAnimation(g('1-1',1),1)
  walkAnim = anim8.newAnimation(g('1-6',1), 0.1)
  shootAnim = anim8.newAnimation(g('1-6',2), 0.1)

  currentAnim1 = idleAnim

  -- Used to make player face the direction they are walking
  player1Orientation = 1

  --Bool for shooting
  shooting1 = false
  isCreated = false
  
  --Player Physics Components
  player1_body = love.physics.newBody(world, 100, 100, "dynamic")
  player1_box = love.physics.newRectangleShape(playerWidth/2, playerHeight/2, playerWidth, playerHeight)
  fixture1 = love.physics.newFixture(player1_body, player1_box)
  fixture1:setUserData("Player1")
  player1_body:setMassData(player1_box:computeMass( 1 ))
  player1_body:setFixedRotation(true)

  --Players Velocity
  player1_velX = 0
  player1_velY = 0



  player1Score = 0

  shootTime1 = shootTime
  shootTime2 = shootTime

  humans = {h1,h2,h3,h4,h5}

  for i = 1,nrHumans do humans[i] = human:makeHuman(GetScreenSide(),love.math.random( 100, 200 )) end

 
  -- Set the collision callback.
  world:setCallbacks(beginContact,endContact)

  love.graphics.setNewFont("media/Flixel.ttf", 14)
  love.graphics.setBackgroundColor(155,155,155)

  CounterReset()


 --AUDIO
--audio functions

    function RandomizePitch(min, max)
      randomPitch = love.math.random(min,max)
    end

    function RandomizeVolume(min, max)
      randomVol = love.math.random(min,max)
    end
 

 -- Cache the audio

 playDeathSound = true
 playRunSound = true

 music = love.audio.newSource("media/18-machinae_supremacy-lord_krutors_dominion.mp3", "stream")
 music:setVolume(0.1)
 love.audio.play(music)

 footstep1 = love.audio.newSource("media/foot1.mp3", "static")
 footstep2 = love.audio.newSource("media/foot2.mp3", "static")
 footstep3 = love.audio.newSource("media/foot3.mp3", "static")
 footstep3 = love.audio.newSource("media/foot3.mp3", "static")

 monsterStep1 = love.audio.newSource("media/flap1.mp3", "static")
 monsterStep2 = love.audio.newSource("media/flap2.mp3", "static")
 monsterStep3 = love.audio.newSource("media/flap3.mp3", "static")


 --sound layers of the Laser
    laser1 = love.audio.newSource("media/crumble.mp3", "static")
    laser1:setVolume(0.2)
    laser2 = love.audio.newSource("media/flyby.mp3", "static")
    laser2:setVolume(0.6)
    laser3 = love.audio.newSource("media/bomb_launch.mp3", "static")
    laser3:setVolume(0.2)
    laser4 = love.audio.newSource("media/giant_leg.mp3", "static")
    laser4:setVolume(0.4)

 shape = love.physics.newRectangleShape(450, 500, 100, 100)

end

function love.update(dt)

  player1_velX = 0
  player1_velY = 0

  currentAnim1:update(dt)
  currentAnim0:update(dt)
  
  world:update(dt)


  if love.timer.getTime() - start > 2 then
    for i = 1,nrHumans do
      if humans[i] == nil then 
        humans[i] = human:makeHuman(GetScreenSide(),love.math.random( 100, 200 ))
        CounterReset()
      end
    end
  end

  for i = 1,nrHumans do 
    if humans[i] ~= nil then
      humans[i]:update(humans[i],dt)
      if humans[i].body:getX() < -30 or humans[i].body:getX() > width + 30  then
       humans[i] = nil
      end
   end
  end


  
-- player 1 inputs

if love.keyboard.isDown( "w" ) and shooting1 == false  and player1_body:getY()>100 then
   player1_velY = -playerMoveSpeed
end

if love.keyboard.isDown( "a" ) and shooting1 == false and player1_body:getX()>0 then
   player1_velX = -playerMoveSpeed
   player1Orientation = 1
end

if love.keyboard.isDown( "s" ) and shooting1 == false and player1_body:getY()<height-playerHeight then
   player1_velY = playerMoveSpeed
end

if love.keyboard.isDown( "d" ) and shooting1 == false and player1_body:getX()<width-playerWidth then
   player1_velX = playerMoveSpeed
   player1Orientation = -1
end

if shooting1 then
  Shooting(dt)
  laser1:play()
  laser2:play()
  laser3:play()
  laser4:play()
  
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

function CounterReset()
  start = love.timer.getTime()
end

function Shooting(dt)

  if shootTime1 > 0 then
  shootTime1 = shootTime1-dt
    if isCreated == false then
      CreateLaser(player1_body:getX() + playerWidth/2-shootWidth/2 - player1Orientation*(playerWidth/2+shootWidth/2),
                  player1_body:getY() - shootHeight/2)
      isCreated = true
    end
  
else
   
  isCreated = false

  shooting1 = false
  shootTime1 = shootTime
  laserObject_fixture:destroy()
  
  end
end

function CreateLaser(x,y)

  laserObject_body = love.physics.newBody(world, x, y, "static")
  laserObject_shape = love.physics.newRectangleShape(shootWidth/2, shootHeight/2, shootWidth, shootHeight)


  laserObject_fixture = love.physics.newFixture(laserObject_body, laserObject_shape)
  laserObject_fixture:setUserData("laser")
  --fixture:setFilterData(1,1,-1)
end


function love.draw()

  --Draw screen shake
  if t < shakeDuration then
    local dx = love.math.random(-shakeMagnitude, shakeMagnitude)
    local dy = love.math.random(-shakeMagnitude, shakeMagnitude)
    love.graphics.translate(dx, dy)
    --print ("SHAKE DRAW: " .. dx)
  end

  -- Sets up the level and player sprites / tilesets
  love.graphics.draw(background, 0, -120, 0, 1.78, 1.56, 0, 200)
  DrawBackground()

  currentAnim1:draw(walkerImg, player1_body:getX()+playerWidth/2, player1_body:getY()-60, player1_body:getAngle(), player1Orientation, 1,90,0)

  
  love.graphics.setColor(255, 0, 255)
  -- debug show shooting area 5- player1Orientation * 80

--if shooting1 then
  --love.graphics.rectangle("line",
  --player1_body:getX() + playerWidth/2-shootWidth/2 - player1Orientation*(playerWidth/2+shootWidth/2),
  --player1_body:getY() - shootHeight/2, shootWidth, shootHeight)
--end

-- debug show player coll
love.graphics.setColor(255, 255, 0)
love.graphics.rectangle("line", player1_body:getX(), player1_body:getY(), playerWidth, playerHeight )

-- debug show test coll
--love.graphics.rectangle("line", body1:getX(),body1:getX(),50,50)


  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(tilesetBatch, 0, 0, 0, 1, 1)

   -- Print Score
  love.graphics.print("Humans Purged : " .. player1Score, 20, 10)

  --human1:draw()
 -- human2:draw()

 for i =1,nrHumans do 
  if humans[i] ~= nil then
    humans[i]:draw()
  end
end


end

function  beginContact( bodyA, bodyB, coll )
  local aData=bodyA:getUserData()
  local bData =bodyB:getUserData()

  if(aData == "Player1" and bData == "Human") then

  end


end

function startShake(duration, magnitude)
    t, shakeDuration, shakeMagnitude = 0, duration or 1, magnitude or 5
end

function updateTilesetBatch()
  tilesetBatch:clear()

  -- tilesetBatch:add(tileQuads[0])
  -- DrawBackground(tilesetBatch, tileQuads)

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

function DrawBackground()

  for x=width - 1, 0, -1 do 
    for y=height - 1, 1 do
      if x == 0 and y == 0 then
        tilesetBatch:add(tileQuads[0], x1 + x * tileSize, y1 + y * tileSize, 0)
      else
        if y == 0 and x == self.width - 1 then
          tilesetBatch:add(tileQuads[1], x1 + x * tileSize, y1 + y * tileSize, 0)
        else 
          if y == 0 then
            tilesetBatch:add(tileQuads[0], x1 + x * tileSize, y1 + y * tileSize, 0)
          else 
            num = math.floor(x + y + x1 + y1)
            if (num)%5 == 0 then
              --tilesetBatch:add(tileQuads[5], x1 + x * tileSize, y1 + y * tileSize, 0)
            else
              tilesetBatch:add(tileQuads[1], x1 + x * tileSize, y1 + y * tileSize, 0)
            end
          end
        end
      end
    end
  end
end

function GetScreenSide()

  if love.math.random(1,100) % 2 == 0 then
    return width + 30
  else
    return -30
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