-- 少年女娲 90
local Snnw = class("Snnw", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function Snnw:ctor()
	self:setNormalToBig()
end

function Snnw:_initCache()
	XTHD.createSprite("res/spine/effect/020/zd.png")
	self:getEffectSpineFromCache("res/spine/effect/020/atk0")
	self:getEffectSpineFromCache("res/spine/effect/020/atk01")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/020/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/020/atk2")
			self:getEffectSpineFromCache("res/spine/effect/020/atk22")
		end
	end
end

function Snnw:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getSelectedTargets(_animalName)
	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
	if targets == nil then
		do return end
	end
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		
	else
		--[[对应技能的攻击次数+1]]
		if targets == nil then
			return
		end
		--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
		if name == BATTLE_ANIMATION_EVENT.onAtkDone then	
			local target = targets[1]
			local feibiao_sp = XTHD.createSprite("res/spine/effect/020/zd.png")
			feibiao_sp:setScale(self:getScaleY())
			feibiao_sp:setAnchorPoint(cc.p(0.9,0.5))
			local _fireSlotNodePos = self:getSlotPositionInWorld("firePoint");
			feibiao_sp:setPosition( _fireSlotNodePos );

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = feibiao_sp},
			})
			-- 敌人
			local endPos = target:getSlotPositionInWorld("midPoint")
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
				--[[攻击的帧事件，此时敌人应该出发受击操作]]
				self:doHurt({skill = _skillData,targets = targets})
			end) , cc.RemoveSelf:create(true)))
		elseif name == "atk1" then	
			local _target = targets[1]
			if _target and _target:isAlive() then
				local effect_spine  = self:getEffectSpineFromCache("res/spine/effect/020/atk1")
				_target:addNodeForSlot({node = effect_spine, slotName = "root" , zorder = 10})
				effect_spine:setScaleX(-1*effect_spine:getScaleX())
				effect_spine:setAnimation(0, "animation", false)	
				performWithDelay(effect_spine,function( )
					effect_spine:removeFromParent()
				end, 2.1666)
			end
		elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then	
			self:doHurt({skill = _skillData,targets = targets})
		elseif name == "atk2" then	
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/020/atk2")
			self:addNodeForSlot({node = effect_spine, slotName = "root" , zorder = 10})
			effect_spine:setAnimation(0, "animation4", false)	
			performWithDelay(effect_spine,function( )
				effect_spine:removeFromParent()
			end, 2.2333)
		elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then	
			self:doHurt({skill = _skillData,targets = targets})
		elseif name == "yinxiao" then	
			musicManager.playEffect("res/sound/skill/sound_effect_hit_atk0.mp3")
		elseif name == "atk0" then	
			local function _do( _target )
				local _count = self._hitcount[_skillData.skillid] or {}
				_count = tonumber(_count._hitCount) or 0
				local _name = _count%2 == 0 and "01" or "02"
				local effect_spine = self:getEffectSpineFromCache("res/spine/effect/020/atk0", 1.0)
				local point = _target:getSlotPositionInWorld("root")
				effect_spine:setPosition(point.x, winHeight*0.5 + 10)
				musicManager.playEffect("res/sound/skill/sound_effect_hit_atk0.mp3")
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = effect_spine, zorder = 10},
				})

				local pDir = self:getFaceDirection() == BATTLE_DIRECTION.RIGHT and 1 or -1
				effect_spine:setScaleX(pDir * effect_spine:getScaleX())
				effect_spine:setAnimation(0, _name, false)	
				performWithDelay(effect_spine,function( )
					effect_spine:removeFromParent()
				end, 1)
				effect_spine:registerSpineEventHandler( function ( event )
					local name = event.eventData.name
					if name == "onAtk0Done" then
						self:doHurt({skill = _skillData,targets = targets})
					end
				end, sp.EventType.ANIMATION_EVENT)

				local effect_spine2 = self:getEffectSpineFromCache("res/spine/effect/020/atk01", 1.0)
				local point = _target:getSlotPositionInWorld("root")
				effect_spine2:setPosition(point.x, winHeight*0.5 + 10)
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = effect_spine2, zorder = -1},
				})

				local pDir = self:getFaceDirection() == BATTLE_DIRECTION.RIGHT and 1 or -1
				effect_spine2:setScaleX(pDir * effect_spine2:getScaleX())
				effect_spine2:setAnimation(0, _name, false)	
				performWithDelay(effect_spine2,function()
					effect_spine2:removeFromParent()
				end, 1)
			end
			for i=1, #targets do
				local _target = targets[i]
				if _target and _target:isAlive() then
					_do(_target)
					break
				end
			end
		end
	end

end

function Snnw:setNormalToBig()
	-- local _node = self:getNodeForSlot("qiu")
	-- local _particle = cc.ParticleSystemQuad:create("res/spine/effect/020/xh.plist") 
	-- _particle:setPosition(0, 0)
	-- _node:addChild(_particle)
	-- _node:setLocalZOrder(10)
end

function Snnw:setBigToNormal()
	-- local _node = self:getNodeForSlot("qiu")
	-- _node:removeAllChildren()
end

function Snnw:create(params)
	return Snnw.new(params)
end

function Snnw:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

return Snnw