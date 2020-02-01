--[[
	刀盾兵-304
	对应monsterid:201~300
]]
local DaoDunBing = class("DaoDunBing", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function DaoDunBing:create(params)
	return DaoDunBing.new(params)
end

function DaoDunBing:doAnimationEvent(event)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	local targets = self:getSelectedTargets(_animalName)

	local _targetList 	= targets
	if _targetList == nil or #_targetList < 1 then
		do
			-- XTHDTOAST("304攻击没有攻击目标")
			return
		end
	end

	if name == BATTLE_ANIMATION_EVENT.onAtkDone then
		self:doHurt({skill = _skillData,targets = targets})
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
		-- self:setAnimation(0,"atk1_1",false)
		self:doHurt({skill = _skillData,targets = targets})
	end

end

return DaoDunBing