--[[
	世界boss囚牛-801/802
]]
local QiuNiu = class("QiuNiu", function ( params )
	local animal = Character:_create(params)
	return animal
end)
function QiuNiu:_initCache()
	for key,value in pairs(self:getSkills()) do
		if key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/801/atk2_1")
			self:getEffectSpineFromCache("res/spine/effect/801/atk2_2")
		elseif key == "skillid3" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/801/atk3")
			self:getEffectSpineFromCache("res/spine/effect/801/atk3_1")
		end
	end
end


function QiuNiu:doAnimationEvent(event)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	local targets = self:getSelectedTargets(_animalName)
	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})

	--[[大招，判断敌人是否在技能伤害范围之内]]
	if targets ~= nil then
		if name == BATTLE_ANIMATION_EVENT.onAtkDone then
			self:doHurt({skill = _skillData,targets = targets})
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 20},
			})
		elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
			local _target = targets[1]
			if _target and _target:isAlive() and not _target:isWorldBoss() then
				local pState = _target:isHurtable()
				_target:setHurtable(true)
				self:doHurt({skill = _skillData, targets = targets})
				_target:setHurtable(pState)
				local _movePoint = cc.p(cc.Director:getInstance():getWinSize().width*1.5, cc.Director:getInstance():getWinSize().height*0.8)
				if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
					_movePoint = cc.p(-cc.Director:getInstance():getWinSize().width*0.5, cc.Director:getInstance():getWinSize().height*0.8)
				end
				_target:runAction(cc.Sequence:create(
					cc.EaseCubicActionIn:create(cc.MoveTo:create(0.5, _movePoint)),
					cc.DelayTime:create(0.5),
					cc.CallFunc:create(function ( ... )
						if _target:isAlive() then
							_target:setPositionY(_target:getDefualtRootY())
						end
					end)
				))
			end
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 20},
			})
		elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 20},
			})
			local _spine = self:getEffectSpineFromCache("res/spine/effect/801/atk2_1")
			local pos = self:getSlotPositionInWorld("root")
			_spine:setAnimation(0, "atk2_1", false)
			_spine:setPosition(150,pos.y)
			if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
				_spine:setScaleX(-1*_spine:getScaleX())
			end
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _spine, zorder = 10},
			})
			performWithDelay(_spine,function()
				_spine:removeFromParent()
			end, 6)
			local _count = 0
			_spine:registerSpineEventHandler( function ( event )
				local name = event.eventData.name
				if name == "onAtk2Done_1" then
					_count = _count + 1
					if _count == 1 then
						XTHD.dispatchEvent({
							name = EVENT_NAME_SHAKE_SCREEN,
							data = {delta = 30, time = 0.5},
						})
					elseif _count == 2 then
						XTHD.dispatchEvent({
							name = EVENT_NAME_SHAKE_SCREEN,
							data = {delta = 20, time = 2.8},
						})
					end
					self:doHurt({skill = _skillData, targets = targets})
				end
			end, sp.EventType.ANIMATION_EVENT)

			local _spine2 = self:getEffectSpineFromCache("res/spine/effect/801/atk2_2")
			local pos = self:getSlotPositionInWorld("root")
			_spine2:setAnimation(0, "atk2_2", false)
			print("=====================>>>",pos.x,pos.y)
			_spine2:setPosition(150,pos.y)
			if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
				_spine2:setScaleX(-1*_spine2:getScaleX())
			end
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _spine2, zorder = -1},
			})
			performWithDelay(_spine2,function()
				_spine2:removeFromParent()
			end, 5.7666)
		elseif name == BATTLE_ANIMATION_EVENT.onAtk3Done then
			local enemy_spine = self:getEffectSpineFromCache("res/spine/effect/801/atk3")
			local pos = self:getSlotPositionInWorld("root")
			enemy_spine:setAnimation(0, "atk3", false)
			enemy_spine:setPosition(150,pos.y)
			if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
				enemy_spine:setScaleX(-1*enemy_spine:getScaleX())
			end
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = enemy_spine, zorder = -1},
			})
			performWithDelay(enemy_spine,function()
				enemy_spine:removeFromParent()
			end, 4.4)
			local enemy_spine2 = self:getEffectSpineFromCache("res/spine/effect/801/atk3_1")
			local pos = self:getSlotPositionInWorld("root")
			enemy_spine2:setAnimation(0, "atk3", false)
			enemy_spine2:setPosition(150,pos.y)
			if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
				enemy_spine2:setScaleX(-1*enemy_spine2:getScaleX())
			end
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = enemy_spine2, zorder = 10},
			})
			performWithDelay(enemy_spine2,function()
				enemy_spine2:removeFromParent()
			end, 4.2666)
		elseif name == "onAtk3_1Done" then
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 40, time = 0.5},
			})
			for k,v in pairs(targets) do
				if v:isAlive() and not v:isWorldBoss() then
					v:runAction(cc.Sequence:create(
						cc.MoveBy:create(0.05,cc.p(0, 100)), 
						cc.DelayTime:create(0.2),  
						cc.MoveBy:create(0.3, cc.p(0, -100))
					))
				end
			end
			self:doHurt({skill = _skillData,targets = targets})
		end
	else
	end
end

function QiuNiu:create(params)
	return QiuNiu.new(params)
end

return QiuNiu