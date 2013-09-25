-- # Welcome to Corona!

local screenWidth = display.contentWidth
local screenHeight = display.contentHeight

-- Corona has a Storyboard library that we can use to load different levels of
-- our games at different times.
local storyboard = require("storyboard")


-- Pre-load the soundtrack. We're using three tracks from Anamanaguchi's Power
-- Supply EP.
media.playSound("powersupply.mp3")

-- ## Down the Rabbit Hole

-- In this first scene we'll guide a Skater around the Blue door and into the
-- Red door. If the skater passes through the blue door, they'll go back to the
-- starting position, if they pass through the red door. We'll advance to the
-- next level.

-- We name the scene "skater" because they are the main character of the scene
-- so it's easy to remember. We could just as easily name the scene "down the
-- rabbit hole" or "level1"
local down_the_rabbit_hole = storyboard.newScene("skater")

-- This function will be called whenever the scene is first created.
function down_the_rabbit_hole:createScene(event)

	-- Sometimes saving even a few keystrokes is worth it. This lets us call the
	-- view just `view` instead of `self.view.
  local view = self.view

  -- Let's have a nice background
  local background = display.newRect(0, 0, screenWidth, screenHeight)
  background:setFillColor(32, 48, 48)
  view:insert(background)

	-- The two doors are just different image files that we load. After they're
	-- created, set the width and height accordingly.
  local blue_door = display.newImageRect("blue_door.png", 200, 200)
  blue_door.x, blue_door.y = 100, 300
  view:insert(blue_door)
  local red_door = display.newImageRect("red_door.png", 200, 200)
  red_door.x, red_door.y = 500, 170
  view:insert(red_door)

	-- Our skater is the "player character" of this particular scene. We'll
	-- control them by dragging them around with our finger.
  local skater = display.newImageRect("skater.png", 200, 200)
  skater.x = 100
  skater.y =  screenHeight - 100
  view:insert(skater)

	-- Some games are hard because you don't know what to do. Our game isn't meant
	-- to be hard. It's just meant to get you excited.
  local message = display.newText("Take the red door",
    screenWidth - 250, screenHeight - 200,
    200, 500, system.nativeFont, 48)
  view:insert(message)

	-- We want to know if our skater comes close to either door. To do this,
	-- we write some methods. Methods are like functions where the first parameter
	-- is always the table our method belongs to.
  function skater:on_red_door()
		-- When I have a lot of variables, I like to announce them all at once at
		-- the beginning instead of one by one. Old habits die hard.
    local minX, maxX, minY, maxY, fuzz
		-- Fuzz is just how accurate we want to make all of these calculations. I
		-- just picked an arbitrary number that felt good.
    fuzz = 50
		-- The minimum *x* value our skater can have to be considered on top of the
		-- door. It's calculated from the door's position and size with a bit of
		-- fuzz.
    minX = red_door.x - red_door.width / 2 + fuzz
		-- The maximum *x* value and *y* values are calculated in a similar way.
    maxX = red_door.x + red_door.width / 2 - fuzz
    minY = red_door.y - red_door.height / 2 + fuzz
    maxY = red_door.y + red_door.height / 2 - fuzz

		-- If our skater is within the range of values we calculated, we determine
		-- that they are "on the door".
    return skater.x >= minX and skater.x <= maxX and skater.y >= minY and skater.y <= maxY
  end

	-- We create a function for the blue door just like the red one. Do you see a
	-- general `on_door` method that we could write which takes the door as a
	-- parameter?
  function skater:on_blue_door()
    local minX, maxX, minY, maxY, fuzz
    fuzz = 20
    minX = blue_door.x - blue_door.width / 2 + fuzz
    maxX = blue_door.x + blue_door.width / 2 - fuzz
    minY = blue_door.y - blue_door.height / 2 + fuzz
    maxY = blue_door.y + blue_door.height / 2 - fuzz

    return skater.x >= minX and skater.x <= maxX and skater.y >= minY and skater.y <= maxY
  end


	-- It's perfectly okay to give your functions silly names... as long as what
	-- the function does is clear. In this case, the function controls the
	-- movement of our skater as we drag them about.
  function skater.moveitmoveit(event)
		-- The start of a move event. We just touched the skater.
    if event.phase == "began" then
			-- We'll keep track of whether or not we can still move them.
      skater.on_a_move = true
		-- If this isn't the start of a touch, we must be dragging the skater some
		-- where.
    elseif event.phase == "moved" and skater.on_a_move then
			-- As long as we're not trying to drag them off the screen, we move the
			-- skater to wherever we're currently touching.
      if event.x <= screenWidth and event.x >= 0 then
        skater.x = event.x 
      end
      if event.y <= screenHeight and event.y >= 0 then
        skater.y = event.y
      end
		-- If we didn't start touching the skater, and we're not dragging them
		-- around, we must have lifted up our finger. Time to stop!
    else
      skater.on_a_move = false
    end

		-- As we're moving the skater, we want to check if they're on either door.

		-- If they're on the red door, that means we take them to the next level.
		-- First we reset the skater in case we ever come back

		-- If they're on the red door, that means we take them to the next level.
		-- First we reset the skater in case we ever come back to this level later.
    if skater:on_red_door() then
      skater.x = 100
      skater.y =  screenHeight - 100
      skater.on_a_move = false
			-- Onward to crush bugs!
      storyboard.gotoScene("bugs")
    end

		-- Why oh why did you take the blue door?
    if skater:on_blue_door() then
			-- It's fine, just try again!
      skater.x = 100
      skater.y =  screenHeight - 100
      skater.on_a_move = false
      local old_text = message.text
      local old_size = message.size
      message.text = "Have confidence. Take the red door."
      message.size = 32
      message:setTextColor(128, 255, 0)
      timer.performWithDelay(1000, function()
        message.text = old_text
        message.size = old_size
        message:setTextColor(255, 255, 255)
      end)
    end
  end

	-- Now that we've defined a function to run every time we touch the skater,
	-- we have to tell Corona to run it every time we touch the skater. Functions
	-- like this are called "event listeners" or "event handlers".
  skater:addEventListener("touch", skater.moveitmoveit)
end
-- Lastly, that whole createScene function we defined is an event handler for
-- first loading this level.
down_the_rabbit_hole:addEventListener("createScene")

-- ## Bug crushing
local ready_to_crush_bugs = storyboard.newScene("bugs")
function ready_to_crush_bugs:createScene(event)
  local view = self.view

  local background = display.newRect(0, 0, screenWidth, screenHeight)
  background:setFillColor(212, 212, 212)
  view:insert(background)

  local bugs = {}
  local squished_bugs = 0

  for i = 1, 10 do
    local bug = display.newImageRect("beetle.png", 150, 150)
    view:insert(bug)
    bug.x = 200
    bug.y = 100
    bug.deltaX = math.random(-50, 50)
    bug.deltaY = math.random(-50, 50)
    function bug.squish(event)
      if event.phase == "began" and not bug.squished then
        bug.isVisible = false
        bug.squished = display.newImageRect("squished.png", 150, 150)
                view:insert(bug.squished)
                bug.squished.x = bug.x
                bug.squished.y = bug.y
        squished_bugs = squished_bugs + 1
      end
    end
    bug:addEventListener("touch", bug.squish)
    bugs[i] = bug
  end
  local message = display.newText("You'll have to squish bugs!",
  50, 300, screenWidth, screenHeight, system.nativeFont, 72)
  message:setTextColor(0, 0, 0)
  view:insert(message)

  local function are_all_squished()
    if squished_bugs == 10 then
      for i = 1, 10 do
        bugs[i].squished = nil
        bugs[i]:setFillColor(255, 255, 255)
      end
      squished_bugs = 0
      storyboard.gotoScene("finish")
    end
  end

  local function run_bugs_run(event)
    for i = 1, 10 do
      if not bugs[i].squished then

        bugs[i].x = bugs[i].x + bugs[i].deltaX
        bugs[i].y = bugs[i].y + bugs[i].deltaY
        if bugs[i].x < 0 or bugs[i].x > screenWidth then
          bugs[i].deltaX = bugs[i].deltaX * -1
        end
        if bugs[i].y < 0 or bugs[i].y > screenHeight then
          bugs[i].deltaY = bugs[i].deltaY * -1
        end

      end
      are_all_squished()
    end
  end
  Runtime:addEventListener("enterFrame", run_bugs_run)

  ready_to_crush_bugs:addEventListener("exitScene", function()
    Runtime:removeEventListener("enterFrame", run_bugs_run)
  end)
end
ready_to_crush_bugs:addEventListener("createScene")

local alright_lets_go = storyboard.newScene("finish")
function alright_lets_go:createScene(event)
  local background = display.newRect(0, 0, screenWidth, screenHeight)
  background:setFillColor(255, 255, 255)
  local text = display.newText("Alright, let's go! You are lookin' good.",
    100, 100, screenWidth - 200, screenHeight - 200, native.systemFont, 56)
  text:setReferencePoint(display.TopLeftReferencePoint)
  text:setTextColor(0, 0, 0)

  timer.performWithDelay(720, function(event)
    local red = math.random(0, 255)
    local green = math.random(0, 255)
    local blue = math.random(0, 255)
    if red + green + blue < 255 then
      text:setTextColor(255, 255, 255)
    else
      text:setTextColor(0, 0, 0)
    end
    if math.random(0, 1) == 0 then
      text.x = 100
      text.y = 700
    else
      text.x = 100
      text.y = 100
    end
    background:setFillColor(red, green, blue)
  end, 0)
end
alright_lets_go:addEventListener("createScene")


storyboard.gotoScene("skater")

