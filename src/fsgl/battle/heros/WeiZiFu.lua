-- 卫子夫

local WeiZiFu = class("WeiZiFu", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function WeiZiFu:_initCache()
	XTHD.createSprite("res/spine/effect/046/zidan.png")
	self:getEffectSpineFromCache("res/spine/effect/046/atk0/atk0")
	self:getEffectSpineFromCache("res/spine/effect/046/atk0/atk0_1")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/046/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
		end
	end
end

function WeiZiFu:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getSelectedTargets(_animalName)
	if targets == nil then
		do return end
	end
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
		local target = targets[1]
		local endPos = target:getSlotPositionInWorld("root")
		local effect_sp = self:getEffectSpineFromCache("res/spine/effect/046/atk0/atk0", 1.0)
		effect_sp:setPosition(endPos)

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = effect_sp , zorder = -1},
		})

		effect_sp:setAnimation(0,"atk1",false)
		performWithDelay(effect_sp,function()
			effect_sp:removeFromParent()
		end, 4)
	else
		--[[对应技能的攻击次数+1]]
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if event.eventData.name == "onAtk0_1Done" then
				for k,target in pairs(targets) do
					local effect_spine = self:getEffectSpineFromCache("res/spine/effect/046/atk0/atk0_1")
					target:addNodeForSlot({node = effect_spine , slotName = "root" , zorder = 10})
					effect_spine:setAnimation(0,"atk1",false)
					performWithDelay(effect_spine,function()
						effect_spine:removeFromParent()
					end, 3)
				end--[[for end]]
				self:doHurt({skill = _skillData,targets = targets})				
			elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then	
				local target = targets[1]
				local feibiao_sp = XTHD.createSprite("res/spine/effect/046/zidan.png")
				feibiao_sp:setScale(self:getScaleY())
				feibiao_sp:setAnchorPoint(cc.p(0.9,0.5))
				local _fireSlotNodePos = self:getSlotPositionInWorld("firePoint");
				feibiao_sp:setPosition( _fireSlotNodePos );

				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = feibiao_sp},
				})
				-- 敌人
				local endPos = target:getSlotPositionInWorld("midPoint")
				--计算角度
				-- 判定斜率,非弓箭状态
				local deltaY = endPos.y - _fireSlotNodePos.y;
				local deltaX = endPos.x - _fireSlotNodePos.x;
				local angel = deltaX > 0 and 0 or 180;
				local K = deltaY / deltaX;
				if deltaX ~= 0 then
					feibiao_sp:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
				end

				local dt = getDynamicTime(math.abs(endPos.x - _fireSlotNodePos.x),1000)
				feibiao_sp:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					self:doHurt({skill = _skillData,targets = targets})
				end) , cc.RemoveSelf:create(true)))
			elseif name == BATTLE_ANIMATION_EVENT.onAtk3Done or name == BATTLE_ANIMATION_EVENT.onAtk2Done then

				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then	
				for k,target in pairs(targets) do
					local effect_spine = self:getEffectSpineFromCache("res/spine/effect/046/atk1/atk1")
					target:addNodeForSlot({node = effect_spine , slotName = "root" , zorder = 10})
					local pI = -1
					-- if target:getScaleX() < 0 then
					-- 	pI = -1
					-- end
					effect_spine:setScaleX(pI*effect_spine:getScaleX())
					effect_spine:setAnimation(0,"atk1", false)
					performWithDelay(effect_spine,function()
						effect_spine:removeFromParent()
					end, 0.9666)
				end
			elseif name == "onAtk1_1Done" then	
				self:doHurt({skill = _skillData,targets = targets})
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
		
	end

end

function WeiZiFu:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function WeiZiFu:create(params)
	return WeiZiFu.new(params)
end

return WeiZiFu