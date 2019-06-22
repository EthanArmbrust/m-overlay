love.filesystem.setRequirePath("?.lua;?/init.lua;modules/?.lua;modules/?/init.lua")

require("util.love2d")

local watcher = require("memory.watcher")
local perspective = require("perspective")

local graphics = love.graphics
local newImage = graphics.newImage

function love.load()
	love.window.setTitle("M'Overlay - Waiting for Dolphin.exe")
	watcher.init()
	graphics.setBackgroundColor(0, 0, 0, 0) -- Transparent background for OBS
end

local BUTTONS = {
	DPAD_LEFT = 0x0001,
	DPAD_RIGHT = 0x0002,
	DPAD_DOWN = 0x0004,
	DPAD_UP = 0x0008,
	Z = 0x0010,
	R = 0x0020,
	L = 0x0040,
	A = 0x0100,
	B = 0x0200,
	X = 0x0400,
	Y = 0x0800,
	START = 0x1000,
}

function love.update(dt)
	watcher.update("Dolphin.exe") -- Look for Dolphin.exe
end

local BUTTON_TEXTURES = {
	DPAD = {
		GATE = newImage("textures/buttons/d-pad-gate.png"),
		POSITION = {
			x = 100,
			y = 128,
		},
	},

	DPAD_LEFT = {
		PRESSED = newImage("textures/buttons/d-pad-pressed-left.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	DPAD_RIGHT = {
		PRESSED = newImage("textures/buttons/d-pad-pressed-right.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	DPAD_UP = {
		PRESSED = newImage("textures/buttons/d-pad-pressed-up.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	DPAD_DOWN = {
		PRESSED = newImage("textures/buttons/d-pad-pressed-down.png"),

		POSITION = {
			x = 108,
			y = 144,
		},
	},

	JOYSTICK = {
		GATE = newImage("textures/buttons/joystick-gate.png"),
		MASK = newImage("textures/buttons/joystick-mask.png"),
		STICK = newImage("textures/buttons/joystick-outline.png"),
	},
	CSTICK = {
		GATE = newImage("textures/buttons/c-stick-gate.png"),
		STICK = newImage("textures/buttons/c-stick.png"),
	},
	A = {
		OUTLINE = newImage("textures/buttons/a-outline.png"),
		PRESSED = newImage("textures/buttons/a-pressed.png"),
		COLOR = {0, 225, 150, 255},
		POSITION = {
			x = 12 + 64 + 256,
			y = 64
		}
	},
	B = {
		OUTLINE = newImage("textures/buttons/b-outline.png"),
		PRESSED = newImage("textures/buttons/b-pressed.png"),
		COLOR = {230, 0, 0, 255},
		POSITION = {
			x = 16 + 256,
			y = 108
		}
	},
	X = {
		OUTLINE = newImage("textures/buttons/x-outline.png"),
		PRESSED = newImage("textures/buttons/x-pressed.png"),
		COLOR = {255, 255, 255, 255},
		POSITION = {
			x = 138 + 256,
			y = 48
		}
	},
	Y = {
		OUTLINE = newImage("textures/buttons/y-outline.png"),
		PRESSED = newImage("textures/buttons/y-pressed.png"),
		COLOR = {255, 255, 255, 255},
		POSITION = {
			x = 60 + 256,
			y = 0
		}
	},
	Z = {
		OUTLINE = newImage("textures/buttons/z-outline.png"),
		PRESSED = newImage("textures/buttons/z-pressed.png"),
		COLOR = {165, 75, 165, 255},
		POSITION = {
			x = 128 + 256,
			y = -16
		}
	},
	START = {
		OUTLINE = newImage("textures/buttons/start-outline.png"),
		PRESSED = newImage("textures/buttons/start-pressed.png"),
		COLOR = {255, 255, 255, 255},
		POSITION = {
			x = 256,
			y = 42
		}
	}
}

local MAX_PORTS = 4
local PORT = 0

function love.gameLoaded()
	love.window.setTitle(string.format("M'Overlay - Port %d", PORT + 1))
end

function love.wheelmoved(x, y)
	if not watcher.isReady() then return end

	if y > 0 then
		PORT = PORT - 1
	elseif y < 0 then
		PORT = PORT + 1
	end
	PORT = PORT % MAX_PORTS
	love.gameLoaded()
end

local vertices = {
	{
		0, 0,
		0, 0,
		1, 1, 1,
	},
	{
		128, 0,
		1, 0,
		1, 1, 1
	},
	{
		128, 128,
		1, 1,
		1, 1, 1
	},
	{
		0, 128,
		0, 1,
		1, 1, 1
	},
}

local rotated_vertices = {}

local function transformVertices(vertices, x, y, angle, ox, oy)
	if #vertices ~= #rotated_vertices then
		rotated_vertices = {}
	end

	local c = math.cos(angle)
	local s = math.sin(angle)

	for i=1, #vertices do
		-- Create or use vertex cache
		rotated_vertices[i] = rotated_vertices[i] or {}

		-- Copy and rotate X and Y vertex points
		rotated_vertices[i][1] = x + (vertices[i][1] - ox) * c - (vertices[i][2] - oy) * s
		rotated_vertices[i][2] = y + (vertices[i][1] - ox) * s + (vertices[i][2] - oy) * c

		-- Copy other vertex settings
		rotated_vertices[i][3] = vertices[i][3]
		rotated_vertices[i][4] = vertices[i][4]
		rotated_vertices[i][5] = vertices[i][5]
		rotated_vertices[i][6] = vertices[i][6]
	end

	return rotated_vertices
end

function love.draw()
	local player = watcher.player[PORT + 1].entity

	--local controller = watcher.controller[PORT + 1]

	local controller = player.controller

	if controller then -- and controller.plugged ~= 0xFF then
		-- Draw Joystick

		local x, y = controller.joystick.x, 1 - controller.joystick.y

		local angle = math.atan2(controller.joystick.x, controller.joystick.y)
		local mag = math.sqrt(controller.joystick.x ^ 2 + controller.joystick.y ^ 2)

		local far = mag * 15
		local near = mag * 20

		-- Make the rectangle look like its fading into the horizon
		vertices[1][1] = far		-- x
		vertices[1][2] = near		-- y
		vertices[2][1] = 128 - far	-- x
		vertices[2][2] = near		-- y

		local rotated = transformVertices(vertices, 64 + 22 + (40 * x), 64 + 12 + (40 * y), angle, 64, 64)

		graphics.setColor(255, 255, 255, 255)

		graphics.stencil(function()
			perspective.on()
			perspective.quad(BUTTON_TEXTURES.JOYSTICK.MASK, rotated[1], rotated[2], rotated[3], rotated[4])
			perspective.off()
		end, "replace", 1)
		graphics.setStencilTest("equal", 0) -- Mask out the gate behind the joystick
			graphics.easyDraw(BUTTON_TEXTURES.JOYSTICK.GATE, 22, 52, 0, 128, 128)
		graphics.setStencilTest()

		perspective.on()
		perspective.quad(BUTTON_TEXTURES.JOYSTICK.STICK, rotated[1], rotated[2], rotated[3], rotated[4])
		perspective.off()

		-- Draw C-Stick

		local x, y = controller.cstick.x, 1 - controller.cstick.y

		local angle = math.atan2(controller.cstick.x, controller.cstick.y)
		local mag = math.sqrt(controller.cstick.x ^ 2 + controller.cstick.y ^ 2)

		local far = mag * 12
		local near = mag * 16

		-- Make the rectangle look like its fading into the horizon
		vertices[1][1] = far		-- x
		vertices[1][2] = near		-- y
		vertices[2][1] = 128 - far	-- x
		vertices[2][2] = near		-- y

		local rotated = transformVertices(vertices, 64 + 48 + 128 + (32 * x), 64 + 20 + (32 * y), angle, 64, 64)

		graphics.setColor(255, 235, 0, 255)
		graphics.easyDraw(BUTTON_TEXTURES.CSTICK.GATE, 48 + 128, 52, 0, 128, 128)

		perspective.on()
		perspective.quad(BUTTON_TEXTURES.CSTICK.STICK, rotated[1], rotated[2], rotated[3], rotated[4])
		perspective.off()

		graphics.setColor(255, 255, 255, 255)

		-- Draw L

		graphics.setLineStyle("smooth")
		love.graphics.setLineWidth(3)

		graphics.stencil(function()
			-- Create a rounded rectangle mask
			graphics.rectangle("fill", 24 + 14, 16, 100, 12, 6, 6)
		end, "replace", 1)
		graphics.setStencilTest("greater", 0) -- Only draw within our rounded rectangle mask
			-- L Analog
			graphics.rectangle("fill", 24 + 14, 16, 88 * controller.analog.float, 12)

	 		-- L Button
			if bit.band(controller.buttons.pressed, BUTTONS.L) == BUTTONS.L then
				graphics.rectangle("fill", 24 + 14 + 88, 16, 12, 12)
			end
		graphics.setStencilTest()

		-- Draw outline
		graphics.rectangle("line", 24 + 14, 16, 100, 12, 6, 6)
		-- Draw segment for button press
		graphics.line(24 + 14 + 88, 16, 24 + 14 + 88, 16 + 12)

		-- Draw R

		graphics.stencil(function()
			-- Create a rounded rectangle mask
			graphics.rectangle("fill", 48 + 128 + 14, 16, 100, 12, 6, 6)
		end, "replace", 1)
		graphics.setStencilTest("greater", 0) -- Only draw within our rounded rectangle mask
			-- R Analog
			graphics.rectangle("fill", 48 + 128 + 14 + 12 + (88 * (1 - controller.analog.float)), 16, 88 * controller.analog.float, 12)

			-- R Button
			if bit.band(controller.buttons.pressed, BUTTONS.R) == BUTTONS.R then
				graphics.rectangle("fill", 48 + 128 + 14, 16, 12, 12)
			end
		graphics.setStencilTest()

		-- Draw outline
		graphics.rectangle("line", 48 + 128 + 14, 16, 100, 12, 6, 6)
		-- Draw segment for button press
		graphics.line(48 + 128 + 14 + 12, 16, 48 + 128 + 14 + 12, 16 + 12)

		-- Draw buttons

		graphics.easyDraw(BUTTON_TEXTURES.DPAD.GATE, 108, 144, 0, 128, 128)

		for button, flag in pairs(BUTTONS) do
			local texture = BUTTON_TEXTURES[button]
			if texture then
				local pos = texture.POSITION
				graphics.setColor(texture.COLOR)
				if texture.PRESSED and bit.band(controller.buttons.pressed, flag) == flag then -- Check if the button is pressed
					graphics.easyDraw(texture.PRESSED, pos.x, pos.y, 0, 128, 128)
				elseif texture.OUTLINE then
					graphics.easyDraw(texture.OUTLINE, pos.x, pos.y, 0, 128, 128)
				end
			end
		end
	end
end

local FPS_LIMIT = 60

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0
 
	-- Main loop time.
	return function()
		local frame_start = love.timer.getTime()

		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end
 
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
 
			if love.draw then love.draw() end
 
			love.graphics.present()
		end
 
		if love.timer then
			local frame_time = love.timer.getTime() - frame_start
			love.timer.sleep(1 / FPS_LIMIT- frame_time)
		end
	end
end

function love.quit()
end
local utf8 = require("utf8")
 
local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
	msg = tostring(msg)
 
	error_printer(msg, 2)
 
	if not love.window or not love.graphics or not love.event then
		return
	end
 
	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end
 
	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
 
	love.graphics.reset()
	local font = love.graphics.setNewFont(14)
 
	love.graphics.setColor(255, 255, 255, 255)
 
	local trace = debug.traceback()
 
	love.graphics.origin()
 
	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)
 
	local err = {}
 
	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)
 
	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end
 
	table.insert(err, "\n")
 
	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end
 
	local p = table.concat(err, "\n")
 
	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")
 
	local function draw()
		local pos = 8
		love.graphics.clear(89/255, 157/255, 220/255)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end
 
	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
		draw()
	end
 
	if love.system and love.keyboard then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end
 
	return function()
		love.event.pump()
 
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end
 
		draw()
 
		if love.timer then
			love.timer.sleep(0.1)
		end
	end
 
end