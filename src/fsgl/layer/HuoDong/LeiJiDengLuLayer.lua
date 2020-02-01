--  Created by xingchen
-- 累计登录奖励界面
local LeiJiDengLuLayer = class("LeiJiDengLuLayer", function(params)
    return XTHD.createFunctionLayer(cc.size(856,415))
end)

function LeiJiDengLuLayer:ctor(params)
    local _data = params.httpData or {}
    self.parentLayer = params.parentLayer or nil
    self._fontSize = 18
    self.totalDayLabel = nil
    -- self.dayProgress = nil
    -- self.dayProgressBg = nil
    -- self.totalBg = nil

    self.logindailyData = {}
    self.getrewardDay = 0
    self.dailyItems = {}
    self.continueNum = 7
    self.totalNum = 3
    self.staticDailyData = {}
    self.totalStaticData = {}           --已经领取奖励的天数为1
    self.totalRewardState = {}          --true表示可以领取
    self.maxDay = 0

    self:setOpacity(0)
    self:getStaticData()
    self:initWithData(_data)
end
function LeiJiDengLuLayer:initWithData(data)
    self:setData(data)

    local _advertSp = cc.Sprite:create("res/image/activities/logindaily/logindaily_advertsp.png")
    _advertSp:setAnchorPoint(cc.p(0,0))
    _advertSp:setPosition(cc.p(0,0))
    self:addChild(_advertSp)
    _advertSp:setScaleX(0.68)
    _advertSp:setScaleY(0.71)
    local _midPosX = _advertSp:getBoundingBox().x+_advertSp:getBoundingBox().width

    local _continueHeight = 365
    --累计背景
    local _continueDayBg = ccui.Scale9Sprite:create(cc.rect(12,12,1,1),"res/image/common/scale9_bg_25.png")
    self.continueDayBg = _continueDayBg
    _continueDayBg:setContentSize(cc.size(self:getContentSize().width -_midPosX-3 ,_continueHeight-2))
    _continueDayBg:setAnchorPoint(cc.p(0,0))
    _continueDayBg:setPosition(cc.p(_midPosX,0+2))
    self:addChild(_continueDayBg)

    
    local _numberRow = 4
    local _widthRow = _continueDayBg:getContentSize().width
    -- tonumber(self:getContentSize().width - _midPosX - 4 - 2)
    local _heightRow = _continueDayBg:getContentSize().height
    for i=0,self.continueNum - 1 do
        local _posX = (_widthRow/_numberRow/2)*((i%_numberRow)*2+1)
        local _posY = _heightRow - (_heightRow/4)*(math.floor(i/_numberRow)*2+1)
        local _itemSp = self:initDailyItem(i+1)
        _itemSp:setPosition(cc.p(_posX,_posY))
        _continueDayBg:addChild(_itemSp)
    end
    --累计
    local _totalLabelSp = cc.Sprite:create("res/image/activities/logindaily/logindaily_checkintext.png")
    _totalLabelSp:setAnchorPoint(cc.p(0,0))
    _totalLabelSp:setPosition(cc.p(18 + _midPosX,_continueHeight + 10))
    self:addChild(_totalLabelSp)
    _totalLabelSp:setScale(0.8)
    local _totalDayLabel = XTHDLabel:create("20",24)
    self.totalDayLabel = _totalDayLabel
    -- getCommonWhiteBMFontLabel(20)
    _totalDayLabel:setColor(self:getTextColor("juhuangse"))
    _totalDayLabel:setAnchorPoint(cc.p(0,0))
    _totalDayLabel:setPosition(cc.p(_totalLabelSp:getBoundingBox().x + _totalLabelSp:getBoundingBox().width + 6,_totalLabelSp:getBoundingBox().y))
    self:addChild(_totalDayLabel)
    self:setTotalDayLabel()

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
    _effectSp:setPosition(cc.p(self:getContentSize().width - 10 - _rewardBoxSp:getContentSize().width/2,_continueHeight + _rewardBoxSp:getBoundingBox().height/2))
    self:addChild(_effectSp)
    _rewardBoxSp:setPosition(_effectSp:getPositionX(),_effectSp:getPositionY())
    self:addChild(_rewardBoxSp)
    _rewardBoxSp:setTouchEndedCallback(function()
            self:rewardBoxCallback()
        end)

    self.rewardBoxSp = _rewardBoxSp

    local _totalrewardLabel = XTHDLabel:create(0,18)
    self.totalrewardLabel = _totalrewardLabel
    _totalrewardLabel:setAnchorPoint(cc.p(1,0))
    _totalrewardLabel:setColor(cc.c3b(246, 252, 210))
    _totalrewardLabel:setPosition(cc.p(_rewardBoxSp:getBoundingBox().x-16,_totalLabelSp:getBoundingBox().y))
    self:addChild(_totalrewardLabel)
    self:reFreshTotalRewardState()
end

-- 初始化每一项内容
function LeiJiDengLuLayer:initDailyItem(_idx)
    _idx = _idx or 1
    local _itemData = self.staticDailyData[tostring(_idx)] or {}
    local _dailyItemBg = XTHD.createButton({
                        normalFile = "res/image/activities/logindaily/logindaily_dayBg.png"
                        ,selectedFile = "res/image/activities/logindaily/logindaily_dayBg.png"
                        ,needEnableWhenMoving = true
                        ,touchScale = 0.95
                        ,touchSize = cc.size(158,160)
                    })
    _dailyItemBg.bgState = "normal"
    self.dailyItems[tostring(_idx)] = _dailyItemBg
    _dailyItemBg:setAnchorPoint(cc.p(0.5,0.5))
    _dailyItemBg:setTouchEndedCallback(function()
            self:httpToGetReward(_idx)
        end)
    local _titleSp = cc.Sprite:create("res/image/activities/logindaily/logindaily_daytitle_" .. _idx .. ".png")
    _titleSp:setAnchorPoint(cc.p(0.5,1))
    _titleSp:setPosition(cc.p(10, _dailyItemBg:getContentSize().height - 10))
    _dailyItemBg:addChild(_titleSp)

    -- local _itemNameStr = _itemData.name or ""
    local _itemType = _itemData.reward1type or 0
    -- local _itemCount = tonumber(_itemType)==4 and _itemData.reward1count or nil
    local _itemCount = _itemData.reward1count or 0

    -- local _itemSp = ItemNode:createWithParams({
    --             dbId = nil,
    --             itemId = _itemData and _itemData.reward1id or 0,
    --             _type_ = tonumber(_itemType),
    --             touchShowTip = false,
    --             count = _itemCount
    --         })

    local _itemSp = cc.Sprite:create(XTHD.resource.getResourcePath(_itemType, {
        itemId = _itemData and _itemData.reward1id or 0,
    }))
    _itemSp:setName("itemSp")
    _itemSp:setAnchorPoint(cc.p(0.5,0.5))
    _itemSp:setPosition(cc.p(_dailyItemBg:getContentSize().width/2, 85))
    _dailyItemBg:addChild(_itemSp)

    local _itemLabel = XTHDLabel:create(LANGUAGE_KEY_ACTIVITIES.count.._itemCount, 18)
    _itemLabel:setAnchorPoint(cc.p(0.5, 0))
    _itemLabel:setColor(cc.c3b(78, 67, 53))
    _itemLabel:setPosition(cc.p(_dailyItemBg:getContentSize().width / 2, 10))
    _dailyItemBg:addChild(_itemLabel)

    --设置已领取
    self:setItemState(_idx)
    return _dailyItemBg
end

function LeiJiDengLuLayer:rewardBoxCallback()
    local _rewardData = {}
    for i=self.continueNum+1,self.continueNum + self.totalNum do
        local _index = tonumber(#_rewardData + 1)
        _rewardData[_index] = clone(self.staticDailyData[tostring(i)] or {})
        local _dayNumber = self.staticDailyData[tostring(i)].rewardday or 0
        if self.logindailyData.totalDay and tonumber(self.logindailyData.totalDay)>=tonumber(_dayNumber) then
            if not self.totalStaticData[tostring(_dayNumber)] or tonumber(self.totalStaticData[tostring(_dayNumber)])~=1 then
                _rewardData[_index].rewardState = "canReward"
            else
                _rewardData[_index].rewardState = "Rewarded"
            end
        else
            _rewardData[_index].rewardState = "cannotReward"
        end
    end
    local _popLayer = requires("src/fsgl/layer/HuoDong/LoginDailyRewardPopLayer.lua"):create(_rewardData,self)
    self.parentLayer:addChild(_popLayer)
end

function LeiJiDengLuLayer:httpToGetReward(_idx)
    ClientHttp:requestAsyncInGameWithParams({
        modules = "continueLoginReward?",
        params = {day=_idx or 1},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                self:reFreshHttpData(data,_idx)
                self.logindailyData.conLoginRewardDay = data.conLoginRewardDay or {}
                self:setGetRewardDay(self.logindailyData.conLoginRewardDay)
                -- ShowRewardNode:create(_rewardTable)
                self:setItemState(_idx)
            else
              XTHDTOAST(data.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST("网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function LeiJiDengLuLayer:httpToGetTotalReward(_idx,_callback)
    local _totalIndx = _idx + self.continueNum
    local _rewardDay = tonumber(self.staticDailyData[tostring(_totalIndx)].rewardday  or 0) 
    ClientHttp:requestAsyncInGameWithParams({
        modules = "totalLoginReward?",
        params = {day=_rewardDay},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                self:reFreshHttpData(data,_totalIndx)
                if _callback~=nil then
                    _callback()
                end
                self.logindailyData.totalLoginRewardDay = data.totalLoginRewardDay or {}
                self:setTotalRewardedData(self.logindailyData["totalLoginRewardDay"] or {})
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

function LeiJiDengLuLayer:reFreshHttpData(data,_idx)
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
    local _rewardTable = {}
    _rewardTable[1] = {}
    -- dump(self.staticDailyData[tostring(_idx)] or {})
    _rewardTable[1].rewardtype = tonumber(self.staticDailyData[tostring(_idx)].reward1type or 1)
    _rewardTable[1].num = tonumber(self.staticDailyData[tostring(_idx)].reward1count or 0)
    _rewardTable[1].dbId = _rewarddbid
    _rewardTable[1].id = tonumber(self.staticDailyData[tostring(_idx)].reward1id or 1)
    ShowRewardNode:create(_rewardTable)
end

function LeiJiDengLuLayer:setTotalDayLabel()
    self.totalDayLabel:setString(self.logindailyData.totalDay or 0)
end

function LeiJiDengLuLayer:reFreshTotalRewardState()
    local _effectSp = nil
    local _rewardBox = nil
    if self.rewardBoxSp~=nil and self:getChildByName("effectSp") then
        _effectSp = self:getChildByName("effectSp")
        _rewardBox = self.rewardBoxSp
    else
        return
    end
    local _rewardState = false
    local _rewardDay = self.staticDailyData[tostring(self.continueNum+self.totalNum)].rewardday or 0
    for i=1,self.totalNum do
        local _dayNumber = self.staticDailyData[tostring(self.continueNum+i)].rewardday or 0
        if self.logindailyData.totalDay and tonumber(self.logindailyData.totalDay)>=tonumber(_dayNumber) then
            if not self.totalStaticData[tostring(_dayNumber)] or tonumber(self.totalStaticData[tostring(_dayNumber)])~=1 then
                _rewardState = true
                _rewardDay = _dayNumber
                break
            end
        else
            _rewardDay = _dayNumber
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
        self.totalrewardLabel:setString(LANGUAGE_KEY_ACTIVITIES.totalRewardTextXc .. ":" .. self.logindailyData.totalDay .. "/" .. _rewardDay)
    end
end

function LeiJiDengLuLayer:setItemState(_idx)
    if self.dailyItems[tostring(_idx)]==nil then
        return
    end
    local _continuesDay = tonumber(self.logindailyData.continueDay or 1)
    if tonumber(_idx)<=self.getrewardDay then
        self:setItemRewarded(_idx)
    elseif tonumber(_idx)<=_continuesDay then
        self:setItemCanReward(_idx)
    else
        local _dailyItemBg = self.dailyItems[tostring(_idx)]
        if _dailyItemBg.bgState and _dailyItemBg.bgState ~= "normal" then
            _dailyItemBg:getStateNormal():initWithFile("res/image/activities/logindaily/logindaily_dayBg.png")
            _dailyItemBg:getStateSelected():initWithFile("res/image/activities/logindaily/logindaily_dayBg.png")
        end
        _dailyItemBg.bgState = "normal"
        _dailyItemBg:getChildByName("itemSp")--:setTouchShowTip(true)
        _dailyItemBg:setClickable(false)
        self:removeRewardItemEffect(_dailyItemBg)
    end
end
function LeiJiDengLuLayer:setItemCanReward(_idx)
    if self.dailyItems[tostring(_idx)]==nil then
        return
    end
    local _dailyItem = self.dailyItems[tostring(_idx)]
    _dailyItem:setClickable(true)
    
    if _dailyItem.bgState and _dailyItem.bgState ~="light" then
        _dailyItem:getStateNormal():initWithFile("res/image/activities/logindaily/logindaily_dayrewardBg.png")
        _dailyItem:getStateSelected():initWithFile("res/image/activities/logindaily/logindaily_dayrewardBg.png")
    end
    _dailyItem.bgState = "light"
    
    if _dailyItem:getChildByName("itemSp") then
        local _itemSp = _dailyItem:getChildByName("itemSp")
        if _itemSp:getChildByName("animationSp") then
            return
        end
        local _animationSp = cc.Sprite:create()
        _animationSp:setName("animationSp")
        _animationSp:setPosition(cc.p(_itemSp:getContentSize().width/2,_itemSp:getContentSize().height/2))
		_animationSp:setScaleX(1.5)
		_animationSp:setScaleY(2)
        _itemSp:addChild(_animationSp)
        local animation = getAnimation("res/spine/effect/logindaily_effect/",1,8,0.1)
        _animationSp:runAction(cc.RepeatForever:create(animation))
    end
end

function LeiJiDengLuLayer:setItemRewarded(_idx)
    if self.dailyItems[tostring(_idx)]==nil then
        return
    end
    local _dailyItemBg = self.dailyItems[tostring(_idx)]
    if _dailyItemBg.bgState and _dailyItemBg.bgState ~= "normal" then
        _dailyItemBg:getStateNormal():initWithFile("res/image/activities/logindaily/logindaily_dayBg.png")
        _dailyItemBg:getStateSelected():initWithFile("res/image/activities/logindaily/logindaily_dayBg.png")
    end
    _dailyItemBg.bgState = "normal"
    local _coverSp = cc.Sprite:create("res/image/activities/logindaily/logindaily_coversp.png")
    _coverSp:setPosition(cc.p(_dailyItemBg:getContentSize().width/2,_dailyItemBg:getContentSize().height/2))
    _coverSp:setOpacity(0)
    _dailyItemBg:addChild(_coverSp)
    local _getRewardSp = cc.Sprite:create("res/image/activities/logindaily/yilingqu.png")
    _getRewardSp:setScale(0.8)
    _getRewardSp:setPosition(cc.p(_coverSp:getContentSize().width/2 + 3,_coverSp:getContentSize().height/2 + 7))
    _coverSp:addChild(_getRewardSp)
    _dailyItemBg:setClickable(false)
    if _dailyItemBg:getChildByName("itemSp") then
        _dailyItemBg:getChildByName("itemSp")--:setTouchShowTip(false)
    end
    self:removeRewardItemEffect(_dailyItemBg)
end

function LeiJiDengLuLayer:removeRewardItemEffect(_dailyItemBg)
    if _dailyItemBg:getChildByName("itemSp") then
        if _dailyItemBg:getChildByName("itemSp"):getChildByName("animationSp") then
            _dailyItemBg:getChildByName("itemSp"):stopAllActions()
            _dailyItemBg:getChildByName("itemSp"):removeChildByName("animationSp")
        end
    end
end

function LeiJiDengLuLayer:setGetRewardDay(_data)
    if _data == nil or next(_data)==nil then
        return 
    end
    local _rewardIndex = 1
    for k,v in pairs(_data) do
        if tonumber(v)>_rewardIndex then
            _rewardIndex = tonumber(v)
        end
    end
    self.getrewardDay = _rewardIndex
end

function LeiJiDengLuLayer:setTotalRewardedData(_data)
    self.totalStaticData = {}
    if _data == nil then
        return
    end
    -- dump(data)
    for i=1,#_data do
        self.totalStaticData[tostring(_data[i])] = 1
    end
end

function LeiJiDengLuLayer:setData(data)
    self.logindailyData = {}
    self.logindailyData = data
    self:setGetRewardDay( data and data.conLoginRewardDay or {})
    self:setTotalRewardedData(self.logindailyData["totalLoginRewardDay"] or {})

end

function LeiJiDengLuLayer:getStaticData()
    self.staticDailyData = {}
    self.staticDailyData = gameData.getDataFromCSVWithPrimaryKey("ContinuousClockIn") or {}
    local _itemInfoData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet") or {}
    
    local _continuenum = 0
    local _totalnum = 0
    for k,v in pairs(self.staticDailyData) do
        if self.staticDailyData[tostring(k)].rewardclass and tonumber(self.staticDailyData[tostring(k)].rewardclass)==1 then
            _continuenum = _continuenum + 1
        elseif self.staticDailyData[tostring(k)].rewardclass and tonumber(self.staticDailyData[tostring(k)].rewardclass)==2 then
            _totalnum = _totalnum + 1
        end
        local _itemType = self.staticDailyData[tostring(k)].reward1type or 1
        if tonumber(_itemType) == 4 then
            local _itemdid = self.staticDailyData[tostring(k)].reward1id or 0
            self.staticDailyData[tostring(k)].name = _itemInfoData[tostring(_itemdid)] and _itemInfoData[tostring(_itemdid)].name or ""
        else
            local _count = self.staticDailyData[tostring(k)].reward1count or 0
            self.staticDailyData[tostring(k)].name = _count .. (XTHD.resource.name[tonumber(_itemType)] or "")
        end
    end
    self.maxDay = tonumber(self.staticDailyData[tostring(_continuenum + _totalnum)] and self.staticDailyData[tostring(_continuenum + _totalnum)].rewardday or 0)
    self.continueNum = _continuenum
    self.totalNum = _totalnum
end

function LeiJiDengLuLayer:getTextColor(_str)
    local _color = {
        shenhese = cc.c4b(54,55,112,255),
        juhuangse = cc.c4b(255,0,0,255)
    }
    return _color[tostring(_str)]
end

function LeiJiDengLuLayer:create(params)
    return self.new(params)
end

return LeiJiDengLuLayer