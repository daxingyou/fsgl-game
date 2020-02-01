--[[-- 姬发]]
local JiFa = class("JiFa", function ( params )
	local animal = Character:_create(params)
	return animal
end)

--[[--
 atk：直接伸拐杖
 atk1:伸拐杖（duang)带特效
 atk2:推掌

 特效：
 atk0: 字体左飞然后向右飞
 atk2: 猛推一掌
 atk2_1:光圈散开


005 浣熊师傅
atk0 为必杀 
onAtk0_1Done为 触发特效 帧事件   
onAtk0_2Done  触发对方受击帧事件
atk2 技能2
atk2_1为技能2 受击方播放特效  

	
]]
function JiFa:_initCache()
	XTHD.createSprite("res/spine/effect/005/zd.png")
	self:getEffectSpineFromCache("res/spine/effect/005/atk")
	self:getEffectSpineFromCache("res/spine/effect/005/atk0")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/005/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/005/atk2_1")
			self:getEffectSpineFromCache("res/spine/effect/005/atk2_2")
		end
	end
end

function Character:setStatus(status)
	self._status = status
	--[[--如果被眩晕，则移除黑屏，否则被眩晕以后可能会被卡住]]
	if status == BATTLE_STATUS.DIZZ then
		self:_removeSelfDim()
		if self._superEff then
			self._superEff:removeFromParent()
			self._superEff = nil
		end
	elseif status == BATTLE_STATUS.DEAD or status == BATTLE_STATUS.DEFENSE then
		if self._superEff then
			self._superEff:removeFromParent()
			self._superEff = nil
		end
	end
end

function JiFa:doAnimationEvent(event)
	local name = event.eventData.name
	local pName = self:getNowAniName()
	local _skillData = self:getSkillByAction(pName)
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		self._atk0Zhen = 0
		if self._superEff then
			self._superEff:removeFromParent()
			self._superEff = nil
		end
	else
		local targets = self:getSelectedTargets(pName)
		if name == BATTLE_ANIMATION_EVENT.onAtk0Done or name == "onAtk0_3Done" then
			self._atk0Zhen = self._atk0Zhen + 1
			if self._atk0Zhen == 1 then
				local _eff = self:getEffectSpineFromCache("res/spine/effect/005/atk0")
				self._superEff = _eff
				local pos = self:getSlotPositionInWorld("root")
				_eff:setPosition(pos)
				_eff:setAnimation(0, "atk0", false)
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = _eff, zorder = 10},
				})
				if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
					_eff:setScaleX(-1*_eff:getScaleX())
				end
				performWithDelay(_eff,function()
					_eff:removeFromParent()
					self._superEff = nil
				end, 2.3666)
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 30, time = 0.2}
				})
			elseif self._atk0Zhen == 5 then
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 30, time = 0.6}
				})
				self._atk0Zhen = 0
			else
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 10}
				})
			end
		end
		if targets ~= nil then
			if name == BATTLE_ANIMATION_EVENT.onAtkDone then
				for k,_target_enemy in pairs(targets) do
					local _arrow = XTHD.createSprite("res/spine/effect/005/zd.png")
					_arrow:setScale(self:getScaleY())
					--起始位置
					local _targetSlot = self:getSlotPositionInWorld("firePoint")
					_arrow:setPosition(_targetSlot.x, _targetSlot.y)
					--目标位置
					local endPos = _target_enemy:getSlotPositionInWorld("midPoint")

					local pos_delta = cc.pGetDistance(endPos, _targetSlot)
					local dt = getDynamicTime(pos_delta, 1000)*1.25

					if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
						_arrow:setScaleX(-1*_arrow:getScaleX())
					end

					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = _arrow,spine = self},
					})

					_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
							_arrow:removeFromParent()

							local effect_spine = self:getEffectSpineFromCache("res/spine/effect/005/atk")
							_target_enemy:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder =10})
							effect_spine:setAnimation(0, "atk1", false)
							
							performWithDelay(effect_spine,function()
								effect_spine:removeFromParent()
							end,0.2666)

							local _tmp_targets = {}
							_tmp_targets[#_tmp_targets + 1] = _target_enemy
							--[[攻击的帧事件，此时敌人应该出发受击操作]]
							self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})

					end)))
				end--[[--for end]]
			elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				local _targetList = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
				self:doHurt({skill = _skillData,targets = _targetList})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				for k,v in pairs(targets) do
					local effect_spine = self:getEffectSpineFromCache("res/spine/effect/005/atk1")
					v:addNodeForSlot({node = effect_spine , slotName = "root" , zorder = 10})
					effect_spine:setAnimation(0, "atk1", false)
					performWithDelay(effect_spine,function()
						effect_spine:removeFromParent()
					end, 2.2)
				end
			elseif name == "onAtk1_2Done" then
				local _targetList = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
				self:doHurt({skill = _skillData, targets = _targetList})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				local _size = cc.Director:getInstance():getWinSize()
				local _effSpine = self:getEffectSpineFromCache("res/spine/effect/005/atk2_1", 1.0)
				_effSpine:setPosition(_size.width*0.5, _size.height*0.5)
				_effSpine:setAnimation(0, "atk1", false)
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = _effSpine, zorder = 10},
				})
				if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
					_effSpine:setScaleX(-1*_effSpine:getScaleX())
				end
				performWithDelay(_effSpine,function()
					_effSpine:removeFromParent()
				end, 0.9)

				for k,_target_enemy in pairs(targets) do
					local _beatked_spine = self:getEffectSpineFromCache("res/spine/effect/005/atk2_2")
					if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
						_beatked_spine:setScaleX(-1*_beatked_spine:getScaleX())
					end
					local pos = _target_enemy:getSlotPositionInWorld("root")
					_beatked_spine:setPosition(pos)
					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = _beatked_spine, zorder = 10},
					})
					_beatked_spine:setAnimation(0, "atk1", false)
					performWithDelay(_beatked_spine,function()
						_beatked_spine:removeFromParent()
					end, 0.8)
				end
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 20, time = 0.3},
				})
				self:doHurt({skill = _skillData,targets = targets})
			end
		end
	end
end

function JiFa:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function JiFa:create(params)
	return JiFa.new(params)
end

return JiFa