--[[雪怪]]
local SnowMonster = class("SnowMonster", function ( params )
	local animal = Character:_create(params)
	return animal
end)
--[[
	atk0 大招
	atk  普攻  抓击
	atk1   拨山移石
	atk2   龙爪 被动技能
	atk3   破硬 被动技能
--]]
function SnowMonster:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/042/atk0")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/042/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then 
			self:getEffectSpineFromCache("res/spine/effect/042/atk2")
		end
	end
end

--[[
onAtk0Done2 大招最后一击
]]
function SnowMonster:doAnimationEvent(event)
	local name = event.eventData.name
	local _name = self:getNowAniName()
	if _name == "atk0_1" then
		_name = BATTLE_ANIMATION_ACTION.SUPER
	end
	local _skillData = self:getSkillByAction(_name)
	--[[注意：1.在技能结束时，原先选定的攻击对象可能已经死亡了]]
	local targets = self:getSelectedTargets(_name)
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
		self:setTargetable(false)
		self:setHurtable(false)
	else
		targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtk0Done then--[[--外伤免疫buff]]
				local target = nil
				for i=1, #targets do
					target = targets[1] 
					if target:isAlive() then
						break
					end
				end
				if target then
					local _zorder = target:getLocalZOrder()
					if target:isWorldBoss() then
						_zorder = 10
					end
					local rootDefY = target:getDefualtRootY()
					local _px = target:getPositionX()
					_px = self:getFaceDirection() == BATTLE_DIRECTION.RIGHT and _px - 220 or _px + 220
					self:setPosition(cc.p(_px, rootDefY))
					self:setDefualtRootY()
					self:updateZorder(_zorder)
				end
				self:playAnimation("atk0_1",false)
			elseif name == "onAtk0Done_1" then
				----被砸中的特效
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 40, time = 0.3},
				})
				local effect_spine = self:getEffectSpineFromCache("res/spine/effect/042/atk0")
				local _pos = self:getSlotPositionInWorld("root")
				effect_spine:setAnimation(0, "atk0_1", false)
				effect_spine:setPosition(_pos)
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = effect_spine, zorder = targets[1]:getLocalZOrder()},
				})
				performWithDelay(effect_spine,function()
					effect_spine:removeFromParent()
				end, 1)
				self:doHurt({skill = _skillData,targets = targets})	 

			elseif name == "onAtk0Done_2" then
				self:setTargetable(true)
				self:setHurtable(true)
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then 
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 20},
				})
				local effect_spine = self:getEffectSpineFromCache("res/spine/effect/042/atk1")
				self:addNodeForSlot({node = effect_spine , slotName = "root" , zorder = 10})
				effect_spine:setAnimation(0,"atk1",false)
				performWithDelay(effect_spine,function()
					effect_spine:removeFromParent()
				end, 1)
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then ----自身加buff
				local effect_spine = self:getEffectSpineFromCache("res/spine/effect/042/atk2")
				self:addNodeForSlot({node = effect_spine , slotName = "root" , zorder = 10})
				effect_spine:setAnimation(0,"atk2",false)
				performWithDelay(effect_spine,function()
					effect_spine:removeFromParent()
				end, 2)
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
				self:doHurt({skill = _skillData,targets = targets})
			end
		end
	end
end

function SnowMonster:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function SnowMonster:create(params)
	return SnowMonster.new(params)
end

return SnowMonster