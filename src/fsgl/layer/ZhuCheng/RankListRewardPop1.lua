local RankListRewardPop1 = class("RankListRewardPop1",function ()
	return XTHDPopLayer:create()
end)
function RankListRewardPop1:ctor( id, rank, time )
	self:init( id, rank, time )
end
function RankListRewardPop1:init( id, rank, time )
	local staticData = gameData.getDataFromCSV( "LeaderboardRewards", {type = id})
	-- 背景
    local background = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_34.png")
    background:setContentSize( 664, 484 )
    background:setPosition( self:getContentSize().width/2, self:getContentSize().height/2 )
    self:addContent( background )
    self._bgSize = cc.size( 664, 484)
    -- 关闭按钮
    local closeBtn = XTHD.createBtnClose(function()
--		self:getParent().rankListRewardBtn:setSelected(false)
        self:hide()
    end)
    closeBtn:setPosition( self._bgSize.width - 10, self._bgSize.height - 10 )
    background:addChild( closeBtn )
    -- 标题
    local titleSp = XTHD.createSprite( "res/image/ranklist/rankListReward.png" )
    titleSp:setPosition( self._bgSize.width/2, self._bgSize.height + 10 )
    background:addChild( titleSp )
    -- 排行榜奖励预览
	-- 标题背景
	local titleBg = ccui.Scale9Sprite:create( "res/image/common/common_scale_titlebg.png" )
	titleBg:setAnchorPoint( cc.p( 0, 0.5 ) )
	titleBg:setContentSize( 280, 36 )
	titleBg:setPosition( 15, self._bgSize.height - 30 )
	-- background:addChild( titleBg )
	-- 标题
	local titleLabel = XTHD.createLabel({
		text      = LANGUAGE_RANKLIST_TITLE( id ),
		fontSize  = 18,
		color     = cc.c3b( 255,255,255 ),
		clickable = false,
		--ttf = "res/fonts/def.ttf"
	})
	titleLabel:enableOutline(cc.c4b(106,36,13,255),1)
	titleLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
	titleLabel:setPosition(25, self._bgSize.height - 30)
	background:addChild( titleLabel )
	-- getCompositeNodeWithNode( titleBg, titleLabel )
	-- 领取奖励倒计时
	local fetchRewardTimerText = XTHD.createLabel({
		text      = LANGUAGE_MAINCITY_RANKLIST[7],
		fontSize  = 18,
		anchor    = cc.p( 0, 0.5 ),
		pos       = cc.p( self._bgSize.width - 275, titleLabel:getPositionY() - 2 ),
		color     = cc.c3b( 54, 55, 112 ),
		clickable = false,
	})
	background:addChild( fetchRewardTimerText )
	local fetchRewardTimerNum = XTHD.createLabel({
		text      = XTHD.getTimeHMS( time, true ),
		fontSize  = 24,
		anchor    = cc.p( 0, 0.5 ),
		pos       = cc.p( self._bgSize.width - 140, titleLabel:getPositionY() - 1 ),
		color     = XTHD.resource.color.gray_desc,
		clickable = false,
	})
	background:addChild( fetchRewardTimerNum )
    schedule( self, function()
    	if time > 0 then
    		fetchRewardTimerText:setString( LANGUAGE_MAINCITY_RANKLIST[7] )
    		fetchRewardTimerText:setPositionX( self._bgSize.width - 275 )
    		fetchRewardTimerNum:setVisible( true )
        	fetchRewardTimerNum:setString( XTHD.getTimeHMS( time, true ) )
        	time = time - 1
        else
    		fetchRewardTimerText:setString( LANGUAGE_MAINCITY_RANKLIST[11] )
    		fetchRewardTimerText:setPositionX( self._bgSize.width - 240 )
    		fetchRewardTimerNum:setVisible( false )
        end
    end, 1.0, 233 )
	-- tableviewbg
	local tableViewBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg2_25.png" )
	tableViewBg:setContentSize( self._bgSize.width - 25, 394 )
	tableViewBg:setAnchorPoint( cc.p( 0.5, 0 ) )
	tableViewBg:setPosition( self._bgSize.width*0.5-1, 45 )
	background:addChild( tableViewBg )
	-- tableView
	local tableView = cc.TableView:create( cc.size( tableViewBg:getContentSize().width - 15, tableViewBg:getContentSize().height - 90 ) )
	tableView:setPosition( 9, 86 )
	tableView:setBounceable( true )
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	tableView:setDelegate()
	tableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	tableViewBg:addChild( tableView )
	local cellSize = cc.size( tableViewBg:getContentSize().width - 8, 95 )
	local function numberOfCellsInTableView( table )
		return #staticData
	end
	local function cellSizeForTable( table, index )
		return cellSize.width,cellSize.height
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end
        -- 数据
        index = index + 1
        local data = staticData[index]
        -- cell背景
        local cellBg = ccui.Scale9Sprite:create( "res/image/common/scale9_bg_32.png" )
        cellBg:setContentSize( cellSize.width - 16, cellSize.height - 5 )
        cellBg:setAnchorPoint( cc.p( 0, 0 ) )
        cellBg:setPosition( 3, 5 )
        cell:addChild( cellBg )
        -- 分隔线
        -- local splitLine = ccui.Scale9Sprite:create( cc.rect( 0, 0, 3, 2 ), "res/image/ranklistreward/splitcell.png" )
        -- splitLine:setContentSize( cellSize.width, 2 )
        -- splitLine:setAnchorPoint( cc.p( 0.5, 0 ) )
        -- splitLine:setPosition( cellSize.width/2 + 1, 1 )
        -- cell:addChild( splitLine )
        -- 排名icon
        local rankIcon = XTHD.createSprite( "res/image/ranklistreward/"..( index > 4 and 4 or index )..".png" )
        rankIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
        rankIcon:setPosition( 48, cellSize.height*0.5 + 3 )
        cell:addChild( rankIcon )
        -- 排名文字
		local rankText   = ""
		local orderTable = string.split( data.order, "#" )
		local beginRank  = 0
		local endRank    = 0
		if #orderTable > 1 then
			beginRank = tonumber( orderTable[1] )
			endRank   = tonumber( orderTable[2] )
		elseif #orderTable == 1 then
			beginRank = tonumber( orderTable[1] )
			endRank   = beginRank
		end
        if index == #staticData then
        	rankText = LANGUAGE_KEY_RANKTEXT( 1, beginRank - 1 )
    	elseif beginRank == endRank then
        	rankText = LANGUAGE_KEY_RANKTEXT( 2, beginRank )
        else
        	rankText = LANGUAGE_KEY_RANKTEXT( 3, beginRank ,endRank )
    	end
        local rankLabel = XTHD.createLabel({
			text      = rankText,
			fontSize  = 20,
			pos       = cc.p( 140, rankIcon:getPositionY() ),
			color     = cc.c3b( 67, 28, 4 ),
			clickable = false,
    	})
    	cell:addChild( rankLabel )
    	-- 排名奖励icons
		local iconTableView = self:createIcons( data, 0.8, cellSize.width - 160, cellSize.height - 5 )
		iconTableView:setScale(0.8)
    	iconTableView:setPosition( 220, 0 )
    	cell:addChild( iconTableView )

    	return cell
	end
	tableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    tableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    tableView:reloadData()
    -- 分隔线
    -- local splitLine = ccui.Scale9Sprite:create( cc.rect( 0, 0, 3, 2 ), "res/image/ranklistreward/splitcell.png" )
    -- splitLine:setContentSize( tableViewBg:getContentSize().width, 2 )
    -- splitLine:setAnchorPoint( cc.p( 0, 0 ) )
    -- splitLine:setPosition( 1, 84 )
    -- tableViewBg:addChild( splitLine )
    -- 阴影
    -- local splitLine2 = ccui.Scale9Sprite:create( cc.rect( 28, 6, 3, 3 ), "res/image/ranklist/split.png" )
    -- splitLine2:setContentSize( tableViewBg:getContentSize().width, 15 )
    -- splitLine2:setAnchorPoint( cc.p( 0, 0 ) )
    -- splitLine2:setPosition( splitLine:getPosition() )
    -- tableViewBg:addChild( splitLine2 )
    -- 问号
    local tip = XTHD.createButton({
		normalFile = "res/image/common/btn/tip_up.png",
		selectedFile = "res/image/common/btn/tip_down.png",
	})
	tip:setPosition( 50, 42 )
	tableViewBg:addChild( tip )
	tip:setTouchEndedCallback( function()
		local tipLayer = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type = 20}); --byhuangjunjian玩法说明                              
        self:addChild( tipLayer, 3 )
	end)
	-- 我的排名奖励图片
	local myRankSprite = XTHD.createSprite( "res/image/ranklistreward/myrank.png" )
	myRankSprite:setPosition( 154, 62 )
	tableViewBg:addChild( myRankSprite )
	local myRank = rank + 1
	if myRank == -1 then
		-- 暂无
		local myRankTTFLabel = XTHD.createLabel({
	    	text = LANGUAGE_KEY_NA,
			fontSize  = 20,
			clickable = false,
		})
	    myRankTTFLabel:setPosition( 154, 28 )
	    tableViewBg:addChild( myRankTTFLabel )
	elseif myRank == 0 then
		-- 最后一档
		local myRankTTFLabel = XTHD.createLabel({
	    	text = LANGUAGE_KEY_RANKTEXT( 1, tonumber( string.split( staticData[#staticData].order, "#" )[1] ) - 1 ),
			fontSize  = 20,
			clickable = false,
		})
	    myRankTTFLabel:setPosition( 154, 28 )
	    tableViewBg:addChild( myRankTTFLabel )
	else
		-- 正常
		local myRankBMLabel = XTHD.createBMFontLabel({
			text = myRank,
			fnt = "res/fonts/yellowwordforcamp.fnt",
		})
	    myRankBMLabel:setPosition( 154, 21 )
	    tableViewBg:addChild( myRankBMLabel )
	end
	local iconData = {}
	for i = 1, #staticData do
		local data = staticData[i]
		local orderTable = string.split( data.order, "#" )
		local beginRank  = 0
		local endRank    = 0
		if #orderTable > 1 then
			beginRank = tonumber( orderTable[1] )
			endRank   = tonumber( orderTable[2] )
		elseif #orderTable == 1 then
			beginRank = tonumber( orderTable[1] )
			endRank   = beginRank
		end
		if myRank >= beginRank and myRank <= endRank then
			iconData = data
			break
		end
	end
	local iconTableView = self:createIcons( iconData, 0.8, cellSize.width - 224, 90 )
	iconTableView:setPosition( 260, -2 )
	iconTableView:setScale(0.8)
    tableViewBg:addChild( iconTableView )
	-- 奖励将在倒计时结束后以“邮件”形式自动发放，请注意查收邮箱。
	local sendText = XTHD.createLabel({
		text = LANGUAGE_MAINCITY_RANKLIST[8],
		fontSize = 16,
		color = XTHD.resource.color.gray_desc,
		pos = cc.p( self._bgSize.width/2, 35 ),
	})
    background:addChild( sendText )
end
-- 创建一排icon
function RankListRewardPop1:createIcons( data, scale, width, height )
	-- 整理数据
	local iconTable = {}
	-- 元宝
	if data.rewardingot and data.rewardingot ~= 0 then
		table.insert( iconTable, {
			_type_ = XTHD.resource.type.ingot,
			count  = data.rewardingot,
		})
	end
	-- 银两
	if data.rewardgold and data.rewardgold ~= 0 then
		table.insert( iconTable, {
			_type_ = XTHD.resource.type.gold,
			count  = data.rewardgold,
		})
	end
	-- 翡翠
	if data.rewardjade and data.rewardjade ~= 0 then
		table.insert( iconTable, {
			_type_ = XTHD.resource.type.feicui,
			count  = data.rewardjade,
		})
	end
	-- 物品1
	if data.reward1type and data.reward1type ~= 0 and data.reward1num and data.reward1num ~= 0 then
		if data.reward1type == 4 and data.reward1id ~= 0 then
			table.insert( iconTable, {
				_type_ = data.reward1type,
				itemId = data.reward1id,
				count  = data.reward1num,
			})
		elseif data.reward1type ~= 4 then
			table.insert( iconTable, {
				_type_ = data.reward1type,
				itemId = data.reward1id,
				count  = data.reward1num,
			})
		end
	end
	-- 物品2
	if data.reward2type and data.reward2type ~= 0 and data.reward2num and data.reward2num ~= 0 then
		if data.reward2type == 4 and data.reward2id ~= 0 then
			table.insert( iconTable, {
				_type_ = data.reward2type,
				itemId = data.reward2id,
				count  = data.reward2num,
			})
		elseif data.reward2type ~= 4 then
			table.insert( iconTable, {
				_type_ = data.reward2type,
				itemId = data.reward2id,
				count  = data.reward2num,
			})
		end
	end
	if isMyReward then
		for i, v in ipairs( iconTable ) do
			self._resultData[i] = {}
			self._resultData[i].rewardtype = v._type_
			self._resultData[i].num = v.count
			if v._type_ == 4 then
				self._resultData[i].id = v.itemId
			end
		end
	end
	-- 创建UI
	local tableView  = cc.TableView:create( cc.size( width-30, height ) )
	local cellWidth  = 0
	local cellHeight = height
	-- 根据数量设置大小和是否可以回弹
	if width > #iconTable * 85 * scale then
		tableView:setBounceable( true )
		cellWidth = width / #iconTable
	else
		tableView:setBounceable( true )
		cellWidth = 65 * scale
	end
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_HORIZONTAL )

	tableView:setDelegate()

	local function numberOfCellsInTableView( table )
		return #iconTable
	end
	local function cellSizeForTable( table, index )
		return cellWidth - 20,cellHeight
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end
        local icon = XTHD.createItemNode( iconTable[index + 1] )
        icon:setPosition( cellWidth * 0.5 + 10, cellHeight * 0.5 + 5 )
        icon:setScale( scale )
        cell:addChild( icon )

        return cell
    end

	tableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    tableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    tableView:reloadData()

    return tableView
end
function RankListRewardPop1:initUI()
    
end

function RankListRewardPop1:create( id, rank, time )
	return RankListRewardPop1.new( id, rank, time )
end
return RankListRewardPop1