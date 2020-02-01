--少年闻仲106
local Snwz = class("Snwz", function ( params )
	local animal = Character:_create(params)
	return animal
end)

--[[
	atk: 铁钩砸地
	atk1:铁钩抓取
	atk2:飞抡群伤
	atk0:裹取挤压
]]

--用锁链连接指定的两个点
--[[ 
	27*16 锁链图片尺寸
	baseNode: 添加到的目标节点
	_point1: 起点
	_point2: 终点
]]
function Snwz:_initCache()
	XTHD.createSprite("res/spine/effect/035/atk_guiji.png")
	self:getEffectSpineFromCache("res/spine/effect/034/atk0")
	self:getEffectSpineFromCache("res/spine/effect/034/atk1")
	for key,value in pairs(self:getSkills()) do
		local _level = tonumber(value.level) or 0
		if key == "skillid2" and _level > 0 then
			self:getEffectSpineFromCache("res/spine/effect/034/atk2")
		end
	end
end

function Snwz:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getSelectedTargets(_animalName)
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		
	else
		--[[对应技能的攻击次数+1]]
		targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtkDone then
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				local _target = self.mSkilltarget
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 10}
				})
				if _target then
					_target:setHurtable(true)
					self:doHurt({skill = _skillData, targets = targets})
					self._atkCount0 = self._atkCount0 + 1
					if self._atkCount0 ~= 5 then
						_target:setHurtable(false)
					else
						self:_resetSkillTarget()
					end
				end
			elseif name == "chuxian" then
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 10}
				})
				local _target = self.mSkilltarget
				if _target then
					local partX = 150
					local winWidth = cc.Director:getInstance():getWinSize().width
					if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
						if _target:getPositionX() + partX > winWidth - 200 then
							partX = winWidth - 200 - _target:getPositionX()
						end
					else
						partX = -150
						if _target:getPositionX() + partX < 200 then
							partX = 200 - _target:getPositionX()
						end
					end
					local moveByPos = cc.p(partX, 0)
					_target:runAction(cc.MoveBy:create(0.02, moveByPos))
				end
			elseif name == "xiaoshi" then
				XTHD.dispatchEvent({
					name = EVENT_NAME_SHAKE_SCREEN,
					data = {delta = 10}
				})
				local _target = self.mSkilltarget
				if _target then
					local root_pos = self:getSlotPositionInWorld("root")
					if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
						_target:setPosition(cc.p(root_pos.x + 100, root_pos.y))
					else
						_target:setPosition(cc.p(root_pos.x - 100, root_pos.y))
					end
					_target:setDefualtRootY()
					_target:updateZorder(self:getLocalZOrder())
					_target:setVisible(false)
				end
				self:_resetChainNode()
			elseif name == "onAtk01Done" then
				self._atkCount0 = 0
				self:_selfStopSkillTarget()
				local _target = targets[1]
				if not self:_checkCanCatchOne(_target) then
					self:showMissTip(_target)
					self:_removeSelfDim()
					self:playAnimation(BATTLE_ANIMATION_ACTION.IDLE,true)
					self:setLastAttackTime(0)
					return
				end
				self:_catchOne(_target)
				local chainNode = ChainNode:createOne()
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = chainNode},
				})
				local original_pos = self:getSlotPositionInWorld("firePoint")
				local middle_pos = _target:getSlotPositionInWorld("midPoint")
				chainNode:setBeganPoint(original_pos)
				chainNode:setMovedPoint(middle_pos)
				chainNode:updatePoint()
				self._chainNode = chainNode
				local effect = self:getEffectSpineFromCache("res/spine/effect/034/atk0")
				effect:setAnimation(0, "atk0", false)
				-- effect:setPosition(root_pos)
				_target:addNodeForSlot({node = effect , slotName = "root" , zorder = 10})
				local _sc = -1
				-- _target:getScaleX() > 0 and 1 or -1
				effect:setScaleX(_sc*effect:getScaleX())
				self._effectSkill0 = effect
				-- XTHD.dispatchEvent({
				-- 	name = EVENT_NAME_BATTLE_PLAY_EFFECT,
				-- 	data = {node = effect},
				-- })
				performWithDelay(effect,function()
					effect:removeFromParent()
					self._effectSkill0 = nil
				end,3)
				
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				local _target = targets[1]
				local original_pos = self:getSlotPositionInWorld("firePoint")
				local _endPos = self:getSlotPositionInWorld("root")
				local pDir = self:getFaceDirection() == BATTLE_DIRECTION.RIGHT and 1 or -1
				_endPos.x = _endPos.x + pDir*30
				local sp = self:getEffectSpineFromCache("res/spine/effect/034/atk1")
				if self:getFaceDirection() ~= BATTLE_DIRECTION.RIGHT then
					sp:setScaleY(-1*sp:getScaleX())
				end
				self:_resetChainNode()
				local chainNode = ChainNode:createOne(sp)
				XTHD.dispatchEvent({
					name = EVENT_NAME_BATTLE_PLAY_EFFECT,
					data = {node = chainNode, zorder = _target:getLocalZOrder()},
				})
				chainNode:setVisible(true)
				-- self._chainNode = chainNode

				local _randomNum
				local function _doConnotCache( )
					self:showMissTip(_target)
					self:playAnimation(BATTLE_ANIMATION_ACTION.IDLE,true)
					self:setLastAttackTime(0)
					-- self:_selfStopSkillTarget()
					chainNode:removeFromParent()
					chainNode = nil
				end
				local function _firstCall( changeY )
					if changeY > 40 then
						_doConnotCache()
						return true
					end
					if not self:_checkCanCatchOne(_target) then
						_doConnotCache()
						return true
					end
					local _minzhong = false
					_minzhong, _randomNum = self:isSkillMingzhong({skill = _skillData, target = _target})
					if not _minzhong then
						_doConnotCache()
						return true
					end
					self:_catchOne(_target)
					if sp then
						sp:setAnimation(0, "animation5", false)
					end
					XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 10}
					})
					return false
				end
				local function _endCall( ... )
					self:setAnimation(0, "atk1_1", false)
					XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 10}
					})
					local partX = 150
					local winWidth = cc.Director:getInstance():getWinSize().width
					if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
						if _target:getPositionX() + partX > winWidth - 200 then
							partX = winWidth - 200 - _target:getPositionX()
						end
					else
						partX = -150
						if _target:getPositionX() + partX < 200 then
							partX = 200 - _target:getPositionX()
						end
					end
					local moveByPos = cc.p(partX, 0)
					_target:runAction(cc.MoveBy:create(0.02, moveByPos))
					_target:setDefualtRootY()
					_target:updateZorder(self:getLocalZOrder())
					chainNode:removeFromParent()
					chainNode = nil
					self:_resetSkillTarget()
					-- self:_selfStopSkillTarget()
					self:doHurt({skill = _skillData, targets = targets, isMingzhong = _randomNum})

			 	end
				chainNode:catchOneNode({beginPos = original_pos, endPos = _endPos, target = _target, endCall = _endCall, firstCall = _firstCall})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				self:doHurt({skill = _skillData,targets = targets})
				for k,target in pairs(targets) do
					if target:isAlive() then
						local effect_spine = self:getEffectSpineFromCache("res/spine/effect/034/atk2")
						target:addNodeForSlot({node = effect_spine , slotName = "midPoint" , zorder = 10})
						local _sc = -1
						-- target:getScaleX() > 0 and 1 or -1
						effect_spine:setScaleX(_sc*effect_spine:getScaleX())
						effect_spine:setAnimation(0,"atk0",false)
						performWithDelay(effect_spine,function()
							effect_spine:removeFromParent()
							end,2)
					end
				end--[[for end]]
				
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
		
	end
end

function Snwz:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snwz:_selfStopSkillTarget( ... )
	self:_resetChainNode()
	self:_resetSkillTarget()
end

function Snwz:_checkCanCatchOne( sTarget )
	if not sTarget or not sTarget:isAlive() then
		return false
	end
	if sTarget:isWorldBoss() then
		return false
	end
	if not sTarget:isTargetable() then
		return false
	end
	if sTarget:isBeCatched() then
		return false
	end
	if sTarget:isHiding() then
		return false
	end
	return true
end

function Snwz:_catchOne( sTarget )
	sTarget:setBeCatched(true)
	sTarget:setHurtable(false)
	sTarget:changeToIdel()
	sTarget:setMove(false)
	self.mSkilltarget = sTarget
end

function Snwz:_resetSkillTarget()
	local _target = self.mSkilltarget
	if _target and _target:isAlive() then
		_target:setBeCatched(false)
		_target:setHurtable(true)
		_target:setVisible(true)
		local _state = _target:getStatus()
		if _state == BATTLE_STATUS.DIZZ then
			_target:playAnimation(BATTLE_ANIMATION_ACTION.DIZZ, true)
		else
			_target:changeToIdel()
		end
		_target:setLastAttackTime(0)
	end
	self.mSkilltarget = nil
end

function Snwz:canDoSuper( ... )
	if self:getStatus() == BATTLE_STATUS.ATK1 or self.mSkilltarget ~= nil or self._chainNode ~= nil then
		return false
	end
	return true
end

function Snwz:_resetChainNode( ... )
	if self._chainNode then
		self._chainNode:removeFromParent()
		self._chainNode = nil
	end
	if self._effectSkill0 then
		self._effectSkill0:removeFromParent()
		self._effectSkill0 = nil
	end
end

function Snwz:setStatus(status)
	self._status = status
	self:_selfStopSkillTarget()
	--[[--如果被眩晕，则移除黑屏，否则被眩晕以后可能会被卡住]]
	if status == BATTLE_STATUS.DIZZ then
		self:_removeSelfDim()
	end
end

function Snwz:create(params)
	return Snwz.new(params)
end

return Snwz