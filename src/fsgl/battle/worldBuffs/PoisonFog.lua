--毒雾
local PoisonFog = class("PoisonFog", function ( params )
	local buff = WorldBuff:_create(params)
	return buff
end)

function PoisonFog:ctor()
	-- XTHD.createSprite("res/spine/effect/dw/dw8")
	self:getEffectSpineFromCache("res/spine/effect/dw/dw2")
end

function PoisonFog:doStart( )
	self:startAction()

	performWithDelay(self, function()
		local winSize = cc.Director:getInstance():getWinSize()
		-- self._effPic = XTHD.createSprite("res/spine/effect/dw/dw8.png")
		self._effPic = self:getEffectSpineFromCache("res/spine/effect/dw/dw2")
		self._effPic:setAnimation(0, "idle", true)
		self._effPic:setPosition(winSize.width*0.5, winSize.height*0.5)
		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_WORLD_EFFECT,
			data = {node = self._effPic},
		})
	end, 0.01)
end

function PoisonFog:startAction()
	self:setAnimation(0, "idle", true)
	schedule(self, function ( ... )
		-- self:setVisible(true)
		-- self:setAnimation(0, "atk", false)
		local data = {side = BATTLE_SIDE.LEFT}
		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
			data = data,
		})
		local tagets = data.team
		if tagets then
			self:doHurt(tagets)
		end
	end, self:getBuffDuration())
end

function PoisonFog:doAnimationEvent(event)
	-- local name = event.eventData.name
	-- local data = {side = BATTLE_SIDE.LEFT}
	-- XTHD.dispatchEvent({
	-- 	name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
	-- 	data = data,
	-- })
	-- local tagets = data.team
	-- if tagets then
	-- 	if name == "atk" then
	-- 		self:doHurt(tagets)
	-- 	end
	-- end
end

function PoisonFog:create(params)
	return PoisonFog.new(params)
end

return PoisonFog