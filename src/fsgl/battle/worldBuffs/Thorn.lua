--地刺
local Thorn = class("Thorn", function ( params )
	local buff = WorldBuff:_create(params)
	return buff
end)

function Thorn:ctor()
	-- XTHD.createSprite("res/spine/effect/dw/dw8")
	self:getEffectSpineFromCache("res/spine/effect/dw/dici2")
end

function Thorn:onCleanup( ... )
	if self._soundId then
		musicManager.stopEffect(self._soundId)
	end
end

function Thorn:doStart()
	self:startAction()
	self._soundId = musicManager.playEffect("res/sound/wind_home.mp3", true)
	performWithDelay(self, function()
		local winSize = cc.Director:getInstance():getWinSize()
		self._effPic = self:getEffectSpineFromCache("res/spine/effect/dw/dici2")
		self._effPic:setAnimation(0, "idle", true)
		self._effPic:setPosition(winSize.width*0.5, winSize.height*0.5)

		local scaleX = winSize.width / 1024
		local scaleY = winSize.height / 615
		self._effPic:setScaleX(scaleX)
		self._effPic:setScaleY(scaleY)
		
		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_WORLD_EFFECT,
			data = {node = self._effPic},
		})
	end, 0.01)
end

function Thorn:startAction()
	self:setVisible(false)
	performWithDelay(self, function ( ... )
		self:setVisible(true)
		self:setAnimation(0, "atk", false)
	end, self:getBuffDuration())
end

function Thorn:doAnimationEvent(event)
	local name = event.eventData.name
	local data = {side = BATTLE_SIDE.LEFT}
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
		data = data,
	})
	local tagets = data.team
	if tagets then
		if name == "atk" then
			self:doHurt(tagets)
			musicManager.playEffect("res/sound/hiteffect_lurker.mp3")
		end
	end
end

function Thorn:doAnimationComplete( event )
	local name = event.animation
	if name == "atk" then
		self:startAction()
	end
end

function Thorn:create(params)
	return Thorn.new(params)
end

return Thorn