-- # Welcome to Corona!

local screenWidth = display.contentWidth
local screenHeight = display.contentHeight

local storyboard = require("storyboard")
local down_the_rabbit_hole = storyboard.newScene("skater")


-- Pre-load the soundtrack.
media.playSound("powersupply.mp3")


function down_the_rabbit_hole:createScene(event)

	local sceneView = self.view

	-- Let's have a nice background
	local background = display.newRect(0, 0, screenWidth, screenHeight)
	background:setFillColor(32, 48, 48)
	sceneView:insert(background)

	local blue_door = display.newRect(100, 200, 100, 200)
	blue_door:setFillColor(0, 0, 196)
	sceneView:insert(blue_door)

	local red_door = display.newRect(400, 30, 100, 200)
	red_door:setFillColor(196, 0, 0)
	sceneView:insert(red_door)

	local skater = display.newImageRect("skater.png", 200, 200)
	skater.x = 100
	skater.y =  screenHeight - 100
	sceneView:insert(skater)

	local message = display.newText("Take the red door",
		screenWidth - 250, screenHeight - 200,
		200, 500, system.nativeFont, 48)
	sceneView:insert(message)

	function skater:on_red_door()
		local minX, maxX, minY, maxY, fuzz
		fuzz = 50
		minX = red_door.x - red_door.width + fuzz
		maxX = red_door.x + red_door.width - fuzz
		minY = red_door.y - red_door.height + fuzz
		maxY = red_door.y + red_door.height - fuzz
		return skater.x >= minX and skater.x <= maxX and skater.y >= minY and skater.y <= maxY
	end

	function skater:on_blue_door()
		local minX, maxX, minY, maxY, fuzz
		fuzz = 20
		minX = blue_door.x - blue_door.width + fuzz
		maxX = blue_door.x + blue_door.width - fuzz
		minY = blue_door.y - blue_door.height + fuzz
		maxY = blue_door.y + blue_door.height - fuzz

		return skater.x >= minX and skater.x <= maxX and skater.y >= minY and skater.y <= maxY
	end


	function skater.moveitmoveit(event)
		if event.phase == "began" then
			skater.on_a_move = true
		elseif event.phase == "moved" and skater.on_a_move then
			if event.x <= screenWidth and event.x >= 0 then
				skater.x = event.x 
			end
			if event.y <= screenHeight and event.y >= 0 then
				skater.y = event.y
			end
		else
			skater.on_a_move = false
		end

		if skater:on_red_door() then
			skater.x = 100
			skater.y =  screenHeight - 100
			skater.on_a_move = false
			storyboard.gotoScene("bugs")
		end

		if skater:on_blue_door() then
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

	skater:addEventListener("touch", skater.moveitmoveit)
end
down_the_rabbit_hole:addEventListener("createScene")

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
				bug.squished = true
				bug:setFillColor(255, 0, 0)
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

