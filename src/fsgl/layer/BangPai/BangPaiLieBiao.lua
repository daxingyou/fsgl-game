-- createdBy xingchen
-- 2015/10/15
-- 帮派列表界面
local BangPaiLieBiao = class("BangPaiLieBiao", function(...)
    return XTHD.createBasePageLayer()
end )

function BangPaiLieBiao:init(sParams)
    self._fontSize = 20
    self.currentPage = 1
    self.guildListData = { }
    self.currentGuildListData = { }
    self.currentPageGuildListData = { }
    self:setGuildListData(sParams)
    self:setCurrentGuildListData()
    self:setCurrentPageGuildListData(self.currentPage)

    self.pageLabel = nil
    self.createGuildBtn = nil

    self.isApplyGuild = true
    if gameUser.getGuildId() == 0 then
        self.isApplyGuild = false
    end
    local _topBarHeight = self.topBarHeight or 40
    local _bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
    _bg:setPosition(cc.p(self:getContentSize().width / 2,(self:getContentSize().height - _topBarHeight) / 2))
    self:addChild(_bg)
    local bsize = _bg:getContentSize()

    local title = "res/image/public/bangpailist_title.png"
    XTHD.createNodeDecoration(_bg, title)

    local _bgSprite = cc.Sprite:createWithTexture(nil, cc.rect(0, 0, bsize.width, bsize.height))
    _bgSprite:setOpacity(0)
    self.bgSprite = _bgSprite
    _bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    _bgSprite:setPosition(cc.p(bsize.width / 2, bsize.height / 2))
    _bg:addChild(_bgSprite)

    local _upPosY = _bgSprite:getContentSize().height - 45
    local _downPosY = 60
    -- 创建帮派按钮
    if self.isApplyGuild == false then
        local _createGuildBtn = BangPaiFengZhuangShuJu.createGuildBtnNode( {
            btnSize = cc.size(102,46)
            ,
            labelStr = "create_text"
            ,
            imgStr = "createGuild"
        } )
        _createGuildBtn:getLabel():setFontSize(26)
        _createGuildBtn:getLabel():enableOutline(cc.c4b(150, 79, 39, 255), 2)
        _createGuildBtn:getLabel():setPosition(cc.p(_createGuildBtn:getLabel():getPositionX() -6, _createGuildBtn:getLabel():getPositionY() -2))
        _createGuildBtn:setName("createGuildBtn")
        _createGuildBtn:setAnchorPoint(cc.p(1, 0.5))
        _createGuildBtn:setPosition(cc.p(_bgSprite:getContentSize().width - 36, _upPosY + 2))
        _bgSprite:addChild(_createGuildBtn)
        _createGuildBtn:setScale(0.6)
        _createGuildBtn:setTouchEndedCallback( function()
            if tonumber(gameUser.getGuildId()) ~= 0 then
                XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildCannotApplyToastXc)
                return
            end
            self:createGuildCallBack()
        end )
    end
    -- 搜索
    local _exploreSp = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT_1 .. ":", 18)
    -- cc.Sprite:create("res/image/guild/guildTitleText_exploreGuild.png")
    _exploreSp:setColor(cc.c3b(55, 54, 112))
    _exploreSp:setAnchorPoint(cc.p(0, 0.5))
    _exploreSp:setPosition(cc.p(36, _upPosY))
    _bgSprite:addChild(_exploreSp)

    -- 搜索底框
    local _exploreSize = cc.size(205, 34)
    local _exploreBg = ccui.Scale9Sprite:create("res/image/login/login_input_bg.png")
    _exploreBg:setAnchorPoint(cc.p(0, 0.5))
    _exploreBg:setContentSize(_exploreSize)
    _exploreBg:setPosition(cc.p(_exploreSp:getBoundingBox().width + _exploreSp:getBoundingBox().x + 5, _upPosY))
    _bgSprite:addChild(_exploreBg)

    local _explore_editbox = ccui.EditBox:create(cc.size(_exploreSize.width - 15, _exploreSize.height - 5), ccui.Scale9Sprite:create(), nil, nil)
    _explore_editbox:setFontColor(cc.c4b(255, 255, 255, 255))
    _explore_editbox:setPlaceHolder(LANGUAGE_INPUTTIPS8)
    _explore_editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    _explore_editbox:setAnchorPoint(cc.p(0, 0.5))
    _explore_editbox:setMaxLength(10)
    _explore_editbox:setPosition(10, _exploreSize.height / 2)
    _explore_editbox:setPlaceholderFontColor(cc.c4b(255, 255, 255, 255))
    _explore_editbox:setFontSize(self._fontSize)
    _explore_editbox:setPlaceholderFontSize(self._fontSize)
    _explore_editbox:setFontName("Helvetica")
    _explore_editbox:setFontColor(cc.c4b(255, 255, 255, 255))
    _explore_editbox:setPlaceholderFontName("Helvetica")
    _explore_editbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    _exploreBg:addChild(_explore_editbox)

    local _exploreBtn = XTHD.createButton( {
        normalFile = "res/image/common/btn/btn_explore_normal.png",
        selectedFile = "res/image/common/btn/btn_explore_selected.png"
    } )
    _exploreBtn:setAnchorPoint(cc.p(0, 0.5))
    _exploreBtn:setPosition(cc.p(_exploreBg:getBoundingBox().x + _exploreBg:getBoundingBox().width + 5, _upPosY))
    _exploreBtn:setScale(0.8)
    _exploreBtn:setTouchEndedCallback( function()
        local _idStr = _explore_editbox:getText()
        _explore_editbox:setText("")
        if tonumber(_idStr) == nil or tonumber(_idStr) < 0 then
            XTHDTOAST(LANGUAGE_TIPS_WORDS224)
            return
        end
        if _idStr == nil or string.len(_idStr) < 1 then
            XTHDTOAST(LANGUAGE_TIPS_WORDS76)
            ------"查找信息不可为空！")
            return
        end
        self:exploreGuildCallBack(tonumber(_idStr))
    end )
    _bgSprite:addChild(_exploreBtn)

    local _pagePosY = _downPosY - 20
    -- 前后页
    local _pageBg = ccui.Scale9Sprite:create(cc.rect(0, 0, 0, 0), "res/image/common/scale9_bg1_24.png")
    _pageBg:setContentSize(cc.size(76, 30))
    _pageBg:setPosition(cc.p(_bgSprite:getContentSize().width / 2, _pagePosY))
    _bgSprite:addChild(_pageBg)

    local _pageLabel = XTHDLabel:create("1/1", self._fontSize)
    _pageLabel:setColor(cc.c4b(255, 255, 255, 255))
    self.pageLabel = _pageLabel
    _pageLabel:setPosition(cc.p(_pageBg:getContentSize().width / 2, _pageBg:getContentSize().height / 2))
    _pageBg:addChild(_pageLabel)

    self:refreshPage()

    -- 上一页，下一页
    local _previousPageBtn = self:createPageBtn("res/image/guild/btnText_previousPage.png")
    _previousPageBtn:setAnchorPoint(cc.p(1, 0.5))
    _previousPageBtn:setPosition(cc.p(_pageBg:getBoundingBox().x - 30, _pagePosY))
    _bgSprite:addChild(_previousPageBtn)
    _previousPageBtn:setTouchEndedCallback( function()
        self:previousBtnCallBack()
    end )
    local _nextPageBtn = self:createPageBtn("res/image/guild/btnText_nextPage.png")
    _nextPageBtn:setAnchorPoint(cc.p(0, 0.5))
    _nextPageBtn:setPosition(cc.p(_pageBg:getBoundingBox().x + _pageBg:getBoundingBox().width + 30, _pagePosY))
    _bgSprite:addChild(_nextPageBtn)
    _nextPageBtn:setTouchEndedCallback( function()
        print("金金金")
        self:nextBtnCallBack()
    end )
    local _distance = 32
    -- 第二个背景框
    -- local _listBg = BangPaiFengZhuangShuJu.createListBg(cc.size(_bgSprite:getContentSize().width - _distance*2,_upPosY - 22 - _downPosY))
    local _listBg = ccui.Scale9Sprite:create()
    _listBg:setContentSize(cc.size(_bgSprite:getContentSize().width - _distance * 2, _upPosY - 22 - _downPosY))
    self.listBg = _listBg
    _listBg:setAnchorPoint(cc.p(0, 0))
    _listBg:setPosition(cc.p(_distance, _downPosY))
    _bgSprite:addChild(_listBg)

    -- 表头
    local bt_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_25.png")
    bt_bg:setContentSize(_listBg:getContentSize().width - 10, 50)
    bt_bg:setPosition(_listBg:getContentSize().width / 2, _listBg:getContentSize().height - 25)
    _listBg:addChild(bt_bg)

    -- 表头文字（先调下面位置）
    -- 帮派名称
    local bpName = XTHDLabel:create("帮派名称", 20)
    bpName:setPosition(156, bt_bg:getContentSize().height / 2)
    bpName:setColor(cc.c3b(55, 54, 112))
    bt_bg:addChild(bpName)
    -- ID号码
    local bpID = XTHDLabel:create("编号", 20)
    bpID:setPosition(405, bt_bg:getContentSize().height / 2)
    bpID:setColor(cc.c3b(55, 54, 112))
    bt_bg:addChild(bpID)
    -- 帮派等级
    local bplevel = XTHDLabel:create("帮派等级", 20)
    bplevel:setPosition(515, bt_bg:getContentSize().height / 2)
    bplevel:setColor(cc.c3b(55, 54, 112))
    bt_bg:addChild(bplevel)
    -- 帮派人数
    local bpNum = XTHDLabel:create("帮派人数", 20)
    bpNum:setPosition(615, bt_bg:getContentSize().height / 2)
    bpNum:setColor(cc.c3b(55, 54, 112))
    bt_bg:addChild(bpNum)
    -- 等级限制
    local bplimt = XTHDLabel:create("等级限制", 20)
    bplimt:setPosition(745, bt_bg:getContentSize().height / 2)
    bplimt:setColor(cc.c3b(55, 54, 112))
    bt_bg:addChild(bplimt)
    -- 申请入帮
    local bpapply = XTHDLabel:create("申请入帮", 20)
    bpapply:setPosition(860, bt_bg:getContentSize().height / 2)
    bpapply:setColor(cc.c3b(55, 54, 112))
    bt_bg:addChild(bpapply)



    local _tableViewSize = cc.size(_listBg:getContentSize().width, _listBg:getContentSize().height - 3 * 2 - 50)
    local _tableViewCellSize = cc.size(_tableViewSize.width, 115)
    self.tableViewCellSize = _tableViewCellSize

    local _tableView = CCTableView:create(_tableViewSize)
    TableViewPlug.init(_tableView)
    self.tableView = _tableView
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _tableView:setBounceable(true)
    _tableView:setDelegate()
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    _tableView:setPosition(cc.p(0, 4))
    _listBg:addChild(_tableView)


    local function numberOfCellsInTableView(table_view)
        return #self.currentPageGuildListData
    end
    local function cellSizeForTable(table_view, idx)
        return _tableViewCellSize.width, _tableViewCellSize.height
    end
    -- local function scrollViewDidScroll(table_view)
    --     self.isScrolling = true
    -- end
    self.tableView.getCellNumbers = numberOfCellsInTableView
    self.tableView.getCellSize = cellSizeForTable
    local function tableCellAtIndex(table_view, idx)
        local cell = table_view:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
            cell:setContentSize(cc.size(_tableViewCellSize.width, _tableViewCellSize.height))
        end
        local _cellBg = self:createGuildListCellSprite(idx + 1)
        _cellBg:setPosition(cc.p(_tableViewCellSize.width / 2, _tableViewCellSize.height / 2))
        cell:addChild(_cellBg)
        -- if idx ~=#self.currentPageGuildListData-1 then
        --     local _lineSp = BangPaiFengZhuangShuJu.createListLine(_tableViewCellSize.width - 2)
        --     _lineSp:setPosition(cc.p(_tableViewCellSize.width/2,0))
        --     cell:addChild(_lineSp)
        -- end

        return cell
    end
    _tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView.getCellNumbers = numberOfCellsInTableView
    _tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView.getCellSize = cellSizeForTable
    _tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    -- _tableView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
    _tableView:reloadData()

    self:createNoApplyPrompt()

    XTHD.addEventListenerWithNode( {
        name = CUSTOM_EVENT.REFRESH_GUILDINFO,
        node = self,
        callback = function(event)
            self:refreshGuildState()
        end
    } )
end

function BangPaiLieBiao:createGuildListCellSprite(_idx)
    -- 每一行的背景图
    -- local _guildBg = BangPaiFengZhuangShuJu.createListCellBg(cc.size(self.tableViewCellSize.width - 4*2,self.tableViewCellSize.height - 4*2))
    local _guildBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_32.png")
    _guildBg:setContentSize(cc.size(self.tableViewCellSize.width - 4 * 2, self.tableViewCellSize.height))

    local _guildData = self.currentPageGuildListData[tonumber(_idx)] or { }
    if next(_guildData) == nil then
        return _guildBg
    end

    local _guildIcon = BangPaiFengZhuangShuJu.createGuildIcon(_guildData.guildIcon, _guildData.level)
    _guildIcon:setAnchorPoint(cc.p(0, 0.5))
    _guildIcon:setPosition(cc.p(5, _guildBg:getContentSize().height / 2))
    _guildBg:addChild(_guildIcon)

    local _linePosX = 110
    local _linePosY = _guildBg:getContentSize().height - 50
    -- ID  and  帮派人数 x位置
    local _midPosX = _guildBg:getContentSize().width / 2 - 70
    -- local _verticalLine = ccui.Scale9Sprite:create(cc.rect(0,34,2,1),"res/image/guild/guild_verticalLine.png")
    -- _verticalLine:setContentSize(cc.size(2,110))
    -- _verticalLine:setPosition(cc.p(_linePosX,_guildBg:getContentSize().height/2-1))
    -- _guildBg:addChild(_verticalLine)

    local _lineWidth = _guildBg:getContentSize().width - _linePosX - 80
    -- local _horizontalLine = ccui.Scale9Sprite:create(cc.rect(190,0,20,4),"res/image/common/common_split_line.png")
    -- _horizontalLine:setContentSize(cc.size(_lineWidth,2))
    -- _horizontalLine:setAnchorPoint(cc.p(0,0.5))
    -- _horizontalLine:setPosition(cc.p(_linePosX,_linePosY))
    -- _guildBg:addChild(_horizontalLine)

    -- 帮派名称
    local _guildName = XTHDLabel:createWithSystemFont(_guildData.guildName or "", "Helvetica", self._fontSize)
    -- XTHDLabel:create(_guildData.guildName or "",self._fontSize + 6)
    _guildName:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    _guildName:setAnchorPoint(cc.p(0, 0))
    _guildName:setPosition(cc.p(_linePosX + 15, _guildBg:getContentSize().height / 2 - 10))
    _guildBg:addChild(_guildName)

    -- 帮派ID
    local _guildIDTitle = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.guildIDTitleTextXc .. ":", self._fontSize)
    _guildIDTitle:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    _guildIDTitle:setAnchorPoint(cc.p(0, 0))
    _guildIDTitle:setPosition(cc.p(_midPosX - 100, _guildName:getPositionY()))
    _guildBg:addChild(_guildIDTitle)
    _guildIDTitle:setVisible(false)
    local _guildIDLabel = XTHDLabel:create(_guildData.guildId or 1, self._fontSize)
    _guildIDLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    _guildIDLabel:setAnchorPoint(cc.p(0, 0))
    _guildIDLabel:setPosition(cc.p(_guildIDTitle:getBoundingBox().x + _guildIDTitle:getBoundingBox().width - 10, _guildIDTitle:getPositionY()))
    _guildBg:addChild(_guildIDLabel)

    -- 帮派等级
    local _guildLevelTitle = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.guildLevelTitleTextXc .. ":", self._fontSize)
    _guildLevelTitle:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    _guildLevelTitle:setAnchorPoint(cc.p(0, 0))
    _guildLevelTitle:setPosition(cc.p(_guildIDLabel:getPositionX() + 60, _guildName:getPositionY()))
    _guildBg:addChild(_guildLevelTitle)
    _guildLevelTitle:setVisible(false)
    local _guildLevelLabel = XTHDLabel:create((_guildData.guildLevel or 1) .. LANGUAGE_NAMES.level, self._fontSize)
    _guildLevelLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    _guildLevelLabel:setAnchorPoint(cc.p(0, 0))
    _guildLevelLabel:setPosition(cc.p(_guildLevelTitle:getBoundingBox().x + _guildLevelTitle:getBoundingBox().width - 30, _guildLevelTitle:getPositionY()))
    _guildBg:addChild(_guildLevelLabel)

    local _limitColor = BangPaiFengZhuangShuJu.getTextColor("shenhese")
    local _limitStr = LANGUAGE_ADJ.nolimit
    local _shadowRange = 0
    if _guildData.limitLevel and tonumber(_guildData.limitLevel) > 0 then
        _limitColor = cc.c3b(108, 48, 12)
        _limitStr = _guildData.limitLevel .. LANGUAGE_NAMES.level
        _shadowRange = 0.4
    end

    -- 帮派等级限制
    local _guildLimitTitle = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.guildLimitTitleTextXc .. ":", self._fontSize)
    _guildLimitTitle:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    _guildLimitTitle:setAnchorPoint(cc.p(0, 0))
    _guildLimitTitle:setPosition(cc.p(_midPosX + 180, _guildName:getPositionY()))
    _guildBg:addChild(_guildLimitTitle)
    _guildLimitTitle:setVisible(false)
    local _guildLimitLabel = XTHDLabel:create(_limitStr, self._fontSize)
    _guildLimitLabel:enableShadow(_limitColor, cc.size(_shadowRange, - _shadowRange), _shadowRange)
    _guildLimitLabel:setColor(_limitColor)
    _guildLimitLabel:setAnchorPoint(cc.p(0, 0))
    _guildLimitLabel:setPosition(cc.p(_guildLimitTitle:getBoundingBox().x + _guildLimitTitle:getBoundingBox().width + 55, _guildName:getPositionY()))
    _guildBg:addChild(_guildLimitLabel)

    -- 帮派人数
    local _guildNumberTitle = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.guildMemberNumberTitleTextXc .. ":", self._fontSize)
    _guildNumberTitle:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    _guildNumberTitle:setAnchorPoint(cc.p(0, 0))
    _guildNumberTitle:setPosition(cc.p(_midPosX + 50, _guildLevelTitle:getPositionY()))
    _guildBg:addChild(_guildNumberTitle)
    _guildNumberTitle:setVisible(false)
    local _numberStr =(_guildData.curSum or 0) .. "/" ..(_guildData.maxSum or 0)
    local _guildNumberLabel = XTHDLabel:create(_numberStr, self._fontSize + 4)
    _guildNumberLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("juhuangse"))
    _guildNumberLabel:setAnchorPoint(cc.p(0, 0))
    _guildNumberLabel:setPosition(cc.p(_guildNumberTitle:getBoundingBox().x + _guildNumberTitle:getBoundingBox().width + 50, _guildNumberTitle:getBoundingBox().y - 2))
    _guildBg:addChild(_guildNumberLabel)

    -- 申请加入按钮
    local applyBtn = nil
    if _guildData.applyState and tonumber(_guildData.applyState) == 0 then
        _btnEnable = true
        if _guildData.limitLevel and tonumber(gameUser.getLevel()) >= tonumber(_guildData.limitLevel) then
            applyBtn = XTHD.createCommonButton( {
                btnColor = "write_1",
                btnSize = cc.size(135,46),
                isScrollView = true,
                text = LANGUAGE_BTN_KEY.applyJoin_text,
                fontSize = self._fontSize + 4,
                fontColor = XTHD.resource.btntextcolor.write_1,
                needEnableWhenMoving = true,
            } )
            applyBtn:setScale(0.7)
            applyBtn:setTouchEndedCallback( function()
                -- if self.isScrolling~=nil and self.isScrolling == false then
                if tonumber(gameUser.getGuildId()) ~= 0 then
                    XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildCannotApplyToastXc)
                    return
                end
                self:httpToApplyGuild(_idx)
            end )
        else
            applyBtn = XTHDLabel:create(LANGUAGE_BTN_KEY.noEnoughLevel, self._fontSize + 2)
            applyBtn:setColor(BangPaiFengZhuangShuJu.getTextColor("hongse"))
        end

    else
        -- 已申请
        -- applyBtn = XTHDLabel:create(LANGUAGE_BTN_KEY.applyed,self._fontSize+2)
        -- applyBtn:setColor(BangPaiFengZhuangShuJu.getTextColor("lvse"))
        applyBtn = cc.Sprite:create("res/image/common/btn/applyed.png")
        applyBtn:setScale(0.7)

    end
    applyBtn:setAnchorPoint(cc.p(0.5, 0.5))
    applyBtn:setPosition(cc.p(_guildBg:getContentSize().width - 90, _guildBg:getContentSize().height / 2))
    -- 帮派：
    if _guildData.guildId ~= gameUser.getGuildId() then
        _guildBg:addChild(applyBtn)
    else
        applyBtn = XTHDLabel:create(LANGUAGE_BTN_KEY.alreadyexist, self._fontSize + 2)
        applyBtn:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
        -- 已是该帮派成员
        applyBtn:setAnchorPoint(cc.p(0.5, 0.5))
        applyBtn:setPosition(cc.p(_guildBg:getContentSize().width - 90, _guildBg:getContentSize().height / 2))
        _guildBg:addChild(applyBtn)
    end

    return _guildBg
end

function BangPaiLieBiao:refreshGuildState()
    if tonumber(gameUser.getGuildId()) > 0 then
        self:exchangeGuildState()
    end
end

function BangPaiLieBiao:exchangeGuildState()
    local confirmDialog = XTHDConfirmDialog:createWithParams( {
        msg = LANGUAGE_KEY_GUILD_TEXT.guildAcceptedByGuildTextXc,
        rightCallback = function()
            LayerManager.addShieldLayout()
            BangPaiFengZhuangShuJu.createGuildLayer( {
                parNode = self,
                callBack = function(...)
                    LayerManager.removeLayout()
                end
            } )
        end
    } )
    self:addChild(confirmDialog, 10)
end


function BangPaiLieBiao:getBtnNode(path)
    local _node = ccui.Scale9Sprite:create(cc.rect(50, 0, 30, 49), path)
    _node:setContentSize(cc.size(163, 49))
    return _node
end

function BangPaiLieBiao:createPageBtn(_path)
    local _pageBtn = XTHD.createButton( {
        -- normalFile = "res/image/common/btn/btn_gray_small_normal.png",
        -- selectedFile = "res/image/common/btn/btn_gray_small_selected.png"
        touchSize = cc.size(36,37)
    } )
    local _pageSp = cc.Sprite:create(_path)
    _pageSp:setPosition(cc.p(_pageBtn:getContentSize().width / 2, _pageBtn:getContentSize().height / 2))
    _pageBtn:addChild(_pageSp)
    return _pageBtn
end

function BangPaiLieBiao:createNoApplyPrompt()
    if #self.currentGuildListData < 1 then
        if self.listBg == nil or self.listBg:getChildByName("noApplyPrompt") then
            return
        end
        local _noApplyPromptSp = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.guildNoGuildListTextXc, 30)
        _noApplyPromptSp:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
        _noApplyPromptSp:setName("noApplyPrompt")
        _noApplyPromptSp:setPosition(cc.p(self.listBg:getContentSize().width / 2, self.listBg:getContentSize().height / 2))
        self.listBg:addChild(_noApplyPromptSp)
    else
        if self.listBg ~= nil and self.listBg:getChildByName("noApplyPrompt") then
            self.listBg:removeChildByName("noApplyPrompt")
        end
    end
end

function BangPaiLieBiao:previousBtnCallBack()
    if self.currentPage < 2 then
        XTHDTOAST(LANGUAGE_TIPS_WORDS225)
        return
    end
    self.currentPage = self.currentPage - 1
    self:setCurrentPageGuildListData(self.currentPage)
    self:reloadGuildList()
end

function BangPaiLieBiao:nextBtnCallBack()
    print("@@@@@@@")
    if self.currentPage > math.ceil(#self.currentGuildListData / 10 - 1) then
        XTHDTOAST(LANGUAGE_TIPS_WORDS226)
        return
    end
    self.currentPage = self.currentPage + 1
    self:setCurrentPageGuildListData(self.currentPage)
    self:reloadGuildList()
end

function BangPaiLieBiao:reloadGuildList()
    -- 加载tableview
    self.tableView:reloadData()
    self.tableView:scrollToNext()
    -- 刷新页数
    self:refreshPage()
    self:createNoApplyPrompt()
end

function BangPaiLieBiao:refreshPage()
    if self.pageLabel == nil then
        return
    end
    local _allPages = math.ceil(#self.currentGuildListData / 10 or 0)
    local _currentPage = self.currentPage or 0
    if _currentPage > _allPages then
        _currentPage = _allPages
    end
    self.pageLabel:setString(_currentPage .. "/" .. _allPages)

end

function BangPaiLieBiao:exploreGuildCallBack(_id)
    if self.bgSprite == nil then
        return
    end
    -- 显示返回列表
    if _id == nil then
        return
    end
    -- 隐藏创建帮派
    if self.bgSprite:getChildByName("createGuildBtn") then
        self.bgSprite:getChildByName("createGuildBtn"):setVisible(false)

    end
    if self.bgSprite:getChildByName("backToListBtn") then
        self.bgSprite:getChildByName("backToListBtn"):setVisible(true)
    else
        local backToListBtn = BangPaiFengZhuangShuJu.createGuildBtnNode( {
            btnSize = cc.size(135,46)
            ,
            labelStr = "backList_text"
            ,
            imgStr = "backToList"
        } )
        backToListBtn:setName("backToListBtn")
        backToListBtn:setScale(0.7)
        backToListBtn:setAnchorPoint(cc.p(1, 0.5))
        backToListBtn:getLabel():setColor(cc.c3b(119, 58, 16))
        backToListBtn:getLabel():setFontSize(28)
        backToListBtn:getLabel():setPosition(cc.p(backToListBtn:getLabel():getPositionX() -3, backToListBtn:getLabel():getPositionY() -2))
        backToListBtn:setTouchEndedCallback( function()
            self:backToGuildList()
            if self.bgSprite:getChildByName("createGuildBtn") then
                self.bgSprite:getChildByName("createGuildBtn"):setVisible(true)
            end
            if self.bgSprite:getChildByName("backToListBtn") then
                self.bgSprite:getChildByName("backToListBtn"):setVisible(false)
            end
        end )
        backToListBtn:setPosition(cc.p(self.bgSprite:getContentSize().width - 20, self.bgSprite:getContentSize().height - 45 + 2))
        self.bgSprite:addChild(backToListBtn)
    end
    local _exploreGuildData = { }
    for i = 1, #self.guildListData do
        if self.guildListData[i].guildId and tonumber(self.guildListData[i].guildId) == tonumber(_id) then
            _exploreGuildData[#_exploreGuildData + 1] = self.guildListData[i]
            break
        end
    end
    self.currentGuildListData = _exploreGuildData
    self:setCurrentPageGuildListData(1)
    self:reloadGuildList()
end

function BangPaiLieBiao:backToGuildList()

    self.currentPage = 1
    self:setCurrentGuildListData()
    self:setCurrentPageGuildListData(self.currentPage)
    self:reloadGuildList()
end

-- 创建帮派
function BangPaiLieBiao:createGuildCallBack()
    if tonumber(gameUser.getLevel()) < 21 then
        XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildCannotCreateGuildToastXc)
        return
    end
    requires("src/fsgl/layer/BangPai/BangPaiCreate.lua"):createOne()
end
-- 刷新当前cell
function BangPaiLieBiao:httpToApplyGuild(_idx)
    local _guildData = self.currentPageGuildListData[tonumber(_idx)] or { }
    if _guildData.guildId == nil or tonumber(_guildData.guildId) < 0 then
        return
    end
    ClientHttp.httpApplyJoinGuild(self, function(data)
        for i = 1, #self.guildListData do
            if self.guildListData[i].guildId and tonumber(self.guildListData[i].guildId) == tonumber(_guildData.guildId) then
                self.guildListData[i].applyState = 1
                break
            end
        end
        XTHDTOAST(LANGUAGE_KEY_GUILD_TEXT.guildSendedApplyToastXc)
        self.tableView:updateCellAtIndex(_idx - 1)
    end , { guildId = _guildData.guildId })
end


function BangPaiLieBiao:setCurrentPageGuildListData(_pageIndex)
    self.currentPageGuildListData = { }
    local _pageIdx = _pageIndex or 1
    local _startIndex = 1 +(_pageIdx - 1) * 10
    local _endIndex = _pageIdx * 10
    for i = _startIndex, _endIndex do
        if self.currentGuildListData[i] == nil or next(self.currentGuildListData[i]) == nil then
            break
        end
        self.currentPageGuildListData[#self.currentPageGuildListData + 1] = self.currentGuildListData[i]
    end
end

function BangPaiLieBiao:setCurrentGuildListData()
    self.currentGuildListData = { }
    self.currentGuildListData = self.guildListData
end

function BangPaiLieBiao:setGuildListData(_data)
    self.guildListData = { }
    if _data == nil then
        return
    end
    self.guildListData = _data.list or { }
end


function BangPaiLieBiao:createForLayerManager(sParams)
    local pLay = BangPaiLieBiao.new()
    pLay:init(sParams)
    return pLay
end

function BangPaiLieBiao:onEnter()
    -- YinDaoMarg:getInstance():addGuide( { parent = self, index = 4 }, 21)
    -- ----剧情
    -- YinDaoMarg:getInstance():doNextGuide()
end

return BangPaiLieBiao