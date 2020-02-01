--帮派事件
local BangPaiShiJian = class("BangPaiShiJian",function()
		return XTHDPopLayer:create()
	end)

function BangPaiShiJian:ctor(data,_type)
    self.showType = _type or 1   --显示类型，1：帮派日志，2：幸运转盘的我的奖品
	self.logData = {}
    self:setLogData(data)
    self:initLayer()
end

function BangPaiShiJian:initLayer()
	local _container = self:getContainerLayer()
	local _popNode = ccui.Scale9Sprite:create(cc.rect(0,0,0,0), "res/image/common/scale9_bg1_34.png" )
    _popNode:setContentSize(639,387)
	_popNode:setPosition(cc.p(_container:getContentSize().width/2,_container:getContentSize().height/2))
	_container:addChild(_popNode)

     --关闭按钮
    local close_btn = XTHD.createBtnClose(function()
        self:hide()
    end)
    close_btn:setPosition(cc.p(_popNode:getContentSize().width - 10,_popNode:getContentSize().height -10))
    _popNode:addChild(close_btn)

    local title_bg=BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277,50))
    title_bg:setAnchorPoint(0.5,1)
    title_bg:setPosition(_popNode:getContentSize().width/2,_popNode:getContentSize().height+15)
    _popNode:addChild(title_bg)
    --帮派日志或者幸运榜我的奖品
    local title_label
    if self.showType == 2 then
        title_label = XTHDLabel:create("我的奖品",24)
    else
        title_label = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.guildLogTitleTextXc,24)
    end
    title_label:setColor(cc.c3b(104, 33, 11))
    title_label:setPosition(title_bg:getContentSize().width/2,title_bg:getContentSize().height/2)
    title_bg:addChild(title_label)

    local _logPosY = 20
    local _logContentSize = cc.size(_popNode:getContentSize().width-20, title_bg:getBoundingBox().y-30)
    local _logBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_34.png")
    _logBg:setContentSize(_logContentSize)
    _logBg:setAnchorPoint(0.5,0)
    _logBg:setPosition(_popNode:getContentSize().width/2,_logPosY+5)
    _popNode:addChild(_logBg)

    local _tableViewSize = _logContentSize
    local _tableViewCellSize = cc.size(_tableViewSize.width,45)
    local _tableView = CCTableView:create(_tableViewSize)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _tableView:setBounceable(true)
    _tableView:setDelegate()
    _tableView:setPosition(cc.p(0,0))
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    _logBg:addChild(_tableView)

    local function numberOfCellsInTableView(table_view)
        return #self.logData
    end
    local function cellSizeForTable(table_view, idx)
        return _tableViewCellSize.width,_tableViewCellSize.height
    end
    local function tableCellAtIndex(table_view, idx)
        local cell = table_view:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
        end

        local _currentlogData = self.logData[idx + 1] or {}
        -- local _line = ccui.Scale9Sprite:create(cc.rect(150,0,1,1),"res/image/common/line_1.png")
        -- _line:setContentSize(cc.size(_tableViewCellSize.width,1))
        -- _line:setAnchorPoint(cc.p(0.5,0))
        -- _line:setPosition(cc.p(_tableViewCellSize.width/2,0))
        -- cell:addChild(_line)

        --cellbg
        local cellbg = BangPaiFengZhuangShuJu.createListCellBg(cc.size(_tableViewCellSize.width+10,_tableViewCellSize.height),idx+1)
        cellbg:setPosition(_tableViewCellSize.width/2,_tableViewCellSize.height/2)
        cell:addChild(cellbg)
        local _timeStr
        if self.showType == 2 then
            _timeStr = os.date("%Y-%m-%d %H:%M:%S", _currentlogData.diffTime or 0)
        else
            _timeStr = XTHD.getTimeStrBySecond(_currentlogData.diffTime or 0)
        end
        local _timelabel = XTHDLabel:createWithSystemFont(_timeStr,"Helvetica",18)
        -- XTHDLabel:create(_timeStr,18)
        _timelabel:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
        _timelabel:setAnchorPoint(cc.p(0,0.5))
        _timelabel:setPosition(cc.p(11,_tableViewCellSize.height/2))
        cell:addChild(_timelabel)

        local _contentStr = _currentlogData.content or ""
        local _contentLabel = XTHDLabel:createWithSystemFont(_contentStr,"Helvetica",18)
        -- XTHDLabel:create(_contentStr,18
        _contentLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
        _contentLabel:setAnchorPoint(cc.p(0,0.5))
        if self.showType == 2 then
            _contentLabel:setPosition(cc.p(210,_tableViewCellSize.height/2))
        else
            _contentLabel:setPosition(cc.p(110,_tableViewCellSize.height/2))
        end
        cell:addChild(_contentLabel)

        return cell
    end
    _tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    

    if #self.logData > 0 then
        _tableView:reloadData()
    else
        local none_label
        if self.showType == 2 then
             none_label = XTHDLabel:create("暂无奖品",24)
        else
             none_label = XTHDLabel:create(LANGUAGE_KEY_GUILD_TEXT.noneGuildLogTextXc,24)
        end 
        none_label:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
        none_label:setPosition(_logBg:getContentSize().width/2,_logBg:getContentSize().height/2)
        _logBg:addChild(none_label)
    end

    self:show()
end

function BangPaiShiJian:setLogData(data)
	self.logData = {}
	if data == nil then
		return
	end
	self.logData = data.list or {}
	table.sort(self.logData,function(data1,data2)
			return tonumber(data1.diffTime)>tonumber(data2.diffTime)
		end)
end

function BangPaiShiJian:create(data,_type)
	local _layer = self.new(data,_type)
	return _layer
end

return BangPaiShiJian