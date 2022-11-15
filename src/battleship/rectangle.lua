require "battleship/point"

Rectangle = { topleft = nil, width = 0, height = 0 }
Rectangle.__index = Rectangle

function Rectangle:new(o)
	o = o or {}
	setmetatable(o, Rectangle)

	o.top = o.topleft.y
	o.bottom = o.top + o.height
	o.left = o.topleft.x
	o.right = o.left + o.width

	o.topright = Point:new{x=o.right, y=o.top}
	o.bottomleft = Point:new{x=o.left, y=o.bottom}
	o.bottomright = Point:new{x=o.right, y=o.bottom}

	return o
end

function Rectangle:contains(point)
	if point.x <= self.right and point.x >= self.left then
		if point.y <= self.bottom and point.y >= self.top then
			return true
		end
	end
	return false
end

function Rectangle:collides(rectangle)
	local xcollision = rectangle.left < self.right and self.left < rectangle.right
	local ycollision = rectangle.top < self.bottom and self.top < rectangle.bottom

	return xcollision and ycollision
end

function Rectangle:anycollides(rectangles)
	return not (self:collidingindex(rectangles) == 0)
end

function Rectangle:collidingindex(rectangles)
	for i, rect in ipairs(rectangles) do
		if rect:collides(self) then
			return i
		end
	end
	return 0
end