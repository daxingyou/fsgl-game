local BuyExpByIngotPopLayer1 = class("BuyExpByIngotPopLayer1",function()
    return XTHDPopLayer:create()
end)

function BuyExpByIngotPopLayer1:ctor(_itemid,_layer,isUpdate,callFunc)
self._fontSize = 18
self.itemId = _itemid
self.maxNumber = 0
self.buyItemStaticData = {}
self.cannotBuyReasonStr = nil
self.lastCount = 0
self.buyType = _layer.buyType or 1
self.configId = _layer.configId or 1
self.localData = _layer.data or {num = 1}
self.isWBG = _layer.isWBG or false

self.parentlayer = _layer

self.lastBuyCountLabel = nil
self._createNumLabel = nil
self.buyPriceLabel = nil
self._isUpdate = isUpdate
self._callFunc = callFunc

self:setStaticBuyItems()

-- self:setMaxNumber()
self:initLayer()
end

-- 当前道具是否是经验相关道具
function isExpItem(itemId)
    -- body
    if itemId >= 2007 and itemId < 2011 and itemId ~= 2008 then
        return true
    end
    return false
end

function BuyExpByIngotPopLayer1:initLayer() 
    local popNode = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png" )
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

    -- --title
    -- local _titleBg = cc.Sprite:create("res/image/plugin/saint_beast/pop_title.png")
    -- _titleBg:setAnchorPoint(cc.p(0.5,0))
    -- _titleBg:setPosition(cc.p(popNode:getContentSize().width/2,popNode:getContentSize().height-13))
    -- popNode:addChild(_titleBg)

    -- local _titlelabel = XTHDLabel:create(LANGUAGE_KEY_TITLENAME.buyExpItemsTitleTextXc,self._fontSize + 2)
    -- _titlelabel:setColor(self:getTextColor("huanghese"))
    -- _titlelabel:setPosition(cc.p(_titleBg:getContentSize().width/2,_titleBg:getContentSize().height/2))
    -- _titleBg:addChild(_titlelabel)

    --last buy counts
	local _lastBuyCountTitleLabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.buyItemLastCountTextXc,self._fontSize)
	if self.buyType == 4 then
		_lastBuyCountTitleLabel:setString("今日剩余购买数量:")
	else
		_lastBuyCountTitleLabel:setString(LANGUAGE_KEY_HERO_TEXT.buyItemLastCountTextXc)
	end
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

    if self.isWBG then
        _lastBuyCountlabel:setString("不限")
    end

   -- if self.lastCount == 999 then
   --     _lastBuyCountlabel:setString("不限")
   -- end

    --button
    local buyBtn = XTHD.createCommonButton({
        btnSize = cc.size(200,46),
        text = LANGUAGE_BTN_KEY.querengoumai,
        isScrollView = false,
    })
    buyBtn:setScale(0.8)
    buyBtn:setAnchorPoint(cc.p(0.5,0))
    buyBtn:setPosition(cc.p(popNode:getContentSize().width/2,30))
    popNode:addChild(buyBtn)

    buyBtn:setTouchEndedCallback(function()
        if self.buyType == 1 or self.buyType == 3 then
            self:httpToBuyExpItems()
        else 
            self:httpToShopBuyItems()
        end
    end)

    self:setInfopart()
    self:show()
end

function BuyExpByIngotPopLayer1:setInfopart()
   --info
   local _partPosY = (self.popNode:getContentSize().height+30)/2
   local _partBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
   _partBg:setContentSize(cc.size(self.popNode:getContentSize().width - 34,120))
   _partBg:setPosition(cc.p(self.popNode:getContentSize().width/2,_partPosY))
   self.popNode:addChild(_partBg)

   --头像
    local _itemSp = ItemNode:createWithParams({
                dbId = nil,
                itemId = self.itemId,
                _type_ = 4,
                count = self.localData.num,
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
    _namelabel:setAnchorPoint(cc.p(0,1))
    _namelabel:setPosition(cc.p(_linePosX,_partBg:getContentSize().height - 9))
    _partBg:addChild(_namelabel)

   --introduce
    if isExpItem(self.itemId) then
        local _expTitleLabel = XTHDLabel:create("EXP:",self._fontSize)
        _expTitleLabel:setColor(self:getTextColor("shenhese"))
        _expTitleLabel:setAnchorPoint(cc.p(0,0))
        _expTitleLabel:setPosition(cc.p(_linePosX,_linePosY + 5))
        _partBg:addChild(_expTitleLabel)

        local _addExpLabel = XTHDLabel:create("+".. self.buyItemStaticData.effectvalue,self._fontSize)
        _addExpLabel:setAnchorPoint(cc.p(0,0))
        _addExpLabel:setColor(self:getTextColor("lvse"))
        _addExpLabel:setPosition(cc.p(_expTitleLabel:getBoundingBox().x+_expTitleLabel:getBoundingBox().width,_expTitleLabel:getBoundingBox().y))
        _partBg:addChild(_addExpLabel)
    end

   local _priceTitlelabel = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.buyExpPriceTitleTextXc,self._fontSize)
    _priceTitlelabel:setColor(self:getTextColor("chenghongse"))
   _priceTitlelabel:setAnchorPoint(cc.p(0,0))
   _priceTitlelabel:setPosition(cc.p(_linePosX + 130,_linePosY + 5))
   _partBg:addChild(_priceTitlelabel)

   local _priceSp = cc.Sprite:create("res/image/common/header_ingot.png")
	if self.buyType == 2 or self.buyType == 4 then
		if self.localData.ingotprice == 0 then
			_priceSp = cc.Sprite:create(IMAGE_KEY_HEADER_GOLD)
		else
			_priceSp = cc.Sprite:create("res/image/common/header_ingot.png")
		end	
	else
		_priceSp = cc.Sprite:create("res/image/common/header_ingot.png")
	end
   _priceSp:setAnchorPoint(cc.p(0,0.5))
   _priceSp:setPosition(cc.p(_priceTitlelabel:getBoundingBox().x+_priceTitlelabel:getBoundingBox().width,_priceTitlelabel:getBoundingBox().y+_priceTitlelabel:getBoundingBox().height/2))
   _partBg:addChild(_priceSp)
   local _priceValueLabel
   if self.buyType == 2 or self.buyType == 3 then  --元宝商城
       _priceValueLabel = getCommonWhiteBMFontLabel(getHugeNumberWithLongNumber(self.localData.ingotprice,10000) or 0)
	elseif self.buyType == 4 then
		if self.localData.ingotprice == 0 then
			_priceValueLabel = getCommonWhiteBMFontLabel(getHugeNumberWithLongNumber(self.localData.goldprice,10000) or 0)
		else
			_priceValueLabel = getCommonWhiteBMFontLabel(getHugeNumberWithLongNumber(self.localData.ingotprice,10000) or 0)
		end	
   else
       _priceValueLabel = getCommonWhiteBMFontLabel(getHugeNumberWithLongNumber(self.buyItemStaticData.price,10000) or 0)   
   end
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

local _createNum_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_24.png")
_createNum_bg:setContentSize(cc.size(128,30))
_createNum_bg:setAnchorPoint(cc.p(0,0.5))
_createNum_bg:setPosition(cc.p(_reduceBtn:getBoundingBox().x+_reduceBtn:getBoundingBox().width + 14,_btnPosY))
_partBg:addChild(_createNum_bg)

local _createNumLabel = getCommonWhiteBMFontLabel(1)
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
function BuyExpByIngotPopLayer1:createBtn(_type)
local _path = "addDot"
if _type == "cut" then
    _path = "reduceDot"
end
local _tousize = cc.size(70,70)
local _btn = XTHD.createButton({
    normalFile = "res/image/common/btn/btn_" .. _path .. "_normal.png"
    ,selectedFile = "res/image/common/btn/btn_" .. _path .. "_selected.png"
    ,touchSize = _tousize
    ,needEnableWhenOut = true})
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

function BuyExpByIngotPopLayer1:setMakeNumberLabel(_str)
    local _buyNumber = tonumber(_str or 0)
    self._createNumLabel:setString(_buyNumber)
    local _buyValue
    if self.buyType == 2 or self.buyType == 3 then  --元宝商城
       _buyValue = _buyNumber * tonumber(self.localData.ingotprice or 0)
	elseif self.buyType == 4 then
		if self.localData.ingotprice == 0 then
			_buyValue = _buyNumber * tonumber(self.localData.goldprice or 0)
		else
			_buyValue = _buyNumber * tonumber(self.localData.ingotprice or 0)
		end
    else
       _buyValue = _buyNumber * tonumber(self.buyItemStaticData.price  or 0)  
    end
    self.buyPriceLabel:setString(getHugeNumberWithLongNumber(_buyValue,10000))
end

function BuyExpByIngotPopLayer1:setMaxNumber()
    self.maxNumber = 0
    local _priceValue
    if self.buyType == 2 or self.buyType == 3 then  --元宝商城
       _priceValue = tonumber(self.localData.ingotprice or 1)   
	elseif self.buyType == 4 then
		if self.localData.ingotprice == 0 then
			_priceValue = tonumber(self.localData.goldprice or 1)  
		else
			_priceValue = tonumber(self.localData.ingotprice or 1)  
		end
    else
       _priceValue = tonumber(self.buyItemStaticData.price or 1)   
    end
    local currentBuyCount = math.floor(tonumber(gameUser.getIngot())/_priceValue)
	if self.buyType == 4 then
--		if self.localData.ingotprice == 0 then
--			currentBuyCount = math.floor(tonumber(gameUser.getGold())/_priceValue)  
--		else
--			currentBuyCount = math.floor(tonumber(gameUser.getIngot())/_priceValue)
--		end
		if self.lastCount == "无限" then
            currentBuyCount = math.floor(tonumber(gameUser.getIngot())/_priceValue)
        else
            currentBuyCount = math.floor(tonumber(self.lastCount)/self.localData.num)
        end
	end
    if self.lastCount == "无限" then
        self.cannotBuyReasonStr = "noIngot"
        if self.buyType == 4 then
            if self.localData.ingotprice == 0 then
                if self.localData.goldprice*currentBuyCount > gameUser.getGold() then
                    self.cannotBuyReasonStr = "noGold"
                else
                    self.cannotBuyReasonStr = "noCount"
                end 
            else
                if self.localData.ingotprice*currentBuyCount > gameUser.getGold() then
                    self.cannotBuyReasonStr = "noIngot"
                else
                    self.cannotBuyReasonStr = "noCount"
                end 
            end
        end   
        self.maxNumber = currentBuyCount
    else
        if currentBuyCount < tonumber(self.lastCount) then
            self.cannotBuyReasonStr = "noIngot"
            if self.buyType == 4 then
                if self.localData.ingotprice == 0 then
                    if self.localData.goldprice*currentBuyCount > gameUser.getGold() then
                        self.cannotBuyReasonStr = "noGold"
                    else
                        self.cannotBuyReasonStr = "noCount"
                    end 
                else
                    if self.localData.ingotprice*currentBuyCount > gameUser.getGold() then
                        self.cannotBuyReasonStr = "noIngot"
                    else
                        self.cannotBuyReasonStr = "noCount"
                    end 
                end
            end   
            self.maxNumber = currentBuyCount
        else
            self.cannotBuyReasonStr = "noCount"
            self.maxNumber = self.lastCount
        end
    end
end

function BuyExpByIngotPopLayer1:getBtnNode(_path)
    local _normalNode = ccui.Scale9Sprite:create(cc.rect(50,0,30,49),_path)
    _normalNode:setContentSize(cc.size(200,49))
    return _normalNode
end

function BuyExpByIngotPopLayer1:showCannotBuyReason()
    if self.cannotBuyReasonStr==nil then
        return
    end
    if tostring(self.cannotBuyReasonStr) == "noCount" then
        self:goToRechargeVIP()
    elseif tostring(self.cannotBuyReasonStr) == "noIngot" then
        self:gotoRechargeIngot()
	elseif tostring(self.cannotBuyReasonStr) == "noGold" then
		local _dialog = XTHDConfirmDialog:createWithParams({
			msg = "您的银两不足，是否前往获取？",
			rightCallback = function()
				replaceLayer({id = 48,fNode = self:getParent()})   
			end
		})
		self:addChild(_dialog)
    end
end

function BuyExpByIngotPopLayer1:goToRechargeVIP()
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
function BuyExpByIngotPopLayer1:gotoRechargeIngot()
--	self.parentlayer:showMoneyNoEnoughtPop("noIngot")
	local _id = 1
    local _idKey = { noCoin = 3, noFeicui = 4, noIngot = 1, noItem = 5 }
    _id = _idKey["noIngot"] or 1
    local recharge = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create( { id = _id })
    self:addChild(recharge, 3)
end

function BuyExpByIngotPopLayer1:httpToShopBuyItems()
    local _countValue = tonumber(self._createNumLabel:getString() or 0)
    local show = {}
    XTHDHttp:requestAsyncInGameWithParams({
        modules = self.localData.payM,
        params = {configId = self.configId, sum =_countValue },
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                -- print("商城购买服务器返回的数据为：")
                -- print_r(data)
                local _reward = {}
                if data.items and #data.items ~= 0 then
                    if data.property then 
                        for i=1,#data.property do
                            local _tb = string.split(data.property[i],",")
                            gameUser.updateDataById(_tb[1], _tb[2])
                        end
                    end 
                    for i=1,#data.items do
                        local item_data = data.items[i]
                        local showCount = item_data.count
                        if item_data.count and tonumber(item_data.count) ~= 0 then
                            --print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
                            showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId))
                            DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
                        else
                            DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
                        end
                        if showCount > 0 then
                            show[1] = {}
                            show[1].rewardtype = 4
                            show[1].dbId = item_data.dbId
                            show[1].id = item_data.itemId
                            if item_data.item_type == 3 then
                                show[1].num = #data.items
                            else
                                show[1].num = showCount
                            end
                        end
                    end
            
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK})
                    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
--					if self.buyType == 4 then
--						self.localData.callBack()
--					else
					self.localData.numLabel:setString(data.count)
--					end
					--self.localData.yuanBaoLabel:setString(gameUser.getIngot())
					self.localData.sCount = data.count
					self:reFreshLastBuyCount()
                    
					if self._isUpdate then
						ShowRewardNode:create(show,self._callFunc())
					else
						ShowRewardNode:create(show)
					end
                end
            elseif tonumber(data.result) == 5501 then ----全服次数没了                
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败!")
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调        
        loadingParent = self,        
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function BuyExpByIngotPopLayer1:httpToBuyExpItems()
    local _countValue = tonumber(self._createNumLabel:getString() or 0)
    print(self.itemId, _countValue)
    ClientHttp:httpHeroBuyExpItems(self,function(data)
        -- dump(data)

        gameUser.setIngot(data.ingot)
		gameUser.settaoFaLingSum(data.taoFaLingSum)
        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
		if self.buyType == 3 then
			gameUser.settaoFaLingSum(data.taoFaLingSum)
		elseif self.buyType == 1 then
			gameUser.setExpItemSurplusSum(data.expItemSurplusSum)
		end
        if isExpItem(self.itemId) then
            self:reFreshHttpData(data)
            self:reFreshLastBuyCount()
            self:setMaxNumber()
            self:setMakeNumberLabel(1)
        else
            if data.items and #data.items ~= 0 then
                for i=1,#data.items do
                    local item_data = data.items[i]
                    local showCount = item_data.count
                    if item_data.count and tonumber(item_data.count) ~= 0 then
                        --print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
                        showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId));
                        DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
                    else
                        DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
                    end
                end
            end
			if self.buyType == 1 then
				if self.itemId ~= 2008 then
					self.parentlayer:refreshBuyLabel()
				else
					 self:reFreshHttpData(data)
					self:reFreshLastBuyCount()
					self:setMaxNumber()
					self:setMakeNumberLabel(1)
				end
			elseif self.buyType == 3 then
				self.parentlayer:freshTopInfo()
			end
			self:reFreshLastBuyCount()
        end

        local _rewardTable = {}
        _rewardTable[1] = {}
        _rewardTable[1].rewardtype = 4
        if self.buyType == 3 then
            _rewardTable[1].num = _countValue*self.localData.num
        elseif self.buyType == 1 then
            _rewardTable[1].num = _countValue
        end  
        _rewardTable[1].id = self.itemId
        ShowRewardNode:create(_rewardTable)
		if self._callFunc then
			self._callFunc()
		end

    end,{itemId=self.itemId,count= self.localData.num == nil and _countValue or _countValue*self.localData.num},function(data)
        if data~=nil and data.result~=nil and tonumber(data.result) == 5502 then
            self:goToRechargeVIP()
        end
    end)
end

function BuyExpByIngotPopLayer1:reFreshHttpData(data)
    --修改消耗品的数量，为0删除
    for i=1,#data["items"] do
        local _dbid = data.items[i].dbId
        if data.items[i].count and tonumber(data.items[i].count)>0 then
            DBTableItem.updateCount(gameUser.getUserId(),data.items[i],_dbid)
        else
            DBTableItem.deleteData(gameUser.getUserId(),_dbid)
        end
    end

    self.parentlayer:getDynamicDBData()      
    self.parentlayer:setCurrentItemData()
    RedPointManage:reFreshDynamicItemData()
    self.parentlayer:reFreshLeftLayer()
end

function BuyExpByIngotPopLayer1:reFreshLastBuyCount()
    if isExpItem(self.itemId) == false then

		self.lastCount = "无限"
		self.lastBuyCountLabel:setString(self.lastCount)
        
    else
        local _expItemSurplusSum = gameUser.getExpItemSurplusSum() or {}
        local _itemIndex = tonumber(self.itemId) - 2006

        self.lastCount = _expItemSurplusSum[_itemIndex] or 0
        self.lastBuyCountLabel:setString(self.lastCount)
    end
	if self.buyType == 3 then
		local count = gameData.getDataFromCSV("VipInfo",{id = 51})["vip"..gameUser.getVip()]
		self.lastCount = count - gameUser.gettaoFaLingSum()
	elseif self.buyType == 2 or self.buyType == 4 then
		self.lastCount = self.localData.sCount
	end
	self.lastBuyCountLabel:setString(self.lastCount)
    self:setMaxNumber()
end

function BuyExpByIngotPopLayer1:setStaticBuyItems()
    self.buyItemStaticData = {}
    local _itemData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
    self.buyItemStaticData = _itemData[tostring(self.itemId)] or {}
end

function BuyExpByIngotPopLayer1:getTextColor(_str)
local _color = {
    huanghese = cc.c4b(237, 232, 193,255)
    ,shenhese = cc.c4b(70,34,34,255)
    ,lanse = cc.c4b(26,158,207,255)
    ,lvse = cc.c4b(104,157,0,255)
    ,chenghongse = cc.c4b(231,87,0,255),
}
return _color[tostring(_str)]
end

function BuyExpByIngotPopLayer1:create(_itemid,_layer,isUpdate,callFunc)
local _layer = self.new(_itemid,_layer,isUpdate,callFunc)
return _layer
end

return BuyExpByIngotPopLayer1