local RiChangRenWuDiceResultPopLayer = class("RiChangRenWuDiceResultPopLayer",function()
		-- return XTHDPopLayer:create()
        return XTHDSprite:createWithTexture(nil,cc.rect(0,0,winWidth,137))
	end)

function RiChangRenWuDiceResultPopLayer:ctor(data,dicelayer)
	self.dicelayer = dicelayer
	self.data = data
	self._fontSize = 20
	self.skyNumber = 0

	self.titleBg = nil
	self.lastFreeCount = nil
	self.lastFreeCountTitle = nil
    self.sureBtn = nil
	self.continueBtn = nil
	self.staticItemData = {}
	self.diceItemArr = {}
	self.diceRewardData = {}

    self:setOpacity(0)

	self:setStaticItemData()
	self:setStaticRewardData()
	self:setSkyNumber()
	self:initLayer()
end

function RiChangRenWuDiceResultPopLayer:initLayer()

    --titleLabel
    local _titlePosY = self:getContentSize().height-20
    local _titleNameLabel = XTHDLabel:create("0",self._fontSize)
    _titleNameLabel:setName("titleNameLabel")
    _titleNameLabel:enableShadow(cc.c4b(255,255,255,255),cc.size(0.4,-0.4),0.4)
    _titleNameLabel:setColor(cc.c4b(255,255,255,255))
    _titleNameLabel:setPosition(cc.p(self:getContentSize().width/2,_titlePosY))
    self:addChild(_titleNameLabel)
    local _leftSp = cc.Sprite:create("res/image/daily_task/destiny_dice/dicetitle_left.png")
    _leftSp:setAnchorPoint(cc.p(1,0.5))
    _leftSp:setPosition(cc.p(self:getContentSize().width/2-55,_titlePosY))
    self:addChild(_leftSp)
    local _rightSp = cc.Sprite:create("res/image/daily_task/destiny_dice/dicetitle_right.png")
    _rightSp:setAnchorPoint(cc.p(0,0.5))
    _rightSp:setPosition(cc.p(self:getContentSize().width/2+55,_titlePosY))
    self:addChild(_rightSp)

    self:refreshTitleName()

    local _btnPosY = 9
    --确认
    local _sureBtn = XTHD.createCommonButton({
            btnColor = "write_1",
            btnSize = cc.size(200,49),
            isScrollView = false,
            text = LANGUAGE_BTN_KEY.atonceGetReward,
            endCallback = function()
                self:httpToGetReward()
            end
        })
        _sureBtn:setScale(0.8)
    self.sureBtn = _sureBtn
    _sureBtn:setAnchorPoint(cc.p(0.5,0))
    _sureBtn:setPosition(cc.p(self:getContentSize().width/3-45,_btnPosY-5))
    self:addChild(_sureBtn)

    --继续
    local _continueBtn = XTHD.createCommonButton({
            btnColor = "write",
            btnSize = cc.size(280,49),
            isScrollView = false,
            text = LANGUAGE_BTN_KEY.diceAgain,
            endCallback = function()
                self.continueBtn:setEnable(false)
                self:httpToDiceAgain()
            end
        })
        _continueBtn:setScale(0.8)
    self.continueBtn = _continueBtn
    _continueBtn:setAnchorPoint(cc.p(0.5,0))
    _continueBtn:setPosition(cc.p(self:getContentSize().width/3*2-5,_btnPosY-5))
    self:addChild(_continueBtn)

    --剩余免费次数
    self:refreshLastCount()

    self:createReward()
    self:refreshBtnState()
end

function RiChangRenWuDiceResultPopLayer:httpToGetReward()    
    YinDaoMarg:getInstance():guideTouchEnd() 
    
	ClientHttp:requestAsyncInGameWithParams({
        modules = "destinyReward?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                -- XTHD.dispatchEvent({name = "ShowDiceBtn"})
                self.dicelayer:closeDiceResultLayer()
                self:reFreshHttpData(data)
                self:setRewardShow(self.diceRewardData[tonumber(self.skyNumber)+1])
                
                -- self:hide({music = true})
                -- self:removeFromParent()
                self.dicelayer:closeDiceResultLayer()
            else
                XTHDTOAST(data.msg)
            end
        end,--成功回调
        targetNeedsToRetain = button,
        failedCallback = function()        
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function RiChangRenWuDiceResultPopLayer:httpToDiceAgain()
    YinDaoMarg:getInstance():guideTouchEnd() 
    
	ClientHttp:requestAsyncInGameWithParams({
        modules = "destinyAgain?",
        successCallback = function(data)
            if tonumber(data.result) == 0 then
                YinDaoMarg:getInstance():getACover(self.dicelayer)

            	self.data.destinyAgainCount = data.destinyAgainCount
            	self.data.destiny = data.destiny
                self.data.cost = data.cost

            	for i=1,#data["property"] do
			        local pro_data = string.split( data["property"][i],',')
			        gameUser.updateDataById(pro_data[1],pro_data[2])
			    end
                local _oldSkyNumber = self.skyNumber
            	self:setSkyNumber()
            	self:refreshLastCount()
                self.dicelayer:playDiceAnimation(_oldSkyNumber,self.data)
                performWithDelay(self,function()
                    self:refreshTitleName()
                    self:createReward()
                    self:refreshBtnState()

                    YinDaoMarg:getInstance():removeCover(self.dicelayer)
                    YinDaoMarg:getInstance():doNextGuide()
                    self.continueBtn:setEnable(true)
                end ,1)

            	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
            else
                YinDaoMarg:getInstance():tryReguide() -----如果网络不好，继续
                XTHDTOAST(data.msg or LANGUAGE_TIPS_WEBERROR)
                self.continueBtn:setEnable(true)
            end
        end,--成功回调
        targetNeedsToRetain = button,
        failedCallback = function()
            YinDaoMarg:getInstance():tryReguide() -----如果网络不好，继续
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)-----"网络请求失败")
            self.continueBtn:setEnable(true)
        end,--失败回调
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
    })
end

function RiChangRenWuDiceResultPopLayer:reFreshHttpData(data)
    if data == nil or next(data)==nil then
        return
    end
    for i=1,#data["property"] do
        local pro_data = string.split( data["property"][i],',')
        -- gameUser.updateDataById(pro_data[1],pro_data[2])
        DBUpdateFunc:UpdateProperty("userdata",pro_data[1],pro_data[2])
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
    self.dicelayer:refreshProficietyData(data)
end

function RiChangRenWuDiceResultPopLayer:createReward()
	local _skyNumber = self.skyNumber
	local _rewardData = self.diceRewardData[tonumber(_skyNumber)+1] or {}
	local rewardNum = 0
	for i=1,5 do
		if _rewardData["num" .. i] and tonumber(_rewardData["num" .. i])>0 then
			rewardNum = i
		else
			break
		end
	end
	for i=1,5 do
		if self:getChildByName("reward" .. i) then
			self:removeChildByName("reward" .. i)
		end
        if self:getChildByName("iconSp" .. i) then
            self:removeChildByName("iconSp" .. i)
        end
	end
	local _itemPosArr = SortPos:sortFromMiddle(cc.p(self:getContentSize().width/2-50,self:getContentSize().height - 55),rewardNum,(self:getContentSize().width-172)/6)
    local _imgTable = {"res/image/tmpbattle/exp_sp.png","res/image/common/header_gold.png","res/image/common/header_ingot.png","res/image/common/header_feicui.png"}
	for i=1,rewardNum do
        local _itemPosX = _itemPosArr[i].x
		local _rewardType = tonumber(_rewardData["rewardtype" .. i])
		local _nameStr  = LANGUAGE_TABLE_RESOURCENAME[_rewardType] or ""
        local _textColor = self:getTextColor("baise")
		if _rewardType == 4 then
			_nameStr = self.staticItemData[tostring(_rewardData["id" .. i])] or {}
			_nameStr = _nameStr.name or ""
        elseif _rewardType <4 or _rewardType == 6 then
            _itemPosX = _itemPosX +30
            _textColor = self:getTextColor("lianghuangse")
            _nameStr = ""
            local _imgOrder = _rewardType
            if _rewardType == 6 then
                _imgOrder = 4
            end
            local _iconSp = cc.Sprite:create(_imgTable[tonumber(_imgOrder)])
            _iconSp:setName("iconSp" .. i)
            _iconSp:setAnchorPoint(cc.p(1,0.5))
            _iconSp:setPosition(cc.p(_itemPosX,_itemPosArr[i].y))
            self:addChild(_iconSp)
		end
		local _rewardStr = _nameStr .. "+" .. _rewardData["num" .. i]
		local _rewardLabel = XTHDLabel:create(_rewardStr,self._fontSize)
        _rewardLabel:setColor(_textColor)
		_rewardLabel:setName("reward" .. i)
        _rewardLabel:enableShadow(_textColor,cc.size(0.4,-0.4),0.4)
		_rewardLabel:setAnchorPoint(cc.p(0,0.5))
		_rewardLabel:setPosition(cc.p(_itemPosX,_itemPosArr[i].y))
		self:addChild(_rewardLabel)
	end
end

function RiChangRenWuDiceResultPopLayer:setRewardShow(data)
    if data==nil or next(data)==nil then
        return
    end
    local _rewardData = data
    local _rewardTable = {}
    for i=1,5 do
        if _rewardData["num" .. i] and tonumber(_rewardData["num" .. i])>0 then
            _rewardTable[i] = {}
            _rewardTable[i].rewardtype = tonumber(_rewardData["rewardtype" .. i])
            _rewardTable[i].id = tonumber(_rewardData["id" .. i])
            _rewardTable[i].num = tonumber(_rewardData["num" .. i])
        else
            break
        end
    end
    ShowRewardNode:create(_rewardTable,nil,nil)
end

function RiChangRenWuDiceResultPopLayer:getBtnNode(_path,_size)
    local _node = ccui.Scale9Sprite:create(cc.rect(40,0,50,39),_path)
    _node:setContentSize(_size)
    return _node
end

function RiChangRenWuDiceResultPopLayer:getDiceAnimation(filepathPrefix, indexArr, perUnit)
    local animation = cc.Animation:create();
    for i=1,(#indexArr or 0) do
        local _index = indexArr[i]
        local filepath = filepathPrefix .. _index .. ".png";
        animation:addSpriteFrameWithFile( filepath );
    end
    animation:setDelayPerUnit( perUnit );
    animation:setRestoreOriginalFrame(true);
    local _action = cc.Animate:create(animation)
    return _action
end

function RiChangRenWuDiceResultPopLayer:refreshBtnState()
    if not self.skyNumber or tonumber(self.skyNumber)<6 then
        return
    end
    if self.sureBtn==nil or self.continueBtn == nil then
        return
    end
    self.continueBtn:setVisible(false)
    self.sureBtn:setPositionX(self:getContentSize().width/2)
    if self.lastFreeCount~=nil then
        self.lastFreeCount:removeFromParent()
        self.lastFreeCount = nil
    end
    if self.lastFreeCountTitle~=nil then
        self.lastFreeCountTitle:removeFromParent()
        self.lastFreeCountTitle = nil
    end
end
--设置天的数量
function RiChangRenWuDiceResultPopLayer:setSkyNumber()
	local _diceIconArr = self.data.destiny or {}
	local _skyNumber = 0
	for i=1,#_diceIconArr do
		if tonumber(_diceIconArr[i]) == 1 then
			_skyNumber = _skyNumber + 1
		end
	end
	self.skyNumber = _skyNumber
end
--刷新title名称
function RiChangRenWuDiceResultPopLayer:refreshTitleName()
	-- if self.titleBg == nil then
	-- 	return
	-- end
	-- local _titlelabel = self.titleBg:getChildByName("titlelabel")
	local _namelabel = self:getChildByName("titleNameLabel")
	if _namelabel==nil then
		return
	end
	local _skyNumber = self.skyNumber
	_namelabel:setString(LANGUAGE_KEY_DICERESULT[tonumber(_skyNumber)+1])
end

--刷新剩余次数
function RiChangRenWuDiceResultPopLayer:refreshLastCount()
	if self.lastFreeCount~=nil then
		self.lastFreeCount:removeFromParent()
		self.lastFreeCount = nil
	end
	if self.lastFreeCountTitle~=nil then
		self.lastFreeCountTitle:removeFromParent()
		self.lastFreeCountTitle = nil
	end
	if self.continueBtn==nil then
		return
	end
	if self.data.destinyAgainCount and tonumber(self.data.destinyAgainCount)>0 then
		--剩余免费次数
	    local _lastFreeCountTitle = XTHDLabel:create(LANGUAGE_KEY_DESTINYDICE.lastFreeCountTextXc,self._fontSize - 4)
        _lastFreeCountTitle:enableShadow(cc.c4b(255,255,255,255),cc.size(0.4,-0.4),0.4)
        _lastFreeCountTitle:setColor(cc.c4b(255,255,255,255))
	    self.lastFreeCountTitle = _lastFreeCountTitle
	    _lastFreeCountTitle:setAnchorPoint(cc.p(0,0.5))
	    local _lastFreeCount = XTHDLabel:create(self.data.destinyAgainCount,self._fontSize)
        _lastFreeCount:enableShadow(self:getTextColor("baise"),cc.size(0.4,-0.4),0.4)
        _lastFreeCount:setColor(self:getTextColor("baise"))
	    self.lastFreeCount = _lastFreeCount
	    _lastFreeCount:setAnchorPoint(cc.p(0,0))
	    _lastFreeCountTitle:setPosition(cc.p(self.continueBtn:getBoundingBox().x + self.continueBtn:getBoundingBox().width + 10,self.continueBtn:getBoundingBox().y+self.continueBtn:getBoundingBox().height/2))
	    _lastFreeCount:setPosition(cc.p(_lastFreeCountTitle:getBoundingBox().x+_lastFreeCountTitle:getBoundingBox().width+2,_lastFreeCountTitle:getBoundingBox().y-2))
	    self:addChild(_lastFreeCountTitle)
	    self:addChild(_lastFreeCount)
	else
		local _againSp = cc.Sprite:create("res/image/common/header_ingot.png")
		_againSp:setAnchorPoint(cc.p(0,0.5))
		self.lastFreeCountTitle = _againSp
		local _costLabel = getCommonWhiteBMFontLabel(self.data.cost or 0)
		_costLabel:setAnchorPoint(cc.p(0,0))
        self.lastFreeCount = _costLabel
		_againSp:setPosition(cc.p(self.continueBtn:getBoundingBox().x + self.continueBtn:getBoundingBox().width +10,self.continueBtn:getBoundingBox().y+self.continueBtn:getBoundingBox().height/2))
	    _costLabel:setPosition(cc.p(_againSp:getBoundingBox().x+_againSp:getBoundingBox().width,_againSp:getBoundingBox().y-5))
	    self:addChild(_againSp)
	    self:addChild(_costLabel)
	end
end

function RiChangRenWuDiceResultPopLayer:setStaticRewardData()
	self.diceRewardData = {}
	local _rewardData = gameData.getDataFromCSV("DiceGame") or {}
	for i=1,#_rewardData do
		if _rewardData[i].typeA and tonumber(_rewardData[i].typeA)==1 then
			self.diceRewardData[#self.diceRewardData + 1] = _rewardData[i] or {}
		else
			break
		end
	end
end
function RiChangRenWuDiceResultPopLayer:setStaticItemData()
	self.staticItemData = {}
	self.staticItemData = gameData.getDataFromCSVWithPrimaryKey("ArticleInfoSheet")
end

function RiChangRenWuDiceResultPopLayer:getTextColor(_str)
    local _color = {
        hongse = cc.c4b(204,2,2,255),
        juhuangse = cc.c4b(205,101,8,255),
        lianghuangse = cc.c4b(255,234,0,255),
        baise = cc.c4b(255,255,255,255)
    }
    return _color[_str]
end

function RiChangRenWuDiceResultPopLayer:create(data,dicelayer)
	local _layer = self.new(data,dicelayer)
	return _layer
end

return RiChangRenWuDiceResultPopLayer