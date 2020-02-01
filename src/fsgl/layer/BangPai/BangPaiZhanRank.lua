--createdBy xingchen 
--2015/11/23
--帮派战确认主将界面
local BangPaiZhanRank = class("BangPaiZhanRank",function()
	    return XTHD.createBasePageLayer()
	end)
function BangPaiZhanRank:ctor(data)
	self.gradeRankData = {}
    self.verticalPos = {}
	self:setGradeRankData(data)
	self:initLayer()
end

function BangPaiZhanRank:initLayer()
    local _topBarHeight = self.topBarHeight or 40
    local _bg = cc.Sprite:create("res/image/common/layer_bottomBg.png")
    _bg:setPosition(cc.p(self:getContentSize().width/2,(self:getContentSize().height - _topBarHeight)/2 ))
    self:addChild(_bg)
	self._bg = _bg

	local title = "res/image/public/paiming_title.png"
	XTHD.createNodeDecoration(self._bg,title)

    table.sort(self.gradeRankData.list,function(data1,data2)
    		return tonumber(data1.rank) < tonumber(data2.rank)
    	end)

    local _distance = 4
    local _distanceHeight = 22
    local _listBg = BangPaiFengZhuangShuJu.createListBg(cc.size(self._bg:getContentSize().width - _distance*2,self._bg:getContentSize().height - _distanceHeight*2))
    self.listBg = _listBg
    _listBg:setAnchorPoint(cc.p(0.5,0))
    _listBg:setPosition(cc.p(_bg:getContentSize().width/2,_distanceHeight))
    _bg:addChild(_listBg)

    --Down
    local _downPosY = 50
    local _yourRankSp = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.myRankTextXc .. ":",18)
    _yourRankSp:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    _yourRankSp:setAnchorPoint(cc.p(0,0.5))
    _yourRankSp:setPosition(cc.p(60,_downPosY/2))
    _listBg:addChild(_yourRankSp)
    local _yourRankLabel = XTHDLabel:create(self.gradeRankData.myGuildRank or 0,24)
    _yourRankLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("hongse"))
    _yourRankLabel:setAnchorPoint(cc.p(0,0.5))
    _yourRankLabel:setPosition(cc.p(_yourRankSp:getBoundingBox().x+_yourRankSp:getBoundingBox().width+4,_yourRankSp:getPositionY()))
    _listBg:addChild(_yourRankLabel)

    local _yourGrade = XTHDLabel:create(LANGUAGE_KEY_GUILDWAR_TEXT.guildGradeTextXc .. ":",18)
    _yourGrade:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    _yourGrade:setAnchorPoint(cc.p(1,0.5))
    _yourGrade:setPosition(cc.p(_listBg:getContentSize().width - 155,_downPosY/2))
    _listBg:addChild(_yourGrade)
    local _yourGradeLabel = XTHDLabel:create(self.gradeRankData.myGuildJifen or 0,24)
    _yourGradeLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("hongse"))
    _yourGradeLabel:setAnchorPoint(cc.p(0,0.5))
    _yourGradeLabel:setPosition(cc.p(_yourGrade:getBoundingBox().x+_yourGrade:getBoundingBox().width+4,_yourGrade:getPositionY()))
    _listBg:addChild(_yourGradeLabel)

    local _linePosY = _listBg:getContentSize().height-35
    -- local _upline = BangPaiFengZhuangShuJu.createListLine(_listBg:getContentSize().width - 4)
    -- _upline:setAnchorPoint(cc.p(0.5,0.5))
    -- _upline:setPosition(cc.p(_listBg:getContentSize().width/2,_linePosY))
    -- _listBg:addChild(_upline)
    local _verticalPosTable = {0.16,0.29,0.32,0.23}
    local _imgKeyTable = {"rank","name","memberSum","grade"}


    local _linePosX = 0
    for i=1,#_verticalPosTable do
        local _curWidth = _listBg:getContentSize().width * _verticalPosTable[i]
        self.verticalPos[i] = _curWidth
        _linePosX = _curWidth + _linePosX
        local _titleLabel = XTHDLabel:create(LANGUAGE_GUILDTITLE_KEY[_imgKeyTable[i]],18)
        _titleLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
        _titleLabel:setAnchorPoint(cc.p(0.5,0.5))
        _titleLabel:setPosition(cc.p(_linePosX - _curWidth/2,_linePosY + 34/2))
        _listBg:addChild(_titleLabel)

        if i~=(#_verticalPosTable) then
            local _lineHeight = 32
            local _verticalLine = BangPaiFengZhuangShuJu.createListVerticalLine(_lineHeight)
            -- _verticalLine:setScaleY(35/_verticalLine:getContentSize().height)
            -- ccui.Scale9Sprite:create(cc.rect(0,34,2,1),)
            _verticalLine:setAnchorPoint(cc.p(0.5,0.5))
            _verticalLine:setPosition(cc.p(_linePosX,_linePosY + _lineHeight/2))
            _listBg:addChild(_verticalLine)
        end
    end

    local _tableViewSize = cc.size(_listBg:getContentSize().width,_listBg:getContentSize().height-35-_downPosY)
    local _tableViewCellSize = cc.size(_tableViewSize.width,64)
    self.tableViewCellSize = _tableViewCellSize
    local _tableView = CCTableView:create(_tableViewSize)
    _tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    _tableView:setBounceable(true)
    _tableView:setDelegate()
    _tableView:setPosition(cc.p(0,_downPosY))
    _tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    _listBg:addChild(_tableView)

    local function numberOfCellsInTableView(table_view)
        return #self.gradeRankData.list
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
        local _cellBg = self:createCellSprite(idx+1)
        _cellBg:setPosition(cc.p(_tableViewCellSize.width/2,_tableViewCellSize.height/2))
        cell:addChild(_cellBg)

        -- if idx ~=#self.gradeRankData.list-1 then
        --     local _lineSp = BangPaiFengZhuangShuJu.createListLine(_tableViewCellSize.width - 2)
        --     _lineSp:setPosition(cc.p(_tableViewCellSize.width/2,0)) 
        --     cell:addChild(_lineSp)
        -- end

        return cell
    end
    _tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    _tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    _tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    _tableView:reloadData()

end

function BangPaiZhanRank:createCellSprite(_idx)
    local _distance = 3
    local _guildBg = BangPaiFengZhuangShuJu.createListCellBg(cc.size(self.tableViewCellSize.width - _distance*2,self.tableViewCellSize.height - 4*2))

    local _guildData = self.gradeRankData.list[tonumber(_idx)] or {}
    if next(_guildData)==nil then
        return _guildBg
    end
    -- local _verticalPosTable = {120,240,255,300}
    local _linePosX = 0-_distance
    local _labelKeyTable = {"rank","guildName","curSum","jifen"}
    local _linePosY = _guildBg:getContentSize().height/2
    for i=1,#self.verticalPos do
        _linePosX = self.verticalPos[i] + _linePosX
        if i ~= #self.verticalPos then
            local _lineHeight = 32
            local _verticalLine = BangPaiFengZhuangShuJu.createListVerticalLine(_guildBg:getContentSize().height - 2)
            _verticalLine:setAnchorPoint(cc.p(0.5,0.5))
            _verticalLine:setPosition(cc.p(_linePosX,_linePosY))
            _guildBg:addChild(_verticalLine)
        end

        local _labelStr = _guildData[_labelKeyTable[i]] or ""
        local _fontSize = 24

        if i==1 then
            local _imgKey = tonumber(_labelStr)<4 and tonumber(_labelStr) or 4
            local _rankSp = cc.Sprite:create("res/image/ranklist/rank_" .. _imgKey .. ".png")
            if _imgKey == 4 then
                _rankSp:setScale(0.7)
            end
        	_rankSp:setAnchorPoint(cc.p(0.5,0.5))
        	_rankSp:setPosition(cc.p(_linePosX - self.verticalPos[i]/2,_guildBg:getContentSize().height/2))
        	_guildBg:addChild(_rankSp)
            if tonumber(_labelStr)>3 then
                local rank_idx=cc.Label:createWithBMFont("res/fonts/paihangbangword.fnt",_labelStr)
                rank_idx:setPosition(_rankSp:getContentSize().width/2,_rankSp:getContentSize().height/2 - 7)
                _rankSp:addChild(rank_idx)
            end
            
    	elseif i==2 then
            if tonumber(_guildData["campId"]) ~=1 and tonumber(_guildData["campId"]) ~=2 then
                _guildData["campId"] = 1
            end
    		local _campSp = cc.Sprite:create("res/image/camp/camp_icon_small" .. _guildData["campId"] .. ".png")
            _campSp:setScale(0.8)
            _campSp:setPosition(cc.p(_linePosX - self.verticalPos[i]/2 - 90,_guildBg:getContentSize().height/2))
            _guildBg:addChild(_campSp)
    		local _guildNameLabel = XTHDLabel:create(_labelStr,20)
            _guildNameLabel:setAnchorPoint(cc.p(0,0.5))
    		_guildNameLabel:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    		_guildNameLabel:setPosition(cc.p(_campSp:getBoundingBox().x+_campSp:getBoundingBox().width + 8,_guildBg:getContentSize().height/2))
    		
    		_guildBg:addChild(_guildNameLabel)
    	else
    		local _value = XTHDLabel:create(_labelStr,24)
    		_value:setColor(BangPaiFengZhuangShuJu.getTextColor("shenhese"))
    		_value:setPosition(cc.p(_linePosX - self.verticalPos[i]/2,_guildBg:getContentSize().height/2))
    		_guildBg:addChild(_value)
        end
	end

    return _guildBg
end

function BangPaiZhanRank:setGradeRankData(data)
	self.gradeRankData = {}
	self.gradeRankData = data or {}
end

function BangPaiZhanRank:create(data)
	local _layer = self.new(data)
	return _layer
end

return BangPaiZhanRank