--[[91少年孔宣]]

local Snkx = class("Snkx", function ( params )
	local animal = Character:_create(params)
	return animal
end)
--[[
	atk0 :仰天长啸，孔雀开屏
	atk : 扔三根镖
	atk1 :扔毒镖
	atk2 : 呱呱呱，号令狼群
]]
function Snkx:_initCache()
	XTHD.createSprite("res/spine/effect/004/atk_biao.png")
	XTHD.createSprite("res/spine/effect/004/atk1_dubiao.png")
	XTHD.createSprite("res/spine/effect/004/atk2_paodan.png")

	self:getEffectSpineFromCache("res/spine/effect/004/atk0_02/004atk02")
	self:getEffectSpineFromCache("res/spine/effect/004/atk0_01/004atk01")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/004/atk1/004atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/004/atk2_02/004atk22")
			self:getEffectSpineFromCache("res/spine/effect/004/atk2_01/004atk21")
		end
	end
end

function Snkx:_initYD_Cache()
	self:getEffectSpineFromCache("res/spine/effect/004/bian_atk0/1004atk02")
	self:getEffectSpineFromCache("res/spine/effect/004/bian_atk0/huo")
	self:getEffectSpineFromCache("res/spine/effect/004/bian_atk0/1004atk0")
	cc.ParticleSystemQuad:create("res/spine/effect/004/bian_atk0/kchx.plist")
	self:getEffectSpineFromCache("res/spine/effect/004/bian/fs")
	self:getEffectSpineFromCache("res/spine/effect/004/atk1")
end

--[[
onAtk0Done2 大招最后一击
]]
function Snkx:doAnimationEvent(event)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local _animalName = self:getNowAniName()

	local targets = self:getSelectedTargets(_animalName)
	if _animalName == BATTLE_ANIMATION_ACTION.BIAN_SUPER then
		_animalName = BATTLE_ANIMATION_ACTION.SUPER
	end
	local _skillData = self:getSkillByAction(_animalName)
	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})

	local name = event.eventData.name
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	elseif targets ~= nil then

		if name == BATTLE_ANIMATION_EVENT.onAtkDone then
			for k,_target_enemy in pairs(targets) do
				local _arrow = XTHD.createSprite("res/spine/effect/004/atk_biao.png")
				_arrow:setScaleY(self:getScaleY())
				_arrow:setScaleX(self:getScaleX())
				--起始位置
				local _targetSlot = self:getSlotPositionInWorld("firePoint")
				_arrow:setPosition(_targetSlot.x, _targetSlot.y)
				--目标位置
				local endPos = _target_enemy:getSlotPositionInWorld("midPoint")

				local pos_delta = cc.pGetDistance(endPos, _targetSlot)
				local dt = getDynamicTime(pos_delta, 1000)*1.25

				--计算角度
				-- 判定斜率,非弓箭状态
				local deltaY = endPos.y - _targetSlot.y;
				local deltaX = endPos.x - _targetSlot.x;
				local angel = deltaX > 0 and 0 or 180;
				local K = deltaY / deltaX;
				if deltaX ~= 0 then
					_arrow:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
				end
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = _arrow},
				})

				_arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
						_arrow:removeFromParent()
						--[[攻击的帧事件，此时敌人应该出发受击操作]]
						if k == #targets then
							self:doHurt({skill = _skillData,targets = targets})
						end
				end),cc.RemoveSelf:create(true)))
			end
		elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then

			for k,_target_enemy in pairs(targets) do
				local _arrow = XTHD.createSprite("res/spine/effect/004/atk1_dubiao.png")
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
					local _tmp_targets = {}
					_tmp_targets[#_tmp_targets + 1] = _target_enemy
					--[[攻击的帧事件，此时敌人应该出发受击操作]]
					self:doHurt({skill = _skillData,targets = _tmp_targets})
				end)))
			end
		elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
			self:_doEvent_Atk2(_skillData, targets)
		elseif name == "onAtk0_1" then--[[--孔雀的大招，从天而降的飞镖]]
			
			for k,target in pairs(targets) do
				local atk02_sp = self:getEffectSpineFromCache("res/spine/effect/004/atk0_02/004atk02")
				local s = 1
				if self:getScaleX() < 0 then
					s = -1
				end
				atk02_sp:setScaleX(math.abs(atk02_sp:getScaleX()) * s)

				--目标位置
				local endPos = target:getSlotPositionInWorld("root")
				atk02_sp:setPosition(endPos)

				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = atk02_sp,zorder = target:getLocalZOrder()},
				})

				atk02_sp:registerSpineEventHandler( function ( event )
					if event.eventData.name == "onAtk0Done" then
						local _tmp_targets = {}
						_tmp_targets[#_tmp_targets + 1] = target
						--[[攻击的帧事件，此时敌人应该出发受击操作]]
						self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})
						XTHD.dispatchEvent({
							name = EVENT_NAME_SHAKE_SCREEN,
							data = {delta = 30, time = 0.2},
						})
					end
				end, sp.EventType.ANIMATION_EVENT)
				
				atk02_sp:runAction(cc.Sequence:create(cc.DelayTime:create(0.2*(k-1)),cc.CallFunc:create(function()
						atk02_sp:setAnimation(0,"atk0",false)
					end),cc.DelayTime:create(2),cc.CallFunc:create(function()
						atk02_sp:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
						atk02_sp:removeFromParent()
					end)))
			end--[[--for end]]
		elseif name == "1004atk0" then
			local _count = 0
			for k,target in pairs(targets) do
				local atk02_sp = self:getEffectSpineFromCache("res/spine/effect/004/bian_atk0/1004atk02")
				local s = 1
				if self:getScaleX() < 0 then
					s = -1
				end
				atk02_sp:setScaleX(math.abs(atk02_sp:getScaleX()) * s)

				--目标位置
				local endPos = target:getSlotPositionInWorld("root")
				atk02_sp:setPosition(endPos)

				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = atk02_sp,zorder = target:getLocalZOrder()},
				})

				atk02_sp:registerSpineEventHandler( function ( event )
					if event.eventData.name == "atk0" then
						local _tmp_targets = {}
						_count = _count + 1
						_tmp_targets[#_tmp_targets + 1] = target
						--[[攻击的帧事件，此时敌人应该出发受击操作]]
						self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})
						
						if _count == 1 then
							self:showWolrdEff(true)
							XTHD.dispatchEvent({
								name = EVENT_NAME_SHAKE_SCREEN,
								data = {delta = 30, time = 1.2},
							})
						end
					end
				end, sp.EventType.ANIMATION_EVENT)
				
				atk02_sp:runAction(cc.Sequence:create(cc.DelayTime:create(0.2*(k-1)),cc.CallFunc:create(function()
						atk02_sp:setAnimation(0,"atk0",false)
					end),cc.DelayTime:create(2),cc.CallFunc:create(function()
						atk02_sp:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
						atk02_sp:removeFromParent()
					end)))
			end--[[--for end]]
			
		end
	end

end

function Snkx:showWolrdEff( isDelay )
	local __sp = self:getEffectSpineFromCache("res/spine/effect/004/bian_atk0/huo", 1.0);
	__sp:setPosition(winWidth*0.5, winHeight*0.5)
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_PLAY_EFFECT,
		data = {node = __sp, zorder = -10},
	})			
	__sp:setAnimation(0, "animation", true)
	if isDelay then
		__sp:setOpacity(0)
		__sp:runAction(cc.FadeTo:create(0.5, 255))
	end

	local _particle = cc.ParticleSystemQuad:create("res/spine/effect/004/bian_atk0/kchx.plist") 
	_particle:setPosition(-winWidth*0.25, -20)
	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_PLAY_EFFECT,
		data = {node = _particle, zorder = -10},
	})			
	_particle:setBlendFunc(gl.SRC_ALPHA, gl.ONE)
end


function Snkx:_doEvent_Atk2( _skillData, targets, posYPlus )
	local _posYPlus = posYPlus or 0
	local _target_enemy = targets[1]
	--飞翔的火球
	local _bullet = XTHD.createSprite("res/spine/effect/004/atk2_paodan.png")
	_bullet:setScale(self:getScaleY())

	--起始位置
	local _targetSlot= self:getSlotPositionInWorld("firePoint")
	if self:getSide() == BATTLE_SIDE.LEFT then
        _targetSlot.x = _targetSlot.x - 120
    else
        _targetSlot.x = _targetSlot.x + 120
    end
	_targetSlot.y = _targetSlot.y + _posYPlus
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
	_bullet:setPosition(_targetSlot)

	local dt = getDynamicTime(pos_delta, 1000)*1.25;

	local actionBezier = cc.BezierTo:create(dt, bezier)

	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_PLAY_EFFECT,
		data = {node = _bullet,zorder = self:getLocalZOrder()},
	})

	_bullet:runAction(cc.Sequence:create(actionBezier, cc.CallFunc:create(function() 
		if _bullet then
			_bullet:removeFromParent()
		end
		local shadowNodePos = _target_enemy:getSlotPositionInWorld("root")
		--爆炸的炮弹spine
		local __sp = self:getEffectSpineFromCache("res/spine/effect/004/atk2_02/004atk22")
		__sp:setScaleX(self:getScaleX())
		__sp:setPosition(shadowNodePos)

		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = __sp,zorder = _target_enemy:getLocalZOrder()},
		})

		__sp:setAnimation(0,"atk2",false)

		performWithDelay(__sp, function ()
			__sp:removeFromParent()
		end, 1.4)
		
		--[[攻击的帧事件，此时敌人应该出发受击操作]]
		self:doHurt({skill = _skillData,targets = targets})
	end)))

	return _bullet
end


function Snkx:_doStart_Atk2( posYPlus )
	local _posYPlus = posYPlus or 0
	--[[--战车]]
	local _target_node = self:getSlotPositionInWorld("root")
	local __spatk2 = self:getEffectSpineFromCache("res/spine/effect/004/atk2_01/004atk21")
	__spatk2:setTimeScale(self:getTimeScale())
	local pos = cc.p(-200, _target_node.y + _posYPlus)

	local _z = self:getLocalZOrder()
	if pos.y > _target_node.y then
		_z = _z - 1
	end

	XTHD.dispatchEvent({
		name = EVENT_NAME_BATTLE_PLAY_EFFECT,
		data = {node = __spatk2, zorder = _z},
	})
	if self:getScaleX() < 0 then
		__spatk2:setScaleX(__spatk2:getScaleX() * -1)
    	local winWidth = cc.Director:getInstance():getWinSize().width
    	pos = cc.p(winWidth + 200, _target_node.y + _posYPlus)
	end
	__spatk2:setPosition(pos)
	__spatk2:resume()
	__spatk2:registerSpineEventHandler( function ( event )
		if event.animation == BATTLE_ANIMATION_ACTION.ATTACK then
			__spatk2:setAnimation(0,"houtui",false)	
		elseif event.animation == "houtui" then
			__spatk2:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
			__spatk2:runAction( cc.Sequence:create( cc.DelayTime:create(0.2), cc.RemoveSelf:create(true)   ) )
		end
	end, sp.EventType.ANIMATION_COMPLETE)

	__spatk2:setAnimation(0,"qianjin",false)	

	local _targetPos = cc.p(_target_node.x, _target_node.y + _posYPlus)
	__spatk2:runAction(cc.Sequence:create( 
		cc.MoveTo:create(0.2, _targetPos), 
		cc.CallFunc:create(function() 
			__spatk2:setAnimation(0,"atk",false)	
		end)   
	))
end

function Snkx:doAnimationStart(event)
	if event.animation == BATTLE_ANIMATION_ACTION.SUPER then
		local __sp = self:getEffectSpineFromCache("res/spine/effect/004/atk0_01/004atk01");
		self:addNodeForSlot({node = __sp , slotName = "root" , zorder = 10})				
		
		__sp:setAnimation(0,"atk0",true)		
		
		performWithDelay(__sp, function ()
			__sp:removeFromParent()
		end, 1.4)

		local _animalName = self:getNowAniName()
		local _skillData 	  = self:getSkillByAction(_animalName)
		XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
	elseif event.animation == BATTLE_ANIMATION_ACTION.ATK2 then
		self:_doStart_Atk2()
	elseif event.animation == BATTLE_ANIMATION_ACTION.BIAN_SUPER then
		local __sp = self:getEffectSpineFromCache("res/spine/effect/004/bian_atk0/1004atk0");
		local _dir = self:getFaceDirection() == BATTLE_DIRECTION.RIGHT and 1 or -1
		__sp:setScaleX(_dir*__sp:getScaleX())
		__sp:setPosition(self:getSlotPositionInWorld("root"))
		XTHD.dispatchEvent({
			name = EVENT_NAME_BATTLE_PLAY_EFFECT,
			data = {node = __sp, zorder = -1},
		})			
		__sp:setAnimation(0, "atk0", false)		
		
		performWithDelay(__sp, function ()
			__sp:removeFromParent()
		end, 2.2)
	end
end

function Snkx:create(params)
	return Snkx.new(params)
end

return Snkx
