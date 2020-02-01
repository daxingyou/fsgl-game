--[[
For quick-cocos2d-x
SocketTCP lua
@author zrong (zengrong.net)
Creation: 2013-11-12
Last Modification: 2013-12-05
@see http://cn.quick-x.com/?topic=quickkydsocketfzl
]]
requires ("src/utils/ByteArray.lua")

local SOCKET_TICK_TIME = 0.1 			-- check socket data interval
local SOCKET_RECONNECT_TIME = 0.5			-- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 3	-- socket failure timeout

local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"

local scheduler = requires("src/framework/scheduler.lua")
local socket = require "socket"

local SocketTCP = class("SocketTCP")

SocketTCP.EVENT_DATA = "SOCKET_TCP_DATA"
SocketTCP.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
SocketTCP.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
SocketTCP.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
SocketTCP.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"

SocketTCP._VERSION = socket._VERSION
SocketTCP._DEBUG = socket._DEBUG

function SocketTCP.getTime()
	return socket.gettime()
end

function SocketTCP:ctor(__host, __port, __retryConnectWhenFailure)
    self.host = __host
    self.port = __port
	self.tickScheduler = nil			-- timer for data
	self.reconnectScheduler = nil		-- timer for reconnect
	self.connectTimeTickScheduler = nil	-- timer for connect timeout
	self.name = 'SocketTCP'
	self.tcp = nil
	self.isRetryConnect = __retryConnectWhenFailure
	self.isConnected = false

    self.bytesNeeded=0
    self.eventDispatcher = cc.Node:create():getEventDispatcher()
    self.cache = ByteArray.new(ByteArray.ENDIAN_BIG)
    self.waitingForHeader = true
    self.bytesNeeded = 0
end

function SocketTCP:setName( __name )
	self.name = __name
	return self
end

function SocketTCP:setTickTime(__time)
	SOCKET_TICK_TIME = __time
	return self
end

function SocketTCP:setReconnTime(__time)
	SOCKET_RECONNECT_TIME = __time
	return self
end

function SocketTCP:setConnFailTime(__time)
	SOCKET_CONNECT_FAIL_TIMEOUT = __time
	return self
end

function SocketTCP:connect(__host, __port, __retryConnectWhenFailure)
	if __host then self.host = __host end
	if __port then self.port = __port end
	if __retryConnectWhenFailure ~= nil then self.isRetryConnect = __retryConnectWhenFailure end
	assert(self.host or self.port, "Host and port are necessary!")
	--printInfo("%s.connect(%s, %d)", self.name, self.host, self.port)
	self.tcp = socket.tcp()
	self.tcp:settimeout(0)

	local function __checkConnect()
		local __succ = self:_connect()
		if __succ then
			self:_onConnected()
		end
		return __succ
	end

	if not __checkConnect() then ---- 没连上
		-- check whether connection is success
		-- the connection is failure if socket isn't connected after SOCKET_CONNECT_FAIL_TIMEOUT seconds
		local __connectTimeTick = function ()
			--printInfo("%s.connectTimeTick", self.name)
			if self.isConnected then return end
			self.waitConnect = self.waitConnect or 0
			self.waitConnect = self.waitConnect + SOCKET_RECONNECT_TIME
			if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
				self.waitConnect = nil
				self:close()
				self:_connectFailure()
			end
			__checkConnect()
		end
		if not self.connectTimeTickScheduler then 
			self.connectTimeTickScheduler = scheduler.scheduleGlobal(__connectTimeTick, SOCKET_RECONNECT_TIME)
		end 
	end
end

function SocketTCP:send(__data)
	assert(self.isConnected, self.name .. " is not connected.")
	self.tcp:send(__data)
end

function SocketTCP:close( needReconnect )	
	self.tcp:close();
	self.isConnected = false
	if self.connectTimeTickScheduler then 
		scheduler.unscheduleGlobal(self.connectTimeTickScheduler) 
		self.connectTimeTickScheduler = nil
	end
	if self.tickScheduler then 
		scheduler.unscheduleGlobal(self.tickScheduler)
		self.tickScheduler = nil 
	end
	XTHD.dispatchEvent({name=SocketTCP.EVENT_CLOSED,data = needReconnect})
end

-- disconnect on user's own initiative.
function SocketTCP:disconnect()
	self:_disconnect()
	self.isRetryConnect = false -- initiative to disconnect, no reconnect.
end

--------------------
-- private
--------------------

--- When connect a connected socket server, it will return "already connected"
-- @see: http://lua-users.org/lists/lua-l/2009-10/msg00584.html
function SocketTCP:_connect()
	local __succ, __status = self.tcp:connect(self.host, self.port)
	return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end

function SocketTCP:_disconnect()
	self.isConnected = false
	self.tcp:shutdown()
	XTHD.dispatchEvent({name=SocketTCP.EVENT_CLOSED})
end

function SocketTCP:_onDisconnect()
	self.isConnected = false
	XTHD.dispatchEvent({name=SocketTCP.EVENT_CLOSED})
end

function SocketTCP:_connectFailure(status)
	XTHD.dispatchEvent({name=SocketTCP.EVENT_CONNECT_FAILURE,data = status})
end

-- connecte success, cancel the connection timerout timer
function SocketTCP:_onConnected()
	self.isConnected = true
	XTHD.dispatchEvent({name=SocketTCP.EVENT_CONNECTED})
	if self.connectTimeTickScheduler then 
		scheduler.unscheduleGlobal(self.connectTimeTickScheduler) 
		self.connectTimeTickScheduler = nil
		self.waitConnect = nil
	end

	local function __tick()
		while true do
			local __body, __status, __partial = self.tcp:receive("*a")	-- read the package body
    	    if __status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED then
		    	self:close(true)
		    	if self.isConnected then
		    		self:_onDisconnect()
		    	else
		    		self:_connectFailure(true)
		    	end
		   		return
	    	end
		    if 	(not __body and not __partial) or (__body and string.len(__body) == 0) or (__partial and string.len(__partial) == 0) then 
				return 
			end
			if __body and __partial then 
				__body = __body .. __partial 
			end

            self.cache:writeStringBytes(__body or __partial)
            self.cache:setPos(1)

            self:readData()

            if self.cache:getAvailable() > 0 then  
                local tmp = ByteArray.new(ByteArray.ENDIAN_BIG)
                tmp:writeBytes(self.cache, self.cache:getPos(), self.cache:getAvailable());
                self.cache = tmp
            elseif self.cache:getAvailable() == 0 then
                self.cache = ByteArray.new(ByteArray.ENDIAN_BIG)
            end
		end
	end
	if not self.tickScheduler then 
		self.tickScheduler = scheduler.scheduleGlobal(__tick, SOCKET_TICK_TIME)
	end 
end

----------------------------------------------------------------------------------------------------------------------------------------------------
---authored by LITAO
function SocketTCP:readData()	
    if self.waitingForHeader then
        if self.cache:getAvailable() >= 4 then
            self.bytesNeeded = self.cache:readShort() -----the message size (include head and body)
            self.waitingForHeader = false
        end
    end
    if not self.waitingForHeader then
        if self.cache:getAvailable() >= (self.bytesNeeded - 2) then
            self.waitingForHeader = true
            local msgID = self.cache:readShort() -----current message ID
        	--print("the socket message length is,and message id is",self.bytesNeeded,msgID)
            
            local ba = ByteArray.new(ByteArray.ENDIAN_BIG)
            ba:writeBytes(self.cache, self.cache:getPos(), self.bytesNeeded - 4)
            --writeBytes有bug，不能正确设置self.cache的位置，所以手动设定
            self.cache:setPos(self.cache:getPos() + self.bytesNeeded - 4)
            ba:setPos(1)
		    local event = {msg = ba,length = self.bytesNeeded - 4,msgID = msgID,}
		    XTHD.dispatchEvent({
		    	name = SocketTCP.EVENT_DATA,
		    	data = event
		    })
            self:readData()
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------

return SocketTCP
