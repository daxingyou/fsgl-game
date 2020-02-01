--[[
	弩兵-303
	对应monsterid:1101~1200
]]
local NuBing = class("NuBing", function ( params )
	local animal = Character:_create(params)
	return animal
end)
function NuBing:_initCache()
	XTHD.createSprite("res/spine/effect/303/arrow.png")
end
function NuBing:doAnimationEvent(event)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local name = event.eventData.name

	--[[大招，判断敌人是否在技能伤害范围之内]]
	if name == BATTLE_ANIMATION_EVENT.onAtkDone then
	    local _skillData 	= self:getSkillByAction(BATTLE_ANIMATION_ACTION.ATTACK)
	    local targets 		= self:getSelectedTargets(BATTLE_ANIMATION_ACTION.ATTACK)
		local _targetList 	= targets
		if _targetList == nil or #_targetList < 1 then
			return
		end

		--[[取第一个对象，也是最近的一个]]
		local _target_enemy = _targetList[1]
		if _target_enemy then
			local _arrow = XTHD.createSprite("res/spine/effect/303/arrow.png")
			_arrow:setScale(self:getScaleY())
			--起始位置
			local _targetSlot = self:getSlotPositionInWorld("firePoint")
			_arrow:setPosition(_targetSlot.x, _targetSlot.y)
			--目标位置
			local _randValue = math.random(20)-10
			local _midPointPos = _target_enemy:getSlotPositionInWorld("midPoint")
			local endPos = cc.p(_midPointPos.x + _randValue,_midPointPos.y + _randValue)

			-- 判定斜率,非弓箭状态
			local deltaY = endPos.y - _targetSlot.y;
			local deltaX = endPos.x - _targetSlot.x;
			local angel = deltaX > 0 and 0 or 180;
			local K = deltaY / deltaX;
			if deltaX ~= 0 then
				_arrow:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
			end
			local pos_delta = cc.pGetDistance(endPos, _targetSlot)
			local dt = getDynamicTime(pos_delta, 1000)*1.25

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _arrow,spine = self},
			})
			_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
					local _rotate = _arrow:getRotation()
					animalClickedAnimation({
								rotation = _rotate
								,randValue = _randValue
								,path = "res/spine/effect/303/arrow1.png"
								,attacker = self
								,beAttacker = _target_enemy
							})
					_arrow:removeFromParent()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					self:doHurt({skill = _skillData,targets = targets})
			end)))
		end
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
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
end

function NuBing:create(params)
	return NuBing.new(params)
end

return NuBing