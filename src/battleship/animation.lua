Animation = {}
Animation.__index = Animation

function Animation:new(o)
	o = o or {}
	setmetatable(o, Animation)
	return o
end

function Animation:draw(x, y)
	love.graphics.draw(self.img, self:getquad(), x, y)
end

function Animation:getquad()
	return self.quads[(math.floor(self.timer) % self.frames) + 1]
end

function Animation:update(dt)
	if self.permanent or self.timer < self.maxtimer then
		self.timer = self.timer + dt * self.speed
	else
		self.finished = true
	end
end

function Animation:setsource(path, frames, speed, loops)
	self.timer = 0
	self.quads = {}

	self.frames = frames
	self.speed = speed

	self.maxtimer = frames * loops
	self.permanent = loops == 0
	self.finished = false

	self.img = love.graphics.newImage(path)
	local w = self.img:getWidth()

	self.width = w / frames
	self.height = self.img:getHeight()

	for i = 0, frames - 1 do
		local quad = love.graphics.newQuad(i * self.width, 0, self.width, self.height, self.img)
		table.insert(self.quads, quad)
	end
end