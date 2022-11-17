require "battleship/point"
require "battleship/rectangle"

Entity = { x = 0, y = 0 }
Entity.__index = Entity

function Entity:new(o)
	o = o or {}
	setmetatable(o, Entity)

	o.xdir = 'none'
	o.ydir = 'none'

	return o
end

function Entity:setsprite(path)
	self.img = love.graphics.newImage(path)
	self.width = self.img:getWidth()
	self.height = self.img:getHeight()
end

function Entity:move(dt, rectangles)
	local nx = self.x
	local ny = self.y

	if love.keyboard.isDown('right') then
		self.xdir = 'right'
		nx = self.x + (self.speed * dt)
	elseif love.keyboard.isDown('left') then
		self.xdir = 'left'
		nx = self.x - (self.speed * dt)
	else
		self.xdir = 'none'
	end

	if love.keyboard.isDown('up') then
		self.ydir = 'up'
		ny = self.y - (self.speed * dt)
	elseif love.keyboard.isDown('down') then
		self.ydir = 'down'
		ny = self.y + (self.speed * dt)
	else
		self.ydir = 'none'
	end

	if not self:collides(nx, self.y, rectangles) then
		self.x = nx
	end

	if not self:collides(self.x, ny, rectangles) then
		self.y = ny
	end
end

function Entity:collides(x, y, rectangles)
	return not (self:collidingindex(x, y, rectangles) == 0)
end

function Entity:collidingindex(x, y, rectangles)
	local tl = Point:new{x = x, y = y}
	local hitbox = Rectangle:new{topleft = tl, width = self.width, height = self.height}

	return hitbox:collidingindex(rectangles)
end