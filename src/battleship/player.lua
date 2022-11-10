require "battleship/point"

Player = { x = 0, y = 0 }
Player.__index = Player

function Player:new(o)
	o = o or {}
	setmetatable(o, Player)

	o.xdir = 'none'
	o.ydir = 'none'

	return o
end

function Player:setsprite(path)
	self.img = love.graphics.newImage(path)
	self.width = self.img:getWidth()
	self.height = self.img:getHeight()
end

function Player:update(dt, rectangles)
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

function Player:collides(x, y, rectangles)
	local left = x
	local right = x + self.width
	local top = y
	local bottom = y + self.height

	for i, rect in ipairs(rectangles) do
		local xcollision = rect.left < right and left < rect.right
		local ycollision = rect.top < bottom and top < rect.bottom

		if xcollision and ycollision then
			return true
		end
	end
	return false
end