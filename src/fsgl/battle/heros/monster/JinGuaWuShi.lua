--[[
	金瓜武士-320
	对应monsterid:暂未定
]]
local JinGuaWuShi = class("JinGuaWuShi", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function JinGuaWuShi:create(params)
	return JinGuaWuShi.new(params)
end

function JinGuaWuShi:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	local targets = self:getSelectedTargets(_animalName)

	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
	if targets==nil or #targets<1 then
		return
	end
	self:doHurt({skill = _skillData,targets = targets})
end

return JinGuaWuShi