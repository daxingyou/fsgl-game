--[[
祭祀-313
对应monsterid:1500~1600
]]
local JiSi = class("JiSi", function(params)
    local animal = Character:_create(params)
    return animal
end )

function JiSi:_initCache()
    XTHD.createSprite("res/spine/effect/313/1.png")
    self:getEffectSpineFromCache("res/spine/effect/040/atk/atk")
end

function JiSi:doAnimationEvent(event)
    --[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
    local name = event.eventData.name
    local _animalName = self:getNowAniName()
    local _skillData = self:getSkillByAction(_animalName)
    local targets = self:getSelectedTargets(_animalName)

    if name == BATTLE_ANIMATION_EVENT.onAtkDone then
        local _targetList = targets
        if _targetList == nil or #_targetList < 1 then
            return
        end
        for k, _target_enemy in pairs(_targetList) do
            local _arrow = XTHDArrow:createWithParams( { fileName = "res/spine/effect/313/1.png", autoRotate = true })
            _arrow:setScale(self:getScaleY())
            -- 起始位置
            local _targetSlot = self:getSlotPositionInWorld("firePoint")

            _arrow:setPosition(_targetSlot.x, _targetSlot.y)
            -- 目标位置
            local endPos = _target_enemy:getSlotPositionInWorld("midPoint")

            local pos_delta = getDistance(endPos, _targetSlot)

            local dt = getDynamicTime(pos_delta, 1000)

            XTHD.dispatchEvent( {
                name = EVENT_NAME_BATTLE_PLAY_EFFECT,
                data = { node = _arrow, spine = self },
            } )

            _arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt, endPos), cc.CallFunc:create( function()
                local _effect_spine = self:getEffectSpineFromCache("res/spine/effect/040/atk/atk")
                _target_enemy:addNodeForSlot( { node = _effect_spine, slotName = "midPoint", zorder = 10 })
                _effect_spine:setAnimation(0, "animation", false)
                performWithDelay(_effect_spine, function()
                    _effect_spine:removeFromParent()
                end , 2)
                local _tmp_targets = { }
                _tmp_targets[#_tmp_targets + 1] = _target_enemy
                --[[ 攻击的帧事件，此时敌人应该出发受击操作 ]]
                self:doHurt( { skill = _skillData, targets = _tmp_targets })
            end ), cc.RemoveSelf:create(true)))
        end
    elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
        self:doHurt( { skill = _skillData, targets = _tmp_targets })
    end

end


function JiSi:create(params)
    return JiSi.new(params)
end

return JiSi