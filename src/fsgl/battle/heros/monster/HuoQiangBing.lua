--[[
	火枪兵-306
]]
local HuoQiangBing = class("HuoQiangBing", function ( params )
	local animal = Character:_create(params)
	return animal
end)
function HuoQiangBing:_initCache()
	XTHD.createSprite("res/spine/effect/306/shitou2.png")
end
function HuoQiangBing:doAnimationEvent(event)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
  	local _skillData = self:getSkillByAction(_animalName)
	local _targetList = self:getSelectedTargets(_animalName)
	_targetList = self:getHurtableTargets({selectedTargets = _targetList , skill = _skillData})
	if _targetList == nil or #_targetList < 1 then
		return
	end
	--[[大招，判断敌人是否在技能伤害范围之内]]
	if name == BATTLE_ANIMATION_EVENT.onAtkDone then
		local _target_enemy = _targetList[1]
		if _target_enemy then
			local _arrow = XTHD.createSprite("res/spine/effect/306/shitou2.png")
			_arrow:setScale(self:getScaleY())
			--起始位置
			local _targetSlot = self:getSlotPositionInWorld("firePoint")

			_arrow:setPosition(_targetSlot.x, _targetSlot.y)
			--目标位置
			local endPos = _target_enemy:getSlotPositionInWorld("midPoint")

			local pos_delta = cc.pGetDistance(endPos, _targetSlot)
			local dt = getDynamicTime(pos_delta, 1000)*1.25

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _arrow,spine = self},
			})

			_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
					_arrow:removeFromParent()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					self:doHurt({skill = _skillData,targets = _targetList})
			end)))
		end
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
		self:doHurt({skill = _skillData,targets = _targetList})
	end
end

function HuoQiangBing:create(params)
	return HuoQiangBing.new(params)
end

return HuoQiangBing