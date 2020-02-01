--[[神·凌振 54]]
local sslz = class("sslz", function ( params )
	if not params then
		params = {}
	end
	-- params.id = 17
	local animal = Character:_create(params)
	return animal
end)
--[[
atk0 大招炮弹
atk  手雷
atk1 飞轮
atk2 射箭
]]
function sslz:_initCache()
	XTHD.createSprite("res/spine/effect/054/atk2/atk2.png")
	self:getEffectSpineFromCache("res/spine/effect/054/atk0/atk0")	
	self:getEffectSpineFromCache("res/spine/effect/054/shoulei/017")	
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/054/atk1/017atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
		end
	end
end

function sslz:doAnimationEvent(event)
	local scene 		= cc.Director:getInstance():getRunningScene()
	local _animalName   = self:getNowAniName()
	local _skillData 	= self:getSkillByAction(_animalName)
	local targets 		= self:getSelectedTargets(_animalName)
	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
	local name = event.eventData.name

	if targets == nil then
		do
			-- XTHDTOAST("没有攻击对象")
			return
		end
	end
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		for k,target in pairs(targets) do
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/054/atk0/atk0")
			local _target_pos = target:getSlotPositionInWorld("root")
			effect_spine:setPosition(_target_pos)
			
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = effect_spine,zorder = target:getLocalZOrder()},
			})

			if self:getScaleX() < 0 then
				effect_spine:setScaleX(-1*effect_spine:getScaleX())
			end

			effect_spine:runAction( cc.Sequence:create( cc.DelayTime:create(0.1 * (k - 1)) , cc.CallFunc:create(function() 
						effect_spine:setAnimation(0,"atk0",false)
					end)  , cc.DelayTime:create(1) , cc.CallFunc:create(function() 
						local isInAttackRange, distance = circleIntersectRect(_target_pos , 100, target:getBox())
						if isInAttackRange == true then
							local _tmp_targets = {}
							_tmp_targets[#_tmp_targets + 1] = target
							self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})
						end
					end)  , cc.DelayTime:create(1) , cc.RemoveSelf:create(true) ) )
		end
	--[[大招，判断敌人是否在技能伤害范围之内]]
	elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
		--[[取第一个对象，也是最近的一个]]
		local _target_enemy = targets[1]
		if _target_enemy then
			local shoulei_sp = self:getEffectSpineFromCache("res/spine/effect/054/shoulei/017")
			-- local shoulei_sp = sp.SkeletonAnimation:create("res/spine/effect/054/shoulei/017.json", "res/spine/effect/054/shoulei/017.atlas", 1)--cc.Sprite:create("res/spine/effect/054/zhadan.png")
			--起始位置
			local _targetSlot= self:getSlotPositionInWorld("firePoint")
			--目标位置
			local endPos = _target_enemy:getSlotPositionInWorld("root")

			local pos_delta = cc.pGetDistance(endPos, _targetSlot)

			local bezier = nil
			if pos_delta < 300 then
				bezier  = {
			        cc.p((endPos.x-_targetSlot.x)/4*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+100),
					cc.p((endPos.x-_targetSlot.x)/2*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+50),
					cc.p(endPos.x, endPos.y + 30)
		    	}
			else
				bezier  = {
			        cc.p((endPos.x-_targetSlot.x)/4*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+100 + 50),
					cc.p((endPos.x-_targetSlot.x)/2*1+_targetSlot.x, (endPos.y-_targetSlot.y)/2+_targetSlot.y+50 + 50),
					cc.p(endPos.x, endPos.y + 30)
		    	}
			end

			local dt = getDynamicTime(pos_delta, 1000)*1.25;

			local actionBezier = cc.BezierTo:create(dt, bezier)
			--shoulei_sp:runAction(actionBezier)

			shoulei_sp:setPosition(_targetSlot.x, _targetSlot.y)
			-- scene:addChild(shoulei_sp)
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = shoulei_sp},
			})

			shoulei_sp:setAnimation(0,BATTLE_ANIMATION_ACTION.ATTACK,true)

			-- 记录当前是第几次攻击
			local _subEventCount = _EventCount
			shoulei_sp:runAction(cc.Sequence:create(--[[cc.EaseSineIn:create(actionBezier)]]cc.Spawn:create(actionBezier, cc.RotateBy:create(dt, 1200*dt ) ),cc.CallFunc:create(function()
			 	-- 子弹命中目标后的回调
			 	local brust_sp = cc.Sprite:create()
			 	brust_sp:setScale(self:getScaleY())

			 	brust_sp:setPosition(shoulei_sp:getPositionX(), shoulei_sp:getPositionY())
			 	local brust_animation =  getAnimation( "res/spine/effect/brust/", 0, 7, 0.1)
			 	brust_sp:runAction(cc.Sequence:create(brust_animation,cc.CallFunc:create(function()
			 		brust_sp:removeFromParent()
			 		end)))
			 	-- scene:addChild(brust_sp)
			 	XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = brust_sp,zorder = _target_enemy:getLocalZOrder()},
				})
			end),cc.CallFunc:create(function()
					shoulei_sp:removeFromParent()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					self:doHurt({skill = _skillData,targets = targets})
			end)))
		end

	elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then--[[--机械猪大招不在这里处理]]
	elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
	elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then--[[--射箭]]
		for k,_target_enemy in pairs(targets) do
			local _arrow = XTHD.createSprite("res/spine/effect/054/atk2/atk2.png")
			_arrow:setScale(self:getScaleY())
			--起始位置
			local _targetSlot = self:getSlotPositionInWorld("firePoint")
			_arrow:setPosition(_targetSlot.x, _targetSlot.y)
			--目标位置
			local endPos = _target_enemy:getSlotPositionInWorld("midPoint")

			-- 判定斜率,非弓箭状态
			local deltaY = endPos.y - _targetSlot.y;
			local deltaX = endPos.x - _targetSlot.x;
			local angel = deltaX > 0 and 0 or 180;
			local K = deltaY / deltaX;
			if deltaX ~= 0 then
				_arrow:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
			end
			
			local pos_delta = cc.pGetDistance(endPos, _targetSlot)

			local dt = getDynamicTime(pos_delta, 1000)*1.25

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _arrow,spine = self},
			})

			_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
					_arrow:removeFromParent()
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					local _tmp_targets = {}
					_tmp_targets[#_tmp_targets + 1] = _target_enemy
					self:doHurt({skill = _skillData,targets = _tmp_targets})
			end)))
		end--[[--for end]]
		
	end
end

function sslz:doAnimationStart(event)
	local scene = cc.Director:getInstance():getRunningScene()

	--[[记录当前的技能数据]]
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	local targets = self:getSelectedTargets(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())

	if event.animation == BATTLE_ANIMATION_ACTION.ATK1 then
		targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
		local faceDirection = self:getFaceDirection()
		local __sp = self:getEffectSpineFromCache("res/spine/effect/054/atk1/017atk1")
		-- local __sp= sp.SkeletonAnimation:create("res/spine/effect/054/atk1/017atk1.json", "res/spine/effect/054/atk1/017atk1.atlas")
		__sp:setScaleX(self:getScaleX())

		local shadowNodePos = self:getSlotPositionInWorld("root")
		__sp:setPosition(shadowNodePos.x, shadowNodePos.y)

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = __sp},
		})

		__sp:setAnimation(0,BATTLE_ANIMATION_ACTION.ATK1,false)
		-- __sp:scheduleUpdateWithPriorityLua(function(dt)
		-- 	end,0)
		--[[记录飞轮攻击过的目标，如果被攻击过，就不能再次被该飞轮攻击]]
		local _temp_targets = {}
		local _targets = {}
		
		--[[飞轮时刻检测是否有敌人进入攻击范围内]]
		schedule(__sp, function(dt)

			if targets then
				for k,target in pairs(targets) do
					--[[如果敌人没有死亡，就判读是否受到飞轮的攻击]]
					if target:isAlive() == true then
						local _gear = __sp:getNodeForSlot("feibiao")
						local _gearWorldPos = _gear:convertToWorldSpace(cc.p(0.5, 0.5))
						local _gearNodePos = scene:convertToNodeSpace( _gearWorldPos )

						local _targetMidNode = target:getNodeForSlot("midPoint");
						local _targetMidWorldPos = _targetMidNode:convertToWorldSpace(cc.p(0.5, 0.5))
						local _targetMidNodePos = scene:convertToNodeSpace( _targetMidWorldPos )

						local x = 0
						if faceDirection == BATTLE_DIRECTION.LEFT then
							if _targetMidNodePos.x > _gearNodePos.x and _temp_targets[target:getStandId()] == nil then
								x = -30
								_temp_targets[target:getStandId()] = target
								local _tmp_targets = {}
								_tmp_targets[#_tmp_targets + 1] = target
								self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})
							end
						elseif faceDirection == BATTLE_DIRECTION.RIGHT and _temp_targets[target:getStandId()] == nil then
							if _targetMidNodePos.x < _gearNodePos.x then
								x = 30
								_temp_targets[target:getStandId()] = target
								local _tmp_targets = {}
								_tmp_targets[#_tmp_targets + 1] = target
								self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})
							end
						end
						if not target:isWorldBoss() and not target:isCannotBemoved() then
							target:runAction(cc.EaseExponentialOut:create(cc.MoveBy:create(0.2,cc.p(x,0))))
						end
					end
				end--[[for end]]
			end
			
		end, 1 / 60)

		local _action = cc.Sequence:create( cc.DelayTime:create(1.5), cc.RemoveSelf:create(true))
		__sp:runAction( _action )
	end
end

function sslz:create(params)
	return sslz.new(params)
end

return sslz