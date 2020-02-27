local BattleLayer = class("BattleLayer", function(params)
    return XTHDDialog:create()
end )
local TAG_COUNT_DOWN = 100
-- BATTLE_TIME_SCALE = BATTLE_SPEED.X2
function BattleLayer:replay(params)
    if self._uiLay then
        self._uiLay:setVisible(true)
    end
    self._random_list = clone(self.BATTLE_RANDOM_RECORD)
    self._super_list = clone(self.BATTLE_SUPER_RECORD)
    self:unscheduleUpdate()
    self._isReplaying = true
    self._end = false
    self._sceneSwitching = false
    self:removeAllChildren()
    self:stopAllActions()
    self:_start(params)
    if self._controlLayer then
        doFuncForAllChild(self._controlLayer, function(child)
            if child.isAvatarButton then
                child:setTouchEndedCallback( function()
                end )
            end
        end )
    end
end
function BattleLayer:pauseBattle(notPauseAni)
    self:pauseTimer()
    self:pauseAll(notPauseAni)
    self:pause()
end
function BattleLayer:pauseAll(notPauseAni)
    self._isPaused = true
    self._animalLayer:pause()
    if self._isReplaying ~= true then
        self._controlLayer:pause()
    end
    self._bg:pauseAll()
    if not notPauseAni then
        doFuncForAllChild(self._animalLayer, function(child)
            if child.pauseSelf then
                child:pauseSelf()
            else
                child:pause()
            end
        end )
    end
end
function BattleLayer:resumeAll(notResumeAni)
    self._isPaused = false
    self._animalLayer:resume()
    if self._isReplaying ~= true then
        self._controlLayer:resume()
    end
    self._bg:resumeAll()
    if not notResumeAni then
        doFuncForAllChild(self._animalLayer, function(child)
            if child.resumeSelf then
                if child:getDimCount() < 1 then
                    child:resumeSelf()
                end
            else
                child:resume()
            end
        end )
    end
end
function BattleLayer:resumeBattle(notResumeAni)
    self:resumeTimer()
    self:resumeAll(notResumeAni)
    self:resume()
end
function BattleLayer:pauseTimer()
    if self._timer then
        self._timer:pause()
    end
end
function BattleLayer:resumeTimer()
    if self._timer then
        self._timer:resume()
    end
end
function BattleLayer:isAuto()
    if self._isReplaying then
        return true
    end
    return self._isAuto
end
function BattleLayer:ctor(params)
    print("创建战斗")
    self._sceneSwitching = false
    self._isReplaying = false
    self._isAuto = false
end
function BattleLayer:initWithParams(params)
    self._restoredBattleData = clone(params)
    self.BATTLE_RANDOM_RECORD = params.randomRecord or { }
    self.BATTLE_SUPER_RECORD = params.superRecord or { }
    if params.isReplaying == nil then
    end
    self._isReplaying = params.isReplaying
    if self._isReplaying == true then
        self._random_list = #self.BATTLE_RANDOM_RECORD > 0 and clone(self.BATTLE_RANDOM_RECORD) or { }
        self._super_list = #self.BATTLE_SUPER_RECORD > 0 and clone(self.BATTLE_SUPER_RECORD) or { }
    end
    self._sceneSwitching = false
    self._isAuto = false
    self:_init(params)
end
function BattleLayer:_init(params)
    self._isPaused = false
    self:_removeEventListener()
    self._tick_ = 0
    local winWidth = self:getContentSize().width
    local winHeight = self:getContentSize().height
    local _instanceId = params.instancingid
    local _dropList = params.dropList
    local _instanceType = params.instanceType
    local _bgList = params.bgList
    local _teamListLeft = params.teamListLeft
    local _teamListRight = params.teamListRight
    local _battleEndCallback = params.battleEndCallback
    local _replayEndCallback = params.replayEndCallback
    local _battleType = params.battleType
    local _bgm = params.bgm
    local _battleTime = params.battleTime
    local isAuto = params.isAuto
    local _helps = params.helps
    local _worldBuff = params.worldBuff or "0#0#0"
    local _worldBuffDamage = params.worldBuffDamage or "0#0"
    local _bgType = params.bgType
    local _isGuide = params.isGuide == nil and -1 or params.isGuide
    local _showSpeed = params.showSpeed == nil and true or params.showSpeed
    if isAuto == nil then
        isAuto = getAutoState(_battleType)
    end
    if _isGuide ~= -1 then
        isAuto = false
    end
    if _battleTime == nil then
        _battleTime = 0
    end
    self._waves = #_teamListRight
    if _bgm ~= nil then
        local musicFile = _bgm
        musicManager.playMusic(musicFile, true)
    end
    self._isGuide = _isGuide
    self._instanceId = _instanceId
    self._battleEndCallback = _battleEndCallback
    self._replayEndCallback = _replayEndCallback
    self._battleType = _battleType
    self._bgList = _bgList
    self._isAuto = isAuto
    self._helps = _helps or { }
    self._worldBuff = string.split(_worldBuff, "#")
    self._worldBuffDamage = string.split(_worldBuffDamage, "#")
    local animalLayer = XTHD.createLayer()
    self:addChild(animalLayer)
    self._animalLayer = animalLayer
    local worldEffLayer = XTHD.createLayer()
    self:addChild(worldEffLayer)
    self._worldEffLayer = worldEffLayer
    local function _callback(...)
        if self._buildPointer then
            self._buildPointer:removeFromParent()
            self._buildPointer = false
        end
    end
    local btn_speed = createSpeedButton(_battleType, _callback)
    if _showSpeed == false then
        btn_speed:setVisible(false)
    end
    local btn_speed_down = XTHDPushButton:createWithParams( { text = "减速3倍" })
    btn_speed_down:setTouchEndedCallback( function()
        local _timeScale = 0.2
        if cc.Director:getInstance():getScheduler():getTimeScale() < 1 then
            cc.Director:getInstance():getScheduler():setTimeScale(1)
            BATTLE_TIME_SCALE = BATTLE_SPEED.X1
            btn_speed_down:setString("减速3倍")
        else
            cc.Director:getInstance():getScheduler():setTimeScale(_timeScale)
            btn_speed_down:setString("恢复正常-夏侯惇")
            BATTLE_TIME_SCALE = math.abs(_timeScale)
        end
    end )
    btn_speed_down:setPosition(cc.p(100, winHeight - 100))
    self:addChild(btn_speed_down)
    local paused = false
    local btn_pause = XTHDPushButton:createWithParams( { text = "暂停" })
    btn_pause:setTouchEndedCallback( function()
        if paused == true then
            cc.Director:getInstance():resume()
            paused = false
            btn_pause:setString("暂停")
        else
            cc.Director:getInstance():pause()
            paused = true
            btn_pause:setString("继续")
        end
    end )
    btn_pause:setPosition(cc.p(winWidth / 2, winHeight - 50))
    self:addChild(btn_pause)
    local btn = XTHDPushButton:createWithParams( {
        text = "返回",
        endCallback = function()
            cc.Director:getInstance():resume()
            cc.Director:getInstance():getScheduler():setTimeScale(1)
            cc.Director:getInstance():popScene()
        end
    } )
    btn:setPosition(cc.p(winWidth - 100, winHeight - 50))
    self:addChild(btn)
    local btn_replay = XTHDPushButton:createWithParams( {
        text = "重播",
        endCallback = function()
            XTHD.dispatchEvent( { name = EVENT_NAME_BATTLE_REPLAY })
        end
    } )
    btn_replay:setPosition(cc.p(winWidth - 150, winHeight - 50))
    self:addChild(btn_replay)
    if IS_NEI_TEST then
        local btn_oneKey = XTHDPushButton:createWithParams( {
            text = "",
            touchSize = cc.size(50,50),
            anchor = cc.p(0,0),
            endCallback = function()
                if self._isReplaying then
                    return
                end
                local rightNowData = self._rightNowData
                local _rightTeamList = self._rightTeamList
                local right_animals = rightNowData.team or { }
                for k, v in pairs(right_animals) do
                    if v:isAlive() then
                        v:setHpNow(0)
                        v._isAlive = false
                        v:playAnimation(BATTLE_ANIMATION_ACTION.DEATH, false)
                        XTHD.dispatchEvent( {
                            name = EVENT_NAME_BATTLE_DEAD,
                            data = { animal = v }
                        } )
                    end
                end
            end
        } )
        self:addChild(btn_oneKey)
    end
    btn_speed_down:setVisible(false)
    btn_pause:setVisible(false)
    btn_replay:setVisible(false)
    btn:setVisible(false)
    local function debug(BATTLE_DEBUG)
        if BATTLE_DEBUG and BATTLE_DEBUG == true then
            btn_speed_down:setVisible(true)
            btn_pause:setVisible(true)
            btn_replay:setVisible(true)
            btn:setVisible(true)
        end
    end
    local btn_debug = XTHDPushButton:createWithParams( {
        touchSize = cc.size(100,100),
        needSwallow = false
    } )
    btn_debug._times_ = 0
    btn_debug:setTouchEndedCallback( function()
        btn_debug._times_ = btn_debug._times_ + 1
        if btn_debug._times_ >= 5 then
            debug(true)
        end
    end )
    btn_debug:setPosition(cc.p(20, 400))
    self:addChild(btn_debug)
    self._leftAnimals = { }
    self._rightAnimals = { }
    local controlLayer = XTHD.createLayer()
    controlLayer:setCascadeOpacityEnabled(true)
    local _di = XTHD.createSprite("res/image/tmpbattle/avatorBg.png")
    local _diSize = _di:getContentSize()
    _di:setAnchorPoint(0.5, 0)
    _di:setPosition(winWidth * 0.5, 0)
    _di:setVisible(false)
    controlLayer:addChild(_di)
    self._controlLayer = controlLayer
    local _clockBg = XTHD.createButton( {
        normalNode = cc.Sprite:create("res/image/tmpbattle/pausebtn.png"),
        selectedNode = cc.Sprite:create("res/image/tmpbattle/pausebtn_disabled.png"),
        endCallback = function()
            if self._isReplaying then
            elseif _battleType ~= BattleType.PVE and _battleType ~= BattleType.ELITE_PVE and _battleType ~= BattleType.DIFFCULTY_COPY 
                and _battleType ~= BattleType.OFFERREWARD_PVE and _battleType ~= BattleType.SINGLECHALLENGE and _battleType ~= BattleType.JADITE_COPY_PVE and _battleType ~= BattleType.GODBEASE_PVE then
                XTHDTOAST(LANGUAGE_TIPS_BATTLE_PAUSEUNABLE)
                return
            end
            XTHD.dispatchEvent( { name = EVENT_NAME_BATTLE_PAUSE })
            if self._isReplaying then
                self:addChild(BattleUIPauseLayer:create(_battleType, function()
                    self:hideWithoutBg()
                    if self._replayEndCallback then
                        self._replayEndCallback()
                    end
                end ))
            else
                self:addChild(BattleUIPauseLayer:create(_battleType))
            end
        end
    } )
    controlLayer:addChild(_clockBg)
    if _battleType ~= BattleType.PVP_GUILDFIGHT and _battleType ~= BattleType.PVP_SHURA then
        _clockBg:setPosition(40, winHeight - _clockBg:getContentSize().height * 0.5)
        if self._isReplaying then
            local _replayTag = XTHD.createSprite("res/image/tmpbattle/replayTag.png")
            self:addChild(_replayTag)
            _replayTag:setPosition(150, winHeight - 30)
            _replayTag:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(1))))
        else
            local btnAuto = createAutoButton(_battleType)
            btnAuto:setPosition(cc.p(115, winHeight - btnAuto:getContentSize().height / 2))
            controlLayer:addChild(btnAuto)
        end
    else
        _clockBg:setPosition(winWidth * 0.5, winHeight - _clockBg:getContentSize().height * 0.5)
    end
    local battle_time = _battleTime
    self._battleTotleTime = _battleTime
    self._battle_time = battle_time
    local min = math.modf(battle_time / 60)
    local sec = battle_time % 60
    if sec < 10 then
        sec = "0" .. sec or sec
    end
    local label_timer = XTHDLabel:createWithParams( {
        text = min .. ":" .. sec,
        size = 18,
        color = cc.c3b(246,241,243)
    } )
    label_timer:setAnchorPoint(cc.p(0.5, 0.5))
    label_timer:setPosition(cc.p(_clockBg:getContentSize().width * 0.5, _clockBg:getContentSize().height * 0.5 - 8))
    _clockBg:addChild(label_timer)
    if _battleType == BattleType.GOLD_COPY_PVE then
        label_timer:setVisible(false)
    end
    local _speedDi = XTHD.createSprite("res/image/tmpbattle/btnSpeedDi.png")
    _speedDi:setPosition(50, _diSize.height * 0.5 - 35)
    controlLayer:addChild(_speedDi)
    btn_speed:setPosition(50, _diSize.height * 0.5 - 35)
    btn_speed:setScale(0.7)
    self._btn_speed = btn_speed
    controlLayer:addChild(btn_speed)

    local scrollBg = cc.Sprite:create("res/image/tmpbattle/scrollBg.png")
    controlLayer:addChild(scrollBg)
    scrollBg:setPosition(self:getContentSize().width - scrollBg:getBoundingBox().width/2,scrollBg:getBoundingBox().height/2)
    self.scrollBg = scrollBg

    local _leftTeamList = _teamListLeft
    local _rightTeamList = _teamListRight
    if _teamListRight == nil or #_teamListRight < 1 then
        XTHDTOAST(LANGUAGE_TIPS_WORDS233)
        return
    end
    if _leftTeamList == nil or #_leftTeamList < 1 then
        XTHDTOAST(LANGUAGE_TIPS_WORDS234)
        return
    end
    local dis_avatar = 10
    self._record_hurt_left = { }
    self._reportDataTeamRight = { }
    self._rightTeamList = _rightTeamList
    self:createOneWaveEnemy(1)
    local reportDataTeamLeft = { }
    local tmp_data_left = { }
    reportDataTeamLeft[#reportDataTeamLeft + 1] = tmp_data_left
    local _avatarBtns = { }
    local _leftTeamListNew = { }
    for teamIndex, team in pairs(_leftTeamList) do
        local _team = { }
        local _count = #team
        local posTb = SortPos:sortFromMiddle(cc.p(self.scrollBg:getPositionX() + 35, self.scrollBg:getPositionY() + 15), _count, 75)
        for k, _aniData in pairs(team) do
            local animal = Character:createWithParams(_aniData)
            if not animal then
                return
            end
            _team[#_team + 1] = animal
            local index = k
            x = winWidth * -0.05 - winWidth * 0.07 * index - 50
            y = index % 2 == 0 and self:_getPosY(3) or self:_getPosY(7)
            animal:setParent(nil)
            animal:setVisible(true)
            animal:setFaceDirection(BATTLE_DIRECTION.RIGHT)
            animal:setPosition(cc.p(x, y))
            local z = 0
            z = index % 2 == 0 and 10 or 0
            animalLayer:addChild(animal, z)
            animal:setLineNum(z)
            animal:changeToMove(true)
            animal:setSide(BATTLE_SIDE.LEFT)
            animal:setStandId(index)
            animal:setWave(teamIndex)
            animal:setVisible(false)
            if teamIndex == 1 then
                animal:setVisible(true)
                local avatar = AvatarButton:createWithParams( { animal = animal })
                avatar:setPosition(posTb[_count - k + 1])
                _avatarBtns[#_avatarBtns + 1] = avatar
                avatar:setScale(0.6)
                controlLayer:addChild(avatar)
            end
            animal:setDefualtRootY()
            if animal:getStandRange() > 250 then
                animal:getSkills().skillid.range = animal:getSkills().skillid.range + 60 *(k - 1)
            end
            self._record_hurt_left[animal:getHeroId()] = 0
            local tmp = { }
            tmp.type = animal:getType()
            tmp.id = animal:getId()
            tmp.heroid = animal:getHeroId()
            tmp.hp_begin = animal:getHpBegin()
            tmp.sp_begin = animal:getMp()
            tmp.sp_end = 0
            tmp.hp_end = 0
            tmp.hurt = 0
            tmp.standId = animal:getStandId()
            tmp_data_left[#tmp_data_left + 1] = tmp
        end
        _leftTeamListNew[#_leftTeamListNew + 1] = _team
    end
    _leftTeamList = _leftTeamListNew
    self._reportDataTeamLeft = reportDataTeamLeft
    self._leftAnimals = _leftTeamList[1]
    table.remove(_leftTeamList, 1)
    self:addChild(controlLayer)
    if BattleType.PVP_SHURA == _battleType or BattleType.PVP_GUILDFIGHT == _battleType or BattleType.MULTICOPY_FIGHT == _battleType then
        for k, v in pairs(_avatarBtns) do
            v:setTouchEndedCallback(nil)
        end
        self._isAuto = true
    end
    schedule(label_timer, function()
        battle_time = battle_time - 1
        battle_time = battle_time < 0 and 0 or battle_time
        self._battle_time = battle_time
        if battle_time <= 0 and _isGuide == -1 then
            label_timer:stopAllActions()
            self:unscheduleUpdate()
            self:pauseAll(true)
            doFuncForAllChild(self._animalLayer, function(child)
                if child.pauseSelf then
                    child:pauseSelf()
                else
                    child:pause()
                end
                child:runAction(cc.TintTo:create(2, 200, 200, 200))
            end )
            self:_showResult(BATTLE_RESULT.TIMEOUT)
        else
            local min = math.modf(battle_time / 60)
            local sec = battle_time % 60
            if sec < 10 then
                sec = "0" .. sec or sec
            end
            label_timer:setString(min .. ":" .. sec)
        end
    end , 1, TAG_COUNT_DOWN)
    self._timer = label_timer
    self._clockbg = _clockBg
    if _isGuide ~= -1 then
        label_timer:setVisible(false)
    end
    local wave = 1
    local _waveIndex = XTHD.createBMFontLabel( {
        text = wave .. "/" .. tostring(self:getWaveCount()),
        fnt = XTHD.resource.bmfont.white
    } )
    _waveIndex:setPosition(cc.p(self:getContentSize().width * 0.5, _clockBg:getPositionY() -5))
    controlLayer:addChild(_waveIndex)
    self._waveIndex = _waveIndex
    if _battleType == BattleType.PVP_SHURA or _battleType == BattleType.GOLD_COPY_PVE or _battleType == BattleType.WORLDBOSS_PVE or _battleType == BattleType.PVP_GUILDFIGHT then
        _waveIndex:setVisible(false)
    end
    self._wave = wave
    self:_addEventListener()
    local _data = {
        _type = _bgType,
        effPar = self._animalLayer,
        bgList = self._bgList,
        isGuide = _isGuide,
        worldBuff = self._worldBuff,
        worldBuffDamage = self._worldBuffDamage,
        worldEffLayer = self._worldEffLayer
    }
    self._bg = BattleBackground:createWithParams(_data)
    self:addChild(self._bg, -1)
    if self._bg:getBgType() == BATTLE_GUIDEBG_TYPE.TYPE_NORMAL then
        self._bg:changeToNext()
    end
end
function BattleLayer:createOneWaveEnemy(_wave)
    if #self._rightTeamList < 1 then
        return { }
    end
    local winWidth = self:getContentSize().width
    local winHeight = self:getContentSize().height
    local _teamInfo = self._rightTeamList[1].team
    local _storyIds = self._rightTeamList[1].storyId
    local key = _wave
    local tmp_data = { }
    local _team = { }
    if _teamInfo then
        for k, _aniData in pairs(_teamInfo) do
            local animal = Character:createWithParams(_aniData)
            _team[#_team + 1] = animal
            local index = k
            local x = winWidth * 1.05 + winWidth * 0.07 * index + 80
            local y = index % 2 ~= 0 and self:_getPosY(7) or self:_getPosY(3)
            local z = 0
            z = index % 2 == 0 and 10 or 0
            if #_teamInfo > 5 then
                x = x + k * 80
                if k > 5 then
                    y = self:_getPosY(5)
                    z = 5
                end
            end
            animal:setParent(nil)
            animal:setVisible(true)
            animal:setFaceDirection(BATTLE_DIRECTION.LEFT)
            animal:setPosition(cc.p(x, y))
			if self._battleType == BattleType.GUILD_BOSS_PVE or self._battleType == BattleType.CAMP_SHOUWEI then
				animal:setPosition(cc.p(x, y - 40))
			end
            self._animalLayer:addChild(animal, z)
            animal:setLineNum(z)
            animal:setSide(BATTLE_SIDE.RIGHT)
            animal:setStandId(index)
            animal:setWave(key)
            if animal:isNpc() == true then
                animal:setPositionX(winWidth / 2 + 150)
                animal:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, true)
            elseif animal:isWorldBoss() == true then
                animal:setPositionX(winWidth - 160)
                animal:setLocalZOrder(0)
                animal:setPositionY(winHeight * 0.5 - 100)
                animal:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, true)
            else
                animal:changeToMove(true)
            end
            if animal:isWorldBoss() then
                animal:setDefualtRootY(self:_getPosY(3))
            else
                animal:setDefualtRootY()
            end
            if animal:getStandRange() > 250 then
                animal:getSkills().skillid.range = animal:getSkills().skillid.range + 60 *(k - 1)
            end
            local tmp = { }
            tmp.type = animal:getType()
            tmp.id = animal:getId()
            tmp.heroid = animal:getHeroId()
            tmp.hp_begin = animal:getHpBegin()
            tmp.sp_begin = animal:getMp()
            tmp.sp_end = 0
            tmp.hp_end = 0
            tmp.hurt = 0
            tmp.standId = animal:getStandId() + 100
            tmp_data[#tmp_data + 1] = tmp
        end
    end
    self._reportDataTeamRight[#self._reportDataTeamRight + 1] = tmp_data
    table.remove(self._rightTeamList, 1)
    self._rightNowData = { team = _team, storyId = _storyIds }
end
function BattleLayer:_addEventListener()
    XTHD.addEventListener( {
        name = EVENT_NAME_PLAY_SUPER_ACT,
        callback = function(event)
            local _data = event.data
            event.data.isPlaySuper = self:_doSuper(_data)
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_FRESH_ZORDER,
        callback = function(event)
            self:_freshSideZorder(BATTLE_SIDE.RIGHT)
            self:_freshSideZorder(BATTLE_SIDE.LEFT)
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_PLAY_SUPER_DIM_DISMISS,
        callback = function(event)
            local data = event.data
            local heroid = data.heroid
            local existDim = false
            for k, animal in pairs(self._leftAnimals) do
                animal:setDimCount(animal:getDimCount() -1)
                if animal:getDimCount() < 1 then
                    animal:showDim(false)
                    animal:resumeSelf()
                else
                    existDim = true
                end
            end
            for k, animal in pairs(self._rightNowData.team) do
                animal:setDimCount(animal:getDimCount() -1)
                if animal:getDimCount() < 1 then
                    animal:showDim(false)
                    animal:resumeSelf()
                else
                    existDim = true
                end
            end
            if existDim == false then
                self._bg:setAllColor(cc.c3b(255, 255, 255))
                self:resumeBattle(true)
                doFuncForAllChild(self._animalLayer, function(child)
                    if child.isAnimal then
                        child:isAnimal()
                    else
                        child:resume()
                    end
                end )
            end
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_SHAKE_SCREEN,
        callback = function(event)
            local data = event.data
            data = data or { }
            data.shakeNode = self
            XTHD.action.runActionShake(data)
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_PLAY_EFFECT,
        callback = function(event)
            local data = event.data
            local node = data.node
            local zorder = data.zorder
            if node ~= nil then
                if zorder == nil then
                    zorder = node:getLocalZOrder()
                end
                self._animalLayer:addChild(node, zorder)
            end
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_PLAY_WORLD_EFFECT,
        callback = function(event)
            local data = event.data
            local node = data.node
            local zorder = data.zorder
            if node ~= nil then
                if zorder == nil then
                    zorder = node:getLocalZOrder()
                end
                self._worldEffLayer:addChild(node, zorder)
            end
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_DEAD,
        callback = function(event)
            local data = event.data
            local animal = data.animal
            if animal ~= nil then
                animal:setMp(0)
                if animal:getSide() == BATTLE_SIDE.LEFT then
                    XTHD.dispatchEvent( {
                        name = EVENT_NAME_BATTLE_AVATAR_GRAY(animal:getHeroId()),
                        data =
                        {
                            standId = animal:getStandId()
                        }
                    } )
                elseif self._rightNowData.team then
                end
            end
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS,
        callback = function(event)
            local data = event.data
            local side = data.side
            local team = self:getAliveTeam(side)
            data.team = team
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_GET_RANDOM,
        callback = function(event)
            local data = event.data
            local random = 1
            math.newrandomseed()
            local _max = data.max or 100
            random = math.random(0, _max)
            local _standId = data.standId
            local _heroid = data.heroid
            local _side = data.side
            self.BATTLE_RANDOM_RECORD[_side] = self.BATTLE_RANDOM_RECORD[_side] or { }
            self.BATTLE_RANDOM_RECORD[_side][_heroid] = self.BATTLE_RANDOM_RECORD[_side][_heroid] or { }
            local _time = random
            table.insert(self.BATTLE_RANDOM_RECORD[_side][_heroid], _time)
            data.random = random
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_REPLAY,
        callback = function(event)
            local _reCall
            if event.data and event.data.replayEndCallback then
                _reCall = event.data.replayEndCallback
            end
            local _params = clone(self._restoredBattleData)
            _params.replayEndCallback = _reCall
            self:replay(_params)
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_RESUME,
        callback = function(event)
            self:resumeBattle()
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_PAUSE,
        callback = function(event)
            self:pauseBattle()
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_ISAUTO,
        callback = function(event)
            local data = event.data
            data.auto = self:isAuto()
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_ISREPLAY,
        callback = function(event)
            local data = event.data
            data.isReplay = self._isReplaying
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_GETGUIDESTATE,
        callback = function(event)
            local data = event.data
            data.guideState = self._isGuide
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_MUSIC_PLAY,
        callback = function(event)
            if _bgm ~= nil then
                local musicFile = _bgm
                musicManager.playMusic(musicFile, true)
            end
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_AUTO,
        callback = function(event)
            local data = event.data
            local auto = data.auto
            if auto == nil then
                auto = false
            end
            self._isAuto = auto
            if auto == true then
                XTHD.dispatchEvent( { name = EVENT_NAME_BATTLE_AUTO_SUPER })
            end
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_DATA_HURT_RECORD,
        callback = function(event)
            local data = event.data
            local animal = data.animal
            local target = data.target
            local targetPos = data.targetPos
            local hurt = data.hurt
            if animal and hurt then
                if animal:getSide() == BATTLE_SIDE.LEFT then
                    if self._reportDataTeamLeft[animal:getWave()] and self._reportDataTeamLeft[animal:getWave()][animal:getStandId()] then
                        local lastHurt = self._reportDataTeamLeft[animal:getWave()][animal:getStandId()].hurt
                        if lastHurt == nil then
                            lastHurt = 0
                        end
                        self._reportDataTeamLeft[animal:getWave()][animal:getStandId()].hurt = lastHurt + hurt
                        if animal ~= target then
                            XTHD.dispatchEvent( {
                                name = "GOLD_COPY_GET_GOLD_NUM",
                                data = { hurt_num = hurt, target = targetPos }
                            } )
                        end
                    end
                elseif animal:getSide() == BATTLE_SIDE.RIGHT then
                    local lastHurt = self._reportDataTeamRight[animal:getWave()][animal:getStandId()].hurt
                    if lastHurt == nil then
                        lastHurt = 0
                    end
                    self._reportDataTeamRight[animal:getWave()][animal:getStandId()].hurt = lastHurt + hurt
                end
            end
        end
    } )
    XTHD.addEventListener( {
        name = EVENT_NAME_BATTLE_GET_ALL_ATTACKABLE_TARGETS,
        callback = function(event)
            local data = event.data
            local animal = data.animal
            local skill = data.skill
            if animal and skill then
                data.targets = self:_getAttackableTargets(animal, skill)
            end
        end
    } )
end
function BattleLayer:cleanWorldEffect()
    self._bg:cleanWorldEffect()
end
function BattleLayer:_removeEventListener()
    XTHD.removeEventListener(EVENT_NAME_PLAY_SUPER_ACT)
    XTHD.removeEventListener(EVENT_NAME_PLAY_SUPER_DIM_DISMISS)
    XTHD.removeEventListener(EVENT_NAME_SHAKE_SCREEN)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_PLAY_EFFECT)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_PLAY_WORLD_EFFECT)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_DEAD)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_GET_ALL_ALIVE_TARGETS)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_GET_RANDOM)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_REPLAY)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_RESUME)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_PAUSE)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_ISAUTO)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_AUTO)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_MUSIC_PLAY)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_DATA_HURT_RECORD)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_GET_ALL_ATTACKABLE_TARGETS)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_FRESH_ZORDER)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_ISREPLAY)
    XTHD.removeEventListener(EVENT_NAME_BATTLE_GETGUIDESTATE)
end
function BattleLayer:onCleanup()
    cc.Director:getInstance():getScheduler():setTimeScale(1)
    self:removeAllChildren()
    self:_removeEventListener()
    helper.collectMemory(true)
    print("战斗被回收了")
end
function BattleLayer:getWaveCount()
    return self._waves
end
function BattleLayer:_initCache(...)
    for i = 1, 8 do
        if i < 4 then
            XTHD.createSprite("res/image/tmpbattle/effect/hiteffect004/" .. i .. ".png")
        end
    end
    cc.Label:createWithBMFont("res/fonts/wulibaoji.fnt", "1")
    cc.Label:createWithBMFont("res/fonts/fashubaoji.fnt", "1")
    cc.Label:createWithBMFont("res/fonts/fashugongji.fnt", "1")
    cc.Label:createWithBMFont("res/fonts/wuligongji.fnt", "1")
    cc.Label:createWithBMFont("res/fonts/jiaxue.fnt", "1")
    sp.SkeletonAnimation:create("res/spine/effect/atk0_effect/daozhao.json", "res/spine/effect/atk0_effect/daozhao.atlas", 1)
    sp.SkeletonAnimation:create("res/spine/effect/jineng/jineng.json", "res/spine/effect/jineng/jineng.atlas", 1)
end
function BattleLayer:start()
    helper.collectMemory(true)
    self:_doFrame()
end
function BattleLayer:_start(params)
    helper.collectMemory(true)
    self:_init(params)
    self:_doFrame()
end
function BattleLayer:_showResult(win)
    self:cleanWorldEffect()
    self:stopActionByTag(TAG_COUNT_DOWN)
    if self._end == true then
        print("战斗已经开始")
        return
    end
    self._end = true
    self:pauseTimer()
    self._clockbg:setVisible(false)
    self._controlLayer:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create( function()
        self._controlLayer:removeAllChildren()
    end )))
    cc.Director:getInstance():getScheduler():setTimeScale(1)
    if self._isReplaying == true then
        performWithDelay(self, function()
            self:hideWithoutBg()
            if self._replayEndCallback then
                self._replayEndCallback()
            end
        end , 1.5)
        return
    end
    local star = 3
    for k, animal in pairs(self._leftAnimals) do
        self._reportDataTeamLeft[animal:getWave()][animal:getStandId()].hp_end = animal:getHpNow()
        self._reportDataTeamLeft[animal:getWave()][animal:getStandId()].sp_end = animal:getMp()
        if self._battleType == BattleType.MULTICOPY_FIGHT then
            self._reportDataTeamLeft[animal:getWave()][animal:getStandId()].charId = animal:getHeroData().charId
        end
        if animal:getHpNow() <= 0 then
            star = star - 1
        end
    end
    if star < 1 then
        star = 1
    end
    local params = { }
    params.battleType = self._battleType
    params.result = win
    params.star = star
    if self._instanceId then
        params.instancingid = self._instanceId
    end
    for k, animal in pairs(self._rightNowData.team) do
        self._reportDataTeamRight[animal:getWave()][animal:getStandId()].hp_end = animal:getHpNow()
        self._reportDataTeamRight[animal:getWave()][animal:getStandId()].sp_end = animal:getMp()
    end
    while 0 < #self._rightTeamList do
        local _teamInfo = self._rightTeamList[1].team
        local tmp_data = { }
        if _teamInfo then
            for k, _aniData in pairs(_teamInfo) do
                local tmp = { }
                tmp.type = _aniData._type
                tmp.id = _aniData.id
                if heroType == ANIMAL_TYPE.PLAYER then
                    tmp.heroid = _aniData.data.heroid
                else
                    tmp.heroid = _aniData.id
                end
                tmp.hp_begin = _aniData.startHp and _aniData.startHp or 0
                tmp.sp_begin = _aniData.startSp and _aniData.startSp or 0
                tmp.sp_end = 0
                tmp.hp_end = 0
                tmp.hurt = 0
                tmp.standId = k + 100
                tmp_data[#tmp_data + 1] = tmp
            end
        end
        self._reportDataTeamRight[#self._reportDataTeamRight + 1] = tmp_data
        table.remove(self._rightTeamList, 1)
    end
    params.left = self._reportDataTeamLeft
    params.right = self._reportDataTeamRight
    params.wave = self._wave
    local costTime = self._battleTotleTime - self._battle_time
    if costTime < 0 then
        costTime = 0
    elseif costTime > self._battleTotleTime then
        costTime = self._battleTotleTime
    end
    params.battleCostTime = costTime
    params.randomList = self.BATTLE_RANDOM_RECORD
    params.superList = self.BATTLE_SUPER_RECORD
    if win == BATTLE_RESULT.TIMEOUT then
        musicManager.stopBackgroundMusic()
        cc.Director:getInstance():getScheduler():setTimeScale(1)
        if self._uiLay then
            self._uiLay:setVisible(false)
        end
        local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 8925))
        self:addChild(layer)
        local json_file = "res/spine/effect/fightOverTime/luo.json"
        local atlas_file = "res/spine/effect/fightOverTime/luo.atlas"
        local _eff = sp.SkeletonAnimation:create(json_file, atlas_file, 1)
        _eff:setAnimation(0, "animation", false)
        local winSize = cc.Director:getInstance():getWinSize()
        _eff:setPosition(winSize.width * 0.5, winSize.height * 0.5)
        self:addChild(_eff)
        _eff:registerSpineEventHandler( function(event)
            local name = event.eventData.name
            if name == "duang" then
                musicManager.playEffect("res/sound/sound_battleOverTime.mp3")
            end
        end , sp.EventType.ANIMATION_EVENT)
        performWithDelay(_eff, function(...)
            if self._battleEndCallback then
                self._battleEndCallback(params)
            end
        end , 1.5)
    elseif self._battleEndCallback then
        local spine = sp.SkeletonAnimation:create("res/image/loading/newLoading/skeleton.json", "res/image/loading/newLoading/skeleton.atlas", 1)
        spine:setAnimation(0, "animation", false)
        spine:setPosition(self:getContentSize().width*0.5, self:getContentSize().height*0.5)
        spine:registerSpineEventHandler( function(event)
            spine:setVisible(false)
        end , sp.EventType.ANIMATION_COMPLETE)
        self:addChild(spine)
        self._battleEndCallback(params)
    end
end
function BattleLayer:hideWithoutBg()
    self:cleanWorldEffect()
    self._animalLayer:setVisible(false)
    cc.Director:getInstance():getScheduler():setTimeScale(1)
    if self._uiLay then
        self._uiLay:setVisible(false)
    end
end
function BattleLayer:getReportDataTeam()
    return self._reportDataTeamLeft, self._reportDataTeamRight
end
function BattleLayer:getAliveTeam(side)
    if side == BATTLE_SIDE.RIGHT then
        return self._rightNowData.team
    else
        return self._leftAnimals
    end
end
function BattleLayer:getAliveAndInScreenTeam(side)
    local _tmp = self:getAliveTeam(side)
    local res = { }
    local winWidth = cc.Director:getInstance():getWinSize().width
    for k, v in pairs(_tmp) do
        if v:getPositionX() >= 20 and v:getPositionX() <= winWidth - 20 then
            res[#res + 1] = v
        end
    end
    return res
end
function BattleLayer:_getPosY(idx)
    return 180 + 15 * idx
end
function BattleLayer:_removeAllSuperState()
    for k, animal in pairs(self._leftAnimals) do
        animal:showDim(false)
        animal:setDimCount(0)
        animal:resumeSelf()
    end
    for k, animal in pairs(self._rightNowData.team) do
        animal:showDim(false)
        animal:setDimCount(0)
        animal:resumeSelf()
    end
    self._bg:setAllColor(cc.c3b(255, 255, 255))
    self:resumeBattle(true)
    doFuncForAllChild(self._animalLayer, function(child)
        if child.isAnimal then
            child:isAnimal()
        else
            child:resume()
        end
    end )
end
function BattleLayer:_doSuper(data)
    if self._sceneSwitching ~= false then
        return
    end
    local _heroid = data.heroid
    local _standId = data.standId
    local _side = data.side
    local _play_side_animals = self._leftAnimals
    local _pause_side_animals = self._rightNowData.team
    local animalType = ANIMAL_TYPE.PLAYER
    local shouldPlaySuper = false
    if _side == BATTLE_SIDE.RIGHT then
        _pause_side_animals = self._leftAnimals
        _play_side_animals = self._rightNowData.team
    end
    local atkName = BATTLE_ANIMATION_ACTION.SUPER
    local winWidth = self:getContentSize().width
    local winHeight = self:getContentSize().height
    local minx = 70
    local maxx = winWidth - 70
    local _doSuperAni = _play_side_animals[_standId]
    if not _doSuperAni or _doSuperAni:isAlive() ~= true or _doSuperAni:getHeroId() ~= _heroid or _doSuperAni:isAddict() == true or _doSuperAni:isFrozen() == true or _doSuperAni:isFreeze() == true or _doSuperAni:isPetrifaction() == true or _doSuperAni:isBeCatched() == true or _doSuperAni:isSilence() == true or _doSuperAni:getStatus() == BATTLE_STATUS.SUPER or _doSuperAni:getStatus() == BATTLE_STATUS.DIZZ or minx > _doSuperAni:getPositionX() or maxx < _doSuperAni:getPositionX() or _doSuperAni:getType() == ANIMAL_TYPE.MONSTER and _doSuperAni:isPaused() == true or not _doSuperAni:isExistAnimation(atkName) or _doSuperAni:getHeroId() == 34 and not _doSuperAni:canDoSuper() then
        return shouldPlaySuper
    end
    local skill = _doSuperAni:getSkillByAction(atkName)
    local targets = self:_getAttackableTargets(_doSuperAni, skill)
    if targets == nil or next(targets) == nil then
        return shouldPlaySuper
    end
    shouldPlaySuper = true
    animalType = _doSuperAni:getType()
    _doSuperAni:setMp(_doSuperAni:getMpMax() *(_doSuperAni:getAngerSave() / 100))
    if _doSuperAni:getSide() == BATTLE_SIDE.LEFT then
        XTHD.dispatchEvent( {
            name = EVENT_NAME_BATTLE_CLEAR_MP(_heroid),
            data =
            {
                heroid = _heroid,
                side = _side,
                standId = _standId
            }
        } )
    end
    _doSuperAni:showDim(false)
    _doSuperAni:setDimCount(0)
    _doSuperAni:resumeSelf()
    _doSuperAni:setSelectedTargets( { name = atkName, targets = targets })
    local posOther = targets[1]:getPositionX()
    local posSelf = _doSuperAni:getPositionX()
    if _doSuperAni:getFaceDirection() == BATTLE_DIRECTION.LEFT and posOther > posSelf then
        _doSuperAni:setFaceDirection(BATTLE_DIRECTION.RIGHT)
    elseif _doSuperAni:getFaceDirection() == BATTLE_DIRECTION.RIGHT and posOther < posSelf then
        _doSuperAni:setFaceDirection(BATTLE_DIRECTION.LEFT)
    end
    if animalType == ANIMAL_TYPE.PLAYER then
        self._bg:setAllColor(BATTLE_DIM_COLOR)
        self:pauseBattle(true)
        doFuncForAllChild(self._animalLayer, function(child)
            if child.isAnimal then
                if child ~= _doSuperAni then
                    if child:getSide() == BATTLE_SIDE.LEFT then
                        if child:getStatus() ~= BATTLE_STATUS.SUPER then
                            child:showDim(true)
                            child:setDimCount(child:getDimCount() + 1)
                            child:pauseSelf()
                        end
                    elseif child:getType() == ANIMAL_TYPE.MONSTER or child:getStatus() ~= BATTLE_STATUS.SUPER then
                        child:showDim(true)
                        child:setDimCount(child:getDimCount() + 1)
                        child:pauseSelf()
                    end
                end
            else
                child:pause()
            end
        end )
    end
    _doSuperAni:playAnimation(atkName)
    _doSuperAni:setLastAttackTime(0)
    if self._isReplaying ~= true then
        self.BATTLE_SUPER_RECORD[_side] = self.BATTLE_SUPER_RECORD[_side] or { }
        self.BATTLE_SUPER_RECORD[_side][_heroid] = self.BATTLE_SUPER_RECORD[_side][_heroid] or { }
        local _time = self._tick_
        table.insert(self.BATTLE_SUPER_RECORD[_side][_heroid], _time)
    end
    return shouldPlaySuper
end
function BattleLayer:_isDeadAll(animals)
    local flag = true
    for k, v in pairs(animals) do
        if v:isAlive() == true then
            flag = false
            break
        end
    end
    return flag
end
function BattleLayer:_resetLeftStands(sParams)
    local params = sParams or { }
    if params.isTurn == nil then
    end
    local _isTurn = params.isTurn
    local _endCall = params.sEndCall
    local _time = tonumber(params.moveTime) or 1
    if params.isEndToStand == nil then
    end
    local _endToStand = params.isEndToStand
    local _haveWait = false
    local _animals = self._leftAnimals
    if _animals or next(_animals) ~= nil then
        local winWidth = cc.Director:getInstance():getWinSize().width
        local _aliveAni = { }
        for k, v in pairs(_animals) do
            if v:isAlive() == true then
                _aliveAni[#_aliveAni + 1] = v
            else
                v:setVisible(false)
            end
        end
        local x, y, z, _pos
        if #_aliveAni > 0 then
            if #_aliveAni > 0 then
                table.sort(_aliveAni, function(a, b)
                    local n1 = tonumber(a:getHeroData().attackrange) or 0
                    local n2 = tonumber(b:getHeroData().attackrange) or 0
                    return n1 < n2
                end )
            end
            for index, animal in pairs(_aliveAni) do
                _side = animal:getSide()
                z = index % 2 == 0 and 10 or 0
                animal:setLocalZOrder(z)
                animal:setLineNum(z)
                animal:changeToMove(true)
                animal:setStandId(index)
                x = winWidth * -0.05 - winWidth * 0.07 * index + winWidth * 0.5
                y = index % 2 ~= 0 and self:_getPosY(7) or self:_getPosY(3)
                _pos = cc.p(animal:getPosition())
                if x ~= _pos.x or y ~= _pos.y then
                    _haveWait = true
                    if _isTurn then
                        if x < _pos.x then
                            animal:setFaceDirection(BATTLE_DIRECTION.LEFT)
                        else
                            animal:setFaceDirection(BATTLE_DIRECTION.RIGHT)
                        end
                    else
                        animal:setFaceDirection(BATTLE_DIRECTION.RIGHT)
                    end
                    if _time > 0 then
                        animal:runAction(cc.Sequence:create(cc.MoveTo:create(_time, cc.p(x, y)), cc.CallFunc:create( function()
                            animal:setFaceDirection(BATTLE_DIRECTION.RIGHT)
                            if _endToStand then
                                animal:changeToIdel()
                            end
                        end )))
                    else
                        animal:setPosition(cc.p(x, y))
                        if _endToStand then
                            animal:changeToIdel()
                        end
                    end
                end
            end
            self:_freshSideZorder(BATTLE_SIDE.LEFT)
        end
    end
    if _haveWait then
        performWithDelay(self, function()
            if _endCall and type(_endCall) == "function" then
                _endCall()
            end
        end , _time + 0.2)
    elseif _endCall and type(_endCall) == "function" then
        _endCall()
    end
end
function BattleLayer:_doFrame()
    self:_initCache()
    self._sceneSwitching = false
    self._tick_ = 0
    self._frameCd = 0
    local winWidth = self:getContentSize().width
    local winHeight = self:getContentSize().height
    local rightNowData = self._rightNowData
    local _rightTeamList = self._rightTeamList
    local left_animals = self._leftAnimals
    local right_animals = rightNowData.team or { }
    local _type = self._bg:getBgType()
    if not self._bg.haveDoneStart then
        self._bg.haveDoneStart = true
        performWithDelay(self, function()
            self._bg:startGuide(self, function()
                self:_doFrame()
            end )
        end , 0.1)
        return
    end
    for k, v in pairs(left_animals) do
        if v._initCache then
            v:_initCache()
        end
    end
    for k, v in pairs(right_animals) do
        if v._initCache then
            v:_initCache()
        end
        v:setInFight(true)
    end
    doFuncForAllChild(self._controlLayer, function(child)
        if child.isAvatarButton then
            child:start()
        end
    end )
    local num = #left_animals
    local rightNum = #right_animals
    if num < rightNum then
        num = rightNum
    end
    local storyId
    local excuteAttack = false
    local _tmpCountTime = 0
    local deadAllLeft = false
    local deadAllRight = false
    self:scheduleUpdateWithPriorityLua( function(dt)
        local speed = BATTLE_TIME_SCALE * MOVE_SPEED
        storyId = rightNowData.storyId
        deadAllLeft = self:_isDeadAll(left_animals)
        deadAllRight = self:_isDeadAll(right_animals)
        if deadAllLeft == true then
            self:resumeBattle()
            if deadAllRight == true then
                self:_showResult(BATTLE_RESULT.FAIL)
                print("!!!!!!!!!同归于尽!!!!!!!!!!!")
            else
                local _end = true
                self:pauseTimer()
                for k, rightAnimal in pairs(right_animals) do
                    rightAnimal:removeBuffEffect()
                    local status = rightAnimal:getStatus()
                    if status == BATTLE_STATUS.SUPER or status == BATTLE_STATUS.ATTACK or status == BATTLE_STATUS.ATK1 or status == BATTLE_STATUS.ATK2 or status == BATTLE_STATUS.ATK3 or status == BATTLE_STATUS.DEFENSE then
                        _end = false
                    else
                        rightAnimal:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, true)
                    end
                end
                if _end == true then
                    for k, rightAnimal in pairs(right_animals) do
                        rightAnimal:playAnimation(BATTLE_ANIMATION_ACTION.WIN, true)
                    end
                    self:unscheduleUpdate()
                    self:_showResult(BATTLE_RESULT.FAIL)
                end
            end
            return
        elseif deadAllRight == true then
            self:resumeBattle()
            if #_rightTeamList > 0 and storyId == nil then
                local _switch = true
                for k, leftAnimal in pairs(left_animals) do
                    local status = leftAnimal:getStatus()
                    if status == BATTLE_STATUS.SUPER or status == BATTLE_STATUS.ATTACK or status == BATTLE_STATUS.ATK1 or status == BATTLE_STATUS.ATK2 or status == BATTLE_STATUS.ATK3 then
                        _switch = false
                    elseif leftAnimal:isAlive() == true then
                        leftAnimal:setFaceDirection(BATTLE_DIRECTION.RIGHT)
                        leftAnimal:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, true)
                    end
                end
                if _switch == true then
                    self._sceneSwitching = true
                    self:unscheduleUpdate()
                    if not self:checkDataSafe(left_animals, right_animals) then
                        return
                    end
                    if right_animals then
                        for index, animal in pairs(right_animals) do
                            if animal:isAlive() == false then
                                animal:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create( function()
                                    animal:setVisible(false)
                                end )))
                            end
                        end
                    end
                    do
                        local _left_animals_alive = { }
                        local _dead_left_animals_ = { }
                        for k, leftAnimal in pairs(left_animals) do
                            if leftAnimal:isAlive() == true then
                                _left_animals_alive[#_left_animals_alive + 1] = leftAnimal
                                leftAnimal:waveRest(true)
                            else
                                _dead_left_animals_[#_dead_left_animals_ + 1] = leftAnimal
                                leftAnimal:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create( function()
                                    leftAnimal:setVisible(false)
                                end )))
                            end
                        end
                        local function createNextWave()
                            local _nowWave = self:getWaveCount() - #self._rightTeamList + 1
                            self:createOneWaveEnemy(_nowWave)
                            local _right_animals = self._rightNowData.team
                            if _right_animals then
                                for k, animal in pairs(_right_animals) do
                                    animal:changeToMove(true)
                                    animal:setVisible(true)
                                end
                            end
                            self._waveIndex:setString(_nowWave .. "/" .. self:getWaveCount())
                        end
                        local _controlChild = self._controlLayer:getChildren()
                        for k, child in pairs(_controlChild) do
                            child:pause()
                        end
                        if self._bg:getBgType() == BATTLE_GUIDEBG_TYPE.TYPE_BRIDGE then
                            createNextWave()
                            local sParams = { moveTime = 2, isEndToStand = false }
                            self:_resetLeftStands(sParams)
                            self._bg:startFightNext(self, right_animals, _dead_left_animals_, function()
                                for k, child in pairs(_controlChild) do
                                    child:resume()
                                end
                                self:_doFrame()
                            end )
                            return
                        end
                        self:scheduleUpdateWithPriorityLua( function(dt)
                            local speed = BATTLE_TIME_SCALE * 1.5 * MOVE_SPEED
                            for k, leftAnimal in pairs(_left_animals_alive) do
                                leftAnimal:changeToMove(true)
                                leftAnimal:move(speed, false)
                                if k >= #_left_animals_alive and leftAnimal:getPositionX() > winWidth + 100 then
                                    self:unscheduleUpdate()
                                    self._bg:changeToNext()
                                    createNextWave()
                                    for index, leftAnimal in pairs(_left_animals_alive) do
                                        local x = winWidth * -0.05 - winWidth * 0.07 * index - 50
                                        local y = index % 2 ~= 0 and self:_getPosY(7) or self:_getPosY(3)
                                        leftAnimal:setPosition(x, y)
                                        leftAnimal:setLocalZOrder(index % 2 == 0 and 10 or 0)
                                        leftAnimal:setDefualtRootY()
                                        leftAnimal:setLineNum(self:getLocalZOrder())
                                    end
                                    self:_freshSideZorder(BATTLE_SIDE.LEFT)
                                    local function _endDo()
                                        for k, child in pairs(_controlChild) do
                                            child:resume()
                                        end
                                        self:_doFrame()
                                    end
                                    if self._bg:getBgType() == BATTLE_GUIDEBG_TYPE.TYPE_NORMAL then
                                        self._bg:startFightNext(self, _endDo)
                                        break
                                    end
                                    _endDo()
                                    break
                                end
                            end
                        end , 0)
                    end
                end
                return
            elseif #_rightTeamList < 1 then
                local _end = true
                self:cleanWorldEffect()
                self:pauseTimer()
                for k, leftAnimal in pairs(left_animals) do
                    leftAnimal:removeBuffEffect()
                    if leftAnimal:getNowAniName() == BATTLE_ANIMATION_ACTION.SUPER or leftAnimal:getNowAniName() == BATTLE_ANIMATION_ACTION.ATTACK or leftAnimal:getNowAniName() == BATTLE_ANIMATION_ACTION.ATK1 or leftAnimal:getNowAniName() == BATTLE_ANIMATION_ACTION.ATK2 or leftAnimal:getNowAniName() == BATTLE_ANIMATION_ACTION.ATK3 or leftAnimal:getNowAniName() == BATTLE_ANIMATION_ACTION.DEFENSE then
                        _end = false
                    elseif leftAnimal:isAlive() == true then
                        leftAnimal:playAnimation(BATTLE_ANIMATION_ACTION.IDLE, true)
                    end
                end
                if _end == true then
                    for k, leftAnimal in pairs(left_animals) do
                        if leftAnimal:isAlive() == true then
                            leftAnimal:playAnimation(BATTLE_ANIMATION_ACTION.WIN, true)
                        end
                    end
                    self:unscheduleUpdate()
                    print("右边没人，胜利")
                    if not self:checkDataSafe(left_animals, right_animals) then
                        return
                    end
                    self._controlLayer:setVisible(false)
                    local _controlChild = self._controlLayer:getChildren()
                    for k, child in pairs(_controlChild) do
                        child:pause()
                    end
                    self._bg:startFightEnd(self, function()
                        self:_showResult(BATTLE_RESULT.WIN)
                    end )
                end
                return
            end
        end
        excuteAttack = false
        _tmpCountTime = _tmpCountTime + dt
        if _tmpCountTime > 0.1 then
            _tmpCountTime = _tmpCountTime - 0.1
            excuteAttack = true
        end
        self._tick_ = self._tick_ + dt
        local _haveDoSpuer = false
        for i = 1, num do
            local leftAnimal = left_animals[i]
            local rightAnimal = right_animals[i]
            if leftAnimal and leftAnimal:isAlive() == true then
                local last_time = leftAnimal:getLastAttackTime()
                leftAnimal:setLastAttackTime(last_time + dt)
                leftAnimal:move(speed)
                if leftAnimal:getStatus() == BATTLE_STATUS.SUPER then
                    _haveDoSpuer = true
                end
            end
            if rightAnimal and rightAnimal:isAlive() == true then
                local last_time = rightAnimal:getLastAttackTime()
                rightAnimal:setLastAttackTime(last_time + dt)
                rightAnimal:move(speed)
                if rightAnimal:getStatus() == BATTLE_STATUS.SUPER then
                    _haveDoSpuer = true
                end
            end
            if leftAnimal and leftAnimal:isAlive() == true and excuteAttack == true then
                if leftAnimal:getPositionX() >= winWidth * 0.2 and storyId then
                    XTHD.dispatchEvent( { name = EVENT_NAME_BATTLE_PAUSE })
                    self:addChild(StoryLayer:createWithParams( {
                        storyId = storyId,
                        callback = function()
                            XTHD.dispatchEvent( { name = EVENT_NAME_BATTLE_RESUME })
                            self._rightNowData.storyId = nil
                        end
                    } ))
                    return
                end
                if self:_shouldExcuteAttack(leftAnimal) == true then
                    self:_doOneAnimalLogic(leftAnimal, right_animals)
                end
            elseif leftAnimal and leftAnimal:isAlive() == false and leftAnimal:getAnimationName() == BATTLE_ANIMATION_ACTION.IDLE then
                leftAnimal:setVisible(false)
            end
            if rightAnimal and rightAnimal:isAlive() == true and excuteAttack == true and self:_shouldExcuteAttack(rightAnimal) == true then
                self:_doOneAnimalLogic(rightAnimal, left_animals)
            elseif rightAnimal and rightAnimal:isAlive() == false and rightAnimal:getAnimationName() == BATTLE_ANIMATION_ACTION.IDLE then
                rightAnimal:setVisible(false)
            end
        end
        if _haveDoSpuer == false and self._isPaused == true then
            self:_removeAllSuperState()
        end
    end , 0)
end
function BattleLayer:_doOneAnimalSuper(sAnimal)
    local _doSuper = false
    if sAnimal:getMp() < sAnimal:getMpMax() then
        return _doSuper
    end
    if sAnimal:getSide() == BATTLE_SIDE.LEFT and self:isAuto() ~= true then
        return _doSuper
    end
    local _data = {
        heroid = sAnimal:getHeroId(),
        side = sAnimal:getSide(),
        standId = sAnimal:getStandId()
    }
    _doSuper = self:_doSuper(_data)
    return _doSuper
end
function BattleLayer:_doOneAnimalLogic(_animal, _otherAni)
    local minx = 70
    local winWidth = cc.Director:getInstance():getWinSize().width
    local maxx = winWidth - 70
    local _doSuper = self:_doOneAnimalSuper(_animal)
    if _doSuper then
        return
    end
    if minx <= _animal:getPositionX() and maxx >= _animal:getPositionX() then
        self:_doAttack(_animal, _otherAni)
    elseif _animal:getStatus() == BATTLE_STATUS.IDLE and _animal:getStatus() ~= BATTLE_STATUS.DIZZ then
        _animal:changeToMove()
    end
    return false
end
function BattleLayer:_getReplayRandom(sParams)
    if self._isReplaying ~= true then
        return 0
    end
    if self._random_list == nil or next(self._random_list) == nil then
        return 0
    end
    local _side = sParams.side
    local _sideDatas = self._random_list[_side]
    if _sideDatas == nil or next(_sideDatas) == nil then
        return 0
    end
    local _heroid = sParams.heroid
    local _heroDatas = _sideDatas[_heroid]
    if _heroDatas == nil or next(_heroDatas) == nil then
        return 0
    end
    local random = _heroDatas[1]
    table.remove(self._random_list[_side][_heroid], 1)
    return random
end
function BattleLayer:_checkDoReplaySuper(sParams)
    if self._isReplaying ~= true then
        return false
    end
    if self._super_list == nil or next(self._super_list) == nil then
        return false
    end
    local _side = sParams.side
    local _sideDatas = self._super_list[_side]
    if _sideDatas == nil or next(_sideDatas) == nil then
        return false
    end
    local _heroid = sParams.heroid
    local _heroDatas = _sideDatas[_heroid]
    if _heroDatas == nil or next(_heroDatas) == nil then
        return false
    end
    local _time = _heroDatas[1]
    if _time > self._tick_ then
        return false
    end
    local _heroid = sParams.heroid
    local _data = {
        heroid = _heroid,
        standId = _standId,
        side = _side
    }
    XTHD.dispatchEvent( { name = EVENT_NAME_PLAY_SUPER_ACT, data = _data })
    if _data.isPlaySuper then
        table.remove(self._super_list[_side][_heroid], 1)
        return true
    end
    return false
end
function BattleLayer:_shouldExcuteAttack(animal)
    local flag = true
    local status = animal:getStatus()
    if status == BATTLE_STATUS.SUPER or status == BATTLE_STATUS.ATTACK or status == BATTLE_STATUS.ATK1 or status == BATTLE_STATUS.ATK2 or status == BATTLE_STATUS.ATK3 or status == BATTLE_STATUS.DEFENSE or status == BATTLE_STATUS.DIZZ or self._sceneSwitching ~= false or animal:isFrozen() == true or animal:isFreeze() == true or animal:isPetrifaction() == true or animal:isBeCatched() == true then
        flag = false
    end
    return flag
end
function BattleLayer:_doAttack(animal, animals)
    local status = animal:getStatus()
    local index = animal:getProcessIndex()
    local isFirst = index
    if index == -1 then
        index = 1
    end
    local process_id = animal:getAttackProcess()[index]
    local atkName = animal:getAtkAnimNameByProcessId(process_id)
    if animal:isAddict() == true or animal:isSilence() == true then
        atkName = BATTLE_ANIMATION_ACTION.ATTACK
    end
    local _skillData = animal:getSkillByAction(atkName)
    local function _doNotAtk(_canMove)
        if animal:isWorldBoss() then
            return
        end
        local alive_animals = { }
        local tmp_animals = self:_getAliveTeam(animal, _skillData)
        for k, v in pairs(tmp_animals) do
            if v and v:isAlive() == true and v:isHiding() ~= true and v:isBeCatched() ~= true and v:isHurtable() ~= false then
                alive_animals[#alive_animals + 1] = v
            end
        end
        local _count = #alive_animals
        if _count <= 0 then
            animal:changeToIdel()
        else
            do
                local posSelf = cc.p(animal:getPosition())
                if _count > 1 then
                    table.sort(alive_animals, function(a, b)
                        local dis1 = math.abs(a:getPositionX() - posSelf.x)
                        local dis2 = math.abs(b:getPositionX() - posSelf.x)
                        return dis1 < dis2
                    end )
                end
                local _otherAni = alive_animals[1]
                local posOther = cc.p(_otherAni:getPosition())
                if animal:getFaceDirection() == BATTLE_DIRECTION.LEFT and posOther.x > posSelf.x then
                    animal:setFaceDirection(BATTLE_DIRECTION.RIGHT)
                elseif animal:getFaceDirection() == BATTLE_DIRECTION.RIGHT and posOther.x < posSelf.x then
                    animal:setFaceDirection(BATTLE_DIRECTION.LEFT)
                end
                if _canMove then
                    local _normalSkill = _skillData
                    local _normalAtkRange = animal:getSkillAttackRangeBySkill(_normalSkill)
                    local isInAttackRange = self:_isInAttackRange(animal, _otherAni, _normalAtkRange)
                    if isInAttackRange then
                        animal:changeToIdel()
                    else
                        animal:changeToMove()
                    end
                else
                    animal:changeToIdel()
                end
            end
        end
    end
    local cd = animal:getSkillCdByAction(_skillData)
    local time_diff = animal:getLastAttackTime() * 1000
    if isFirst == -1 or cd <= time_diff then
        local targets, alive_animals = self:_getAttackableTargets(animal, _skillData)
        if targets ~= nil and next(targets) ~= nil then
            if not animal:isWorldBoss() then
                local pAnimalPos = animal:getPositionX()
                local pHaveForwardTarget = false
                for k, v in pairs(targets) do
                    if animal:getFaceDirection() == BATTLE_DIRECTION.LEFT then
                        if pAnimalPos >= v:getPositionX() then
                            pHaveForwardTarget = true
                            break
                        end
                    elseif pAnimalPos <= v:getPositionX() then
                        pHaveForwardTarget = true
                        break
                    end
                end
                if not pHaveForwardTarget then
                    if animal:getFaceDirection() == BATTLE_DIRECTION.LEFT then
                        animal:setFaceDirection(BATTLE_DIRECTION.RIGHT)
                    else
                        animal:setFaceDirection(BATTLE_DIRECTION.LEFT)
                    end
                end
            end
            local isShouldStandby = true
            for k, target in pairs(targets) do
                if target:isHurtable() == true then
                    isShouldStandby = false
                    break
                end
            end
            if #targets == 1 and targets[1]:isTargetable() == false then
                isShouldStandby = true
            end
            if animal:isExistAnimation(atkName) == false then
                isShouldStandby = true
            end
            if isShouldStandby then
                animal:changeToIdel()
            else
                animal:setMove(false)
                animal:setSelectedTargets( { name = atkName, targets = targets })
                animal:playAnimation(atkName)
                animal:setLastAttackTime(0)
                animal:gotoNextAttackProcessIndex()
            end
            return
        end
        _doNotAtk(true)
        return
    end
    _doNotAtk(false)
end
function BattleLayer:_isInAttackRange(animal, target, attack_range)
    local _box = animal:getBox()
    local lx = _box.x
    local ly = _box.y
    local lwidth = _box.width
    local lheight = _box.height
    local x = lx + lwidth
    if animal:getFaceDirection() == BATTLE_DIRECTION.LEFT then
        x = lx
    end
    local isInAttackRange, distance = circleIntersectRect(cc.p(x, ly + lheight / 2), attack_range, target:getBox())
    return isInAttackRange, distance
end
function BattleLayer:_getAliveTeam(animal, skill)
    local targetType = skill.targettype
    if animal:isAddict() == true then
        targetType = 1
    end
    local side = BATTLE_SIDE.LEFT
    if targetType == 1 then
        side = animal:getSide()
    else
        side = animal:getSide() == BATTLE_SIDE.LEFT and BATTLE_SIDE.RIGHT or BATTLE_SIDE.LEFT
    end
    local tmp_animals = self:getAliveTeam(side)
    return tmp_animals
end
function BattleLayer:_getAttackableTargets(animal, skill)
    local _box = animal:getBox()
    local lx = _box.x
    local ly = _box.y
    local lwidth = _box.width
    local lheight = _box.height
    local targets = { }
    local target_in_attack_range = { }
    local hurtType = skill.target
    local targetType = skill.targettype
    if animal:isAddict() == true then
        targetType = 1
    end
    local alive_animals = { }
    local tmp_animals = self:_getAliveTeam(animal, skill)
    local potential_animals = { }
    local target_by_standid = { }
    local winWidth = cc.Director:getInstance():getWinSize().width
    local attack_range = animal:getSkillAttackRangeBySkill(skill)
    for k, tmpTarget in pairs(tmp_animals) do
        if tmpTarget:isAlive() == true then
            alive_animals[#alive_animals + 1] = tmpTarget
            local isInScreen = tmpTarget:getPositionX() >= 20 and tmpTarget:getPositionX() <= winWidth - 20
            if tmpTarget:getSide() == animal:getSide() then
                isInScreen = true or isInScreen
            end
            if isInScreen == true and tmpTarget:isHiding() == false and tmpTarget:isAlive() == true and tmpTarget:isBeCatched() == false then
                potential_animals[#potential_animals + 1] = tmpTarget
            end
            local isInAttackRange, distance = self:_isInAttackRange(animal, tmpTarget, attack_range)
            local condition = true
            if isInAttackRange == false or tmpTarget:isAlive() == false or tmpTarget:isBeCatched() == true or tmpTarget:isHiding() == true or animal:isAddict() == true and tmpTarget == animal then
                condition = false
            end
            if condition == true then
                tmpTarget._tmp_distance_ = distance
                target_in_attack_range[#target_in_attack_range + 1] = tmpTarget
                target_by_standid[tmpTarget:getStandId()] = tmpTarget
            end
        end
    end
    local selectedTarget
    math.newrandomseed()
    if hurtType == 3 or hurtType == 13 then
        targets = potential_animals
    elseif hurtType == 12 then
        selectedTarget = animal
    elseif #target_in_attack_range > 0 then
        if hurtType == 1 or hurtType == 2 then
            table.sort(target_in_attack_range, function(a, b)
                return a._tmp_distance_ < b._tmp_distance_
            end )
            if hurtType == 1 then
                selectedTarget = target_in_attack_range[1]
            else
                selectedTarget = target_in_attack_range[#target_in_attack_range]
            end
        elseif hurtType == 4 or hurtType == 5 then
            table.sort(target_in_attack_range, function(a, b)
                local ahp = a:getHpNow() * 1 / a:getHpTotal()
                local bhp = b:getHpNow() * 1 / b:getHpTotal()
                return ahp < bhp
            end )
            if hurtType == 4 then
                selectedTarget = target_in_attack_range[1]
            else
                selectedTarget = target_in_attack_range[#target_in_attack_range]
            end
        elseif hurtType > 5 and hurtType < 11 then
            local standId = hurtType - 5
            local found = false
            if target_by_standid[standId] ~= nil then
                selectedTarget = target_by_standid[standId]
                found = true
            end
            if found == false then
                for i = standId, 5 do
                    if target_by_standid[i] ~= nil then
                        selectedTarget = target_by_standid[i]
                        found = true
                        break
                    end
                end
                if found == false then
                    for i = 1, standId do
                        if target_by_standid[i] ~= nil then
                            selectedTarget = target_by_standid[i]
                            found = true
                            break
                        end
                    end
                end
            end
        elseif hurtType == 11 then
            local random = 1
            if #target_in_attack_range > 1 then
                local data = {
                    standId = animal:getStandId(),
                    side = animal:getSide(),
                    heroid = animal:getHeroId(),
                    max = #target_in_attack_range - 1
                }
                XTHD.dispatchEvent( { name = EVENT_NAME_BATTLE_GET_RANDOM, data = data })
                random = data.random + 1
            end
            selectedTarget = target_in_attack_range[random]
        elseif hurtType == 15 then
            table.sort(target_in_attack_range, function(a, b)
                local ahp = a:getHpNow()
                local bhp = b:getHpNow()
                return ahp < bhp
            end )
            selectedTarget = target_in_attack_range[1]
        elseif hurtType == 16 then
            table.sort(target_in_attack_range, function(a, b)
                local aAtkMF = a:getAttackMoFaNow()
                local bAtkMF = b:getAttackMoFaNow()
                return aAtkMF > bAtkMF
            end )
            selectedTarget = target_in_attack_range[1]
        elseif hurtType == 17 then
            table.sort(target_in_attack_range, function(a, b)
                local aAtkWL = a:getAttackWuLiNow()
                local bAtkWL = b:getAttackWuLiNow()
                return aAtkWL > bAtkWL
            end )
            selectedTarget = target_in_attack_range[1]
        end
    end
    if selectedTarget ~= nil and selectedTarget:isAlive() == true then
        targets[#targets + 1] = selectedTarget
    end
    return #targets > 0 and targets or nil, alive_animals
end
function BattleLayer:setUILay(lay)
    self._uiLay = lay
end
function BattleLayer:create()
    return BattleLayer.new()
end
function BattleLayer:createWithParams(params)
    local obj = BattleLayer.new(params)
    obj:initWithParams(params)
    return obj
end
function BattleLayer:_freshSideZorder(sSide)
    local _sideAnimals = self:getAliveTeam(sSide) or { }
    local _animal
    local _allTb = { }
    for i = 1, #_sideAnimals do
        _animal = _sideAnimals[i]
        if _animal and _animal:isAlive() then
            _allTb[#_allTb + 1] = _animal
        end
    end
    local pCount = #_allTb
    if pCount < 2 then
        return
    end
    table.sort(_allTb, function(a, b)
        if a:isWorldBoss() ~= b:isWorldBoss() then
            return a:isWorldBoss()
        end
        if a:getDefualtRootY() ~= b:getDefualtRootY() then
            return a:getDefualtRootY() > b:getDefualtRootY()
        end
        if a:getLineNum() ~= b:getLineNum() then
            return a:getLineNum() < b:getLineNum()
        end
        return a:getStandId() < b:getStandId()
    end )
    for i = 1, pCount do
        _animal = _allTb[i]
        local _parent = _animal:getParent()
        if _parent then
            _parent:reorderChild(_animal, _animal:getLocalZOrder())
        end
    end
end
function BattleLayer:checkDataSafe(sLefts, sRights)
    for k, v in pairs(sLefts) do
        if not v:checkDataSafe() then
            return false
        end
    end
    for k, v in pairs(sRights) do
        if not v:checkDataSafe() then
            return false
        end
    end
    return true
end
return BattleLayer
