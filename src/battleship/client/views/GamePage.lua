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

	o.bg = Animation:new()
	o.bg:setsource("battleship/assets/bg.png", 8, 2)

	o.player = Entity:new{x = 0, y = o.height - 96}
	o.player.speed = 200

	o.player:setsprite("battleship/assets/ship.png")

	return o
end

function GamePage:addrectangles()
	self.rectangles = {}

	local point = Point:new{x = 347, y = 220}
	local rect = Rectangle:new{topleft = point, width = 32, height = 50}
	self.rectangles[1] = rect

	local point2 = Point:new{x = 0, y = 0}
	local rect2 = Rectangle:new{topleft = point2, width = 640, height = 50}
	self.rectangles[2] = rect2
end

function GamePage:draw()
	love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
	self.bg:draw(0, 0)

	player = self.player
	love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, player.height)
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

function GamePage:onevent(dt, event)
	if event.type == 'connect' then
		--Start game
	elseif event.type == 'receive' then
		--Handle server input
	end
end