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

	self.player = Player:new()
	self.player:setsprite("battleship/assets/player.png")

	self.host = host

	return o
end

function GamePage:draw()
	love.graphics.setColor(love.math.colorFromBytes(45, 162, 255))
	love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	player = self.player
	love.graphics.draw(player.img, player.x, player.y, 0, 1, 1, 0, player.height)
end

function GamePage:update(dt)
	local event = self.host:service()
	if event then
		if event.type == 'connect' then
			--Start game
		elseif event.type == 'receive' then
			if event.data == "ping" then
				--Any new players will be told that the game has already started
				event.peer:send("started")
			end
		end
	end

	player = self.player
	if love.keyboard.isDown('right') then
		if player.x < (love.graphics.getWidth() - player.width) then
			player.x = player.x + (player.speed * dt)
		else
			player.x = love.graphics.getWidth() - player.width
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
		if player.y < love.graphics.getHeight() then 
			player.y = player.y + (player.speed * dt)
		else
			player.y = love.graphics.getHeight()
		end
	end

	if love.keyboard.isDown('space') then
		--nuke = player:dropnuke()
		--event.peer:send(nuke.x, nuke.y)
	end
end