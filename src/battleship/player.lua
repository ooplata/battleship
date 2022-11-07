Player = {}

function Player:new(src)
	o = {}
	setmetatable(o, self)
	self.__index = self

	self.x = love.graphics.getWidth() / 2
	self.y = love.graphics.getHeight() - 96

	self.speed = 200
	self.setsprite(src)

	return o
end

function Player:setsprite(path)
	self.img = love.graphics.newImage(path)
	self.width = self.img:getWidth()
	self.height = self.img:getHeight()
end