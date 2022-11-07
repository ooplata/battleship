Frame = { content = nil }

function Frame:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function Frame:navigate(page)
	self.content = page:new{frame = self}
end