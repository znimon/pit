local STI = require("lib/sti")
require("player")
require("cameracontroller")
-- require("input")

function love.load()
	-- Camera
	Camera = require("lib/hump/camera")
	cam = Camera()
	-- STI Map
	Map = STI("assets/map/1.lua", {"box2d"})
	World = love.physics.newWorld(0, 0)
	World:setCallbacks(beginContact, endContact)
	Map:box2d_init(World)
	Map.layers.solid.visible = false
	-- background = love.graphics.newImage("assets/images/background.png")
	Player:load()
	CameraController:load()
end

function love.update(dt)
	World:update(dt)
	Player:update(dt)
	CameraController:update(dt)
	love.keyboard.resetKeyStates()
end

function love.keypressed(k, scancode, isRepeat)
	-- print(k, scancode, isRepeat)
end

function love.draw()
	-- love.graphics.draw(background)
	cam:attach()
		love.graphics.scale(2, 2)
		Map:drawLayer(Map.layers["ground"])
		Player:draw()
	cam:detach()
end

function beginContact(a, b, collision)
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end
