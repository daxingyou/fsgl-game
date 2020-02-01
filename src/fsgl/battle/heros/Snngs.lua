-- 少年南宫适
-- id:102
local Snngs = class("Snngs", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function Snngs:ctor()
	self._skill0Scale = 1.5
	self._bigSkillNodes = {7, 12, 14, 18, 20, 30, 32, 35, 37}
	self:setBigToNormal(true)
end

function Snngs:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/024/atk0")
	self:getEffectSpineFromCache("res/spine/effect/024/atk0_1")
	for key,value in pairs(self:getSkills()) do
		local _level = tonumber(value.level) or 0
		if key == "skillid3" and _level > 0 then
			self:getEffectSpineFromCache("res/spine/effect/024/atk3")
		end
	end
end

function Snngs:doAnimationEvent(event)
	local scene = cc.Director:getInstance():getRunningScene()
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	local targets = self:getSelectedTargets(_animalName)

	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		-- 技能刚开始释放的时候
	else
		targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtkDone then
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				local __sp = self:getEffectSpineFromCache("res/spine/effect/024/atk0")
				self:addNodeForSlot({node = __sp, slotName = "root", zorder = 10})
				__sp:setAnimation(0, "atk0", false)
				performWithDelay(__sp, function ( ... )
					__sp:removeFromParent()
				end, 3.1)
			elseif name == "onAtk0Done1" then
				if self.__Effect0Sp then
					self.__Effect0Sp:removeFromParent()
					self.__Effect0Sp = nil
				end
				local __sp = self:getEffectSpineFromCache("res/spine/effect/024/atk0_1")
				self:addNodeForSlot({node = __sp, slotName = "midPoint", zorder = 10})
				__sp:setAnimation(0, "atk0", true)
				self.__Effect0Sp = __sp
				self:doHurt({skill = _skillData, targets = targets})
				self:setNormalToBig()
				local buffid = tonumber(_skillData["buff1id"])
				local staticBuffData = gameData.getDataFromCSV("Jinengbuff", {["buffid"] = buffid} )
				local duration = staticBuffData.duration / 1000.0
				local pNode = self.__Effect0Sp or self
				performWithDelay(pNode, function ( ... )
					self:setBigToNormal()
				end, duration)
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 10},
				})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				
				--[[记录飞轮攻击过的目标，如果被攻击过，就不能再次被该飞轮攻击]]
				local _temp_targets = {}

				local _node = cc.Node:create()
				local x = 30
				if self:getFaceDirection() == BATTLE_DIRECTION.LEFT then
					x = -30
				end
				
				schedule(_node, function(dt)
					if self:getNowAniName() ~= BATTLE_ANIMATION_ACTION.ATK1 then
						return
					end
					local _pos = self:getSlotPositionInWorld("xxxx14")
					for k,target in pairs(targets) do
						local _isMingzhong = false
						if target:isAlive() == true and _temp_targets[target:getStandId()] == nil then
							local _box = target:getBox()
							if _box.x <= _pos.x and _box.x + _box.width >= _pos.x then
								_isMingzhong = true
							end
						end
						if _isMingzhong then
							_temp_targets[target:getStandId()] = target
							local _tmp_targets = {}
							_tmp_targets[#_tmp_targets + 1] = target
							self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})
							XTHD.dispatchEvent({
								name = EVENT_NAME_SHAKE_SCREEN,
								data = {delta = 10},
							})
							if not target:isWorldBoss() and not target:isCannotBemoved() then
								target:runAction(cc.EaseExponentialOut:create(cc.MoveBy:create(0.2,cc.p(x,0))))
							end
						end
					end
				end, 1.00/60)
				self:addChild(_node)
				local _action = cc.Sequence:create( cc.DelayTime:create(2), cc.RemoveSelf:create(true))
				_node:runAction( _action )
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				self:doHurt({skill = _skillData,targets = targets})
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 10},
				})
			elseif name == "fei" then
				local target = targets and targets[1] or nil
				if target and target:isAlive() and not target:isWorldBoss() and not target:isCannotBemoved() and not target:isImmuneControl() then
					local partX = 500
					local partWidth = 50
					local winWidth = cc.Director:getInstance():getWinSize().width
					if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
						-- if target:getPositionX() + partX > winWidth - partWidth then
						-- 	partX = winWidth - partWidth - target:getPositionX()
						-- end
						partX = winWidth - partWidth - target:getPositionX()
					else
						-- partX = -partX
						-- if target:getPositionX() + partX < partWidth then
						-- 	partX = partWidth - target:getPositionX()
						-- end
						partX = partWidth - target:getPositionX()
					end
					target:runAction(cc.MoveBy:create(0.02, cc.p(partX, 0)))
				end
			elseif name == "up" then
				local target = targets and targets[1] or nil
				if target and target:isAlive() then
					local pX = 230
					local _zorder = target:getLocalZOrder()
					if target:isWorldBoss() then
						_zorder = 10
						pX = 0
					end
					local _pBox = target:getBox()
					local x = _pBox.x
					if target:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
						x = x + _pBox.width
					end
					local _wid = _pBox.width*0.5
					-- local y = target:getDefualtRootY()
					pX = pX + _wid
					if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
						pX = -pX
					end
					x = x + pX
					local isRun = true
					if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
						if x <= self:getPositionX() then
							isRun = false
						end
					else
						if x >= self:getPositionX() then
							isRun = false
						end
					end
					if isRun then
						local _x = x - self:getPositionX()
						-- local _y = y - self:getPositionY()
						self._atk2MoveAction = cc.Sequence:create(
							cc.DelayTime:create(0.1),
							cc.MoveBy:create(0.66, cc.p(_x, 0)),
							cc.CallFunc:create(function()
								-- self:setDefualtRootY()
								-- self:updateZorder(_zorder)
								self._atk2MoveAction = nil
							end)
						)
						self:runAction(self._atk2MoveAction)
					end
				end
			elseif name == BATTLE_ANIMATION_EVENT.onAtk3Done then
				self:doHurt({skill = _skillData,targets = targets})
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
		
	end
end

function Snngs:setNormalToBig( ... )
	local pX = 1
	if self:getFaceDirection() ~= BATTLE_DIRECTION.RIGHT then
		pX = -1
	end
	self:setScaleX(pX * self._scale * self._skill0Scale)
	self:setScaleY(self._scale * self._skill0Scale)

	for k,v in pairs(self._bigSkillNodes) do
		self:setAttachment(v, v)
	end
end

function Snngs:setBigToNormal( haveNoAni )
	local pX = 1
	if self:getFaceDirection() ~= BATTLE_DIRECTION.RIGHT then
		pX = -1
	end
	if not haveNoAni then
		self:runAction(cc.ScaleTo:create(0.08, pX * self._scale, self._scale))
	else
		self:setScaleX(pX * self._scale)
		self:setScaleY(self._scale)
	end
	
	if self.__Effect0Sp then
		self.__Effect0Sp:removeFromParent()
		self.__Effect0Sp = nil
	end

	for k,v in pairs(self._bigSkillNodes) do
		self:setAttachment(v, "")
	end
end

function Snngs:setStatus(status)
	self._status = status
	--[[--如果被眩晕，则移除黑屏，否则被眩晕以后可能会被卡住]]
	if status == BATTLE_STATUS.DIZZ then
		self:_removeSelfDim()
		if self._atk2MoveAction then
			self:stopAction(self._atk2MoveAction)
		end
	elseif status == BATTLE_STATUS.DEAD or status == BATTLE_STATUS.DEFENSE then
		if self._atk2MoveAction then
			self:stopAction(self._atk2MoveAction)
		end
		if status == BATTLE_STATUS.DEAD then
			self:setBigToNormal()
		end
	end
end

function Snngs:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snngs:create(params)
	return Snngs.new(params)
end

return Snngs