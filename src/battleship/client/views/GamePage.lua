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

	self.player = Player:new()
	self.player:setsprite("battleship/assets/ship.png")

	self.host = host
	self.server = server

	self.width = love.graphics.getWidth()
	self.height = love.graphics.getHeight()

	return o
end

function GamePage:draw()
	love.graphics.setColor(love.math.colorFromBytes(45, 162, 255))
	love.graphics.rectangle('fill', 0, 0, self.width, self.height)

	player = self.player
	love.graphics.setColor(love.math.colorFromBytes(255, 255, 255))
	love.graphics.draw(player.img, (self.width / 2) - (player.width / 2), (self.height / 2) - (player.height / 2), 0, 1, 1, 0, player.height)
end

function GamePage:update(dt)
	local event = self.host:service()
	if event then
		if event.type == 'connect' then
			--Start game
		elseif event.type == 'receive' then
			--Handle server input
		end
	end

	player = self.player
	if love.keyboard.isDown('right') then
		if player.x < (self.width - player.width) then
			player.x = player.x + (player.speed * dt)
		else
			player.x = self.width - player.width
		end
	elseif love.keyboard.isDown('left') then
		if player.x > 0 then 
			player.x = player.x - (player.speed * dt)
		else
			player.x = 0
		end
	end

	if love.keyboard.isDown('up') then
		if player.y > player.height then
			player.y = player.y - (player.speed * dt)
		else
			player.y = player.height
		end
	elseif love.keyboard.isDown('down') then
		if player.y < self.height then 
			player.y = player.y + (player.speed * dt)
		else
			player.y = self.height
		end
	end
end