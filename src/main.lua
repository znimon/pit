local STI = require("sti")
require("player")

function love.load()
	Map = STI("map/1.lua", {"box2d"})
	World = love.physics.newWorld(0,0)
	World:setCallbacks(beginContact, endContact)
	Map:box2d_init(World)
	Map.layers.solid.visible = false
	background = love.graphics.newImage("assets/background.png")
	Player:load()
end

function love.update(dt)
	World:update(dt)
	Player:update(dt)
	love.keyboard.resetKeyStates()
end

function love.keypressed(k, scancode, isRepeat)
	print(k, scancode, isRepeat)
end

function love.draw()
	love.graphics.draw(background)
	Map:draw(0, 0, 2, 2)
	love.graphics.push()
	love.graphics.scale(2,2)
	Player:draw()
	love.graphics.pop()
end

function beginContact(a, b, collision)
	Player:beginContact(a, b, collision)
end

function endContact(a, b, collision)
	Player:endContact(a, b, collision)
end
