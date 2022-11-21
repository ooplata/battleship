require "battleship/point"
require "battleship/rectangle"
require "battleship/ui/frame"

local enet = require "enet"
local socket = require "socket"

MainPage = { frame = nil }
MainPage.__index = MainPage

local ipfilter = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.', '-' }
local portfilter = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' }

function MainPage:new(o)
	o = o or {}
	setmetatable(o, MainPage)

	o.host = nil
	o.server = nil

	o.bigfont = love.graphics.newFont("battleship/assets/Robot_Font.otf", 28)
	o.bigfont:setFilter("nearest")

	o.bg = love.graphics.newImage("battleship/assets/start.png")

	o.btnimg = love.graphics.newImage("battleship/assets/start-buttons.png")
	o.inputimg = love.graphics.newImage("battleship/assets/start-input.png")

	o:addbuttons()
	o.selected = 0

	o.msg = ""
	o.ip = ""

	return o
end

function MainPage:addbuttons()
	self.buttons = {}

	local point = Point:new{x = 207, y = 302}
	local rect = Rectangle:new{topleft = point, width = 242, height = 51}
	self.buttons[1] = rect

	point = Point:new{x = 208, y = 366}
	rect = Rectangle:new{topleft = point, width = 242, height = 51}
	self.buttons[2] = rect
end

function MainPage:draw()
	love.graphics.draw(self.bg, 0, 0)

	if self.selected == 0 then
		love.graphics.draw(self.btnimg, 0, 0)
	else
		love.graphics.draw(self.inputimg, 0, 0)
	end

	love.graphics.setColor(love.math.colorFromBytes(53, 44, 11))
	love.graphics.print(self.ip, self.bigfont, 220, 342)
	love.graphics.print(self.msg, 206, 312)

	love.graphics.setColor(1, 1, 1)
end

function MainPage:mousepressed(point, button, istouch, presses)
	if self.selected == 0 then
		for i, rect in ipairs(self.buttons) do
			if rect:contains(point) then
				self.selected = i
				if i == 1 then
					local hn = socket.dns.gethostname()
					local ip, _ = socket.dns.toip(hn)

					self.address = ip
					self.msg = "IP Address: " .. ip
				end

				return
			end
		end
	end
end

function MainPage:keypressed(key, scancode, isrepeat)
	if isrepeat or not self.host == nil then
		return
	end

	if self.selected == 1 then
		self:onserverinput(key)
	elseif self.selected == 2 then
		self:onclientinput(key)
	end
end

function MainPage:onclientinput(key)
	if key == 'return' then
		local ip = split(self.ip, "-")
		if not #ip == 2 then
			self.msg = "The introduced IP is invalid, please try again"
			return
		end

		local result, err = socket.dns.tohostname(ip[1])
		if result == nil then
			self.msg = "The introduced IP is invalid, please try again"
		else
			self.host = enet.host_create()
			self.server = self.host:connect(self.ip:gsub("-", ":"))
			self.msg = "Looking for the desired lobby..."
		end
	elseif key == 'backspace' then
		self.ip = self.ip:sub(1, -2)
	elseif contains(ipfilter, key) then
		self.ip = self.ip .. key
	end
end

function MainPage:onserverinput(key)
	if key == 'return' then
		if self.ip:len() == 4 then
			self.host = enet.host_create("*:" .. self.ip)
			self.msg = "Waiting for players. Your IP: " .. self.address
		else
			self.msg = "Invalid port. A port has to be 4 numbers"
		end
	elseif key == 'backspace' then
		self.ip = self.ip:sub(1, -2)
	elseif self.ip:len() == 4 then
		self.msg = "A port is 4 numbers at most"
	elseif contains(portfilter, key) then
		self.ip = self.ip .. key
	else
		self.msg = "IP Address: " .. self.address
	end
end

function MainPage:update(dt)
	if self.host then
		local event = self.host:service()
		if event then
			if self.selected == 1 then
				self:onserverevent(event)
			else
				self:onclientevent(event)
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

function split(input, sep)
	if sep == nil then
		sep = "%s"
	end

	local t = {}
	i = 1
	for str in string.gmatch(input, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end