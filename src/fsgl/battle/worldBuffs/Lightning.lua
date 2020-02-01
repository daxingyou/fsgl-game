--闪电
local Lightning = class("Lightning", function ( params )
	local buff = WorldBuff:_create(params)
	return buff
end)

function Lightning:ctor()
	-- XTHD.createSprite("res/spine/effect/dw/dw8")
	self:getEffectSpineFromCache("res/spine/effect/dw/sd2")
end

function Lightning:onCleanup( ... )
	if self._soundId then
		musicManager.stopEffect(self._soundId)
	end
end

function Lightning:doStart( )
	self:startAction()
	self._soundId = musicManager.playEffect("res/sound/wind_home.mp3", true)
	performWithDelay(self, function()
		local winSize = cc.Director:getInstance():getWinSize()
		self._effPic = self:getEffectSpineFromCache("res/spine/effect/dw/sd")
		self._effPic:setAnimation(0, "idle", true)
		self._effPic:setPosition(winSize.width*0.5, winSize.height*0.5)
		
		local scaleX = winSize.width / 1024
		local scaleY = winSize.height / 615

        self._effPic:setScaleX(scaleX)
		self._effPic:setScaleY(scaleY)
       -- self._effPic:setScale(screenRadio)
		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_WORLD_EFFECT,
			data = {node = self._effPic},
		})

		self._effPic:registerSpineEventHandler( function ( event )
			local name = event.animation
			if name == "atk" then
				self._effPic:setAnimation(0, "idle", true)
			end
		end, sp.EventType.ANIMATION_COMPLETE)
	end, 0.01)
end


function Lightning:startAction()
	self:setAnimation(0, "idle", true)
	performWithDelay(self, function ( ... )
		if self._effPic then
			self._effPic:setAnimation(0, "atk", false)
		end
		self:setAnimation(0, "atk", false)
	end, self:getBuffDuration())
end

function Lightning:doAnimationEvent(event)
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
			musicManager.playEffect("res/sound/skill/sound_effect_35_atk0.mp3")
		end
	end
end

function Lightning:doAnimationComplete( event )
	local name = event.animation
	if name == "atk" then
		self:startAction()
	end
end

function Lightning:create(params)
	return Lightning.new(params)
end

return Lightning