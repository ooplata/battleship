require "battleship/animation"
require "battleship/player"
enet = require "enet"

GamePage = { frame = nil }

local host = nil
function GamePage.sethost(param)
	host = param
end

function GamePage:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	self.host = host

	self.width = love.graphics.getWidth()
	self.height = love.graphics.getHeight()

	self.bg = Animation:new()
	self.bg:setsource("battleship/assets/bg.png", 8, 2)

	self.player = Player:new(self.width / 2, self.height - 96)
	self.player.speed = 200

	self.player:setbounds(self.width, self.height)
	self.player:setsprite("battleship/assets/player.png")

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

	if love.keyboard.isDown('space') then
		--nuke = player:dropnuke()
		--event.peer:send(nuke.x, nuke.y)
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