--[[--少年金吒 99]]

local Snjinzha = class("Snjinzha", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function Snjinzha:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/041/atk0/atk0_1")
	self:getEffectSpineFromCache("res/spine/effect/041/atk0/atk0_2")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/041/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/041/atk2/atk2")
		end
	end
end

function Snjinzha:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _skillData = self:getSkillByAction(self:getNowAniName())
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getSelectedTargets(self:getNowAniName())
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
    elseif name == "onAtk2Begin" then
        local _node=self:getNodeForSlot("midPoint")
        _node:setVisible(false)
    elseif name == "onAtk2End" then
        local _node=self:getNodeForSlot("midPoint")
        _node:setVisible(true)
	else
		targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtk0Done then--[[--外伤免疫buff]]
				self:doHurt({skill = _skillData,targets = targets})
				for k,target in pairs(targets) do
					local effect_spine = self:getEffectSpineFromCache("res/spine/effect/041/atk0/atk0_2")
					target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})
					effect_spine:setAnimation(0,"animation",false)
					performWithDelay(effect_spine,function()
						effect_spine:removeFromParent()
					end, 2)
				end--[[for end]]
			elseif name == "onAtk1Done2" then
				for k,target in pairs(targets) do
					local effect_spine = self:getEffectSpineFromCache("res/spine/effect/041/atk1/atk1")
					target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})
					effect_spine:setAnimation(0,"animation",false)
					performWithDelay(effect_spine,function()
						effect_spine:removeFromParent()
					end, 2)
				end
			elseif name == "onAtk2Done2" then	
				for k,target in pairs(targets) do
					local effect_spine = self:getEffectSpineFromCache("res/spine/effect/041/atk2/atk2")
					target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})
					effect_spine:setAnimation(0,"animation",false)
					performWithDelay(effect_spine,function()
						effect_spine:removeFromParent()
					end, 2)
				end
			elseif name == BATTLE_ANIMATION_EVENT.onAtkDone or name == BATTLE_ANIMATION_EVENT.onAtk1Done or name == BATTLE_ANIMATION_EVENT.onAtk2Done then	
				self:doHurt({skill = _skillData,targets = targets})
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
		
	end

end

function Snjinzha:doSuperAnimationStart(event)
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snjinzha:create(params)
	return Snjinzha.new(params)
end

return Snjinzha