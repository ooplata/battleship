require "battleship/animation"
require "battleship/entity"
require "battleship/point"
require "battleship/rectangle"

enet = require "enet"

GamePage = { frame = nil }
GamePage.__index = GamePage

local host = nil
local server = nil

function GamePage.sethost(param)
	host = param
end

function GamePage.setserver(param)
	server = param
end

function GamePage:new(o)
	o = o or {}
	setmetatable(o, GamePage)

	o.host = host
	o.server = server

	o.width = love.graphics.getWidth()
	o.height = love.graphics.getHeight()

	o:addrectangles()

	o.mines = {}
	o.activemines = {}
	o.mineimg = love.graphics.newImage("battleship/assets/mine.png")

	o.bg = Animation:new()
	o.bg:setsource("battleship/assets/bg.png", 8, 2, 0)

	o.player = Entity:new{x = 0, y = o.height - 96}
	o.player:setsprite("battleship/assets/ship.png")
	o.player.speed = 100

	o.player.hearts = { true, true, true }
	o.heartimg = love.graphics.newImage("battleship/assets/point-filled.png")
	o.emptyheartimg = love.graphics.newImage("battleship/assets/point.png")

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

	for _, itm in ipairs(self.activemines) do
		love.graphics.draw(self.mineimg, itm.topleft.x, itm.topleft.y)
	end

	love.graphics.draw(self.player.img, self.player.x, self.player.y)

	local x = 88
	for _, heart in ipairs(self.player.hearts) do
		if heart then
			love.graphics.draw(self.heartimg, x, 16)
		else
			love.graphics.draw(self.emptyheartimg, x, 16)
		end
		x = x - 24
	end

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

	self.player:move(dt, self.rectangles)

	local index = self.player:collidingindex(self.player.x, self.player.y, self.activemines)
	if index > 0 then
		self:onminecollision(self.activemines[index], index)
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

function GamePage:onminecollision(mine, index)
	for i, heart in ipairs(self.player.hearts) do
		if heart then
			self.player.hearts[i] = false
			if i == #self.player.hearts then
				self.lost = true
				self.server:send("loss" .. index)
			end

			break
		end
	end

	mine.exploded = true
	self.activemines = self:getactivemines()

	self.server:send("boom" .. index)
end

function GamePage:onevent(dt, event)
	if event.type == 'disconnect' then
		self.won = true
	elseif event.type == 'receive' then
		local msg = event.data:sub(1, 4)
		local data = event.data:sub(5, #event.data)

		if msg == "mine" then
			local location = split(data, ",")
			local x = tonumber(location[1])
			local y = tonumber(location[2])

			local point = Point:new{x = x, y = y}
			local mine = Rectangle:new{topleft = point, width = self.mineimg:getWidth(), height = self.mineimg:getHeight()}

			local loc = tonumber(location[3])
			self.mines[loc] = mine
			self.activemines = self:getactivemines()
		end
	end
end

function split(input, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	i = 1
	for str in string.gmatch(input, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end