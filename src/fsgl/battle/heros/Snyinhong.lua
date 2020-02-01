--[[--少年殷洪
heroId : 98
]]
local Snyinhong = class("Snyinhong", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function Snyinhong:ctor()
	self:setCannotBeMoved(true)
end

function Snyinhong:_initCache()
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/044/atk1/atk1")
			self:getEffectSpineFromCache("res/spine/effect/044/atk1/atk1_1")
		end
	end
end
--[[--
	atk0：大招护盾
	atk1：丢苹果技能，onAtk1Done
	atk2：放刺技能，onAtk2Done
]]
function Snyinhong:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getSelectedTargets(_animalName)
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
		self:doHurt({skill = _skillData,targets = targets})
	else
		--[[对应技能的攻击次数+1]]
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				self:setAnimation(0,"atk0_1",true)
				local buffid = tonumber(_skillData["buff1id"])
				local staticBuffData = gameData.getDataFromCSV("Jinengbuff", {["buffid"] = buffid} )
				local duration = staticBuffData.duration / 1000.0
				performWithDelay(self,function()
					self:playAnimation(BATTLE_ANIMATION_ACTION.IDLE,true)
				end, duration)
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				local _apple = self:getEffectSpineFromCache("res/spine/effect/044/atk1/atk1")
				_apple:setAnimation(0,"atk1",true)
				local _targetEnemy = targets[1]
				--起始位置
				local _targetSlot = self:getSlotPositionInWorld("root")
				_apple:setPosition(_targetSlot.x, _targetSlot.y)
				--目标位置
				local endPos = _targetEnemy:getSlotPositionInWorld("root")
				if endPos.x<_targetSlot.x then
					_apple:setScaleX(-1*_apple:getScaleX())
				end

				local pos_delta = cc.pGetDistance(endPos, _targetSlot)
				local dt = getDynamicTime(pos_delta, 200)

				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = _apple},
				})
				_apple:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					self:doHurt({skill = _skillData,targets = targets})
					local _enemySp = self:getEffectSpineFromCache("res/spine/effect/044/atk1/atk1_1")
					_enemySp:setAnimation(0,"atk1_1",false)
					_targetEnemy:addNodeForSlot({node = _enemySp , slotName = "root" , zorder = 10})
				end),cc.RemoveSelf:create(true)))

			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
				self:doHurt({skill = _skillData,targets = targets})
			end
		end--[[if end]]
		
	end

end

function Snyinhong:doSuperAnimationStart(event)
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snyinhong:create(params)
	return Snyinhong.new(params)
end

return Snyinhong