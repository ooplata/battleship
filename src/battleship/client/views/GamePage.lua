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

	o.bg = love.graphics.newImage("battleship/assets/bg.png")

	o.player = Entity:new{x = o.width / 2, y = o.height - 96}
	o.player:setsprite("battleship/assets/ship.png")

	o.player.xhitoffset = 3
	o.player.yhitoffset = 11
	o.player.hbwidth = 38
	o.player.hbheight = 22

	o.player.speed = 100

	o.player.hearts = { true, true, true }
	o.heartimg = love.graphics.newImage("battleship/assets/point-filled.png")
	o.emptyheartimg = love.graphics.newImage("battleship/assets/point.png")

	o.hitanimation = Animation:new()
	o.hitanimation:setsource("battleship/assets/ship-damaged.png", 4, 2, 1)

	return o
end

function GamePage:addrectangles()
	self.rectangles = {}

	--Outer bounds
	local point = Point:new{x = 0, y = 0}
	local rect = Rectangle:new{topleft = point, width = 24, height = self.height}
	self.rectangles[1] = rect

	rect = Rectangle:new{topleft = point, width = self.width, height = 25}
	self.rectangles[2] = rect

	point = Point:new{x = 0, y = 468}
	rect = Rectangle:new{topleft = point, width = self.width, height = 12}
	self.rectangles[3] = rect

	point = Point:new{x = 625, y = 0}
	rect = Rectangle:new{topleft = point, width = 15, height = self.height}
	self.rectangles[4] = rect

	--Top left excess
	point = Point:new{x = 24, y = 25}
	rect = Rectangle:new{topleft = point, width = 121, height = 35}
	self.rectangles[5] = rect

	point = Point:new{x = 24, y = 60}
	rect = Rectangle:new{topleft = point, width = 76, height = 38}
	self.rectangles[6] = rect

	point = Point:new{x = 24, y = 98}
	rect = Rectangle:new{topleft = point, width = 29, height = 28}
	self.rectangles[7] = rect

	--Bottom left excess
	point = Point:new{x = 24, y = 359}
	rect = Rectangle:new{topleft = point, width = 6, height = 16}
	self.rectangles[8] = rect

	point = Point:new{x = 24, y = 375}
	rect = Rectangle:new{topleft = point, width = 40, height = 41}
	self.rectangles[9] = rect

	point = Point:new{x = 24, y = 416}
	rect = Rectangle:new{topleft = point, width = 83, height = 20}
	self.rectangles[10] = rect

	point = Point:new{x = 24, y = 436}
	rect = Rectangle:new{topleft = point, width = 108, height = 32}
	self.rectangles[11] = rect

	--Top right excess
	point = Point:new{x = 526, y = 25}
	rect = Rectangle:new{topleft = point, width = 99, height = 23}
	self.rectangles[12] = rect

	point = Point:new{x = 551, y = 48}
	rect = Rectangle:new{topleft = point, width = 74, height = 16}
	self.rectangles[13] = rect

	point = Point:new{x = 571, y = 64}
	rect = Rectangle:new{topleft = point, width = 54, height = 10}
	self.rectangles[14] = rect

	point = Point:new{x = 589, y = 74}
	rect = Rectangle:new{topleft = point, width = 36, height = 21}
	self.rectangles[15] = rect

	--Bottom right excess
	point = Point:new{x = 603, y = 413}
	rect = Rectangle:new{topleft = point, width = 22, height = 30}
	self.rectangles[16] = rect

	point = Point:new{x = 575, y = 443}
	rect = Rectangle:new{topleft = point, width = 50, height = 16}
	self.rectangles[17] = rect

	point = Point:new{x = 512, y = 459}
	rect = Rectangle:new{topleft = point, width = 113, height = 9}
	self.rectangles[18] = rect

	--Islands
	point = Point:new{x = 298, y = 218}
	rect = Rectangle:new{topleft = point, width = 27, height = 26}
	self.rectangles[19] = rect

	point = Point:new{x = 141, y = 272}
	rect = Rectangle:new{topleft = point, width = 11, height = 19}
	self.rectangles[20] = rect

	point = Point:new{x = 40, y = 205}
	rect = Rectangle:new{topleft = point, width = 11, height = 12}
	self.rectangles[21] = rect

	point = Point:new{x = 125, y = 182}
	rect = Rectangle:new{topleft = point, width = 44, height = 51}
	self.rectangles[22] = rect

	point = Point:new{x = 232, y = 362}
	rect = Rectangle:new{topleft = point, width = 21, height = 24}
	self.rectangles[23] = rect

	point = Point:new{x = 231, y = 75}
	rect = Rectangle:new{topleft = point, width = 13, height = 13}
	self.rectangles[24] = rect

	point = Point:new{x = 449, y = 331}
	rect = Rectangle:new{topleft = point, width = 43, height = 50}
	self.rectangles[25] = rect

	point = Point:new{x = 357, y = 84}
	rect = Rectangle:new{topleft = point, width = 80, height = 84}
	self.rectangles[26] = rect

	point = Point:new{x = 404, y = 262}
	rect = Rectangle:new{topleft = point, width = 15, height = 11}
	self.rectangles[27] = rect

	point = Point:new{x = 554, y = 208}
	rect = Rectangle:new{topleft = point, width = 15, height = 12}
	self.rectangles[28] = rect
end

function GamePage:draw()
	love.graphics.draw(self.bg, 0, 0)

	for _, itm in ipairs(self.activemines) do
		love.graphics.draw(self.mineimg, itm.topleft.x, itm.topleft.y)
	end

	self.player:draw()

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

	self.player:update(dt)

	if self.won or self.lost then return end
	if self.player.animation and self.player.animation.finished then
		self.player.speed = 100
	end

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
	self.player:setanimation(self.hitanimation, true)
	self.player.speed = 0
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