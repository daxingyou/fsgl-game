--[[少年杨戬108]]
local Snyangjian = class("Snyangjian", function ( params )
	local animal = Character:_create(params)
	return animal
end)
--[[
	atk0 大招
	atk  普攻  抓击
	atk1   拨山移石
	atk2   龙爪 被动技能
	atk3   破硬 被动技能
--]]
function Snyangjian:_initCache()
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/009/atk1")
		end
	end
end

--[[
onAtk0Done2 大招最后一击
]]
function Snyangjian:doAnimationEvent(event)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local _animalName = self:getNowAniName()
	local targets = self:getSelectedTargets(_animalName)
	
	local name = event.eventData.name
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else
		local _skillData = self:getSkillByAction(_animalName)
		targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})

		--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
		if name == BATTLE_ANIMATION_EVENT.onAtk0Done or name == BATTLE_ANIMATION_EVENT.onAtk0Done2 then
			if name == BATTLE_ANIMATION_EVENT.onAtk0Done2 then
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 5}
				})
				--[[处理击退]]
				local winWidth = cc.Director:getInstance():getWinSize().width

				for k,target in pairs(targets) do
					local targetPosX, targetPosY = target:getPosition()
					if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
						targetPosX = targetPosX + 100
						--[[如果超过边界，就无法再被击退]]
						if targetPosX > winWidth - 100 then
							targetPosX = winWidth - 100
						end
					else
						targetPosX = targetPosX - 100
						--[[如果超过边界，就无法再被击退]]
						if targetPosX < 100 then
							targetPosX = 100
						end
					end

					if not target:isWorldBoss() and not target:isCannotBemoved() then
						target:runAction( cc.MoveTo:create(0.05, cc.p(targetPosX, targetPosY)) )
					end
				end--[[for end]]
			end
			
			self:doHurt({skill = _skillData,targets = targets})


		elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
			local target = targets[1]
			if target:isAlive() then
				local _effect_spine = self:getEffectSpineFromCache("res/spine/effect/009/atk")
				target:addNodeForSlot({node = _effect_spine , slotName = "midPoint" , zorder = 10})				
				_effect_spine:setAnimation(0,"animation",false)
				_effect_spine:setScaleX(-1*_effect_spine:getScaleX())
				self:doHurt({skill = _skillData,targets = targets})
				performWithDelay(_effect_spine,function()
					_effect_spine:removeFromParent()
				end, 0.3333)
			end
		elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
			self:doHurt({skill = _skillData,targets = targets})
		elseif name == "onAtk1Done2" then
			for k,target in pairs(targets) do
				if target:isAlive() then
					local _effect_spine = self:getEffectSpineFromCache("res/spine/effect/009/atk1")
					target:addNodeForSlot({node = _effect_spine , slotName = "midPoint" , zorder = 10})				
					_effect_spine:setAnimation(0,"animation",false)

					performWithDelay(_effect_spine,function()
						_effect_spine:removeFromParent()
					end, 0.9333)
				end
			end
		end
	end

end

function Snyangjian:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snyangjian:create(params)
	return Snyangjian.new(params)
end

return Snyangjian