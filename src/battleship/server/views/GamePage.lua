require "battleship/animation"
require "battleship/point"
require "battleship/rectangle"
require "battleship/server/reticle"

enet = require "enet"

GamePage = { frame = nil }
GamePage.__index = GamePage

local host = nil
function GamePage.sethost(param)
	host = param
end

function GamePage:new(o)
	o = o or {}
	setmetatable(o, GamePage)

	o.host = host

	o.width = love.graphics.getWidth()
	o.height = love.graphics.getHeight()

	o:addrectangles()

	o.mines = {}
	o.mineimg = love.graphics.newImage("battleship/assets/mine.png")

	o.bg = Animation:new()
	o.bg:setsource("battleship/assets/bg.png", 8, 2, 0)

	o.player = Reticle:new{x = o.width / 2, y = o.height - 96}
	o.player:setsprite("battleship/assets/player.png")
	o.player.speed = 200

	return o
end

function GamePage:addrectangles()
	self.rectangles = {}

	local point = Point:new{x = 347, y = 220}
	local rect = Rectangle:new{topleft = point, width = 32, height = 50}
	self.rectangles[1] = rect

	point = Point:new{x = 0, y = 0}
	rect = Rectangle:new{topleft = point, width = 640, height = 36}
	self.rectangles[2] = rect

	rect = Rectangle:new{topleft = point, width = 0, height = 480}
	self.rectangles[3] = rect

	point = Point:new{x = 0, y = 516}
	rect = Rectangle:new{topleft = point, width = 640, height = 0}
	self.rectangles[4] = rect

	point = Point:new{x = 640, y = 0}
	rect = Rectangle:new{topleft = point, width = 36, height = 480}
	self.rectangles[5] = rect
end

function GamePage:draw()
	love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
	self.bg:draw(0, 0)

	player = self.player
	love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, player.height)

	for _, itm in ipairs(self.mines) do
		if itm then
			love.graphics.draw(self.mineimg, itm.topleft.x, itm.topleft.y, 0, 1, 1, 0, itm.height)
		end
	end
end

function GamePage:update(dt)
	if self.host then
		local event = self.host:service()
		if event then
			self:onevent(dt, event)
		end
	end

	self.bg:update(dt)
	self.player:update(dt, self.rectangles)
end

function GamePage:keypressed(key, scancode, isrepeat)
	if not isrepeat and key == 'space' then
		local mine = self.player:dropmine(self.mineimg:getWidth(), self.mineimg:getHeight())
		if mine:anycollides(self.mines) then return end

		local loc = 1
		for _, itm in ipairs(self.mines) do
			if itm == nil then
				break
			end
			loc = loc + 1
		end

		self.mines[loc] = mine
	end
end

function GamePage:onevent(dt, event)
	if event.type == 'connect' then
		--Start game
	elseif event.type == 'receive' then
		if event.data == "ping" then
			--Any new players will be told that the game has already started
			event.peer:send("started")
		end
	end
end