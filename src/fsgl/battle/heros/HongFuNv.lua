--红拂女

local HongFuNv = class("HongFuNv", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function HongFuNv:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/012/atk0")
end

function HongFuNv:_initYD_Cache()
	self:getEffectSpineFromCache("res/spine/effect/012/yan")
end

function HongFuNv:doAnimationStart(event)
	local name = event.animation
	if name == BATTLE_ANIMATION_ACTION.SUPER then
		musicManager.playEffect("res/sound/skill/sound_effect_12_atk0.mp3")

		local _animalName = self:getNowAniName()
		local _skillData 	  = self:getSkillByAction(_animalName)
		XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
	end
end

function HongFuNv:doAnimationEvent(event)
	
	local name = event.eventData.name
	local pName = self:getNowAniName()
	if pName == "atk0_1" then
		pName = BATTLE_ANIMATION_ACTION.SUPER
	end
	local _skillData = self:getSkillByAction(pName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local selectedTargets = self:getSelectedTargets(pName)
	local targets = self:getHurtableTargets({selectedTargets = selectedTargets
			,skill=_skillData})
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
		musicManager.playEffect("res/sound/skill/".._skillData.sound..".mp3")
		local target = targets[1]
		if target:isAlive() then
			if self:getPositionX() < target:getPositionX() and self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
				self:setFaceDirection(BATTLE_DIRECTION.RIGHT)
			elseif self:getPositionX() > target:getPositionX() and self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
				self:setFaceDirection(BATTLE_DIRECTION.LEFT)
			end
		end  
	else
		--[[对应技能的攻击次数+1]]
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				-- 震屏
				if self:getType() == ANIMAL_TYPE.PLAYER then
					XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 10},
					})
				end
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == "chuxian" then
				self:setTargetable(true)
				self:setHurtable(true)
			elseif name == "xiaoshi" then
				--[[--变成无敌状态]]
				self:setTargetable(false)
				self:setHurtable(false)
				self:registerSpineEventHandler( function ( event )
					if event.animation == BATTLE_ANIMATION_ACTION.SUPER then
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

							local pBox = target:getBox()
							local posTarX = pBox.x + pBox.width
							local rootDefY = target:getDefualtRootY()
							local pos = 150
							if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
								pos = -pos
								posTarX = pBox.x
							end
							local finX = posTarX + pos
							if finX < 20 then
								finX = 20
							elseif finX > cc.Director:getInstance():getWinSize().width then
								finX = cc.Director:getInstance():getWinSize().width - 20
							end
							self:setPosition(cc.p(finX, rootDefY))
							self:setDefualtRootY()
							self:updateZorder(_zorder)
							self:setAnimation(0, "atk0_1", false)
							local enemy_spine = self:getEffectSpineFromCache("res/spine/effect/012/atk0")
							local pos = target:getSlotPositionInWorld("midPoint")
							enemy_spine:setAnimation(0, "atk0", false)
							enemy_spine:setPosition(pos)
							if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
								enemy_spine:setScaleX(-1*enemy_spine:getScaleX())
							end
							XTHD.dispatchEvent({
								name = EVENT_NAME_BATTLE_PLAY_EFFECT,
								data = {node = enemy_spine, zorder = 10},
							})
							performWithDelay(enemy_spine,function()
								enemy_spine:removeFromParent()
								end,4)
						else
							self._mp_add = 0
							self:_doAnimationComplete(event)
						end
					else
						self._mp_add = 0
						self:_doAnimationComplete(event)
					end		
				end, sp.EventType.ANIMATION_COMPLETE)
			elseif name == BATTLE_ANIMATION_EVENT.onAtkDone or name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				local count = self._attackcount[_skillData.skillid]
				if name == BATTLE_ANIMATION_EVENT.onAtk1Done and count < 7 then
					musicManager.playEffect("res/sound/skill/".._skillData.sound..".mp3")
				end
				self:doHurt({skill = _skillData,targets = targets})
			end
		else
			-- XTHDTOAST("狐狸没有攻击目标")
		end--[[if end]]
	end

end

function HongFuNv:create(params)
	return HongFuNv.new(params)
end

return HongFuNv