--[[
------用于客户端向服务器发送socket消息
]]

SocketSend = class("SocketSend")
SocketSend.instance = nil

function SocketSend:ctor( )
	self._cache = {}
	self._length = 0
	self._errorCallStack = {}
end

function SocketSend:getInstance( )
	if not SocketSend.instance then 
		SocketSend.instance = SocketSend.new()
	end 
	return SocketSend.instance
end

function SocketSend:writeChar(data)
	self._cache[#self._cache + 1] = {value = data,_type = "char"}
	self._length = self._length + 1
end

function SocketSend:writeShort(data)
	self._cache[#self._cache + 1] = {value = data,_type = "short"}
	self._length = self._length + 2
end

function SocketSend:writeInt(data)
	self._cache[#self._cache + 1] = {value = data,_type = "int"}
	self._length = self._length + 4
end

function SocketSend:writeLong(data)
	self._cache[#self._cache + 1] = {value = data,_type = "long"}
	self._length = self._length + 4
end

function SocketSend:writeFloat(data)
	self._cache[#self._cache + 1] = {value = data,_type = "float"}
	self._length = self._length + 4
end

function SocketSend:writeDouble(data)
	self._cache[#self._cache + 1] = {value = data,_type = "double"}
	self._length = self._length + 8
end

function SocketSend:writeString(data)
	self:writeShort(string.len(data))
	self._cache[#self._cache + 1] = {value = data,_type = "string"}
	self._length = self._length + string.len(data)
end

function SocketSend:send(msgHead)
	if self._length >= 0 then 
		local data = ByteArray.new(ByteArray.ENDIAN_BIG)
		local len = MsgCenter.HEADERLENGTH + self._length
		data:writeShort(len)
		data:writeShort(msgHead)
		for k,v in ipairs(self._cache) do 
			if v._type == "char" then 
				data:writeChar(v.value)
			elseif v._type == "short" then 
				data:writeShort(v.value)				
			elseif v._type == "int" then 
				data:writeInt(v.value)
			elseif v._type == "long" then 
				data:writeLong(v.value)
			elseif v._type == "float" then 
				data:writeFloat(v.value)
			elseif v._type == "double" then 
				data:writeDouble(v.value)
			elseif v._type == "string" then 
				data:writeStringBytes(v.value)
			end 
		end
		MsgCenter:getInstance():msgSend(data)
		--print("client send msg to server,The Head is,the length is",msgHead,self._length)
		self._cache = {}
		self._length = 0
	else 
		--print("then send msg lenght is unavaliable,at file of SocketSend.lua,line 84")
	end 
end

function SocketSend:erroHandle(errorID,data)
	if self._errorCallStack[errorID] then
		self._errorCallStack[errorID](data)
		self._errorCallStack[errorID] = nil
	end 
end

function SocketSend:addErrorFunc(errorID,errorCall)
	if errorID and errorCall then 
		self._errorCallStack[errorID] = errorCall
	end 
end