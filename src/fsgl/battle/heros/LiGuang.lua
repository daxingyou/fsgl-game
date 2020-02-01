--李广

local LiGuang = class("LiGuang", function ( params )
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
function LiGuang:_initCache()
	XTHD.createSprite("res/spine/effect/032/032zidan.png")
	self:getEffectSpineFromCache("res/spine/effect/032/atk0/atk0")
	self:getEffectSpineFromCache("res/spine/effect/032/atk0/atk0_1")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/032/atk1/032atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/032/atk2/atk2")
		end
	end
	self._atk2Count = 1
end

function LiGuang:doAnimationEvent(event)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
    local selectedTargets = self:getSelectedTargets(_animalName)
	local _targetList 	  = self:getHurtableTargets({selectedTargets = selectedTargets , skill = _skillData})

	if _targetList == nil or #_targetList < 1 then
		return
	end
	--[[大招，判断敌人是否在技能伤害范围之内]]
	if name == BATTLE_ANIMATION_EVENT.onAtkDone then
		--[[取第一个对象，也是最近的一个]]
		local _target_enemy = _targetList[1]
		if _target_enemy then
			local _arrow = XTHD.createSprite("res/spine/effect/032/032zidan.png")
			_arrow:setScale(self:getScaleY())
			--起始位置
			local _targetSlot = self:getSlotPositionInWorld("firePoint")

			_arrow:setPosition(_targetSlot.x, _targetSlot.y)
			--目标位置
			local endPos = _target_enemy:getSlotPositionInWorld("midPoint")

			local pos_delta = cc.pGetDistance(endPos, _targetSlot)
			local dt = getDynamicTime(pos_delta, 1000)

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _arrow},
			})
			-- 判定斜率,非弓箭状态
			local deltaY = endPos.y - _targetSlot.y;
			local deltaX = endPos.x - _targetSlot.x;
			local angel = deltaX > 0 and 0 or 180;
			local K = deltaY / deltaX;
			if deltaX ~= 0 then
				_arrow:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
			end

			_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					self:doHurt({skill = _skillData,targets = _targetList})
			end) , cc.RemoveSelf:create(true)))
		end
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
		for k,_target_enemy in pairs(_targetList) do
			local _arrow = XTHD.createSprite("res/spine/effect/032/032zidan.png")
			_arrow:setScale(self:getScaleY())
			--起始位置
			local _targetSlot = self:getSlotPositionInWorld("firePoint")

			_arrow:setPosition(_targetSlot.x, _targetSlot.y)
			--目标位置
			local endPos = _target_enemy:getSlotPositionInWorld("midPoint")

			local pos_delta = cc.pGetDistance(endPos, _targetSlot)
			local dt = getDynamicTime(pos_delta, 1000)

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _arrow},
			})
			--计算角度
			-- 判定斜率,非弓箭状态
			local deltaY = endPos.y - _targetSlot.y;
			local deltaX = endPos.x - _targetSlot.x;
			local angel = deltaX > 0 and 0 or 180;
			local K = deltaY / deltaX;
			if deltaX ~= 0 then
				_arrow:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
			end
			_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					local _tmp_targets = {}
					_tmp_targets[#_tmp_targets + 1] = _target_enemy
					self:doHurt({skill = _skillData,targets = _tmp_targets})
					local effect_spine = self:getEffectSpineFromCache("res/spine/effect/032/atk1/032atk1")
					_target_enemy:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})
					effect_spine:setAnimation(0,"atk1",false)
					performWithDelay(effect_spine,function()
						effect_spine:removeFromParent()
					end, 0.6)
			end) , cc.RemoveSelf:create(true)))
		end
	elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
		self._atk2Count = self._atk2Count or 1
		local _bitCount = self._atk2Count
		for k,_target_enemy in pairs(_targetList) do
			local _arrow = XTHD.createSprite("res/spine/effect/032/032zidan.png")
			_arrow:setScale(self:getScaleY())
			--起始位置
			local _targetSlot = self:getSlotPositionInWorld("firePoint")

			_arrow:setPosition(_targetSlot.x, _targetSlot.y)
			--目标位置
			local endPos = _target_enemy:getSlotPositionInWorld("midPoint")

			local pos_delta = cc.pGetDistance(endPos, _targetSlot)
			local dt = getDynamicTime(pos_delta, 1000)

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _arrow},
			})
			--计算角度
			-- 判定斜率,非弓箭状态
			local deltaY = endPos.y - _targetSlot.y;
			local deltaX = endPos.x - _targetSlot.x;
			local angel = deltaX > 0 and 0 or 180;
			local K = deltaY / deltaX;
			if deltaX ~= 0 then
				_arrow:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
			end
			_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					local _tmp_targets = {}
					_tmp_targets[#_tmp_targets + 1] = _target_enemy
					self:doHurt({skill = _skillData,targets = _tmp_targets, count = _bitCount})
					local effect_spine = self:getEffectSpineFromCache("res/spine/effect/032/atk2/atk2");
					_target_enemy:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})
					
					effect_spine:setAnimation(0,"atk2",false)
					performWithDelay(effect_spine,function()
						effect_spine:removeFromParent()
					end, 3)
			end) , cc.RemoveSelf:create(true)))
		end
		self._atk2Count = self._atk2Count + 1
		if self._atk2Count > 6 then
			self._atk2Count = 1
		end
	elseif name == "onAtk0_1Done" then--[[--]]
		for k,_target_enemy in pairs(_targetList) do
			-- 预留设置打击对方
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/032/atk0/atk0_1")
			local _targetPos = _target_enemy:getSlotPositionInWorld("midPoint")
			effect_spine:setPosition(_targetPos)

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = effect_spine,zorder = _target_enemy:getLocalZOrder()},
			})

			effect_spine:setAnimation(0,"atk0",false)
			performWithDelay(effect_spine,function()
				effect_spine:removeFromParent()
			end, 1.5)
		end
	elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
		for k,_target_enemy in pairs(_targetList) do
			local _arrow = XTHD.createSprite("res/spine/effect/032/032zidan.png")
			--起始位置
			local _targetSlot = self:getSlotPositionInWorld("firePoint")

			_arrow:setPosition(_targetSlot.x, _targetSlot.y)
			--目标位置
			local endPos = _target_enemy:getSlotPositionInWorld("midPoint")

			local pos_delta = cc.pGetDistance(endPos, _targetSlot)
			local dt = getDynamicTime(pos_delta, 1000)

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _arrow},
			})
			--计算角度
			-- 判定斜率,非弓箭状态
			local deltaY = endPos.y - _targetSlot.y;
			local deltaX = endPos.x - _targetSlot.x;
			local angel = deltaX > 0 and 0 or 180;
			local K = deltaY / deltaX;
			if deltaX ~= 0 then
				_arrow:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
			end
			_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
					_arrow:removeFromParent()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					local _tmp_targets = {}
					_tmp_targets[#_tmp_targets + 1] = _target_enemy
					self:doHurt({skill = _skillData,targets = _tmp_targets})
					local effect_spine = self:getEffectSpineFromCache("res/spine/effect/032/atk0/atk0")

					local _targetSlot = _target_enemy:getSlotPositionInWorld("midPoint")
					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = effect_spine,zorder = _target_enemy:getLocalZOrder()},
					})
					effect_spine:setPosition(_targetSlot)

					effect_spine:setAnimation(0,"atk0",false)
					performWithDelay(effect_spine,function()
						effect_spine:removeFromParent()
					end, 2)
			end)))
		end--[[--for end]]
	end
end

function LiGuang:doSuperAnimationStart(event)
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function LiGuang:create(params)
	return LiGuang.new(params)
end

return LiGuang