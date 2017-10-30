--assign require files
local anim8 = require 'anim8'
require 'building'

-- Parts of the tileset used for different tiles
tileQuads = {} 

-- Time variable. Used for animations
local time = 0

-- We use these variables to make our game code easier to read
-- Our game states are defined by these numbers
local GAME_START	= 0
local GAME_PLAY		= 1
local GAME_OVER		= 2
local state = GAME_START

--	CHRIS
--	PLEASE NOTE:
	--	If a function seems to be missing parameters from
	--	its definition assume those values to be zero or null.
	--	For all method signatures only significant parameters 
	--	are included.
function love.load()
  width = 600
  height = 300

  -- Makes a window of the specified height and width and makes the window sized fixed
  love.window.setMode(width, height, {resizable=false})
  -- Sets title fo the window
  love.window.setTitle("Luabalt")

  -- One meter is 32px in physics engine
  love.physics.setMeter(15)

  -- newWorld Method
	--	Signature:	newWorld(xg, yg, sleep)
	--	Definition: Establishes the physics for our game
	--	Parameters:
	--				number		xg		: gravity's force in the horizontal direction
	--				number		yg		: gravity's force in the vertical direction
	--				bool		sleep	: whether bodies in the world are allowed to sleep (I don't know what sleep means in this context)
	--	Returns: 
	--				A world with physics

  -- Create a world with standard gravity
  world = love.physics.newWorld(0, 9.81*15, true)

  -- Sets background image 
  background = love.graphics.newImage('media/iPadMenu_atlas0.png')
  -- Make nearest neighbor, so pixels are sharp
  background:setFilter("nearest", "nearest")

  -- Get Tile Image
  tilesetImage=love.graphics.newImage('media/play1_atlas0.png')
  -- Make nearest neighbor, so pixels are sharp
  tilesetImage:setFilter("nearest", "nearest") -- this "linear filter" removes some artifacts if we were to scale the tiles
  tileSize = 16
 
  -- newQuad Method
	--	Signature:	newQuad( x, y, width, height, sw, sh )
	--	Definition: Returns the quad from an Image using user definied parameters
	--	Parameters:
	--				number		x		: top-left position in the Image along the x-axis.
	--				number		y		: top-left position in the Image along the y-axis
	--				number		width	: width of the Image in pixels
	--				number		height	: height of the Image in pixels
	--				number		sw		: reference width of the Image (in our case the game window's width)
	--				number		sh		: reference height of theImage (In our case the game window's height)
	--
	--	Returns: 
	--				Quad
  
  -- Reference quad for the crate
  tileQuads[0] = love.graphics.newQuad(0, 0, 
    18, 18,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- Left corner
  tileQuads[1] = love.graphics.newQuad(228, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- Top middle
  tileQuads[2] = love.graphics.newQuad(324, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- Right middle
  tileQuads[3] = love.graphics.newQuad(387, 68, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- Middle1
  tileQuads[4] = love.graphics.newQuad(100, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  tileQuads[5] = love.graphics.newQuad(116, 0, 
    16, 16,
    tilesetImage:getWidth(), tilesetImage:getHeight())

  -- newSpriteBatch Method
	--	Signature:	newSpriteBatch(image, maxSprites)
	--	Definition: Groups sprites together to render images on screen faster
	--	Parameters:
	--				Image		image		: the image to use for sprites
	--				number		maxSprites	: the max number a sprite batch can contain
	--
	--	Returns: 
	--				SpriteBatch
  tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, 1500)

  -- newBody Method
	--	Signature:	newBody(world, x, y, type)
	--	Definition: Creates a new body in our world at the user definied location 
	--				(This is similer to Unity's rigidbody system)
	--	Parameters:
	--				World		world		: the world our body will exist in 
	--										  (world is defined on Line 31 in our game)
	--				number		x			: the x position of our body
	--				number		y			: the y position of our body
	--				BodyType	type		: the type of body
					-- What is a Bodytype
						--	A collection of rules that define a body's interaction with the 
						--	physics of the game
						--	Bodytype types:
						--				string		"static"	: does not move
						--				string		"dynamic"	: collides with all bodies
						--				string		"kinematic"	: only collides with "dynamic" bodies
	--
	--	Returns: 
	--				Body

  -- Create a Body for the crate.
  crate_body = love.physics.newBody(world, 770, 200, "dynamic")

  -- newRectangle Method
	--	Signature:	newRectangleShape(x, y, width, height)
	--	Definition: Creates the collision shape for our body (in this case a rectangle)
	--	Parameters:
	--				number		x			: offset along x axis
	--				number		y			: offset along y axis
	--				number		width		: width of collision shape
	--				number		height		: height of collision shape
	--	Returns: 
	--				Shape
  crate_box = love.physics.newRectangleShape(9, 9, 18, 18)
  
  -- newFixture Method
	--	Signature:	newFixture(body, shape)
	--	Definition: Attaches the collision shape to the Body
	--	Parameters:
	--				Body		body		: the body to have the collision shape attached
	--				Shape		shape		: thee shape to be attached to the body
	--	
	--	Returns: 
	--				Fixture (i.e. A body with a collision shape attached)
  fixture = love.physics.newFixture(crate_body, crate_box)
  -- setUserData Method
	--	Signature:	setUserData(value)
	--	Definition: associates a lua value with the Fixture
	--	Parameters:
	--				any			value		: the value to be associated with the Fixture
	--
	--	Returns: 
	--				Nothing

  -- Now we can refer to the crate by using the string "Crate"
  fixture:setUserData("Crate")

  -- setMassData Method
	--	Signature:	setMassData(x, y, mass, inertia)
	--	Definition:	Overrides current mass info. All physics bodies have mass. 
	--				At this point in the code our crate has no mass info.
	--	Parameters:
	--				number		x			: x position for center of mass
	--				number		y			: y position for center of mass
	--				number		mass		: the mass of the object
	--				number		inertia		: rotational inertia
	--
	--	Returns: 
	--				Nothing

  -- computeMass Method
	--	Signature:	computeMass(density)
	--	Definition: figures out the mass, inertia and center of mass for a Shape
	--	Parameters:
	--				number		density		: density of the shape
	--
	--	Returns:
	--				number		x			: x position for center of mass
	--				number		y			: y position for center of mass
	--				number		mass		: the mass of the object
	--				number		inertia		: rotational inertia

  crate_body:setMassData(crate_box:computeMass( 1 ))

  text = "hello World"

  -- What Is A Building
	--	An Image with a Body, Shape, and Fixture
  -- makeBuilding Method
	--	Signature:	makeBuilding(x, y)
	--	Definition: Creates a build at the user defined position
	--	Parameters:
	--				number		x			: x position of the building
	--				number		y			: y position of the building
	--
	--	Returns:
	--				Building	
  
  -- These are the two buildings we see at the start of the game
  building1 = building:makeBuilding(750, 16)
  building2 = building:makeBuilding(1200, 16)

  -- Sets player image
  playerImg = love.graphics.newImage("media/player2.png")

  -- Create a Body for the player.
  -- "Dynamic" Bodytype collides with all bodies
  body = love.physics.newBody(world, 400, 100, "dynamic")

  -- Create a shape for the body.
  player_box = love.physics.newRectangleShape(15, 15, 30, 30)

  -- Create fixture between body and shape
  fixture = love.physics.newFixture(body, player_box)

  -- We can now refer to the player using the string "Player"
  fixture:setUserData("Player")
  
  -- Calculate the mass of the body based on attatched shapes.
  -- This gives realistic simulations.
  body:setMassData(player_box:computeMass( 1 ))

  -- setFixedRotation Method
	--	Signature:	setFixedRotation(isFixed)
	--	Definition: Tells the body if its rotation is staionary or not
	--	Parameters:
	--				bool		isFixed		: If true we do not rotate
	--
	--	Returns:
	--				Nothing

  -- The player is not allowed to rotate
  body:setFixedRotation(true)

  -- applyLinearImpulse Method
	--	Signature: applyLinearImpulse(ix, iy)
	--	Definition: applies force to the body. In this case it is a linear force
	--	Parameters:
	--				number		ix			: force applied to the center of mass in the horizontal direction
	--				number		iy			: force applied to the center of mass in the vertical direction
	--
	--	Returns:
	--				Nothing

  -- The player an init push.
  -- This is what makes the player move to the right
  body:applyLinearImpulse(1000, 0)

  -- setCallbacks Method
	--	Signature:	setCallbacks(beginContact, endContact)
	--	Definition: Sets functions for the collision callbacks during the world update.
	--				The first two arguments are the colliding fixtures.
	--	Parameters:
	--				function	beginContact : gets called when two fixtures overlap
	--				function	endContact	 : Gets called when two fixtures cease to overlap. 
	--										   This will also be called outside of a world update, 
	--										   when colliding objects are destroyed.
	--
	--	Returns:
	--				Nothing

  -- Set the collision callback.
  world:setCallbacks(beginContact,endContact)

  -- Sets font size to 12
  love.graphics.setNewFont(12)

  -- Sets background color using RGB
  love.graphics.setBackgroundColor(155,155,155)

  -- What is anim8
	-- An animation library for LÖVE

  -- newGrid Method
	--	Signature:	newGrid(frameWidth, frameHeight, imageWidth, imageHeight)
	--	Definition: Creates a grid to be applied to a spritesheet
	--	Parameters:
	--				number		frameWidth	: width of the frame
	--				number		frameHeight : height of the frame
	--				number		imageWidth	: width of the image
	--				number		imageHeight : height of the image
	--
	--	Returns:
	--				A local gird from anim8 to apply to a spritesheet

  -- We will use the grid g to define the frames of our animation
  local g = anim8.newGrid(30, 30, playerImg:getWidth(), playerImg:getHeight())

  -- newAnimation Method
	--	Signature:	newAnimation(frames, durations, onLoop)
	--	Definition: Creates a new animation
	--	Parameters:
	--				Image[]		frames		: the images to use for the animations
	--										  grid(range, row)
	--				number		durations	: duration of all frames in animation
									--	duration can be a number or table
										-- if number	:	All frames have the same value
										-- if table		:	You can specify durations for all frames individually, 
										--					like this: {0.1, 0.5, 0.1} or you can specify durations 
										--					for ranges of frames: {['3-5']=0.2}.
	--				string		onLoop		: should animation loop. Animation loops by default
						--	Types of Animation loops
							--	"loops"			- loops animation
							--	"pauseAtEnd"	- pauses the animation at the end
	--
	--	Returns:
	--			An Animation using the images specified
	
  runAnim = anim8.newAnimation(g('1-14',1), 0.05)
  jumpAnim = anim8.newAnimation(g('15-19',1), 0.1)
  inAirAnim = anim8.newAnimation(g('1-8',2), 0.1)
  rollAnim = anim8.newAnimation(g('9-19',2), 0.05)

  -- Sets current animation
  currentAnim = inAirAnim

  -- newSource Method
	--	Signature:	newSource(path, type)
	--	Definition: Establishes a source of audio
	--	Parameters:
	--				string		path		: the file path to find the audio file
	--				SourceType	type		: how the audio file is played
					-- What is a Source Type:
						--	SourceType types:
						--				"stream"	: Stream the sound; decode it gradually. 
						--							  Use for Background Music
						--				"static"	: Decode the entire sound at once.
						--							  Use for Sound effects.
	--
	--	Returns:
	--			An Audio file

  music = love.audio.newSource("media/18-machinae_supremacy-lord_krutors_dominion.mp3", "stream")
  -- Volume: 1.0 is max and 0.0 is off.
  music:setVolume(0.1)
  --love.audio.play(music)

  -- Sets the run sound effect
  runSound = love.audio.newSource("media/foot1.mp3", "static")
  --runSound:setLooping(true);


  -- Makes a shape. I don't know the reason why
  shape = love.physics.newRectangleShape(0, 00, 100, 100)

  -- We could use this shape to tell the game if the player has died
	shapeBody = love.physics.newBody(world, 0, 0, "dynamic")
	shapeBody:applyLinearImpulse(1000, 0)
	shapeFixture = love.physics.newFixture(shapeBody, shape)
	shapeFixture:setUserData("Shape")
end

function restartGame()
 -- Sets the state to GAME_PLAY for now, but in the future 
 -- This should set the state to GAME_START
 state = GAME_PLAY
 -- Calls the load function to reset our variables
 -- We could have a reload function instead of calling the load function
 love.load()
end

-- CHRIS
function love.update(dt)
 -- A simple state machine to make our game have different screens
 if(state == GAME_START) then
		startScreen(dt)
 elseif (state == GAME_PLAY) then
		gameScreen(dt)
 elseif (state == GAME_END) then
		endScreen(dt)
 end
end

function startScreen(dt)
 -- Input is handled in love.keypressed so we don't need an update function for now
end

function prepGameScreen()
  -- Sets font size to 12
  love.graphics.setNewFont(12)
  -- Resets the text field 
  text = "hello world"
  state = GAME_PLAY
end

function gameScreen(dt)
-- Updates the animation using deltaTime
	currentAnim:update(dt)
	-- Updates the world using deltaTime
	world:update(dt)

	-- Updates the building using the player's body, deltaTime and the building itself
	building1:update(body, dt, building2)
	building2:update(body, dt, building1)

	-- BUG : Game does not end when player falls off screen
			--  CATEGORY: GAME LOGIC
			--  STATUS  : PENDING REVIEW
	-- We can use this to move a death boundary to detect if the player has died
		shapeBody:setPosition(body:getX(), 500)
		newShape = love.physics.newRectangleShape(shapeBody:getX(), shapeBody:getY(), 
		                                          100, 
	                                            100)
		shape = newShape

	-- Updates which tiles to render on screen
	updateTilesetBatch()

	-- Set current animation to in air animation if 0.25 of a second has passed since we did the jump animation
	if(time < love.timer.getTime( ) - 0.25) and currentAnim == jumpAnim then
	  currentAnim = inAirAnim
	  currentAnim:gotoFrame(1)
	end

	-- Set current animation to run animation if 0.5 of a second has passed since we did the roll animation
	if (time < love.timer.getTime( ) - 0.5) and currentAnim == rollAnim then
	  currentAnim = runAnim
	  currentAnim:gotoFrame(1)
	end

	-- BUG : Game camera keeps moving when player is offscreen
			--  CATEGORY: GAME LOGIC
			--  STATUS  : PENDING REVIEW
	-- If the current animation is the run animation
		-- Apply force proportional to the amount of time passed multiplied by a factor of 250
	-- OTHERWISE (If our animation is not the running animation)
		-- Apply force proportional to the amount of time passed multiplied by a factor of 100
	if(currentAnim == runAnim) then
	  --print("ON GROUND")
	  body:applyLinearImpulse(250 * dt, 0)
	else
	  body:applyLinearImpulse(100 * dt, 0)
	end
end

function endScreen(dt)
-- Input is handled in love.keypressed so we don't need an update function for now
end

-- CHRIS
function love.draw()
 -- A simple state machine to make our game draw different screens
 if(state == GAME_START) then
		drawStartScreen()
 elseif (state == GAME_PLAY) then
		drawGameScreen()
 elseif (state == GAME_OVER) then
		drawEndScreen()
 end
end

function drawStartScreen()
 love.graphics.draw(background, 0, 0, 0, 1.56, 1.56, 0, 200)
 love.graphics.setColor(255, 255, 255)

 -- Two graphic draw calls are made to make the font render in two sizes
 -- I couldn't think of another way to do this
 love.graphics.setNewFont(76)
 text = "LUABALT".. "\n"
 love.graphics.print(text, width/5, height/3)
 love.graphics.setNewFont(32)
 text = "Press ENTER To Play"
 love.graphics.print(text, width/5, height * 2 /3)
end

function drawGameScreen()
-- draw Method
	--	Signature:	draw( drawable, x, y, r, sx, sy, ox, oy, kx, ky )
	--	Definition: Renders the image at the position and scale
	--	Parameters:
	--				Drawable		drawable	: the thing to be rendered. Image extends from Drawable
	--				number			x			: the position to draw the object (x-axis)
	--				number			y			: the position to draw the object (y-axis)
	--				number			r			: the orientation of the object
	--				number			sx			: Scale factor (x-axis)
	--				number			sy			: Scale factor (y-axis)
	--				number			ox			: Origin offset (x-axis)
	--				number			ox			: Origin offset (y-axis)
	--				number			kx			: Shearing factor (x-axis)
	--				number			ky			: Shearing factor (y-axis)
										--	What is Shearing factor
											-- The distance a point moves due to shear divided by the 
											-- perpendicular distance of a point from the invariant line.
											--What is shear
												-- A transformation in which all points along a given line L 
												-- remain fixed while other points are shifted parallel to L 
												-- by a distance proportional to their perpendicular distance 
												-- from L
	--
	--	Returns: Nothing

  -- Draws the background
  love.graphics.draw(background, 0, 0, 0, 1.56, 1.56, 0, 200)

  -- Sets color of all graphics to White
  love.graphics.setColor(255, 255, 255)

  -- Prints text on the game window with a user defined offset
  love.graphics.print(text, 10, 10)

  -- This keeps the player in the middle of the screen
  love.graphics.translate(width/2 - body:getX(), 0)
   
  -- Draws the current animation
  currentAnim:draw(playerImg, body:getX(), body:getY(), body:getAngle())

  -- Sets color of all graphics to Red
  love.graphics.setColor(255, 0, 0)
  -- Draws the collision rectangle of building1
  --love.graphics.polygon("line", building1.shape:getPoints())
  -- Draws teh collision rectangle of building2
  --love.graphics.polygon("line", building2.shape:getPoints())
  love.graphics.polygon("line", shape:getPoints())
  -- Sets color of all graphics to White (again)
  love.graphics.setColor(255, 255, 255)

  -- draws all tiles in the tilesetBatch
  love.graphics.draw(tilesetBatch, 0, 0, 0, 1, 1)
end

function drawEndScreen()
 love.graphics.draw(background, 0, 0, 0, 1.56, 1.56, 0, 200)
 love.graphics.setColor(255, 255, 255)

 -- Two graphic draw calls are made to make the font render in two sizes
 -- I couldn't think of another way to do this
 love.graphics.setNewFont(76)
 text = "GAME OVER".. "\n"
 love.graphics.print(text, width/10, height/3)
 love.graphics.setNewFont(32)
 text = "Press BACKSPACE To Try Again"
 love.graphics.print(text, width/10, height * 2 /3)
end

--Chao
--This function is called when we need to render tiles on screen
function updateTilesetBatch()
  --clear all the tiles in the tilesetbatch
  tilesetBatch:clear()
  --add tilequads into tilesetbatch, with paramters of tilequad type, crate_body x, y, position and it's angle.
  --Potential Bug: it's only add one type of tilequads
  tilesetBatch:add(tileQuads[0], crate_body:getX(), crate_body:getY(), crate_body:getAngle());
  -- call building.draw function in the building script, draw two of them
  building1:draw(tilesetBatch, tileQuads);
  building2:draw(tilesetBatch, tileQuads);
  --save tilesetBatch
  tilesetBatch:flush()
end

--This funcion is called when there is a key input
--Potential bug: isrepeat is not using in this function, which made the player could keep jumping and never fall.
function love.keypressed( key, isrepeat )
  --If up key was pressed and the character is on the ground, then do these:
  if key == "up" and onGround then
    -- apply a linear impulse to up direction on the character
    body:applyLinearImpulse(0, -500)
    -- set the current animation to jump anim
    currentAnim = jumpAnim
    --play jumpanim
    currentAnim:gotoFrame(1)
    -- get the time when we start to do the jump animation
    time = love.timer.getTime( )
  end

  -- Press tab to return to the main menu from the GAME_PLAY screen and GAME_OVER screen
  if (key == "tab" and state ~= GAME_START) then
   state = GAME_START
  end

  -- Press Enter to start the game if we are at the main menu
  if(key == "return" and state == GAME_START) then
   prepGameScreen()
  end

  -- Press q to restart Game Screen
  if(key == "q") then
   restartGame()
  end

  -- Restart the game if backspace is pressed and is game over or if player presses q
  if (key == "backspace" and state == GAME_OVER) then
	state = GAME_START
  end
end

-- This is called every time a collision begin.
function beginContact(bodyA, bodyB, coll)
  --Get the userdata from these two body, which we will print out later
  local aData=bodyA:getUserData()
  local bData =bodyB:getUserData()
  -- get the collider position, x and y
  cx,cy = coll:getNormal()
  --save the information we got from aData and bData, and also the position where collision happened
  text = text.."\n"..aData.." colliding with "..bData.." with a vector normal of: "..cx..", "..cy
  --print out the information we just saved
  print (text)

  if((aData == "Player" and bData == "Shape") or(aData == "Shape" and bData == "Player")) then
	state = GAME_OVER
  end

  -- if one of the body is player, then do these:
  if(aData == "Player" or bData == "Player") then
    --Yes, player is on ground
    onGround = true
    --set the current animation to roll anim
    currentAnim = rollAnim
    --play rollanim
    currentAnim:gotoFrame(1)
    --get the time we start to do the roll anim
    time = love.timer.getTime( )
    --Yes, I am running, so play the run sound
    runSound:play()

  end
end

-- This is called every time a collision end.
--David's code
--Gets called when two fixtures cease to overlap.
--takes the initial body, the second body, and the collider
function endContact(bodyA, bodyB, coll)
--when contact ends, that means we are either falling or jumping, so we're no longer on the ground 
  onGround = false

  --these two local variables store the names of the objects overlapping
  --or maybe it's the "fixture" of the object because they are using the same strings as the fixture
  --as of right now, this is pretty much always the player and the building
  --"text" is the means by which we can log to the console.
  local aData=bodyA:getUserData()
  local bData=bodyB:getUserData()
  text = "Collision ended: " .. aData .. " and " .. bData

  --if contact ends between the player and something, then that means the player is not grounded
  --as such, the running sound, as declared in load, stops.
  if(aData == "Player" or bData == "Player") then
    runSound:stop();
  end
end

--David's code
--focus is a callback function that is triggered when the window loses "focus"
--focus in this case is whether the window is clicked on
--so if you click to another window, the game loses "focus"
--just in general, we might want to say that if the window is NOT in focus, pause the game
function love.focus(f)
  if not f then
    print("LOST FOCUS")
  else
    print("GAINED FOCUS")
  end
end

--David's code
--callback function triggered when game is closed
function love.quit()
  print("Thanks for playing! Come back soon!")
end