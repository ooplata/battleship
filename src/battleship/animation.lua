Animation = {}

function Animation:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Animation:draw(x, y)
	love.graphics.draw(self.img, self:getquad(), x, y, 0, 1, 1)
end

function Animation:getquad()
	return self.quads[(math.floor(self.timer) % self.frames) + 1]
end

function Animation:update(dt)
	self.timer = self.timer + dt * self.speed
end

function Animation:setsource(path, frames, speed)
	self.img = love.graphics.newImage(path)
	self.timer = 0

	self.frames = frames
	self.speed = speed
	self.quads = {}

	local w = self.img:getWidth()
	local h = self.img:getHeight()

	local width = w / frames
	for i = 0, frames - 1 do
		local quad = love.graphics.newQuad(i * width, 0, width, h, self.img)
		table.insert(self.quads, quad)
	end
end