--[[
	投弹手-309
	只有动作atk
	对应monsterid:601~700
]]

local TouDanShou = class("TouDanShou", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function TouDanShou:_initCache()
	XTHD.createSprite("res/spine/effect/309/zhu_qiangzidan.png")
	self:getEffectSpineFromCache("res/spine/effect/309/atk1")
end

function TouDanShou:doAnimationEvent(event)
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
		do
			-- XTHDTOAST("309普通攻击没有攻击目标")
			return
		end
	end

	if name == BATTLE_ANIMATION_EVENT.onAtkDone then
		--[[取第一个对象，也是最近的一个]]
		local _target_enemy = _targetList[1]
		if _target_enemy then
			local _arrow = XTHD.createSprite("res/spine/effect/309/zhu_qiangzidan.png")
			_arrow:setScale(self:getScaleY())
			--[[有设置角度的地方就不需要设置翻转]]
			if self:getScaleX() < 0 then
				-- _arrow:setScaleX(-1.0)
			end
			--起始位置
			local _targetSlot = self:getSlotPositionInWorld("firePoint")
			
			_arrow:setPosition(_targetSlot.x, _targetSlot.y)
			--目标位置
			local endPos = _target_enemy:getSlotPositionInWorld("midPoint")

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
					_arrow:removeFromParent()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					self:doHurt({skill = _skillData,targets = targets})
			end)))
		end
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
		local __sp = self:getEffectSpineFromCache("res/spine/effect/309/atk1")
		if self:getScaleX()<0 then
			__sp:setScaleX(-1.0*__sp:getScaleX())
		end
		local _target_enemy = _targetList[1]
		local _TarSlotNode = _target_enemy:getSlotPositionInWorld("root")
		__sp:setPosition(_TarSlotNode)

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = __sp,zorder = self:getLocalZOrder()},
		})

		__sp:registerSpineEventHandler( function ( event )
			if event.eventData.name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				self:doHurt({skill = _skillData,targets = _targetList})
				__sp:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
			end
		end, sp.EventType.ANIMATION_EVENT)

		__sp:setAnimation(0,"atk1",false)
		performWithDelay(__sp, function ()
			if __sp then
				__sp:removeFromParent()
			end
		end, 2)
	end

end

function TouDanShou:create(params)
	return TouDanShou.new(params)
end

return TouDanShou