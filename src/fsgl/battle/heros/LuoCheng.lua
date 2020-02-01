--[[--罗成
heroId : 8
]]
local LuoCheng = class("LuoCheng", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function LuoCheng:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/008/atk0/atk0")
	-- for key,value in pairs(self:getSkills()) do
	-- 	if key == "skillid1" and tonumber(value.level) > 0 then
	-- 	elseif key == "skillid2" and tonumber(value.level) > 0 then
	-- 	end
	-- end
end
--[[--
	atk0：root在屏幕中心，根据box 碰撞敌人触发击退等效果
	atk1：蹦起捶地
	atk2：弯腰前顶
]]
function LuoCheng:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getSelectedTargets(_animalName)
	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				local faceDirection = self:getFaceDirection()
				local __sp = self:getEffectSpineFromCache("res/spine/effect/008/atk0/atk0", 1.0)
				__sp:setAnimation(0,"atk0",false)
				local _spScale = 1
				if self:getScaleX() < 0 then
					_spScale = -1
				end
				__sp:setScaleX(_spScale)
				local _winSize = cc.Director:getInstance():getWinSize()
				__sp:setPosition(_winSize.width/2, _winSize.height/2)

				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = __sp, zorder = self:getLocalZOrder() },
				})
				--左是我方，右是敌方。碰撞过以后不会再发生碰撞。标记
				--left
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
				--碰撞过的
				local left_temp_targets = {}
				local right_temp_targets = {}
				
				--[[时刻检测碰撞盒子，是否与英雄发生碰撞，碰撞后不再对这个英雄进行判断]]
				schedule(__sp, function(dt)
					for right_k,right_v in pairs(_rightTargets) do
						if right_v:isAlive() == true and right_temp_targets[right_v:getStandId()] == nil then
							local _box = __sp:getNodeForSlot("box")
							local _boxWorldPos = _box:convertToWorldSpace(cc.p(0.5, 0.5))
							-- local _gearNodePos = scene:convertToNodeSpace( _boxWorldPos )
							local _targetMidNode = right_v:getNodeForSlot("midPoint")
							local _targetMidWorldPos = _targetMidNode:convertToWorldSpace(cc.p(0.5, 0.5))
							local _posBool = false
							local _distanceOffset = 0
							if faceDirection == BATTLE_DIRECTION.LEFT then
								if _targetMidWorldPos.x > _boxWorldPos.x then
									_posBool = true
									_distanceOffset = -100
									if right_v:getPositionX()<150 then
										_distanceOffset = -right_v:getPositionX() + 50
									end
									_distanceOffset = _distanceOffset >0 and 0 or _distanceOffset
								end
							else
								if _targetMidWorldPos.x < _boxWorldPos.x then
									_posBool = true
									_distanceOffset = 100
									if right_v:getPositionX()>_winSize.width-150 then
										_distanceOffset = _winSize.width-right_v:getPositionX() - 50
									end
									_distanceOffset = _distanceOffset <0 and 0 or _distanceOffset
								end
							end
							if _posBool == true then
								right_temp_targets[right_v:getStandId()] = right_v	
								if not right_v:isWorldBoss() and not right_v:isCannotBemoved() then
									print("houtui>>>_distanceOffset》》" .. _distanceOffset)
									local _moveAction1 = cc.MoveTo:create(0.1, cc.p(right_v:getPositionX() + _distanceOffset, right_v:getPositionY()) )
									right_v:runAction(_moveAction1)
								end
								self:doHurt({skill = _skillData,targets = {[1]=right_v},count = 1})
							end
						end					
					end
				end, 1 / 60)

				local _action = cc.Sequence:create( cc.DelayTime:create(2.5), cc.RemoveSelf:create(true))
				__sp:runAction( _action )
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
				self:doHurt({skill = _skillData,targets = targets})
			end
		end--[[if end]]
		
	end

end

function LuoCheng:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function LuoCheng:create(params)
	return LuoCheng.new(params)
end

return LuoCheng
