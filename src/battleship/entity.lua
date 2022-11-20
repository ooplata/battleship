require "battleship/animation"
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

function Entity:setanimation(animation, revertonfinished)
	self.animation = animation
	self.revertonfinished = revertonfinished

	self.width = animation.width
	self.height = animation.height

	animation:restart()
end

function Entity:stopanimation()
	self.revertonfinished = true
	self.animation:stop()
end

function Entity:setsprite(path)
	self.img = love.graphics.newImage(path)
	self.width = self.img:getWidth()
	self.height = self.img:getHeight()
end

function Entity:draw()
	if self.animation then
		if not self.animation.finished or not self.revertonfinished then
			self.animation:draw(self.x, self.y)
			return
		end
	end

	love.graphics.draw(self.img, self.x, self.y)
end

function Entity:update(dt)
	if self.animation then
		self.animation:update(dt)
		if self.animation.finished and self.animation.revertonfinished then
			self.width = self.img:getWidth()
			self.width = self.img:getHeight()
		end
	end
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
	if not self.xhitoffset then
		self.xhitoffset = 0
	end
	if not self.yhitoffset then
		self.yhitoffset = 0
	end

	if not self.hbwidth then
		self.hbwidth = self.width
	end
	if not self.hbheight then
		self.hbheight = self.height
	end

	local tl = Point:new{x = x + self.xhitoffset, y = y + self.yhitoffset}
	local hitbox = Rectangle:new{topleft = tl, width = self.hbwidth, height = self.hbheight}

	return hitbox:collidingindex(rectangles)
end