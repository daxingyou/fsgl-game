--created By xingchen
--2015/10/24
--运镖战斗记录
local YaYunLiangCaoRecordPopLayer = class("YaYunLiangCaoRecordPopLayer",function ()
	return XTHD.createPopLayer()
end)

function YaYunLiangCaoRecordPopLayer:ctor(data)
	self:initUI(data)
end

function YaYunLiangCaoRecordPopLayer:initUI(data)
	local _recordData = data and data.list or {}
    table.sort(_recordData,function(data1,data2)
    	return tonumber(data1.time)<tonumber(data2.time)
    end)

	local Bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
	Bg:setContentSize(cc.size(650,453))
	Bg:setPosition(self:getBoundingBox().width/2,self:getBoundingBox().height/2)
	self:addContent(Bg)

	local titleBg = BangPaiFengZhuangShuJu.createTitleNameBg(cc.size(277, 50))
	titleBg:setAnchorPoint(0.5,0.5)
	titleBg:setPosition(Bg:getBoundingBox().width/2,Bg:getBoundingBox().height-13)
	Bg:addChild(titleBg)

	local titleLabel = XTHDLabel:createWithParams({
		text = LANGUAGE_KEY_FIGHTRECORD,----"战斗记录",
        fontSize = 28,
        color = cc.c3b(104, 33, 11)
	})
	titleLabel:setPosition(titleBg:getBoundingBox().width/2,titleBg:getBoundingBox().height/2 + 5)
	titleBg:addChild(titleLabel)

	local _resultStrTable = {
		{
			LANGUAGE_KEY_ESCORTRECORD7,
			LANGUAGE_KEY_ESCORTRECORD8
		},{
			LANGUAGE_KEY_ESCORTRECORD9,
			LANGUAGE_KEY_ESCORTRECORD10
		}
	}

    
    if #_recordData<1 then
        local _noRecord = XTHDLabel:create(LANGUAGE_KEY_ESCORTRECORD6,30)    
        _noRecord:setColor(XTHD.resource.color.brown_desc)
        _noRecord:setPosition(cc.p(Bg:getContentSize().width/2,Bg:getContentSize().height/2-20))
        Bg:addChild(_noRecord)
    end

    -- tableView背景
    local tableViewBg = ccui.Scale9Sprite:create()
    tableViewBg:setContentSize( 628, 374 )
    tableViewBg:setAnchorPoint( cc.p( 0, 0 ) )
    tableViewBg:setPosition( (Bg:getBoundingBox().width-628)/2, 30 )
    Bg:addChild( tableViewBg )

	self._recordTable = CCTableView:create(cc.size(620,385))
    self._recordTable:setPosition((Bg:getBoundingBox().width-620)/2, 30)
    self._recordTable:setBounceable(true)
    self._recordTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL) --设置横向纵向
    self._recordTable:setDelegate()
    self._recordTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    Bg:addChild(self._recordTable)

    local function cellSizeForTable(table,idx)
        return 620,112
    end

    local function numberOfCellsInTableView(table)
        return #_recordData
    end

    local function tableCellTouched(table,cell)
    end

    local function tableCellAtIndex(table1,idx)
        local cell = table1:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
        else
            cell:removeAllChildren()
        end

        local nowData = _recordData[idx+1]

        local cell_bg = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png" )--ccui.Scale9Sprite:create(cc.rect(52,52,1,1),"res/image/common/scale9_bg_3.png")
        cell_bg:setContentSize(619,106)
        cell_bg:setAnchorPoint(0,0)
        cell_bg:setPosition( 0, 3 )
        cell:addChild(cell_bg)

        -- 分隔线
        -- local splitCellLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
        -- splitCellLine:setContentSize( cell_bg:getBoundingBox().width + 8, 2 )
        -- splitCellLine:setAnchorPoint( cc.p( 0.5, 0 ) )
        -- splitCellLine:setPosition( cell_bg:getBoundingBox().width*0.5, -2 )
        -- cell:addChild( splitCellLine )

        local split = cc.Sprite:create("res/image/plugin/competitive_layer/split.png")
        split:setPosition(120,cell_bg:getBoundingBox().height/2)
        cell_bg:addChild(split)

        local timeNum = math.ceil(nowData.time/60)
        local timePath = "res/image/plugin/competitive_layer/min_before.png"
        if timeNum > 60 then
        	timeNum = math.floor(timeNum/60)
        	timePath = "res/image/plugin/competitive_layer/hour_before.png"
        	if timeNum > 24 then
	        	timeNum = math.floor(timeNum/24)
	        	timePath = "res/image/plugin/competitive_layer/day_before.png"
	        	if timeNum > 7 then
		        	timeNum = 7
		        end
	        end
        end

        local timeLabel = getCommonWhiteBMFontLabel(timeNum)
        timeLabel:setAnchorPoint(0,0.5)

        local strLabel = cc.Sprite:create(timePath)
        strLabel:setAnchorPoint(0,0.5)

        timeLabel:setPosition((120-timeLabel:getBoundingBox().width-strLabel:getBoundingBox().width)/2,cell_bg:getBoundingBox().height/2-7)
        cell_bg:addChild(timeLabel)
        strLabel:setPosition(timeLabel:getPositionX()+timeLabel:getBoundingBox().width,cell_bg:getBoundingBox().height/2)
        cell_bg:addChild(strLabel)

        local _labelTypeStrBegan = LANGUAGE_KEY_ESCORTRECORD1
        local _labelTypeStrEnd = LANGUAGE_KEY_ESCORTRECORD3
        local _resultStrData = _resultStrTable[1]
        if nowData["type"] and tonumber(nowData["type"]) == 0 then
        	_labelTypeStrBegan = LANGUAGE_KEY_ESCORTRECORD1
        	_labelTypeStrEnd = LANGUAGE_KEY_ESCORTRECORD3
        	_resultStrData = _resultStrTable[1]
        else
        	_labelTypeStrBegan = LANGUAGE_KEY_ESCORTRECORD2
        	_labelTypeStrEnd = LANGUAGE_KEY_ESCORTRECORD4
        	_resultStrData = _resultStrTable[2]
        end
        local _campStr = tonumber(nowData.campId) == 1 and LANGUAGE_CAMP_NAME1 or LANGUAGE_CAMP_NAME2
        local _resultStr = tonumber(nowData.result) == 1 and _resultStrData[1] or _resultStrData[2]

        local _typeLabelBegan = XTHDLabel:createWithParams({
	        	text = _labelTypeStrBegan,
	        	fontSize = 18,
	        	color = XTHD.resource.color.brown_desc
	        })
        _typeLabelBegan:setAnchorPoint(cc.p(0,0.5))
        _typeLabelBegan:setPosition(cc.p(split:getPositionX()+30,cell_bg:getBoundingBox().height-40))
        cell_bg:addChild(_typeLabelBegan)

        local _campLabel = XTHDLabel:createWithParams({
	        	text = _campStr,
	        	fontSize = 20,
	        	color = XTHD.resource.color.brown_desc
	        })
        _campLabel:enableShadow(XTHD.resource.color.brown_desc, cc.size(0.4,-0.4), 0.4)
        _campLabel:setAnchorPoint(cc.p(0,0))
        _campLabel:setPosition(cc.p(_typeLabelBegan:getBoundingBox().x+_typeLabelBegan:getBoundingBox().width+3,_typeLabelBegan:getBoundingBox().y))
        cell_bg:addChild(_campLabel)

        local _playLabel = XTHDLabel:createWithParams({
	        	text = LANGUAGE_KEY_ESCORTRECORD5,
	        	fontSize = 18,
	        	color = XTHD.resource.color.brown_desc
	        })
        _playLabel:setAnchorPoint(cc.p(0,0))
        _playLabel:setPosition(cc.p(_campLabel:getBoundingBox().x+_campLabel:getBoundingBox().width+3,_campLabel:getBoundingBox().y))
        cell_bg:addChild(_playLabel)

        local _playNameLabel = XTHDLabel:createWithSystemFont(nowData.charName or "","Helvetica",20)
        _playNameLabel:setColor(XTHD.resource.color.brown_desc)
        _playNameLabel:enableShadow(XTHD.resource.color.brown_desc, cc.size(0.4,-0.4), 0.4)
        _playNameLabel:setAnchorPoint(cc.p(0,0))
        _playNameLabel:setPosition(cc.p(_playLabel:getBoundingBox().x+_playLabel:getBoundingBox().width+3,_playLabel:getBoundingBox().y-2))
        cell_bg:addChild(_playNameLabel)

        local _typeLabelEnd = XTHDLabel:createWithParams({
	        	text = _labelTypeStrEnd,
	        	fontSize = 18,
	        	color = XTHD.resource.color.brown_desc
	        })
        _typeLabelEnd:setAnchorPoint(cc.p(0,0))
        _typeLabelEnd:setPosition(cc.p(_playNameLabel:getBoundingBox().x+_playNameLabel:getBoundingBox().width+3,_playLabel:getBoundingBox().y))
        cell_bg:addChild(_typeLabelEnd)

        --结果
        local _resultLabel = XTHDLabel:createWithParams({
	        	text = _resultStr,
	        	fontSize = 18,
	        	color = XTHD.resource.color.brown_desc
	        })
        _resultLabel:setAnchorPoint(cc.p(0,0.5))
        _resultLabel:setPosition(cc.p(_typeLabelBegan:getBoundingBox().x,40))
        cell_bg:addChild(_resultLabel)

        return cell
    end

    self._recordTable:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._recordTable:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
    self._recordTable:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    self._recordTable:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    self._recordTable:reloadData()

    self:show()
end

function YaYunLiangCaoRecordPopLayer:create(data)
	return YaYunLiangCaoRecordPopLayer.new(data)
end

return YaYunLiangCaoRecordPopLayer