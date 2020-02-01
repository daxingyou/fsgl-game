--[[--21 芈月]]
local MinYue = class("MinYue", function ( params )
	local animal = Character:_create(params)
	return animal
end)
--[[
	atk0_01：大招施法地面特效工程，帧事件：onAtk0done
	atk0_02：大招施法落锤特效工程，帧事件：onAtk0luochui
	atk1：蹦起捶地
	atk2：弯腰前顶
]]
function MinYue:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/021/atk0/atk0")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/021/atk2/atk2")
		end
	end
end

function MinYue:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _skillData = self:getSkillByAction(self:getNowAniName())
	local targets = self:getNowSkillTarges(_skillData)

	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				self:doHurt({skill = _skillData,targets = targets})
				for k,v in pairs(targets) do 
					local effect = self:getEffectSpineFromCache("res/spine/effect/021/atk0/atk0")

					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = effect,spine = self},
					})
					if self:getScaleX() < 0 then
						effect:setScaleX(-1*effect:getScaleX())
					end
					effect:setPosition(v:getPosition())
					effect:setAnimation(0,"animation",false)
					performWithDelay(effect,function( )
						effect:removeFromParent()	
					end,1.0)
					if not v:isWorldBoss() then
						v:runAction(cc.Sequence:create(
							cc.MoveBy:create(0.05,cc.p(0, 70)), 
							cc.DelayTime:create(0.1),  
							cc.MoveBy:create(0.2, cc.p(0,-70))))
					end
				end 

				if self:getType() == ANIMAL_TYPE.PLAYER then
					XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
					})
				end
			elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				self:doHurt({skill = _skillData,targets = targets})
				for k,v in pairs(targets) do 
					local effect = self:getEffectSpineFromCache("res/spine/effect/021/atk2/atk2")

					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = effect,spine = self},
					})
					if self:getScaleX() < 0 then
						effect:setScaleX(-1*effect:getScaleX())
					end
					effect:setPosition(v:getPosition())
					effect:setAnimation(0,"animation",false)
					performWithDelay(effect,function( )
						effect:removeFromParent()	
					end,1.0)
				end 
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				self:doHurt({skill = _skillData,targets = targets})
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
		
	end

end

function MinYue:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function MinYue:create(params)
	return MinYue.new(params)
end

return MinYue