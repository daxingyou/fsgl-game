--[[--101 少年邓九公]]
local Sndjg = class("Sndjg", function ( params )
	local animal = Character:_create(params)
	return animal
end)
--[[
	atk: 提抓
	atk1:蹦抓
	atk2:狼嚎
	atk0:连续伤害
]]
function Sndjg:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/028/atk0/atk0")
	for key,value in pairs(self:getSkills()) do
        value.level=value.level or 0
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/028/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/028/atk2/atk2_2")
		end
	end
end

function Sndjg:doAnimationEvent(event)
	local name 			= event.eventData.name
	local _animalName = self:getNowAniName()
    local _skillData 	= self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getSelectedTargets(_animalName)
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else
		targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
		if targets ~= nil then

			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				for k,target in pairs(targets) do
					local _effect_spine = self:getEffectSpineFromCache("res/spine/effect/028/atk1/atk1")
					target:addNodeForSlot({node = _effect_spine , slotName = "midPoint" , zorder = 10})	
					local _target_scale = -1
					-- if target:getScaleX() < 0 then
					-- 	_target_scale = -1
					-- end			
					_effect_spine:setScaleX(_target_scale * math.abs(_effect_spine:getScaleX()))

					_effect_spine:setAnimation(0,"animation",false)

					performWithDelay(_effect_spine,function()
						_effect_spine:removeFromParent()
						end, 2)
				end
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				local data = {animal = self,skill = _skillData}
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_GET_ALL_ATTACKABLE_TARGETS,
					data = data,
				})
				local targets = data.targets
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == "onAtk0_1Done" then
				for k,target in pairs(targets) do
					local _effect_spine = self:getEffectSpineFromCache("res/spine/effect/028/atk0/atk0")
					target:addNodeForSlot({node = _effect_spine , slotName = "midPoint" , zorder = 10})	
					-- _effect_spine:setScale(1.0 / target:getScaleY())			
					_effect_spine:setAnimation(0,"animation",false)
					performWithDelay(_effect_spine,function()
						_effect_spine:removeFromParent()
						end, 2.7)
				end
			elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				self:doHurt({skill = _skillData,targets = targets})
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
		
	end

end
function Sndjg:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Sndjg:create(params)
	return Sndjg.new(params)
end

return Sndjg