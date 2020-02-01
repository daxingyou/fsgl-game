--[[LuZhiShen 鲁智深 id 22]]


local LuZhiShen = class("LuZhiShen", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function LuZhiShen:_initCache()
	XTHD.createSprite("res/spine/effect/022/tu.png")
	for key,value in pairs(self:getSkills()) do
		local _level = tonumber(value.level) or 0
		if key == "skillid1" and _level > 0 then
			self:getEffectSpineFromCache("res/spine/effect/022/atk1")
			-- self:getEffectSpineFromCache("res/spine/effect/022/atk1_1")
		elseif key == "skillid2" and _level > 0 then
			self:getEffectSpineFromCache("res/spine/effect/022/atk2")
		end
	end
end

function LuZhiShen:doAnimationEvent(event)
	
	local name = event.eventData.name

	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		return
	end
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	local targets = self:getSelectedTargets(_animalName)
	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
	if targets == nil or #targets < 1 then
		return
	end

	if name == BATTLE_ANIMATION_EVENT.onAtkDone then
		self:doHurt({skill = _skillData,targets = targets})
	elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
		local _target = targets[1]
		local endPos = _target:getSlotPositionInWorld("root")
		local eff =  sp.SkeletonAnimation:createWithBinaryFile("res/spine/022.skel", "res/spine/022.atlas", 1.0)
		eff:setScale(self:getScaleY())
		if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
			eff:setScaleX(-1*eff:getScaleX())
		end
		eff:setAnimation(0, "atk0_1", false)
		performWithDelay(eff, function()
			eff:removeFromParent()
			self:setHurtable(true)
			self:setTargetable(true)
		end, 1.6666)
		eff:setPosition(endPos)
		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = eff},
		})
--	elseif name == "xiaoshi" then
--		self:setHurtable(false)
--		self:setTargetable(false)
--	elseif name == "chuxian" then
--		self:setHurtable(true)
--		self:setTargetable(true)
	elseif name == "onAtk0Done1" then
		local _target = targets[1]
		self:doHurt({skill = _skillData,targets = targets})
		if _target:isWorldBoss() or _target:isCannotBemoved() then
			return
		end
		local partX = 500
		local partWidth = 50
		local winWidth = cc.Director:getInstance():getWinSize().width
		if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
			partX = winWidth - partWidth - _target:getPositionX()
		else
			partX = partWidth - _target:getPositionX()
		end
		XTHD.dispatchEvent({
			name = EVENT_NAME_SHAKE_SCREEN,
			data = {delta = 10}
		})
		local _action = cc.Spawn:create(
			cc.MoveBy:create(0.3, cc.p(partX, 0)),
			cc.Sequence:create(
				cc.MoveBy:create(0.1, cc.p(0, 150)),
				cc.DelayTime:create(0.1),
				cc.EaseExponentialOut:create(cc.MoveBy:create(0.1, cc.p(0, -150))),
				cc.CallFunc:create(function ()
					local effectSprite = XTHD.createSprite("res/image/tmpbattle/effect/hiteffect004/1.png")
					_target:addNodeForSlot({node = effectSprite , slotName = "midPoint" , zorder = 10})
					local effect_animation = getAnimation( "res/image/tmpbattle/effect/hiteffect004/", 1, 3, 20/1000 )
					effectSprite:runAction(cc.Sequence:create(effect_animation , cc.RemoveSelf:create(true) ) )
					if self:getScaleX() < 0 then
						effectSprite:setScaleX(-1 * effectSprite:getScaleX())
					end
				end)
			)
		)
		_target:runAction(_action)
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
		local _target = targets[1]
		-- local endPos = _target:getSlotPositionInWorld("root")
		-- local effect_sp = self:getEffectSpineFromCache("res/spine/effect/022/atk1_1", 1.0)
		-- if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
		-- 	effect_sp:setScaleX(-1*effect_sp:getScaleX())
		-- end
		-- effect_sp:setPosition(endPos)

		-- XTHD.dispatchEvent({
		-- 	name = EVENT_NAME_BATTLE_PLAY_EFFECT,
		-- 	data = {node = effect_sp , zorder = -1},
		-- })

		-- effect_sp:setAnimation(0,"atk1",false)
		-- performWithDelay(effect_sp,function()
		-- 	effect_sp:removeFromParent()
		-- end, 1.1)

		for k,v in pairs(targets) do
			local endPos = v:getSlotPositionInWorld("root")
			local _effSp = self:getEffectSpineFromCache("res/spine/effect/022/atk1")
			_effSp:setPosition(endPos)
			if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
				_effSp:setScaleX(-1*_effSp:getScaleX())
			end
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _effSp},
			})
			_effSp:setAnimation(0,"atk1",false)
			performWithDelay(_effSp,function()
				_effSp:removeFromParent()
			end, 1.1)
		end
		XTHD.dispatchEvent({
			name = EVENT_NAME_SHAKE_SCREEN,
			data = {delta = 10}
		})
		self:doHurt({skill = _skillData,targets = targets})
	elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
		local _target = targets[1]
		local original_pos = self:getSlotPositionInWorld("firePoint")
		local biubiu = XTHD.createSprite("res/spine/effect/022/tu.png")
		biubiu:setScale(self:getScaleY())
		if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
			biubiu:setScaleX(-1*biubiu:getScaleX())
		end
		biubiu:setPosition(original_pos)
		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = biubiu},
		})

		local _target_pos = _target:getSlotPositionInWorld("midPoint")
		local dt = getDynamicTime(math.abs(_target_pos.x - original_pos.x), 1200)

		biubiu:runAction(cc.Sequence:create(
			cc.MoveTo:create(dt, _target_pos),
			cc.CallFunc:create(function()
				local effect_sp = self:getEffectSpineFromCache("res/spine/effect/022/atk2")
				_target:addNodeForSlot({node = effect_sp , slotName = "midPoint" , zorder = 10})
				effect_sp:setAnimation(0,"atk1",false)
				performWithDelay(effect_sp,function()
					effect_sp:removeFromParent()
				end, 0.4)
				local _tmp_targets = {}
				_tmp_targets[#_tmp_targets + 1] = _target
				self:doHurt({skill = _skillData,targets = _tmp_targets})
			end),
			cc.RemoveSelf:create(true)
		))
	end
end

function LuZhiShen:doSuperAnimationStart(event)
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function LuZhiShen:create(params)
	return LuZhiShen.new(params)
end

return LuZhiShen