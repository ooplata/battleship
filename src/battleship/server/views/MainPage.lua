require "battleship/ui/frame"
require "battleship/server/views/GamePage"

enet = require "enet"

MainPage = { frame = nil }

local nums = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' }

function MainPage:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	self.host = nil

	self.msg = ""
	self.port = ""

	return o
end

function MainPage:draw()
	love.graphics.print("")
	love.graphics.print("	Welcome to Battleship!", 0, 24)
	love.graphics.print("	Type out a port to get started: " .. self.port, 0, 48)

	love.graphics.print("	" .. self.msg, 0, 72)
end

function MainPage:keypressed(key, scancode, isrepeat)
	if not isrepeat then
		if self.host == nil then
			if key == 'return' then
				self.host = enet.host_create("*:" .. self.port)

				self.msg = "Waiting for players..."
			elseif key == 'backspace' then
				self.port = self.port:sub(1, -2)
				self.msg = ""
			elseif self.port:len() == 4 then
				self.msg = "A port is 4 characters at most."
			elseif contains(nums, key) then
				self.port = self.port .. key
				self.msg = ""
			else
				self.msg = "A port is composed of numbers only."
			end
		end
	end
end

function MainPage:update(dt)
	if self.host then
		local event = self.host:service()
		if event then
			if event.type == 'connect' then
				self.msg = "A player joined the lobby! Starting game soon."
			elseif event.type == 'receive' then
				if event.data == "ping" then
					event.peer:send("pong")
					self.host:flush()

					self.frame:navigate(GamePage)
				end
			end
		end
	end
end

function contains(table, val)
	for i = 1, #table do
		if table[i] == val then 
			return true
		end
	end
	return false
end