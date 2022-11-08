require "battleship/ui/frame"
require "battleship/server/views/MainPage"

local frame

function love.load()
	love.window.setMode(640, 480)
	love.window.setTitle("Battleship")
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