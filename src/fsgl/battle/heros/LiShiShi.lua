--[[--李师师]]
local LiShiShi = class("LiShiShi", function ( params )
	local animal = Character:_create(params)
	return animal
end)

--[[
	仙鹤:
	atk:左翅猛扇一次
	atk1:收翅前推
	atk2:也是比较不好描述，也挺陶醉的<→_→，感觉词穷了>
	atk0:动作很难描述，但是感觉很陶醉的样子
]]
function LiShiShi:_initCache()
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/007/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
		end
	end	
end

function LiShiShi:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getSelectedTargets(_animalName)
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else

		--[[对应技能的攻击次数+1]]
		targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
		if targets ~= nil then

			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtk0Done or name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == "onAtk1_1Done" then--[[--敌人受伤]]
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				for k,target in pairs(targets) do
					local effect_spine = self:getEffectSpineFromCache("res/spine/effect/007/atk1/atk1")
					target:addNodeForSlot({node = effect_spine , slotName = "root" , zorder = 10})
					local pS = -1 
					-- if target:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
					-- 	pS = -1
					-- end
					effect_spine:setScaleX(pS/target:getScaleX())

					effect_spine:setAnimation(0,"atk1",false)

					performWithDelay(effect_spine,function()
						effect_spine:removeFromParent()
					end, 0.3333)
				end--[[--for end]]
			elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
				for k,target in pairs(targets) do
					local _arrow = XTHD.createSprite("res/spine/effect/007/biao.png")
					_arrow:setScaleX(self:getScaleX())
					_arrow:setScaleY(self:getScaleY())
					--起始位置
					local _targetSlot = self:getSlotPositionInWorld("firePoint")
					_arrow:setPosition(_targetSlot.x, _targetSlot.y)
					--目标位置
					local endPos = target:getSlotPositionInWorld("midPoint")

					--计算角度
					-- 判定斜率,非弓箭状态
					local deltaY = endPos.y - _targetSlot.y;
					local deltaX = endPos.x - _targetSlot.x;
					local angel = deltaX > 0 and 0 or 180;
					local K = deltaY / deltaX;
					if deltaX ~= 0 then
						_arrow:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
					end
					
					local pos_delta = cc.pGetDistance(endPos, _targetSlot)
					local dt = getDynamicTime(pos_delta, 1000)

					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = _arrow},
					})
					--[[--飞镖飞到敌人位置造成伤害]]
					_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
							_arrow:removeFromParent()
							local _tmp_targets = {}
							_tmp_targets[#_tmp_targets + 1] = target
							--[[攻击的帧事件，此时敌人应该出发受击操作]]
							self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})
					end)))
				end--[[--for end]]
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
		
	end

end



function LiShiShi:doAnimationStart(event)
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end


function LiShiShi:create(params)
	return LiShiShi.new(params)
end

return LiShiShi