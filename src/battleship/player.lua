require "battleship/point"

Player = {}

function Player:new(x, y)
	o = {}
	setmetatable(o, self)
	self.__index = self

	self.x = x
	self.y = y

	return o
end

function Player:setbounds(width, height)
	self.bounds = Point:new(width, height)
end

function Player:setsprite(path)
	self.img = love.graphics.newImage(path)
	self.width = self.img:getWidth()
	self.height = self.img:getHeight()
end

function Player:update(dt)
	local box = self.bounds
	if love.keyboard.isDown('right') then
		if self.x < (box.x - self.width) then
			self.x = self.x + (self.speed * dt)
		else
			self.x = box.x - self.width
		end
	elseif love.keyboard.isDown('left') then
		if self.x > 0 then 
			self.x = self.x - (self.speed * dt)
		else
			self.x = 0
		end
	end

	if love.keyboard.isDown('up') then
		if self.y > self.height then
			self.y = self.y - (self.speed * dt)
		else
			self.y = self.height
		end
	elseif love.keyboard.isDown('down') then
		if self.y < box.y then 
			self.y = self.y + (self.speed * dt)
		else
			self.y = box.y
		end
	end
end