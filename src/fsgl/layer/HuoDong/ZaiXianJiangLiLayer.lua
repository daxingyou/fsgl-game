--  Created by xingchen
-- 在线奖励界面
local ZaiXianJiangLiLayer = class("ZaiXianJiangLiLayer", function(params)
    return XTHD.createFunctionLayer(cc.size(856,415))
end)

function ZaiXianJiangLiLayer:ctor(params)
    local _data = params.httpData or {}
    self.parentLayer = params.parentLayer or nil
    self._fontSize = 18
    self.cardItemArr = {}
    self.cardItemData = {}
    self.staticRewardData = {}
    self.totalRewardState = {}
    self.totalStaticData = {}
    self.turncardStaticData = {}
    self.iteminfoData = {}
    self.extraRewardData = {}

    self.isturnCard = false                 --新一轮的翻牌，是否已经翻过牌,
    self.isTurnning = false                 --是否正在翻牌
    self.isReverse = true                   --是否是反面
    self.totalturnCountLabel = 0            --翻牌次数
    self.maxCount = 0
    self.clickNumber = 0                    

    self._gettotalOnlineRewardBtn = nil
    self.totalPart_bg = nil                 --累计在线奖励背景
    -- self.lastonlineTimeLabel = nil          --剩余领奖时间
    self.lastSecondLabel = nil              --剩余秒数
    self.lastMinuteLabel = nil              --剩余分钟
    self.totalBg = nil                      --累计翻牌次数

    self:setOpacity(0)
    self:getItemInfoData()
    self:getStaticData()
    self:setCardItemData(_data)
    self:initWithData(_data)
end

function ZaiXianJiangLiLayer:onCleanup( )
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey("res/image/activities/onlinereward/onlinereward_front.png")
    textureCache:removeTextureForKey("res/image/activities/onlinereward/onlinereward_reverse.png")
end

function ZaiXianJiangLiLayer:initWithData(data)
    local _advertSp = cc.Sprite:create("res/image/activities/onlinereward/onlinereward_advertsp.png")
    _advertSp:setAnchorPoint(cc.p(0,0))
    _advertSp:setPosition(cc.p(0,3))
    _advertSp:setScaleX(0.65)
    _advertSp:setScaleY(0.7)
    self:addChild(_advertSp)

    -- local _rulePosX = 10
    -- local _ruleTitle = XTHDLabel:create(LANGUAGE_ACTIVITIES_RULE.rule .. ":",22)
    -- _ruleTitle:setAnchorPoint(cc.p(0,0.5))
    -- _ruleTitle:enableShadow(cc.c4b(255,255,255,255),cc.size(0.4,-0.4),0.4)
    -- _ruleTitle:setPosition(cc.p(_rulePosX,_advertSp:getContentSize().height - 30))
    -- _advertSp:addChild(_ruleTitle)

    -- local _contentColor = cc.c4b(247,240,46,255)
    -- local _ruleContent = XTHDLabel:create(LANGUAGE_ACTIVITIES_RULE.content,20)
    -- _ruleContent:setAnchorPoint(cc.p(0,1))
    -- _ruleContent:setWidth(_advertSp:getContentSize().width - 15)
    -- _ruleContent:setLineBreakWithoutSpace(true)
    -- _ruleContent:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    -- _ruleContent:setColor(_contentColor)
    -- _ruleContent:enableShadow(_contentColor,cc.size(0.4,-0.4),0.4)
    -- _ruleContent:setPosition(cc.p(_rulePosX,_ruleTitle:getBoundingBox().y - 5))
    -- _advertSp:addChild(_ruleContent)

    local _midPosX = _advertSp:getBoundingBox().x+_advertSp:getBoundingBox().width

    -- local _totalPart_bg = ccui.Scale9Sprite:create(cc.rect(10,10,10,10),"res/image/common/scale9_bg_5.png")
    -- self.totalPart_bg = _totalPart_bg
    -- _totalPart_bg:setContentSize(cc.size(self:getContentSize().width - 8,60))
    -- _totalPart_bg:setAnchorPoint(cc.p(0.5,1))
    -- _totalPart_bg:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height))
    -- self:addChild(_totalPart_bg)
    -- self:setOnlineTimeRewardLabel()

    local _cardBg = ccui.Scale9Sprite:create("res/image/activities/onlinereward/scale9_bg_25.png")
    self.cardBg = _cardBg
    _cardBg:setContentSize(cc.size(self:getContentSize().width-_midPosX - 2*2,310))
    _cardBg:setAnchorPoint(cc.p(1,0))
    _cardBg:setPosition(cc.p(self:getContentSize().width - 2,58))
    self:addChild(_cardBg)

    --牌
    for i=1,3 do
        local _cardItem = XTHDPushButton:createWithParams({
                        normalFile = "res/image/activities/onlinereward/onlinereward_reverse.png"
                        ,selectedFile = "res/image/activities/onlinereward/onlinereward_reverse.png"
                    })
        local cardPosX = _cardBg:getContentSize().width/2 - (2-i)*(_cardBg:getContentSize().width/3-2)
        local cardPosY = _cardBg:getContentSize().height/2
        _cardItem:setPosition(cc.p(cardPosX,cardPosY))
        _cardBg:addChild(_cardItem)
        self.cardItemArr[i] = _cardItem
        _cardItem.turnState = nil

        _cardItem:setTouchEndedCallback(function()
                if tonumber(self.clickNumber>0) then
                    return
                end
                if self.cardItemData.surplusTime >0 then
                    XTHDTOAST(LANGUAGE_TIPS_TIMETODRAW(XTHD.getTimeHMS(self.cardItemData.surplusTime)))
                    return
                elseif self.cardItemData.surplusTime == 0 then
                    --时间已到
                else
                end
                self.clickNumber = 1
                self:httpToTurnCard(i)
            end)
    end
    self.isTurnning = false           --是否刚翻过牌
    if self.cardItemData.surplusTime ==0 then
        self.isturnCard = false
    else 
        self.isturnCard = true
    end

    local _countPosY = 35
    --累计
    -- local _lastCountLabelSp = cc.Sprite:create("res/image/activities/onlinereward/onlinereward_lastTurnCount.png")
    local _lastCountLabelSp = XTHDLabel:create("剩余翻牌次数：",20)
    _lastCountLabelSp:setAnchorPoint(cc.p(1,0.5))
    _lastCountLabelSp:setColor(cc.c3b(254,202,2))-----------------------累积翻牌次数
    _lastCountLabelSp:setPosition(cc.p(160 + _midPosX,_countPosY))
    self:addChild(_lastCountLabelSp)
    local _lastCountLabel = XTHDLabel:create("0",20)
    self.lastCountLabel = _lastCountLabel
    -- getCommonWhiteBMFontLabel(20)
    _lastCountLabel:setColor(cc.c3b(254,202,2))-------------剩余翻牌次数
    _lastCountLabel:setAnchorPoint(cc.p(0,0.5))
    _lastCountLabel:setPosition(cc.p(_lastCountLabelSp:getBoundingBox().x + _lastCountLabelSp:getBoundingBox().width ,_countPosY))
    self:addChild(_lastCountLabel)
    self:setLastTurnCountLabel()

    local _effectSp = cc.Sprite:create("res/image/activities/onlinereward/onlinereward_lightBg.png")
    _effectSp:setName("effectSp")
    _effectSp:runAction(cc.RepeatForever:create(cc.RotateBy:create(15,360)))
    _effectSp:setVisible(false)

    local _rewardBoxSp = XTHD.createButton({
            normalFile = "res/image/activities/logindaily/logindaily_box_3.png"
        })
    -- cc.Sprite:create("res/image/activities/logindaily/logindaily_box_3.png")
    _rewardBoxSp:setScale(0.8)
    _rewardBoxSp:setAnchorPoint(cc.p(0.5,0.5))
    _effectSp:setPosition(cc.p(self:getContentSize().width - 10 - _rewardBoxSp:getContentSize().width/2,_countPosY))
    self:addChild(_effectSp)
    _rewardBoxSp:setPosition(_effectSp:getPositionX(),_effectSp:getPositionY())
    self:addChild(_rewardBoxSp)
    _rewardBoxSp:setTouchEndedCallback(function()
            self:rewardBoxCallback()
        end)

    self.rewardBoxSp = _rewardBoxSp

    local _totalrewardLabel = XTHDLabel:create("",20)
    self.totalrewardLabel = _totalrewardLabel
    _totalrewardLabel:setAnchorPoint(cc.p(1,0))
    _totalrewardLabel:setColor(cc.c3b(254,202,2))-----------------------累积翻牌次数
    _totalrewardLabel:setPosition(cc.p(_rewardBoxSp:getBoundingBox().x-26,_lastCountLabelSp:getBoundingBox().y))
    self:addChild(_totalrewardLabel)

    -- local _totalrewardLabelnum = XTHDLabel:create(0,20)
    -- self.totalrewardLabelnum = _totalrewardLabelnum
    -- _totalrewardLabelnum:setAnchorPoint(cc.p(1,0))
    -- _totalrewardLabelnum:setColor(cc.c3b(255,255,255))-----------------------累积翻牌次数
    -- _totalrewardLabelnum:setPosition(cc.p(_rewardBoxSp:getBoundingBox().x+5,_lastCountLabelSp:getBoundingBox().y))
    -- self:addChild(_totalrewardLabelnum)
    self:reFreshTotalRewardState()
    self:setTurnCardPrompt()
end

function ZaiXianJiangLiLayer:setCardStateFront(_data,_idx)
    if _idx==nil or _idx>3 or _idx<1 then 
        return
    end
    if _data==nil or next(_data) == nil then
        return
    end
    if self.cardItemArr[_idx]==nil then
        return
    end
    local _cardItem = self.cardItemArr[_idx]
    _cardItem:setStateNormal(cc.Sprite:create("res/image/activities/onlinereward/onlinereward_front.png"))
    _cardItem:setStateSelected(cc.Sprite:create("res/image/activities/onlinereward/onlinereward_front.png"))
    _cardItem:setClickable(false)
    local _rewardBg = cc.Sprite:createWithTexture(nil,cc.rect(0,0,_cardItem:getContentSize().width,_cardItem:getContentSize().height))
    _rewardBg:setOpacity(0)
    -- cc.Sprite:create("res/image/plugin/competitive_layer/light_bg.png")
    _rewardBg:setName("rewardBg")
    _rewardBg:setAnchorPoint(cc.p(0.5,0.5))
    _rewardBg:setPosition(cc.p(_cardItem:getContentSize().width/2,_cardItem:getContentSize().height/2))
    _cardItem:addChild(_rewardBg)
    local _rewardItem = ItemNode:createWithParams({
                dbId = nil,
                itemId = _data.rewardId or 0,
                _type_ = _data.rewardType or 1,
                touchShowTip = true,
                count = _data.rewardSum or 0
            })
    -- _rewardItem:setScale(66/_rewardItem:getContentSize().width)
    _rewardItem:setPosition(cc.p(_rewardBg:getContentSize().width/2,_rewardBg:getContentSize().height - 99))
    _rewardBg:addChild(_rewardItem)

    local _nameStr = self:getRewardName({
            _type = _data.rewardType or 1
            ,_itemid =_data.rewardId or 0
            ,_count = _data.rewardSum or 0
        })
    local _nameLabel = XTHDLabel:create(_nameStr,self._fontSize)
    _nameLabel:setColor(self:getTextColor("newcolor"))            ------------------翻牌获得道具名称
    _nameLabel:setPosition(cc.p(_rewardItem:getBoundingBox().x + _rewardItem:getBoundingBox().width/2,_rewardItem:getBoundingBox().y - 20))
    _rewardBg:addChild(_nameLabel)

    local _getBtnNode = function(_path)
        local _node = ccui.Scale9Sprite:create(cc.rect(51,0,1,46),_path)
        _node:setContentSize(cc.size(145,46))
        return _node
    end
    local _receiveBtn = nil
    if _data.state and tonumber(_data.state)==0 then
        _receiveBtn = XTHD.createCommonButton({
                        btnColor = "write_1",
                        isScrollView = false,
                        btnSize = cc.size(145,46)
                    })
        _receiveBtn:setTouchEndedCallback(function()
                self:httpToTurnCard(_idx)
            end)

        local _ingotSp = cc.Sprite:create("res/image/common/header_ingot.png")
        _ingotSp:setAnchorPoint(cc.p(0,0.5))
        _ingotSp:setName("ingotSp")
        _ingotSp:setPosition(cc.p(50,_receiveBtn:getContentSize().height/2))
        _receiveBtn:addChild(_ingotSp)

        local _ingotLabel = getCommonWhiteBMFontLabel(1)
        _ingotLabel:setAnchorPoint(cc.p(0,0.5))
        _ingotLabel:setName("ingotLabel")
        _ingotLabel:setPosition(cc.p(_ingotSp:getBoundingBox().x+_ingotSp:getBoundingBox().width,_receiveBtn:getContentSize().height/2-7))
        _receiveBtn:addChild(_ingotLabel)

		local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		_receiveBtn:addChild(fetchSpine)
		fetchSpine:setScaleY(0.8)
		fetchSpine:setPosition(_receiveBtn:getBoundingBox().width*0.5, _receiveBtn:getContentSize().height*0.5+2)
		fetchSpine:setAnimation(0, "querenjinjie", true )	
        -- local _textSp =  XTHDLabel:create(LANGUAGE_KEY_GET,26,"res/fonts/def.ttf")
        -- _textSp:setColor(XTHD.resource.btntextcolor.write)
        -- _textSp:enableShadow(XTHD.resource.btntextcolor.write,cc.size(0.4,-0.4),0.4)
        -- _textSp:setAnchorPoint(cc.p(1,0.5))
        -- _textSp:enableOutline(cc.c4b(150,79,39,255),2)
        -- _textSp:setPosition(cc.p(_receiveBtn:getContentSize().width - 25,_receiveBtn:getContentSize().height/2-3))
        -- _receiveBtn:addChild(_textSp)
        
    else
        _receiveBtn = cc.Sprite:create("res/image/vip/yilingqu.png") 
        _receiveBtn:setScale(0.9)
    end
    _receiveBtn:setName("receiveBtn")
    _receiveBtn:setPosition(cc.p(_cardItem:getContentSize().width/2,47))
	_receiveBtn:setScale(0.8)
    _cardItem:addChild(_receiveBtn)

    

    self:setTurnCardCostLabel(_cardItem)

end
function ZaiXianJiangLiLayer:setCardStateReverse(_idx)
    if _idx==nil or _idx>3 or _idx<1 or self.cardItemArr[_idx]==nil then
        return
    end
    local _cardItem = self.cardItemArr[_idx]
    if _cardItem:getChildByName("rewardBg") then
        _cardItem:getChildByName("rewardBg"):removeAllChildren()
        _cardItem:getChildByName("rewardBg"):removeFromParent()
    end
    if _cardItem:getChildByName("receiveBtn") then
        _cardItem:getChildByName("receiveBtn"):removeFromParent()
    end
    _cardItem:setStateNormal(cc.Sprite:create("res/image/activities/onlinereward/onlinereward_reverse.png"))
    _cardItem:setStateSelected(cc.Sprite:create("res/image/activities/onlinereward/onlinereward_reverse.png"))
    _cardItem:setClickable(true)
end
function ZaiXianJiangLiLayer:setCardStateReverseAni()
    self.clickNumber = 0
    if self.isReverse == true then
        return
    end
    self.isReverse = true
    self:runAction(cc.Sequence:create(cc.CallFunc:create(function()
            for i=1,3 do
                local _cardItem = self.cardItemArr[i]
                if _cardItem~=nil then
                    _cardItem:setClickable(false)
                    _cardItem:runAction(cc.ScaleTo:create(0.15,0.001,1))
                end
            end
        end),cc.DelayTime:create(0.15),cc.CallFunc:create(function()
            for i=1,3 do
                self:setCardStateReverse(i)
            end
        end),cc.DelayTime:create(0.15),cc.CallFunc:create(function()
            for i=1,3 do
                local _cardItem = self.cardItemArr[i]
                if _cardItem~=nil then
                    _cardItem:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1,1),cc.CallFunc:create(function()
                            _cardItem:setClickable(true)
                        end)))
                end
            end
        end)))
end
function ZaiXianJiangLiLayer:setCardRewarded(_idx,_data)
    if _idx==nil or _idx>3 or _idx<1 or _data==nil or next(_data) == nil or self.cardItemArr[_idx]==nil then
        return
    end
    local _cardItem = self.cardItemArr[tonumber(_idx)]
    local _receivepos = cc.p(_cardItem:getContentSize().width/2,40) 
    if _cardItem:getChildByName("receiveBtn") then
        local _receiveBtn = _cardItem:getChildByName("receiveBtn")
        _receivepos.x,_receivepos.y = _receiveBtn:getPosition()
        _cardItem:getChildByName("receiveBtn"):removeAllChildren()
        _cardItem:getChildByName("receiveBtn"):removeFromParent()
        local _receiveSpr = cc.Sprite:create("res/image/vip/yilingqu.png")
        _receiveSpr:setScale(0.9)
        _receiveSpr:setName("receiveBtn")
        _receiveSpr:setPosition(_receivepos)
        _cardItem:addChild(_receiveSpr)
    end
    
    for i=1,#_data do
        if _data[i].state and tonumber(_data[i].state)==0 and _data[i].index then
            if self.cardItemArr[tonumber(_data[i].index)] then
                self:setTurnCardCostLabel(self.cardItemArr[tonumber(_data[i].index)])
            end
        end
    end
end

function ZaiXianJiangLiLayer:setTurnCardCostLabel(_target)
    if _target:getChildByName("receiveBtn")==nil then
        return
    end
    local _receiBtn = _target:getChildByName("receiveBtn")
    if _receiBtn:getChildByName("ingotLabel") then
        local _ingotLabel = _receiBtn:getChildByName("ingotLabel")
        _ingotLabel:setString(tonumber(self.cardItemData.ingotChouPai or 0) + 1)
    end
end

function ZaiXianJiangLiLayer:httpToTurnCard(_idx)
    _idx = _idx or 1
    if _idx<1 or _idx>3 then
        return
    end
    ClientHttp:requestAsyncInGameWithParams({
        modules = "timeReward?",
        params = {index=_idx},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                --翻牌次数进度条
                self.cardItemData.totalChouPai = data.totalChouPai or 0
                self.cardItemData.ingotChouPai = data.ingotChouPai or 0
                self.cardItemData.surplusTime = data.surplusTime or 0
                self:reFreshHttpData(data)
                -- self:setTotalTurnCountLabel()
            
                self:setLastTurnCountLabel()
                
                local _rewardListData = {}
                _rewardListData[1] = {}
                for k,v in pairs(data.rewardList) do
                    local _cardindex = v.index or 1
                    if _cardindex==_idx then
                        _rewardListData[1] = v
                    else
                        _rewardListData[#_rewardListData + 1] = v
                    end
                end
                local _rewardTable = {}
                
                if data.curReward~=nil then
                    local _rewardData = string.split(data.curReward,",")
                    _rewardTable[1] = {}
                    _rewardTable[1].rewardtype = tonumber(_rewardData[1] or 4)
                    _rewardTable[1].id = tonumber(_rewardData[2] or 1)
                    _rewardTable[1].num = tonumber(_rewardData[3] or 0 )
                end
                
                --判断是否是翻得免费牌
                if self.isturnCard == false then
                    self.isReverse = false
                    self.isTurnning = true
                    local _otherFunc = function(_num)
                        local _index = _rewardListData[_num] and _rewardListData[_num].index
                        if self.cardItemArr[tonumber(_index)]~=nil then

                            self.cardItemArr[tonumber(_index)]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,0.01,1)
                            ,cc.CallFunc:create(function()
                                self:setCardStateFront(_rewardListData[_num],_index)
                            end),cc.ScaleTo:create(0.15,1,1)))
                        end
                    end
                    for i=1,3 do
                        if self.cardItemArr[tonumber(i)] then
                            self.cardItemArr[tonumber(i)]:setClickable(false)
                        end
                    end
                    self:runAction(cc.Sequence:create(cc.CallFunc:create(function()
                        self.cardItemArr[_idx]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,0.01,1)
                            ,cc.CallFunc:create(function()
                                self:setCardStateFront(_rewardListData[1],_idx)
                                
                            end),cc.ScaleTo:create(0.15,1,1)))
                    end),cc.DelayTime:create(0.2),cc.Spawn:create(cc.CallFunc:create(function()
                            _otherFunc(2)
                        end),cc.CallFunc:create(function()
                            _otherFunc(3)
                        end)),cc.DelayTime:create(0.25),cc.CallFunc:create(function()
                            --弹出奖励框
                            ShowRewardNode:create(_rewardTable)
                        end)))
                    -- self:setTurnTime()
                    self:setTurnCardPrompt()
                else
                    self.isTurnning = false
                    self:setCardRewarded(_idx,_rewardListData)
                    if tonumber(data.surplusTime)>0 then
                        self:setTurnCardPrompt()
                    end
                    --弹出奖励框
                    ShowRewardNode:create(_rewardTable)
                end
                self.isturnCard = true
                self:reFreshTotalRewardState(i)
                -- for i=1,#self.staticRewardData do
                    
                -- end
            else
                XTHDTOAST(data.msg)
            end
            self.clickNumber = 0
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
            self.clickNumber = 0
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ZaiXianJiangLiLayer:httpToGetTotalReward(_idx,_callback)
    local _rewardCount = tonumber(self.staticRewardData[tonumber(_idx)].needTimes  or 0) 
    ClientHttp:requestAsyncInGameWithParams({
        modules = "chouPaiReward?",
        params = {count=_rewardCount},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                self:reFreshHttpData(data)
                if _callback~=nil then
                    _callback()
                end
                local _rewardTable = {}
                _rewardTable[1] = {}
                _rewardTable[1].rewardtype = tonumber(self.staticRewardData[tonumber(_idx)].reward1 or 1)
                _rewardTable[1].num = tonumber(self.staticRewardData[tonumber(_idx)].reward1num or 0)
                _rewardTable[1].dbId = _rewarddbid
                _rewardTable[1].id = tonumber(self.staticRewardData[tonumber(_idx)].reward1id or 1)
                ShowRewardNode:create(_rewardTable)

                self.totalStaticData[tostring(data.number)] = 1
                -- ShowRewardNode:create(_rewardTable)
                self:reFreshTotalRewardState()
            else
                XTHDTOAST(data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function ZaiXianJiangLiLayer:setLastTurnCount()
    self.lastTurnCount = #self.turncardStaticData - tonumber(self.cardItemData.totalChouPai or 0)+tonumber(self.cardItemData.ingotChouPai or 0)
    if tonumber(self.cardItemData.surplusTime)<0 or tonumber(self.lastTurnCount)<0 then
        self.lastTurnCount = 0
    end
end

function ZaiXianJiangLiLayer:setLastTurnCountLabel()
    self:setLastTurnCount()
    self.lastCountLabel:setString(self.lastTurnCount)
end

function ZaiXianJiangLiLayer:setTurnTime()
    local _turnTime = 30
    self.lastSecondLabel:setString(_turnTime)
    schedule(self,function()
            _turnTime = _turnTime - 1
            if _turnTime<=0 then
                local _currentCount = tonumber(self.cardItemData.totalChouPai or 0)-tonumber(self.cardItemData.ingotChouPai or 0)+1
                local _currentData = self.turncardStaticData[tonumber(_currentCount)] or {}
                self.cardItemData.surplusTime = (_currentData.needTime or 10)*60
                self:setTurnCardPrompt()
            else
                self.lastSecondLabel:setString(_turnTime)
            end
        end,1,111)
end

function ZaiXianJiangLiLayer:setWaitTime()
    self:setCardStateReverseAni()
    local _waitTime = tonumber(self.cardItemData.surplusTime)
    self.lastMinuteLabel:setString(XTHD.getTimeHMS(_waitTime))
    schedule(self,function()
        _waitTime = _waitTime - 1
        self.cardItemData.surplusTime = _waitTime
        if _waitTime<=0 then
            self:setTurnCardPrompt()
        else
            self.lastMinuteLabel:setString(XTHD.getTimeHMS(_waitTime))
        end
    end,1,111)
end

function ZaiXianJiangLiLayer:createRewardPop(_rewardData)
    if _rewardData==nil or next(_rewardData)==nil then
        return
    end
    local _rewardDialog = XTHDConfirmDialog:createWithParams({
            leftVisible = false
        })

    local _confirmDialogBg = nil
    if _rewardDialog:getContainer() then
        _confirmDialogBg = _rewardDialog:getContainer()
    else
        _rewardDialog:removeFromParent()
        return
    end
    if _rewardDialog:getRightButton() then
        _rewardDialog:getRightButton():setVisible(false)
    end
    local _rewardItem = ItemNode:createWithParams({
                dbId = nil,
                itemId =  _rewardData.reward1id,
                _type_ = _rewardData.reward1 or 1,
                touchShowTip = true,
                count = _rewardData.reward1num or 0
            })
    _rewardItem:setPosition(cc.p(_confirmDialogBg:getContentSize().width/2,_confirmDialogBg:getContentSize().height/2+20))
    _confirmDialogBg:addChild(_rewardItem)
    local _descLabel = XTHDLabel:create(LANGUAGE_TIPS_onlineTotalTurnRewardDescTextXc(_rewardData.needTimes or 0),self._fontSize)
    _descLabel:setColor(self:getTextColor("shenhese"))
    _descLabel:setPosition(cc.p(_confirmDialogBg:getContentSize().width/2,50))
    _confirmDialogBg:addChild(_descLabel)
    if self.parentLayer then
        self.parentLayer:addChild(_rewardDialog)
    end

    local _dayNumber = _rewardData.needTimes or 0
    if self.totalStaticData[tostring(_dayNumber)] and tonumber(self.totalStaticData[tostring(_dayNumber)])==1 then
        local _getRewardSp = cc.Sprite:create("res/image/camp/camp_reward_getted.png")
        _getRewardSp:setPosition(cc.p(_rewardItem:getContentSize().width/2,_rewardItem:getContentSize().height/2))
        _rewardItem:addChild(_getRewardSp)
    end
end

function ZaiXianJiangLiLayer:reFreshHttpData(data)
    if data == nil or next(data)==nil then
        return
    end
    for i=1,#data["property"] do
        local pro_data = string.split( data["property"][i],',')
        gameUser.updateDataById(pro_data[1],pro_data[2])
    end

    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
    local _rewarddbid = nil
    for i=1,#data["items"] do
        local _dbid = data.items[i].dbId
        _rewarddbid = _dbid
        if data.items[i].count and tonumber(data.items[i].count)>0 then
            DBTableItem.updateCount(gameUser.getUserId(),data.items[i],_dbid)
        else
            DBTableItem.deleteData(gameUser.getUserId(),_dbid)
        end
    end
    
end

function ZaiXianJiangLiLayer:rewardBoxCallback()
    local _rewardData = {}
    local _allChoupai = tonumber(self.cardItemData.totalChouPai or 0)   
    for i=1,#self.staticRewardData do
        local _index = tonumber(#_rewardData + 1)
        _rewardData[_index] = clone(self.staticRewardData[tonumber(i)] or {})
        local _dayNumber = self.staticRewardData[tonumber(i)].needTimes or 0
        if tonumber(_allChoupai)>=tonumber(_dayNumber) then
            if not self.totalStaticData[tostring(_dayNumber)] or tonumber(self.totalStaticData[tostring(_dayNumber)])~=1 then
                _rewardData[_index].rewardState = "canReward"
            else
                _rewardData[_index].rewardState = "Rewarded"
            end
        else
            _rewardData[_index].rewardState = "cannotReward"
        end
    end
    local _popLayer = requires("src/fsgl/layer/HuoDong/LoginDailyRewardPopLayer.lua"):create(_rewardData,self,"onlinereward")
    self.parentLayer:addChild(_popLayer)

end
--翻牌提示
function ZaiXianJiangLiLayer:setTurnCardPrompt()
    if self:getChildByName("turnPrompt") then
        self:removeChildByName("turnPrompt")
    end
    if self.lastSecondLabel~=nil then
        self.lastSecondLabel:removeFromParent()
        self.lastSecondLabel = nil
    end
    if self.lastMinuteLabel~=nil then
        self.lastMinuteLabel:removeFromParent()
        self.lastMinuteLabel = nil
    end
    self.isturnCard = true
    self:stopActionByTag(111)
    if self.lastTurnCount<1 then
        self.cardItemData.surplusTime = -1
    end
    local _promptPosY = self:getContentSize().height - 30
    -- self.totalPart_bg:getBoundingBox().y-22
    local _midPosX = self.cardBg:getBoundingBox().x+self.cardBg:getBoundingBox().width/2
    local _turnCardPromptSp = nil
    local _callBack = function()
    end
    --可翻牌或正在翻牌
    if self.cardItemData.surplusTime and tonumber(self.cardItemData.surplusTime)<1 then
        if self.isTurnning~=nil and self.isTurnning==true then
            local _turnCardPromptSp = XTHDLabel:create(LANGUAGE_KEY_ACTIVITIES.endTurnCardSecondTextXc,22)
            _turnCardPromptSp:setColor(cc.c3b(246, 252, 210))
            -- cc.Sprite:create("res/image/activities/onlinereward/onlinereward_nextturntimesp.png")
            _turnCardPromptSp:setName("turnPrompt")
            -- _turnCardPromptSp:setPosition(cc.p(_midPosX,_promptPosY))
            _turnCardPromptSp:setPosition(cc.p(_midPosX + 20/2,_promptPosY))
            self:addChild(_turnCardPromptSp)
            local _lastTurnCountLabel = XTHDLabel:create(self.lastSecondLabel,22)
            _lastTurnCountLabel:setColor(cc.c3b(246, 252, 210))
            -- getCommonWhiteBMFontLabel(self.lastSecondLabel)
            self.lastSecondLabel = _lastTurnCountLabel
            _lastTurnCountLabel:setAnchorPoint(cc.p(1,0.5))
            _lastTurnCountLabel:setPosition(cc.p(_turnCardPromptSp:getBoundingBox().x,_promptPosY))
            self:addChild(_lastTurnCountLabel)
            self:setTurnTime()
        elseif self.isTurnning~=nil and self.isTurnning == false and tonumber(self.cardItemData.surplusTime)==0 then
            self.isturnCard = false
            local _turnCardPromptSp = XTHDLabel:create(LANGUAGE_KEY_ACTIVITIES.turnCardGetRewardTextXc,30)
            _turnCardPromptSp:setColor(cc.c3b(246, 252, 210))
            -- cc.Sprite:create("res/image/activities/onlinereward/onlinereward_canturncardsp.png")
            _turnCardPromptSp:setName("turnPrompt")
            _turnCardPromptSp:setPosition(cc.p(_midPosX,_promptPosY))
            self:addChild(_turnCardPromptSp)
--            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ONLINEREWARD})
        else
            self.isTurnning = false
            _turnCardPromptSp = XTHDLabel:create(LANGUAGE_KEY_ACTIVITIES.turnCardTimesOverTextXc,30)
            _turnCardPromptSp:setColor(cc.c3b(246, 252, 210))
            -- cc.Sprite:create("res/image/activities/onlinereward/onlinereward_noturncountsp.png")
            _turnCardPromptSp:setName("turnPrompt")
            _turnCardPromptSp:setPosition(cc.p(_midPosX,_promptPosY))
            self:addChild(_turnCardPromptSp)
--            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ONLINEREWARD})
        end
    --已翻牌
    elseif self.cardItemData.surplusTime and tonumber(self.cardItemData.surplusTime)>0 then
        self.isTurnning = false
        local _turnCardPromptSp = XTHDLabel:create(LANGUAGE_KEY_ACTIVITIES.nextTurnTimeTextXc .. (self.lastTurnCount or 0) .. "/5",22)
        _turnCardPromptSp:setColor(cc.c3b(246, 252, 210))
        -- cc.Sprite:create("res/image/activities/onlinereward/onlinereward_lastturncountsp.png")
        _turnCardPromptSp:setName("turnPrompt")
        _turnCardPromptSp:setPosition(cc.p(_midPosX + 50/2,_promptPosY))
        self:addChild(_turnCardPromptSp)
        local _lastTimeLabel = XTHDLabel:create(0,22)
        -- getCommonWhiteBMFontLabel(0)
        self.lastMinuteLabel = _lastTimeLabel
        _lastTimeLabel:setColor(cc.c3b(246, 252, 210))
        _lastTimeLabel:setAnchorPoint(cc.p(1,0.5))
        _lastTimeLabel:setPosition(cc.p(_turnCardPromptSp:getBoundingBox().x,_promptPosY))
        self:addChild(_lastTimeLabel)
        self:setWaitTime()
--        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ONLINEREWARD})
    --不可翻牌
    else
        --todo
        self.isTurnning = false
        local _turnCardPromptSp = XTHDLabel:create(LANGUAGE_KEY_ACTIVITIES.turnCardTimesOverTextXc,22)
        _turnCardPromptSp:setColor(cc.c3b(246, 252, 210))
        -- cc.Sprite:create("res/image/activities/onlinereward/onlinereward_noturncountsp.png")
        _turnCardPromptSp:setName("turnPrompt")
        _turnCardPromptSp:setPosition(cc.p(_midPosX,_promptPosY))
        self:addChild(_turnCardPromptSp)
--        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ONLINEREWARD})
    end

end
function ZaiXianJiangLiLayer:reFreshTotalRewardState()
    local _effectSp = nil
    local _rewardBox = nil
    if self.rewardBoxSp~=nil and self:getChildByName("effectSp") then
        _effectSp = self:getChildByName("effectSp")
        _rewardBox = self.rewardBoxSp
    else
        return
    end
    local _rewardState = false
    local _rewardCount = self.staticRewardData[#self.staticRewardData].needTimes or 0
    local _allChoupai = tonumber(self.cardItemData.totalChouPai or 0)   
    for i=1,#self.staticRewardData do
        local _dayNumber = self.staticRewardData[tonumber(i)].needTimes or 0
        if tonumber(_allChoupai)>=tonumber(_dayNumber) then
            if not self.totalStaticData[tostring(_dayNumber)] or tonumber(self.totalStaticData[tostring(_dayNumber)])~=1 then
                _rewardState = true
                _rewardCount = _dayNumber
                break
            end
        else
            _rewardCount = _dayNumber
            break
        end
    end
    if _rewardState == true then
        _effectSp:setVisible(true)
        _rewardBox:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.5,1),cc.ScaleTo:create(0.8,0.8))))
    else
        _effectSp:setVisible(false)
        _rewardBox:stopAllActions()
        _rewardBox:setScale(0.8)
    end
    if self.totalrewardLabel~=nil then
        self.totalrewardLabel:setString(LANGUAGE_KEY_ACTIVITIES.totalTurnCardRewardTextXc .. ":".._allChoupai .. "/" .. _rewardCount)
        --self.totalrewardLabelnum:setString( _allChoupai .. "/" .. _rewardCount)
    end
end

function ZaiXianJiangLiLayer:setCardItemData(_data)
    self.cardItemData = _data or {}
    for k,v in pairs(self.cardItemData.list) do
        self.totalStaticData[tostring(v)] = 1
    end
    gameUser.setOnlineTime(self.cardItemData.times or 0)
end
function ZaiXianJiangLiLayer:getRewardName(_data)
    local _nameStr = nil
    local _itemType = _data._type or 1
    if tonumber(_itemType) == 4 then
        local _itemid = _data._itemid or 0
        _nameStr = self.iteminfoData[tostring(_itemid)] and self.iteminfoData[tostring(_itemid)].name or ""
    else
        _nameStr = (XTHD.resource.name[tonumber(_itemType)] or "")
    end
    return _nameStr
end

function ZaiXianJiangLiLayer:getStaticData()
    self.staticRewardData = {}
    local _table = gameData.getDataFromCSV("OnlineRewards") or {}
    local _itemInfoData = self.iteminfoData
    self.turncardStaticData = _table
    self.extraRewardData = _table[#_table] or {}
    for i=(#_table-3),(#_table-1) do
        _table[i].name = self:getRewardName({
                _type = _table[i].reward1 or 1
                ,_itemid = _table[i].reward1id or 0
                ,_count = _table[i].reward1num or 0
            })
        self.staticRewardData[#self.staticRewardData+1] = _table[i]
    end
    local _index = #_table - 1
    _index = tonumber(_index > 0 and _index or #_table)
    self.maxCount = tonumber(_table[_index].needTimes or 0)
    for i=1,4 do
        table.remove(self.turncardStaticData,#self.turncardStaticData)
    end
    -- self.maxCount = tonumber(#self.turncardStaticData or 0)*3
end
function ZaiXianJiangLiLayer:getItemInfoData()
    self.iteminfoData = {}
    self.iteminfoData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet") or {}
end

function ZaiXianJiangLiLayer:getTextColor(_str)
    local _color = {
        shenhese = cc.c4b(73,66,98,255),
        juhuangse = cc.c4b(192,81,27,255),
        newcolor=cc.c4b(254,202,2)
    }
    return _color[tostring(_str)]
end

function ZaiXianJiangLiLayer:create(params)
    return self.new(params)
end

return ZaiXianJiangLiLayer