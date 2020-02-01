--[[--少年龙吉
heroId : 88
]]
local Snljgz = class("Snljgz", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function Snljgz:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/039/atk0/atk0")
	self:getEffectSpineFromCache("res/spine/effect/039/atk/atk")
	for key,value in pairs(self:getSkills()) do
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/039/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/039/atk2/atk2")
			self:getEffectSpineFromCache("res/spine/effect/039/atk2/atk2_1")
		elseif key == "skillid3" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/039/atk3/atk3")
		end
	end
end

function Snljgz:_initYD_Cache()
	self:getEffectSpineFromCache("res/spine/effect/039/atk4/atk4")
end
--[[--
	atk0：大招石化
	atk1：伞放毒雨，onAtk1Done
	atk2：召唤小蛇攻击，onAtk2Done
	atk3：加护罩
	atk：丟伞
]]
function Snljgz:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local targets = self:getSelectedTargets(_animalName)
	if _animalName == "atk4" then
		_animalName = BATTLE_ANIMATION_ACTION.ATK1
	end
	local _skillData = self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else
		--[[对应技能的攻击次数+1]]
		if targets == nil then
			return
		end
		--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
		if name == BATTLE_ANIMATION_EVENT.onAtk0Done then
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 30, time = 0.3},
			})
			local _targetList = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
			self:doHurt({skill = _skillData,targets = _targetList})
			for k,_enemyTarget in pairs(targets) do
				local effect_spine = self:getEffectSpineFromCache("res/spine/effect/039/atk0/atk0")
				local _pos = _enemyTarget:getSlotPositionInWorld("midPoint")
				effect_spine:setPosition(_pos)
				effect_spine:setAnimation(0,"atk0",false)
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = effect_spine, zorder = self:getLocalZOrder()},
				})
				performWithDelay(effect_spine,function( )
					effect_spine:removeFromParent()
				end,0.4)
			end
		elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/039/atk1/atk1")
			local _firstPos = targets[1]:getSlotPositionInWorld("root")
			effect_spine:setPosition(cc.p(_firstPos.x, _firstPos.y))
			if self:getScaleX()<0 then
				effect_spine:setScaleX(-1*effect_spine:getScaleX())
			end
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = effect_spine, zorder = 10},
			})
			XTHD.dispatchEvent({
				name = EVENT_NAME_SHAKE_SCREEN,
				data = {delta = 20, time = 0.3},
			})
			effect_spine:setAnimation(0,"atk1",false)
			performWithDelay(effect_spine,function( )
				effect_spine:removeFromParent()
			end,1.9666)

			effect_spine:registerSpineEventHandler( function ( event )
				if event.eventData.name == "onAtk1Done" then
					XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 10, time = 0.1},
					})
					local _targetList = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
					self:doHurt({skill = _skillData, targets = _targetList})
				end
			end, sp.EventType.ANIMATION_EVENT)
		elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/039/atk2/atk2")
			local _effectPos = self:getSlotPositionInWorld("root")
			effect_spine:setPosition(cc.p(_effectPos.x, _effectPos.y))
			if self:getScaleX()<0 then
				effect_spine:setScaleX(-1*effect_spine:getScaleX())
			end
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = effect_spine, zorder = self:getLocalZOrder()+1},
			})
			effect_spine:setAnimation(0,"atk2",false)
			performWithDelay(effect_spine,function( )
				effect_spine:removeFromParent()
			end,3.2666)
			effect_spine:getNodeForSlot("a")
			effect_spine:getNodeForSlot("b")
			effect_spine:getNodeForSlot("c")
			local _smallSnake = function(_key)
				local _posNode = effect_spine:getNodeForSlot(_key)
				local _smallPos = _posNode:convertToWorldSpace(cc.p(0.5,0.5))
				local _bulletSp = XTHD.createSprite("res/spine/effect/039/atk2/zd1.png")
				_bulletSp:setScale(self:getScaleY())
				if self:getScaleX()<0 then
					_bulletSp:setScaleX(-1*_bulletSp:getScale())
				end
				local endPos = targets[1]:getSlotPositionInWorld("midPoint")
				_bulletSp:setPosition(_smallPos)

				--计算角度
				-- 判定斜率,非弓箭状态
				local deltaY = endPos.y - _smallPos.y;
				local deltaX = endPos.x - _smallPos.x;
				local angel = deltaX > 0 and 0 or 180;
				local K = deltaY / deltaX;
				if deltaX ~= 0 then
					_bulletSp:setRotation(angel-CC_RADIANS_TO_DEGREES(math.atan(K)));
				end
				local pos_delta = cc.pGetDistance(endPos, _smallPos)
				local dt = getDynamicTime(pos_delta, 1000)

				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = _bulletSp,zorder = self:getLocalZOrder()},
				})
				_bulletSp:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
						_bulletSp:removeFromParent()
						local click_spine = self:getEffectSpineFromCache("res/spine/effect/039/atk2/atk2_1")
						targets[1]:addNodeForSlot({node = click_spine , slotName = "midPoint" , zorder = 10})				
						click_spine:setAnimation(0,"atk2",false)
						self:doHurt({skill = _skillData,targets = targets})
						performWithDelay(click_spine,function( )
							click_spine:removeFromParent()
						end,0.5333)
					end)))
			end
			effect_spine:registerSpineEventHandler( function ( event )
				if event.eventData.name == BATTLE_ANIMATION_EVENT.onAtk2Done then
					_smallSnake("a")
				elseif event.eventData.name == "onAtk2Done1" then
					_smallSnake("b")
				elseif event.eventData.name == "onAtk2Done2" then
					_smallSnake("c")
				end
			end, sp.EventType.ANIMATION_EVENT)
		elseif name == BATTLE_ANIMATION_EVENT.onAtk3Done then
			self:doHurt({skill = _skillData,targets = targets})
		elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
			local _target_enemy = targets[1]
			local endPos = _target_enemy:getSlotPositionInWorld("midPoint")
			local _umbrella = XTHD.createSprite("res/spine/effect/039/atk/gj.png")
			_umbrella:setScaleX(self:getScaleX())
			local _targetSlot = self:getSlotPositionInWorld("firePoint")
			_umbrella:setPosition(_targetSlot)

			local pos_delta = cc.pGetDistance(endPos, _targetSlot)
			local dt = getDynamicTime(pos_delta, 1000)

			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = _umbrella,zorder = self:getLocalZOrder()},
			})
			local _clickFunc = function()
				local _rotation = _umbrella:getRotation()
				_umbrella:removeFromParent()
				self:doHurt({skill = _skillData,targets = targets})
				local _clickUmbrella = self:getEffectSpineFromCache("res/spine/effect/039/atk/atk")
				_target_enemy:addNodeForSlot({node = _clickUmbrella , slotName = "midPoint" , zorder = 10})
				-- _clickUmbrella:setScaleX(-1*_clickUmbrella:getScaleX())

				if _target_enemy:getScaleX()>0 then
			        _clickUmbrella:setScaleX(-1*_clickUmbrella:getScaleX())
			    end

				performWithDelay(_clickUmbrella,function( )
					_clickUmbrella:removeFromParent()
				end,0.1666)

			end 
			_umbrella:runAction(cc.Sequence:create(cc.MoveTo:create(dt,endPos),cc.CallFunc:create(function()
					_clickFunc()
				end)))
		elseif name == "onAtk4Done" then
			local effect_spine = self:getEffectSpineFromCache("res/spine/effect/039/atk4/atk4")
			local _pos = targets[1]:getSlotPositionInWorld("root")
			effect_spine:setPosition(_pos.x + 50, _pos.y)
			if self:getScaleX() < 0 then
				effect_spine:setScaleX(-1*effect_spine:getScaleX())
			end
			XTHD.dispatchEvent({
				name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				data = {node = effect_spine, zorder = targets[1]:getLocalZOrder() - 1},
			})
			effect_spine:setAnimation(0, "atk4", false)
			local _count = 0
			effect_spine:registerSpineEventHandler(function(event)
				if event.eventData.name == "onAtk1Done" then
					XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 10, time = 0.1},
					})
					local _targetList = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
					self:doHurt({skill = _skillData, targets = _targetList})
				end
			end, sp.EventType.ANIMATION_EVENT)
			effect_spine:registerSpineEventHandler(function(event)
				if event.animation == "atk4" then
					effect_spine:setAnimation(0, "atk4_1", false)
				elseif event.animation == "atk4_1" then
					_count = _count + 1
					if _count < 7 then
						effect_spine:setAnimation(0, "atk4_1", false)
						if _count == 4 then
							effect_spine:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
						end
					else
						effect_spine:setVisible(false)
						performWithDelay(effect_spine, function()
							effect_spine:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
							effect_spine:removeFromParent()
						end, 0.1)
					end
				end
			end, sp.EventType.ANIMATION_COMPLETE)
		end
	end

end

function Snljgz:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snljgz:create(params)
	return Snljgz.new(params)
end

return Snljgz