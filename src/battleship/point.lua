Point = { x = 0, y = 0 }
Point.__index = Point

function Point:new(o)
	o = o or {}
	setmetatable(o, Point)
	return o
end