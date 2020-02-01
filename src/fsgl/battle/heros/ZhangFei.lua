-- 张飞

local ZhangFei = class("ZhangFei", function ( params )
	local animal = Character:_create(params)
	return animal
end)
--[[--
	atk0 大招
	atk  普攻
	atk1 防护罩
	atk2  蹦起捶地猛攻

	onAtk0Done_1：播放atk0   与敌人root对齐    
	onAtk0Done：  大招掉血
	onAtkDone ：  普攻掉血
	onAtk1Done：  播放atk1   与大侠root对齐  人物上层循环播放
	onAtk2Done：  播放atk21  任务上层  ； atk22   人物下层   都是和大侠root对齐  技能二掉血
]]
function ZhangFei:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/031/atk0/atk0")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/031/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/031/atk2_1/atk21")
			self:getEffectSpineFromCache("res/spine/effect/031/atk2_2/atk22")
		end
	end
end

function ZhangFei:_initYD_Cache()
	self:getEffectSpineFromCache("res/spine/effect/031/bian_atk0/1031_atk0_1")
	self:getEffectSpineFromCache("res/spine/effect/031/bian_atk0/1031_atk0")
end

function ZhangFei:doAnimationEvent(event)
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local selectedTargets = self:getSelectedTargets(_animalName)
	if _animalName == BATTLE_ANIMATION_ACTION.BIAN_SUPER then
		_animalName = BATTLE_ANIMATION_ACTION.SUPER
	end
	local _skillData = self:getSkillByAction(_animalName)
	--[[--这一下不算在总招数里]]
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else
		--[[注意：
			1.在技能结束时，原先选定的攻击对象可能已经死亡了

		  ]]
		local targets = self:getHurtableTargets({selectedTargets = selectedTargets
			,skill=_skillData})
		if targets == nil then
			return
		end
		--[[--护盾，触发buff]]
		-- if name == BATTLE_ANIMATION_EVENT.onAtk1Done then
		-- 	--[[--护盾，没有伤害]]
		-- 	if _skillData.skillid == 184 then
		-- 		do return end
		-- 	end
		-- end
		--[[大招眩晕buff]]
		if name == BATTLE_ANIMATION_EVENT.onAtk0Done then
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 30, time = 0.3},
			})
		end
		if name ~= "onAtk0Done_1" and name ~= "onAtk0Done2" then
			--[[对应技能的攻击次数+1]]
			self:doHurt({skill = _skillData,targets = targets})
		end
		
		if name == BATTLE_ANIMATION_EVENT.onAtk2Done then
			local __sp = self:getEffectSpineFromCache("res/spine/effect/031/atk2_1/atk21")
			local _spScale = 1.0;
			if self:getScaleX() < 0 then
				_spScale = -1.0;
			end
			__sp:setScaleX( _spScale*__sp:getScaleX() )

			local _TarSlotNodePos = self:getSlotPositionInWorld("root")

			__sp:setPosition(_TarSlotNodePos.x, _TarSlotNodePos.y)

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = __sp, zorder = self:getLocalZOrder() - 1},
			})
			__sp:setAnimation(0,"atk2",false)
			performWithDelay(__sp, function ()
					if __sp then
						__sp:removeFromParent()
					end
				end, 2)
			local _sp2 = self:getEffectSpineFromCache("res/spine/effect/031/atk2_2/atk22")
			
			_sp2:setScaleX( _spScale*_sp2:getScaleX() )
			_sp2:setPosition(_TarSlotNodePos.x, _TarSlotNodePos.y)

			_sp2:setAnimation(0,"atk1",false)

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _sp2 , zorder = self:getLocalZOrder() - 1},
			})

			performWithDelay(_sp2, function ()
				if _sp2 then
					_sp2:removeFromParent()
				end
			end, 2)
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 20, time = 0.2},
			})
		end
		--[[大象震飞敌人，此事件只用于播放动画]]
		if name == "onAtk0Done_1" then
			for k,target in pairs(targets) do
				local __sp = self:getEffectSpineFromCache("res/spine/effect/031/atk0/atk0")
				
				local target_sp = target
				if self:getType() == ANIMAL_TYPE.PLAYER then
					XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 10}
					})
				end
				
				local _TarSlotNode = target:getSlotPositionInWorld("root")
				__sp:setPosition(_TarSlotNode)
				
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = __sp},
				})

				__sp:setAnimation(0,"atk0_01",false)
				if not target_sp:isWorldBoss() and not target_sp._eliAction then
					local eliAction = cc.Sequence:create(
						cc.MoveBy:create(0.08,cc.p(0,50)),
						cc.DelayTime:create(0.55+0.12), 
						cc.Spawn:create(
							cc.CallFunc:create(function() 
								if self:getType() == ANIMAL_TYPE.PLAYER then
									XTHD.dispatchEvent({
										name = EVENT_NAME_SHAKE_SCREEN,
									})
								end
							end), 
							cc.EaseExponentialOut:create(cc.MoveBy:create(0.4,cc.p(0,100)))
						),
						cc.EaseExponentialIn:create(cc.MoveBy:create(0.5,cc.p(0,-150))),
						cc.CallFunc:create(function()
							target_sp._eliAction = nil
						end)
					)
					target_sp._eliAction = eliAction
					target_sp:runAction(eliAction)
				end
				performWithDelay(__sp, function ()
					if __sp then
						__sp:removeFromParent()
					end
				end, 2)
			end
		elseif name == "onAtk0Done2" then
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 30, time = 0.3},
			})
			local _target = targets[1]
			if _target and _target:isAlive() then
				local _eff = self:getEffectSpineFromCache("res/spine/effect/031/bian_atk0/1031_atk0")
				_eff:setAnimation(0, "1031_atk0", false)
				local _point = _target:getSlotPositionInWorld("root")
				_eff:setPosition(_point)
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = _eff , zorder = _target:getLocalZOrder() - 1},
				})
				performWithDelay(_eff, function()
					_eff:removeFromParent()
				end, 2.2)
				_eff:registerSpineEventHandler( function ( event )
					local name = event.eventData.name
					if name == "1031onAtk0Done" then
						_target:runAction(cc.MoveBy:create(0.1, cc.p(0, 200)))
						XTHD.dispatchEvent({
							name = EVENT_NAME_SHAKE_SCREEN,
							data = {delta = 30, time = 1.5},
						})
						self:doHurt({skill = _skillData,targets = {_target}, count = 1})
						local _eff2 = self:getEffectSpineFromCache("res/spine/effect/031/bian_atk0/1031_atk0_1")
						_eff2:setAnimation(0, "1031_atk0_1", false)
						local _point = _target:getSlotPositionInWorld("root")
						_eff2:setPosition(_point)
						XTHD.dispatchEvent({
							name = EVENT_NAME_BATTLE_PLAY_EFFECT,
							data = {node = _eff2 , zorder = _target:getLocalZOrder()},
						})
						performWithDelay(_eff2, function()
							_eff2:removeFromParent()
						end, 0.4666)
					elseif name == "1031onAtk0Done2" then
						self:doHurt({skill = _skillData,targets = {_target}, count = 2})
						local _eff2 = self:getEffectSpineFromCache("res/spine/effect/031/bian_atk0/1031_atk0_1")
						_eff2:setAnimation(0, "1031_atk0_1", false)
						local _point = _target:getSlotPositionInWorld("root")
						_eff2:setPosition(_point)
						XTHD.dispatchEvent({
							name = EVENT_NAME_BATTLE_PLAY_EFFECT,
							data = {node = _eff2 , zorder = _target:getLocalZOrder()},
						})
						performWithDelay(_eff2, function()
							_eff2:removeFromParent()
						end, 0.4666)
					end
				end, sp.EventType.ANIMATION_EVENT)
				_eff:registerSpineEventHandler( function ( event )
					_target:runAction(cc.Sequence:create(
						cc.EaseExponentialIn:create(cc.MoveBy:create(0.5,cc.p(0,-200))),
						cc.MoveBy:create(0.12, cc.p(0, 50)),
						cc.MoveBy:create(0.06, cc.p(0, -50)),
						cc.MoveBy:create(0.03, cc.p(0, 20)),
						cc.MoveBy:create(0.01, cc.p(0, -20))
					))
				end, sp.EventType.ANIMATION_COMPLETE)
			end
		end
	end
end

function ZhangFei:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function ZhangFei:create(params)
	return ZhangFei.new(params)
end

return ZhangFei