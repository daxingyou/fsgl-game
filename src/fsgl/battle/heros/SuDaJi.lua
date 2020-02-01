--[[--苏妲己30]]
local SuDaJi = class("SuDaJi", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function SuDaJi:ctor()
	self:getSlotPositionInWorld("abc1")
	self:getSlotPositionInWorld("abc2")
end
--[[
	老鼠
	atk	:小手飞轮
	atk1:铁片快镖
	atk2:群伤药瓶
	atk0:必杀巨轮
]]
function SuDaJi:_initCache()

	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/030/atk1/atk1")	
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/030/atk2/atk2_1")
			self:getEffectSpineFromCache("res/spine/effect/030/atk2/atk2_2")
		end
	end	
	self:getEffectSpineFromCache("res/spine/effect/030/atk/atkzidan")
	self:getEffectSpineFromCache("res/spine/effect/030/atk0/atk0_4")
	self:getEffectSpineFromCache("res/spine/effect/030/atk0/atk0_1")
end

function SuDaJi:doAnimationEvent(event)
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
			--目标位置
			local endPos = _target_enemy:getSlotPositionInWorld("midPoint")
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/030/atk/atkzidan")
			local original_pos = self:getSlotPositionInWorld("firePoint")
			effect_spine:setPosition(original_pos)

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = effect_spine},
			})

			effect_spine:setAnimation(0,"atk",false)
			local dt = getDynamicTime(endPos.x-original_pos.x,1000)
			effect_spine:runAction(cc.Sequence:create(cc.MoveTo:create(dt,cc.p(endPos)),cc.CallFunc:create(function()
				self:doHurt({skill = _skillData,targets = _targetList})
			end),cc.FadeOut:create(0.2),cc.CallFunc:create(function()
				effect_spine:removeFromParent()
			end)))
		end
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
		for k,target in pairs(_targetList) do
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/030/atk1/atk1")	
			target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})				
			effect_spine:setAnimation(0,"atk",false)
			performWithDelay(effect_spine,function( )
				effect_spine:removeFromParent()
			end,2.0)
		end--[[--for end]]
		self:doHurt({skill = _skillData,targets = _targetList})
	elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done and selectedTargets[1]:isAlive() == true then
		--[[--第一个目标]]
		local target = selectedTargets[1]
		local endPos = target:getSlotPositionInWorld("root")


		local feibiao_sp = XTHDArrow:createWithParams({fileName = "res/spine/effect/030/atk1/laoshuatk1zidan.png" , autoRotate = true})
		feibiao_sp:setScale(self:getScaleY())
		local _targetSlot= self:getSlotPositionInWorld("firePoint")
		--目标位置
		local pos_delta = getDistance( endPos, _targetSlot );

		local bezier = nil
		if pos_delta < 300 then
			bezier  ={
		        cc.p((endPos.x-_targetSlot.x)/4*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+100),
				cc.p((endPos.x-_targetSlot.x)/2*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+50),
				cc.p(endPos.x, endPos.y)
	    	}
		else
			bezier  ={
		        cc.p((endPos.x-_targetSlot.x)/4*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+100 + 50),
				cc.p((endPos.x-_targetSlot.x)/2*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+50 + 50),
				cc.p(endPos.x, endPos.y)
	    	}
		end
		local dt = getDynamicTime(pos_delta, 1000)*1.25;
		local actionBezier = cc.BezierTo:create(dt, bezier)
		feibiao_sp:setPosition(_targetSlot)
		

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = feibiao_sp},
		})

		feibiao_sp:runAction(cc.Sequence:create(cc.Spawn:create(actionBezier, cc.RotateBy:create(dt, 270 ) ),cc.CallFunc:create(function()
		 	local effect_spine = self:getEffectSpineFromCache("res/spine/effect/030/atk2/atk2_1", 1.0)
			effect_spine:setPosition(feibiao_sp:getPosition())

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = effect_spine},
			})

			effect_spine:setAnimation(0,"atk",false)
			performWithDelay(effect_spine,function()
				effect_spine:removeFromParent()
			end, 2)

			self:doHurt({skill = _skillData,targets = _targetList})

		end),cc.RemoveSelf:create(true)))

	elseif name == BATTLE_ANIMATION_EVENT.onAtk3Done then--[[--友方加buff]]
	elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
		local target = selectedTargets[1]
		local _targetPos = target:getSlotPositionInWorld("midPoint")
		for attackidx=1,2 do
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/030/atk0/atk0_4")
			-- local _original_pos = self:getSlotPositionInWorld("abc"..tostring(attackidx))
			local _original_pos = self:getSlotPositionInWorld("xxxx5")
			effect_spine:setPosition(_original_pos)
			effect_spine:setAnimation(0,"atk",true)
			
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = effect_spine},
			})

			local dt = getDynamicTime(_targetPos.x-_original_pos.x,1200)
			effect_spine:runAction(cc.Sequence:create(cc.MoveTo:create(dt,_targetPos),cc.CallFunc:create(function()
				effect_spine:setVisible(false)
				if  attackidx == 1 then
					self:doHurt({skill = _skillData,targets = _targetList})
				else
					local brust_effect = self:getEffectSpineFromCache("res/spine/effect/030/atk0/atk0_1")
					brust_effect:setPosition(effect_spine:getPosition())
					brust_effect:setAnimation(0,"atk",false)
					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = brust_effect},
					})
					performWithDelay(brust_effect,function()
						brust_effect:removeFromParent()
					end, 2)
				end
			end) , cc.RemoveSelf:create(true)))
		end

	end
end

function SuDaJi:doSuperAnimationStart(event)
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function SuDaJi:create(params)
	return SuDaJi.new(params)
end

return SuDaJi