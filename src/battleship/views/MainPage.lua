require "battleship/ui/frame"
local enet = require "enet"

MainPage = { frame = nil }
MainPage.__index = MainPage

local ipfilter = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.', '-' }
local portfilter = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' }

function MainPage:new(o)
	o = o or {}
	setmetatable(o, MainPage)

	o.host = nil
	o.server = nil

	o.bg = love.graphics.newImage("battleship/assets/start.png")

	o.userselected = false

	o.choicemsg = "Press up to become a lobby. Press down to join a lobby."
	o.typemsg = ""

	o.msg = ""
	o.ip = ""

	return o
end

function MainPage:draw()
	love.graphics.draw(self.bg, 0, 0)

	love.graphics.print("")
	love.graphics.print("	Welcome to Bomberfrog!", 0, 24)
	love.graphics.print("	" .. self.choicemsg, 0, 48)
	love.graphics.print("	" .. self.typemsg .. self.ip, 0, 72)

	love.graphics.print("	" .. self.msg, 0, 96)
end

function MainPage:keypressed(key, scancode, isrepeat)
	if not isrepeat then
		if not self.userselected then
			if key == 'up' then
				self.isclient = false

				self.choicemsg = "You are a lobby."
				self.typemsg = "Type out a port to get started: "
			elseif key == 'down' then
				self.isclient = true

				self.choicemsg = "You will be joining a lobby."
				self.typemsg = "Type out an IP address followed by a port (IP-port) to get started: "
			else
				return
			end

			self.userselected = true
		end

		if self.host == nil then
			if self.isclient then
				self:onclientinput(key)
			else
				self:onserverinput(key)
			end
		end
	end
end

function MainPage:onclientinput(key)
	if key == 'return' then
		self.host = enet.host_create()
		self.server = self.host:connect(self.ip:gsub("-", ":"))

		self.msg = "Looking for the desired lobby..."
	elseif key == 'backspace' then
		self.ip = self.ip:sub(1, -2)
		self.msg = ""
	elseif contains(ipfilter, key) then
		self.ip = self.ip .. key
		self.msg = ""
	else
		self.msg = "An IP address is composed of numbers and dots, with a 4 number port at the end."
	end
end

function MainPage:onserverinput(key)
	if key == 'return' then
		self.host = enet.host_create("*:" .. self.ip)

		self.msg = "Waiting for players..."
	elseif key == 'backspace' then
		self.ip = self.ip:sub(1, -2)
		self.msg = ""
	elseif self.ip:len() == 4 then
		self.msg = "A port is 4 characters at most."
	elseif contains(portfilter, key) then
		self.ip = self.ip .. key
		self.msg = ""
	else
		self.msg = "A port is composed of 4 numbers only."
	end
end

function MainPage:update(dt)
	if self.host then
		local event = self.host:service()
		if event then
			if self.isclient then
				self:onclientevent(event)
			else
				self:onserverevent(event)
			end
		end
	end
end

function MainPage:onclientevent(event)
	if event.type == 'connect' then
		self.msg = "Found a lobby! Starting game soon."
		event.peer:send("ping")
		self.host:flush()
	elseif event.type == 'receive' then
		if event.data == "pong" then
			require "battleship/client/views/GamePage"
			GamePage.sethost(self.host)
			GamePage.setserver(self.server)

			self.frame:navigate(GamePage)
		elseif event.data == "started" then
			self.msg = "This lobby's game has already started. Close the game and try again later."
		end
	end
end

function MainPage:onserverevent(event)
	if event.type == 'connect' then
		self.msg = "A player joined the lobby! Starting game soon."
	elseif event.type == 'receive' then
		if event.data == "ping" then
			event.peer:send("pong")
			self.host:flush()

			require "battleship/server/views/GamePage"
			GamePage.sethost(self.host)
			self.frame:navigate(GamePage)
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