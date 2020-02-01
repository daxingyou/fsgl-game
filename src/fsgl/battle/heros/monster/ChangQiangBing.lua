--[[
	长枪兵-310
	只有动作atk
	对应monsterid:701~800
]]
local ChangQiangBing = class("ChangQiangBing", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function ChangQiangBing:create(params)
	return ChangQiangBing.new(params)
end

function ChangQiangBing:doAnimationEvent(event)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	local targets = self:getSelectedTargets(_animalName)

	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})

	local _targetList 	= targets
	if _targetList == nil or #_targetList < 1 then
		return
	end

	--[[大招，判断敌人是否在技能伤害范围之内]]
	if name == BATTLE_ANIMATION_EVENT.onAtkDone then
		
		self:doHurt({skill = _skillData,targets = _targetList})
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
		self:doHurt({skill = _skillData,targets = _targetList})
	end
end

return ChangQiangBing