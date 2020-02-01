--少年云霄[[--92]]
local Snyx = class("Snyx", function ( params )
	local animal = Character:_create(params)
	return animal
end)
--[[
	atk : 手杖砸地
	atk1:挥舞手杖，欢呼雀跃
	atk2：弯腰顶出去个球
	atk3：挥洒神药，施放魔法
	atk0: 摇摆摇摆
]]
function Snyx:_initCache()
	XTHD.createSprite("res/spine/effect/040/zidan.png")
	self:getEffectSpineFromCache("res/spine/effect/040/atk/atk")
	self:getEffectSpineFromCache("res/spine/effect/040/atk0/atk0_bao")
	self:getEffectSpineFromCache("res/spine/effect/040/atk0/atk0_di")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/040/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			XTHD.createSprite("res/spine/effect/040/zidan1.png")
			self:getEffectSpineFromCache("res/spine/effect/040/atk2/atk2_bao")
		elseif key == "skillid3" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/040/atk3/atk3_jia")
			self:getEffectSpineFromCache("res/spine/effect/040/atk3/atk3_jia2")
		end
	end
end

function Snyx:doAnimationEvent(event)
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
		local target = _targetList[1]
		if target then
			local _arrow = XTHD.createSprite("res/spine/effect/040/zidan.png")
			_arrow:setScale(self:getScaleY())
			--起始位置
			local _targetSlot = self:getSlotPositionInWorld("firePoint")

			_arrow:setPosition(_targetSlot.x, _targetSlot.y)
			--目标位置
			local endPos = target:getSlotPositionInWorld("midPoint")

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
					_arrow:removeFromParent()

					--播放敌人身上的spine
					local _effect_spine = self:getEffectSpineFromCache("res/spine/effect/040/atk/atk")
					target:addNodeForSlot({node = _effect_spine , slotName = "midPoint" , zorder = 10})	
					
					_effect_spine:setAnimation(0,"animation",false)
					performWithDelay(_effect_spine,function()
						_effect_spine:removeFromParent()
						end,4)
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					self:doHurt({skill = _skillData,targets = _targetList})
			end)))
		end
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then--[[--加血]]
		for k,target in pairs(_targetList) do
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/040/atk1/atk1")
				
			target:addNodeForSlot({node = effect_spine , slotName = "root" , zorder = 10})				
			effect_spine:setAnimation(0,"animation",false)

			performWithDelay(effect_spine,function( )
				effect_spine:removeFromParent()
			end,3.0)
		end--[[--for end]]
		self:doHurt({skill = _skillData,targets = _targetList})
	elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
		--[[取第一个对象，也是最近的一个]]
		local target = _targetList[1]
		if target then
			local _arrow = XTHD.createSprite("res/spine/effect/040/zidan1.png")
			_arrow:setScale(self:getScaleY())
			--起始位置
			local _targetSlot = self:getSlotPositionInWorld("firePoint")

			_arrow:setPosition(_targetSlot.x, _targetSlot.y)
			--目标位置
			local endPos = target:getSlotPositionInWorld("midPoint")
			if target:getFaceDirection() == BATTLE_DIRECTION.LEFT then
				endPos.x = endPos.x - _arrow:getBoundingBox().width / 2
			else
				endPos.x = endPos.x + _arrow:getBoundingBox().width / 2
			end
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
					_arrow:removeFromParent()

					--播放敌人身上的spine
					local _effect_spine = self:getEffectSpineFromCache("res/spine/effect/040/atk2/atk2_bao")
					target:addNodeForSlot({node = _effect_spine , slotName = "midPoint" , zorder = 10})	
					_effect_spine:setAnimation(0,"animation",false)
					performWithDelay(_effect_spine,function()
						_effect_spine:removeFromParent()
						end,3)
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					self:doHurt({skill = _skillData,targets = _targetList})
			end)))
		end
	elseif name == "onAtk3Done1" then
		for k, _target in pairs(_targetList) do
			if _target and _target:isAlive() then
				local effect_spine = self:getEffectSpineFromCache("res/spine/effect/040/atk3/atk3_jia")
				_target:addNodeForSlot({node = effect_spine , slotName = "root" , zorder = -10})
				effect_spine:setAnimation(0,"animation",false)
				performWithDelay(effect_spine,function()
					effect_spine:removeFromParent()
				end, 0.8333)
				local effect_spine2 = self:getEffectSpineFromCache("res/spine/effect/040/atk3/atk3_jia2")
				_target:addNodeForSlot({node = effect_spine2 , slotName = "root" , zorder = 10})
				effect_spine2:setAnimation(0,"animation",false)
				performWithDelay(effect_spine2,function()
					effect_spine2:removeFromParent()
				end, 0.8333)
			end 
		end
		self:doHurt({skill = _skillData,targets = _targetList})
	elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
		for k,target in pairs(_targetList) do
			local buffid = tonumber(_skillData["buff1id"])
			local staticBuffData = gameData.getDataFromCSV("Jinengbuff", {["buffid"] = buffid} )
			local duration = staticBuffData.duration / 1000.0
			local effect_spine  = self:getEffectSpineFromCache("res/spine/effect/040/atk0/atk0_bao")
			target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})
			effect_spine:setAnimation(0,"atk",false)	
			performWithDelay(effect_spine,function( )
				effect_spine:removeFromParent()
			end,0.6666)

			local atk0_di_spine = self:getEffectSpineFromCache("res/spine/effect/040/atk0/atk0_di")
			target:addNodeForSlot({node = atk0_di_spine , slotName = "root" , zorder = 10})	
			atk0_di_spine:setAnimation(0,"animation",false)

			performWithDelay(effect_spine,function( )
				atk0_di_spine:removeFromParent()
			end,0.4)
		end--[[--for end]]
		self:doHurt({skill = _skillData,targets = _targetList})
	end
end

function Snyx:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snyx:create(params)
	return Snyx.new(params)
end

return Snyx