Character = class("Character", function(params)
    local resourceId = params.resourceId
    local spineID = string.format("%03d", resourceId)
    print("spineID=" .. spineID)
    local skeletonNode = sp.SkeletonAnimation:createWithBinaryFile("res/spine/" .. spineID .. ".skel", "res/spine/" .. spineID .. ".atlas", 1)

    local star = 0
    if params.star then
        star = params.star
    elseif params.data then
        star = params.data.star or 0
    elseif params.monster then
        star = params.monster.star or 0
    end

    return XTHDTouchExtend.extend(skeletonNode)
end )
function Character:ctor(params)
    self:getSlotPositionInWorld("firePoint")
    self:getSlotPositionInWorld("root")
    self:getSlotPositionInWorld("midPoint")
    local _node = cc.Node:create()
    self:addChild(_node)
    self._unPauseNode = _node
    local id = params.id
    local heroType = params._type
    local isNpc = params.isNpc
    local monster = params.monster
    local helps = params.helps
    local m_startHp = params.startHp
    local m_startMaxHp = params.startMaxHp
    local m_startSp = params.startSp
    local m_startMaxSp = params.startMaxSp
    local isWorldBoss = params.isWorldBoss
    self._isGuidingHero = params.isGuidingHero
    if self._isGuidingHero then
        m_startMaxHp = 80000
        m_startHp = 80000
    end
    if isNpc == nil then
        isNpc = false
    end
    if isWorldBoss == nil then
        isWorldBoss = false
    end
    if heroType == nil then
        heroType = ANIMAL_TYPE.PLAYER
        print("error------类型不正确")
    end
    print("params.id------" .. tostring(params.id))
    local condition = { heroid = id }
    local heroData
    if heroType == ANIMAL_TYPE.PLAYER then
        heroData = gameData.getDataFromCSV("GeneralInfoList", condition)
    elseif heroType == ANIMAL_TYPE.MONSTER then
        if monster ~= nil then
            heroData = monster
        else
            heroData = gameData.getDataFromCSV("EnemyList", { monsterid = id })
        end
        heroData.advance = heroData.rank
        condition = {
            heroid = heroData.heroid
        }
        id = heroData.monsterid
    end
    self._heroId = heroData.heroid
    if self._heroId == 801 then
        isWorldBoss = true
    end
    local staticHeroSkillData = gameData.getDataFromCSV("GeneralSkillList", condition)
    local _skill_ = {
        "talent",
        "skillid",
        "skillid0",
        "skillid1",
        "skillid2",
        "skillid3"
    }
    self._skills = { }
    for key, value in pairs(_skill_) do
        local staticSkillData = gameData.getDataFromCSV("JinengInfo", {
            skillid = staticHeroSkillData[value]
        } )
        staticSkillData._buffData = { }
        for i = 1, 3 do
            local buffid = tonumber(staticSkillData["buff" .. i .. "id"]) or 0
            if buffid > 0 then
                local buffData = gameData.getDataFromCSV("Jinengbuff", { buffid = buffid })
                staticSkillData._buffData[i] = buffData
            end
        end
        if heroType == ANIMAL_TYPE.MONSTER then
            staticSkillData.level = 1
        end
        self._skills[value] = staticSkillData
    end
    self._buffNode = { }
    for i = 1, 3 do
        self._buffNode[i] = cc.Node:create()
        self:addChild(self._buffNode[i])
        self._buffNode[i].buffTb = { }
    end
    local scale = heroData.scale
    local attackrange = heroData.attackrange
    local attackprocess = heroData.attackprocess
    attackprocess = string.gsub(attackprocess, "#", "")
    self._scale = tonumber(scale)
    self._stand_range = tonumber(attackrange)
    self:setScale(scale)
    local hpBarPointBone = self:getNodeForSlot("hpBarPoint")
    self._hpBarBG = XTHD.createSprite("res/image/tmpbattle/hp_black_small.png")
    hpBarPointBone:addChild(self._hpBarBG)
    self._hpBarBG:setScale(1 / math.abs(self:getScaleX()))
    self._hpActionBar = cc.ProgressTimer:create(XTHD.createSprite("res/image/tmpbattle/hp_yellow_small.png"))
    self._hpActionBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._hpActionBar:setMidpoint(cc.p(0, 0.5))
    self._hpActionBar:setPercentage(100)
    self._hpActionBar:setBarChangeRate(cc.p(1, 0))
    self._hpActionBar:setAnchorPoint(cc.p(0.5, 0.5))
    self._hpActionBar:setPosition(cc.p(self._hpBarBG:getContentSize().width / 2, self._hpBarBG:getContentSize().height / 2))
    self._hpBarBG:addChild(self._hpActionBar)
    self._hpBar = cc.ProgressTimer:create(XTHD.createSprite("res/image/tmpbattle/hp_red_small.png"))
    self._hpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._hpBar:setMidpoint(cc.p(0, 0.5))
    self._hpBar:setBarChangeRate(cc.p(1, 0))
    self._hpBar:setPercentage(100)
    self._hpBar:setAnchorPoint(cc.p(0.5, 0.5))
    self._hpBar:setPosition(self._hpActionBar:getPosition())
    self._hpBarBG:addChild(self._hpBar)
    self._hpBarBG:setVisible(false)
    local split = function(data)
        local skillTab = { }
        if string.len(data) == 0 then
            return skillTab
        end
        for i = 1, string.len(data) do
            local subStr = string.sub(data, i, i)
            skillTab[#skillTab + 1] = subStr
        end
        return skillTab
    end
    if heroType == ANIMAL_TYPE.PLAYER and not helps and not params.data then
        local _tmpSkill = DBTableHeroSkill.getData(gameUser.getUserId(), condition)
        for key, value in pairs(self._skills) do
            if _tmpSkill[key .. "lv"] ~= nil then
                value.level = _tmpSkill[key .. "lv"]
            end
        end
        local skillid1lv = _tmpSkill.skillid1lv or 0
        local skillid2lv = _tmpSkill.skillid2lv or 0
        local skillid3lv = _tmpSkill.skillid3lv or 0
        if skillid1lv == 0 then
            attackprocess = string.gsub(attackprocess, "1", "")
        end
        if skillid2lv == 0 then
            attackprocess = string.gsub(attackprocess, "2", "")
        end
        if skillid3lv == 0 then
            attackprocess = string.gsub(attackprocess, "3", "")
        end
        local dynamicHeroData = DBTableHero.getData(gameUser.getUserId(), condition)
        dynamicHeroData.charId = gameUser.getUserId()
        for k, v in pairs(dynamicHeroData) do
            heroData[k] = v
        end
    elseif heroType == ANIMAL_TYPE.MONSTER and heroData.skilllevel then
        local monster_skilllevel = string.split(tostring(heroData.skilllevel), "#")
        local index = 1
        for key, value in pairs(self._skills) do
            if monster_skilllevel[index] ~= nil then
                value.level = tonumber(monster_skilllevel[index])
            end
            index = index + 1
        end
    end
    if params.data then
        local _data_ = params.data
        local property = _data_.property
        local skill = _data_.skill
        local Params = { }
        Params.level = tonumber(_data_.level)
        Params.star = tonumber(_data_.star)
        Params.advance = tonumber(_data_.phase)
        Params.curHp = tonumber(_data_.curHp)
        Params.charId = tonumber(_data_.charId) or gameUser.getUserId()
        Params.power = tonumber(property["407"]) or 0
        Params.hp = tonumber(property["200"]) or 0
        Params.physicalattack = tonumber(property["201"]) or 0
        Params.physicaldefence = tonumber(property["202"]) or 0
        Params.manaattack = tonumber(property["203"]) or 0
        Params.manadefence = tonumber(property["204"]) or 0
        Params.hit = tonumber(property["300"]) or 0
        Params.dodge = tonumber(property["301"]) or 0
        Params.crit = tonumber(property["302"]) or 0
        Params.crittimes = tonumber(property["303"]) or 0
        Params.anticrit = tonumber(property["304"]) or 0
        Params.antiattack = tonumber(property["305"]) or 0
        Params.attackbreak = tonumber(property["306"]) or 0
        Params.antiphysicalattack = tonumber(property["307"]) or 0
        Params.physicalattackbreak = tonumber(property["308"]) or 0
        Params.antimanaattack = tonumber(property["309"]) or 0
        Params.manaattackbreak = tonumber(property["310"]) or 0
        Params.suckblood = tonumber(property["311"]) or 0
        Params.heal = tonumber(property["312"]) or 0
        Params.behealed = tonumber(property["313"]) or 0
        Params.antiangercost = tonumber(property["314"]) or 0
        Params.hprecover = tonumber(property["315"]) or 0
        Params.angerrecover = tonumber(property["316"]) or 0
        for k, v in pairs(Params) do
            heroData[k] = v
        end
        for k, v in pairs(_skill_) do
            if skill[k] ~= nil then
                self._skills[v].level = tonumber(skill[k])
            end
        end
        for k, v in pairs(self._skills) do
            if 1 > v.level then
                if k == "skillid1" then
                    attackprocess = string.gsub(attackprocess, "1", "")
                elseif k == "skillid2" then
                    attackprocess = string.gsub(attackprocess, "2", "")
                elseif k == "skillid3" then
                    attackprocess = string.gsub(attackprocess, "3", "")
                end
            end
        end
        print(self._heroId .. "对手处理后的攻击序列：attackprocess=" .. tostring(attackprocess))
    elseif params.monster then
    elseif params.helps then
        for k, v in pairs(helps) do
            heroData[k] = v
        end
        if heroData.skilllevel then
            local monster_skilllevel = string.split(tostring(heroData.skilllevel), "#")
            local index = 1
            for k, v in pairs(_skill_) do
                if monster_skilllevel[k] ~= nil then
                    self._skills[v].level = tonumber(monster_skilllevel[k])
                end
            end
        end
    end
    self._attackprocess = split(tostring(attackprocess))
    self._attackcount = { }
    self._hitcount = { }
    self:registerSpineEventHandler( function(event)
        if self:doOtherAnimationStartCheck(event) then
            return
        end
        local name = event.animation
        self:_doAttackAnimationStart(event)
        if name == BATTLE_ANIMATION_ACTION.DEATH then
        elseif name == BATTLE_ANIMATION_ACTION.ATTACK then
            self._canStartMove = true
        end
        self:doAnimationStart(event)
    end , sp.EventType.ANIMATION_START)
    self:registerSpineEventHandler( function(event)
        self:doAnimationEnd(event)
    end , sp.EventType.ANIMATION_END)
    self:registerSpineEventHandler( function(event)
        if self:doOtherAnimationCompleteCheck(event) then
            return
        end
        self:_doAnimationComplete(event)
    end , sp.EventType.ANIMATION_COMPLETE)
    self:registerSpineEventHandler( function(event)
        if self:doOtherAnimationEventCheck(event) then
            return
        end
        local name = event.eventData.name
        if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
            self:_removeSelfDim()
        else
            self:addAttackCountOnce(name)
        end
        self:doAnimationEvent(event)
    end , sp.EventType.ANIMATION_EVENT)
    local hp = heroData.hp
    local hprecover = heroData.hprecover
    local angerrecover = heroData.angerrecover
    local beginanger = heroData.beginanger
    local antiangercost = heroData.antiangercost
    local suckblood = heroData.suckblood
    if suckblood == nil then
        suckblood = 0
    end
    if beginanger == nil then
        beginanger = 0
    end
    if antiangercost == nil then
        antiangercost = 0
    end
    self._heroData = heroData
    self._dataNode = CharacterData:create(heroData)
    self:addChild(self._dataNode)
    self._id = id
    self._restoredHeroData = clone(heroData)
    self._isMoving = false
    self._lastAttackTime = 0
    self._status = BATTLE_STATUS.IDLE
    if self._heroData.hp then
        self:setHpTotal(self._heroData.hp)
    elseif self._heroData.curHp then
        self:setHpTotal(self._heroData.curHp)
    end
    if self._heroData.curHp then
        self:setHpBegin(self._heroData.curHp)
    else
        self:setHpBegin(self._heroData.hp)
    end
    self._side = BATTLE_SIDE.LEFT
    self._heroType = heroType
    self._targets_with_attackrange = { }
    self._paused = false
    self:setCascadeColorEnabled(true)
    self._dimCount = 0
    self._standId = 0
    self._hp_extra = 0
    self._normalAtkCount = 0
    self._canStartMove = false
    self._startFight = false
    self._isUseTalent = false
    self._animationName = ""
    self._detectable = true
    self._hurtable = true
    self._hprecover = hprecover
    self._angerrecover = angerrecover
    self._beginanger = beginanger
    self._isInFight = false
    self._noramlPause = false
    self._yd_bian = false
    self._mp_now = beginanger
    self._wave = 1
    self:setHpNow(self:getHpBegin())
    self._antiangercost = antiangercost
    self._suckblood = suckblood
    self._isNpc = isNpc
    self._isWorldBoss = isWorldBoss
    self._isStageBoss = heroData.mark == 1 and true or false
    self._isMonsterImmunize = heroData.res == 1 and true or false
    self._isAlive = true
    self._isAddict = false
    self._isPetrifaction = false
    self._isTargetable = true
    self._isFroze = false
    self._isFreeze = false
    self._isHiding = false
    self._isBeCatched = false
    self._isImmuneControl = false
    self._isSilence = false
    self._cannotmove = false
    self._isCannotBemoved = false
    self._moveSpeedScale = 1
    self._speedScale = 1
    if m_startMaxHp and tonumber(m_startMaxHp) ~= 0 then
        self:setHpTotal(m_startMaxHp)
    end
    if m_startHp and tonumber(m_startHp) ~= 0 then
        self:setHpBegin(m_startHp)
        self:setHpNow(m_startHp)
        self:freshHpBarStart()
    end
    if m_startSp and tonumber(m_startSp) ~= 0 then
        self:setMp(m_startSp)
    end
    if self._isStageBoss then
        local _data = {
            file = "res/image/tmpbattle/effect/buff/dizuo",
            name = "dizuo",
            startIndex = 1,
            endIndex = 4,
            perUnit = 0.1
        }
        _node = XTHD.createSpriteFrameSp(_data)
        _node:setScale(self:getScaleY())
        self:addNodeForSlot( {
            node = _node,
            slotName = "root",
            zorder = - 10
        } )
    end
    if self._isMonsterImmunize then
        local _node = self:getEffectSpineFromCache("res/image/tmpbattle/effect/buff/bati")
        _node:setScale(_node:getScaleY())
        self:addNodeForSlot( { node = _node, slotName = "midPoint" })
        _node:setAnimation(0, "animation", true)
    end
end
function Character:getInFight()
    return self._isInFight
end
function Character:setInFight(_inFight)
    self._isInFight = _inFight
    if self._coverAction then
        self:stopAction(self._coverAction)
        self._coverAction = nil
    end
    if _inFight == true then
        self:startMpTimeRecover()
    end
end
function Character:setLineNum(num)
    self._defaultLineNum = tonumber(num) or 0
end
function Character:getLineNum(...)
    return self._defaultLineNum or 0
end
function Character:setDefualtRootY(sPosY)
    if sPosY then
        self._defaultRootY = sPosY
    else
        local _pos = self:getSlotPositionInWorld("root")
        self._defaultRootY = _pos and _pos.y or 0
    end
    local _mod, _ceil = math.modf(self._defaultRootY / 1)
    if _ceil >= 0.4 then
        self._defaultRootY = math.ceil(self._defaultRootY)
    elseif _ceil < 0.4 then
        self._defaultRootY = math.floor(self._defaultRootY)
    end
end
function Character:getDefualtRootY()
    return self._defaultRootY or 0
end
function Character:getMoveSpeedScale(...)
    return self._moveSpeedScale
end
function Character:setMoveSpeedScale(moveSpeedScale)
    self._moveSpeedScale = tonumber(moveSpeedScale) or 1
    self._moveSpeedScale = self._moveSpeedScale <= 0 and 0.1 or self._moveSpeedScale
end
function Character:isImmuneControl(...)
    return self._isImmuneControl
end
function Character:setImmuneControl(immuneControl)
    self._isImmuneControl = immuneControl
end
function Character:isSilence()
    return self._isSilence
end
function Character:setSilence(hiding)
    if hiding == true and(self:isImmuneControl() or self:isWorldBoss()) then
        return
    end
    self._isSilence = hiding
end
function Character:isCannotMove()
    return self._cannotmove
end
function Character:setCannotMove(cannotmove)
    if cannotmove == true then
    end
    self._cannotmove = cannotmove
end
function Character:getWaiImmune()
    return self._isWaiImmune
end
function Character:setWaiImmune(_isImmune)
    self._isWaiImmune = _isImmune
end
function Character:getNeiImmune()
    return self._isNeiImmune
end
function Character:setNeiImmune(_isImmune)
    self._isNeiImmune = _isImmune
end
function Character:isBeCatched(...)
    return self._isBeCatched
end
function Character:setBeCatched(beCached)
    if not beCached or beCached == true then
    else
    end
    self._isBeCatched = beCached
end
function Character:getSpeedScale()
    return self._speedScale
end
function Character:setSpeedScale(speedScale)
    local _num = tonumber(speedScale)
    if not _num then
        return
    end
    self._speedScale = _num
end
function Character:isHiding()
    return self._isHiding
end
function Character:setHiding(hiding)
    if hiding and hiding == true then
        XTHD.setShader(self, "res/shader/BanishShader.vsh", "res/shader/BanishShader.fsh")
    else
        self:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(cc.SHADER_POSITION_TEXTURE_COLOR_NO_MVP))
    end
    self._isHiding = hiding
end
function Character:isFreeze()
    return self._isFreeze
end
function Character:setFreeze(freeze)
    if self._isFreeze == freeze then
        return
    end
    if freeze == true and(self:isImmuneControl() or self:isWorldBoss() or self:isMonsterImmunize()) then
        return
    end
    self._isFreeze = freeze
    if freeze == true then
        self:pauseSelf(true)
    elseif self:isPetrifaction() == false and self:isFrozen() == false then
        self:resumeSelf(true)
    end
end
function Character:isFrozen()
    return self._isFroze
end
function Character:setFrozen(froze)
    if self._isFroze == froze then
        return
    end
    if froze == true and(self:isImmuneControl() or self:isWorldBoss() or self:isMonsterImmunize()) then
        return
    end
    self._isFroze = froze
    if froze == true then
        self:pauseSelf(true)
    elseif self:isPetrifaction() == false and self:isFreeze() == false then
        self:resumeSelf(true)
    end
end
function Character:_doAddSkillAtkCount(_skillData, count)
    local _count = count
    if not _count then
        self._attackcount[_skillData.skillid] = self._attackcount[_skillData.skillid] or 0
        _count = self._attackcount[_skillData.skillid] + 1
    end
    self._attackcount[_skillData.skillid] = _count
end
function Character:_doAddSkillHitCount(_skillData)
    self._hitcount[_skillData.skillid] = self._hitcount[_skillData.skillid] or { }
    self._hitcount[_skillData.skillid]._lastAtkCount = self._hitcount[_skillData.skillid]._lastAtkCount or 0
    self._hitcount[_skillData.skillid]._hitCount = self._hitcount[_skillData.skillid]._hitCount or 0
    if self._hitcount[_skillData.skillid]._lastAtkCount ~= self._attackcount[_skillData.skillid] then
        self._hitcount[_skillData.skillid]._lastAtkCount = self._attackcount[_skillData.skillid]
        self._hitcount[_skillData.skillid]._hitCount = self._hitcount[_skillData.skillid]._hitCount + 1
    end
end
function Character:_doAddAttackCount()
end
function Character:addAttackCountOnce(eventName)
    self:_doAddAttackCount()
end
function Character:getAngerSave()
    return self._antiangercost
end
function Character:setWave(wave)
    self._wave = wave
end
function Character:getWave()
    return self._wave
end
function Character:getSuckBlood()
    return self._suckblood
end
function Character:isAnimal()
end
function Character:freshHpBarStart()
    local percentage = self:getHpBegin() * 100 / self:getHpTotal()
    self._hpBar:setPercentage(percentage)
    self._hpActionBar:setPercentage(percentage)
end
function Character:reset()
    self._canStartMove = false
    self:setNormalAtkCount(0)
    self:setUseTalent(false)
    self:setSpeedScale(1)
    self:setSilence(false)
    self:setCannotMove(false)
    self:setFrozen(false)
    self:setFreeze(false)
    self._isAlive = true
    self:setAddict(false)
    self:setPetrifaction(false)
    self._isTargetable = true
    self:setOpacity(255)
    self._isBeCatched = false
    self._isImmuneControl = false
    self:setMoveSpeedScale(1)
    self:resetProcessIndex()
    self:setLastAttackTime(0)
    self:stopAllActions()
    self:setToSetupPose()
    self:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, false)
    self._heroData = clone(self._restoredHeroData)
    self._dataNode:resetData()
    self._hp_now = self:getHpBegin()
    self._hpBar:setPercentage(100)
    self._hpActionBar:setPercentage(100)
    self:setHurtable(true)
    self:removeBuffEffect()
    local firePoint = self:getNodeForSlot("firePoint")
    local root = self:getNodeForSlot("root")
    local midPoint = self:getNodeForSlot("midPoint")
    local tabs = { }
    if firePoint then
        tabs[#tabs + 1] = firePoint
    end
    if root then
        tabs[#tabs + 1] = root
    end
    if midPoint then
        tabs[#tabs + 1] = midPoint
    end
    for k, v in pairs(tabs) do
        v:removeAllChildren()
        v:setVisible(true)
    end
end
function Character:isTargetable()
    return self._isTargetable
end
function Character:setTargetable(target)
    self._isTargetable = target
end
function Character:isAddict()
    return self._isAddict
end
function Character:setAddict(flag)
    if hiding == true and(self:isImmuneControl() or self:isWorldBoss()) then
        return
    end
    self._isAddict = flag
end
function Character:isPetrifaction()
    return self._isPetrifaction
end
function Character:setPetrifaction(flag)
    if flag == self._isPetrifaction then
        return
    end
    if flag == true and(self:isImmuneControl() or self:isWorldBoss() or self:isMonsterImmunize()) then
        return
    end
    self._isPetrifaction = flag
    if flag == true then
        XTHD.setShader(self, "res/shader/GrayScalingShader.vsh", "res/shader/GrayScalingShader.fsh")
        self:setFreeze(true)
    else
        self:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(cc.SHADER_POSITION_TEXTURE_COLOR_NO_MVP))
        if self:isFrozen() == false and self:isFreeze() then
            self:setFreeze(false)
        end
    end
end
function Character:checkDataSafe()
    if self:getSide() == BATTLE_SIDE.RIGHT then
        return true
    end
    return self._dataNode:checkDataSafe()
end
function Character:getAttackWuLiOrigin()
    return self._dataNode:getAttackWuLiOrigin()
end
function Character:getAttackMoFaOrigin()
    return self._dataNode:getAttackMoFaOrigin()
end
function Character:getDefenseWuLiOrigin()
    return self._dataNode:getDefenseWuLiOrigin()
end
function Character:getDefenseMoFaOrigin()
    return self._dataNode:getDefenseMoFaOrigin()
end
function Character:getAttackWuLiNow()
    return self._dataNode:getAttackWuLiNow()
end
function Character:getAttackMoFaNow()
    return self._dataNode:getAttackMoFaNow()
end
function Character:getDefenseWuLiNow()
    return self._dataNode:getDefenseWuLiNow()
end
function Character:getDefenseMoFaNow()
    return self._dataNode:getDefenseMoFaNow()
end
function Character:getHitNow()
    return self._dataNode:getHitNow()
end
function Character:getDodgeNow()
    return self._dataNode:getDodgeNow()
end
function Character:getCritNow()
    return self._dataNode:getCritNow()
end
function Character:getCrittimesNow()
    return self._dataNode:getCrittimesNow()
end
function Character:getAnticritNow()
    return self._dataNode:getAnticritNow()
end
function Character:getAttackbreakNow()
    return self._dataNode:getAttackbreakNow()
end
function Character:getAntiattackNow()
    return self._dataNode:getAntiattackNow()
end
function Character:getPhysicalattackbreakNow()
    return self._dataNode:getPhysicalattackbreakNow()
end
function Character:getAntiphysicalattackNow()
    return self._dataNode:getAntiphysicalattackNow()
end
function Character:getManaattackbreakNow()
    return self._dataNode:getManaattackbreakNow()
end
function Character:getSuckbloodNow()
    return self._dataNode:getSuckbloodNow()
end
function Character:getHealNow()
    return self._dataNode:getHealNow()
end
function Character:getBehealedNow()
    return self._dataNode:getBehealedNow()
end
function Character:getAntiangercostNow()
    return self._dataNode:getAntiangercostNow()
end
function Character:getAntimanaattackNow()
    return self._dataNode:getAntimanaattackNow()
end
function Character:setAttributesByBuff(params)
    self._dataNode:setAttributesByBuff(params)
end
function Character:getStandRange()
    return self._stand_range
end
function Character:getHpRecover()
    return self._hprecover
end
function Character:getMpRecover()
    return self._angerrecover
end
function Character:getMpBegin()
    return self._beginanger
end
function Character:isHurtable()
    return self._hurtable
end
function Character:setHurtable(hurtable)
    self._hurtable = hurtable
end
function Character:isDetectable()
    return self._detectable
end
function Character:setDetectable(detectable)
    self._detectable = detectable
end
function Character:removeBuffEffect()
    if self:isHiding() == true then
        self:setHiding(false)
    end
    if self:isBeCatched() == true then
        self:setBeCatched(false)
    end
    self:setSpeedScale(1)
    for i = 1, 3 do
        self:removeBuffEffectByType(i)
    end
    if self:getHeroId() == 24 or self:getHeroId() == 13 then
        self:setBigToNormal()
    end
end
function Character:onCleanup()
    print("Character:onCleanup")
    self:_unregisterSpineEventHandler()
end
function Character:_unregisterSpineEventHandler()
    self:unregisterSpineEventHandler(sp.EventType.ANIMATION_START)
    self:unregisterSpineEventHandler(sp.EventType.ANIMATION_END)
    self:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
    self:unregisterSpineEventHandler(sp.EventType.ANIMATION_EVENT)
end
function Character:isNpc()
    return self._isNpc
end
function Character:isWorldBoss()
    return self._isWorldBoss
end
function Character:isStageBoss()
    return self._isStageBoss
end
function Character:isMonsterImmunize()
    return self._isMonsterImmunize
end
function Character:isCannotBemoved()
    return self._isCannotBemoved
end
function Character:setCannotBeMoved(isCan)
    self._isCannotBemoved = isCan
end
function Character:isAlive()
    return self._isAlive
end
function Character:isPaused()
    return self._paused
end
function Character:pauseSelf(isBuffPause)
    if isBuffPause == nil then
        self._noramlPause = true
    end
    self._paused = true
    doFuncForAllChild(self, function(node)
        if node == self._hpBarBG or node == self._hpActionBar or node == self._hpBar or node == self._unPauseNode then
            return
        end
        if isBuffPause then
            if not node._isBuffNode then
                node:pause()
            end
        else
            node:pause()
        end
    end )
end
function Character:resumeSelf(isBuffResume)
    if isBuffResume and self._noramlPause then
        return
    end
    if isBuffResume == nil then
        self._noramlPause = false
    end
    if self:isFrozen() or self:isPetrifaction() or self:isFreeze() then
        return
    end
    self._paused = false
    doFuncForAllChild(self, function(node)
        node:resume()
    end )
end
function Character:getId()
    return self._id
end
function Character:getHeroId()
    return self._heroId
end
function Character:getHeroData()
    return self._heroData
end
function Character:setStandId(id)
    self._standId = id
end
function Character:getStandId()
    return self._standId
end
function Character:getType()
    return self._heroType
end
function Character:setDimCount(count)
    if count == nil or count < 0 then
        count = 0
    end
    self._dimCount = count
end
function Character:getDimCount()
    return self._dimCount
end
function Character:_setCascadeColor(color)
    local function _func_(node)
        node:setColor(color)
        for k, node in pairs(node:getChildren()) do
            _func_(node)
        end
    end
    _func_(self)
end
function Character:showDim(dim)
    local color = cc.c3b(255, 255, 255)
    if dim == true then
        color = BATTLE_DIM_COLOR
    end
    self:_setCascadeColor(color)
    self._dim = dim
end
function Character:isDim()
    if self._dim == nil then
        self._dim = false
    end
    return self._dim
end
function Character:_removeSelfDim()
    self:showDim(false)
    self:setDimCount(0)
    XTHD.dispatchEvent( {
        name = EVENT_NAME_PLAY_SUPER_DIM_DISMISS,
        data =
        {
            heroid = self:getHeroId()
        }
    } )
end
function Character:setSide(side)
    self._side = side
end
function Character:getSide()
    return self._side
end
function Character:getQuality()
    local advance = self._heroData.advance or self._heroData.rank
    if advance == nil then
        advance = 1
    end
    local quality = 1
    if advance == 1 then
    elseif advance == 2 or advance == 3 then
        quality = 2
    elseif advance >= 4 and advance <= 6 then
        quality = 3
    elseif advance >= 7 and advance <= 10 then
        quality = 4
    elseif advance >= 11 and advance <= 15 then
        quality = 5
    elseif advance >= 16 then
        quality = 6
    end
    return quality
end
function Character:getStar()
    return self._heroData.star
end
function Character:getLevel()
    return self._heroData.level or 1
end
function Character:setHpTotal(total)
    self._hp_total = total
end
function Character:getHpTotal()
    return self._hp_total
end
function Character:getHpBegin()
    return self._hp_begin
end
function Character:setHpBegin(hp)
    self._hp_begin = hp
end
function Character:getHpNow()
    return self._hp_now
end
function Character:setHpNow(hp)
    self._hp_now = hp
    if self._hp_now < 0 then
        self._hp_now = 0
    end
end
function Character:getHpExtra()
    return self._hp_extra
end
function Character:setHpExtra(hp)
    self._hp_extra = hp
end
function Character:setMp(mp)
    self._mp_now = mp
    if self._mp_now < 0 then
        self._mp_now = 0
    elseif self._mp_now > self:getMpMax() then
        self._mp_now = self:getMpMax()
    end
end
function Character:getMp()
    return self._mp_now
end
function Character:getMpMax()
    local _num = self._heroData.powermax or 1000
    return _num
end
function Character:_getSkillHurt(skill)
    local skill_level = skill.level or 1
    local basedata = skill.basedata
    local levelupgrow = skill.levelupgrow
    local levelupbase = skill.levelupbase
    local datatype = skill.datatype
    local hurt = 0
    local hpMax = tonumber(self:getHpTotal())
    local hpNow = tonumber(self:getHpNow())
    local physicalattack = tonumber(self:getAttackWuLiNow())
    local physicaldefence = tonumber(self:getDefenseWuLiNow())
    local manaattack = tonumber(self:getAttackMoFaNow())
    local manadefence = tonumber(self:getDefenseMoFaNow())
    local _base = basedata / 10000 + levelupgrow / 10000 *(skill_level - 1)
    if datatype == 1 then
        hurt = hpMax * _base
    elseif datatype == 2 then
        hurt = hpNow * _base
    elseif datatype == 3 then
        hurt = physicalattack * _base
    elseif datatype == 4 then
        hurt = physicaldefence * _base
    elseif datatype == 5 then
        hurt = manaattack * _base
    elseif datatype == 6 then
        hurt = manadefence * _base
    elseif datatype == 7 then
        hurt = _base
    end
    hurt = hurt +(skill_level - 1) * levelupbase
    return hurt
end
function Character:_doAttackAnimationStart(event)
    local name = event.animation
    if name == BATTLE_ANIMATION_ACTION.SUPER or name == BATTLE_ANIMATION_ACTION.ATTACK or name == BATTLE_ANIMATION_ACTION.ATK1 or name == BATTLE_ANIMATION_ACTION.ATK2 or name == BATTLE_ANIMATION_ACTION.ATK3 then
        do
            local skill = self:getSkillByAction(name)
            self._attackcount[skill.skillid] = 0
            self._hitcount[skill.skillid] = { }
            if skill.sound and tostring(skill.sound) and 0 < string.len(tostring(skill.sound)) then
                performWithDelay(self, function()
                    musicManager.playEffect("res/sound/skill/" .. skill.sound .. ".mp3")
                end , skill.sound_delay / 1000)
            end
            if (name == BATTLE_ANIMATION_ACTION.ATK1 or name == BATTLE_ANIMATION_ACTION.ATK2 or name == BATTLE_ANIMATION_ACTION.ATK3) and not self:isWorldBoss() then
                do
                    local __sp = self:getEffectSpineFromCache("res/spine/effect/jineng/jineng")
                    local pos = self:getSlotPositionInWorld("root")
                    __sp:setPosition(pos)
                    XTHD.dispatchEvent( {
                        name = EVENT_NAME_BATTLE_PLAY_EFFECT,
                        data = { node = __sp, zorder = - 1 }
                    } )
                    __sp:setAnimation(0, "animation", false)
                    performWithDelay(__sp, function()
                        __sp:removeFromParent()
                    end , 0.53)
                end
            end
        end
    end
    if name == BATTLE_ANIMATION_ACTION.SUPER then
        self:doSuperAnimationStart(event)
    elseif name == BATTLE_ANIMATION_ACTION.WIN then
        self:removeBuffEffect()
    end
end
function Character:doSuperAnimationStart(event)
    local __sp = self:getEffectSpineFromCache("res/spine/effect/atk0_effect/daozhao")
    self:addNodeForSlot( {
        node = __sp,
        slotName = "root",
        zorder = - 10
    } )
    __sp:setAnimation(0, "animation", false)
    performWithDelay(__sp, function()
        __sp:removeFromParent()
    end , 1.5)
end
function Character:doAnimationStart(event)
end
function Character:doDeathAnimationStart(event)
    self:_removeSelfDim()
    self:removeBuffEffect()
    self:stopAllActions()
    self._eliAction = nil
    if self:getDefualtRootY() ~= self:getPositionY() then
        local pDis = math.abs(self:getPositionY() - self:getDefualtRootY())
        local pTime = pDis * 0.5 / 150
        if self:getPositionY() > self:getDefualtRootY() then
            pDis = - pDis
        end
        self:runAction(cc.MoveBy:create(pTime, cc.p(0, pDis)))
    end
    if self:getHeroId() == 20 then
        self:setBigToNormal()
    end
    local firePoint = self:getNodeForSlot("firePoint")
    local root = self:getNodeForSlot("root")
    local midPoint = self:getNodeForSlot("midPoint")
    local hpBar_slot = self:getNodeForSlot("hpBarPoint")
    performWithDelay(self, function()
        if firePoint then
            firePoint:setVisible(false)
            firePoint:removeAllChildren()
        end
        if root then
            root:setVisible(false)
            root:removeAllChildren()
        end
        if midPoint then
            midPoint:setVisible(false)
            midPoint:removeAllChildren()
        end
        if hpBar_slot then
            hpBar_slot:setVisible(false)
        end
    end , 1)
end
function Character:doAnimationEnd(event)
end
function Character:setDoOtherAnimationEventCheckFunction(_call)
    self._doOtherAnimationEventCheck = _call
end
function Character:doOtherAnimationEventCheck(event)
    if self._doOtherAnimationEventCheck then
        return self._doOtherAnimationEventCheck(event)
    end
    return false
end
function Character:setDoOtherAnimationStartCheckFunction(_call)
    self._doOtherAnimationStartCheck = _call
end
function Character:doOtherAnimationStartCheck(event)
    if self._doOtherAnimationStartCheck then
        return self._doOtherAnimationStartCheck(event)
    end
    return false
end
function Character:setDoOtherAnimationCompleteCheckFunction(_call)
    self._doOtherAnimationCompleteCheck = _call
end
function Character:doOtherAnimationCompleteCheck(event)
    if self._doOtherAnimationCompleteCheck then
        return self._doOtherAnimationCompleteCheck(event)
    end
    return false
end
function Character:_doAnimationComplete(event)
    local name = event.animation
    local skill = self:getSkillByAction(name)
    local tmp = false
    if event.animation == BATTLE_ANIMATION_ACTION.SUPER or event.animation == BATTLE_ANIMATION_ACTION.BIAN_SUPER or event.animation == BATTLE_ANIMATION_ACTION.ATTACK or event.animation == BATTLE_ANIMATION_ACTION.ATK1 or event.animation == BATTLE_ANIMATION_ACTION.ATK2 or event.animation == BATTLE_ANIMATION_ACTION.ATK3 or event.animation == BATTLE_ANIMATION_ACTION.DEFENSE or event.animation == BATTLE_ANIMATION_ACTION.BIAN_DEFENSE or event.animation == "atk0_1" and(self:getHeroId() == 12 or self:getHeroId() == 49) or event.animation == "atk0_3" and self:getHeroId() == 37 or event.animation == "atk1_1" and(self:getHeroId() == 34 or self:getHeroId() == 50) or event.animation == "atk_3" and self:getHeroId() == 6 or event.animation == "atk0_1" and self:getHeroId() == 42 then
        if event.animation ~= BATTLE_ANIMATION_ACTION.DEFENSE or event.animation ~= BATTLE_ANIMATION_ACTION.BIAN_DEFENSE then
            self:setLastAttackTime(0)
        end
        local status = self:getStatus()
        if status == BATTLE_STATUS.DIZZ then
            if self:getYD_Bian() then
                self:playAnimation(BATTLE_ANIMATION_ACTION.BIAN_DIZZ, true)
            else
                self:playAnimation(BATTLE_ANIMATION_ACTION.DIZZ, true)
            end
            self:setStatus(BATTLE_STATUS.DIZZ)
        else
            self:setStatus(BATTLE_STATUS.IDLE)
            self:changeToIdel()
        end
        return
    elseif event.animation == BATTLE_ANIMATION_ACTION.DEATH or event.animation == BATTLE_ANIMATION_ACTION.BIAN_DEATH then
        local actionFadeout = cc.FadeOut:create(0.3)
        local function func_hide()
            self:setVisible(false)
        end
        local actionCallfunc = cc.CallFunc:create(func_hide)
        local seqAction = cc.Sequence:create(actionFadeout, actionCallfunc)
        self:runAction(seqAction)
        print("死亡动画结束" .. "id=" .. tostring(id))
    elseif event.animation == BATTLE_ANIMATION_ACTION.BIAN then
        self:setYD_Bian(true)
        self:changeToIdel()
    else
        tmp = true
    end
end
function Character:doAnimationEvent(event)
    local name = event.eventData.name
    if name == BATTLE_ANIMATION_EVENT.onAtk0Begin then
    else
        local _animalName = self:getNowAniName()
        local _skillData = self:getSkillByAction(_animalName)
        local targets = self:getSelectedTargets(_animalName)
        self:doHurt( { skill = _skillData, targets = targets })
    end
end
function Character:setYD_Bian(yd_bian)
    self._yd_bian = yd_bian
end
function Character:getYD_Bian()
    return self._yd_bian
end
function Character:setStatus(status)
    self._status = status
    if status == BATTLE_STATUS.DIZZ then
        self:_removeSelfDim()
    end
end
function Character:getStatus()
    return self._status
end
function Character:playSuperSkill()
    self:setStatus(BATTLE_STATUS.SUPER)
    print("播放大招，需要重写")
end
function Character:getLastAttackTime()
    return self._lastAttackTime == nil and 0 or self._lastAttackTime
end
function Character:setLastAttackTime(time)
    self._lastAttackTime = time
end
function Character:setSelectedTargets(params)
    local name = params.name
    local targets = params.targets
    self._targets_with_attackrange[name] = targets
end
function Character:getSelectedTargets(atkName)
    if self._targets_with_attackrange == nil then
        self._targets_with_attackrange = { }
    end
    return self._targets_with_attackrange[atkName]
end
function Character:getNowSkillTarges(_skill)
    local data = { animal = self, skill = _skill }
    XTHD.dispatchEvent( { name = EVENT_NAME_BATTLE_GET_ALL_ATTACKABLE_TARGETS, data = data })
    local targets = data.targets
    return targets
end
function Character:getHurtableTargets(params)
    local selectedTargets = params.selectedTargets
    local skill = params.skill
    local targets = { }
    local _cantBeTarget = function(hurtTarget)
        if hurtTarget:isAlive() == false or hurtTarget:isHurtable() == false then
            return true
        end
        return false
    end
    if selectedTargets ~= nil then
        if #selectedTargets > 1 then
            for k, hurtTarget in pairs(selectedTargets) do
                local condition = true
                if _cantBeTarget(hurtTarget) == true then
                    condition = false
                end
                if condition == true then
                    targets[#targets + 1] = hurtTarget
                end
            end
        elseif #selectedTargets == 1 then
            local selectedTarget = selectedTargets[1]
            targets[#targets + 1] = selectedTarget
            local hurtRange = self:getSkillHurtRangeBySkill(skill)
            if hurtRange > 0 then
                local side = BATTLE_SIDE.LEFT
                if self:getSide() == BATTLE_SIDE.LEFT then
                    side = BATTLE_SIDE.RIGHT
                else
                    side = BATTLE_SIDE.LEFT
                end
                local data = { side = side }
                XTHD.dispatchEvent( { name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS, data = data })
                if data.team ~= nil then
                    for k, hurtTarget in pairs(data.team) do
                        local midPoint = selectedTarget:getSlotPositionInWorld("midPoint")
                        local isInHurtRange, distance = circleIntersectRect(midPoint, hurtRange, hurtTarget:getBox())
                        if isInHurtRange == true then
                            local condition = true
                            if selectedTarget == hurtTarget or _cantBeTarget(hurtTarget) == true then
                                condition = false
                            end
                            if condition == true then
                                targets[#targets + 1] = hurtTarget
                            end
                        end
                    end
                end
            end
        end
    end
    if #targets < 1 then
        print(tostring(self:getHeroId()) .. "没有选中的攻击目标,hurtType=" .. skill.target .. ",skill=" .. skill.skillid)
    end
    return #targets > 0 and targets or nil
end
function Character:setFaceDirection(direction)
    if direction == nil then
        direction = BATTLE_DIRECTION.RIGHT
    end
    self._direction = direction
    if direction == BATTLE_DIRECTION.LEFT then
        self:setScaleX(-1 * math.abs(self:getScaleX()))
    else
        self:setScaleX(math.abs(self:getScaleX()))
    end
end
function Character:getFaceDirection()
    return self._direction or BATTLE_DIRECTION.RIGHT
end
function Character:getProcessIndex()
    local index = 1
    index = self._attackIndex == nil and -1 or self._attackIndex
    return index == 0 and 1 or index
end
function Character:resetProcessIndex()
    self._attackIndex = -1
end
function Character:gotoNextAttackProcessIndex()
    local index = self:getProcessIndex()
    local next_index = index + 1
    if index == -1 then
        next_index = 2
    end
    if next_index > #self:getAttackProcess() then
        next_index = 1
    end
    self._attackIndex = next_index
end
function Character:gotoBackAttackProcessIndex()
    local index = self:getProcessIndex()
    if index == -1 then
        self._attackIndex = 1
    else
        self._attackIndex = self._attackIndex - 1
    end
    if self._attackIndex < 1 then
        self._attackIndex = 1
    end
end
function Character:getAttackProcess()
    return self._attackprocess == nil and { } or self._attackprocess
end
function Character:move(speed, toCheck)
    if self:isWorldBoss() then
        return
    end
    local condition = false
    if (self:getStatus() == BATTLE_STATUS.RUN or self:getStatus() == BATTLE_STATUS.WALK) and self:isMoving() == true and self:isPaused() == false and not self:isBeCatched() then
        condition = true
    end
    if self:isCannotMove() then
        condition = false
    end
    if condition == true then
        if speed == nil then
            speed = MOVE_SPEED
        end
        if self:getStatus() == BATTLE_STATUS.WALK then
        end
        local x = self:getPositionX()
        local diff = speed * self:getMoveSpeedScale()
        if self:getFaceDirection() ~= BATTLE_DIRECTION.RIGHT then
            diff = - diff
        end
        x = x + diff
        if toCheck ~= false then
            local pNum = 20
            local needTurn = false
            if diff > 0 and x > cc.Director:getInstance():getWinSize().width - pNum then
                x = cc.Director:getInstance():getWinSize().width - pNum
                needTurn = true
            elseif diff < 0 and pNum > x then
                x = pNum
                needTurn = true
            end
            if needTurn then
                self:setFaceDirection(self:getFaceDirection() == BATTLE_DIRECTION.RIGHT and BATTLE_DIRECTION.LEFT or BATTLE_DIRECTION.RIGHT)
            end
        end
        self:setPositionX(x)
    end
end
function Character:moveY(speed)
    if self:isWorldBoss() then
        return
    end
    local condition = false
    if self:getStatus() == BATTLE_STATUS.RUN or self:getStatus() == BATTLE_STATUS.WALK then
        condition = true
    end
    if self:isCannotMove() then
        condition = false
    end
    if self:isPaused() == false and condition == true then
        local y = self:getPositionY()
        local diff = speed
        y = y + diff
        self:setPositionY(y)
        self:setDefualtRootY()
    end
end
function Character:addNormalAtkTimes()
    self._normalAtkCount = self._normalAtkCount + 1
end
function Character:setNormalAtkCount(_num)
    self._normalAtkCount = tonumber(_num) or 0
end
function Character:getNormalAtkTimes()
    return self._normalAtkCount
end
function Character:setMove(flag)
    if self:isWorldBoss() and flag == true then
        return
    end
    self._isMoving = flag
end
function Character:isMoving()
    return self._isMoving
end
function Character:getSkillCdByAction(_skillData)
    local _timeScale = self:getSpeedScale()
    local cd = _skillData.coldtime *(2 - _timeScale)
    if cd < 0 then
        cd = 0
    end
    return cd
end
function Character:getSkills()
    return self._skills
end
function Character:hasSuperSkill()
    if tonumber(self._skills.skillid0) and tonumber(self._skills.skillid0) > 0 then
        return true
    end
    return false
end
function Character:getSkillByAtkDone(name)
    local skillid = "skillid"
    if name == BATTLE_ANIMATION_EVENT.onAtkDone then
        skillid = "skillid"
    elseif name == BATTLE_ANIMATION_EVENT.onAtk0Done or name == BATTLE_ANIMATION_EVENT.onAtk0Done2 or name == BATTLE_ANIMATION_EVENT.onAtk0Done_1 then
        skillid = "skillid0"
    elseif name == BATTLE_ANIMATION_EVENT.onAtk1Done then
        skillid = "skillid1"
    elseif name == BATTLE_ANIMATION_EVENT.onAtk2Done then
        skillid = "skillid2"
    elseif name == BATTLE_ANIMATION_EVENT.onAtk3Done then
        skillid = "skillid3"
    end
    local skill = self:getSkills()[skillid]
    return skill
end
function Character:getSkillByAction(name)
    local skillid = "skillid"
    if name == BATTLE_ANIMATION_ACTION.ATTACK then
        skillid = "skillid"
    elseif name == BATTLE_ANIMATION_ACTION.SUPER or name == "atk0_1" and self:getHeroId() == 12 then
        skillid = "skillid0"
    elseif name == BATTLE_ANIMATION_ACTION.ATK1 then
        skillid = "skillid1"
    elseif name == BATTLE_ANIMATION_ACTION.ATK2 then
        skillid = "skillid2"
    elseif name == BATTLE_ANIMATION_ACTION.ATK3 then
        skillid = "skillid3"
    end
    local skill = self:getSkills()[skillid]
    return skill
end
function Character:getSkillAttackRangeBySkill(skill)
    if skill.range == nil then
        skill.range = 0
    end
    return skill.range
end
function Character:getSkillHurtRangeBySkill(skill)
    if skill.attackrange == nil then
        skill.attackrange = 0
    end
    return skill.attackrange
end
function Character:getAtkAnimNameByProcessId(id)
    if id == nil then
        id = 0
    end
    local _id = tonumber(id)
    local animName = BATTLE_ANIMATION_ACTION.ATTACK
    if _id == 1 then
        animName = "atk1"
    elseif _id == 2 then
        animName = "atk2"
    elseif _id == 3 then
        animName = "atk3"
    end
    return animName
end
function Character:_isHittable(params)
    local _params = params or { }
    local attacker = _params.attacker
    if attacker and attacker:isWorldBoss() then
        if self:isAlive() == false then
            return false
        end
        return true
    end
    if self:getHeroId() == 1 and self._attackcount[3] and self._attackcount[3] >= 5 and self._attackcount[3] < 7 then
        return false
    end
    if self:isHurtable() == false or self:isAlive() == false then
        return false
    end
    return true
end
function Character:runTip(params)
    local _type = params._type
    local text = params.text
    local parent = cc.Director:getInstance():getRunningScene()
    local hpPointNodePos = self:getSlotPositionInWorld("hpBarPoint")
    local position = cc.p(hpPointNodePos.x, hpPointNodePos.y - 70)
    return XTHD.action.runActionTipCharacter( {
        parent = parent,
        position = position,
        _type = _type,
        text = text
    } )
end
function Character:getHeroHurtFix(_skill, _hurt)
    local _skillMax = _skill.maxdamage
    if not _skillMax then
        return _hurt
    end
    local _dir = _hurt < 0 and -1 or 1
    local _nowHurt = math.abs(_hurt)
    local _newHurt = _nowHurt
    local _data = string.split(_skillMax, "#")
    local _type = tonumber(_data[1]) or 0
    local _bei = tonumber(_data[2]) or 1
    if _type == 1 then
        local hpMax = tonumber(self:getHpTotal())
        _newHurt = _bei * hpMax
    elseif _type == 2 then
        local hpNow = tonumber(self:getHpNow())
        _newHurt = _bei * hpNow
    elseif _type == 3 then
        local physicalattack = tonumber(self:getAttackWuLiNow())
        _newHurt = _bei * physicalattack
    elseif _type == 4 then
        local physicaldefence = tonumber(self:getDefenseWuLiNow())
        _newHurt = _bei * physicaldefence
    elseif _type == 5 then
        local manaattack = tonumber(self:getAttackMoFaNow())
        _newHurt = _bei * manaattack
    elseif _type == 6 then
        local manadefence = tonumber(self:getDefenseMoFaNow())
        _newHurt = _bei * manadefence
    end
    if not(_nowHurt > _newHurt) or not _newHurt then
        _newHurt = _nowHurt
    end
    _newHurt = _dir * _newHurt
    return _newHurt
end
function Character:runActionTip(params)
    if self:_isHittable( {
            attacker = params.attacker
        } ) == false then
        return nil
    end
    local blood = params.blood
    local _type = params._type
    local crit = params.crit
    local text = params.text
    local skill = params.skill
    local count = params.count
    local parent = params.parent
    local position = params.position
    local isBuffHurt = params.isBuffHurt
    local attacker = params.attacker
    if count == nil then
        count = 1
    end
    if blood == nil then
        blood = 0
    end
    local calculatetype = 1
    if skill then
        calculatetype = skill.calculatetype
    end
    local hpPointNodePos = self:getSlotPositionInWorld("hpBarPoint")
    if (not attacker or not attacker:isWorldBoss()) and(self:getWaiImmune() and calculatetype == 1 or self:getNeiImmune() and calculatetype == 2) then
        local _text
        if self:getWaiImmune() and self:getNeiImmune() then
            _text = "immunity"
        elseif self:getWaiImmune() then
            _text = "39_2"
        else
            _text = "39_1"
        end
        XTHD.action.runActionTipCharacter( {
            parent = cc.Director:getInstance():getRunningScene(),
            crit = false,
            position = cc.p(hpPointNodePos.x,hpPointNodePos.y - 70),
            text = _text,
            _type = XTHD.action.type.buff
        } )
        return nil
    end
    local side = self:getSide()
    if crit == nil then
        crit = false
    end
    local doDefenseAct = false
    local extraHp = self:getHpExtra()
    local showBuffTip = false
    if blood < 0 then
        if extraHp < math.abs(blood) then
            blood = blood + extraHp
            self:setHpExtra(0)
        else
            self:setHpExtra(extraHp - math.abs(blood))
        end
    end
    if blood < 0 and math.abs(blood) > 0.15 * self:getHpTotal() then
        doDefenseAct = true
    end
    local extraHpAfter = self:getHpExtra()
    if extraHpAfter > 0 and blood < 0 then
        showBuffTip = true
        text = "shield"
    end
    if extraHpAfter <= 0 and extraHp > 0 then
        self:removeBuffEffectById(7)
        self:removeBuffEffectById(112)
        self:removeBuffEffectById(142)
        self:removeBuffEffectById(275)
    end
    if showBuffTip == true then
        _type = XTHD.action.type.buff
    end
    if _type == XTHD.action.type.jiaxue then
        self._hp_now = self._hp_now + blood
        if 1 > math.abs(blood) then
            blood = 1
        end
    elseif _type == XTHD.action.type.wuligongji or _type == XTHD.action.type.wulibaoji or _type == XTHD.action.type.fashugongji or _type == XTHD.action.type.fashubaoji then
        self._hp_now = self._hp_now + blood
        if 1 > math.abs(blood) then
            blood = -1
        end
    end
    blood = math.ceil(blood)
    if _type ~= XTHD.action.type.buff then
        if blood > 0 then
            text = "+" .. blood
        else
            text = blood
        end
    end
    if 0 > self._hp_now then
        self._hp_now = 0
    elseif self._hp_now > self:getHpTotal() then
        self._hp_now = self:getHpTotal()
    end
    self._hpBarBG:setVisible(true)
    local lastPercentage = self._hpBar:getPercentage()
    local percentage = math.abs(self:getHpNow() * 1 / self:getHpTotal()) * 100
    if percentage < 1 and percentage > 0 then
        percentage = 1
    end
    local action = cc.ProgressFromTo:create(0.1, lastPercentage, percentage)
    local action1 = cc.ProgressFromTo:create(0.5, lastPercentage, percentage)
    self._hpBar:runAction(action)
    self._hpActionBar:runAction(action1)
    performWithDelay(self, function()
        self._hpBarBG:setVisible(false)
    end , 1.5)
    local victim = self
    if 0 >= victim._hp_now then
        victim._isAlive = false
        percentage = 0
        if self:getYD_Bian() then
            victim:playAnimation(BATTLE_ANIMATION_ACTION.BIAN_DEATH, false)
        else
            victim:playAnimation(BATTLE_ANIMATION_ACTION.DEATH, false)
        end
        XTHD.dispatchEvent( {
            name = EVENT_NAME_BATTLE_DEAD,
            data = { animal = victim }
        } )
    elseif doDefenseAct == true and showBuffTip == false and isBuffHurt ~= true and not self:isImmuneControl() and not self:isFrozen() and not self:isFreeze() and not self:isPetrifaction() and not self:isWorldBoss() then
        if (self:getStatus() == BATTLE_STATUS.ATTACK or self:getStatus() == BATTLE_STATUS.ATK1 or self:getStatus() == BATTLE_STATUS.ATK2 or self:getStatus() == BATTLE_STATUS.ATK3 or self:getStatus() == BATTLE_STATUS.SUPER or self:getStatus() == BATTLE_STATUS.DIZZ) and self:getStatus() ~= BATTLE_STATUS.DIZZ then
            self:setLastAttackTime(0)
            XTHD.action.runActionTipCharacter( {
                parent = cc.Director:getInstance():getRunningScene(),
                crit = false,
                position = cc.p(hpPointNodePos.x,hpPointNodePos.y - 70),
                text = "discrupt",
                _type = XTHD.action.type.buff
            } )
        end
        if self:isPaused() ~= true then
            if self:getStatus() == BATTLE_STATUS.SUPER then
                self:_removeSelfDim()
            end
            if self:getYD_Bian() then
                self:playAnimation(BATTLE_ANIMATION_ACTION.BIAN_DEFENSE, false)
            else
                self:playAnimation(BATTLE_ANIMATION_ACTION.DEFENSE, false)
            end
        end
    end
    if victim:getSide() == BATTLE_SIDE.LEFT then
        XTHD.dispatchEvent( {
            name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(victim:getHeroId()),
            data =
            {
                hp = percentage,
                standId = victim:getStandId()
            }
        } )
    end
    self:doTalent(BATTLE_TALENT_TYPE.TYPE_HP_LOW)
    if parent == nil then
        parent = cc.Director:getInstance():getRunningScene()
    end
    if position == nil then
        position = cc.p(hpPointNodePos.x, hpPointNodePos.y - 70)
    end
    if attacker and blood < -1 then
        if attacker:getSide() == BATTLE_SIDE.LEFT and not attacker:isWorldBoss() and blood <= -10000000 then
            local _params = {
                _type = "doAtk",
                attacker = attacker:getHeroData(),
                heroData = self:getHeroData(),
                cutHp = blood
            }
            LayerManager.sendZuobi(_params)
        end
        XTHD.dispatchEvent( {
            name = EVENT_NAME_BATTLE_DATA_HURT_RECORD,
            data =
            {
                animal = attacker,
                hurt = math.abs(blood),
                skill = params.skill,
                target = self,
                targetPos = self:getSlotPositionInWorld("midPoint")
            }
        } )
        if _type ~= XTHD.action.type.buff and attacker ~= self then
            local _allInfo = self:getSkills()
            local _talentSkillId = _allInfo.talent.skillid
            local _hurtSkillId = params.skill and params.skill.skillid or -1
            if _hurtSkillId ~= -1 and _talentSkillId ~= _hurtSkillId then
                attacker:doTalent(BATTLE_TALENT_TYPE.TYPE_DOHURT)
                self:doTalent(BATTLE_TALENT_TYPE.TYPE_BEHURT, { attacker = attacker })
            end
        end
    end
    return XTHD.action.runActionTipCharacter( {
        parent = parent,
        crit = crit,
        position = position,
        _type = _type,
        text = text
    } )
end
function Character:waveRest(isRecover)
    self:setDefualtRootY()
    self:setLineNum(self:getLocalZOrder())
    self:setNormalAtkCount(0)
    self._canStartMove = false
    self:setUseTalent(false)
    self:resetProcessIndex()
    self:setLastAttackTime(0)
    self:removeBuffEffect()
    self:setBeCatched(false)
    self:setHurtable(true)
    self:setVisible(true)
    if self:getFaceDirection() ~= BATTLE_DIRECTION.RIGHT then
        self:setFaceDirection(BATTLE_DIRECTION.RIGHT)
    end
    self:changeToMove(true)
    if isRecover then
        if 0 < self:getHpRecover() then
            self:runActionTip( {
                blood = self:getHpRecover(),
                _type = XTHD.action.type.jiaxue
            } )
        end
        if self:getSide() == BATTLE_SIDE.LEFT and tonumber(self:getMpRecover()) and 0 < self:getMpRecover() then
            self:setMp(self:getMp() + self:getMpRecover())
            XTHD.dispatchEvent( {
                name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(self:getHeroId()),
                data =
                {
                    mpadd = self:getMpRecover(),
                    standId = self:getStandId()
                }
            } )
        end
    end
end
function Character:isUseTalent()
    return self._isUseTalent
end
function Character:setUseTalent(_isUse)
    self._isUseTalent = _isUse
end
function Character:doTalent(talentEffType, sParams)
    if not self:isAlive() then
        return
    end
    if self:getHeroId() ~= 22 and self:getHeroId() ~= 34 and self:getHeroId() ~= 39 and self:getHeroId() ~= 41 and self:getHeroId() ~= 44 and self:getHeroId() ~= 46 then
        return
    end
    if self:isUseTalent() then
        return
    end
    if self._talentNode then
        return
    end
    local _allInfo = self:getSkills()
    local _skillData = _allInfo.talent
    if not _skillData then
        return
    end
    local _skilleffect = tonumber(_skillData.skilleffect) or 0
    local _effType = tonumber(talentEffType) or -1
    if BATTLE_TALENT_TYPE.TYPE_DODGE_AND_HIT == _skilleffect then
        if _effType ~= BATTLE_TALENT_TYPE.TYPE_NORMAL_HIT_NUM and _effType ~= BATTLE_TALENT_TYPE.TYPE_DODGE then
            return
        end
    elseif _effType ~= _skilleffect then
        return
    end
    local _targettype = tonumber(_skillData.targettype) or 0
    if _targettype ~= 1 and _targettype ~= 2 then
        return
    end
    local _tars
    if _effType == BATTLE_TALENT_TYPE.TYPE_BEHURT then
        local params = sParams or { }
        if _skillData.target == 18 and params.attacker then
            _tars = { }
            _tars[1] = params.attacker
        else
            _tars = self:getNowSkillTarges(_skillData)
        end
    else
        _tars = self:getNowSkillTarges(_skillData)
    end
    if _tars == nil or #_tars < 1 then
        return
    end
    local _hptrigger = tonumber(_skillData.hptrigger) or 0
    if _effType == BATTLE_TALENT_TYPE.TYPE_NORMAL_HIT_NUM then
        if _hptrigger > self:getNormalAtkTimes() then
            return
        end
        self:setNormalAtkCount(0)
    elseif _effType == BATTLE_TALENT_TYPE.TYPE_HP_LOW then
        local _hpPer = self:getHpNow() / self:getHpTotal()
        if _hpPer > _hptrigger * 0.01 then
            return
        end
    end
    self:doHurt( {
        skill = _skillData,
        targets = _tars,
        isTalentSkill = true
    } )
end
function Character:isBuffMingzhong(params)
    local skill = params.skill
    local target = params.target
    local buff = params.buff
    local triggertimingmax = buff.triggertimingmax * 100 / 10000
    local triggertimingmin = buff.triggertimingmin * 100 / 10000
    local buffTriggertRatio = 100
    local skill_level = skill.level or 1
    local targetLevel = target:getLevel()
    if targetLevel <= skill_level * 2 then
        buffTriggertRatio = triggertimingmax
    else
        buffTriggertRatio = triggertimingmin
    end
    local mingzhong = false
    local data = {
        standId = self:getStandId(),
        side = self:getSide(),
        heroid = self:getHeroId()
    }
    XTHD.dispatchEvent( { name = EVENT_NAME_BATTLE_GET_RANDOM, data = data })
    local random = data.random
    if target:isAlive() == true and buffTriggertRatio >= random and target:_isHittable() == true then
        mingzhong = true
    end
    return mingzhong
end
function Character:getBuffAddNode(_type)
    local _bufftype = _type
    self._buffNode = self._buffNode or { }
    if not self._buffNode[_bufftype] then
        self._buffNode[_bufftype] = cc.Node:create()
        self:addChild(self._buffNode[_bufftype])
        self._buffNode[_bufftype].buffTb = { }
    end
    return self._buffNode[_bufftype]
end
function Character:getBuffCount(staticBuffData, sNode)
    local _node = sNode == nil and self:getBuffAddNode(staticBuffData.type) or sNode
    local _buffId = staticBuffData.buffid
    if _node then
        local _str = "buffid" .. _buffId
        _node.buffTb[_str] = _node.buffTb[_str] or { }
        return #_node.buffTb[_str]
    end
    return 0
end
function Character:stopBuffByInfo(_node, isRemove)
    local _isRemove = isRemove == nil and true or isRemove
    if _node then
        if _node.doStop then
            _node.doStop()
        end
        if _isRemove then
            _node:removeFromParent()
        end
    end
end
function Character:getBuffNodesById(_id)
    local _buffId = "buffid" .. tostring(_id)
    for i = 1, 3 do
        local _tb = self:getBuffAddNode(i)
        if _tb and _tb.buffTb and _tb.buffTb[_buffId] and #_tb.buffTb[_buffId] > 0 then
            return _tb.buffTb[_buffId]
        end
    end
    return nil
end
function Character:removeBuffEffectById(_id)
    local _buffId = "buffid" .. tostring(_id)
    for i = 1, 3 do
        local _tb = self:getBuffAddNode(i)
        if _tb and _tb.buffTb and _tb.buffTb[_buffId] and #_tb.buffTb[_buffId] > 0 then
            for k, v in pairs(_tb.buffTb[_buffId]) do
                self:stopBuffByInfo(v)
            end
            _tb.buffTb[_buffId] = { }
        end
    end
end
function Character:removeBuffEffectByType(_type)
    local _tb = self:getBuffAddNode(_type)
    if _tb then
        if _tb.buffTb and next(_tb.buffTb) ~= nil then
            for k, v in pairs(_tb.buffTb) do
                for key, value in pairs(v) do
                    self:stopBuffByInfo(value)
                end
            end
            _tb.buffTb = { }
        end
        _tb:stopAllActions()
        _tb:removeAllChildren()
    end
end
function Character:_getBuffTypeCount(_type)
    self._buffTypeCount = self._buffTypeCount or { }
    self._buffTypeCount[_type] = self._buffTypeCount[_type] or 0
    return self._buffTypeCount[_type]
end
function Character:_countBuffByNum(_type, isPlus)
    local pNum = self:_getBuffTypeCount(_type)
    pNum = isPlus and pNum + 1 or pNum - 1
    if pNum < 0 then
        pNum = 0 or pNum
    end
    self._buffTypeCount[_type] = pNum
    return pNum == 0
end
function Character:_getBuffHurt(params)
    local _skillData = params.skill
    local staticBuffData = params.buff
    local _target = params.target
    local _skillHurt = params.skillHurt
    local skill_level = _skillData.level or 1
    local buffid = staticBuffData.buffid
    local buffeffect = staticBuffData.buffeffect
    local argumenttype = staticBuffData.argumenttype
    local argument = staticBuffData.argument
    local buffprobabilitygrow = staticBuffData.buffprobabilitygrow
    local buffbasicgrow = staticBuffData.buffbasicgrow
    local hurt = _skillHurt or self:_getSkillHurt(_skillData)
    local extra = 0
    if (buffeffect == 29 or buffeffect == 30 or buffeffect == 31) and argumenttype == 3 then
        argumenttype = 2
    end
    if buffeffect == 24 then
        argumenttype = 3
    end
    if argumenttype == 1 then
        extra = argument +(skill_level - 1) * buffbasicgrow
    elseif argumenttype == 2 then
        extra = hurt *(argument / 10000 +(skill_level - 1) * buffprobabilitygrow / 10000) +(skill_level - 1) * buffbasicgrow
    elseif argumenttype == 3 then
        local base = argument / 10000 +(skill_level - 1) * buffprobabilitygrow / 10000 +(skill_level - 1) * buffbasicgrow
        if buffeffect >= 7 and buffeffect <= 21 then
            base = argument / 100 +(skill_level - 1) * buffprobabilitygrow / 100 +(skill_level - 1) * buffbasicgrow
        end
        if buffeffect == 2 then
            extra = _target:getHpTotal() * base
        elseif buffeffect == 3 then
            extra = _target:getAttackWuLiOrigin() * base
        elseif buffeffect == 4 then
            extra = _target:getDefenseWuLiOrigin() * base
        elseif buffeffect == 5 then
            extra = _target:getAttackMoFaOrigin() * base
        elseif buffeffect == 6 then
            extra = _target:getDefenseMoFaOrigin() * base
        elseif buffeffect == 7 then
            extra = base
        elseif buffeffect == 8 then
            extra = base
        elseif buffeffect == 9 then
            extra = base
        elseif buffeffect == 10 then
            extra = base
        elseif buffeffect == 11 then
            extra = base
        elseif buffeffect == 12 then
            extra = base
        elseif buffeffect == 13 then
            extra = base
        elseif buffeffect == 14 then
            extra = base
        elseif buffeffect == 15 then
            extra = base
        elseif buffeffect == 16 then
            extra = base
        elseif buffeffect == 17 then
            extra = base
        elseif buffeffect == 18 then
            extra = base
        elseif buffeffect == 19 then
            extra = base
        elseif buffeffect == 20 then
            extra = base
        elseif buffeffect == 21 then
            extra = base
        else
            extra = base
        end
    end
    return extra
end
function Character:doBuff(params)
    local _skillData = params.skill
    local _count = params.count
    local count
    if _count then
        count = _count
    else
        self:_doAddSkillHitCount(_skillData)
    end
    if params.isTalentSkill then
        self._hitcount[_skillData.skillid]._hitCount = 1
    end
    count = count or tonumber(self._hitcount[_skillData.skillid]._hitCount) or 1
    local buffid, staticBuffData, buffidtargettype
    for i = 1, 3 do
        staticBuffData = _skillData._buffData[i]
        if staticBuffData ~= nil then
            buffidtargettype = tonumber(_skillData["buff" .. i .. "idtargettype"])
            local _do = true
            if buffidtargettype == 1 then
                if _skillData.timing == 2 and count ~= 1 then
                    if self._hitcount[_skillData.skillid]._useSelf then
                        _do = false
                    else
                        self._hitcount[_skillData.skillid]._useSelf = true
                    end
                end
            elseif buffidtargettype == 2 and _skillData.timing == 2 and count ~= 1 then
                _do = false
            end
            if _do then
                staticBuffData.buffprobabilitygrow = tonumber(_skillData["buff" .. i .. "probabilitygrow"])
                staticBuffData.buffbasicgrow = tonumber(_skillData["buff" .. i .. "basicgrow"])
                params.targetType = buffidtargettype
                params.buff = staticBuffData
                self:_doBuffByOne(params)
            end
        end
    end
end
function Character:_doBuffByOne(params)
    local _skillData = params.skill
    local _skillHurt = params.skillHurt
    local targets = params.targets
    local staticBuffData = params.buff
    local buffidtargettype = params.targetType
    local calculatetype = _skillData.calculatetype
    local buffid = staticBuffData.buffid
    local buffeffect = staticBuffData.buffeffect
    local _bufftype = staticBuffData.type
    local duration = staticBuffData.duration or 0
    duration = staticBuffData.duration / 1000
    local triggeroppotunity = staticBuffData.triggeroppotunity or 0
    triggeroppotunity = triggeroppotunity / 1000
    local recovertime = staticBuffData.recovertime or 0
    recovertime = staticBuffData.recovertime / 1000
    local _tiptype = calculatetype == 1 and XTHD.action.type.wuligongji or XTHD.action.type.fashugongji
    local function _getEffBufNode(buffShowNode, target)
        local _node
        if buffeffect == 2 and buffid == 10 then
            _node = self:getEffectSpineFromCache("res/spine/effect/004/atk1/004atk1")
            target:addNodeForSlot( {
                node = _node,
                slotName = "midPoint",
                zorder = 10
            } )
            _node:setAnimation(0, "atk1", true)
        elseif buffeffect == 2 and buffid == 98 then
            local winWidth = cc.Director:getInstance():getWinSize().width
            local winHeight = cc.Director:getInstance():getWinSize().height
            _node = self:getEffectSpineFromCache("res/spine/effect/027/atk0/atk0_1", 1)
            _node:setPosition(winWidth * 0.5, winHeight * 0.5)
            _node:setAnimation(0, "animation", true)
            XTHD.dispatchEvent( {
                name = EVENT_NAME_BATTLE_PLAY_EFFECT,
                data =
                {
                    node = _node,
                    zorder = self:getLocalZOrder()
                }
            } )
        elseif buffeffect == 2 and buffid == 143 then
            _node = self:getEffectSpineFromCache("res/spine/effect/040/atk2/atk2_xunhuan")
            target:addNodeForSlot( {
                node = _node,
                slotName = "midPoint",
                zorder = 10
            } )
            _node:setAnimation(0, "animation", true)
        elseif buffeffect == 2 and buffid == 207 then
            _node = self:getEffectSpineFromCache("res/spine/effect/030/atk2/atk2_2")
            target:addNodeForSlot( {
                node = _node,
                slotName = "root",
                zorder = - 10
            } )
            _node:setAnimation(0, "atk", true)
        elseif buffeffect == 24 and buffid == 233 then
            _node = self:getEffectSpineFromCache("res/spine/effect/028/atk2/atk2_2")
            _node:setAnimation(0, "animation", true)
            target:addNodeForSlot( {
                node = _node,
                slotName = "hpBarPoint",
                zorder = 10
            } )
        elseif buffeffect == 27 and buffid == 150 then
            _node = self:getEffectSpineFromCache("res/spine/effect/041/atk0/atk0_1")
            _node:setAnimation(0, "animation", true)
            target:addNodeForSlot( {
                node = _node,
                slotName = "midPoint",
                zorder = 10
            } )
        elseif buffeffect == 29 and buffid == 7 then
            _node = self:getEffectSpineFromCache("res/spine/effect/003/atk1/atk1")
            _node:setAnimation(0, "atk1", false)
            target:addNodeForSlot( {
                node = _node,
                slotName = "root",
                zorder = 10
            } )
            performWithDelay(_node, function()
                _node:setAnimation(0, "atk2", true)
            end , 0.97)
        elseif buffeffect == 29 and buffid == 112 then
            _node = self:getEffectSpineFromCache("res/spine/effect/031/atk1/atk1")
            _node:setAnimation(0, "atk1", true)
            target:addNodeForSlot( {
                node = _node,
                slotName = "midPoint",
                zorder = 10
            } )
        elseif buffeffect == 29 and buffid == 142 then
            _node = self:getEffectSpineFromCache("res/spine/effect/040/atk0/atk0_bao")
            _node:setAnimation(0, "idle", true)
            target:addNodeForSlot( {
                node = _node,
                slotName = "midPoint",
                zorder = 10
            } )
        elseif buffeffect == 29 and buffid == 267 then
            _node = self:getEffectSpineFromCache("res/spine/effect/044/atk/atk_beidong")
            _node:setAnimation(0, "chixu", true)
            target:addNodeForSlot( {
                node = _node,
                slotName = "root",
                zorder = 10
            } )
        elseif buffeffect == 29 and buffid == 275 then
            _node = self:getEffectSpineFromCache("res/spine/effect/039/atk3/atk3")
            _node:setAnimation(0, "atk3", true)
            target:addNodeForSlot( {
                node = _node,
                slotName = "root",
                zorder = 10
            } )
        elseif buffeffect == 32 then
            local _data = {
                file = "res/image/tmpbattle/effect/buff/dizz",
                name = "dizz_",
                startIndex = 1,
                endIndex = 6,
                perUnit = 0.1
            }
            _node = XTHD.createSpriteFrameSp(_data)
            target:addNodeForSlot( {
                node = _node,
                slotName = "hpBarPoint",
                zorder = 10
            } )
            _node:setPosition(0, 30)
        elseif buffeffect == 34 and buffid == 278 then
            _node = self:getEffectSpineFromCache("res/spine/effect/020/atk22")
            _node:setAnimation(0, "01", false)
            target:addNodeForSlot( {
                node = _node,
                slotName = "root",
                zorder = 10
            } )
            _node:setScaleX(-1 * _node:getScaleX())
        elseif buffeffect == 35 then
            if buffid == 95 then
                _node = self:getEffectSpineFromCache("res/spine/effect/027/atk2/atk2_1")
                target:addNodeForSlot( {
                    node = _node,
                    slotName = "midPoint",
                    zorder = 10
                } )
                _node:setAnimation(0, "animation", true)
                local _pox1 = target:getSlotPositionInWorld("midPoint")
                local _pox2 = target:getSlotPositionInWorld("hpBarPoint")
                local _node2 = XTHD.createSprite("res/fonts/buffWord/silence.png")
                _node:addChild(_node2)
                _node2:setScale(1 / self:getScaleY())
                _node2:setScaleX(-1 * _node2:getScaleX())
                _node2:setPosition((_pox2.x - _pox1.x) / target:getScaleY(),(_pox2.y - _pox1.y) / target:getScaleY())
            else
                _node = XTHD.createSprite("res/fonts/buffWord/silence.png")
                _node:setScaleX(-1 * _node:getScaleX())
                target:addNodeForSlot( {
                    node = _node,
                    slotName = "hpBarPoint",
                    zorder = 10
                } )
            end
        elseif buffeffect == 37 then
            local _data = {
                file = "res/image/tmpbattle/effect/buff/addict",
                name = "addict_",
                startIndex = 1,
                endIndex = 9
            }
            _node = XTHD.createSpriteFrameSp(_data)
            target:addNodeForSlot( {
                node = _node,
                slotName = "hpBarPoint",
                zorder = 10
            } )
            _node:setPosition(cc.p(20, 20))
        elseif buffeffect == 40 and buffid == 241 then
            _node = self:getEffectSpineFromCache("res/spine/effect/024/atk3")
            _node:setAnimation(0, "atk3", true)
            target:addNodeForSlot( {
                node = _node,
                slotName = "midPoint",
                zorder = 10
            } )
        elseif buffeffect == 42 and buffid == 270 then
            _node = self:getEffectSpineFromCache("res/spine/effect/039/atk0/atk0")
            _node:setAnimation(0, "atk_1", true)
            local _pos = target:getSlotPositionInWorld("midPoint")
            _node:setPosition(_pos)
            XTHD.dispatchEvent( {
                name = EVENT_NAME_BATTLE_PLAY_EFFECT,
                data = { node = _node, zorder = 10 }
            } )
        else
            _node = cc.Node:create()
            buffShowNode:addChild(_node)
        end
        return _node
    end
    local function _doChangeHp(sTarget, sBlood)
        if not sTarget:isAlive() then
            return
        end
        if _bufftype == 1 then
            do
                local _data = {
                    file = "res/image/tmpbattle/effect/buff/blood_change_up",
                    name = "blood_change_up_",
                    startIndex = 1,
                    endIndex = 9,
                    perUnit = 0.1,
                    isCircle = false
                }
                local _top_sp = XTHD.createSpriteFrameSp(_data)
                _top_sp:setScale(self:getScaleY())
                sTarget:addNodeForSlot( {
                    node = _top_sp,
                    slotName = "midPoint",
                    zorder = 10
                } )
                performWithDelay(_top_sp, function()
                    _top_sp:removeFromParent()
                end , 0.9)
            end
        end
        local _blood = self:getHeroHurtFix(_skillData, sBlood)
        sTarget:runActionTip( {
            blood = _blood,
            _type = _tiptype,
            attacker = self,
            skill = _skillData,
            isBuffHurt = true
        } )
    end
    local function _tmp(target)
        if not target:isAlive() then
            return false
        end
        local ishit = self:isBuffMingzhong( {
            skill = _skillData,
            target = target,
            buff = staticBuffData
        } )
        if buffid == 249 then
            ishit = true
        end
        if not ishit then
            return false
        end
        if buffeffect == 2 then
            if buffid == 121 then
                if self._talentNode then
                    return false
                end
                self._talentNode = cc.Node:create()
                self:addChild(self._talentNode)
                performWithDelay(self, function(...)
                    self._talentNode:removeFromParent()
                    self._talentNode = nil
                end , recovertime)
            end
        elseif buffeffect == 3 then
            if target:isWorldBoss() and _bufftype == 2 then
                return false
            end
        elseif buffeffect == 4 then
            if buffid == 268 then
                if self._talentNode then
                    return false
                end
                self._talentNode = cc.Node:create()
                self:addChild(self._talentNode)
                performWithDelay(self, function(...)
                    self._talentNode:removeFromParent()
                    self._talentNode = nil
                end , recovertime)
            end
        elseif buffeffect == 24 then
            if _bufftype == 2 and target:isWorldBoss() then
                return
            end
        elseif buffeffect == 25 then
            if _bufftype == 2 and target:isWorldBoss() then
                return
            end
        elseif buffeffect == 29 then
            local _data = gameData.getDataFromCSV("Jinengbuff", { buffid = 275 })
            if target:getBuffCount(_data) > 0 and buffid ~= 275 then
                return false
            end
            target:removeBuffEffectById(7)
            target:removeBuffEffectById(112)
            target:removeBuffEffectById(142)
            target:removeBuffEffectById(275)
        elseif buffeffect == 32 then
            if target:isImmuneControl() or target:isWorldBoss() or target:isMonsterImmunize() or target:getHeroId() == 6 then
                return false
            end
        elseif buffeffect == 33 then
            target:setFreeze(true)
            if not target:isFreeze() then
                return false
            end
        elseif buffeffect == 34 then
            target:setFrozen(true)
            if not target:isFrozen() then
                return false
            end
        elseif buffeffect == 35 then
            target:setSilence(true)
            if not target:isSilence() then
                return false
            end
        elseif buffeffect == 37 then
            target:setAddict(true)
            if not target:isAddict() then
                return false
            end
        elseif buffeffect == 42 then
            target:setPetrifaction(true)
            if not target:isPetrifaction() then
                return false
            end
        elseif buffeffect == 43 then
            target:setCannotMove(true)
            if not target:isCannotMove() then
                return false
            end
        end
        local _buffNode = target:getBuffAddNode(staticBuffData.type)
        local superpositiontimes = tonumber(staticBuffData.superpositiontimes) or 0
        local _needClean = superpositiontimes <= target:getBuffCount(staticBuffData, _buffNode)
        local _node
        local _buffIdString = "buffid" .. buffid
        _buffNode.buffTb[_buffIdString] = _buffNode.buffTb[_buffIdString] or { }
        if _needClean then
            local _nodes = _buffNode.buffTb[_buffIdString]
            if _nodes and #_nodes > 0 then
                local _node = table.remove(_nodes, 1)
                target:stopBuffByInfo(_node, false)
            end
        end
        _node = _node or _getEffBufNode(_buffNode, target)
        table.insert(_buffNode.buffTb[_buffIdString], _node)
        if buffeffect == 2 then
            do
                local extra = self:_getBuffHurt( {
                    skill = _skillData,
                    skillHurt = _skillHurt,
                    buff = staticBuffData,
                    target = target
                } )
                local blood = _bufftype == 1 and extra *(1 + self:getHealNow() / 100) *(1 + target:getBehealedNow() / 100) or - extra
                _tiptype = _bufftype == 1 and XTHD.action.type.jiaxue or _tiptype
                if buffid == 97 then
                    do
                        local _action = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(triggeroppotunity), cc.CallFunc:create( function()
                            if target:isAlive() then
                                _doChangeHp(target, blood)
                            end
                        end )))
                        local function _doStop()
                            _node:stopAction(_action)
                        end
                        _node:runAction(_action)
                        _node.doStop = _doStop
                    end
                elseif duration > 0 then
                    do
                        local _action = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(triggeroppotunity), cc.CallFunc:create( function()
                            _doChangeHp(target, blood)
                            if buffid == 259 then
                                do
                                    local eff = self:getEffectSpineFromCache("res/spine/effect/036/atk2/atk2_2")
                                    eff:setAnimation(0, "atk0_1", false)
                                    target:addNodeForSlot( {
                                        node = eff,
                                        slotName = "root",
                                        zorder = 10
                                    } )
                                    performWithDelay(eff, function()
                                        eff:removeFromParent()
                                    end , 1)
                                end
                            end
                        end )))
                        local _action2 = cc.Sequence:create(cc.DelayTime:create(duration - 0.2), cc.FadeOut:create(0.2))
                        _node:runAction(_action)
                        _node:runAction(_action2)
                        local function _doStop()
                            _node:stopAction(_action)
                            _node:stopAction(_action2)
                        end
                        _node.doStop = _doStop
                    end
                else
                    _doChangeHp(target, blood)
                end
            end
        elseif buffeffect >= 3 and buffeffect <= 21 then
            do
                local extra = self:_getBuffHurt( {
                    skill = _skillData,
                    skillHurt = _skillHurt,
                    buff = staticBuffData,
                    target = target
                } )
                local blood = _bufftype == 1 and extra or - extra
                local text = _bufftype == 1 and buffeffect .. "_1" or buffeffect .. "_2"
                target:setAttributesByBuff( { buffeffect = buffeffect, extra = blood })
                if buffeffect ~= 21 then
                    target:runTip( {
                        text = text,
                        _type = XTHD.action.type.buff,
                        attacker = self,
                        skill = _skillData,
                        isBuffHurt = true
                    } )
                end
                if _bufftype == 1 then
                    do
                        local _effNode = self:getEffectSpineFromCache("res/spine/effect/speed_up/up")
                        target:addNodeForSlot( {
                            node = _effNode,
                            slotName = "root",
                            zorder = - 1
                        } )
                        _effNode:setAnimation(0, "animation3", false)
                        performWithDelay(_effNode, function()
                            _effNode:removeFromParent()
                        end , 1.2)
                    end
                else
                    do
                        local _effNode = self:getEffectSpineFromCache("res/spine/effect/speed_down/down")
                        target:addNodeForSlot( {
                            node = _effNode,
                            slotName = "midPoint",
                            zorder = 10
                        } )
                        _effNode:setAnimation(0, "animation3", false)
                        performWithDelay(_effNode, function()
                            _effNode:removeFromParent()
                        end , 1.1666)
                    end
                end
                local function _doStop()
                    target:setAttributesByBuff( {
                        buffeffect = buffeffect,
                        extra = - blood
                    } )
                end
                _node.doStop = _doStop
            end
        elseif buffeffect == 24 then
            local extra = self:_getBuffHurt( {
                skill = _skillData,
                skillHurt = _skillHurt,
                buff = staticBuffData,
                target = target
            } )
            local blood = _bufftype == 1 and extra or - extra
            local text = _bufftype == 1 and "24_1" or "24_2"
            _tiptype = XTHD.action.type.buff
            target:runTip( {
                text = text,
                _type = _tiptype,
                attacker = self,
                skill = _skillData,
                isBuffHurt = true
            } )
            local x = 1 + blood
            if x <= 0 then
                x = 0.1
            end
            target:setSpeedScale(x)
            if buffid == 277 then
                XTHD.setShader(target, "res/shader/FrozenShader.vsh", "res/shader/FrozenShader.fsh")
            end
            local function _doStop()
                if buffid == 277 then
                    target:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(cc.SHADER_POSITION_TEXTURE_COLOR_NO_MVP))
                end
                target:setSpeedScale(1)
            end
            _node.doStop = _doStop
        elseif buffeffect == 25 then
            local extra = self:_getBuffHurt( {
                skill = _skillData,
                skillHurt = _skillHurt,
                buff = staticBuffData,
                target = target
            } )
            extra = _bufftype == 1 and 1 + extra or 1 - extra
            local pStr = extra > 1 and "25_1" or "25_2"
            target:setMoveSpeedScale(extra)
            target:runActionTip( {
                text = pStr,
                _type = XTHD.action.type.buff,
                attacker = self,
                skill = _skillData,
                isBuffHurt = true
            } )
            if buffid == 279 then
                XTHD.setShader(target, "res/shader/FrozenShader.vsh", "res/shader/FrozenShader.fsh")
            end
            local function _doStop()
                if buffid == 279 then
                    target:setGLProgramState(cc.GLProgramState:getOrCreateWithGLProgramName(cc.SHADER_POSITION_TEXTURE_COLOR_NO_MVP))
                end
                target:setMoveSpeedScale(1)
            end
            _node.doStop = _doStop
        elseif buffeffect == 27 then
            target:_countBuffByNum(buffeffect, true)
            target:setWaiImmune(true)
            local function _doStop()
                local _result = target:_countBuffByNum(buffeffect, false)
                if _result then
                    target:setWaiImmune(false)
                end
            end
            _node.doStop = _doStop
        elseif buffeffect == 28 then
            target:_countBuffByNum(buffeffect, true)
            target:setNeiImmune(true)
            local function _doStop()
                local _result = target:_countBuffByNum(buffeffect, false)
                if _result then
                    target:setNeiImmune(false)
                end
            end
            _node.doStop = _doStop
        elseif buffeffect == 29 then
            do
                local extra = self:_getBuffHurt( {
                    skill = _skillData,
                    skillHurt = _skillHurt,
                    buff = staticBuffData,
                    target = target
                } )
                target:setHpExtra(extra)
                local _action = cc.Sequence:create(cc.DelayTime:create(duration - 0.2), cc.FadeOut:create(0.2))
                local function _doStop()
                    _node:stopAction(_action)
                    target:setHpExtra(0)
                end
                _node:runAction(_action)
                _node.doStop = _doStop
            end
        elseif buffeffect == 32 then
            if target:getYD_Bian() then
                target:playAnimation(BATTLE_ANIMATION_ACTION.BIAN_DIZZ, true)
            else
                target:playAnimation(BATTLE_ANIMATION_ACTION.DIZZ, true)
            end
            target:setStatus(BATTLE_STATUS.DIZZ)
            target:setMove(false)
            target:_countBuffByNum(buffeffect, true)
            local function _doStop()
                local _result = target:_countBuffByNum(buffeffect, false)
                if target:isAlive() and target:getStatus() == BATTLE_STATUS.DIZZ and _result then
                    if target:getYD_Bian() then
                        target:playAnimation(BATTLE_ANIMATION_ACTION.BIAN_IDLE, true)
                    else
                        target:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, true)
                    end
                    target:setStatus(BATTLE_STATUS.IDLE)
                end
            end
            _node.doStop = _doStop
        elseif buffeffect == 33 then
            target:setFreeze(true)
            target:_countBuffByNum(buffeffect, true)
            local function _doStop()
                local _result = target:_countBuffByNum(buffeffect, false)
                if _result then
                    if target:getDimCount() < 1 then
                        target:setFreeze(false)
                    else
                        target._isFreeze = false
                    end
                end
            end
            _node.doStop = _doStop
        elseif buffeffect == 34 then
            target:setFrozen(true)
            target:_countBuffByNum(buffeffect, true)
            local function _doStop()
                local _result = target:_countBuffByNum(buffeffect, false)
                if _result then
                    if target:getDimCount() < 1 then
                        target:setFrozen(false)
                    else
                        target._isFroze = false
                    end
                end
                if buffid == 278 then
                    do
                        local _node2 = self:getEffectSpineFromCache("res/spine/effect/020/atk22")
                        _node2:setAnimation(0, "02", false)
                        local point = target:getSlotPositionInWorld("root")
                        _node2:setPosition(point)
                        XTHD.dispatchEvent( {
                            name = EVENT_NAME_BATTLE_PLAY_EFFECT,
                            data = { node = _node2, zorder = 10 }
                        } )
                        _node2:setScaleX(-1 * _node2:getScaleX())
                        performWithDelay(_node2, function()
                            _node2:removeFromParent()
                        end , 0.4333)
                    end
                end
            end
            _node.doStop = _doStop
        elseif buffeffect == 35 then
            target:setSilence(true)
            target:_countBuffByNum(buffeffect, true)
            local _name = target:getAnimationName()
            if _name == BATTLE_ANIMATION_ACTION.SUPER or _name == BATTLE_ANIMATION_ACTION.ATK1 or _name == BATTLE_ANIMATION_ACTION.ATK2 or _name == BATTLE_ANIMATION_ACTION.ATK3 then
                target:_removeSelfDim()
                target:changeToIdel()
            end
            local function _doStop()
                local _result = target:_countBuffByNum(buffeffect, false)
                if _result then
                    target:setSilence(false)
                end
            end
            _node.doStop = _doStop
        elseif buffeffect == 37 then
            target:setAddict(true)
            target:_countBuffByNum(buffeffect, true)
            local function _doStop()
                local _result = target:_countBuffByNum(buffeffect, false)
                if _result then
                    target:setAddict(false)
                end
            end
            _node.doStop = _doStop
        elseif buffeffect == 38 then
            target:setHiding(true)
            target:_countBuffByNum(buffeffect, true)
            local function _doStop()
                local _result = target:_countBuffByNum(buffeffect, false)
                if _result then
                    target:setHiding(false)
                end
            end
            _node.doStop = _doStop
        elseif buffeffect == 40 then
            do
                local extra = self:_getBuffHurt( {
                    skill = _skillData,
                    skillHurt = _skillHurt,
                    buff = staticBuffData,
                    target = target
                } )
                local blood = _bufftype == 1 and extra or - extra
                local text = _bufftype == 1 and "23_1" or "23_2"
                _tiptype = XTHD.action.type.buff
                local function tmp(target)
                    if target:isAlive() then
                        target:setMp(target:getMp() + blood)
                        if target:getSide() == BATTLE_SIDE.LEFT then
                            XTHD.dispatchEvent( {
                                name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(target:getHeroId()),
                                data =
                                {
                                    mpadd = blood,
                                    standId = target:getStandId()
                                }
                            } )
                        end
                        target:runActionTip( {
                            text = text,
                            _type = _tiptype,
                            attacker = self,
                            skill = _skillData,
                            isBuffHurt = true
                        } )
                    end
                end
                if duration == 0 then
                    tmp(target)
                else
                    do
                        local _action = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(triggeroppotunity), cc.CallFunc:create( function()
                            tmp(target)
                        end )))
                        _node:runAction(_action)
                        local function _doStop()
                            _node:stopAction(_action)
                        end
                        _node.doStop = _doStop
                    end
                end
            end
        elseif buffeffect == 41 then
            target:_countBuffByNum(buffeffect, true)
            target:setImmuneControl(true)
            local function _doStop()
                local _result = target:_countBuffByNum(buffeffect, false)
                if _result then
                    target:setImmuneControl(false)
                end
            end
            _node.doStop = _doStop
        elseif buffeffect == 42 then
            target:_countBuffByNum(buffeffect, true)
            target:setPetrifaction(true)
            local function _doStop()
                local _result = target:_countBuffByNum(buffeffect, false)
                if _result then
                    target:setPetrifaction(false)
                end
            end
            _node.doStop = _doStop
        elseif buffeffect == 43 then
            target:setCannotMove(true)
            local function _doStop()
                local _result = target:_countBuffByNum(buffeffect, false)
                if _result then
                    target:setCannotMove(false)
                end
            end
            _node.doStop = _doStop
        end
        _node._isBuffNode = true
        local function _doEnd()
            if _node then
                local _nodes = _buffNode.buffTb[_buffIdString]
                if _nodes and #_nodes > 0 then
                    for k, v in pairs(_nodes) do
                        if v == _node then
                            table.remove(_nodes, k)
                            break
                        end
                    end
                end
                target:stopBuffByInfo(_node)
            end
        end
        if duration <= 0 then
            _doEnd()
        else
            performWithDelay(_node, function()
                _doEnd()
            end , duration)
        end
        return true
    end
    local hitFlag, musicFile
    if buffidtargettype == 1 then
        local target = self
        hitFlag = _tmp(target)
    elseif buffidtargettype == 2 and targets ~= nil then
        for k, target in pairs(targets) do
            local _hit = _tmp(target)
            if _hit then
                hitFlag = true
            end
        end
    end
    if hitFlag then
        if buffeffect == 35 then
            musicFile = "res/sound/soundhilence.mp3"
        end
        if musicFile then
            musicManager.playEffect(musicFile, false)
        end
    end
end
function Character:isSkillMingzhong(params)
    local skill = params.skill
    local target = params.target
    local _skillData = skill
    local _skillattackrangetype = _skillData.attackrangetype
    local _skillattackrange = _skillData.attackrange
    local targetType = _skillData.targettype
    local hitType = _skillData.hittype
    local datatype = _skillData.datatype
    local skill_level = _skillData.level
    if target == nil then
        return false
    end
    if targetType == 1 then
        return false
    end
    if target:isAlive() == false then
        return false
    end
    local targetLevel = target:getLevel()
    local hitRatio = 100
    if hitType == 1 then
        hitRatio = self:getHitNow() - target:getDodgeNow()
    elseif hitType == 2 then
        hitRatio = 100
    elseif hitType == 3 then
        if target == nil or targetLevel <= skill_level * 5 then
            hitRatio = 100
        else
            hitRatio = 75
        end
    end
    local mingzhong = false
    local data = {
        standId = self:getStandId(),
        side = self:getSide(),
        heroid = self:getHeroId()
    }
    XTHD.dispatchEvent( { name = EVENT_NAME_BATTLE_GET_RANDOM, data = data })
    local random = data.random
    if hitRatio >= random then
        mingzhong = true
    end
    return mingzhong, random
end
function Character:showMissTip(target)
    if target:isAlive() == true then
        local hpPointNode = target:getNodeForSlot("hpBarPoint")
        local hpPointWorldPos = hpPointNode:convertToWorldSpace(cc.p(0.5, 0.5))
        local hpPointNodePos = cc.Director:getInstance():getRunningScene():convertToNodeSpace(hpPointWorldPos)
        XTHD.action.runActionTipCharacter( {
            parent = cc.Director:getInstance():getRunningScene(),
            crit = crit,
            position = cc.p(hpPointNodePos.x,hpPointNodePos.y - 70),
            text = "dodge",
            _type = XTHD.action.type.buff
        } )
    end
end
function Character:doHurt(params)
    local skill = params.skill
    local targets = params.targets
    local count = params.count
    local _skillData = skill
    local addMingzhongMp = params.addMingzhongMp or false
    if targets == nil then
        return
    end
    self:_doAddSkillAtkCount(_skillData, count)
    count = self._attackcount[_skillData.skillid]
    local hpcost = _skillData.hpcost
    if hpcost > 0 then
        local cost = self:getHpTotal() * hpcost / 100
        local _type = XTHD.action.type.wuligongji
        if cost < self:getHpNow() then
            self:runActionTip( {
                blood = - cost,
                crit = false,
                attacker = self,
                _type = _type,
                skill = _skillData,
                count = count
            } )
        end
    end
    local attacker = self
    local _mingzhong_ = false
    local targetType = _skillData.targettype
    if targetType == 1 or _skillData.basedata == 1 then
        self:doBuff(params)
    else
        local m_isMingzhong = params.isMingzhong
        local skillId = _skillData.skillid
        local _attacktimes = _skillData.attacktimes
        local calculatetype = _skillData.calculatetype
        local tabPercentage = string.split(_attacktimes, "#")
        local mingzhong = false
        local baoji = false
        local _critRandom = 0
        local _buffMingzhongTargets = { }
        local hurt = self:_getSkillHurt(_skillData)
        for k, target in pairs(targets) do
            if target:isAlive() == true then
                baoji = false
                local targetLevel = target:getLevel()
                if m_isMingzhong ~= nil then
                    mingzhong = true
                    _critRandom = m_isMingzhong
                else
                    mingzhong, _critRandom = self:isSkillMingzhong( { skill = _skillData, target = target })
                end
                if mingzhong == true then
                    _mingzhong_ = true
                    do
                        local hurtPercent = 1
                        if tonumber(_attacktimes) == 1 or count == nil then
                            hurtPercent = 1
                        else
                            local times = count
                            if times > #tabPercentage then
                                hurtPercent = 0
                            else
                                hurtPercent = tonumber(tabPercentage[times])
                            end
                        end
                        local hp_now = self:getHpNow()
                        local critRatio = self:getCritNow()
                        if _critRandom <= critRatio then
                            baoji = true
                        end
                        local crittimes = tonumber(self:getCrittimesNow()) / 100
                        local targetDefence = tonumber(target:getDefenseMoFaNow())
                        local attackbreakA = tonumber(self:getAttackbreakNow())
                        local defbreakA = tonumber(self:getManaattackbreakNow())
                        local targetAntiAttack = tonumber(target:getAntiattackNow())
                        local targetAntiDefRatio = tonumber(target:getAntimanaattackNow())
                        local _type = XTHD.action.type.wuligongji
                        if calculatetype == 1 then
                            targetDefence = tonumber(target:getDefenseWuLiNow())
                            targetAntiDefRatio = tonumber(target:getAntiphysicalattackNow())
                            defbreakA = tonumber(self:getPhysicalattackbreakNow())
                            if baoji == true then
                                _type = XTHD.action.type.wulibaoji
                            end
                        elseif baoji == true then
                            _type = XTHD.action.type.fashubaoji
                        else
                            _type = XTHD.action.type.fashugongji
                        end
                        if not(targetDefence > 0) or not targetDefence then
                            targetDefence = 0
                        end
                        local defB = targetDefence *(1 -(attackbreakA / 100 + defbreakA / 100))
                        local _critRatio = 1
                        if baoji == true then
                            local targetAnticrit = tonumber(target:getAnticritNow()) / 100
                            _critRatio = crittimes - targetAnticrit < 1 and 1 or crittimes - targetAnticrit
                        end
                        local _hitBlood =(hurt - defB *(1 -(attackbreakA / 100 + defbreakA / 100))) *(1 -(targetAntiAttack / 100 + targetAntiDefRatio / 100))
                        local _level_diff_ = 1 +(self:getLevel() - targetLevel) / 50
                        if _level_diff_ < 0.1 then
                            _level_diff_ = 0.1
                        end
                        _hitBlood = _hitBlood * _level_diff_ * _critRatio
                        if not(_hitBlood > 1) or not _hitBlood then
                            _hitBlood = 1
                        end
                        if _hitBlood < hurt * 0.15 then
                            _hitBlood = hurt * 0.15
                        end
                        _hitBlood = _hitBlood * hurtPercent
                        local hp = _hitBlood
                        local victim = target
                        target:runAction(cc.Sequence:create(cc.TintTo:create(0.05, 255, 0, 0), cc.TintTo:create(0, 255, 255, 255)))
                        if target:getFaceDirection() == BATTLE_DIRECTION.LEFT then
                            target:runAction(cc.Sequence:create(cc.MoveBy:create(0.05, cc.p(2, 0)), cc.MoveBy:create(0.05, cc.p(-4, 0)), cc.MoveBy:create(0.05, cc.p(2, 0))))
                        else
                            target:runAction(cc.Sequence:create(cc.MoveBy:create(0.05, cc.p(-2, 0)), cc.MoveBy:create(0.05, cc.p(4, 0)), cc.MoveBy:create(0.05, cc.p(-2, 0))))
                        end
                        local extraHp = target:getHpExtra()
                        hp = self:getHeroHurtFix(_skillData, hp)
                        target:runActionTip( {
                            blood = - hp,
                            crit = baoji,
                            attacker = attacker,
                            _type = _type,
                            skill = _skillData,
                            count = count
                        } )
                        if extraHp < hp and 0 < self:getSuckBlood() then
                            local _tmp_hp = hp - extraHp
                            local suck = self:getSuckBlood() / 100 * math.abs(_tmp_hp) *(1 + self:getBehealedNow() / 100)
                            self:runActionTip( {
                                blood = suck,
                                crit = false,
                                attacker = attacker,
                                _type = XTHD.action.type.jiaxue,
                                skill = _skillData,
                                count = 1
                            } )
                        end
                        if self:getType() == ANIMAL_TYPE.PLAYER then
                            XTHD.dispatchEvent( { name = EVENT_NAME_SHAKE_SCREEN })
                        end
                        if 0 >= target:getHpNow() then
                            victim:setMp(0)
                            attacker:setMp(attacker:getMp() + BATTLE_MP.DEAD)
                            if victim:getSide() == BATTLE_SIDE.LEFT then
                                XTHD.dispatchEvent( {
                                    name = EVENT_NAME_BATTLE_CLEAR_MP(victim:getHeroId()),
                                    data =
                                    {
                                        heroid = victim:getHeroId(),
                                        standId = victim:getStandId()
                                    }
                                } )
                            end
                            if attacker:getSide() == BATTLE_SIDE.LEFT then
                                XTHD.dispatchEvent( {
                                    name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(attacker:getHeroId()),
                                    data =
                                    {
                                        mpadd = BATTLE_MP.DEAD,
                                        standId = attacker:getStandId()
                                    }
                                } )
                            end
                        elseif skillId ~= 69 and not victim._unPauseNode:getActionByTag(BATTLE_MP_VICTIMCTRL.TAG) then
                            local mp = 0
                            if hp > 0 and _type ~= XTHD.action.type.buff and extraHp < hp then
                                local _tmp_hp_ = math.abs(hp - extraHp)
                                mp = 10 /(victim:getHpNow() / victim:getHpTotal()) + victim:getMpMax() * _tmp_hp_ / victim:getHpTotal()
                            end
                            if victim:getWaiImmune() and calculatetype == 1 or victim:getNeiImmune() and calculatetype == 2 then
                                mp = 0
                            end
                            if mp > BATTLE_MAX_HURT_REMP then
                                mp = BATTLE_MAX_HURT_REMP or mp
                            end
                            if mp ~= 0 then
                                victim:setMp(victim:getMp() + mp)
                                if victim:getSide() == BATTLE_SIDE.LEFT then
                                    XTHD.dispatchEvent( {
                                        name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(victim:getHeroId()),
                                        data =
                                        {
                                            mpadd = mp,
                                            standId = victim:getStandId()
                                        }
                                    } )
                                end
                            end
                            local _action = performWithDelay(victim._unPauseNode, function()
                                victim._unPauseNode:stopActionByTag(BATTLE_MP_VICTIMCTRL.TAG)
                            end , BATTLE_MP_VICTIMCTRL.TIME)
                            _action:setTag(BATTLE_MP_VICTIMCTRL.TAG)
                        end
                        if target:getHeroId() == 44 and target:getStatus() == BATTLE_STATUS.SUPER then
                            local _allInfo = target:getSkills()
                            local _skill0Data = _allInfo.skillid0
                            if _skill0Data.sound_hit then
                                local musicFile = "res/sound/skill/" .. _skill0Data.sound_hit .. ".mp3"
                                musicManager.playEffect(musicFile, false)
                            end
                        end
                        local hit_effect = _skillData.hit_effect
                        if tonumber(hit_effect) and tonumber(hit_effect) == -1 then
                        else
                            local max_effectframe = _skillData.max_effectframe
                            local effectspeed = _skillData.effectspeed
                            local effectSprite = XTHD.createSprite("res/image/tmpbattle/effect/hiteffect004/1.png")
                            effectSprite:setScale(self:getScaleY())
                            target:addNodeForSlot( {
                                node = effectSprite,
                                slotName = "midPoint",
                                zorder = 10
                            } )
                            if tonumber(hit_effect) ~= nil and tonumber(hit_effect) == 0 then
                                hit_effect = "hiteffect004"
                                max_effectframe = 3
                                effectspeed = 20
                            end
                            effectSprite:setScaleX(-1 * effectSprite:getScaleX())
                            local effect_animation = getAnimation("res/image/tmpbattle/effect/" .. hit_effect .. "/", 1, max_effectframe, tonumber(effectspeed) / 1000)
                            effectSprite:runAction(cc.Sequence:create(effect_animation, cc.RemoveSelf:create(true)))
                        end
                        _buffMingzhongTargets[#_buffMingzhongTargets + 1] = target
                    end
                else
                    self:showMissTip(target)
                    target:doTalent(BATTLE_TALENT_TYPE.TYPE_DODGE)
                end
            end
        end
        if _mingzhong_ == true then
            if #_buffMingzhongTargets > 0 then
                params.skillHurt = hurt
                params.targets = _buffMingzhongTargets
                self:doBuff(params)
            end
            if attacker ~= nil then
                local sound_hit = _skillData.sound_hit
                if sound_hit then
                    local musicFile = "res/sound/skill/" .. sound_hit .. ".mp3"
                    musicManager.playEffect(musicFile, false)
                end
                if addMingzhongMp then
                    local mpadd_attacker = BATTLE_MP.ATTACKER / #tabPercentage
                    attacker:setMp(attacker:getMp() + mpadd_attacker)
                    if attacker:getSide() == BATTLE_SIDE.LEFT then
                        XTHD.dispatchEvent( {
                            name = EVENT_NAME_REFRESH_HERO_PERCENTAGE(attacker:getHeroId()),
                            data =
                            {
                                mpadd = mpadd_attacker,
                                standId = attacker:getStandId()
                            }
                        } )
                    end
                end
            end
            local _allInfo = self:getSkills()
            local _normalSkill = _allInfo.skillid
            if _skillData.skillid == _normalSkill.skillid then
                self:addNormalAtkTimes()
                self:doTalent(BATTLE_TALENT_TYPE.TYPE_NORMAL_HIT_NUM)
            end
        end
    end
end
function Character:getEffectSpineFromCache(prefix, scale)
    local json_file = prefix .. ".json"
    local atlas_file = prefix .. ".atlas"
    local scale_value = scale == nil and self:getScaleY() or scale
    local eff = sp.SkeletonAnimation:create(json_file, atlas_file, 1)
    eff:setTimeScale(self:getTimeScale())
    eff:setScale(scale_value)
    return eff
end
function Character:addNodeForSlot(params)
    local node = params.node
    local slotName = params.slotName
    local zorder = params.zorder
    local slot = self:getNodeForSlot(slotName)
    slot:addChild(node)
    local _pScale = node:getScaleY() / self:getScaleY()
    node:setScale(_pScale)
    if zorder ~= nil then
        slot:setLocalZOrder(zorder)
    end
end
function Character:getSlotPositionInWorld(slotName)
    local pointNode = self:getNodeForSlot(slotName)
    if pointNode then
        local pointWorldPos = pointNode:convertToWorldSpace(cc.p(0.5, 0.5))
        local pointNodePos = cc.Director:getInstance():getRunningScene():convertToNodeSpace(pointWorldPos)
        return pointNodePos
    end
    return cc.p(0, 0)
end
function Character:getAnimationName()
    return self._animationName
end
function Character:updateZorder(_Zorder)
    self:setLocalZOrder(_Zorder)
    XTHD.dispatchEvent( { name = EVENT_NAME_BATTLE_FRESH_ZORDER })
end
function Character:startMpTimeRecover(...)
    if self:getSide() == BATTLE_SIDE.RIGHT then
        self._coverAction = schedule(self, function()
            if self:isAlive() == true then
                self:setMp(self:getMp() + BATTLE_MP.AUTO)
            end
        end , 5)
    end
end
function Character:changeToIdel()
    if self:getYD_Bian() then
        self:playAnimation(BATTLE_ANIMATION_ACTION.BIAN_IDLE, true)
    else
        self:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, true)
    end
    self:setMove(false)
end
function Character:changeToMove(isRun)
    local _name = BATTLE_ANIMATION_ACTION.RUN
    if self:getYD_Bian() then
        _name = BATTLE_ANIMATION_ACTION.BIAN_RUN
    end
    self:playAnimation(_name, true)
    local _state = BATTLE_STATUS.RUN
    self:setStatus(_state)
    self:setMove(true)
end
function Character:playAnimation(name, loop)
    if self:getAnimationName() == name then
        return
    end
    local aniName = name
    if self:isExistAnimation(aniName) == false then
        if name == BATTLE_ANIMATION_ACTION.WALK then
            aniName = BATTLE_ANIMATION_ACTION.RUN
            if self:isExistAnimation(aniName) == false then
                return
            end
        else
            return
        end
    end
    loop = loop or false
    local status = self:getStatus()
    self:setMove(false)
    if name == BATTLE_ANIMATION_ACTION.IDLE or name == BATTLE_ANIMATION_ACTION.BIAN_IDLE then
        self:setStatus(BATTLE_STATUS.IDLE)
    elseif name == BATTLE_ANIMATION_ACTION.RUN or name == BATTLE_ANIMATION_ACTION.BIAN_RUN then
        self:setStatus(BATTLE_STATUS.RUN)
        self:setMove(true)
    elseif name == BATTLE_ANIMATION_ACTION.WALK then
        self:setStatus(BATTLE_STATUS.WALK)
        self:setMove(true)
    elseif name == BATTLE_ANIMATION_ACTION.DEATH or name == BATTLE_ANIMATION_ACTION.BIAN_DEATH then
        self._isAlive = false
        self:doDeathAnimationStart()
        self:setStatus(BATTLE_STATUS.DEAD)
        local musicFile = "res/sound/hero/sound_effect_" .. self:getHeroId() .. "_death.mp3"
        musicManager.playEffect(musicFile, false)
    elseif name == BATTLE_ANIMATION_ACTION.SUPER or name == BATTLE_ANIMATION_ACTION.BIAN_SUPER then
        self:setStatus(BATTLE_STATUS.SUPER)
    elseif name == BATTLE_ANIMATION_ACTION.ATTACK then
        self:setStatus(BATTLE_STATUS.ATTACK)
    elseif name == BATTLE_ANIMATION_ACTION.ATK1 then
        self:setStatus(BATTLE_STATUS.ATK1)
    elseif name == BATTLE_ANIMATION_ACTION.ATK2 then
        self:setStatus(BATTLE_STATUS.ATK2)
    elseif name == BATTLE_ANIMATION_ACTION.ATK3 then
        self:setStatus(BATTLE_STATUS.ATK3)
    elseif name == BATTLE_ANIMATION_ACTION.DEFENSE or name == BATTLE_ANIMATION_ACTION.BIAN_DEFENSE then
        self:setStatus(BATTLE_STATUS.DEFENSE)
    elseif name == BATTLE_ANIMATION_ACTION.DIZZ or name == BATTLE_ANIMATION_ACTION.BIAN_DIZZ then
        self:setStatus(BATTLE_STATUS.DIZZ)
        self:setMove(false)
    elseif name == BATTLE_ANIMATION_ACTION.BIAN then
        self:setStatus(BATTLE_STATUS.BIAN)
    end
    if status == BATTLE_STATUS.DIZZ then
        self:setStatus(BATTLE_STATUS.DIZZ)
    end

    self._animationName = name
    self:setAnimation(0, aniName, loop)
end
function Character:_create(params)
    print("Character:create")
    return Character.new(params)
end
function Character:createWithParams(params)
    local id = params.id
    local _type = params._type
    local heroId = id
    if params.monster then
        heroId = params.monster.heroid
    elseif _type == ANIMAL_TYPE.MONSTER then
        local heroData = gameData.getDataFromCSV("EnemyList", { monsterid = id })
        heroId = heroData.heroid
    end
    local target = XTHD.battle.getAnimalPathByHeroId(heroId)
    params.resourceId = heroId
    print("resourceId=" .. tostring(params.resourceId))
    if id > 1000 then
        id = id % 1000
        params.id = id
    end
    if params.monster then
        heroId = heroId % 1000
        params.monster.heroid = heroId
    end
    print("id=" .. tostring(id))
    return requires(target):create(params)
end
