--程咬金
local ChenYaoJin = class("ChenYaoJin", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function ChenYaoJin:ctor()
	self._bigSlotsName = "funiu_da"
	self:setBigToNormal()
end

function ChenYaoJin:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local targets = self:getSelectedTargets(_animalName)
	--[[对应技能的攻击次数+1]]
	targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else
		if targets ~= nil then
			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtkDone then
				self:doHurt({skill = _skillData,targets = targets})
				XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 10}
					})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				self:setNormalToBig(_skillData)
				self:doHurt({skill = _skillData,targets = targets})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				self:doHurt({skill = _skillData,targets = targets})
				XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 10}
					})
			elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
				self:doHurt({skill = _skillData,targets = targets})
				XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 10}
					})
				--[[处理击退]]
				local winWidth = cc.Director:getInstance():getWinSize().width
				
				local distance = 30
				for k,target in pairs(targets) do
					local targetPosX, targetPosY = target:getPosition()
					if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
						targetPosX = targetPosX + distance
						--[[如果超过边界，就无法再被击退]]
						if targetPosX > winWidth - 100 then
							targetPosX = winWidth - 100
						end
					else
						targetPosX = targetPosX - distance
						--[[如果超过边界，就无法再被击退]]
						if targetPosX < 100 then
							targetPosX = 100
						end
					end

					if not target:isWorldBoss() and not target:isCannotBemoved() then
						target:runAction( cc.MoveTo:create(0.05, cc.p(targetPosX, targetPosY)) )
					end
				end--[[for end]]
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
		
	end
end


function ChenYaoJin:setNormalToBig( _skillData )
	self:setAttachment(self._bigSlotsName, self._bigSlotsName)
	local _node = self:getNodeForSlot("gua")
	local _particle = cc.ParticleSystemQuad:create("res/spine/effect/013/niuniu.plist") 
	-- _particle:setPositionType(cc.POSITION_TYPE_RELATIVE) 
	_particle:setPosition(0, 0)
	_node:addChild(_particle)
	_node:setLocalZOrder(-1)
	local buffid = tonumber(_skillData["buff1id"])
	local staticBuffData = gameData.getDataFromCSV("Jinengbuff", {["buffid"] = buffid} )
	local duration = staticBuffData.duration / 1000.0
	performWithDelay(_node, function ( ... )
		self:setBigToNormal()
	end, duration)
end

function ChenYaoJin:setBigToNormal()
	self:setAttachment(self._bigSlotsName, "")
	local _node = self:getNodeForSlot("gua")
	_node:removeAllChildren()
end

function ChenYaoJin:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())

	--程咬金
	print(tostring(self._heroType))
end

function ChenYaoJin:create(params)
	return ChenYaoJin.new(params)
end

return ChenYaoJin