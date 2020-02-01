--[[--长颈鹿
heroId : 26
]]
local Giraffe = class("Giraffe", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function Giraffe:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/026/atk")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/026/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/026/atk2")
			self._haveSkill2 = true
		end
	end
end

--[[--
大招
onAtk0Begin:   关闭黑屏！
onAtk0Done : 大招  一次伤害掉血！
onAtk0Done2：敌人要飞起来向后落下！后落下眩晕！

普通技能1
onAtk1Done：  同时播放 atk1特效  root与敌人midPoin对齐！  两次伤害掉血！

技能2
onAtk2Done： 技能1 同时播放atk2   root与敌人目标root对齐！ 
onAtk1Done1:一次伤害掉血！

普通技能
onAtkDone：普通技能     同时播放atk特效  root与敌人midPoin对齐！  一次伤害掉血！
PS:普攻是技能1的一半。
]]
function Giraffe:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	local targets = self:getSelectedTargets(_animalName)
	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})

	local _winSize = cc.Director:getInstance():getWinSize()
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else
		--[[对应技能的攻击次数+1]]
		if targets == nil then
			return
		end
		--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
		if name == BATTLE_ANIMATION_EVENT.onAtk0Done then
			local _target = targets[1]
			self:doHurt({skill = _skillData,targets = targets})
			if _target:isAlive() and self._haveSkill2 then
				self:setDoOtherAnimationCompleteCheckFunction(function(event)
					if event.animation == BATTLE_ANIMATION_ACTION.SUPER then
						self:setSelectedTargets({name = BATTLE_ANIMATION_ACTION.ATK2, targets = {_target}})
						self:playAnimation(BATTLE_ANIMATION_ACTION.ATK2)
						self:setDoOtherAnimationCompleteCheckFunction(nil)
						return true
					end
					return false
				end)
			end
		elseif name == "onAtk0Done2" then
			local _target = targets[1]
			if not _target:isWorldBoss() and not _target:isCannotBemoved() then
				local selfPos = self:getSlotPositionInWorld("root")
				local startPos = _target:getSlotPositionInWorld("root")
				local endPos = cc.p(startPos.x,startPos.y)
				if selfPos.x>startPos.x then
					endPos = cc.p(startPos.x - 300,startPos.y)
					if endPos.x <50 then
						endPos.x = 50
					end
				else
					endPos = cc.p(startPos.x + 300,startPos.y)
					if endPos.x >_winSize.width-50 then
						endPos.x = _winSize.width-50
					end
				end
				
				local mid = cc.p((endPos.x - startPos.x) / 2 + startPos.x, startPos.y+300)
				
				local mid_x = (endPos.x - startPos.x) / 2 + startPos.x
		        bezier_pos1 = cc.p(startPos.x, startPos.y)
		        bezier_pos2 = cc.p(mid.x, mid.y )
				bezier_pos3 = cc.p(endPos.x, endPos.y)
				-- XTHDTOAST(random)
				local bezier = {
			        bezier_pos1,
					bezier_pos2,
					bezier_pos3,
			    }

				local pos_delta = getDistance( endPos, startPos )
				local dt = getDynamicTime(pos_delta, 1000) * 1.5
				local actionBezier = cc.BezierTo:create(dt, bezier)
				-- _target:runAction(cc.Sequence:create(actionBezier,cc.CallFunc:create(
						
				-- 	)))
				_target:runAction(actionBezier)
			end
		elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
			local _target = targets[1]
			if _target and _target:isAlive() then
				local effect_spine  = self:getEffectSpineFromCache("res/spine/effect/026/atk2")
				_target:addNodeForSlot({node = effect_spine , slotName = "root" , zorder = 10})
				-- if _target:getScaleX()<0 then
					effect_spine:setScaleX(-1*effect_spine:getScaleX())
				-- end
				effect_spine:setAnimation(0,"atk1",false)
				effect_spine:registerSpineEventHandler( function ( event )
					if event.eventData.name == "onAtk1Done1" then
						self:doHurt({skill = _skillData, targets = targets})
					end
				end, sp.EventType.ANIMATION_EVENT)

				performWithDelay(effect_spine,function( )
					effect_spine:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
					effect_spine:removeFromParent()
				end,1.5333)
			end
		elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
			local _target = targets[1]
			if _target and _target:isAlive() then
				local effect_spine  = self:getEffectSpineFromCache("res/spine/effect/026/atk")
				_target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})
				-- if _target:getScaleX()<0 then
					effect_spine:setScaleX(-1*effect_spine:getScaleX())
				-- end
				self:doHurt({skill = _skillData,targets = targets})

				effect_spine:setAnimation(0,"atk1",false)
				performWithDelay(effect_spine,function( )
					effect_spine:removeFromParent()
				end,0.2)
			end
		elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
			local _target = targets[1]
			if _target and _target:isAlive() then
				local effect_spine  = self:getEffectSpineFromCache("res/spine/effect/026/atk1")
				_target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})
				-- if _target:getScaleX()<0 then
					effect_spine:setScaleX(-1*effect_spine:getScaleX())
				-- end
				self:doHurt({skill = _skillData,targets = targets})

				effect_spine:setAnimation(0,"atk1",false)	
				performWithDelay(effect_spine,function( )
					effect_spine:removeFromParent()
				end,0.5333)
			end
		end
	end

end

function Giraffe:create(params)
	return Giraffe.new(params)
end

return Giraffe