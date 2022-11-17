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

	local point = Point:new{x = 347, y = 180}
	local rect = Rectangle:new{topleft = point, width = 32, height = 50}
	self.rectangles[1] = rect

	point = Point:new{x = 0, y = 0}
	rect = Rectangle:new{topleft = point, width = self.width, height = 0}
	self.rectangles[2] = rect

	rect = Rectangle:new{topleft = point, width = 0, height = self.height}
	self.rectangles[3] = rect

	point = Point:new{x = 0, y = self.height}
	rect = Rectangle:new{topleft = point, width = self.width, height = 0}
	self.rectangles[4] = rect

	point = Point:new{x = self.width, y = 0}
	rect = Rectangle:new{topleft = point, width = 0, height = self.height}
	self.rectangles[5] = rect
end

function GamePage:draw()
	love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
	self.bg:draw(0, 0)

	for _, itm in ipairs(self.mines) do
		if not itm.exploded then
			love.graphics.draw(self.mineimg, itm.topleft.x, itm.topleft.y)
		end
	end

	love.graphics.draw(self.player.img, self.player.x, self.player.y)

	if self.lost then
		if not self.lostimg then
			self.lostimg = love.graphics.newImage("battleship/assets/lost.png")
		end
		love.graphics.draw(self.lostimg, 0, 0)
	elseif self.won then
		if not self.wonimg then
			self.wonimg = love.graphics.newImage("battleship/assets/won.png")
		end
		love.graphics.draw(self.wonimg, 0, 0)
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
	if self.won or self.lost then return end

	self.player:update(dt, self.rectangles)
end

function GamePage:keypressed(key, scancode, isrepeat)
	if not isrepeat and key == 'space' then
		local mine = self.player:dropmine(self.mineimg:getWidth(), self.mineimg:getHeight())
		if mine:anycollides(self.mines) then return end

		local loc = #self.mines + 1
		self.mines[loc] = mine
		self.host:broadcast("mine" .. mine.topleft.x .. "," .. mine.topleft.y .. "," .. loc)
	end
end

function GamePage:getactivemines()
	local active = {}
	local i = 1

	for _, itm in ipairs(self.mines) do
		if not itm.exploded then
			active[i] = itm
			i = i + 1
		end
	end
	return active
end

function GamePage:onevent(dt, event)
	if event.type == 'disconnect' then
		self.won = true
	elseif event.type == 'receive' then
		local msg = event.data:sub(1, 4)
		local data = event.data:sub(5, #event.data)

		if msg == "ping" then
			--Any new players will be told that the game has already started
			event.peer:send("started")
		elseif msg == "boom" then
			local index = tonumber(data)
			self:getactivemines()[index].exploded = true
		elseif msg == "loss" then
			self.won = true
		elseif msg == "win" then
			self.lost = true
		end
	end
end