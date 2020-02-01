
--[[35 杨玉环]]
local YangYuHuan = class("YangYuHuan", function ( params )
	local animal = Character:_create(params)
	return animal
end)
--[[
	宝冠雄鹿
	atk: 掐腰前垂小铃铛
	atk1: 自我陶醉，摇晃铃铛
	atk2: 释放铃铛炮
	atk0: 施放铃铛阵
]]
function YangYuHuan:_initCache()
	XTHD.createSprite("res/spine/effect/035/atk_guiji.png")
	self:getEffectSpineFromCache("res/spine/effect/035/atk0/atk0")
	self:getEffectSpineFromCache("res/spine/effect/035/atk0_1/atk0_1")
	self:getEffectSpineFromCache("res/spine/effect/035/atk0_2/atk0_2")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/035/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/035/atkd/atkd")
			XTHD.createSprite("res/spine/effect/035/atk2guiji.png")
		end
	end
end

function YangYuHuan:doAnimationEvent(event)
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
		local target = selectedTargets[1]
		local endPos = target:getSlotPositionInWorld("midPoint")
	
		local feibiao_sp = XTHD.createSprite("res/spine/effect/035/atk_guiji.png") 
		feibiao_sp:setScale(self:getScaleY())

		local _fireSlotNodePos = self:getSlotPositionInWorld("firePoint")
		feibiao_sp:setPosition( _fireSlotNodePos )

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = feibiao_sp},
		})
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
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/035/atkd/atkd")
			target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})				
			effect_spine:setAnimation(0,"atkd",false)
			performWithDelay(effect_spine,function()
				effect_spine:removeFromParent()
				end, 2)

			self:doHurt({skill = _skillData,targets = _targetList})
		end) , cc.RemoveSelf:create(true)))
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
		local _target_pos = cc.p(0,0)
		local _zorder = 0
		local target = selectedTargets[1]
		local _target_pos = target:getSlotPositionInWorld("root")
		
		
		local effect_spine = self:getEffectSpineFromCache("res/spine/effect/035/atk1/atk1")
		effect_spine:setPosition(_target_pos)
		effect_spine:setAnimation(0,"atk1",false)
		performWithDelay(effect_spine,function()
			effect_spine:removeFromParent()
			end, 2)

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = effect_spine},
		})

		self:doHurt({skill = _skillData,targets = _targetList})
	elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
		local target = selectedTargets[1]
		-- 预留设置打击对方
		local feibiao_sp = XTHDArrow:createWithParams({fileName = "res/spine/effect/035/atk2guiji.png" , autoRotate = false})
		feibiao_sp:setScale(self:getScaleY())
		local _fireSlotNodePos = self:getSlotPositionInWorld("firePoint");
		feibiao_sp:setPosition( _fireSlotNodePos );

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = feibiao_sp},
		})
		-- 敌人
		local _TarSlotNodePos = target:getSlotPositionInWorld("midPoint")
		--计算角度
		-- 判定斜率,非弓箭状态
		local deltaY = _TarSlotNodePos.y - _fireSlotNodePos.y;
		local deltaX = _TarSlotNodePos.x - _fireSlotNodePos.x;
		local angel = deltaX > 0 and 0 or 180;
		local K = deltaY / deltaX;
		if deltaX ~= 0 then
			feibiao_sp:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
		end

		local dt = getDynamicTime(_fireSlotNodePos.x-_TarSlotNodePos.x,1000)
		feibiao_sp:runAction(cc.Sequence:create(cc.MoveTo:create(dt,_TarSlotNodePos),cc.CallFunc:create(function()
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/035/atkd/atkd")
			target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})				
			effect_spine:setAnimation(0,"atkd",false)
			performWithDelay(effect_spine,function()
				effect_spine:removeFromParent()
				end, 2)
		end) , cc.RemoveSelf:create(true)))
		
		self:doHurt({skill = _skillData,targets = _targetList})
	elseif name == "onAtk0_1Done" then
	    local winWidth = cc.Director:getInstance():getWinSize().width
	    local winHeight = cc.Director:getInstance():getWinSize().height
		local special_effect = self:getEffectSpineFromCache("res/spine/effect/035/atk0_2/atk0_2", 1.0)
		special_effect:setPosition(winWidth/2, winHeight / 2)
		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = special_effect},
		})
		special_effect:setAnimation(0,"atk0",false)
		performWithDelay(special_effect,function()
			special_effect:removeFromParent()
		end, 3)

		for k,target in pairs(_targetList) do
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/035/atk0/atk0")

			local _target_pos = target:getSlotPositionInWorld("root")
			effect_spine:setPosition(_target_pos)
						
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = effect_spine,zorder = target:getLocalZOrder()},
			})
			effect_spine:setAnimation(0,"atk0",false)
			performWithDelay(effect_spine,function()
				effect_spine:removeFromParent()
			end, 2)
		end--[[--for end]]
		self:doHurt({skill = _skillData,targets = _targetList})
	end
end


function YangYuHuan:doAnimationStart(event)
    local winWidth = cc.Director:getInstance():getWinSize().width
    local winHeight = cc.Director:getInstance():getWinSize().height
	if event.animation == BATTLE_ANIMATION_ACTION.SUPER then
		local effect_atk0_1 = self:getEffectSpineFromCache("res/spine/effect/035/atk0_1/atk0_1", 1.0)
		effect_atk0_1:setPosition(winWidth/2, winHeight/2)

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = effect_atk0_1,zorder = 11},
		})
		effect_atk0_1:setAnimation(0,"atk0",true)
		performWithDelay(effect_atk0_1,function()
			effect_atk0_1:removeFromParent()
		end, 3)

		local _animalName = self:getNowAniName()
		local _skillData 	  = self:getSkillByAction(_animalName)
		XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
	end
end

function YangYuHuan:create(params)
	return YangYuHuan.new(params)
end

return YangYuHuan