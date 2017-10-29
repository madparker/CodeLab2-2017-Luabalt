local anim8 = require 'anim8' --local is like private?
require 'building' --require is like using

tileQuads = {} -- array? parts of the tileset used for different tiles

local time = 0 

function love.load() --loads the game
  width = 600 --size of window
  height = 300

  love.window.setMode(width, height, {resizable=false}) --sets display to width and height, makes static size
  love.window.setTitle("Luabalt") --sets window title

  -- One meter is 32px in physics engine
  love.physics.setMeter(15)
  -- Create a world with standard gravity
  world = love.physics.newWorld(0, 9.81*15, true)

  background=love.graphics.newImage('media/iPadMenu_atlas0.png')
  --Make nearest neighbor, so pixels are sharp
  background:setFilter("nearest", "nearest") --for image scaling, compression format

  --Get Tile Image
  tilesetImage=love.graphics.newImage('media/play1_atlas0.png')
  --Make nearest neighbor, so pixels are sharp
  tilesetImage:setFilter("nearest", "nearest") -- this "linear filter" removes some artifacts if we were to scale the tiles
  tileSize = 16 --declares the size of the tile
 
  -- crate
  tileQuads[0] = love.graphics.newQuad(0, 0,  --this is grabbing the graphics from the sprite sheet
    16, 16,
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

  tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, 1500) --creates a new sprite batch! max number of sprites the batch can contain

  -- Create a Body for the crate.
  crate_body = love.physics.newBody(world, 770, 200, "dynamic") --where to create body, coords, and body type
  crate_box = love.physics.newRectangleShape(8, 8, 16, 16) --x, y, width, height
  fixture = love.physics.newFixture(crate_body, crate_box) --creates and attaches a fixture to the body
  fixture:setUserData("Crate") -- Set a string userdata
  crate_body:setMassData(crate_box:computeMass( 1 )) --sets mass

  text = "hello World" --hi

  building1 = building:makeBuilding(750, 16) --
  building2 = building:makeBuilding(1200, 16) --

  playerImg = love.graphics.newImage("media/player2.png") --sets player img, getting spritey for playey
  -- Create a Body for the player.
  body = love.physics.newBody(world, 400, 100, "dynamic") --sets physics for player
  -- Create a shape for the body.
  player_box = love.physics.newRectangleShape(15, 15, 30, 30) --playey boxey
  -- Create fixture between body and shape
  fixture = love.physics.newFixture(body, player_box)
  fixture:setUserData("Player") -- Set a string userdata
  
  -- Calculate the mass of the body based on attached shapes.
  -- This gives realistic simulations.
  body:setMassData(player_box:computeMass( 1 )) --playey massey
  body:setFixedRotation(true) --player won't rotate, rotatey nopey
  --the player an init push.
  body:applyLinearImpulse(1000, 0) -- applies force, shovey playey

  -- Set the collision callback.
  world:setCallbacks(beginContact,endContact) 

  love.graphics.setNewFont(12) --fontey settey
  love.graphics.setBackgroundColor(155,155,155) --rgb color

  local g = anim8.newGrid(30, 30, playerImg:getWidth(), playerImg:getHeight()) --ANIMATION SETTY
  runAnim = anim8.newAnimation(g('1-14',1), 0.05)
  jumpAnim = anim8.newAnimation(g('15-19',1), 0.1)
  inAirAnim = anim8.newAnimation(g('1-8',2), 0.1)
  rollAnim = anim8.newAnimation(g('9-19',2), 0.05)

  currentAnim = inAirAnim --starts with this jumpy anime

  music = love.audio.newSource("media/18-machinae_supremacy-lord_krutors_dominion.mp3", "stream") --boppy setty
  music:setVolume(0.1) --loudy setty
  love.audio.play(music) --boppy playey

  runSound = love.audio.newSource("media/foot1.mp3", "static") --runny soundy
  runSound:setLooping(true); --runny loopy


  --shape = love.physics.newRectangleShape(450, 500, 100, 100) --??????? HERPY DERPY
end

function love.update(dt) --delta time

  currentAnim:update(dt)
  world:update(dt)

  building1:update(body, dt, building2)
  building2:update(body, dt, building1)

  updateTilesetBatch()

  if(time < love.timer.getTime( ) - 0.25) and currentAnim == jumpAnim then --transition from jumpy to airy
    currentAnim = inAirAnim
    currentAnim:gotoFrame(1)
  end

  if (time < love.timer.getTime( ) - 0.5) and currentAnim == rollAnim then --transition from rolly to runny
    currentAnim = runAnim
    currentAnim:gotoFrame(1)
  end

  if(currentAnim == runAnim) then
    --print("ON GROUND")
    body:applyLinearImpulse(250 * dt, 0) --continually apply forces, higher if we are running
  else
    body:applyLinearImpulse(100 * dt, 0)
  end
end

function love.draw() --drawey everythingey
  love.graphics.draw(background, 0, 0, 0, 1.56, 1.56, 0, 200) 
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(text, 10, 10)

  love.graphics.translate(width/40 - body:getX(), 0) -- camey movey
   
  currentAnim:draw(playerImg, body:getX(), body:getY(), body:getAngle()) --playey drawey

  --love.graphics.setColor(255, 0, 0)
  --love.graphics.polygon("line", building1.shape:getPoints())
  --love.graphics.polygon("line", building2.shape:getPoints())
 
  love.graphics.setColor(255, 255, 255) --color setty
  love.graphics.draw(tilesetBatch, 0, 0, 0, 1, 1)
end

function updateTilesetBatch()
  tilesetBatch:clear() --clearey batchey

  tilesetBatch:add(tileQuads[0], crate_body:getX(), crate_body:getY(), crate_body:getAngle()); --tiley addey

  building1:draw(tilesetBatch, tileQuads); --buildy drawey
  building2:draw(tilesetBatch, tileQuads); --secondy buildy drawey

  tilesetBatch:flush() --send new and modified sprite data to graphic card
end

function love.keypressed( key, isrepeat ) --jumpey buttoney
  if key == "up" and onGround then --if up key and grounded, get high
    body:applyLinearImpulse(0, -500) --applyey forcey uppy
    currentAnim = jumpAnim --anime changey jumpey
    currentAnim:gotoFrame(1) --framey changey
    time = love.timer.getTime( ) --timey getty timey setty
  end
  if key == "r" then
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

  if((aData == "Player" or bData == "Player") and cy ~= 0) then --if player is colliding FIRST BUG SOLVED YEAYAYAYAHA

    onGround = true --player is grounded, his mom is very upset
    currentAnim = rollAnim --sets player animation
    currentAnim:gotoFrame(1) --sets back to first frame of anim
    time = love.timer.getTime( ) --banks time MAYBE?!?!?!?!?!
    runSound:play() --plays run sound

  end
end

-- This is called every time a collision end.
function endContact(bodyA, bodyB, coll) --touchey stoppey pwease

  onGround = false --no longer grounded, groundey nopey, startey smokey
  local aData=bodyA:getUserData()
  local bData=bodyB:getUserData()
  cx,cy = coll:getNormal() --direction of collision
  text = "Collision ended: " .. aData .. " and " .. bData

  if((aData == "Player" or bData == "Player")) then
    runSound:stop(); --stopey soundey when touchey stoppey pwease
  end
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