--[[--93少年胡喜媚]]
local Snhxm = class("Snhxm", function ( params )
	local animal = Character:_create(params)
	return animal
end)

--[[--

onAtk0Done 
atk0_1_2 隐身状态下播放大招

]]
function Snhxm:_initCache()
	self:getEffectSpineFromCache("res/spine/effect/037/atk/atk")
	for key,value in pairs(self:getSkills()) do
        value.level=value.level or 0
		if key == "skillid1" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/037/atk1/atk1")
		elseif key == "skillid2" and tonumber(value.level) > 0 then
			self:getEffectSpineFromCache("res/spine/effect/037/atk2/atk2")
		end
	end
end

function Snhxm:doAnimationStart(event)
	local name = event.animation
	if name == BATTLE_ANIMATION_ACTION.SUPER 
		or name == BATTLE_ANIMATION_ACTION.ATTACK 
		or name == BATTLE_ANIMATION_ACTION.ATK1 
		or name == BATTLE_ANIMATION_ACTION.ATK2 
		or name == BATTLE_ANIMATION_ACTION.ATK3 then
		self:setHiding(false)
		print("YSM self:setHiding(false)")
	end

	local _animalName = self:getNowAniName()
    local _skillData 	  = self:getSkillByAction(_animalName)
	XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snhxm:doAnimationEvent(event)
	local name = event.eventData.name
	local nowAniName = self:getNowAniName()
	if nowAniName == "atk0_3" or nowAniName == "atk0_2" then
		nowAniName = BATTLE_ANIMATION_ACTION.SUPER
	end

	local _skillData = self:getSkillByAction(nowAniName)
	--[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
	local selectedTargets = self:getSelectedTargets(nowAniName)
	
	if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
		--[[去除阴影]]
		--[[--记录当前隐身的位置]]
		self._temp_hide_pos = cc.p(self:getPositionX(), self:getDefualtRootY())
		self._temp_face = self:getFaceDirection()
	else
		if name == "onAtk0Done_1" then--[[--出现动画]]
			self:setHurtable(true)
			self:setTargetable(true)
			self:setPosition(self._temp_hide_pos)
			self:setFaceDirection(self._temp_face)
			self:setAnimation(0,"atk0_3",false)
			print("YSM self:setHurtable(true)")
		elseif name == "onAtk0_1Done" then--[[--击打动画，此时人物消失]]
			self:setHurtable(false)
			self:setTargetable(false)
			self:setAnimation(0,"atk0_2",false)
			print("YSM self:setHurtable(false)")
			local _target_item = selectedTargets[1]
			if self:getPositionX() > _target_item:getPositionX() then
				if self._temp_face == BATTLE_DIRECTION.LEFT then
					self:setFaceDirection(BATTLE_DIRECTION.RIGHT)
				end
				self:setPosition(_target_item:getPositionX()-100, _target_item:getPositionY())
			else
				if self._temp_face == BATTLE_DIRECTION.RIGHT then
					self:setFaceDirection(BATTLE_DIRECTION.LEFT)
				end
				self:setPosition(_target_item:getPositionX()+100, _target_item:getPositionY())
			end
		else
			--[[对应技能的攻击次数+1]]
			targets = self:getHurtableTargets({selectedTargets = selectedTargets , skill = _skillData})
			
			if targets ~= nil then
				--[[如果是大招，则需要单独处理一些事务，例如击退、震屏]]
				if name == BATTLE_ANIMATION_EVENT.onAtkDone then
					for k,target in pairs(targets) do
						local biao = self:getEffectSpineFromCache("res/spine/effect/037/atk/atk")
						biao:setAnimation(0, "atk1", true)
						
						local original_pos = self:getSlotPositionInWorld("firePoint")
						biao:setPosition(original_pos.x, original_pos.y)

						local _target_pos = target:getSlotPositionInWorld("midPoint")
						local dt  =  getDynamicTime(math.abs(_target_pos.x-original_pos.x), 1200);

						XTHD.dispatchEvent({
							name = EVENT_NAME_BATTLE_PLAY_EFFECT,
							data = {node = biao, zorder = target:getLocalZOrder()},
						})

						biao:runAction(cc.Sequence:create(cc.MoveTo:create(dt,_target_pos),cc.CallFunc:create(function()
							local _tmp_targets = {}
							_tmp_targets[#_tmp_targets + 1] = target
							self:doHurt({skill = _skillData,targets = _tmp_targets, count = 1})
						end) ,cc.RemoveSelf:create(true)))
					end
				elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
					local atk1_spine = self:getEffectSpineFromCache("res/spine/effect/037/atk1/atk1", 1.0)
					local _target_pos = targets[1]:getSlotPositionInWorld("root")
					atk1_spine:setPosition(_target_pos.x, _target_pos.y)
					local _sc = self:getScaleX() > 0 and 1 or -1
					atk1_spine:setScaleX(_sc*atk1_spine:getScaleX())
					atk1_spine:setAnimation(0,"atk1",false)
					performWithDelay(atk1_spine,function()
						atk1_spine:removeFromParent()
						end, 3)

					XTHD.dispatchEvent({
						name = EVENT_NAME_BATTLE_PLAY_EFFECT,
						data = {node = atk1_spine, zoreder = -1},
					})
					self:doHurt({skill = _skillData,targets = targets})
				elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
					local atk1_spine = self:getEffectSpineFromCache("res/spine/effect/037/atk1/atk1")
					self:addNodeForSlot({node = atk1_spine , slotName = "root" , zorder = 10})
					atk1_spine:setAnimation(0, "atk2", false)
					self:doHurt({skill = _skillData, targets = targets})
				elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
					if self:getType() == ANIMAL_TYPE.PLAYER then
						XTHD.dispatchEvent({
							name = EVENT_NAME_SHAKE_SCREEN,
							data = {delta = 10}
						})
					end
					self:doHurt({skill = _skillData,targets = targets})
				end
			elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
				-- XTHDTOAST(name.."没有攻击目标")
			end--[[if end]]	
		end
		
	end

end

function Snhxm:create(params)
	return Snhxm.new(params)
end

return Snhxm