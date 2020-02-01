--[[--少年黄天化
heroId : 109
]]
local Snhth = class("Snhth", function(params)
    local animal = Character:_create(params)
    return animal
end )

function Snhth:_initCache()
    self._catchTb = { }
    self:getEffectSpineFromCache("res/spine/effect/006/atk0")
    self:getEffectSpineFromCache("res/spine/effect/006/atk")
    for key, value in pairs(self:getSkills()) do
        if key == "skillid1" and tonumber(value.level) > 0 then
            self:getEffectSpineFromCache("res/spine/effect/006/atk1")
        elseif key == "skillid2" and tonumber(value.level) > 0 then
            self:getEffectSpineFromCache("res/spine/effect/006/atk2")
        end
    end
end
--[[--
	onAtk0Begin:   关闭黑屏！
		up:  播放atk0 与敌人root对齐，不跟随人物位移！ 播放atk0_1 与敌人midPoin对齐！
		     敌人起来！敌人高度220像素左右，在起来期间五个敌人要不同的上下幅度，幅度65像素左右，用眩晕动作vertigo！
	onAtk0Done :7次伤害！
		down:  敌人下落！眩晕1秒！

	技能1
	onAtk1Done： 播放atk1   root与目标root对齐！     老虎移到敌人面前  0.3秒   老虎先打最后一排！
	onAtk1Done2  播放atk1_1  root与目标midPoin对齐！

	技能2
	onAtk2Done：播放atk2   root与目标midPoin对齐！

	普通技能
	onAtkDone：播放atk   root与目标midPoin对齐！
]]
function Snhth:doAnimationEvent(event)

    local name = event.eventData.name
    local _animalName = self:getNowAniName()
    if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
        --[[ 去除阴影 ]]
    else
        if name == "onAtk1Done2" or name == "onAtk1Done3" then
            _animalName = BATTLE_ANIMATION_ACTION.ATK1
        end

        local _skillData = self:getSkillByAction(_animalName)
        local targets = self:getSelectedTargets(_animalName)
        targets = self:getHurtableTargets( { selectedTargets = targets, skill = _skillData })
        if targets ~= nil then
            --[[ 如果是大招，则需要单独处理一些事务，例如击退、震屏 ]]
            if name == "down" then
                XTHD.dispatchEvent( {
                    name = EVENT_NAME_SHAKE_SCREEN,
                    data = { delta = 20, time = 0.3 },
                } )
                self:_selfStopSkillTarget(true)
                self:doHurt( { skill = _skillData, targets = targets, addMingzhongMp = false })
            elseif name == "up" then
                XTHD.dispatchEvent( {
                    name = EVENT_NAME_SHAKE_SCREEN,
                    data = { delta = 20, time = 0.3 },
                } )
                self:_catchTargets(targets)
                self:doHurt( { skill = _skillData, targets = targets, addMingzhongMp = true })
            elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done then
                XTHD.dispatchEvent( {
                    name = EVENT_NAME_SHAKE_SCREEN,
                    data = { delta = 20, time = 0.3 },
                } )
                for k, v in pairs(targets) do
                    if v and v:isAlive() then
                        v:playAnimation(BATTLE_ANIMATION_ACTION.DEFENSE, false)
                    end
                end

                self:doHurt( { skill = _skillData, targets = targets, addMingzhongMp = false })
            elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
                local _target = targets[1]
                local effect_spine = self:getEffectSpineFromCache("res/spine/effect/006/atk1")
                effect_spine:setAnimation(0, "atk1", false)
                local _startPos = self:getSlotPositionInWorld("root")
                effect_spine:setPosition(cc.p(_startPos.x, _startPos.y))
                effect_spine:setScale(self:getScaleY())
                if self:getScaleX() > 1 then
                    effect_spine:setScaleX(-1 * effect_spine:getScaleX())
                end

                local _enemyPos = _target:getSlotPositionInWorld("root")
                local _posXSub = 160 + self:getBox().width / 2 + _target:getBox().width / 2
                if tonumber(_startPos.x) > tonumber(_enemyPos.x) then
                    _posXSub = _posXSub
                    if tonumber(_startPos.x) <= tonumber(_enemyPos.x) + _posXSub then
                        _posXSub = tonumber(_startPos.x) - tonumber(_enemyPos.x)
                    end
                else
                    _posXSub = -1 * _posXSub
                    if tonumber(_startPos.x) >= tonumber(_enemyPos.x) + _posXSub then
                        _posXSub = tonumber(_startPos.x) - tonumber(_enemyPos.x)
                    end
                end
                local _endPos = cc.p(_enemyPos.x + _posXSub, _startPos.y)
                local _dtime = math.abs(0.1 / 300 *(_endPos.x - _startPos.x))
                if math.abs(_endPos.x - _startPos.x) > 200 then
                    XTHD.dispatchEvent( {
                        name = EVENT_NAME_BATTLE_PLAY_EFFECT,
                        data = { node = effect_spine, zorder = self:getLocalZOrder() -1 },
                    } )
                    performWithDelay(effect_spine, function()
                        effect_spine:removeFromParent()
                    end , 0.4)
                end
                self:playAnimation("atk_2", true)
                self:runAction(cc.Sequence:create(cc.EaseIn:create(cc.MoveTo:create(_dtime * 1.1, _endPos), _dtime), cc.CallFunc:create( function()
                    if self:getAnimationName() == "atk_2" then
                        self:playAnimation("atk_3", false)
                    end

                end )))
            elseif name == "onAtk1Done2" then
                local _target = targets[1]
                if _target and _target:isAlive() then
                    local effect_spine = self:getEffectSpineFromCache("res/spine/effect/006/atk1")
                    _target:addNodeForSlot( { node = effect_spine, slotName = "midPoint", zorder = 10 })
                    -- if _target:getScaleX()<0 then
                    effect_spine:setScaleX(-1 * effect_spine:getScaleX())
                    -- end
                    self:doHurt( { skill = _skillData, targets = targets })

                    effect_spine:setAnimation(0, "atk1_1", false)
                    performWithDelay(effect_spine, function()
                        effect_spine:removeFromParent()
                    end , 0.4666)
                end
            elseif name == "onAtk1Done3" then
                local _target = targets[1]
                if _target and _target:isAlive() then
                    local effect_spine = self:getEffectSpineFromCache("res/spine/effect/006/atk1")
                    _target:addNodeForSlot( { node = effect_spine, slotName = "midPoint", zorder = 10 })
                    -- if _target:getScaleX()<0 then
                    effect_spine:setScaleX(-1 * effect_spine:getScaleX())
                    -- end
                    self:doHurt( { skill = _skillData, targets = targets })

                    effect_spine:setAnimation(0, "atk1_2_2", false)
                    performWithDelay(effect_spine, function()
                        effect_spine:removeFromParent()
                    end , 0.4666)
                end
            elseif name == "onAtk2Done2" then
                local _target = targets[1]
                if _target and _target:isAlive() then
                    local effect_spine = self:getEffectSpineFromCache("res/spine/effect/006/atk2")
                    _target:addNodeForSlot( { node = effect_spine, slotName = "midPoint", zorder = 10 })
                    -- if _target:getScaleX()<0 then
                    effect_spine:setScaleX(-1 * effect_spine:getScaleX())
                    -- end
                    effect_spine:setAnimation(0, "atk2", false)
                    performWithDelay(effect_spine, function()
                        effect_spine:removeFromParent()
                    end , 1.8333)
                    -- self:doHurt({skill = _skillData,targets = targets})
                end
            elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
                self:doHurt( { skill = _skillData, targets = targets })
            elseif name == BATTLE_ANIMATION_EVENT.onAtkDone then
                local _target = targets[1]
                if _target and _target:isAlive() then
                    local effect_spine = self:getEffectSpineFromCache("res/spine/effect/006/atk")
                    _target:addNodeForSlot( { node = effect_spine, slotName = "midPoint", zorder = 10 })
                    effect_spine:setAnimation(0, "atk", false)
                    performWithDelay(effect_spine, function()
                        effect_spine:removeFromParent()
                    end , 0.1666)
                    self:doHurt( { skill = _skillData, targets = targets })
                end
            end
        end
        --[[ if end ]]

    end

end

function Snhth:_catchTargets(targets)
    self._catchTb = { }
    for k, v in pairs(targets) do
        if v:isAlive() then
            local _tb = { }
            _tb.tar = v
            local effect_spine2 = self:getEffectSpineFromCache("res/spine/effect/006/atk0")
            effect_spine2:setAnimation(0, "atk0_1", false)
            v:addNodeForSlot( { node = effect_spine2, slotName = "midPoint", zorder = 10 })
            performWithDelay(effect_spine2, function()
                effect_spine2:removeFromParent()
                _tb._hurt = nil
            end , 1.8333)
            _tb._hurt = effect_spine2
            if not v:isWorldBoss() then
                local _posY = math.random(180, 200)
                _tb._y = _posY
                v:setPositionY(v:getPositionY() + _posY)
                -- v:runAction(cc.MoveBy:create(0.1, cc.p(0, _posY)))
                v:setBeCatched(true)
                v:setTargetable(true)
                v:setHurtable(true)
                v:_removeSelfDim()
                v:changeToIdel()
                local effect_spine = self:getEffectSpineFromCache("res/spine/effect/006/atk0")
                local _pos = v:getSlotPositionInWorld("root")
                effect_spine:setAnimation(0, "atk0", false)
                effect_spine:setPosition(_pos)
                XTHD.dispatchEvent( {
                    name = EVENT_NAME_BATTLE_PLAY_EFFECT,
                    data = { node = effect_spine, zorder = v:getLocalZOrder() },
                } )
                performWithDelay(effect_spine, function()
                    effect_spine:removeFromParent()
                    _tb._eff = nil
                end , 2.5)
                _tb._eff = effect_spine
            end
            self._catchTb[#self._catchTb + 1] = _tb
        end
    end
end

function Snhth:_selfStopSkillTarget(isNormalOver)
    if self._catchTb and next(self._catchTb) ~= nil then
        for k, v in pairs(self._catchTb) do
            if v.tar then
                if v.tar:isAlive() then
                    if v._hurt then
                        v._hurt:removeFromParent()
                    end
                    if not isNormalOver and v._eff then
                        v._eff:removeFromParent()
                    end
                    if not v.tar:isWorldBoss() and v.tar:isBeCatched() then
                        v.tar:setBeCatched(false)
                        local _posY = v.tar:getDefualtRootY()
                        if v.tar:getPositionY() ~= _posY then
                            v.tar:setPositionY(_posY)
                        end
                    end
                end
            end
        end
    end
    self._catchTb = { }
end

function Snhth:setStatus(status)
    self._status = status
    self:_selfStopSkillTarget()
    --[[ --如果被眩晕，则移除黑屏，否则被眩晕以后可能会被卡住 ]]
	self:_removeSelfDim()
    if status == BATTLE_STATUS.DIZZ then
        self:_removeSelfDim()
    end
end

function Snhth:doSuperAnimationStart(event)
    --
    local _animalName = self:getNowAniName()
    local _skillData = self:getSkillByAction(_animalName)
    XTHD.playSkillEffectAndPlaySound(_skillData["skill_pic"], _skillData["skill_tak"], self:getSide())
end

function Snhth:create(params)
    return Snhth.new(params)
end

return Snhth