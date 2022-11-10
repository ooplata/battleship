Frame = { content = nil }
Frame.__index = Frame

function Frame:new(o)
	o = o or {}
	setmetatable(o, Frame)
	return o
end

function Frame:navigate(page)
	self.content = page:new{frame = self}
end