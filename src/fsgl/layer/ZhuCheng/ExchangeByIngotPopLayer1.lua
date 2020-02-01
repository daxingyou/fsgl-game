--xingchen
local ExchangeByIngotPopLayer1 = class("ExchangeByIngotPopLayer1",function()
	return XTHDPopLayer:create()
	end)

function ExchangeByIngotPopLayer1:ctor(_type,_parentLayer)
	self._type = _type or nil
    self._oneIngotlabel = nil
    self._tenIngotlabel = nil
    self._minNumberLabel = nil
    self._titleSpr = nil
    self.popNode = nil
    self.parentLayer = _parentLayer or nil

    self._exchangeData = {}             --兑换数据
    self.vipExchangeData = {}           --VIP数据
    self.exchangeListData = {}         --兑换列表数据
    self.exchangedCount = 0            --已兑换数量 
    self.recordListData = {}            --兑换记录

    self.startExchangeData = {}

    self._distance = 135
    self.tableViewSize = cc.size(520,159)
    self._fontSize = 20

    

	if not self._type then
        self:removeFromParent()
		return
	end
    self.tableName = "YuanbaoExchange"
    self._surpluscount = 0
    local _id = 15
    if self._type == "silver" then
        _id = 15
        self.tableName = "YuanbaoExchange"
        self._surpluscount = gameUser.getGoldSurplusExchangeCount()
    elseif self._type == "feicui" then
        _id = 16
        self.tableName = "EmeraldExchange"
        self._surpluscount = gameUser.getFeicuiSurplusExchangeCount()
    end
    self:getVipExchangeData(_id)
	self:init()
end

function ExchangeByIngotPopLayer1:onCleanup()
    XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TASKLIST })
end

function ExchangeByIngotPopLayer1:init()
    -- print("8431>>>ExchangeByIngotPopLayer1:init()>")
    
    self:getExchangeData()
    -- if self._exchangeData == nil or next(self._exchangeData)==nil then
    --     XTHDTOAST("今日兑换次数已达上限")
    --     self:hide({music = false})
    --     return
    -- end

    local _shadowPosY = 141
    local _exchangeData_ = {}
    if self._exchangeData == nil or next(self._exchangeData)==nil then
        _exchangeData_ = self.startExchangeData
    else
        _exchangeData_ = self._exchangeData
    end
	local _popBgSprite = cc.Sprite:create("res/image/common/exchangeByIngot_bg.png")
	local popNode = XTHDPushButton:createWithParams({
                        normalNode = _popBgSprite
                    })
    popNode:setTouchEndedCallback(function ()
        print("点到背景了")
    end)
    popNode:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2+90)  -- 
    self:getContainerLayer():addChild(popNode)
    self.popNode = popNode

    self.recordLayer = ccui.Scale9Sprite:create(cc.rect(25,25,1,1),"res/image/common/exchange_scalebox.png")
    self.recordLayer:setContentSize(cc.size(520,175))
    self.recordLayer:setAnchorPoint(cc.p(0.5,1))
    self.recordLayer:setPosition(cc.p(self:getContentSize().width / 2,popNode:getBoundingBox().y - 5))
    self:getContainerLayer():addChild(self.recordLayer)
    self.recordLayer:setVisible(false)

    --关闭按钮
    local _closeBtn = XTHD.createBtnClose(function()
        self:hide()
    end)
    _closeBtn:setPosition(cc.p(popNode:getContentSize().width-22,popNode:getContentSize().height-15))
    popNode:addChild(_closeBtn,5)

    --imagePath
    local _exchangeNumberImgPath = "res/image/common/header_gold.png"
    local _titleImgpath = "res/image/common/exchangeCoin_spr.png"
    local _titleLabel_img = "res/image/common/exchangeCoin_label.png"
    local _titleStr = LANGUAGE_KEY_GOLD----"银两"
    if self._type == "silver" then
        _exchangeNumberImgPath = "res/image/common/header_gold.png"
        _titleImgpath = "res/image/common/exchangeCoin_spr.png"
        _titleLabel_img = "res/image/common/exchangeCoin_label.png"
        _titleStr = LANGUAGE_KEY_GOLD----"银两"
    elseif  self._type == "feicui" then
        _exchangeNumberImgPath = "res/image/common/header_feicui.png"
        _titleImgpath = "res/image/common/exchangeFeicui_spr.png"
        _titleLabel_img = "res/image/common/exchangeFeicui_label.png"
        _titleStr = LANGUAGE_KEY_JADE----- "翡翠"
    end

    --titleImage 
    local _titleSprite =  cc.Sprite:create(_titleImgpath)
    self._titleSpr = _titleSprite
    _titleSprite:setAnchorPoint(cc.p(0,1))
    _titleSprite:setPosition(cc.p(57,popNode:getContentSize().height - 28))
    popNode:addChild(_titleSprite)
    local _titleLabel_sp = cc.Sprite:create(_titleLabel_img)
    _titleLabel_sp:setAnchorPoint(cc.p(0,1))
    _titleLabel_sp:setPosition(cc.p(_titleSprite:getBoundingBox().x + _titleSprite:getBoundingBox().width + 10,_titleSprite:getBoundingBox().y + _titleSprite:getBoundingBox().height - 8))
    popNode:addChild(_titleLabel_sp)
    --剩余兑换次数
    local _lastExchangelabel = XTHDLabel:create("("..LANGUAGE_TIPS_WORDS133..":",self._fontSize)----(今日剩余兑换次数:",self._fontSize)
    _lastExchangelabel:setColor(self:getTextColor("hese"))
    _lastExchangelabel:setAnchorPoint(cc.p(0,0))
    _lastExchangelabel:setPosition(cc.p(_titleLabel_sp:getBoundingBox().x+_titleLabel_sp:getBoundingBox().width + 6,_titleLabel_sp:getBoundingBox().y))
    popNode:addChild(_lastExchangelabel)

    self._lastExchangeNumber = XTHDLabel:create(self._surpluscount,self._fontSize+2)
    self._lastExchangeNumber:setColor(self:getTextColor("lanse"))
    self._lastExchangeNumber:setAnchorPoint(cc.p(0,0))
    self._lastExchangeNumber:setPosition(cc.p(_lastExchangelabel:getBoundingBox().x + _lastExchangelabel:getBoundingBox().width,_lastExchangelabel:getBoundingBox().y))
    popNode:addChild(self._lastExchangeNumber)

    local _otherBraket = XTHDLabel:create(")",self._fontSize)
    _otherBraket:setColor(self:getTextColor("hese"))
    _otherBraket:setName("otherBraket")
    _otherBraket:setAnchorPoint(cc.p(0,0))
    _otherBraket:setPosition(cc.p(self._lastExchangeNumber:getBoundingBox().x+self._lastExchangeNumber:getBoundingBox().width,self._lastExchangeNumber:getBoundingBox().y))
    popNode:addChild(_otherBraket)

    --说明
    local exchange_desc = XTHDLabel:create(LANGUAGE_TIPS_WORDS134 .. _titleStr,self._fontSize-2)----"用少量元宝换取大量"
    exchange_desc:setColor(self:getTextColor("hese"))
    exchange_desc:setAnchorPoint(cc.p(0,0))
    exchange_desc:setPosition(cc.p(_titleLabel_sp:getBoundingBox().x + 2,_titleSprite:getBoundingBox().y + 8))
    popNode:addChild(exchange_desc)

    --兑换1次
    local _exchangeOneBtn = XTHD.createCommonButton({
        btnSize = cc.size(165,46),
        isScrollView = false,
        endCallback  = function()
                -- if self._exchangeData == nil or next(self._exchangeData)==nil then
                --     XTHDTOAST("今日兑换次数已达上限")
                --     self:hide({music = true})
                --     return
                -- end
                -- if tonumber(self._surpluscount)<1 then
                --     self:toRechargeVIP()
                --     return
                -- end
                local _hadIngot = gameUser.getIngot()
                local _needIngot = self._exchangeData and self._exchangeData["yuanbao"] or 0
                if tonumber(_hadIngot)<tonumber(_needIngot) then
                    local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=1})--byhuangjunjian 获得资源共用方法（1.元宝2.体力3.银两4.翡翠）
                    self:addChild(StoredValue)
                    return
                end
                self:httpToExchange(1)
            end,--
    })
    _exchangeOneBtn:setLabel(self:getButtonSpr(1))
    self:setButtonText(_exchangeOneBtn)
    _exchangeOneBtn:setAnchorPoint(cc.p(0.5,0))
    _exchangeOneBtn:setPosition(cc.p(self._distance,32))
    popNode:addChild(_exchangeOneBtn)
    self.exchangeOneBtn = _exchangeOneBtn

    --兑换10次
    local _exchangeTenBtn = XTHD.createCommonButton({
        btnSize      = cc.size(165,46),
        isScrollView = false,
        endCallback  = function()
                -- if self._exchangeData == nil or next(self._exchangeData)==nil then
                --     XTHDTOAST("今日兑换次数已达上限")
                --     self:hide({music = true})
                --     return
                -- end
                local _exchangeMoreDialog = requires("src/fsgl/layer/ZhuCheng/ExchangeMoreDialog1.lua"):create(self,55)
                self:addChild(_exchangeMoreDialog)
                -- if self.parentLayer~=nil then
                --     self.parentLayer:addChild(_exchangeMoreDialog)
                -- else
                --     cc.Director:getInstance():getRunningScene():addChild(_exchangeMoreDialog)
                -- end
                
            end,--
    })
    _exchangeTenBtn:setLabel(self:getButtonSpr(10))
    self:setButtonText(_exchangeTenBtn)
    _exchangeTenBtn:setAnchorPoint(cc.p(0.5,0))
    _exchangeTenBtn:setPosition(cc.p(popNode:getContentSize().width - self._distance,_exchangeOneBtn:getPositionY()))
    popNode:addChild(_exchangeTenBtn)
    self.exchangeTenBtn = _exchangeTenBtn
    self:reFreshExchangeButton()


    local _oneIngotSpr = cc.Sprite:create("res/image/common/common_gold.png")
    _oneIngotSpr:setName("oneIngotSpr")
    _oneIngotSpr:setAnchorPoint(cc.p(0.5,0.5))
    _oneIngotSpr:setPosition(cc.p(0.5,_shadowPosY))
    popNode:addChild(_oneIngotSpr)
    self._oneIngotlabel = getCommonYellowBMFontLabel(_exchangeData_["yuanbao"])
    self._oneIngotlabel:setAnchorPoint(cc.p(0,0.5))
    self._oneIngotlabel:setPosition(cc.p(0,_oneIngotSpr:getPositionY()-7))
    popNode:addChild(self._oneIngotlabel)

    local _oneItemSpr = cc.Sprite:create(_exchangeNumberImgPath)
    _oneItemSpr:setName("oneItemSpr")
    _oneItemSpr:setAnchorPoint(cc.p(0.5,0.5))
    _oneItemSpr:setPosition(cc.p(0,_shadowPosY))
    popNode:addChild(_oneItemSpr)

    self._minNumberLabel = getCommonWhiteBMFontLabel(getHugeNumberWithLongNumber(_exchangeData_["mix"],100000))
    self._minNumberLabel:setAnchorPoint(cc.p(0,0.5))
    self._minNumberLabel:setPosition(cc.p(0,_oneItemSpr:getPositionY()-7))
    popNode:addChild(self._minNumberLabel)

    local exchange_arrow = cc.Sprite:create("res/image/common/exchange_arrow.png")
    exchange_arrow:setPosition(cc.p(popNode:getContentSize().width/2,_shadowPosY))
    popNode:addChild(exchange_arrow)

    self:reFreshCostIngot()

    self:createRecordLayer()

    self:show()
end

function ExchangeByIngotPopLayer1:createRecordLayer()
    if self.recordLayer== nil then
        return
    end
    -- self.recordLayer:setVisible(true)
    self.recordLayer:setPositionY(self.popNode:getBoundingBox().x - 5)

    self._tableView = cc.TableView:create(self.tableViewSize)
	TableViewPlug.init(self._tableView)
    self._tableView:setPosition(0,8)
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) 
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setDelegate()
    self.recordLayer:addChild(self._tableView)
    local _exchangeNumberImgPath = "res/image/common/header_gold.png"
    if self._type == "silver" then
        _exchangeNumberImgPath = "res/image/common/header_gold.png"
    elseif  self._type == "feicui" then
        _exchangeNumberImgPath = "res/image/common/header_feicui.png"
    end

    local _cellSize = cc.size(self.tableViewSize.width,53)

	self._tableView.getCellNumbers = function (table_view)
       return #self.recordListData
    end
    self._tableView:registerScriptHandler(self._tableView.getCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	
	self._tableView.getCellSize = function (table_view,idx)
        return _cellSize.width,_cellSize.height
    end
    self._tableView:registerScriptHandler(self._tableView.getCellSize,cc.TABLECELL_SIZE_FOR_INDEX)

    self._tableView:registerScriptHandler(
        function(table_view,idx)
            local cell = table_view:dequeueCell()
            if cell then
                cell:removeAllChildren()
            else
                cell = cc.TableViewCell:create()
            end

            local _labelUse = XTHDLabel:create(LANGUAGE_VERBS.use,self._fontSize)---"使用"
            _labelUse:setColor(self:getTextColor("chenghuangse"))
            _labelUse:setAnchorPoint(cc.p(0,0))
            _labelUse:setPosition(cc.p(40,10))
            cell:addChild(_labelUse)

            local _labelHarvest = XTHDLabel:create(LANGUAGE_VERBS.get,self._fontSize)-----"获得"
            _labelHarvest:setColor(self:getTextColor("chenghuangse"))
            _labelHarvest:setAnchorPoint(cc.p(0,0))
            _labelHarvest:setPosition(cc.p(200,_labelUse:getBoundingBox().y))
            cell:addChild(_labelHarvest)

            local _middlePosX = (_labelHarvest:getBoundingBox().x+_labelUse:getBoundingBox().x+_labelUse:getBoundingBox().width)/2

            local _costSpr = cc.Sprite:create("res/image/common/common_gold.png")
            _costSpr:setAnchorPoint(cc.p(0.5,0))
            
            _costSpr:setPosition(cc.p(_labelUse:getBoundingBox().x + _labelUse:getBoundingBox().width +5,_labelUse:getBoundingBox().y-8))
            cell:addChild(_costSpr)

            local _costLabel = getCommonYellowBMFontLabel(self.recordListData[tonumber(idx + 1)].costIngot or 0)
            _costLabel:setScale(1.32)
            _costLabel:setAnchorPoint(cc.p(0,0))
            _costSpr:setPositionX(_middlePosX-_costLabel:getBoundingBox().width/2)
            _costLabel:setPosition(cc.p(_costSpr:getBoundingBox().x + _costSpr:getBoundingBox().width +5,_labelUse:getBoundingBox().y-18))
            cell:addChild(_costLabel)

            local _harvestSpr = cc.Sprite:create(_exchangeNumberImgPath)
            _harvestSpr:setAnchorPoint(cc.p(0,0))
            _harvestSpr:setPosition(cc.p(_labelHarvest:getBoundingBox().x + _labelHarvest:getBoundingBox().width +10,_labelHarvest:getBoundingBox().y-8))
            cell:addChild(_harvestSpr)

            local _harvestLabel = getCommonWhiteBMFontLabel(self.recordListData[tonumber(idx + 1)].harvestNum or 0)
            _harvestLabel:setScale(1.3)
            _harvestLabel:setAnchorPoint(cc.p(0,0))
            _harvestLabel:setPosition(cc.p(_harvestSpr:getBoundingBox().x + _harvestSpr:getBoundingBox().width +5,_labelHarvest:getBoundingBox().y-19))
            cell:addChild(_harvestLabel)

            local _lineSpr = cc.Sprite:create("res/image/common/exchange_line.png")
            _lineSpr:setPosition(cc.p(_cellSize.width/2,_labelUse:getBoundingBox().y - 7))
            cell:addChild(_lineSpr)
            if tonumber(self.recordListData[tonumber(idx + 1)].rate)>1 then
                local _rateSp = cc.Sprite:create("res/image/common/exchange_burstsp.png")
                _rateSp:setAnchorPoint(cc.p(0,0))
                _rateSp:setPosition(cc.p(400,_labelUse:getBoundingBox().y))
                cell:addChild(_rateSp)
                local _ratelabel = XTHDLabel:create("x" .. self.recordListData[tonumber(idx + 1)].rate,self._fontSize)
                _ratelabel:setAnchorPoint(cc.p(0,0))
                _ratelabel:setPosition(cc.p(_rateSp:getBoundingBox().x+_rateSp:getBoundingBox().width + 5 ,_labelUse:getBoundingBox().y))
                cell:addChild(_ratelabel)
            end
            return cell
        end
    ,cc.TABLECELL_SIZE_AT_INDEX)

end

function ExchangeByIngotPopLayer1:showRecordLayer()
    if self.recordLayer:isVisible() == true then
        return
    end
    
    -- self.popNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(0,(self.recordLayer:getContentSize().height + 5)/2)),cc.CallFunc:create(function()
            self.popNode:setPositionY(self:getContentSize().height / 2 + (self.recordLayer:getContentSize().height + 5)/2)
            self.recordLayer:setPositionY(self.popNode:getBoundingBox().y - 5)
            self.recordLayer:setVisible(true)
        -- end)))
    
end

function ExchangeByIngotPopLayer1:addRecordList(_data)
    if _data == nil or next(_data)==nil then
        return
    end
    for i=1,#_data do
        local _recordData = {}
        _recordData.costIngot = _data[i].cost or 0
        _recordData.harvestNum = _data[i].money or 0
        _recordData.rate = _data[i].rate or 0
        self.recordListData[#self.recordListData + 1] = _recordData
    end
    
end

function ExchangeByIngotPopLayer1:getButtonNode(_path)
    local _node = ccui.Scale9Sprite:create(cc.rect(50,0,30,51),_path)
    _node:setContentSize(cc.size(160,51))
    return _node
end

function ExchangeByIngotPopLayer1:setButtonText(_btn)
    if _btn==nil then
        return
    end
    local _label1 = XTHDLabel:create(LANGUAGE_VERBS.exchange,22)
    _label1:setAnchorPoint(cc.p(1,0.5))
    _label1:enableShadow(XTHD.resource.btntextcolor.green,cc.size(0.4,-0.4),0.4)
    _label1:setColor(XTHD.resource.btntextcolor.green)
    _label1:setPosition(cc.p(_btn:getContentSize().width/2-10,_btn:getContentSize().height/2))
    _btn:addChild(_label1)

    local _label2 = XTHDLabel:create(LANGUAGE_KEY_TIMES,22)
    _label2:setAnchorPoint(cc.p(0,0.5))
    _label2:setColor(XTHD.resource.btntextcolor.green)
    _label2:enableShadow(XTHD.resource.btntextcolor.green,cc.size(0.4,-0.4),0.4)
    _label2:setPosition(cc.p(_btn:getContentSize().width/2+30,_btn:getContentSize().height/2))
    _btn:addChild(_label2)
    _btn:getLabel():setPosition(cc.p(_btn:getContentSize().width/2+10,_btn:getContentSize().height/2-7))
end

function ExchangeByIngotPopLayer1:getButtonSpr(_num)
    local _number = getCommonWhiteBMFontLabel(_num)
    _number:setScale(1.1)
    return _number
end

--兑换网络请求
function ExchangeByIngotPopLayer1:httpToExchange(_num)
    self._titleSpr:stopAllActions()
    ClientHttp:requestAsyncInGameWithParams({
        modules = self._type .. "Exchange?",
        params = {count= _num},--"http://192.168.11.210:8080/game/petAction.do?method=allPet",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                local _subValue = 0
                local _nameStr = LANGUAGE_KEY_GOLD----"银两"
                local _oldIngot = tonumber(gameUser.getIngot())
                local _newIngot = tonumber(data.ingot)
                local _subIngot = _newIngot - _oldIngot
                local _particleStr = "luojinbi"
                local _effectStr = "collect_gold.mp3"
                if self._type == "silver" then
                    _nameStr = "银两"
                    local _oldGold  = gameUser.getGold()
                    local _currentGold = data.gold
                    _subValue = tonumber(_currentGold) - tonumber(_oldGold)
                    gameUser.setGold(data.gold)
                    gameUser.setGoldSurplusExchangeCount(data["silverSurplusSum"])
                    self._surpluscount = data["silverSurplusSum"]
                    _particleStr = "luojinbi"
                    _effectStr = "collect_gold.mp3"
                elseif self._type == "feicui" then
                    _nameStr = LANGUAGE_KEY_JADE ------"翡翠"
                    local _oldFeicui  = gameUser.getFeicui()
                    local _currentFeicui = data.feicui
                    _subValue = tonumber(_currentFeicui) - tonumber(_oldFeicui)
                    gameUser.setFeicui(data.feicui)
                    gameUser.setFeicuiSurplusExchangeCount(data["feicuiSurplusSum"])
                    self._surpluscount = data["feicuiSurplusSum"]
                    _particleStr = "luobaoshi"
                    _effectStr = "collect_jedct.mp3"
                end
                -- self._titleSpr:runAction(cc.Repeat:create(cc.Sequence:create(cc.CallFunc:create(function()
                        musicManager.playEffect("res/sound/" .. _effectStr);
                        -- local emitter = cc.ParticleSystemQuad:create("res/image/homecity/frames/" .. _particleStr) 
                        local emitter =sp.SkeletonAnimation:create( "res/image/homecity/frames/" .. _particleStr .. ".json", "res/image/homecity/frames/" .. _particleStr .. ".atlas", 1.0)
                        -- emitter:setPositionType(cc.POSITION_TYPE_RELATIVE)
                        -- emitter:setAutoRemoveOnFinish(true)
                        emitter:setAnimation(0,_particleStr,false)
                        emitter:setPosition(self._titleSpr:getContentSize().width/2,self._titleSpr:getContentSize().height/2)
                        self._titleSpr:addChild(emitter)
                    -- end),cc.DelayTime:create(0.1)),tonumber(_num)))
                
                local newRecordTable = {}
                if data.list~=nil then
                    for i=1,#data.list do
                        newRecordTable[i] = data.list[i]
                    end
                end
                local _oldRecordNumber = #self.recordListData
                self:addRecordList(newRecordTable)
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_COSTMONEY_STATE})
                gameUser.setIngot(data.ingot)
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
                self:getExchangeData()
                self:refreshData()
                self:showRecordLayer()
                self:stopAllActions()
                self._tableView:reloadDataAndScrollToCurrentCell()
                -- 
                -- print("8431>>>#self.recordListData>>>" .. #self.recordListData)
                local _animationTable = {}
                for i=_oldRecordNumber,#self.recordListData-1 do
                    _animationTable[#_animationTable + 1] = cc.CallFunc:create(function()
                            local _index = i-2
                            if _index<0 then
                                _index = 0
                            end
                            self._tableView:scrollToCell(_index,true)
                        end)
                    _animationTable[#_animationTable + 1] = cc.DelayTime:create(0.4)
                    _animationTable[#_animationTable + 1] = cc.CallFunc:create(function()
                            
                        end)
                end
                self:runAction(cc.Sequence:create(_animationTable))
                -- self._tableView:scrollToLastCell(true)
                -- if _subValue~= 0 then
                --     XTHDTOAST("你获得了" .. _subValue .. _nameStr)
                -- end
            elseif tonumber(data.result) == 5300 then
                if self._exchangeData~=nil and next(self._exchangeData)~=nil then
                    self:toRechargeVIP()
                else
                    XTHDTOAST(LANGUAGE_KEY_HERO_TEXT.exchangeCountLimit)
                    self:refreshData()
                end
            else
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
                self:refreshData()
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

--获取vip兑换数据
function ExchangeByIngotPopLayer1:getVipExchangeData(_id)
    self.vipExchangeData = gameData.getDataFromCSV("VipInfo",{id = _id})
end
--获取兑换数据
function ExchangeByIngotPopLayer1:getExchangeData()
    self._exchangeData = {}
    self.exchangeListData = {}
    local _table = gameData.getDataFromCSV(self.tableName)
    self.exchangeListData = clone(_table)
    -- print("841>>>self.exchangeListData>>" .. zctech.print_table(self.exchangeListData))
    local _nextTimes = tonumber(self.vipExchangeData["vip" .. gameUser.getVip()]) - self._surpluscount + 1
    _nextTimes = _nextTimes > 0 and _nextTimes or 1
    self._exchangeData = _table[tonumber(_nextTimes)]
    self.exchangedCount = _nextTimes - 1    
    self.startExchangeData = _table[1] or {}
end
--前往VIP
function ExchangeByIngotPopLayer1:toRechargeVIP()
    --购买技能文字
    local _labelStr = LANGUAGE_TIPS_WORDS135 ------"兑换次数不足，是否前往充值VIP增加次数？"
    local _buyDialog = XTHDConfirmDialog:createWithParams({
            msg = _labelStr,
            rightCallback = function()
                self:goToRechargeVIP()
                self:hide({music = true})
            end
        })
    self:addChild(_buyDialog)
end
--跳转到充值
function ExchangeByIngotPopLayer1:goToRechargeVIP()
    -- print("跳转去充值VIP")
    if self.parentLayer~=nil then
        XTHD.createRechargeVipLayer(self.parentLayer)
    else
        XTHD.createRechargeVipLayer(cc.Director:getInstance():getRunningScene() )
    end
    
end

--刷新银两数量
function ExchangeByIngotPopLayer1:reFreshCostIngot()
    local _exchangeData_ = {}
    if self._exchangeData == nil or next(self._exchangeData)==nil then
        _exchangeData_ = self.startExchangeData
    else
        _exchangeData_ = self._exchangeData
    end

    local _oneIngotSpr = self.popNode:getChildByName("oneIngotSpr")
    local _oneItemSpr = self.popNode:getChildByName("oneItemSpr")
    local _leftX = self._distance
    local _rightX = self.popNode:getContentSize().width - self._distance

    self._oneIngotlabel:setString(_exchangeData_["yuanbao"])
    _oneIngotSpr:setPositionX(_leftX - self._oneIngotlabel:getBoundingBox().width/2)
    self._oneIngotlabel:setPositionX(_oneIngotSpr:getBoundingBox().x + _oneIngotSpr:getBoundingBox().width)

    self._minNumberLabel:setString(_exchangeData_["mix"])
    _oneItemSpr:setPositionX(_rightX - self._minNumberLabel:getBoundingBox().width/2)
    self._minNumberLabel:setPositionX(_oneItemSpr:getBoundingBox().x + _oneItemSpr:getBoundingBox().width)
end
--刷新剩余次数
function ExchangeByIngotPopLayer1:reFreshLastCount()
    self._lastExchangeNumber:setString(self._surpluscount)
end
--刷新按钮
function ExchangeByIngotPopLayer1:reFreshExchangeButton()
    if tonumber(self._surpluscount) < 2 then
        self.exchangeOneBtn:setPositionX(self.popNode:getContentSize().width/2)
        self.exchangeTenBtn:setVisible(false)
    elseif tonumber(self._surpluscount)>9 then
        self.exchangeTenBtn:setVisible(true)
        self.exchangeTenBtn:setPositionX(self.popNode:getContentSize().width - self._distance)
        self.exchangeOneBtn:setPositionX(self._distance)
    else
        local _numberStr = tonumber(self._surpluscount)
        self.exchangeTenBtn:setVisible(true)
        self.exchangeOneBtn:setPositionX(self._distance)
        self.exchangeTenBtn:setPositionX(self.popNode:getContentSize().width - self._distance)
        self.exchangeTenBtn:getLabel():setString(_numberStr)
    end
end

--兑换后刷新数据
function ExchangeByIngotPopLayer1:refreshData()
    self:reFreshLastCount()
    self:reFreshCostIngot()
    self:reFreshExchangeButton()
    if self._exchangeData == nil or next(self._exchangeData)==nil then
        self.exchangeOneBtn:setVisible(false)
        self.exchangeTenBtn:setVisible(false)
        local _limitPrompt = XTHDLabel:create(LANGUAGE_KEY_HERO_TEXT.exchangeCountLimit,self._fontSize)
        _limitPrompt:setColor(self:getTextColor("hese"))
        _limitPrompt:setAnchorPoint(cc.p(0.5,0.5))
        _limitPrompt:setPosition(cc.p(self.popNode:getContentSize().width/2,self.exchangeOneBtn:getBoundingBox().y + self.exchangeOneBtn:getBoundingBox().height/2))
        self.popNode:addChild(_limitPrompt)
    end
end

function ExchangeByIngotPopLayer1:getTextColor(_str)
    local _color = {
        hese = cc.c4b(67,28,4,255)
        ,chenghuangse = cc.c4b(255,186,0,255)
        ,lanse = cc.c4b(26,158,207,255)
    }
    return _color[tostring(_str)]
end

--传入itemid
function ExchangeByIngotPopLayer1:create(_type,_parentLayer)
    XTHDTOAST(LANGUAGE_TIPS_WORDS11)
    do return end
	local _layer = self.new(_type,_parentLayer)
	return _layer
end
return ExchangeByIngotPopLayer1