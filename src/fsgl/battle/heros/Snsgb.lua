--[[--少年申公豹
heroId : 84
]]
local Snsgb = class("Snsgb", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function Snsgb:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/036/atk/atk")
	self:getEffectSpineFromCache("res/spine/effect/036/atk0/atk0")
	self:getEffectSpineFromCache("res/spine/effect/036/atk0/atk0_1")
	self:getEffectSpineFromCache("res/spine/effect/036/atk0/atk0_2")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/036/atk2/atk2_1")
			self:getEffectSpineFromCache("res/spine/effect/036/atk2/atk2_2")
		end
	end
end
--[[--
	atk: 帧事件 onAtkDone 触发 受击特效 atk  (特效对其人物 中心点）
	atk1: 帧事件 onAtk1Done 触发 受击
	atk2: 帧事件 onAtk2Done  触发 受击特效atk2_1（特效对其人物ROOT 点）  并触发掉血特效 atk2_2 （特效对其人物ROOT 点）每秒播放一次 持续四秒
	atk0: 帧事件 onAtk0Begin 触发黑屏结束   onAtk0Done触发 特效atk0 （屏幕中心） atk0中 碰撞盒 bx 触发敌方受击特效 atk0_2   己方触发特效atk0_1
]]
function Snsgb:doAnimationEvent(event)
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getSelectedTargets(_animalName)
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
		local x,y = self:getPosition()
		local firstTarget = targets[1]
		local move = 0
		if x < firstTarget:getPositionX() then
			move = math.abs(_skillData.attackrange)
		else
			move = -math.abs(_skillData.attackrange)
		end
		local time = 0.75
		local move1 = cc.MoveBy:create(time,cc.p(move, 0))
		local move2 = cc.MoveBy:create(time,cc.p(-move, 0))
		self:runAction(cc.Sequence:create(move1,move2))
	else
		--[[对应技能的攻击次数+1]]
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				local faceDirection = self:getFaceDirection()
				local __sp = self:getEffectSpineFromCache("res/spine/effect/036/atk0/atk0", 1.0)
				__sp:setAnimation(0,"atk0",false)
				local _spScale = 1
				if self:getScaleX() < 0 then
					_spScale = -1
				end
				__sp:setScaleX(_spScale)
				local _box = self:getBox()
				__sp:setPosition(_box.x,_box.y+_box.height+20)

				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = __sp, zorder = -1},
				})
				local _action = cc.Sequence:create( cc.DelayTime:create(2.6666), cc.RemoveSelf:create(true))
				__sp:runAction( _action )
			elseif name == "onAtk0_1Done" then
				--左是我方，右是敌方。碰撞过以后不会再发生碰撞。标记
				--left
				local _spScale = 1
				if self:getScaleX() < 0 then
					_spScale = -1
				end
				local _sideName = BATTLE_SIDE.LEFT
				if self:getSide() == BATTLE_SIDE.RIGHT then
					_sideName = BATTLE_SIDE.RIGHT
				end
				local sidedata = {side = _sideName}
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
					data = sidedata,
				})
				local _leftTargets = sidedata.team
				--right
				local _rightTargets = targets
				for left_k,left_v in pairs(_leftTargets) do
					if left_v:isAlive() == true then
						local _targetMidNode = left_v:getNodeForSlot("midPoint")
						local _targetMidWorldPos = _targetMidNode:convertToWorldSpace(cc.p(0.5, 0.5))
						local _effectsp = self:getEffectSpineFromCache("res/spine/effect/036/atk0/atk0_1")
						_effectsp:setAnimation(0,"atk0_1",false)
						_effectsp:setScaleX(_spScale * math.abs(left_v:getScaleX()))
						_effectsp:setScaleY(left_v:getScaleY())
						local _targetPos = left_v:getSlotPositionInWorld("root")
						_effectsp:setPosition(_targetPos.x, _targetPos.y)

						XTHD.dispatchEvent({
							name = EVENT_NAME_BATTLE_PLAY_EFFECT,
							data = {node = _effectsp,zorder = left_v:getLocalZOrder()},
						})
						performWithDelay(_effectsp,function()
							_effectsp:removeFromParent()
						end,2.1333)
						
					end
				end
				for right_k,right_v in pairs(_rightTargets) do
					if right_v:isAlive() == true then
						local _targetMidNode = right_v:getNodeForSlot("midPoint")
						local _targetMidWorldPos = _targetMidNode:convertToWorldSpace(cc.p(0.5, 0.5))
						local _effectsp = self:getEffectSpineFromCache("res/spine/effect/036/atk0/atk0_2")
						_effectsp:setAnimation(0,"atk0_1",false)
						_effectsp:setScaleX(_spScale * math.abs(right_v:getScaleX()))
						_effectsp:setScaleY(right_v:getScaleY())
						local _targetPos = right_v:getSlotPositionInWorld("root")
						_effectsp:setPosition(_targetPos.x, _targetPos.y)
						self:doHurt({skill = _skillData,targets = {[1]=right_v}})
						XTHD.dispatchEvent({
							name = EVENT_NAME_BATTLE_PLAY_EFFECT,
							data = {node = _effectsp,zorder = right_v:getLocalZOrder()},
						})
						performWithDelay(_effectsp,function()
							_effectsp:removeFromParent()
						end,2.2666)
					end					
				end

				
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				-- atk2: 帧事件 onAtk2Done  触发 受击特效atk2_1（特效对其人物ROOT 点）  并触发掉血特效 atk2_2 （特效对其人物ROOT 点）每秒播放一次 持续四秒

				local effect_sp = self:getEffectSpineFromCache("res/spine/effect/036/atk2/atk2_1")
			 	targets[1]:addNodeForSlot({node = effect_sp , slotName = "root" , zorder = -1})
				-- if targets[1]:getScaleX() < 0 then
					effect_sp:setScaleX(-1*effect_sp:getScaleX())
				-- end

				effect_sp:setAnimation(0,"atk0_1",false)
				performWithDelay(effect_sp,function()
					effect_sp:removeFromParent()
				end,1.4666)
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
				local effect_sp = self:getEffectSpineFromCache("res/spine/effect/036/atk/atk")
				targets[1]:addNodeForSlot({node = effect_sp , slotName = "midPoint" , zorder = 10})
				-- if targets[1]:getScaleX() < 0 then
					effect_sp:setScaleX(-1*effect_sp:getScaleX())
				-- end
				

				effect_sp:setAnimation(0,"atk0_1",false)
				performWithDelay(effect_sp,function()
					effect_sp:removeFromParent()
				end,0.6333)
				self:doHurt({skill = _skillData,targets = targets})
			end
		end--[[if end]]
		
	end

end

function Snsgb:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snsgb:create(params)
	return Snsgb.new(params)
end

return Snsgb