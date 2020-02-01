--[[
    FileName: buyItemPop1.lua
    Author: andong
    Date: 2016-1-23
    Purpose: 购买item道具界面
]]
local buyItemPop1 = class("buyItemPop1",function()
        return XTHDPopLayer:create()
end)

function buyItemPop1:ctor(_itemid,_parent)
  self._fontSize = 18
    self.itemId = _itemid
    self.maxNumber = 0
    self.buyItemStaticData = {}
    self.cannotBuyReasonStr = nil
    self.lastCount = 0
    self.parentlayer = _parent
    self.lastBuyCountLabel = nil
    self._createNumLabel = nil
    self.buyPriceLabel = nil
    self:setStaticBuyItems()
    self:initLayer()
end

function buyItemPop1:initLayer() 
    local popNode = ccui.Scale9Sprite:create(cc.rect(40,40,1,2), "res/image/common/scale9_bg_34.png" )
    popNode:setContentSize(495,284)
    popNode:setAnchorPoint(cc.p(0.5,0.5))
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
    self:getContainerLayer():addChild(popNode)
    self.popNode = popNode

    --关闭按钮
    local _closeBtn = XTHDPushButton:createWithParams({
        normalFile        = "res/image/common/btn/btn_red_close_normal.png",
        selectedFile      = "res/image/common/btn/btn_red_close_selected.png",
        musicFile         = XTHD.resource.music.effect_close_pop,
        endCallback       = function()
                self:hide({music = true})
            end,--
    })
    _closeBtn:setAnchorPoint(cc.p(0.5,0.5))
    _closeBtn:setPosition(cc.p(popNode:getContentSize().width-15,popNode:getContentSize().height-10))
    popNode:addChild(_closeBtn,5)

    --last buy counts
    local _lastBuyCountTitleLabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.buyItemLastCountTextXc,self._fontSize)
    _lastBuyCountTitleLabel:setColor(self:getTextColor("shenhese"))
    _lastBuyCountTitleLabel:setPosition(cc.p(popNode:getContentSize().width/2 - 15,popNode:getContentSize().height - 42))
    popNode:addChild(_lastBuyCountTitleLabel)

    local _lastBuyCountlabel = XTHDLabel:create(self.lastCount,self._fontSize + 4)
    _lastBuyCountlabel:setColor(self:getTextColor("lanse"))
    self.lastBuyCountLabel = _lastBuyCountlabel
    _lastBuyCountlabel:setAnchorPoint(cc.p(0,0.5))
    _lastBuyCountlabel:setPosition(cc.p(_lastBuyCountTitleLabel:getBoundingBox().x+_lastBuyCountTitleLabel:getBoundingBox().width,_lastBuyCountTitleLabel:getPositionY()))
    popNode:addChild(_lastBuyCountlabel)

    self:reFreshLastBuyCount()

    --button
    local buyBtn = XTHD.createCommonButton({
            btnSize = cc.size(200,46),
            isScrollView = false,
            text = LANGUAGE_BTN_KEY.querengoumai,
        })
    buyBtn:setAnchorPoint(cc.p(0.5,0))
    buyBtn:setPosition(cc.p(popNode:getContentSize().width/2,30))
    popNode:addChild(buyBtn)

    buyBtn:setTouchEndedCallback(function()
            self:httpToBuyExpItems()
        end)


    self:setInfopart()

    self:show()
end

function buyItemPop1:setInfopart()
    --info
    local _partPosY = (self.popNode:getContentSize().height+30)/2
    local _partBg = ccui.Scale9Sprite:create(cc.rect(10,10,10,10),"res/image/common/scale9_bg_5.png")
    _partBg:setContentSize(cc.size(self.popNode:getContentSize().width - 34,113))
    _partBg:setPosition(cc.p(self.popNode:getContentSize().width/2,_partPosY))
    self.popNode:addChild(_partBg)

    --头像
    local _itemSp = ItemNode:createWithParams({
                dbId = nil,
                itemId = self.itemId,
                _type_ = 4,
                touchShowTip = true
            })
    _itemSp:setAnchorPoint(cc.p(0,0.5))
    _itemSp:setPosition(cc.p(20,_partBg:getContentSize().height/2+1))
    _partBg:addChild(_itemSp)

    local _linePosX = 120
    local _linePosY = 59
    --line
    local _lineSp = cc.Sprite:create("res/image/common/line_1.png")
    _lineSp:setAnchorPoint(cc.p(0,0.5))
    _lineSp:setPosition(cc.p(_linePosX,_linePosY))
    _partBg:addChild(_lineSp)

    --name
    local _namelabel = XTHDLabel:create(self.buyItemStaticData.name,self._fontSize)
    _namelabel:setColor(self:getTextColor("shenhese"))
    _namelabel:setAnchorPoint(cc.p(0,0))
    _namelabel:setPosition(cc.p(_linePosX, _linePosY + 5))
    _partBg:addChild(_namelabel)

    --introduce
    -- local _expTitleLabel = XTHDLabel:create("EXP:",self._fontSize)
    -- _expTitleLabel:setColor(self:getTextColor("shenhese"))
    -- _expTitleLabel:setAnchorPoint(cc.p(0,0))
    -- _expTitleLabel:setPosition(cc.p(_linePosX,_linePosY + 5))
    -- _partBg:addChild(_expTitleLabel)

    -- local _addExpLabel = XTHDLabel:create("+".. self.buyItemStaticData.effectvalue,self._fontSize)
    -- _addExpLabel:setAnchorPoint(cc.p(0,0))
    -- _addExpLabel:setColor(self:getTextColor("lvse"))
    -- _addExpLabel:setPosition(cc.p(_expTitleLabel:getBoundingBox().x+_expTitleLabel:getBoundingBox().width,_expTitleLabel:getBoundingBox().y))
    -- _partBg:addChild(_addExpLabel)

    --buy price
    local _priceTitlelabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.buyExpPriceTitleTextXc,self._fontSize)
    _priceTitlelabel:setColor(self:getTextColor("chenghongse"))
    _priceTitlelabel:setAnchorPoint(cc.p(0,0))
    _priceTitlelabel:setPosition(cc.p(_linePosX + 130,_linePosY + 5))
    _partBg:addChild(_priceTitlelabel)

    local _priceSp = cc.Sprite:create("res/image/common/header_ingot.png")
    _priceSp:setAnchorPoint(cc.p(0,0.5))
    _priceSp:setPosition(cc.p(_priceTitlelabel:getBoundingBox().x+_priceTitlelabel:getBoundingBox().width,_priceTitlelabel:getBoundingBox().y+_priceTitlelabel:getBoundingBox().height/2))
    _partBg:addChild(_priceSp)

    local _priceValueLabel = getCommonWhiteBMFontLabel(self.buyItemStaticData.price or 0)
    self.buyPriceLabel = _priceValueLabel
    _priceValueLabel:setAnchorPoint(cc.p(0,0.5))
    _priceValueLabel:setPosition(cc.p(_priceSp:getBoundingBox().x+_priceSp:getBoundingBox().width,_priceSp:getPositionY()-7))
    _partBg:addChild(_priceValueLabel)

    --button
    local _btnPosY = 28
    local _maxButton = XTHD.createMaxBtn()
    -- XTHDPushButton:createWithParams({
    --         normalFile   = "res/image/common/btn/btn_max_normal.png",
    --         selectedFile = "res/image/common/btn/btn_max_selected.png"
    --         ,musicFile = XTHD.resource.music.effect_btn_common
    --     })
    _maxButton:setAnchorPoint(cc.p(1,0.5))
    _maxButton:setPosition(cc.p(_partBg:getContentSize().width - 20,_btnPosY))
    _maxButton:setTouchEndedCallback(function()
            if self._createNumLabel~=nil and self.maxNumber and tonumber(self.maxNumber)>1 then
                self:setMakeNumberLabel(self.maxNumber or 1)
            end
        end)
    _partBg:addChild(_maxButton)

    --减
    local _reduceBtn = self:createBtn("cut")
    _reduceBtn:setAnchorPoint(cc.p(0,0.5))
    _reduceBtn:setPosition(cc.p(_linePosX,_btnPosY))
    _partBg:addChild(_reduceBtn)

    local _createNum_bg = ccui.Scale9Sprite:create(cc.rect(6,6,1,1),"res/image/common/scale9_bg_24.png")
  _createNum_bg:setContentSize(cc.size(128,30))
    _createNum_bg:setAnchorPoint(cc.p(0,0.5))
    _createNum_bg:setPosition(cc.p(_reduceBtn:getBoundingBox().x+_reduceBtn:getBoundingBox().width + 14,_btnPosY))
    _partBg:addChild(_createNum_bg)

    local _createNumLabel = getCommonWhiteBMFontLabel("1")
    self._createNumLabel = _createNumLabel
    -- XTHDLabel:create("1",self._fontSize)
    _createNumLabel:setAnchorPoint(cc.p(0.5,0.5))
    _createNumLabel:setColor(cc.c4b(255,255,255,255))
    _createNumLabel:setPosition(cc.p(_createNum_bg:getContentSize().width/2,_createNum_bg:getContentSize().height/2-7))
    _createNum_bg:addChild(_createNumLabel)
    --加
    local _addBtn = self:createBtn("add")
    _addBtn:setAnchorPoint(cc.p(0,0.5))
    _addBtn:setPosition(cc.p(_createNum_bg:getBoundingBox().x+_createNum_bg:getBoundingBox().width + 14,_createNum_bg:getPositionY()))
    _partBg:addChild(_addBtn)

end
--加号减号按钮
function buyItemPop1:createBtn(_type)
    local _path = "addDot"
    if _type == "cut" then
        _path = "reduceDot"
    end
    local _tousize = cc.size(70,70)
    local _btn = XTHD.createButton({
            normalFile = "res/image/common/btn/btn_" .. _path .. "_normal.png"
            ,selectedFile = "res/image/common/btn/btn_" .. _path .. "_selected.png"
      ,touchSize = _tousize
      ,needEnableWhenOut = true
        })
    _btn._changeValue = 1
    _btn:setScale(0.8)
    _btn.numbers = 0
    _btn.is_click = true
    _btn.ex_num = 0
    _btn.scheduleFunc = nil
    _btn.conditionFunc = nil
    _btn._toastStr = LANGUAGE_TIPS_WORDS101-------"大侠，不能再多了"
    if _type == "cut" then
        _btn._changeValue = -1
        _btn.conditionFunc = function()
            if _btn.ex_num > 1 then
                return true
            end
            return false
        end
        _btn._toastStr = LANGUAGE_TIPS_WORDS102--------"大侠，不能再少了"
    else
        _btn._changeValue = 1
        _btn.conditionFunc = function()
            if _btn.ex_num < 1000000 then
                return true
            end
            return false
        end
        _btn._toastStr = LANGUAGE_TIPS_WORDS101-------"大侠，不能再多了"
    end
    _btn.scheduleFunc = function()
            if true == _btn.conditionFunc() then
                _btn.ex_num = _btn.ex_num + _btn._changeValue
                _btn.numbers = _btn.numbers + 1
            else
                _btn:stopAllActions()
                XTHDTOAST(_btn._toastStr)
                _btn.numbers = 0
            end
        end
    --[[按钮点击和长按操作]]
    _btn.quickExNum = function(  )
        _btn.ex_num = tonumber(self._createNumLabel:getString())
        _btn.scheduleFunc()
        if tonumber(self.maxNumber)<tonumber(_btn.ex_num) then
            _btn:stopAllActions()
            self:showCannotBuyReason()
            return
        else
            self:setMakeNumberLabel(_btn.ex_num)
        end

        --如果减少次数持续10次，则加快减少速度
        if _btn.numbers > 10 and _btn.numbers < 30 then
            _btn:stopAllActions()
            schedule(_btn,_btn.quickExNum,0.05,100)
        elseif _btn.numbers > 30 then
            _btn:stopAllActions()
            schedule(_btn,_btn.quickExNum,0.01,100)
        end
    end
    _btn.pressLongTimeCallback_reduce = function(  )
        _btn.is_click = false
        schedule(_btn,_btn.quickExNum,0.1,100)
    end
    _btn:setTouchBeganCallback(function (  )
        -- 延时多少秒操作，此处是延时1秒后回调pressLongTimeCallback_reduce
        performWithDelay(_btn,_btn.pressLongTimeCallback_reduce,0.3)
        
    end)
    _btn:setTouchEndedCallback(function()
        _btn.ex_num = tonumber(self._createNumLabel:getString())
        if _btn.is_click then
            _btn.scheduleFunc()
            if tonumber(self.maxNumber)<tonumber(_btn.ex_num) then
                _btn:stopAllActions()
                self:showCannotBuyReason()
            else
                self:setMakeNumberLabel(_btn.ex_num)
            end
        end
        _btn.is_click = true
        _btn:stopAllActions()
        _btn.numbers = 0
    end)

    return _btn
end

function buyItemPop1:setMakeNumberLabel(_str)
    local _buyNumber = tonumber(_str or 0)
    self._createNumLabel:setString(_buyNumber)
    local _buyValue = _buyNumber * tonumber(self.buyItemStaticData.price or 0)
    self.buyPriceLabel:setString(_buyValue)
end

function buyItemPop1:setMaxNumber()
    self.maxNumber = 0
    local _priceValue = tonumber(self.buyItemStaticData.price or 1)
    local currentBuyCount = math.floor(tonumber(gameUser.getIngot())/_priceValue)
    if currentBuyCount < self.lastCount then
        self.cannotBuyReasonStr = "noIngot"
        self.maxNumber = currentBuyCount
    else
        self.cannotBuyReasonStr = "noCount"
        self.maxNumber = self.lastCount
    end
end

function buyItemPop1:getBtnNode(_path)
    local _normalNode = ccui.Scale9Sprite:create(cc.rect(50,0,30,49),_path)
    _normalNode:setContentSize(cc.size(200,49))
    return _normalNode
end

function buyItemPop1:showCannotBuyReason()
    if self.cannotBuyReasonStr==nil then
        return
    end
    if tostring(self.cannotBuyReasonStr) == "noCount" then
        self:goToRechargeVIP()
    elseif tostring(self.cannotBuyReasonStr) == "noIngot" then
        self:gotoRechargeIngot()
    end
    
end

function buyItemPop1:goToRechargeVIP()
    -- print("跳转去充值VIP")
    --购买技能文字
    local _labelStr = LANGUAGE_KEY_HERO_TEXT.noEnoughBuyCountTextXc
    local _buyDialog = XTHDConfirmDialog:createWithParams({
            msg = _labelStr,
            rightCallback = function()
                if self.parentlayer~=nil then
                    XTHD.createRechargeVipLayer(self.parentlayer)
                end
            end
        })
    self:addChild(_buyDialog)
    
end
--元宝不足，前往充值
function buyItemPop1:gotoRechargeIngot(_type)
    local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=1})
    self:addChild(StoredValue, 3)
end

function buyItemPop1:httpToBuyExpItems()
    local _countValue = tonumber(self._createNumLabel:getString() or 0)
    ClientHttp:httpHeroBuyExpItems(self,function(data)
            gameUser.setIngot(data.ingot)
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
            gameUser.setGodItemSurplusSum(data.stoneItemSurplusSum)

            self:reFreshLastBuyCount()
            self:setMaxNumber()
            self:reFreshHttpData(data)
            
            self._createNumLabel:setString(1)
            self.buyPriceLabel:setString(self.buyItemStaticData.price)

            local _rewardTable = {}
            _rewardTable[1] = {}
            _rewardTable[1].rewardtype = 4
            _rewardTable[1].num = _countValue
            _rewardTable[1].id = self.itemId
            ShowRewardNode:create(_rewardTable)
        end,{itemId=self.itemId,count=_countValue},function(data)
            if data~=nil and data.result~=nil and tonumber(data.result) == 5502 then
                self:goToRechargeVIP()
            end
        end)
end

function buyItemPop1:reFreshHttpData(data)
    --修改消耗品的数量，为0删除
    for i=1,#data["items"] do
        local _dbid = data.items[i].dbId
        if data.items[i].count and tonumber(data.items[i].count)>0 then
            DBTableItem.updateCount(gameUser.getUserId(),data.items[i],_dbid)
        else
            DBTableItem.deleteData(gameUser.getUserId(),_dbid)
        end
    end

    if self._refreshCall then
        self._refreshCall(data.items)
    end
end

function buyItemPop1:reFreshLastBuyCount()
    local _godItemSurplusSum = gameUser.getGodItemSurplusSum() or {}
    local _itemIndex = tonumber(self.itemId) - 2019

    self.lastCount = _godItemSurplusSum[_itemIndex] or 0
    self.lastBuyCountLabel:setString(self.lastCount)
    self:setMaxNumber()
end

function buyItemPop1:setStaticBuyItems()
    self.buyItemStaticData = {}
    local _itemData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
    self.buyItemStaticData = _itemData[tostring(self.itemId)] or {}
end

function buyItemPop1:getTextColor(_str)
    local _color = {
        huanghese = cc.c4b(237, 232, 193,255)
        ,shenhese = cc.c4b(70,34,34,255)
        ,lanse = cc.c4b(26,158,207,255)
        ,lvse = cc.c4b(104,157,0,255)
        ,chenghongse = cc.c4b(231,87,0,255),
    }
    return _color[tostring(_str)]
end

function buyItemPop1:create(_itemid,_layer, callback)
    if callback and type(callback) == "function" then
        self._refreshCall = callback
    end
    local _layer = self.new(_itemid,_layer)
    return _layer
end

return buyItemPop1