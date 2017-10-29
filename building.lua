building = { 
  tileSize = 16,

  screen_height,

  x = 0,
  y = 0,
  width = 0,
  height = 0,
  body,
  shape
} -- the table representing the class, which will double as the metatable for the instances

building.__index = building -- failed table lookups on the instances should fallback to the class table, to get methods

--David's Code
function building:makeBuilding(x, y, tileSize)

--when we want to make a building, the first thing we have to do is set the "metaTable" for that building
--the metatable "is an ordinary Lua table that defines the behavior of the original value under certain special operations"
--it "controls how an object behaves in arithmetic operations, order comparisons, concatenation, length operation, and indexing."
--in this case, the building class has a table ({}), which is used to make ALL buildings
-- so before we can make the building, we want to set the metatable of the building instance being created
-- essentially, this allows us to make buildings of various shapes and sizes in different locations
  local self = setmetatable({}, building)

  --with the metatable set, we call the "setupBuilding" method
  --this takes the x position of the building, the y position, and the tileSize
  self:setupBuilding(x, y, tileSize)

  return self
end

--so y is always set in the function itself, and never taken as a parameter
--I assume this is because we want uniform Y positions
function building:setupBuilding(x, tileSize)

--set tileSize in the metatable
--set x in the metatable
--set y in the metatable
  self.tileSize = tileSize
  self.x = x
  self.y = 300

  --set width and height, body, and shape, but with some new fun math
  --math.ceil (x): Returns the smallest integer larger than or equal to x.
  -- so we set a random height and width
  self.width  = math.ceil((love.math.random( ) * 10) + 20)
  self.height = math.ceil(5 + love.math.random( ) * 7)
  --self.height = 7 (I'm guessing the original code had uniform heights?)

  --Body, as we saw in Chris' comments, is like the rigidBody and allows physics forces interact with it
  --we pass it the world, x & y coordinates of 0, and set it to static so that it DOES NOT MOVE
  self.body = love.physics.newBody(world, 0, 0, "static")

  --attaches a collider to the body using all the variable set before this
  self.shape = love.physics.newRectangleShape(self.x, self.y, 
                                              self.tileSize * self.width, 
                                              self.tileSize * self.height)
  
  --associates a Lua value with a fixture
  fixture = love.physics.newFixture(self.body, self.shape)

  --now we can refer to the building by using the string "Building"
  fixture:setUserData("Building")
end

--this is the update function that runs on buildings that were made
--it takes a body, a timescale, and another building
--in this case, all buildings are being propogated by the first two buildings
--each time a building gets made, it sets up a new building using the SECOND building built
--this in turn calls all the necessary functions until we get to that second building building more buildings and so on.
function building:update(body, dt, other_building)

--it builds buildings based on the position of the player
--this is some math: if the player is more than halfway across the building, make a new building?
  if self.x + self.width/2 * self.tileSize < body:getX() then
      self:setupBuilding(
          other_building.x + other_building.width  * self.tileSize + 150, 
          16)
  end
end
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
function building:draw(tilesetBatch, tileQuads)
--these are the x and y of the building being drawn, grabbed from the metatable
  x1, y1 = self.shape:getPoints()

  --the collection of quads that make up the crates (I think, since when this is being called, the tileBatch are the crates)
  --pretty sure this sets crates on the building depending on how big the building is
  --so if the building meets none of the conditions for adding a crate, don't add a crate
  tilesetBatch:add(tileQuads[0], self.x, self.y, 0)
  for x=self.width - 1, 0, -1 do 
    for y=0,self.height - 1, 1 do
      if x == 0 and y == 0 then
        tilesetBatch:add(tileQuads[1], x1 + x * tileSize, y1 + y * tileSize, 0)
      else
        if y == 0 and x == self.width - 1 then
          tilesetBatch:add(tileQuads[3], x1 + x * tileSize, y1 + y * tileSize, 0)
        else 
          if y == 0 then
            tilesetBatch:add(tileQuads[2], x1 + x * tileSize, y1 + y * tileSize, 0)
          else 
            num = math.floor(x + y + x1 + y1)
            if (num)%5 == 0 then
              --tilesetBatch:add(tileQuads[5], x1 + x * tileSize, y1 + y * tileSize, 0)
            else
              tilesetBatch:add(tileQuads[4], x1 + x * tileSize, y1 + y * tileSize, 0)
            end
          end
        end
      end
    end
  end
end
