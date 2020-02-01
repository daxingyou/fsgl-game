--[[--姜子牙]]
local JiangZiYa = class("JiangZiYa", function ( params )
	local animal = Character:_create(params)
	return animal
end)
--[[
	atk0: 
	atk1: 抬腿伸手杖
	atk2: 抬腿旋转手杖(伴随光效)，然后指向敌人 ，会飞出小火苗
	atk0: 打坐升起，(伴随莲台旋转)
]]

function JiangZiYa:_initCache()
	XTHD.createSprite("res/spine/effect/015/atk_zidan.png")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/015/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			for i=1,4 do
				XTHD.createSprite("res/spine/effect/015/atk2Bullet/zidan_" .. i .. ".png")
			end
			self:getEffectSpineFromCache("res/spine/effect/015/atk2")
			self:getEffectSpineFromCache("res/spine/effect/015/atk21")
		end
	end
end

function JiangZiYa:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local selectedTargets = self:getSelectedTargets(_animalName)
	local targets = self:getHurtableTargets({selectedTargets = selectedTargets
		,skill=_skillData})
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				local target = targets[1]
				if target and target:isAlive() then
					local root = target:getSlotPositionInWorld("root")
					local cover_spine = self:getEffectSpineFromCache("res/spine/effect/015/atk1", 1.0)
					cover_spine:setPosition(root)
					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = cover_spine},
					})
					cover_spine:setAnimation(0,"atk0",false)
					performWithDelay(cover_spine,function()
						cover_spine:removeFromParent() --动作执行结束，移除自身
						end, 0.6)
				end
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
				local target = targets[1]
				if target and target:isAlive() then
					local _arrow = XTHD.createSprite("res/spine/effect/015/atk_zidan.png")
					--起始位置
					local _targetSlot = self:getSlotPositionInWorld("firePoint")

					_arrow:setPosition(_targetSlot.x, _targetSlot.y)
					--目标位置
					local endPos = target:getSlotPositionInWorld("midPoint")

					local pos_delta = cc.pGetDistance(endPos, _targetSlot)
					local dt = getDynamicTime(pos_delta, 1000)*1.25

					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = _arrow},
					})

					_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
							_arrow:removeFromParent()
							--[[攻击的帧事件，此时敌人应该出发受击操作]]
							self:doHurt({skill = _skillData,targets = targets})
					end)))
				end
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				local target = targets[1]
				if target and target:isAlive() then
					--起始位置
					local _targetSlot = self:getSlotPositionInWorld("firePoint")
					--目标位置
					local endPos = target:getSlotPositionInWorld("midPoint")

					local _arrow = XTHD.createSprite()
					local _action = getAnimation("res/spine/effect/015/atk2Bullet/zidan_", 1, 4, 0.03)
					_arrow:setScale(2)
	                _arrow:runAction(cc.RepeatForever:create(_action))
	                _arrow:setPosition(_targetSlot.x, _targetSlot.y)
	                XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = _arrow},
					})
					local pos_delta = cc.pGetDistance(endPos, _targetSlot)
					local dt = getDynamicTime(pos_delta, 1000)*1.25

					_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
							_arrow:removeFromParent()
							local _effect_spine = self:getEffectSpineFromCache("res/spine/effect/015/atk21")
							target:addNodeForSlot({node = _effect_spine , slotName = "midPoint", zorder = 10})	
							-- _effect_spine:setScale(1.0/target:getScaleY())
							_effect_spine:setAnimation(0,"atk2",false)
							performWithDelay(_effect_spine,function()
								_effect_spine:removeFromParent()
							end, 0.666)
							--[[攻击的帧事件，此时敌人应该出发受击操作]]
							self:doHurt({skill = _skillData,targets = targets})
					end)))
				end
			elseif name == "onAtk0Done_1" then
				for k,target in pairs(targets) do
					local shadow_spine = target:getEffectSpineFromCache("res/spine/effect/015/atk0")
					target:addNodeForSlot({node = shadow_spine , slotName = "root" , zorder = -10})
					-- shadow_spine:setScale(1.0 / target:getScaleY())
					
					shadow_spine:setAnimation(0,"atk0",false)
					performWithDelay(shadow_spine,function()
						shadow_spine:removeFromParent() --动作执行结束，移除自身
					end, 3)
				end
			elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				self:doHurt({skill = _skillData,targets = targets})
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
	end

end

function JiangZiYa:create(params)
	return JiangZiYa.new(params)
end

function JiangZiYa:doAnimationStart(event)
	if event.animation == BATTLE_ANIMATION_ACTION.ATK2 then
		local shadow_spine = self:getEffectSpineFromCache("res/spine/effect/015/atk2")
		self:addNodeForSlot({node = shadow_spine , slotName = "root" , zorder = 10})
		shadow_spine:setAnimation(0,"atk2",false)
		performWithDelay(shadow_spine,function()
			shadow_spine:removeFromParent() --动作执行结束，移除自身
		end, 0.9)
	end

	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

return JiangZiYa