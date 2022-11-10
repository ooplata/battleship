require "battleship/ui/frame"
require "battleship/client/views/GamePage"

MainPage = { frame = nil }

local nums = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.', '-' }

function MainPage:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self

	self.host = nil
	self.server = nil

	self.msg = ""
	self.ip = ""

	return o
end

function MainPage:draw()
	love.graphics.print("")
	love.graphics.print("	Welcome to Battleship!", 0, 24)
	love.graphics.print("	Type out an IP address followed by a port (IP-port) to get started: " .. self.ip, 0, 48)

	love.graphics.print("	" .. self.msg, 0, 72)
end

function MainPage:keypressed(key, scancode, isrepeat)
	if not isrepeat then
		if self.host == nil then
			if key == 'return' then
				self.host = enet.host_create()
				self.server = self.host:connect(self.ip:gsub("-", ":"))

				self.msg = "Looking for the desired lobby..."
			elseif key == 'backspace' then
				self.ip = self.ip:sub(1, -2)
				self.msg = ""
			elseif contains(nums, key) then
				self.ip = self.ip .. key
				self.msg = ""
			else
				self.msg = "An IP address is composed of numbers, dots, and a 4 number port."
			end
		end
	end
end

function MainPage:update(dt)
	if self.host then
		local event = self.host:service()
		if event then
			if event.type == 'connect' then
				self.msg = "Found a lobby! Starting game soon."
				event.peer:send("ping")
				self.host:flush()
			elseif event.type == 'receive' then
				if event.data == "pong" then
					GamePage.sethost(self.host)
					GamePage.setserver(self.server)

					self.frame:navigate(GamePage)
				elseif event.data == "started" then
					self.msg = "This lobby's game has already started. Close the game and try again later."
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