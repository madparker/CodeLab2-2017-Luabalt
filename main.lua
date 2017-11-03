local anim8 = require 'anim8'
require 'building'

tileQuads = {} -- parts of the tileset used for different tiles

local time = 0

t = 0
shakeDuration = -1
shakeMagnitude = 0

function love.load()
  -- Set the width and height of the window (in pixels)
  width = 910
  height = 320
  distance = 0
  onGround = true;
  dead = false

  love.window.setMode(width, height, {resizable=false})
  love.window.setTitle("Luabalt")

  -- One meter is 32px in physics engine
  love.physics.setMeter(15)
  -- Create a world with standard gravity
  world = love.physics.newWorld(0, 9.81*100, true)

  background=love.graphics.newImage('media/iPadMenu_atlas0.png')
  --Make nearest neighbor, so pixels are sharp
  background:setFilter("nearest", "nearest")

  --Get Tile Image
  tilesetImage=love.graphics.newImage('media/play1_atlas0.png')
  --Make nearest neighbor, so pixels are sharp
  tilesetImage:setFilter("nearest", "nearest") -- this "linear filter" removes some artifacts if we were to scale the tiles
  tileSize = 16
 
  -- crate
  tileQuads[0] = love.graphics.newQuad(0, 0, 
    18, 18,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- left corner
  tileQuads[1] = love.graphics.newQuad(228, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- top middle
  tileQuads[2] = love.graphics.newQuad(324, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- right middle
  tileQuads[3] = love.graphics.newQuad(387, 68, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- middle1
  tileQuads[4] = love.graphics.newQuad(100, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  tileQuads[5] = love.graphics.newQuad(116, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- game over text
  tileQuads[6] = love.graphics.newQuad(42, 20, 
    390, 48,
    tilesetImage:getWidth(), tilesetImage:getHeight())

  tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, 1500)

  -- Create a Body for the crate.
  crate_body = love.physics.newBody(world, 0, 0, "dynamic")
  crate_box = love.physics.newRectangleShape(9, 9, 18, 18)
  fixture = love.physics.newFixture(crate_body, crate_box)
  fixture:setUserData("Crate") -- Set a string userdata
  crate_body:setMassData(crate_box:computeMass( 2 ))

  --text = "hello World"

  --Makes buildings by calling the "make building" function on the building script

  building1 = building:makeBuilding(450, 16, false)
  building2 = building:makeBuilding(1380, 16, true)

  playerImg = love.graphics.newImage("media/player2.png")
  -- Create a Body for the player.
  body = love.physics.newBody(world, 400, 100, "dynamic")
  -- Create a shape for the body.
  player_box = love.physics.newRectangleShape(28, 28, 30, 30)
  -- Create fixture between body and shape
  fixture = love.physics.newFixture(body, player_box)

  fixture:setUserData("Player") -- Set a string userdata
  
  -- Calculate the mass of the body based on attatched shapes.
  -- This gives realistic simulations.
  body:setMassData(player_box:computeMass( 1 ))
  body:setFixedRotation(true)
  --the player an init push.
  body:applyLinearImpulse(1000, 0)

  -- Set the collision callback.
  world:setCallbacks(beginContact,endContact)

  love.graphics.setNewFont("media/Flixel.ttf", 14)
  love.graphics.setBackgroundColor(155,155,155)

  --Cache the animations 

  local g = anim8.newGrid(30*1.5, 30*1.5, playerImg:getWidth()*1.5, playerImg:getHeight()*1.5)
  runAnim = anim8.newAnimation(g('1-14',1), 0.05)
  jumpAnim = anim8.newAnimation(g('15-19',1), 0.1)
  inAirAnim = anim8.newAnimation(g('1-8',2), 0.1)
  rollAnim = anim8.newAnimation(g('9-19',2), 0.05)

  currentAnim = inAirAnim

 --AUDIO
 -- Cache the audio
  playDeathSound = true
  playRunSound = true

  music = love.audio.newSource("media/18-machinae_supremacy-lord_krutors_dominion.mp3", "stream")
  music:setVolume(0.1)
  love.audio.play(music)

  runSound = love.audio.newSource("media/footsteps.wav", "static")
  runSound:setVolume(0.4)
  runSound:setLooping(true)

  scrapeSound = love.audio.newSource("media/scrape.wav", "static")
  scrapeSound:setVolume(0.4)
  scrapeSound:setLooping(true)

  --footstep1 = love.audio.newSource("media/foot1.wav"), "static")
  --footstep2 = love.audio.newSource("media/foot2.wav", "static")
  --footstep3 = love.audio.newSource("media/foot3.wav", "static")

  jumpSound = love.audio.newSource("media/jump.wav", "static")
  jumpSound:setVolume(0.4)

  sideColSound = love.audio.newSource("media/sidecol.wav", "static")
  sideColSound:setVolume(0.4)

  deathSound = love.audio.newSource("media/death.mp3", "static")
  deathSound:setVolume(0.4)
  
  landSound = love.audio.newSource("media/land.wav", "static")
  landSound:setVolume(0.6)

  rollSound = love.audio.newSource("media/roll.wav", "static")
  rollSound:setVolume(0.4)

  shape = love.physics.newRectangleShape(450, 500, 100, 100)
end

-- added function to round numbers
function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function love.update(dt)

  currentAnim:update(dt)
  world:update(dt)

  -- Calls the Update functions in the building script. Passes it its body, delta time and the next building (loop)
  building1:update(body, dt, building2)
  building2:update(body, dt, building1)

  updateTilesetBatch()
  distance = round(body:getX(),-1) -- -1 as decimal places, lol
  distanceText = distance/10 .. "m"

  --Checking shake duration time and ending shake
  if t < shakeDuration then 
    t = t + dt
  end

if body:getY() > height then
      dead = true
      if playDeathSound then
        deathSound:play()
        playDeathSound = false
     end
  end

if dead == true then
      --love.audio.stop(runSound)
      body:setLinearVelocity(0,0)
  end

  --transitions animations?

  if(time < love.timer.getTime( ) - 0.25) and currentAnim == jumpAnim then
    currentAnim = inAirAnim
    currentAnim:gotoFrame(1)
  end

  if (time < love.timer.getTime( ) - 0.5) and currentAnim == rollAnim then
    currentAnim = runAnim
    currentAnim:gotoFrame(1)
  end

  if currentAnim == runAnim and dead == false then
    --apples a force on the player body (x value)
    --print("ON GROUND")
    playRunSound = true
    if playRunSound then
      runSound:play()
   end
    body:applyLinearImpulse(1100 * dt, 0)
  elseif dead == false then
    body:applyLinearImpulse(550 * dt, 0)
  end
end


function love.draw()

  -- Sets up the level and player sprites / tilesets
  love.graphics.draw(background, 0, 0, 0, 1.78, 1.56, 0, 200)

  --Draw screen shake
  if t < shakeDuration then
    local dx = love.math.random(-shakeMagnitude, shakeMagnitude)
    local dy = love.math.random(-shakeMagnitude, shakeMagnitude)
    love.graphics.translate(dx, dy)
    print ("SHAKE DRAW: " .. dx)
  end
  
  love.graphics.setColor(255, 255, 255)
  --love.graphics.print(text, 10, 10)
  love.graphics.print(distanceText, 850, 10)

  love.graphics.translate(width/100 - body:getX(), 0)
   
  currentAnim:draw(playerImg, body:getX(), body:getY(), body:getAngle())

  --love.graphics.setColor(255, 0, 0)
  --love.graphics.polygon("line", building1.shape:getPoints())
  --love.graphics.polygon("line", building2.shape:getPoints())

  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(tilesetBatch, 0, 0, 0, 1, 1)
if (dead==true) then
  love.graphics.draw(tilesetImage,tileQuads[6],body:getX()+width/2 - 390/2, height/2 - 48/2)
   gameOverText = "You ran " .. distanceText .. " before your death. Jump to retry your daring escape."
  love.graphics.print (gameOverText, body:getX()+width/2 - 650/2, height/1.7)
  end

end

function startShake(duration, magnitude)
    t, shakeDuration, shakeMagnitude = 0, duration or 1, magnitude or 5
end

function updateTilesetBatch()
  tilesetBatch:clear()

  tilesetBatch:add(tileQuads[0], crate_body:getX(), crate_body:getY(), crate_body:getAngle());

  building1:draw(tilesetBatch, tileQuads);
  building2:draw(tilesetBatch, tileQuads);

  tilesetBatch:flush()
end

-- Called when key pressed. Takes input key and condition for executing code
function love.keypressed( key, isrepeat )
  -- If the up button is pressed and OnGround is true, apply force to player on the Y axis and play sprite animation
  if key == "space" and onGround and dead==false then
    body:applyLinearImpulse(0, -1500)
    currentAnim = jumpAnim
    currentAnim:gotoFrame(1)
    time = love.timer.getTime( )

    love.audio.play(jumpSound)
	onGround = false;
  end
    if key == "down" then

    elseif key == "space" and dead == true then

      love.audio.stop()
      love.load()
  end
end

-- This is called every time a collision begin.
function beginContact(bodyA, bodyB, coll)

  -- Get information on the two colliding objects 
  local aData=bodyA:getUserData()
  local bData =bodyB:getUserData()

-- Get the X and Y coordinates of the collision
  cx,cy = coll:getNormal()
  --text = text.."\n"..aData.." colliding with "..bData.." with a vector normal of: "..cx..", "..cy

  --print(text)

-- If one of the two objects that collided are The Player, set OnGround to true. 
  if(aData == "Player" or bData == "Player") then

	-- Play animations and sound
    -- Checks for collision between player and building and compares the y normal to see if the player is grounded or not
    if(cy ~= 0 and ((aData == "Player" and bData == "Building") or (aData == "Building" and bData == "Player"))) then
		onGround = true
  end
  --Checks for side collision and plays sound
  if(cx ~= 0 and ((aData == "Player" and bData == "Building") or (aData == "Building" and bData == "Player"))) then
    --play crash
    sideColSound:play()
  end

	if(cx ~= 0 and ((aData == "Player" and bData == "Crate") or (aData == "Crate" and bData == "Player"))) then
         body:applyLinearImpulse(-500, 0)
         scrapeSound:play()
         startShake(3, 10)
    end

    landSound:play()
    currentAnim = rollAnim
    if (currentAnim == rollAnim) then
      rollSound:play()
    end
    currentAnim:gotoFrame(1)
    time = love.timer.getTime( )
    --runSound:play()

  end
end

-- This is called every time a collision end.
function endContact(bodyA, bodyB, coll)
-- Sets on ground to false (jump state) (animation calls are made in the key press function)
  onGround = false
  local aData=bodyA:getUserData()
  local bData=bodyB:getUserData()
  text = "Collision ended: " .. aData .. " and " .. bData
-- If on the the jumping bodies is the Player, stop the running sound
  if(aData == "Player" or bData == "Player") then
    runSound:stop();
    playRunSound = false
  end

  if (aData == "Crate" and bData == "Player") or (aData == "Player" and bData == "Crate") then
    onGround = true
    scrapeSound:stop();
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