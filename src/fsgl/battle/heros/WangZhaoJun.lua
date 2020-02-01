--[[--27 王昭君]]
local WangZhaoJun = class("WangZhaoJun", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function WangZhaoJun:_initCache()
	XTHD.createSprite("res/spine/effect/027/zidan.png")
	self:getEffectSpineFromCache("res/spine/effect/027/atk0/atk0")
	self:getEffectSpineFromCache("res/spine/effect/027/atk0/atk0_1")
	for key,value in pairs(self:getSkills()) do
        value.level=value.level or 0
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/027/atk1/atk1")
			self:getEffectSpineFromCache("res/spine/effect/027/atk1/atk1_1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/027/atk2/atk2")
			self:getEffectSpineFromCache("res/spine/effect/027/atk2/atk2_1")
		end
	end

end

function WangZhaoJun:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getSelectedTargets(_animalName)
	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		self:doHurt({skill = _skillData,targets = targets})
	else
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtkDone then
				for k,target in pairs(targets) do
					local biao = XTHDArrow:createWithParams({fileName = "res/spine/effect/027/zidan.png" , autoRotate = true})
					biao:setScale(self:getScaleY())
					local original_pos = self:getSlotPositionInWorld("firePoint")
					biao:setPosition(original_pos.x, original_pos.y)

					local _target_pos = target:getSlotPositionInWorld("midPoint")
					local dt  =  getDynamicTime(math.abs(_target_pos.x-original_pos.x), 1200);

					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = biao, zorder = target:getLocalZOrder()},
					})

					biao:runAction(cc.Sequence:create(cc.MoveTo:create(dt,_target_pos),cc.CallFunc:create(function()
						local _tmp_targets = {}
						_tmp_targets[#_tmp_targets + 1] = target
						self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})
					end) ,cc.RemoveSelf:create(true)))
				end--[[for end]]
			elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				-- local _target_pos = self:getSlotPositionInWorld("root")
				--[[--酷炫的大翅膀放在身后]]
				local skill_effect = self:getEffectSpineFromCache("res/spine/effect/027/atk0/atk0")
				self:addNodeForSlot({node = skill_effect , slotName = "root" , zorder = -10})
				skill_effect:setAnimation(0,"animation",false)
				performWithDelay(skill_effect,function()
					
					skill_effect:removeFromParent()
					
				end,5)
				-- self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				-- local _tar = targets[1]
				for i=1,#targets do
					local _tar = targets[i]
					if _tar and _tar:isAlive() then
						local skill_effect = self:getEffectSpineFromCache("res/spine/effect/027/atk2/atk2")
						_tar:addNodeForSlot({node = skill_effect , slotName = "midPoint" , zorder = 10})
						skill_effect:setAnimation(0,"animation",false)
						performWithDelay(skill_effect,function()
							
							skill_effect:removeFromParent()

						end,0.9666)

					end
				end
				
			elseif name == "onAtk2_1Done" then	
				-- for i=1,#targets do
				-- 	local _tar = targets[i]
				-- 	if _tar and _tar:isAlive() then
				-- 		local buffid = tonumber(_skillData["buff1id"])
				-- 		local staticBuffData = gameData.getDataFromCSV("Jinengbuff", {["buffid"] = buffid} )
				-- 		local duration = staticBuffData.duration / 1000.0
				-- 		local skill_effect = self:getEffectSpineFromCache("res/spine/effect/027/atk2/atk2_1")
				-- 		_tar:addNodeForSlot({node = skill_effect , slotName = "midPoint" , zorder = 10})
				-- 		skill_effect:setAnimation(0,"animation",true)
				-- 		performWithDelay(skill_effect,function()
				-- 			skill_effect:removeFromParent()
				-- 		end, duration)
				-- 	end
				-- end
				self:doHurt({skill = _skillData,targets = targets})
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
		
	end

end

function WangZhaoJun:doAnimationStart(event)
	--[[记录当前的技能数据]]
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	local targets = self:getSelectedTargets(_animalName)

	if event.animation == BATTLE_ANIMATION_ACTION.ATK1 then
		local scene = cc.Director:getInstance():getRunningScene()
		targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
		local faceDirection = self:getFaceDirection()
		
		local __sp = self:getEffectSpineFromCache("res/spine/effect/027/atk1/atk1_1")
		local _sc = self:getScaleX() > 0 and 1 or -1
		__sp:setScaleX(_sc* __sp:getScaleX())

		local shadowNodePos = self:getSlotPositionInWorld("root")
		__sp:setPosition(shadowNodePos.x, shadowNodePos.y)

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = __sp},
		})

		__sp:setAnimation(0,"atk1",false)

		local _temp_targets = {}
		local _targets = {}
		
		--[[飞轮时刻检测是否有敌人进入攻击范围内]]
		schedule(__sp, function(dt)
			if targets then
				for k,target in pairs(targets) do
					--[[如果敌人没有死亡，就判读是否受到飞轮的攻击]]
					if target:isAlive() == true then
						-- local _gearNodePos = __sp:getSlotPositionInWorld("sbox")

						-- local _targetMidNodePos = target:getSlotPositionInWorld("midPoint");

						local _gear = __sp:getNodeForSlot("sbox")
						local _gearWorldPos = _gear:convertToWorldSpace(cc.p(0.5, 0.5))
						local _gearNodePos = scene:convertToNodeSpace( _gearWorldPos )

						-- local _targetMidNode = target:getNodeForSlot("midPoint");
						-- local _targetMidWorldPos = _targetMidNode:convertToWorldSpace(cc.p(0.5, 0.5))
						local _targetMidNodePos = target:getSlotPositionInWorld("midPoint")


						local x = 0
						if faceDirection == BATTLE_DIRECTION.LEFT then
							if _targetMidNodePos.x > _gearNodePos.x and _temp_targets[target:getStandId()] == nil then
								x = -30
								_temp_targets[target:getStandId()] = target
								local _tmp_targets = {}
								_tmp_targets[#_tmp_targets + 1] = target
								self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})


								local baodian = self:getEffectSpineFromCache("res/spine/effect/027/atk1/atk1")
								baodian:setPosition(_targetMidNodePos.x,_targetMidNodePos.y)
								XTHD.dispatchEvent({
									name = EVENT_NAME_BATTLE_PLAY_EFFECT,
									data = {node = baodian},
								})
								baodian:setAnimation(0,"animation",false)
								
							end
						elseif faceDirection == BATTLE_DIRECTION.RIGHT and _temp_targets[target:getStandId()] == nil then
							if _targetMidNodePos.x < _gearNodePos.x then
								x = 30
								_temp_targets[target:getStandId()] = target
								local _tmp_targets = {}
								_tmp_targets[#_tmp_targets + 1] = target
								self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})


								
								local baodian = self:getEffectSpineFromCache("res/spine/effect/027/atk1/atk1")
								baodian:setPosition(_targetMidNodePos.x,_targetMidNodePos.y)
								XTHD.dispatchEvent({
									name = EVENT_NAME_BATTLE_PLAY_EFFECT,
									data = {node = baodian},
								})
								baodian:setAnimation(0,"animation",false)
							end
						end
					end
				end--[[for end]]
			end
			
		end, 1 / 60)

		local _action = cc.Sequence:create( cc.DelayTime:create(4), cc.RemoveSelf:create(true))
		__sp:runAction( _action )
	end

	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function WangZhaoJun:create(params)
	return WangZhaoJun.new(params)
end

return WangZhaoJun