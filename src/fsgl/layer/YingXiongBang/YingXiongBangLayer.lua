--[[
	排行榜奖励界面
	唐实聪
	2015.11.6
]]
local YingXiongBangLayer  = class( "YingXiongBangLayer", function ( ... )
	return XTHD.createBasePageLayer()
end )

function YingXiongBangLayer:ctor( params )
	if params and params.CallFunc then
		self._callFunc = params.CallFunc
	end
	self:initUI( params )
end

function YingXiongBangLayer:onCleanup()
    if self._callFunc then
    	self._callFunc()
    end
end

function YingXiongBangLayer:initUI( params )
	-- 底层背景
	local bottomBackground = XTHD.createSprite( "res/image/common/layer_bottomBg.png" )
	bottomBackground:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	bottomBackground:setPosition( self:getContentSize().width * 0.5, ( self:getContentSize().height - self.topBarHeight ) * 0.5 )
	self._bottomBackground = bottomBackground
	self._bottomSize = bottomBackground:getContentSize()
	self:addChild( bottomBackground )
	-- 全局参数
	self._size       = self:getContentSize()
	self._index      = ( params and params.index and tonumber( params.index ) ) or 1
	self._rank       = ( params and params.rank and ( tonumber( params.rank ) + 1 ) ) or 0
	self._time       = ( params and params.time and tonumber( params.time ) ) or 0
	self._fetch      = ( params and params.state and tonumber( params.state ) ) or 0
	self._dataTable  = gameData.getDataFromCSV( "LeaderboardRewards", {type = self._index})
	self._resultData = {}
	-- 创建界面
	self:initTabs()
	self:initRewardPreview()
	self:initMyReward()
end
-- 创建右侧tabs
function YingXiongBangLayer:initTabs()
	-- 中层背景
	local middleBackground = XTHD.createSprite( "res/image/common/tab_contentBg.png" )
	middleBackground:setAnchorPoint( cc.p( 1, 0.5 ) )
	middleBackground:setPosition( ( self._bottomSize.width + self._size.width ) * 0.5 - 50, self._bottomSize.height * 0.5 )
	self._bottomBackground:addChild( middleBackground, 1 )
	-- tabs按钮
	local tabsTable = {}
	-- tabs文字路径
	local tabsPathTable = {
		"res/image/ranklistreward/power.png",
		"res/image/ranklistreward/compete.png",
		"res/image/ranklistreward/level.png",
		"res/image/ranklistreward/star.png",
	}
	-- tab点击回调
	local function tabCallback( index )
		if self._index ~= index then
            tabsTable[self._index]:setSelected( false )
			tabsTable[self._index]:setEnable( true )
			tabsTable[self._index]:setLocalZOrder( 0 )
			tabsTable[index]:setSelected( true )
			tabsTable[index]:setEnable( false )
			tabsTable[index]:setLocalZOrder( 1 )
			ClientHttp:requestAsyncInGameWithParams({
				modules = "topRewardData?",
				params  = {rewardType = index},
                successCallback = function( data )
                    if tonumber( data.result ) == 0 then
						self._index     = index
						self._rank      = data.rank and ( tonumber( data.rank ) + 1 ) or 0
						self._time      = data.time and tonumber( data.time ) or 0
						self._fetch     = data.state and tonumber( data.state ) or 0
						self._dataTable = gameData.getDataFromCSV( "LeaderboardRewards", {type = self._index})
						self:refreshUI()
                    else
                      	XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败"..data.result)
                    end 
                end,
                failedCallback = function()
                    tabsTable[index]:setSelected( false )
					tabsTable[index]:setEnable( true )
					tabsTable[index]:setLocalZOrder( 0 )
					tabsTable[self._index]:setSelected( true )
					tabsTable[self._index]:setEnable( false )
					tabsTable[self._index]:setLocalZOrder( 1 )
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
				loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
				loadingParent = self,
            })
		end
	end
	-- 循环创建tab
	for i = 1, 4 do
		local tabBtn_normal = ccui.Scale9Sprite:create( cc.rect( 25, 20, 1, 1 ), "res/image/common/btn/btn_smallTab_normal.png" )
		tabBtn_normal:setContentSize( 71, 54 )
		local tabBtn_selected = ccui.Scale9Sprite:create( cc.rect( 25, 20, 1, 1 ), "res/image/common/btn/btn_smallTab_selected.png" )
		tabBtn_selected:setContentSize( 71, 54 )
		local tabBtn = XTHD.createButton({
			normalNode   = tabBtn_normal,
			selectedNode = tabBtn_selected,
			endCallback = function( )
				tabCallback( i )
			end,
		})
		tabBtn:setAnchorPoint( cc.p( 1, 0.5 ) )
		tabBtn:setPosition( self._bottomSize.width * 0.5 + self._size.width * 0.5, self._bottomSize.height + 7 - 57 * i )
		local textSprite = XTHD.createSprite( tabsPathTable[i] )
		self._bottomBackground:addChild( getCompositeNodeWithNode( tabBtn, textSprite ), 0 )
		tabsTable[i] = tabBtn
	end
	tabsTable[self._index]:setSelected( true )
	tabsTable[self._index]:setEnable( false )
	tabsTable[self._index]:setLocalZOrder( 1 )
end
-- 创建奖励预览
function YingXiongBangLayer:initRewardPreview()
	-- 容器
	local previewBg = XTHD.createSprite()
	previewBg:setContentSize( self._size.width - 71 - self._size.width * 0.38, self._bottomSize.height - 38 )
    previewBg:setAnchorPoint( cc.p( 0, 0.5 ) )
    previewBg:setPosition( ( self._bottomSize.width - self._size.width ) * 0.5, self._bottomSize.height * 0.5 )
    self._bottomBackground:addChild( previewBg, 2 )
    -- 本容器内使用的size
    local previewSize = previewBg:getContentSize()
	-- 标题背景
	local titleBg = ccui.Scale9Sprite:create( "res/image/common/common_scale_titlebg.png" )
	titleBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	titleBg:setContentSize( 280, 34 )
	titleBg:setPosition( previewSize.width * 0.5, previewSize.height - 23 )
	previewBg:addChild( titleBg )
	-- 标题
	local transformTitle = {
		LANGUAGE_KEY_POWERNOCOLON,
		LANGUAGE_KEY_COMPETE,
		LANGUAGE_KEY_LEVEL,
		LANGUAGE_KEY_STARLEVEL,
	}
	local titleLabel = XTHD.createLabel({
		text      = LANGUAGE_KEY_RANKLISTREWARD( transformTitle[self._index] ),
		fontSize  = 16,
		pos       = cc.p( titleBg:getPosition() ),
		color     = cc.c3b( 67, 28, 4 ),
		clickable = false,
	})
	self._titleLabel = titleLabel
	previewBg:addChild( titleLabel )
	-- tableView背景
	local tableViewBg = ccui.Scale9Sprite:create("res/image/common/scale9_bg_25.png")
	tableViewBg:setAnchorPoint( cc.p( 0, 0 ) )
	tableViewBg:setContentSize( previewSize.width - 6, previewSize.height - 44 )
	tableViewBg:setPosition( 4, 0 )
	previewBg:addChild( tableViewBg )
	-- 预览tableView
	local previewTableView = CCTableView:create( cc.size( previewSize.width - 6, previewSize.height - 54 ) )
	previewTableView:setPosition( 4, 5 )
	previewTableView:setBounceable( true )
	previewTableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	previewTableView:setDelegate()
	previewTableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	self._previewTableView = previewTableView
	previewBg:addChild( previewTableView )

	local function numberOfCellsInTableView( table )
		return #self._dataTable
	end
	local function cellSizeForTable( table, index )
		return previewSize.width - 6,95
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
        local data = self._dataTable[index]
        -- cell背景
        local cellBg = ccui.Scale9Sprite:create( "res/image/common/scale9_bg_26.png" )
        cellBg:setContentSize( previewSize.width - 14, 88 )
        cellBg:setAnchorPoint( cc.p( 0, 0 ) )
        cellBg:setPosition( 4, 5 )
        cell:addChild( cellBg )
        -- 分隔线
        local splitLine = ccui.Scale9Sprite:create( cc.rect( 0, 0, 3, 2 ), "res/image/ranklistreward/splitcell.png" )
        splitLine:setContentSize( previewSize.width - 10, 2 )
        splitLine:setAnchorPoint( cc.p( 0, 0 ) )
        splitLine:setPosition( 1, 0 )
        cell:addChild( splitLine )
        -- 排名icon
        local rankIcon = XTHD.createSprite( "res/image/ranklistreward/"..( index > 4 and 4 or index )..".png" )
        rankIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
        rankIcon:setPosition( 48, cellBg:getContentSize().height * 0.5 + 5 )
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
        if index == #self._dataTable then
        	rankText = LANGUAGE_KEY_RANKTEXT( 1, beginRank - 1 )
    	elseif beginRank == endRank then
        	rankText = LANGUAGE_KEY_RANKTEXT( 2, beginRank )
        else
        	rankText = LANGUAGE_KEY_RANKTEXT( 3, beginRank ,endRank )
    	end
        local rankLabel = XTHD.createLabel({
			text      = rankText,
			fontSize  = 20,
			pos       = cc.p( 140, cellBg:getContentSize().height * 0.5 + 5 ),
			color     = cc.c3b( 67, 28, 4 ),
			clickable = false,
    	})
    	cell:addChild( rankLabel )
    	-- 排名奖励icons
    	local iconTableView = self:createIcons( data, 0.8, previewSize.width - 224, cellBg:getContentSize().height )
    	iconTableView:setPosition( 200, 0 )
    	cell:addChild( iconTableView )

    	return cell
	end
	previewTableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    previewTableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    previewTableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    previewTableView:reloadData()
end
-- 创建我的奖励
function YingXiongBangLayer:initMyReward()
	-- 背景
	local myRewardBg = ccui.Scale9Sprite:create(  )
	myRewardBg:setContentSize( self._size.width * 0.38, self._bottomSize.height - 57 )
	myRewardBg:setAnchorPoint( cc.p( 0, 0 ) )
	myRewardBg:setPosition( self._bottomSize.width * 0.5 + self._size.width * 0.5 - 71 - self._size.width * 0.38, 30 )
	self._bottomBackground:addChild( myRewardBg, 2 )
	-- 本容器内使用的size
	local myRewardSize = myRewardBg:getContentSize()
	self._myRewardSize = myRewardSize
    -- 过渡
    local splitSprite = XTHD.createSprite( "res/image/ranklistreward/splitY.png" )
	splitSprite:setAnchorPoint( cc.p( 0, 0.5 ) )
	splitSprite:setPosition( 0, myRewardSize.height * 0.5 )
	splitSprite:setFlippedX( true )
	myRewardBg:addChild( splitSprite )
	-- 我的排名奖励背景
	local myRankBg = XTHD.createSprite( "res/image/ranklistreward/myrewardbg.png" )
	myRankBg:setAnchorPoint( cc.p( 0.5, 0 ) )
	myRankBg:setPosition( myRewardSize.width * 0.5, myRewardSize.height - 53 )
	myRewardBg:addChild( myRankBg )
	-- 我的排名奖励图片
	local myRankSprite = XTHD.createSprite( "res/image/ranklistreward/myrank.png" )
	myRankSprite:setAnchorPoint( cc.p( 0, 0.5 ) )
	myRankSprite:setPosition( 20, myRankBg:getContentSize().height * 0.5 )
	myRankBg:addChild( myRankSprite )
	-- 我的排名BM
	local myRankBMLabel = XTHD.createBMFontLabel({
		fnt = "res/fonts/yellowwordforcamp.fnt",
	})
    myRankBMLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
    myRankBMLabel:setPosition( myRankSprite:getContentSize().width + 24, myRankBg:getContentSize().height * 0.5 - 3 )
    self._myRankBMLabel = myRankBMLabel
    myRankBg:addChild( myRankBMLabel )
    -- 我的排名TTF
    local myRankTTFLabel = XTHD.createLabel({
		fontSize  = 20,
		clickable = false,
	})
	myRankTTFLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
    myRankTTFLabel:setPosition( myRankSprite:getContentSize().width + 24, myRankBg:getContentSize().height * 0.5 )
    self._myRankTTFLabel = myRankTTFLabel
    myRankBg:addChild( myRankTTFLabel )
    -- 奖励排名
    local descTitleLabel = XTHD.createLabel({
		text      = LANGUAGE_KEY_REWARDRANK,
		fontSize  = 18,
		pos       = cc.p( 22, myRewardSize.height - 80 ),
		color     = cc.c3b( 205, 101, 8 ),
		clickable = false,
	})
    descTitleLabel:setAnchorPoint( cc.p( 0, 0 ) )
	myRewardBg:addChild( descTitleLabel )
	-- 奖励排名描述
	local descLabel = XTHD.createLabel({
		text      = LANGUAGE_KEY_REWARDRANKDESC,
		fontSize  = 18,
		pos       = cc.p( 22, myRewardSize.height - 140 ),
		color     = cc.c3b( 67, 28, 4 ),
		clickable = false,
	})
	descLabel:setWidth( 295 )
    descLabel:setAnchorPoint( cc.p( 0, 0 ) )
	descLabel:setContentSize( 320, 100 )
	myRewardBg:addChild( descLabel )
	-- 分隔线
	local splitLine1 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
	splitLine1:setContentSize( myRewardSize.width, 2 )
	splitLine1:setAnchorPoint( cc.p( 0, 0 ) )
	splitLine1:setPosition( 0, myRewardSize.height - 170 )
	myRewardBg:addChild( splitLine1 )
	-- 倒计时文字
	local timerTitleLabel = XTHD.createLabel({
		text      = LANGUAGE_KEY_REWARDTIMERTIP,
		fontSize  = 18,
		pos       = cc.p( 22, myRewardSize.height * 0.5 + 25 ),
		color     = cc.c3b( 205, 101, 8 ),
		clickable = false,
	})
    timerTitleLabel:setAnchorPoint( cc.p( 0, 0 ) )
	myRewardBg:addChild( timerTitleLabel )
	-- 倒计时数字
	local timerLabel = XTHD.createLabel({
		text      = self:transformTime( self._time ),
		fontSize  = 24,
		pos       = cc.p( myRewardSize.width * 0.5, myRewardSize.height * 0.5 ),
		color     = cc.c3b( 67, 28, 4 ),
		clickable = false,
	})
    timerLabel:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    self._timerLabel = timerLabel
	myRewardBg:addChild( timerLabel )
	-- 倒计时函数
	local function countDown()
		self._time = self._time - 1
		if self._time < 0 then
			self:stopActionByTag( 233 )
			ClientHttp:requestAsyncInGameWithParams({
				modules = "topRewardData?",
				params  = {rewardType = self._index},
                successCallback = function( data )
                    if tonumber( data.result ) == 0 then
						self._rank      = data.rank and ( tonumber( data.rank ) + 1 ) or 0
						self._time      = data.time and tonumber( data.time ) or 0
						self._fetch     = data.state and tonumber( data.state ) or 0
						self._dataTable = gameData.getDataFromCSV( "LeaderboardRewards", {type = self._index})
						self:refreshUI()
                    else
                        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败"..data.result)
                    end 
                end,
                failedCallback = function()
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                end,--失败回调
				loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
				loadingParent = self,
            })
		else
			timerLabel:setString( self:transformTime( self._time ) )
		end
	end
	schedule( timerLabel, countDown, 1.0, 233 )
	-- 分隔线
	local splitLine2 = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
	splitLine2:setContentSize( myRewardSize.width, 2 )
	splitLine2:setAnchorPoint( cc.p( 0, 0 ) )
	splitLine2:setPosition( 0, 200 )
	splitLine2:setFlippedY( true )
	myRewardBg:addChild( splitLine2 )
	-- 排名固定奖励
	local myRewardTitleLabel = XTHD.createLabel({
		text      = LANGUAGE_KEY_MYRANKREWARD,
		fontSize  = 18,
		pos       = cc.p( 22, 160 ),
		color     = cc.c3b( 205, 101, 8 ),
		clickable = false,
	})
    myRewardTitleLabel:setAnchorPoint( cc.p( 0, 0 ) )
	myRewardBg:addChild( myRewardTitleLabel )
	-- 奖励图标
	local rewardIcons = XTHD.createSprite()
	rewardIcons:setContentSize( myRewardSize.width - 30, 100 )
	rewardIcons:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	rewardIcons:setPosition( myRewardSize.width * 0.5, 115 )
	self._rewardIcons = rewardIcons
	myRewardBg:addChild( rewardIcons )
	if self._rank == -1 then
		myRankBMLabel:setVisible( false )
		myRankTTFLabel:setString( LANGUAGE_KEY_NA )
		myRankTTFLabel:setVisible( true )
	else
		local iconData = self._dataTable[#self._dataTable]
		if self._rank ~= 0 then
			for i = 1, #self._dataTable do
				local data       = self._dataTable[i]
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
				if self._rank >= beginRank and self._rank <= endRank then
					iconData = data
					break
				end
			end
			myRankBMLabel:setString( self._rank )
			myRankBMLabel:setVisible( true )
			myRankTTFLabel:setVisible( false )
		else
			myRankBMLabel:setVisible( false )
			myRankTTFLabel:setString( LANGUAGE_KEY_RANKTEXT( 1, tonumber( string.split( iconData.order, "#" )[1] ) - 1 ) )
			myRankTTFLabel:setVisible( true )
		end
		rewardIcons:addChild( self:createIcons( iconData, 0.8, myRewardSize.width - 30, 100, true ) )
	end
	-- 领取按钮
	local fetchButton = XTHD.createCommonButton({
		btnColor = "write_1",
		btnSize = cc.size(130, 46),
		isScrollView = false,
		text = LANGUAGE_KEY_FETCHREWARD,
		fontSize = 20,
		fontColor = cc.c3b( 59, 155, 0 ),
		endCallback = function( )
			if self._fetch == 1 then
				ClientHttp:requestAsyncInGameWithParams({
					modules = "getTopReward?",
					params  = {rewardType = self._index},
	                successCallback = function( data )
	                    if tonumber(data.result) == 0 then
							self._fetchButton:setVisible( false )
					    	self._fetchButton:setEnable( false )
					    	self._fetchLabel:setVisible( false )
					    	self._fetchedImageView:setVisible( true )
					    	self._fetch = 0
					    	-- 成功获取弹窗
					    	ShowRewardNode:create( self._resultData )
					    	-- 更新属性
					    	if data.property and #data.property > 0 then
				                for i=1, #data.property do
				                    local pro_data = string.split( data.property[i], ',' )
				                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
				                end
				                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
				            end
				            -- 更新背包
				            if data.items and #data.items ~= 0 then
				                for i=1, #data.items do
				                    local item_data = data.items[i]
				                    if item_data.count and tonumber( item_data.count ) ~= 0 then
				                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
				                    else
				                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
				                    end
				                end
				            end
	                    else
                          	XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败"..data.result)
	                    end 
	                end,
	                failedCallback = function()
	                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
	                end,--失败回调
					loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
					loadingParent = self,
	            })
			end
		end,
	})
	fetchButton:setScale(0.7)
	fetchButton:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	fetchButton:setPosition( myRewardSize.width * 0.5, 50 )
	self._fetchButton = fetchButton
	myRewardBg:addChild( fetchButton )
	-- 领取按钮上的骨骼动画
    self._fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
    fetchButton:addChild( self._fetchSpine )
    -- self._fetchSpine:setScaleX( fetchButton:getContentSize().width/102 )
    -- self._fetchSpine:setScaleY( fetchButton:getContentSize().height/46 )
    self._fetchSpine:setPosition( fetchButton:getContentSize().width*0.5+7, fetchButton:getContentSize().height/2+2 )
	self._fetchSpine:setAnimation( 0, "querenjinjie", true )
	-- 可以领取文字
	local fetchLabel = XTHD.createLabel({
		text      = LANGUAGE_KEY_CANFETCHREWARD,
		fontSize  = 16,
		pos       = cc.p( myRewardSize.width * 0.5, 12 ),
		color     = cc.c3b( 128, 112, 91 ),
		clickable = false,
	})
	fetchLabel:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	fetchLabel:runAction( cc.RepeatForever:create( cc.Sequence:create( cc.FadeIn:create( 1 ), cc.FadeOut:create( 1 ) ) ) )
	self._fetchLabel = fetchLabel
	myRewardBg:addChild( fetchLabel )
	-- 已领取
    local fetchedImageView = XTHD.createSprite( "res/image/vip/yilingqu.png" )
	fetchedImageView:setPosition( fetchButton:getPosition() )
	fetchedImageView:setScale(0.7)
    self._fetchedImageView = fetchedImageView
    myRewardBg:addChild( fetchedImageView )
    -- 奖励正在统计中
    local calculateLabel = XTHD.createLabel({
    	text      = "奖励正在统计中...",
		fontSize  = 20,
		pos       = cc.p( myRewardSize.width * 0.5, 80 ),
		color     = cc.c3b( 70, 34, 34 ),
		clickable = false,
	})
	calculateLabel:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	self._calculateLabel = calculateLabel
	myRewardBg:addChild( calculateLabel )
    -- 处理显示
    if self._rank == -1 then
    	calculateLabel:setVisible( true )
    	self._rewardIcons:removeAllChildren()
    	fetchButton:setVisible( false )
    	fetchButton:setEnable( false )
    	fetchLabel:setVisible( false )
    	fetchedImageView:setVisible( false )
    elseif self._fetch == 1 then
    	calculateLabel:setVisible( false )
    	fetchButton:setVisible( true )
    	fetchButton:setEnable( true )
    	fetchLabel:setVisible( true )
    	fetchedImageView:setVisible( false )
    else
    	calculateLabel:setVisible( false )
    	fetchButton:setVisible( false )
    	fetchButton:setEnable( false )
    	fetchLabel:setVisible( false )
    	fetchedImageView:setVisible( true )
    end
end
-- 创建一排icon
function YingXiongBangLayer:createIcons( data, scale, width, height, isMyReward )
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
	local tableView  = CCTableView:create( cc.size( width, height ) )
	local cellWidth  = 0
	local cellHeight = height
	-- 根据数量设置大小和是否可以回弹
	if width > #iconTable * 85 * scale then
		tableView:setBounceable( false )
		cellWidth = width / #iconTable
	else
		tableView:setBounceable( true )
		cellWidth = 85 * scale
	end
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_HORIZONTAL )
	tableView:setDelegate()

	local function numberOfCellsInTableView( table )
		return #iconTable
	end
	local function cellSizeForTable( table, index )
		return cellWidth,cellHeight
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end
        local icon = XTHD.createItemNode( iconTable[index + 1] )
        icon:setPosition( cellWidth * 0.5, cellHeight * 0.5 + 5 )
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
-- 刷新ui
function YingXiongBangLayer:refreshUI()
	-- 刷新预览
	local transformTitle = {
		LANGUAGE_KEY_POWERNOCOLON,
		LANGUAGE_KEY_COMPETE,
		LANGUAGE_KEY_LEVEL,
		LANGUAGE_KEY_STARLEVEL,
	}
	self._titleLabel:setString( LANGUAGE_KEY_RANKLISTREWARD( transformTitle[self._index] ) )
	self._dataTable = gameData.getDataFromCSV( "LeaderboardRewards", {type = self._index})
	self._previewTableView:reloadData()
	-- 刷新我的奖励
	self._timerLabel:setString( self:transformTime( self._time ) )
	if self._rank == -1 then
		self._myRankBMLabel:setVisible( false )
		self._myRankTTFLabel:setString( LANGUAGE_KEY_NA )
		self._myRankTTFLabel:setVisible( true )
	else
		local iconData = self._dataTable[#self._dataTable]
		if self._rank ~= 0 then
			for i = 1, #self._dataTable do
				local data       = self._dataTable[i]
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
				if self._rank >= beginRank and self._rank <= endRank then
					iconData = data
					break
				end
			end
			self._myRankBMLabel:setString( self._rank )
			self._myRankBMLabel:setVisible( true )
			self._myRankTTFLabel:setVisible( false )
		else
			self._myRankBMLabel:setVisible( false )
			self._myRankTTFLabel:setString( LANGUAGE_KEY_RANKTEXT( 1, tonumber( string.split( iconData.order, "#" )[1] ) - 1 ) )
			self._myRankTTFLabel:setVisible( true )
		end
		self._rewardIcons:removeAllChildren()
		self._rewardIcons:addChild( self:createIcons( iconData, 0.8, self._myRewardSize.width - 30, 100, true ) )
	end
	if self._rank == -1 then
		self._calculateLabel:setVisible( true )
    	self._rewardIcons:removeAllChildren()
    	self._fetchButton:setVisible( false )
    	self._fetchButton:setEnable( false )
    	self._fetchLabel:setVisible( false )
    	self._fetchedImageView:setVisible( false )
	elseif self._fetch == 1 then
		self._calculateLabel:setVisible( false )
    	self._fetchButton:setVisible( true )
    	self._fetchButton:setEnable( true )
    	self._fetchLabel:setVisible( true )
    	self._fetchedImageView:setVisible( false )
    else
		self._calculateLabel:setVisible( false )
    	self._fetchButton:setVisible( false )
    	self._fetchButton:setEnable( false )
    	self._fetchLabel:setVisible( false )
    	self._fetchedImageView:setVisible( true )
    end
end

function YingXiongBangLayer:transformTime( params )
	local hour    = params / ( 60 * 60 )
	local hourTen = math.floor( hour / 10 )
	local hourOne = math.floor( hour % 10 )
	
	local minute    = ( params % ( 60 * 60 ) ) / 60
	local minuteTen = math.floor( minute / 10 )
	local minuteOne = math.floor( minute % 10 )

	local second    = params % 60
	local secondTen = math.floor( second / 10 )
	local secondOne = math.floor( second % 10 )

	return hourTen..hourOne..":"..minuteTen..minuteOne..":"..secondTen..secondOne
end

function YingXiongBangLayer:create( params )
	local layer = self.new( params )
	return layer
end

return YingXiongBangLayer