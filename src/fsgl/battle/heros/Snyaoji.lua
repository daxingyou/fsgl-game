--少年瑶姬94

local Snyaoji = class("Snyaoji", function ( params )
	local animal = Character:_create(params)
	return animal
end)
--[[
	atk：左右挥舞
	atk1：蹦起下挥
	atk2：飞起消失，再出现
	atk0:自我陶醉，冉冉升起
		拆分 atk0,atkd0
	        atk2,狂魔乱舞的赶脚(怒抓敌人，挠烂)

	onAtk0Done:开始播放动画029atk0   root点与螳螂对齐
	onAtk01Done:开始播放动画029atk01   root点与敌人对齐
	onAtk0Done2:大招的掉血事件
	onAtk2Done:开始播放029atk2  			ok
	onAtk2Done2：技能2掉血事件  共5次 		ok
]]


function Snyaoji:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/029/atk0/029atk01")
	-- dump(self:getSkills())
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			-- self:getEffectSpineFromCache("res/spine/effect/029/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/029/atk2/029atk2")
		end
	end
end

function Snyaoji:doAnimationEvent(event)
	
	local name 			= event.eventData.name
	local _animalName = self:getNowAniName()
    local _skillData 	= self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getNowSkillTarges(_skillData)--self:getSelectedTargets(_animalName)
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else
		--[[对应技能的攻击次数+1]]
		targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
		if targets ~= nil then

			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtkDone or name == "onAtkDone2" then
				local _spPath = "res/spine/effect/029/biao1.png"
				if name == "onAtkDone2" then
					_spPath = "res/spine/effect/029/biao2.png"
				end
				local arrow_spine = XTHD.createSprite(_spPath)
				-- self:getEffectSpineFromCache("res/spine/effect/029/atk/atk", 1.0)
				local _targetSlot = self:getSlotPositionInWorld("firePoint")
				
				arrow_spine:setScale(self:getScaleY())
				-- if self:getScaleX()<0 then
				-- 	arrow_spine:setScaleX(-1*arrow_spine:getScaleX())
				-- end
				local endPos = targets[1]:getSlotPositionInWorld("midPoint")
				local deltaY = endPos.y - _targetSlot.y;
				local deltaX = endPos.x - _targetSlot.x;
				local angel = deltaX > 0 and 0 or 180;
				local K = deltaY / deltaX;
				if deltaX ~= 0 then
					arrow_spine:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
				end
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = arrow_spine, zorder = 10},
				})
				arrow_spine:setPosition(cc.p(_targetSlot.x, _targetSlot.y))
				local pos_delta = cc.pGetDistance(endPos, _targetSlot)
				local dt = getDynamicTime(pos_delta, 1000)
				arrow_spine:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
							arrow_spine:removeFromParent()
							self:doHurt({skill = _skillData,targets = targets})
						end)))
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				local arrow_sp = XTHD.createSprite("res/spine/effect/029/atk1/atk1.png")
				local _targetSlot = self:getSlotPositionInWorld("firePoint")
				arrow_sp:setPosition(cc.p(_targetSlot.x, _targetSlot.y))
				-- if self:getScaleX()<0 then
				-- 	arrow_sp:setScaleX(-1*arrow_sp:getScaleX())
				-- end
				local endPos = targets[1]:getSlotPositionInWorld("midPoint")
				local deltaY = endPos.y - _targetSlot.y;
				local deltaX = endPos.x - _targetSlot.x;
				local angel = deltaX > 0 and 0 or 180;
				local K = deltaY / deltaX;
				if deltaX ~= 0 then
					arrow_sp:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
				end

				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = arrow_sp, zorder = 10},
				})
				local pos_delta = cc.pGetDistance(endPos, _targetSlot)
				local dt = getDynamicTime(pos_delta, 1000)
				arrow_sp:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
						arrow_sp:removeFromParent()
						self:doHurt({skill = _skillData,targets = targets})
						local _data = {
							file = "res/spine/effect/029/atk1/atk11", 
							name = "100", 
							startIndex = 1,
							endIndex = 12,
							perUnit = 0.1,
							isCircle = false
						 }
						local clicked_sp = XTHD.createSpriteFrameSp(_data)
						clicked_sp:setScale(self:getScaleY()*2)
						targets[1]:addNodeForSlot({node = clicked_sp , slotName = "midPoint" , zorder = 10})
					end)))				
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				local target = targets[1]
				local _target_pos = target:getSlotPositionInWorld("root")
				local effect_spine = self:getEffectSpineFromCache("res/spine/effect/029/atk2/029atk2", 1.0)
				effect_spine:setPosition(_target_pos)
				effect_spine:setAnimation(0,"atk2",false)
				performWithDelay(effect_spine,function()
					effect_spine:removeFromParent()
					end, 3)

				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = effect_spine},
				})
			elseif name == "onAtk2Done2" then
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == "chuxian" then
				-- self:setVisible(true)
				self:setTargetable(true)
				self:setHurtable(true)
			elseif name == "xiaoshi" then
				-- self:setVisible(false)
				self:setHurtable(false)
				self:setTargetable(false)
			elseif name == "onAtk01Done" then
				local target = targets[1]
				local _target_pos = target:getSlotPositionInWorld("root")
				local _effect_spine = self:getEffectSpineFromCache("res/spine/effect/029/atk0/029atk01")

				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = _effect_spine},
				})
				_effect_spine:setPosition(_target_pos)
				_effect_spine:setAnimation(0,"atk0",false)
				performWithDelay(_effect_spine,function()
					_effect_spine:removeFromParent()
					end, 3)
			elseif name == "onAtk0Done2" then
				if self:getType() == ANIMAL_TYPE.PLAYER then
					XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
					})
				end
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				local target = targets[1]
				local _target_pos = self:getSlotPositionInWorld("root")

				local effect_spine = self:getEffectSpineFromCache("res/spine/effect/029/atk0/029atk0")
				effect_spine:setScaleX(self:getScaleX())
				effect_spine:setPosition(_target_pos.x, _target_pos.y)
				effect_spine:setAnimation(0,"atk0",false)

				performWithDelay(effect_spine,function()
					effect_spine:removeFromParent()
					end, 3)

				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = effect_spine},
				})
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
		
	end

end

function Snyaoji:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snyaoji:create(params)
	return Snyaoji.new(params)
end

return Snyaoji