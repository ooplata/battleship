require "battleship/point"
require "battleship/ui/frame"
require "battleship/views/MainPage"

local frame

function love.load()
	love.window.setMode(640, 480)
	love.window.setTitle("Bomberfrog")
	love.window.setIcon(love.image.newImageData("battleship/assets/logo.png"))

	frame = Frame:new()
	frame:navigate(MainPage)
end

function love.update(dt)
	if frame.content.update then
		frame.content:update(dt)
	end
end

function love.draw()
	if frame.content.draw then
		frame.content:draw()
	end
end

function love.keypressed(key, scancode, isrepeat)
	if frame.content.keypressed then
		frame.content:keypressed(key, scancode, isrepeat)
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if frame.content.mousepressed then
		local point = Point:new{x = x, y = y}
		frame.content:mousepressed(point, button, istouch, presses)
	end
end