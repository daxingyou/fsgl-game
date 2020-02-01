-- 神·孙尚香 51

local ssssx = class("ssssx", function ( params )
	local animal = Character:_create(params)
	return animal
end)
--[[
	atk: 普通的弓箭
	atk1: 5只金光闪闪的箭
	atk2: 3连发蓝色晶莹剔透箭
	atk3: 向上发射，自身四周箭镇
	atk0: 炫光神箭
]]
function ssssx:_initCache()
	XTHD.createSprite("res/spine/effect/051/zidanpugong.png")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/051/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/051/atk2/atk2")
			XTHD.createSprite("res/spine/effect/051/atk1/atk1zidan.png")
		end
	end
end

function ssssx:doAnimationEvent(event)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local name = event.eventData.name
	local _animalName = self:getNowAniName()

    local _skillData 	  = self:getSkillByAction(_animalName)
    local selectedTargets = self:getSelectedTargets(_animalName)
	local _targetList 	  = self:getHurtableTargets({selectedTargets = selectedTargets , skill = _skillData})
	--[[大招，判断敌人是否在技能伤害范围之内]]
	if name == BATTLE_ANIMATION_EVENT.onAtkDone then
		if _targetList == nil or #_targetList < 1 then
			return
		end
		--[[取第一个对象，也是最近的一个]]
		local _target_enemy = _targetList[1]
		if _target_enemy then
			local _arrow = XTHD.createSprite("res/spine/effect/051/zidanpugong.png")
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
			_arrow:setAnchorPoint(cc.p(1,0.5))
			local pos_delta = cc.pGetDistance(endPos, _targetSlot)
			local dt = getDynamicTime(pos_delta, 1000)

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _arrow},
			})

			_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
					local _rotate = _arrow:getRotation()
					_arrow:removeFromParent()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					self:doHurt({skill = _skillData,targets = _targetList})
					animalClickedAnimation({
							rotation = _rotate
							,randValue = _randValue
							,path = "res/spine/effect/051/zidanpugong1.png"
							,attacker = self
							,beAttacker = _target_enemy
						})
			end)))
		end
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
		for k,target in pairs(_targetList) do
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/051/atk1/atk1")
				
			target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})				
			effect_spine:setAnimation(0,"atk0",false)

			performWithDelay(effect_spine,function( )
				effect_spine:removeFromParent()
			end,2.0)
		end--[[--for end]]
		self:doHurt({skill = _skillData,targets = _targetList})
	elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done and _targetList[1]:isAlive() == true then
		--[[--第一个目标]]
		local target = _targetList[1]
		local _targetSlot = self:getSlotPositionInWorld("firePoint")
		local endPos = target:getSlotPositionInWorld("midPoint")
		
		math.newrandomseed()
        local arr = {}
        arr[#arr + 1] = -50
        arr[#arr + 1] = 0
        arr[#arr + 1] = 50
        arr[#arr + 1] = 200
        arr[#arr + 1] = 100
        arr[#arr + 1] = 150
        local random = math.random(#arr)
        -- XTHDTOAST("random="..tostring(random))
		local mid = cc.p((endPos.x - _targetSlot.x) / 2 + _targetSlot.x, 250 + _targetSlot.y)
		
		local mid_x = (endPos.x - _targetSlot.x) / 2 + _targetSlot.x
        bezier_pos1 = cc.p(_targetSlot.x, _targetSlot.y)
        bezier_pos2 = cc.p(mid_x-20, 250 + _targetSlot.y )
        bezier_pos3 = cc.p(mid_x+20, 200 + arr[random] + _targetSlot.y )
		bezier_pos4 = cc.p(endPos.x, endPos.y)
		-- XTHDTOAST(random)
		local bezier = {
	        bezier_pos1,
			-- bezier_pos2,
			bezier_pos3,
			bezier_pos4,
	    }


		local _arrow = XTHDArrow:createWithParams({fileName = "res/spine/effect/051/atk1/atk1zidan.png" , autoRotate = true})
		_arrow:setScale(self:getScaleY())
		local pos_delta = getDistance( endPos, _targetSlot )
		-- local bezier = {
	 --        cc.p(_targetSlot.x,_targetSlot.y ),
		-- 	cc.p(mid.x,mid.y),
		-- 	cc.p(mid2.x,mid2.y),
		-- 	cc.p(endPos.x,endPos.y)
	 --    }
		local dt = getDynamicTime(pos_delta, 1000) * 1.5
		local actionBezier = cc.BezierTo:create(dt, bezier)
		local angle = math.atan(( mid.y - _targetSlot.y) / (mid.x - _targetSlot.x))
		_arrow:setPosition(cc.p(_targetSlot.x,_targetSlot.y))
		_arrow:setRotation(0 - 180 * angle / math.pi)
		_arrow:setOpacity(100)
		_arrow:runAction(cc.FadeIn:create(0.3))

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = _arrow},
		})

		_arrow:runAction(cc.Sequence:create(actionBezier,cc.CallFunc:create(function()
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/051/atk2/atk2")
			target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})	
			effect_spine:setAnimation(0,"atk0",false)

			performWithDelay(effect_spine,function( )
				effect_spine:removeFromParent()	
			end,2.0)
			
			local _tmp_targets = {}
			_tmp_targets[#_tmp_targets + 1] = target
			self:doHurt({skill = _skillData,targets = _tmp_targets})

			_arrow:removeFromParent()
		end)))
	elseif name == BATTLE_ANIMATION_EVENT.onAtk3Done then--[[--友方加buff]]
		self:doHurt({skill = _skillData,targets = _targetList})
	elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
		for k,target in pairs(_targetList) do
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/051/atk0/atk0")
				
			target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})				
			effect_spine:setAnimation(0,"atk0",false)
			
			performWithDelay(effect_spine,function( )
				effect_spine:removeFromParent()
			end,2.0)
			--[[攻击的帧事件，此时敌人应该出发受击操作]]
		end--[[--for end]]
		self:doHurt({skill = _skillData,targets = _targetList})
		if self:getType() == ANIMAL_TYPE.PLAYER then
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 20, time = 0.3}
			})
		end
	end
end

function ssssx:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function ssssx:create(params)
	return ssssx.new(params)
end

return ssssx