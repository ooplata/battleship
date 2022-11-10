require "battleship/animation"
require "battleship/player"
enet = require "enet"

GamePage = { frame = nil }

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
	setmetatable(o, self)
	self.__index = self

	self.bg = Animation:new()
	self.bg:setsource("battleship/assets/bg.png", 8, 2)

	self.width = love.graphics.getWidth()
	self.height = love.graphics.getHeight()

	self.player = Player:new(0, self.height - 96)
	self.player.speed = 200

	self.player:setbounds(self.width, self.height)
	self.player:setsprite("battleship/assets/ship.png")

	self.host = host
	self.server = server

	return o
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
	self.player:update(dt)
end

function GamePage:onevent(dt, event)
	if event.type == 'connect' then
		--Start game
	elseif event.type == 'receive' then
		--Handle server input
	end
end