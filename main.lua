local anim8 = require 'anim8' --local is like private?
require 'building' --require is like using
require 'bound'
require 'rocketyShippy'

tileQuads = {} -- array? parts of the tileset used for different tiles

local time = 0 

local jumpForce = -5000
local gravityScale = 15
local runForce = 1000
local initialForce = 10000
local backgroundOffset = 0
local backgroundMoveSpeed = 200
local floorOffset = 0
local floorMoveSpeed = 500
local floorWidth = 570 * 2


function love.load() --loads the game
  width = 512 * 2 --size of window
  height = 424 * 2

  --love.window.setFullscreen(true)
  love.window.setMode(width, height, {resizable = true}) --sets display to width and height, makes static size
  love.window.setTitle("Floaty Doggy") --sets window title

  -- One meter is 32px in physics engine
  love.physics.setMeter(15)
  -- Create a world with standard gravity
  world = love.physics.newWorld(0, 9.81*gravityScale, true)

  rocketyShippyImage = love.graphics.newImage('media/play2_atlas0.png')
  rocketyShippyImage:setFilter ("nearest", "nearest")

  background=love.graphics.newImage('media/iPadMenu_atlas0.png')
  --Make nearest neighbor, so pixels are sharp
  background:setFilter("nearest", "nearest") --for image scaling, compression format

  --Get Tile Image
  tilesetImage=love.graphics.newImage('media/play1_atlas0.png')
  floorImage = love.graphics.newImage('media/barytiley.png')
  --media/barytiley.png

  floorImage:setFilter("nearest", "nearest")
  --Make nearest neighbor, so pixels are sharp
  tilesetImage:setFilter("nearest", "nearest") -- this "linear filter" removes some artifacts if we were to scale the tiles
  tileSize = 16 --declares the size of the tile
 
  -- cratey
  tileQuads[0] = love.graphics.newQuad(0, 0,  --this is grabbing the graphics from the sprite sheet
    18, 18,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- toppy lefty corner
  tileQuads[1] = love.graphics.newQuad(228, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- toppy middley
  tileQuads[2] = love.graphics.newQuad(324, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- toppy righty corner
  tileQuads[3] = love.graphics.newQuad(387, 68, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- middle1
  tileQuads[4] = love.graphics.newQuad(100, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  --lefty middley
  tileQuads[5] = love.graphics.newQuad(36, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  --righty middley
  tileQuads[6] = love.graphics.newQuad(164, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- window
  tileQuads[7] = love.graphics.newQuad(0,173,
   16, 16,
   tilesetImage:getWidth(), tilesetImage:getHeight())
  endQuad = love.graphics.newQuad(40, 18,
    390, 50,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- floor = love.graphics.newQuad(0, 0, 
  --   570, 32,
  --   floorImage:getWidth(), floorImage:getHeight())
  rocketyShippyQuad = love.graphics.newQuad(128, 4, 
    255, 118, 
    rocketyShippyImage:getWidth(), rocketyShippyImage:getHeight())

  tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, 1500) --creates a new sprite batch! max number of sprites the batch can contain

  -- Create a Body for the crate.
  -- crate_body = love.physics.newBody(world, 850, 200, "dynamic") --where to create body, coords, and body type
  -- crate_box = love.physics.newRectangleShape(9, 9, 18, 18) --x, y, width, height
  -- crate_fixture = love.physics.newFixture(crate_body, crate_box) --creates and attaches a fixture to the body
  -- crate_fixture:setUserData("Crate") -- Set a string userdata
  -- crate_body:setMassData(crate_box:computeMass( 1 )) --sets mass

  -- floor_body = love.physics.newBody(world, 0, height - 100, "dynamic")

  -- text = "hello World" --hi
  text = " "

rocketyShippy = rocketyShippy:makerocketyShippy(width)

  upperBound1 = bound:makebound(0,109)
  upperBound2 = bound:makebound(570,109)
  lowerBound1 = bound:makebound(0,height - 109)
  lowerBound2 = bound:makebound(570,height - 109)
  --building1 = building:makeBuilding(750, 16) --
  --building2 = building:makeBuilding(1800, 16) --

  playerImg = love.graphics.newImage("media/floatydoggy.png") --sets player img, getting spritey for playey
  -- Create a Body for the player.
  body = love.physics.newBody(world, 400, 100, "dynamic") --sets physics for player
  -- Create a shape for the body.
  player_box = love.physics.newRectangleShape(64, 66, 120, 58) --playey boxey
  -- Create fixture between body and shape
  fixture = love.physics.newFixture(body, player_box)
  fixture:setFriction(0)
  fixture:setUserData("Player") -- Set a string userdata
  
  -- Calculate the mass of the body based on attached shapes.
  -- This gives realistic simulations.
  body:setMassData(player_box:computeMass( 1 )) --playey massey
  body:setFixedRotation(true) --player won't rotate, rotatey nopey
  --the player an init push.
  body:applyLinearImpulse(initialForce, 0) -- applies force, shovey playey

  -- Set the collision callback.
  world:setCallbacks(beginContact,endContact) 

  love.graphics.setNewFont(12) --fontey settey
  love.graphics.setBackgroundColor(155,155,155) --rgb color

  -- local g = anim8.newGrid(30, 30, playerImg:getWidth(), playerImg:getHeight()) --ANIMATION SETTY
  -- runAnim = anim8.newAnimation(g('1-14',1), 0.05)
  -- jumpAnim = anim8.newAnimation(g('15-19',1), 0.1)
  -- inAirAnim = anim8.newAnimation(g('1-8',2), 0.1)
  -- rollAnim = anim8.newAnimation(g('9-19',2), 0.05)

  -- currentAnim = inAirAnim --starts with this jumpy anime

  music = love.audio.newSource("media/18-machinae_supremacy-lord_krutors_dominion.mp3", "stream") --boppy setty
  music:setVolume(0.1) --loudy setty
  love.audio.play(music) --boppy playey

  runSound = love.audio.newSource("media/foot1.mp3", "static") --runny soundy
  runSound:setLooping(true); --runny loopy


  --shape = love.physics.newRectangleShape(450, 500, 100, 100) --??????? HERPY DERPY
end

function love.update(dt) --delta time

  -- currentAnim:update(dt)
  world:update(dt)

  backgroundOffset = backgroundOffset + dt * backgroundMoveSpeed
  if backgroundOffset > width then
    backgroundOffset = backgroundOffset - width
  end

  floorOffset = floorOffset + dt * floorMoveSpeed
  if floorOffset > floorWidth then
    floorOffset = floorOffset - floorWidth
  end
  --building1:update(body, dt, building2)
  --building2:update(body, dt, building1)
  upperBound1:update(body, dt, upperBound2)
  upperBound2:update(body, dt, upperBound1)

  lowerBound1:update(body, dt, lowerBound2)
  lowerBound2:update(body, dt, lowerBound1)

rocketyShippy:update(body, dt)

  updateTilesetBatch()

  -- if(time < love.timer.getTime( ) - 0.25) and currentAnim == jumpAnim then --transition from jumpy to airy
  --   currentAnim = inAirAnim
  --   currentAnim:gotoFrame(1)
  -- end

  -- if (time < love.timer.getTime( ) - 0.5) and currentAnim == rollAnim then --transition from rolly to runny
  --   currentAnim = runAnim
  --   currentAnim:gotoFrame(1)
  -- end

  -- if(body:getY() < height) then
  --   if(currentAnim == runAnim) then
  --     --print("ON GROUND")
      body:applyLinearImpulse(runForce * dt, 0) --continually apply forces, higher if we are running
  --   else
  --     body:applyLinearImpulse(runForce * 0.5 * dt, 0)
  --   end
  -- else
  --   body:setLinearVelocity(0,0)
  --   gameyEndy = true
  --   text = "You ran for "..math.floor (body:getX()).." pixels!\nPressy R to restarty!"
  --   print (text)
  -- end

  -- if crate_body:getX() < body:getX() - 100 then -- if the crate move outside of the screen
  --   if crate_fixture:isDestroyed() then -- if the fixture has been destoryed
  --     crate_fixture = love.physics.newFixture(crate_body, crate_box) --creates and attaches a fixture to the body
  --     crate_fixture:setUserData("Crate") -- Set a string userdata
  --   end
  --   crate_body:setAwake(true) -- wake up, cratey!
  --   crate_body:setPosition(body:getX() + width * 2, 200) -- cratey movey

  --   -- text = text.."\n".."recreate"
  -- end
end


function love.draw() --drawey everythingey

  love.graphics.draw(background, -backgroundOffset, 0, 0, 2, 2, 0, 30) 
  love.graphics.draw(background, -backgroundOffset + width, 0, 0, 2, 2, 0, 30) 

  -- love.graphics.draw(floorImage, -floorOffset, height - 109, 0, 2, 2, 0, 0)
  -- love.graphics.draw(floorImage, -floorOffset + floorWidth, height - 109, 0, 2, 2, 0, 0)

  -- love.graphics.draw(floorImage, -floorOffset, 109 - 64, 0, 2, 2, 0, 0)
  -- love.graphics.draw(floorImage, -floorOffset + floorWidth, 109 - 64 , 0, 2, 2, 0, 0)


  love.graphics.setColor(255, 255, 255)
  love.graphics.print(text, 10, 10)
  if gameyEndy == true then
    love.graphics.draw(tilesetImage, endQuad, 105, 50)
  end
  love.graphics.translate(width/40 - body:getX(), 0) -- camerey movey
   
  -- currentAnim:draw(playerImg, body:getX(), body:getY(), body:getAngle()) --playey drawey
  love.graphics.draw(playerImg, body:getX(), body:getY(), body:getAngle(), 2, 2, 0, 0)
  --love.graphics.setColor(255, 0, 0)
  --love.graphics.polygon("line", building1.shape:getPoints())
  --love.graphics.polygon("line", building2.shape:getPoints())
 
  love.graphics.setColor(255, 255, 255) --color setty
  love.graphics.draw(tilesetBatch, 0, 0, 0, 1, 1)


  upperBound1:draw(floorImage)
  upperBound2:draw(floorImage)
  lowerBound1:draw(floorImage)
  lowerBound2:draw(floorImage)

  rocketyShippy:draw(rocketyShippyImage, rocketyShippyQuad)

  
end

function updateTilesetBatch()
  tilesetBatch:clear() --clearey batchey

  --building1:draw(tilesetBatch, tileQuads); --buildy drawey
  --uilding2:draw(tilesetBatch, tileQuads); --secondy buildy drawey

  -- tilesetBatch:add(tileQuads[0], crate_body:getX(), crate_body:getY(), crate_body:getAngle()); --tiley addey

  tilesetBatch:flush() --send new and modified sprite data to graphic card
end

function love.keypressed( key, isrepeat ) --jumpey buttoney
  if key == "up" then--and onGround then --if up key and grounded, get high
    body:applyLinearImpulse(0, jumpForce) --applyey forcey uppy
    -- currentAnim = jumpAnim --anime changey jumpey
    -- currentAnim:gotoFrame(1) --framey changey
    -- time = love.timer.getTime( ) --timey getty timey setty
  end
  if key == "r" and gameyEndy == true then
    gameyEndy = false
    love.audio.stop()
    love.load()
  end
end

-- This is called every time a collision begin.
function beginContact(bodyA, bodyB, coll) --the two bodys
  local aData=bodyA:getUserData() --gets data for first body
  local bData =bodyB:getUserData() --gets data for second body

  cx,cy = coll:getNormal() --direction of collision
 text = text.."\n"..aData.." colliding with "..bData.." with a vector normal of: "..cx..", "..cy

  print (text)

  -- if((aData == "Player" or bData == "Player") and (aData ~= "Crate" and bData ~= "Crate") and cy ~= 0) then --if player is colliding FIRST BUG SOLVED YEAYAYAYAHA

  --   onGround = true --player is grounded, his mom is very upset
  --   -- currentAnim = rollAnim --sets player animation
  --   currentAnim:gotoFrame(1) --sets back to first frame of anim
  --   time = love.timer.getTime( ) --banks time MAYBE?!?!?!?!?!
  --   runSound:play() --plays run sound

  -- end

  -- if((aData == "Player" or bData == "Player") and (aData == "Crate" or bData == "Crate")) then --if player is colliding FIRST BUG SOLVED YEAYAYAYAHA
  --   body:applyLinearImpulse(-50, 0)

  --   -- currentAnim = rollAnim -- play roll animation
  --   currentAnim:gotoFrame(1)
  --   time = love.timer.getTime( )

  --   crate_fixture:destroy() -- destory the fixture so the box can fall
  -- end

end

-- This is called every time a collision end.
function endContact(bodyA, bodyB, coll) --touchey stoppey pwease

  
  local aData=bodyA:getUserData()
  local bData=bodyB:getUserData()
  cx,cy = coll:getNormal() --direction of collision
  text = "Collision ended: " .. aData .. " and " .. bData

  -- if((aData == "Player" or bData == "Player")and (aData ~= "Crate" and bData ~= "Crate")) then
  --   runSound:stop() --stopey soundey when touchey stoppey pwease
  --   onGround = false --no longer grounded, groundey nopey, startey smokey
  -- end
end

function love.focus(f)
  if not f then
    print("LOST FOCUS")
  else
    print("GAINED FOCUS")
  end
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end