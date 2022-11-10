Point = { x = 0, y = 0 }

function Point:new(x, y)
	o = {}
	setmetatable(o, self)
	self.__index = self

	self.x = x
	self.y = y

	return o
end