local RiChangRenWuDestinyDiceLayer = class("RiChangRenWuDestinyDiceLayer", function()
    return XTHD.createBasePageLayer( { bg = "res/image/daily_task/destiny_dice/dice_bg.png" })
end )

function RiChangRenWuDestinyDiceLayer:onCleanup()
    XTHD.dispatchEvent( { name = CUSTOM_EVENT.REFRESH_TASKLIST })
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/daily_task/destiny_dice/dice_bg.jpg")
    textureCache:removeTextureForKey("res/image/daily_task/destiny_dice/lastDiceCounttext.png")
    textureCache:removeTextureForKey("res/image/daily_task/destiny_dice/diceIntroducetext.png")
    textureCache:removeTextureForKey("res/image/daily_task/destiny_dice/diceProficientyLeveltext.png")
    textureCache:removeTextureForKey("res/image/daily_task/destiny_dice/spineAnimate/shaizi.png")
    textureCache:removeTextureForKey("res/image/daily_task/destiny_dice/diceResult_bg.png")
    local _tb = { "sky", "land", "money", "person", "feicui", "cloud" }
    for k, v in pairs(_tb) do
        textureCache:removeTextureForKey("res/image/daily_task/destiny_dice/dice_" .. v .. ".png")
    end
    for i = 1, 5 do
        textureCache:removeTextureForKey("res/image/daily_task/destiny_dice/diceAni_" .. i .. ".png")
    end
end

function RiChangRenWuDestinyDiceLayer:ctor(data, mainCity)
    self.data = data
    self._mainCity = mainCity
    self._fontSize = 20
    self.maxProficientyLevel = 30
    self.destinyData = { }
    self.diceResultData = { }

    self.lastDiceLabel = nil
    self.diceProgress = nil
    self.diceLevelLabel = nil
    self.proficientyBtn = nil
    self.diceBtn = nil
    self.dicingBtn = nil
    self.diceSpine = nil
    -- 骰子动画

    self._getBtn = nil
    -----获取奖励按钮
    self._continuBtn = nil
    -----我要逆天按钮

    self.diceNode = { }
    -- 存放骰子sp
    self.diceNodePos = {
        cc.p(0.74,53.53),cc.p(92.54,39.31),cc.p(30.65,- 16.24)
        ,cc.p(-83.2,16.26),cc.p(-39.17,- 61.02),cc.p(97.23,- 50.7)
    }
    -- 骰子的存放位置

    self:setStaticData()
    self:setMaxProficientyLevel()

    self:initLayer()
end

function RiChangRenWuDestinyDiceLayer:initLayer()
    local _contentHeight = self:getContentSize().height - 61
    -- 剩余投掷次数
    local _lastDiceCountNameSp = cc.Sprite:create("res/image/daily_task/destiny_dice/lastDiceCounttext.png")
    _lastDiceCountNameSp:setAnchorPoint(cc.p(0, 0.5))
    _lastDiceCountNameSp:setPosition(cc.p(20, _contentHeight - 25 - 30))
    self:addChild(_lastDiceCountNameSp)

    local _lastDiceLabel = getCommonGreenBMFontLabel(self.data.destinyCount or 0)
    _lastDiceLabel:setScale(0.8)
    self.lastDiceLabel = _lastDiceLabel
    _lastDiceLabel:setAnchorPoint(cc.p(0, 0.5))
    _lastDiceLabel:setPosition(cc.p(_lastDiceCountNameSp:getBoundingBox().width + _lastDiceCountNameSp:getBoundingBox().x + 3, _lastDiceCountNameSp:getPositionY() -2))
    self:addChild(_lastDiceLabel)

    self:refreshLastDiceCount()

    local _contentIntroducesp = cc.Sprite:create("res/image/daily_task/destiny_dice/diceIntroducetext.png")
    _contentIntroducesp:setAnchorPoint(cc.p(0, 0.5))
    _contentIntroducesp:setPosition(cc.p(5, _contentHeight - 25))
    self:addChild(_contentIntroducesp)

    local _progressBg = cc.Sprite:create("res/image/common/common_progressBg_1.png")
    _progressBg:setAnchorPoint(cc.p(1, 0.5))
    _progressBg:setPosition(cc.p(self:getContentSize().width - 80, _contentHeight - 40))
    self:addChild(_progressBg)

    local _diceProgress = cc.ProgressTimer:create(cc.Sprite:create("res/image/common/common_progress_1.png"))
    self.diceProgress = _diceProgress
    _diceProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    _diceProgress:setBarChangeRate(cc.p(1, 0))
    _diceProgress:setMidpoint(cc.p(0, 0.5))
    _diceProgress:setPosition(cc.p(_progressBg:getContentSize().width / 2, _progressBg:getContentSize().height / 2))
    _diceProgress:setPercentage(0)
    _progressBg:addChild(_diceProgress)
    --经验数量
    local explable = XTHDLabel:create("",17,"res/fonts/def.ttf")
    explable:setColor(cc.c3b(0,0,0))
    self:addChild(explable)
    explable:setPosition(self:getContentSize().width - 230,self:getContentSize().height - 102)
    self.explable = explable

    self:refreshProgressPercentage()

    -- 等级
    local _levelPosX = _progressBg:getBoundingBox().x + _progressBg:getBoundingBox().width / 2
    local _diceLevelNameSp = cc.Sprite:create("res/image/daily_task/destiny_dice/diceProficientyLeveltext.png")
    _diceLevelNameSp:setAnchorPoint(cc.p(0.5, 0))
    _diceLevelNameSp:setPosition(cc.p(_levelPosX, _progressBg:getBoundingBox().height + _progressBg:getBoundingBox().y))
    self:addChild(_diceLevelNameSp)
    local _diceLevelLabel = XTHDLabel:create(0, self._fontSize)
    _diceLevelLabel:enableShadow(cc.c4b(255, 255, 255, 255), cc.size(0.4, -0.4), 1)
    self.diceLevelLabel = _diceLevelLabel
    _diceLevelLabel:setAnchorPoint(cc.p(0, 0))
    _diceLevelLabel:setColor(cc.c4b(255, 255, 255, 255))
    _diceLevelNameSp:setPositionX(_levelPosX - _diceLevelLabel:getBoundingBox().width / 2)
    _diceLevelLabel:setPosition(cc.p(_diceLevelNameSp:getBoundingBox().x + _diceLevelNameSp:getBoundingBox().width, _diceLevelNameSp:getPositionY() -1))
    self:addChild(_diceLevelLabel)
    self:refreshDiceLevelLabel()

    -- 熟练度奖励
    local _proficientyPosX = self:getContentSize().width - 60
    local _proficientyBtn = XTHD.createButton( {
        normalNode = cc.Sprite:create(),
        selectedNode = cc.Sprite:create(),
        touchSize = cc.size(100,100),
    } )
    self.proficientyBtn = _proficientyBtn
    _proficientyBtn:setAnchorPoint(cc.p(0.5, 0.5))
    _proficientyBtn:setPosition(cc.p(_proficientyPosX, _contentHeight - 40))
    self:addChild(_proficientyBtn)

	self.proficientyBtn:setTouchBeganCallback(function()
		self.proficientyBtn:setScale(0.95)
	end)

	self.proficientyBtn:setTouchMovedCallback(function()
		self.proficientyBtn:setScale(1)
	end)
		
	self.proficientyBtn:setTouchEndedCallback(function()
		self.proficientyBtn:setScale(1)
		self:httptoOpenProficientyRewardLayer()
	end)

    self:refreshProficientyrewardState()

    -- 掷骰子
    local _diceBtn = XTHD.createButton( {
        normalFile = "res/image/daily_task/destiny_dice/diceProficientyBtn_normal.png",
        selectedFile = "res/image/daily_task/destiny_dice/diceProficientyBtn_selected.png",
        touchScale = 0.95,
        endCallback = function()
            self:httpToDice()
        end
    } )
    self.diceBtn = _diceBtn
    _diceBtn:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
    self:addChild(_diceBtn)

    if self.data and self.data.perResult and next(self.data.perResult) ~= nil then
        self.diceResultData = self.data.perResult
        self:continueBeforeDice()
    end

end

function RiChangRenWuDestinyDiceLayer:continueBeforeDice()
    self:setDiceSp()
    self:showDiceResultLayer(self.diceResultData)
    if self.diceBtn ~= nil then
        self.diceBtn:setVisible(false)
    end
end

function RiChangRenWuDestinyDiceLayer:httptoOpenProficientyRewardLayer()
    ClientHttp:requestAsyncInGameWithParams( {
        modules = "openProficiencyReward?",
        successCallback = function(data, obj, response)
            if tonumber(data.result) == 0 then
                data.proficiencyRank = self.data.proficiencyRank or 0
                local _rewardPop = requires("src/fsgl/layer/RiChangRenWu/RiChangRenWuRewardPopLayer.lua"):create(data, self)
                self:addChild(_rewardPop, 1)
            else
                XTHDTOAST(data.msg)
            end
        end,
        -- 成功回调
        targetNeedsToRetain = button,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            -----"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function RiChangRenWuDestinyDiceLayer:createDiceAnimation()
    local _diceSpine = sp.SkeletonAnimation:create("res/image/daily_task/destiny_dice/spineAnimate/shaizi.json", "res/image/daily_task/destiny_dice/spineAnimate/shaizi.atlas", 1.0)

    _diceSpine:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    self:addChild(_diceSpine)
    self.diceSpine = _diceSpine
end

function RiChangRenWuDestinyDiceLayer:setDiceSp()
    if self.diceResultData == nil then
        return
    end
    local _dicePoint = self.diceResultData.destiny or { }
    local _nameTable = { "sky", "land", "money", "person", "feicui", "cloud" }
    if self.diceNode ~= nil and next(self.diceNode) ~= nil then
        for i = 1, #self.diceNode do
            if self.diceNode[i] ~= nil then
                self.diceNode[i]:removeFromParent()
                self.diceNode[i] = nil
            end
        end
    end
    self.diceNode = { }
    for i = 1, 6 do
        local _diceNodePos = cc.p(self.diceNodePos[i].x + self:getContentSize().width / 2, self.diceNodePos[i].y + self:getContentSize().height / 2)
        local _dice = cc.Sprite:create("res/image/daily_task/destiny_dice/dice_" .. _nameTable[tonumber(_dicePoint[i]) or 6] .. ".png")
        _dice:setPosition(_diceNodePos)
        self.diceNode[i] = _dice
        self:addChild(_dice)
    end
end
function RiChangRenWuDestinyDiceLayer:playDiceAnimation(_oldNumber, _data)
    if _data == nil or next(_data) == nil then
        return
    end
    self.diceResultData = _data
    if _oldNumber == nil then
        _oldNumber = 0
    end
    local _nameTable = { "sky", "land", "money", "person", "feicui", "cloud" }
    local _iconOrder = {
        { 1, 2, 3, 4, 5 },
        { 5, 2, 4, 3, 1 },
        { 3, 2, 5, 1, 4 },
        { 4, 2, 3, 4, 5 },
        { 3, 1, 2, 5, 4 },
        { 1, 3, 5, 2, 4 },
    }
    for i = _oldNumber + 1, 6 do
        if self.diceNode[i] ~= nil then
            local _iconIdx = tonumber(self.diceResultData.destiny[i])
            local _diceIcon = self.diceNode[i]
            _diceIcon:stopAllActions()
            --
            local _posX, _posY = _diceIcon:getPosition()
                _diceIcon:removeFromParent()
                _diceIcon = cc.Sprite:create("res/image/daily_task/destiny_dice/dice_" .. _nameTable[_iconIdx] .. ".png")
                _diceIcon:setPosition(_posX, _posY)
                self:addChild(_diceIcon)
                self.diceNode[i]=_diceIcon
            local _diceAnimate = self:getDiceAnimation(_iconOrder[i])
            _diceIcon:runAction(_diceAnimate)
        end
    end
end

function RiChangRenWuDestinyDiceLayer:getDiceAnimation(_iconOrder)
    local _frameTable = { }
    local _pngRectWidth = 407 / 5
    local _animation = cc.Animation:create()
    for i = 1, 10 do
        local _iconId = _iconOrder[i % 5 + 1]
        _animation:addSpriteFrameWithFile("res/image/daily_task/destiny_dice/diceAni_" .. _iconId .. ".png")
    end
    _animation:setDelayPerUnit(0.1)
    _animation:setRestoreOriginalFrame(true)
    local _animate = cc.Animate:create(_animation)
    return _animate
end

function RiChangRenWuDestinyDiceLayer:turnToDiceResultLayer()
    if self.diceBtn ~= nil then
        self.diceBtn:setVisible(false)
    end
    if self.diceSpine == nil then
        self:createDiceAnimation()
    end
    local _diceSpine = self.diceSpine
    _diceSpine:setVisible(true)
    _diceSpine:setAnimation(0, "animation", false)
    local _spineNode = { }
    for i = 1, 6 do
        _spineNode[i] = _diceSpine:getNodeForSlot("dice" .. i)
    end
    self.diceNode = { }
    local _func = function()
        _diceSpine:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
        self:setDiceSp()
        for i = 1, 6 do
            local _wP = _spineNode[i]:convertToWorldSpace(cc.p(0.5, 0.5))
            local _nodePos = _diceSpine:convertToNodeSpace(_wP)
        end
        _diceSpine:setVisible(false)
        performWithDelay(self, function()
            self:showDiceResultLayer(self.diceResultData)
        end , 0.01)
    end
    _diceSpine:registerSpineEventHandler( function(event)
        -- 如果不需要重复播放，则在播放一次之后播放待机
        if event.animation == "animation" then
            _func()
        end
    end , sp.EventType.ANIMATION_COMPLETE)
end

function RiChangRenWuDestinyDiceLayer:httpToDice()
    YinDaoMarg:getInstance():guideTouchEnd()

    ClientHttp:requestAsyncInGameWithParams( {
        modules = "destiny?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                YinDaoMarg:getInstance():doNextGuide()

                self.data.destinyCount = data.destinyCount
                self.diceResultData = data
                self:refreshLastDiceCount()
                self:turnToDiceResultLayer()
            else
                YinDaoMarg:getInstance():tryReguide()
                -----如果网络不好，继续
                XTHDTOAST(data.msg)
            end
        end,
        -- 成功回调
        targetNeedsToRetain = button,
        failedCallback = function()
            YinDaoMarg:getInstance():tryReguide()
            -----如果网络不好，继续
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            -----"网络请求失败")
        end,
        -- 失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,-- 加载图显示 circle 光圈加载 head 头像加载
    } )
end

function RiChangRenWuDestinyDiceLayer:showDiceBtn()

end

-----------------------------骰子结果began------------------------------------
function RiChangRenWuDestinyDiceLayer:showDiceResultLayer(data)
    YinDaoMarg:getInstance():getACover(self)
    local _resultBg = cc.Sprite:create("res/image/daily_task/destiny_dice/diceResult_bg.png")
    _resultBg:setName("resultBg")
    local _diceresultSp = requires("src/fsgl/layer/RiChangRenWu/RiChangRenWuDiceResultPopLayer.lua"):create(data, self)
    _diceresultSp:setPosition(cc.p(_resultBg:getContentSize().width / 2, _resultBg:getContentSize().height / 2))
    _resultBg:addChild(_diceresultSp)
    _resultBg:setPosition(cc.p(self:getContentSize().width / 2, 0 - _resultBg:getContentSize().height / 2))
    self:addChild(_resultBg)
    ---------------------------------------------------------------------------------------------------------
    self._getBtn = _diceresultSp.sureBtn
    ----领取按钮
    self._continuBtn = _diceresultSp.continueBtn
    ----逆天
    ---------------------------------------------------------------------------------------------------------
    _resultBg:runAction(cc.Sequence:create(cc.MoveTo:create(0.1, cc.p(self:getContentSize().width * 0.5, _resultBg:getContentSize().height / 2))
    , cc.ScaleTo:create(0.1, 1, 1.1), cc.ScaleTo:create(0.1, 1, 1.0)
    , cc.CallFunc:create( function()
        -----添加引导
        YinDaoMarg:getInstance():removeCover(self)
        YinDaoMarg:getInstance():addGuide( { index = 7, parent = self }, 16)
        YinDaoMarg:getInstance():addGuide( {
            ------点击我要逆天
            parent = self,
            target = self._continuBtn,
            index = 8,
            needNext = false,
            updateServer = true,
        } , 16)
        YinDaoMarg:getInstance():addGuide( {
            ------点击我要逆天
            parent = self,
            target = self._getBtn,
            index = 9,
        } , 16)
        local server = gameUser.getGuideID()
        local group = YinDaoMarg:getInstance():getGuideSteps()
        if server and server.group == 16 and server.index == 7 and group == 16 then
            ------表示已经扔过骰子了
            YinDaoMarg:getInstance():skipGuideOnGI(16, 8)
            --- 跳到我要逆天
        elseif server and server.group == 16 and server.index == 9 and group == 16 then
            -----表示已经逆天过了
            YinDaoMarg:getInstance():skipGuideOnGI(16, 9)
            --- 跳到我要逆天
        end
        YinDaoMarg:getInstance():doNextGuide()
    end )))
end

function RiChangRenWuDestinyDiceLayer:closeDiceResultLayer()
    if self.diceNode ~= nil and next(self.diceNode) ~= nil then
        for i = 1, #self.diceNode do
            if self.diceNode[i] ~= nil then
                self.diceNode[i]:removeFromParent()
                self.diceNode[i] = nil
            end
        end
    end
    self.diceResultData = { }
    if self.diceBtn ~= nil then
        self.diceBtn:setVisible(true)
    end
    if self:getChildByName("resultBg") == nil then
        return
    end
    local _resultBg = self:getChildByName("resultBg")
    _resultBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1, 1.1), cc.ScaleTo:create(0.1, 1, 1.0)
    , cc.MoveTo:create(0.1, cc.p(self:getContentSize().width * 0.5, 0 - _resultBg:getContentSize().height / 2))
    , cc.CallFunc:create( function()
        _resultBg:removeFromParent()
    end )))
end
-----------------------------骰子结果end------------------------------------

function RiChangRenWuDestinyDiceLayer:refreshProficietyData(data)
    if data.proficiency ~= nil and data.proficiencyRank ~= nil then
        self.data.proficiency = data.proficiency or 0
        self.data.proficiencyRank = data.proficiencyRank or 0
        self:refreshDiceLevelLabel()
        self:refreshProgressPercentage()
    end
    if data.rewardState ~= nil then
        self.data.rewardState = data.rewardState or 0
        self:refreshProficientyrewardState()
    end
end

function RiChangRenWuDestinyDiceLayer:refreshProficientyrewardState()
    if self.proficientyBtn == nil then
        return
    end
    -- 如果熟练度等级已经被领完就不显示熟练度奖励
    if tonumber(self.maxProficientyLevel) <= tonumber(self.data.proficiencyRank) and tonumber(self.data.rewardState) ~= 1 then
        print("8431>>> 已经到最大级")
        self.proficientyBtn:setVisible(false)
        return
    end
    local _spine = self.proficientyBtn:getChildByName("proficientySpine")
    if _spine == nil then
        _spine = sp.SkeletonAnimation:create("res/image/homecity/frames/spine/renwu.json", "res/image/homecity/frames/spine/renwu.atlas", 1.0)
        self.proficientyBtn:addChild(_spine)
        _spine:setName("proficientySpine")
        _spine:setPosition(self.proficientyBtn:getBoundingBox().width / 2 - 5, self.proficientyBtn:getContentSize().height * 1 / 3 + 5)
        _spine:setScale(0.6)
    end
    if tonumber(self.data.rewardState) == 1 then
        _spine:setAnimation(0, "renwu", true)
    else
        _spine:setAnimation(0, "idle", true)
    end
end

function RiChangRenWuDestinyDiceLayer:refreshDiceLevelLabel()
    if self.diceLevelLabel == nil then
        return
    end
    self.diceLevelLabel:setString(self.data.proficiencyRank .. LANGUAGE_NAMES.level)
end

function RiChangRenWuDestinyDiceLayer:refreshProgressPercentage()
    if self.diceProgress == nil then
        return
    end
    local _progressData = self.destinyData[tonumber(self.data.proficiencyRank)] or { }
    local _allExp = _progressData.need or 0
    local _curExp = self.data.proficiency or 1
    self.diceProgress:setPercentage(_curExp / _allExp * 100)
    self.explable:setString(_curExp.." / ".._allExp)
end

function RiChangRenWuDestinyDiceLayer:refreshLastDiceCount()
    if self.lastDiceLabel == nil then
        return
    end
    self.lastDiceLabel:setString(self.data.destinyCount or 0)
end

function RiChangRenWuDestinyDiceLayer:setStaticData()
    self.destinyData = { }
    self.destinyData = gameData.getDataFromCSV("DiceGame") or { }
    for i = #self.destinyData, 1, -1 do
        if not self.destinyData[i]["typeA"] or tonumber(self.destinyData[i]["typeA"]) == 1 then
            table.remove(self.destinyData, i)
        end
    end
end

function RiChangRenWuDestinyDiceLayer:getBtnNode(_path)
    local _node = ccui.Scale9Sprite:create(cc.rect(5, 4, 1, 1), _path)
    _node:setContentSize(cc.size(90, 80))
    return _node
end

function RiChangRenWuDestinyDiceLayer:setMaxProficientyLevel()
    if self.destinyData == nil or #self.destinyData < 1 then
        self.maxProficientyLevel = 0
    end
    local _level = self.destinyData[#self.destinyData].level or 0
    self.maxProficientyLevel = _level
end

function RiChangRenWuDestinyDiceLayer:create(data, mainCity)
    local _layer = self.new(data, mainCity)
    return _layer
end

function RiChangRenWuDestinyDiceLayer:onEnter()
    -----------引导
    YinDaoMarg:getInstance():addGuide( { index = 5, parent = self }, 16)
    YinDaoMarg:getInstance():addGuide( {
        ------点击扔骰子
        parent = self,
        target = self.diceBtn,
        index = 6,
        needNext = false,
        updateServer = true,
    } , 16)

    local server = gameUser.getGuideID()
    if not server or not(server.group == 16 and(server.index == 7 or server.index == 9)) then
        YinDaoMarg:getInstance():doNextGuide()
    end
end

function RiChangRenWuDestinyDiceLayer:onExit()
    if LayerManager.getBaseLayer() then
        LayerManager.getBaseLayer():addGuide()
        performWithDelay(LayerManager.getBaseLayer(), function()
            YinDaoMarg:getInstance():doNextGuide()
        end , 0.01)
    end
end

return RiChangRenWuDestinyDiceLayer