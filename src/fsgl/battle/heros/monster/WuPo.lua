--[[
巫婆-308
对应monsterid:301~400
]]
local WuPo = class("WuPo", function(params)
    local animal = Character:_create(params)
    return animal
end )

function WuPo:_initCache()
    XTHD.createSprite("res/spine/effect/308/hq.png")
end

function WuPo:doAnimationEvent(event)
    --[[注意：
		1.在技能结束时，原先选定的攻击对象可能已经死亡了
	  ]]
    local name = event.eventData.name
    local _animalName = self:getNowAniName()
    local _skillData = self:getSkillByAction(_animalName)
    local targets = self:getSelectedTargets(_animalName)

    --[[ 大招，判断敌人是否在技能伤害范围之内 ]]
    if name == BATTLE_ANIMATION_EVENT.onAtkDone then
        local _targetList = targets
        if _targetList == nil or #_targetList < 1 then
            do
                print("306普通攻击没有攻击目标")
                return
            end
        end
        --[[ 取第一个对象，也是最近的一个 ]]
        local _target_enemy = _targetList[1]
        if _target_enemy then
            local _arrow = XTHD.createSprite("res/spine/effect/308/hq.png")
            _arrow:setScale(self:getScaleY())
            if self:getScaleX() < 0 then
                _arrow:setScaleX(-1.0 * _arrow:getScaleX())
            end
            -- 起始位置
            local _targetSlot = self:getSlotPositionInWorld("firePoint")

            _arrow:setPosition(_targetSlot.x, _targetSlot.y)
            -- 目标位置
            local endPos = _target_enemy:getSlotPositionInWorld("midPoint")

            local pos_delta = cc.pGetDistance(endPos, _targetSlot)
            local dt = getDynamicTime(pos_delta, 1000) * 1.25

            XTHD.dispatchEvent( {
                name = EVENT_NAME_BATTLE_PLAY_EFFECT,
                data = { node = _arrow, spine = self },
            } )

            _arrow:runAction(cc.Sequence:create(cc.MoveTo:create(dt, endPos), cc.CallFunc:create( function()
                _arrow:removeFromParent()
                --[[ 攻击的帧事件，此时敌人应该出发受击操作 ]]
                self:doHurt( { skill = _skillData, targets = targets })
            end )))
        end
    elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
        self:doHurt( { skill = _skillData, targets = targets })
    end
end

function WuPo:create(params)
    return WuPo.new(params)
end

return WuPo