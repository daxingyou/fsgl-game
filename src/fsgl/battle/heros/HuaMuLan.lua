--花木兰

local HuaMuLan = class("HuaMuLan", function ( params )
	local animal = Character:_create(params)
	return animal
end)

function HuaMuLan:doAnimationEvent(event)
	
	local name = event.eventData.name
	local _animalName = self:getNowAniName()
	local _skillData = self:getSkillByAction(_animalName)
	-- local targets = self:getNowSkillTarges(_skillData)
	local targets = self:getSelectedTargets(_animalName)

	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
	else
		--[[对应技能的攻击次数+1]]
		targets = self:getHurtableTargets({selectedTargets = targets , skill = _skillData})
		if targets ~= nil then
			self:doHurt({skill = _skillData,targets = targets})

			--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
			if name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				if (self._attackcount[_skillData.skillid] == 1 or self._attackcount[_skillData.skillid] == 6 or self._attackcount[_skillData.skillid] == 7)  then
					XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 10}
					})
				end
				--[[处理击退]]
				-- local winWidth = cc.Director:getInstance():getWinSize().width

				-- local PosX = self:getPositionX()
				local distance = 7
				local selfChangeX = self:getChangeX(distance, self:getPositionX(), 200)
				-- if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
				-- 	if PosX + distance > winWidth - 200 then
				-- 		distance = winWidth - 200 - PosX
				-- 	end
				-- 	distance = distance < 0 and 0 or distance
				-- else
				-- 	if PosX - distance < 200 then
				-- 		distance = PosX - 200
				-- 	end
				-- 	distance = distance > 0 and 0 or distance
				-- end
				self:runAction( cc.MoveBy:create( 0.05, cc.p(selfChangeX, 0) ) )

				for k,target in pairs(targets) do
					-- local targetPosX = target:getPositionX()
					-- if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
					-- 	targetPosX = targetPosX + distance
					-- 	--[[如果超过边界，就无法再被击退]]
					-- 	if targetPosX > winWidth - 100 then
					-- 		targetPosX = winWidth - 100
					-- 	end
					-- else
					-- 	targetPosX = targetPosX - distance
					-- 	--[[如果超过边界，就无法再被击退]]
					-- 	if targetPosX < 100 then
					-- 		targetPosX = 100
					-- 	end
					-- end
					if not target:isWorldBoss() and not target:isCannotBemoved() then
						local _changeX = self:getChangeX(distance, target:getPositionX(), 100)
						target:runAction( cc.MoveBy:create(0.05, cc.p(_changeX, 0)) )
					end
				end--[[for end]]
			elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
				XTHD.dispatchEvent({
						name = EVENT_NAME_SHAKE_SCREEN,
						data = {delta = 10}
					})
			end
		else
			-- XTHDTOAST("没有攻击目标")
		end--[[if end]]
		
	end
end

function HuaMuLan:getChangeX( dis, startX, width )
	local distance = dis
	local winWidth = cc.Director:getInstance():getWinSize().width
	if self:getFaceDirection() == BATTLE_DIRECTION.RIGHT then
		if startX + dis > winWidth - width then
			distance = winWidth - width - startX
		end
		distance = distance < 0 and 0 or distance
	else
		distance = - distance
		if startX + distance < width then
			distance = width - startX
		end
		distance = distance > 0 and 0 or distance
	end
	return distance
end

function HuaMuLan:doSuperAnimationStart(event)
	-- 
	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function HuaMuLan:create(params)
	return HuaMuLan.new(params)
end

return HuaMuLan