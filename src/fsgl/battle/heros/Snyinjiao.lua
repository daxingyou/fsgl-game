--[[--少年殷郊
heroId : 97
]]
local Snyinjiao = class("Snyinjiao", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function Snyinjiao:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/003/atk0/atk0")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/003/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/003/atk2/atk2")
		end
	end
end

function Snyinjiao:_initYD_Cache()
	self:getEffectSpineFromCache("res/spine/effect/003/1003_atkd")
	self:getEffectSpineFromCache("res/spine/effect/003/1003_atk0")
end
--[[--
	atk0：大招受击特效，帧事件：onAtk0done
	atk1：护盾技能，onAtk1Done
	atk2：龙柱技能，onAtk2Done
]]
function Snyinjiao:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	if _animalName == BATTLE_ANIMATION_ACTION.BIAN_SUPER then
		_animalName = BATTLE_ANIMATION_ACTION.SUPER
	end
	local _skillData = self:getSkillByAction(_animalName)
	local targets
	if name == BATTLE_ANIMATION_EVENT.onAtk0Done or name == "onAtk0Done_2" then
		targets = self:getNowSkillTarges(_skillData)
	else
		targets = self:getSelectedTargets(_animalName)
	end
	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
		if targets ~= nil then
			local x,y = self:getPosition()
			local firstTarget = targets[1]
			local move = 0
			if x < firstTarget:getPositionX() then
				move = math.abs(_skillData.attackrange)
			else
				move = -math.abs(_skillData.attackrange)
			end
			local time = 0.6
			local move1 = cc.EaseIn:create(cc.MoveBy:create(time,cc.p(move, 0)),time)
			local move2 = cc.EaseOut:create(cc.MoveBy:create(time,cc.p(-move, 0)),time)
			self:runAction(cc.Sequence:create(move1,cc.DelayTime:create(0.3),move2))
		end
	else
		--[[对应技能的攻击次数+1]]
		if targets == nil then
			return
		end
		--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
		if name == BATTLE_ANIMATION_EVENT.onAtk0Done then
			for k,_target in pairs(targets) do
				local effect_spine  = self:getEffectSpineFromCache("res/spine/effect/003/atk0/atk0")
				_target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})
				effect_spine:setAnimation(0,"atk0",false)	
				performWithDelay(effect_spine,function( )
					effect_spine:removeFromParent()
				end,0.2)
			end
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 20, time = 0.2},
			})
			self:doHurt({skill = _skillData,targets = targets})
		elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
			self:doHurt({skill = _skillData,targets = targets})
		elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then

			local effect_sp = self:getEffectSpineFromCache("res/spine/effect/003/atk2/atk2")
			--[[--取第一个人]]
			local mid_slat_pos = targets[1]:getSlotPositionInWorld("root")

			if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
			 	effect_sp:setScaleX(-1*effect_sp:getScaleX())
			end

		 	effect_sp:setPosition(mid_slat_pos.x, mid_slat_pos.y)
			effect_sp:setAnimation(0,"atk2",false)
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = effect_sp, zorder = targets[1]:getLocalZOrder()},
			})
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 20, time = 0.3},
			})

			performWithDelay(effect_sp,function()
				effect_sp:removeFromParent()
			end,0.9666)
			self:doHurt({skill = _skillData,targets = targets})
		elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
			self:doHurt({skill = _skillData,targets = targets})
		elseif name == "onAtk0Done_1" then
			local __sp = self:getEffectSpineFromCache("res/spine/effect/003/1003_atk0", 1.0)
			__sp:setPosition(winWidth*0.5, winHeight*0.5)
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = __sp, zorder = 10},
			})			
			__sp:setAnimation(0, "atk0", false)
			performWithDelay(__sp, function( )
				__sp:removeFromParent()
			end, 1.6333)
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 30, time = 0.3},
			})
		elseif name == "onAtk0Done_2" then
			local __sp = self:getEffectSpineFromCache("res/spine/effect/003/1003_atkd", 1.0)
			for k,_target in pairs(targets) do
				local effect_spine  = self:getEffectSpineFromCache("res/spine/effect/003/1003_atkd", 1.0)
				_target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})
				effect_spine:setAnimation(0,"atk0",false)	
				performWithDelay(effect_spine,function( )
					effect_spine:removeFromParent()
				end,0.4333)
			end
			self:doHurt({skill = _skillData,targets = targets})
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 20, time = 0.2},
			})
		end
	end

end

function Snyinjiao:doAnimationStart(event)
	if event.animation=="atk0" then
        self:setImmuneControl(true)
    end
end

function Snyinjiao:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snyinjiao:create(params)
	return Snyinjiao.new(params)
end

return Snyinjiao