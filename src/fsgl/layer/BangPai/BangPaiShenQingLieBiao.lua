--createdBy xingchen 
--2015/10/21
--帮派申请列表界面
local BangPaiShenQingLieBiao = class("BangPaiShenQingLieBiao",function()
    local node = cc.Node:create()
	node:setAnchorPoint(0.5,0.5)
	node:setContentSize(cc.size(420,435))
	return node
end)
function BangPaiShenQingLieBiao:ctor()
	self.applyListData = {}
end

function BangPaiShenQingLieBiao:initLayer(_data)
	self._fontSize = 20
	self.currentPage = 1
	self.applyListData = {}
	self.currentApplyListData = {}
	self.currentPageApplyListData = {}
    self.verticalPos = {}

	self:setApplyListData(_data)
	self:setCurrentApplyListData()
	self:setCurrentPageApplyListData(self.currentPage)
	
	local _bgSprite = cc.Sprite:createWithTexture(nil, cc.rect(0,0,self:getContentSize().width,self:getContentSize().height))
    _bgSprite:setOpacity(0)
    self.bgSprite = _bgSprite
    _bgSprite:setAnchorPoint(cc.p(0.5,0.5))
    _bgSprite:setPosition(cc.p(self:getContentSize().width/2,self:getContentSize().height/2))
	self:addChild(_bgSprite)

    local _upPosY = _bgSprite:getContentSize().height - 25
    local _applyPerson = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT_2 .. ":",16)
    _applyPerson:setColor(cc.c3b(46,1,1))
    _applyPerson:setAnchorPoint(cc.p(0,0.5))
    _applyPerson:setPosition(cc.p(15,_upPosY))
    self:addChild(_applyPerson)

    local _number = #self.applyListData or 0
    local _personNumberLabel = XTHDLabel:create(_number,self._fontSize+2)
    self.personNumberLabel = _personNumberLabel
    _personNumberLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("hongse"))
    _personNumberLabel:setAnchorPoint(cc.p(0,0.5))
    _personNumberLabel:setPosition(cc.p(_applyPerson:getBoundingBox().x+_applyPerson:getBoundingBox().width+5,_upPosY))
	_bgSprite:addChild(_personNumberLabel)    

    --拒绝所有
	local _refuseAllBtn = BangPaiFengZhuangShuJu.createGuildBtnNode({
        btnSize = cc.size(135,46),
		fontSize = 24,
		labelStr = "refuseAll_text",
		btnColor = "write"
	})
	_refuseAllBtn:setAnchorPoint(cc.p(1,0.5))
	_refuseAllBtn:setPosition(cc.p(self:getContentSize().width-10,_upPosY))
	_refuseAllBtn:setTouchEndedCallback(function()
			self:refuseAllApplyCallback()
		end)
    _refuseAllBtn:setScale(0.5)
    self:addChild(_refuseAllBtn)
    --同意所有
    local _agreeAllBtn = BangPaiFengZhuangShuJu.createGuildBtnNode({
         btnSize = cc.size(135,46),
		fontSize = 24,
		labelStr = "agreeAll_text",
		btnColor = "write_1"
	})

    _agreeAllBtn:setAnchorPoint(cc.p(1,0.5))
    _agreeAllBtn:setPosition(cc.p(_refuseAllBtn:getBoundingBox().x - 3,_upPosY))
    _agreeAllBtn:setTouchEndedCallback(function()
    self:agreeAllApplyCallback()
    end)
    _agreeAllBtn:setScale(0.5)

    self:addChild(_agreeAllBtn)

    local _downPosY = 60
    local _distance = 3
    local _listBg = ccui.Scale9Sprite:create()
    _listBg:setContentSize(cc.size(self:getContentSize().width - 5,_upPosY - 22 - _downPosY))
    self.listBg = _listBg
    _listBg:setAnchorPoint(cc.p(0,0))
    _listBg:setPosition(cc.p(_distance,_downPosY))
    self:addChild(_listBg)

    local _pagePosY = _downPosY-20
    --前后页
    local _pageBg = ccui.Scale9Sprite:create(cc.rect(0,0,0,0),"res/image/common/scale9_bg1_24.png")
    _pageBg:setContentSize(cc.size(76,30))
    _pageBg:setPosition(cc.p(_bgSprite:getContentSize().width/2,_pagePosY))
    _bgSprite:addChild(_pageBg)

    local _pageLabel = XTHDLabel:create("1/1",self._fontSize)
    _pageLabel:setColor(cc.c3b(46,1,1))
    self.pageLabel = _pageLabel 
    _pageLabel:setPosition(cc.p(_pageBg:getContentSize().width/2,_pageBg:getContentSize().height/2))
    _pageBg:addChild(_pageLabel)

    self:refreshPage()

    local _previousPageBtn = self:createPageBtn("res/image/guild/btnText_previousPage.png")
    _previousPageBtn:setAnchorPoint(cc.p(1,0.5))
    _previousPageBtn:setPosition(cc.p(_pageBg:getBoundingBox().x - 30,_pagePosY))
    _bgSprite:addChild(_previousPageBtn)
    _previousPageBtn:setTouchEndedCallback(function()
            self:previousBtnCallBack()
        end)
    local _nextPageBtn = self:createPageBtn("res/image/guild/btnText_nextPage.png")
    _nextPageBtn:setAnchorPoint(cc.p(0,0.5))
    _nextPageBtn:setPosition(cc.p(_pageBg:getBoundingBox().x + _pageBg:getBoundingBox().width + 30,_pagePosY))
    _bgSprite:addChild(_nextPageBtn)
    _nextPageBtn:setTouchEndedCallback(function()
            self:nextBtnCallBack()
        end)


    local _linePosY = _listBg:getContentSize().height-35

    local _verticalPosTable = {0.2,0.15,0.4,0.22}
    local _imgKeyTable = { "member", "level", "playerPower", "pvpRank"}
	
    --表头背景
    local bt_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_25.png")
    bt_bg:setContentSize(_listBg:getContentSize().width,30)
    bt_bg:setPosition(_listBg:getContentSize().width/2,_listBg:getContentSize().height-15)
    _listBg:addChild(bt_bg)

    local _linePosX = 0
    for i=1,#_verticalPosTable do
        local _curWidth = _listBg:getContentSize().width * _verticalPosTable[i]
        self.verticalPos[i] = _curWidth
        _linePosX = _curWidth + _linePosX
        local _titleLabel = XTHDLabel:create(LANGUAGE_GUILDTITLE_KEY[_imgKeyTable[i]],16)
        _titleLabel:setColor(cc.c3b(46,1,1))
        _titleLabel:setAnchorPoint(cc.p(0.5,0.5))
        _titleLabel:setPosition(cc.p(_linePosX - _curWidth/2,_linePosY + 42/2))
        _listBg:addChild(_titleLabel)

        if i~=(#_verticalPosTable) then
            local _lineHeight = 32
            local _verticalLine = BangPaiFengZhuangShuJu.createListVerticalLine(_lineHeight)
            _verticalLine:setAnchorPoint(cc.p(0.5,0.5))
            _verticalLine:setPosition(cc.p(_linePosX,_linePosY + _lineHeight/2+6))
            _listBg:addChild(_verticalLine)
        end
    end

    --list
    local _tableViewSize = cc.size(_listBg:getContentSize().width , _listBg:getContentSize().height - 3*2-35)
    local _tableViewCellSize = cc.size(_tableViewSize.width,70)
    self.tableViewCellSize = _tableViewCellSize
    local _tableView = CCTableView:create(_tableViewSize)
    TableViewPlug.init(_tableView)
    self.applyListTabelView = _tableView
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _tableView:setBounceable(true)
    _tableView:setDelegate()
    _tableView:setPosition(cc.p(0,10))
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    _listBg:addChild(_tableView)

    local function numberOfCellsInTableView(table_view)
        return #self.currentPageApplyListData
    end
    local function cellSizeForTable(table_view, idx)
        return _tableViewCellSize.width,_tableViewCellSize.height+20
    end
    local function tableCellTouched(table, cell)
        print("8431>>>查看成员信息")
    end
    local function tableCellAtIndex(table_view, idx)
        local cell = table_view:dequeueCell()
        if cell then
            if cell:getChildByName("heroBtn") then
                local _heroBtn = cell:getChildByName("heroBtn")
                if _heroBtn.isSelected ~= nil and _heroBtn.isSelected == true then
                    self.selectedHeroSp = nil
                    _heroBtn.isSelected = nil
                end
            end
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
			cell:setContentSize(_tableViewCellSize.width,_tableViewCellSize.height+20)
        end
        local _cellBg = self:createCellSprite(idx+1)
        _cellBg:setPosition(cc.p(_tableViewCellSize.width/2,_tableViewCellSize.height/2))
        cell:addChild(_cellBg)

        if idx ~=#self.currentPageApplyListData-1 then
            local _lineSp = BangPaiFengZhuangShuJu.createListLine(_tableViewCellSize.width - 2)
            _lineSp:setPosition(cc.p(_tableViewCellSize.width/2,0)) 
            cell:addChild(_lineSp)
        end

        return cell
    end
    _tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView.getCellNumbers=numberOfCellsInTableView
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView.getCellSize=cellSizeForTable
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:reloadData()

    self:createNoApplyPrompt()
end

function BangPaiShenQingLieBiao:createCellSprite(_idx)
    local _distance = 3
    local _applyBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
    _applyBg:setContentSize(cc.size(self.tableViewCellSize.width,self.tableViewCellSize.height+20))
    
    local _applyData = self.currentPageApplyListData[tonumber(_idx)] or {}
    if next(_applyData)==nil then
        return _applyBg
    end

    local _labelKeyTable = { "name", "level", "power", "rank", "dealOperate"}
    local _linePosX = 0-_distance
    local _linePosY = _applyBg:getContentSize().height/2
    local _labelPosXTable = {}
    local _labelPosY = _applyBg:getContentSize().height/2 + 15
    for i=1,#self.verticalPos do
        _linePosX = self.verticalPos[i] + _linePosX
        _labelPosXTable[i] = _linePosX - self.verticalPos[i]/2

        local _labelStr = _applyData[_labelKeyTable[i]] or ""
        local _fontSize = 20
        if i==4 then
            local _applySp = cc.Sprite:create("res/image/common/rank_icon/rankIcon_" .. tonumber(_applyData["duanId"]) .. ".png")
            _applySp:setScale(0.7)
            _applySp:setPosition(cc.p(_linePosX,_labelPosY + 2))
            _applyBg:addChild(_applySp)
            local _applyLabel = XTHDLabel:createWithSystemFont(_labelStr,"Helvetiva",_fontSize)
            _applyLabel:setColor(cc.c3b(46,1,1))
            _applyLabel:setAnchorPoint(cc.p(0,0.5))
            _applySp:setPositionX(_linePosX - self.verticalPos[i]/2 - _applyLabel:getBoundingBox().width/2)
            _applyLabel:setPosition(cc.p(_applySp:getBoundingBox().x+_applySp:getBoundingBox().width,_labelPosY))
            _applyBg:addChild(_applyLabel)
        else
        	local _applyLabel = XTHDLabel:create(_labelStr,_fontSize)
            _applyLabel:setColor(cc.c3b(46,1,1))
            _applyLabel:setPosition(cc.p(_linePosX - self.verticalPos[i]/2 + 5,_labelPosY))
            _applyBg:addChild(_applyLabel)
        end
    end
	
	local _refuseApply = XTHD.createCommonButton({
		isScrollView = true,
		btnColor = "write",
		text = LANGUAGE_BTN_KEY.refuse_text,
		fontSize = 24,
    })
	_refuseApply:setScale(0.6)
	_refuseApply:setAnchorPoint(cc.p(1,0.5))
	_refuseApply:setPosition(cc.p(_applyBg:getContentSize().width *0.5 - 10,_refuseApply:getContentSize().height *0.4))
    _applyBg:addChild(_refuseApply)
	_refuseApply:setTouchEndedCallback(function()
		self:refuseApplyCallbackByCharId(_applyData["charId"])
	end)

	local _agreeApply = XTHD.createCommonButton({
		btnColor = "write_1",
		isScrollView = false,
		text = LANGUAGE_BTN_KEY.agree_text,
		fontSize = 24,
	})
	
	_agreeApply:setScale(0.6)
	_agreeApply:setAnchorPoint(cc.p(0,0.5))
	_agreeApply:setPosition(cc.p(_applyBg:getContentSize().width *0.5 + 10,_agreeApply:getContentSize().height *0.4))
	_applyBg:addChild(_agreeApply)
	_agreeApply:setTouchEndedCallback(function()
		self:agreeApplyCallbackByCharId(_applyData["charId"])
	end)
	
    return _applyBg
end


function BangPaiShenQingLieBiao:agreeApplyCallbackByCharId(_charId)
	local _charIdTable = json.encode({_charId})
	ClientHttp.httpAgreeGuildApply( self, function(data)
            BangPaiFengZhuangShuJu.addGuildListData(data.list)
			self:exchangeApplyData(_charId)
            if data~=nil and data.list~=nil and #data.list>0 then
                XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildAcceptApplyToastXc)
                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST})
            else
                XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildAcceptApplyFailToastXc)
            end
        end, {list = _charIdTable } )
end

function BangPaiShenQingLieBiao:refuseApplyCallbackByCharId(_charId)
	local _charIdTable = json.encode({_charId})
	ClientHttp.httpRejectGuildApply( self, function(data)
			self:exchangeApplyData(_charId)
            XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildRefuseApplyToastXc)
        end, {list = _charIdTable } )
end

function BangPaiShenQingLieBiao:agreeAllApplyCallback()
    if #self.currentApplyListData <1 then
        XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildNoApplyTextXc)
        return 
    end
	local _charIdTable = json.encode(self:getAllApplyCharId())
	ClientHttp.httpAgreeGuildApply( self, function(data)
            BangPaiFengZhuangShuJu.addGuildListData(data.list)
			self:exchangeApplyData()
            local _addNumber = #data.list or 0
            XTHDTOAST(LANGUAGE_TIPS_guildAcceptAllApplyToastXc(_addNumber))
            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_GUILDMAIN_LIST})
        end, {list = _charIdTable } )
end

function BangPaiShenQingLieBiao:refuseAllApplyCallback()
    if #self.currentApplyListData <1 then
        XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildNoApplyTextXc)
        return 
    end
	local _charIdTable = json.encode(self:getAllApplyCharId())
	ClientHttp.httpRejectGuildApply( self, function(data)
			self:exchangeApplyData()
            XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildRefuseApplyToastXc)
        end, {list = _charIdTable } )
end

function BangPaiShenQingLieBiao:exchangeApplyData(_charId)
    if _charId~=nil then
        self:deleteDataByCharId(_charId)
    else
        self:resetApplyData()
    end
    self:reloadGuildList()
    self:refreshApplyNumber()

end

function BangPaiShenQingLieBiao:previousBtnCallBack()
    if self.currentPage < 2 then
        XTHDTOAST(LANGUAGE_TIPS_WORDS225)
        return
    end
    self.currentPage = self.currentPage - 1
    self:setCurrentPageApplyListData(self.currentPage)
    self:reloadGuildList()
end

function BangPaiShenQingLieBiao:nextBtnCallBack()
    if self.currentPage >math.ceil(#self.currentApplyListData/10 -1) then
        XTHDTOAST(LANGUAGE_TIPS_WORDS226)
        return
    end
    self.currentPage = self.currentPage + 1
    self:setCurrentPageApplyListData(self.currentPage)
    self:reloadGuildList()
end

function BangPaiShenQingLieBiao:reloadGuildList()
    --加载tableview
    self.applyListTabelView:reloadDataAndScrollToCurrentCell()

    --刷新页数
    self:refreshPage()

    self:createNoApplyPrompt()
end

function BangPaiShenQingLieBiao:createNoApplyPrompt()
	if #self.currentApplyListData <1 then
    	if self.listBg ==nil or self.listBg:getChildByName("noApplyPrompt") then
    		return
    	end
    	local _noApplyPromptSp = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.guildNoApplyTextXc,30)
        _noApplyPromptSp:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
        _noApplyPromptSp:setName("noApplyPrompt")
    	_noApplyPromptSp:setPosition(cc.p(self.listBg:getContentSize().width/2,self.listBg:getContentSize().height/2))
    	self.listBg:addChild(_noApplyPromptSp)
    else
        if self.listBg ~=nil and self.listBg:getChildByName("noApplyPrompt") then
            self.listBg:removeChildByName("noApplyPrompt")
        end
    end
end

function BangPaiShenQingLieBiao:createPageBtn(_path)
    local _pageBtn = XTHD.createButton({
            touchSize = cc.size(36,37) 
        })
    local _pageSp = cc.Sprite:create(_path)
    _pageSp:setPosition(cc.p(_pageBtn:getContentSize().width/2,_pageBtn:getContentSize().height/2))
    _pageBtn:addChild(_pageSp)
    return _pageBtn
end

function BangPaiShenQingLieBiao:getBtnNode(_path)
    local _node = ccui.Scale9Sprite:create(cc.rect(67,0,1,41),_path)
    _node:setContentSize(cc.size(212,41))
    return _node
end

function BangPaiShenQingLieBiao:getAllApplyCharId()
	local _charIdTable = {}
	for i=1,#self.currentApplyListData do
		_charIdTable[i] = self.currentApplyListData[i].charId or 0
	end
	return _charIdTable
	-- json.encode
end

function BangPaiShenQingLieBiao:refreshPage()
    if self.pageLabel == nil then
        return
    end
    local _allPages = math.ceil(#self.currentApplyListData/10 or 0)
    local _currentPage = self.currentPage or 0
    if _currentPage>_allPages then
        _currentPage = _allPages
    end
    self.pageLabel:setString(_currentPage .. "/" .. _allPages)

end

function BangPaiShenQingLieBiao:refreshApplyNumber()
	if self.personNumberLabel==nil then
		return
	end
    local _number = #self.currentApplyListData or 0
    if _number > 0  then
        XTHD.dispatchEvent({name = "GuildApply",data = {["name"] = "Apply",["visible"] = true}})
    else
        XTHD.dispatchEvent({name = "GuildApply",data = {["name"] = "Apply",["visible"] = false}})
    end
	self.personNumberLabel:setString(_number)
end

function BangPaiShenQingLieBiao:setCurrentPageApplyListData(_pageIndex)
    self.currentPageApplyListData = {}
    local _pageIdx = _pageIndex or 1
    local _startIndex = 1+(_pageIdx-1)*10
    local _endIndex = _pageIdx*10
    for i=_startIndex,_endIndex do
        if self.currentApplyListData[i] ==nil or next(self.currentApplyListData[i])==nil then
            break
        end
        self.currentPageApplyListData[#self.currentPageApplyListData + 1] = self.currentApplyListData[i]
    end
end

function BangPaiShenQingLieBiao:setCurrentApplyListData()
    self.currentApplyListData = {}
    self.currentApplyListData = self.applyListData
end

function BangPaiShenQingLieBiao:setApplyListData(_data)
	self.applyListData = {}
	self.applyListData = _data.list or {}
end

function BangPaiShenQingLieBiao:deleteDataByCharId(_charId)
	if _charId == nil then
		return
	end
	for i=1,#self.applyListData do
		if tonumber(_charId) == tonumber(self.applyListData[i].charId) then
			table.remove(self.applyListData,i)
			break
		end
	end
	self.currentPage = 1
	self:setCurrentApplyListData()
	self:setCurrentPageApplyListData(self.currentPage)
end

function BangPaiShenQingLieBiao:resetApplyData()
	self.currentPage = 1
	self:setApplyListData({})
	self:setCurrentApplyListData()
	self:setCurrentPageApplyListData(self.currentPage)
end

function BangPaiShenQingLieBiao:create(_data)
	local _layer = self.new()
	_layer:initLayer(_data)
	return _layer
end

return BangPaiShenQingLieBiao