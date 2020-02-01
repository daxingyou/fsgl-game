-- FileName: GlobalScheduler.lua
-- Author: wangming
-- Date: 2015-09-24
-- Purpose: 唯一的全局定时调度器，调度间隔 1 秒
--[[TODO List]]
GlobalScheduler = class("GlobalScheduler", function()
	return cc.Node:create()
end)

function GlobalScheduler:create( par )
	local node = GlobalScheduler.new()
	if par then
		par:addChild(node)
	end
	return node
end

function GlobalScheduler:ctor( ... )
	self.m_fnUnScheduler = false-- 停止全局定时器的方法
	self.m_tbCallbacks = nil-- 保存注册的回调方法
	local function scriptHandler( tag )
		if tag == "cleanup" then
        	self:destroy()
        end
    end
    self:registerScriptHandler(scriptHandler)
end

-- 开始调度
function GlobalScheduler:schedule()
	if self.m_fnUnScheduler then
		return
	end
	
	local _nowTime, _tarLeft 
	local _mCount = 0
	local function p_scheduleFunc( dt )
		local pNum = tonumber(dt)
		_mCount = _mCount + pNum
        if _mCount < 1 then
            return
        end
        _mCount = _mCount - 1
		_nowTime = os.time()
		for name, func in pairs(self.m_tbCallbacks) do
			if func ~= nil then
				if not func.cdTime then
					_tarLeft = nil
				else
					_tarLeft = func.startTime + func.cdTime - _nowTime
					_tarLeft = _tarLeft < 0 and 0 or _tarLeft
				end
				if (type(func.perCall) == "function") then
					func.perCall(_tarLeft)
				end
				if _tarLeft and _tarLeft == 0 then
					if (type(func.endCall) == "function") then
						func.endCall(_tarLeft)
					end
				end
			end
		end
	end
	self:scheduleUpdateWithPriorityLua(p_scheduleFunc, 0)
	-- self.m_fnUnScheduler = schedule(self, p_scheduleFunc, 0.1)
	self.m_fnUnScheduler = true
end

--[[注册一个全局调度回调
	sName, 字符串, 回调名字; 
	sParams = {
		perCall, 每秒回调方法;
		endCall, 结束回调方法
		cdTime, 剩余时间;
	}
]]
function GlobalScheduler:addCallback( sName, sParams )
	if self.m_tbCallbacks == nil then
		self.m_tbCallbacks = {}
	end
	if not self.m_tbCallbacks[sName] then
		self.m_tbCallbacks[sName] = {}
	end
	self.m_tbCallbacks[sName].perCall = sParams.perCall
	self.m_tbCallbacks[sName].endCall = sParams.endCall
	self.m_tbCallbacks[sName].cdTime = tonumber(sParams.cdTime)
	self.m_tbCallbacks[sName].startTime = os.time()
	self:schedule()
	print("GlobalScheduler-addCallback: sName = " .. tostring(sName))
end

-- 注销一个全局调度回调
-- sName, 字符串, 回调名字;
function GlobalScheduler:removeCallback( sName )
	if self.m_tbCallbacks then
		self.m_tbCallbacks[sName] = nil
	end
	if self.m_tbCallbacks and next(self.m_tbCallbacks) == nil then
		self:destroy()
	end
end

function GlobalScheduler:destroy( needRemove )
	print("GlobalScheduler-destroy")
	if (self.m_fnUnScheduler) then
		self:unscheduleUpdate()
		-- self:stopAction(self.m_fnUnScheduler)
		self.m_fnUnScheduler = false
	end
	self.m_tbCallbacks = nil
	if needRemove then
		self:removeFromParent()
	end
end

return GlobalScheduler
