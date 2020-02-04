--[[
	英雄榜界面
]]
local RankListLayer1  = class( "RankListLayer1", function ( ... )
	return cc.Layer:create()
end )

function RankListLayer1:ctor( params )
	if params and params.CallFunc then
		self._callFunc = params.CallFunc
	end
	self._campId = 0
	self:initData( params )
	self:initUI( params )
end

function RankListLayer1:onCleanup()
    if self._callFunc then
    	self._callFunc()
    end
	local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/power_up.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/power_down.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/level_up.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/level_down.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/duan_up.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/duan_down.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/star_up.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/star_down.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/powerTop.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/levelTop.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/duanTop.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/starTop.png" )
    textureCache:removeTextureForKey( "res/image/ranklistreward/splitcell.png" )
    textureCache:removeTextureForKey( "res/image/common/btn/btn_exclamation_up.png" )
    textureCache:removeTextureForKey( "res/image/common/btn/btn_exclamation_down.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/lookup_up.png" )
    textureCache:removeTextureForKey( "res/image/plugin/ranklist/lookup_down.png" )
    textureCache:removeTextureForKey( "res/image/ranklistreward/1.png" )
    textureCache:removeTextureForKey( "res/image/ranklistreward/2.png" )
    textureCache:removeTextureForKey( "res/image/ranklistreward/3.png" )
    textureCache:removeTextureForKey( "res/image/ranklist/rank_4.png" )
    textureCache:removeTextureForKey( "" )
end

function RankListLayer1:initData( params )
	-- dump( params, "params" )
	--保存数据

	self._dataTable = params.list or {}
	self._duanData = {}
    self._myData = {
    	rank = params.myRank or LANGUAGE_KEY_NA,
    	power = params.myPower or LANGUAGE_KEY_NA,
    	star = params.myStar or LANGUAGE_KEY_NA,
	}

	self._rewardId = {
		2, -- 排位
		1, -- 战力
		3, -- 等级
		4, -- 星级
	}
end

function RankListLayer1:initUI( params )
	local _color = cc.LayerColor:create(cc.c4b(0,0,0,100), self:getContentSize().width ,self:getContentSize().height)
	self:addChild(_color)
	
	 local lookup = XTHDPushButton:createWithParams({
		touchSize = cc.size(self:getContentSize().width ,self:getContentSize().height),
        musicFile = XTHD.resource.music.effect_btn_common,
    	pos = cc.p( self:getContentSize().width*0.5, self:getContentSize().height*0.5 ),
	})
	self:addChild(lookup)
	
	self._size = self:getContentSize()
	-- 底层背景
    self._bottomBg = XTHD.createSprite( "res/image/ranklist/ranklayerbg.png" )
    self._bottomBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	self._bottomBg:setPosition( self:getContentSize().width * 0.5, self:getContentSize().height * 0.5 )
	self._bottomBgSize = self._bottomBg:getContentSize()
	self:addChild( self._bottomBg )

	local normalFile = "res/image/common/btn/close_btn_up.png"
	local selectFile = "res/image/common/btn/close_btn_dwon.png"

	local _back = XTHDPushButton:createWithParams({
		normalFile = normalFile,
		selectedFile = selectFile,
		endCallback = function ()
			self:removeFromParent()
		end
	})
	_back:setPosition(cc.p(self._bottomBg:getContentSize().width -_back:getContentSize().width/2 , self._bottomBg:getContentSize().height - _back:getContentSize().height / 2  - 32))
	self._bottomBg:addChild(_back)
	--阴影
--	local shadow = ccui.Scale9Sprite:create("res/image/common/common_black_shadow.png")
--	shadow:setPosition(self._bottomBg:getContentSize().width + 35,self._bottomBg:getContentSize().height/2)
--	shadow:setAnchorPoint(1,0.5)
--	self._bottomBg:addChild(shadow)

	self._tableViewBigHeight = 0
	self._tableViewSmallHeight = 0

	self._tabsTable = {}
	self._tabIndex = 1

	self._campBtns = {}
	self._campIndex = 1

	self._selectedIndex = 0
	self._selectedCell = nil

	-- 创建界面
	self:initTabs()
	self:initRankList()

	self:changeTab()
end
-- 创建右侧tabs
function RankListLayer1:initTabs()
	-- tabs层左边背景
	-- local tabBg = XTHD.createSprite( "res/image/common/tab_contentBg.png" )
	-- tabBg:setAnchorPoint( cc.p( 1, 0.5 ) )
	-- tabBg:setPosition( self._size.width - 62, ( self._size.height - self.topBarHeight ) * 0.5 )
	-- self:addChild( tabBg, 1 )

	-- tab点击处理
	local function tabCallback( index )
		-- 引导
		-- YinDaoMarg:getInstance():guideTouchEnd()
		if self._tabIndex ~= index then
			-- 更改tabs状态
			self._tabsTable[self._tabIndex]:setSelected( false )
			self._tabsTable[self._tabIndex]:setEnable( true )
			self._tabsTable[self._tabIndex]:setLocalZOrder( 0 )
			self._tabsTable[index]:setSelected( true )
			self._tabsTable[index]:setEnable( false )
			self._tabsTable[index]:setLocalZOrder( 1 )
			local modules={"allDuanRank?","powerRank?","levelRank?","starRank?","flowerRank?","sendFlowerRank?","heroStarRank?","veinsRank?","baodianRank?","heroPhaseRank?","godBeastRank?"}
			ClientHttp:requestAsyncInGameWithParams({
                modules = modules[index], 
				params = { campId  = 0},
                successCallback = function(data)
					if index >= 5 then
						self._rankListRewardBtn:setVisible(false)
					else
						self._rankListRewardBtn:setVisible(true)
					end
                	-- dump( data, "data" )
                	if tonumber(data.result)==0 then
						self._tabIndex = index
						-- 修改数据
						self._dataTable = data.list
						self._myData.rank = data.myRank or LANGUAGE_KEY_NA
						self._myData.power = data.myPower or LANGUAGE_KEY_NA
						self._myData.star = data.myStar or LANGUAGE_KEY_NA
						self:changeTab()
					end
				end,
                failedCallback = function()
					-- 更改tabs状态
					self._tabsTable[self._tabIndex]:setSelected( true )
					self._tabsTable[self._tabIndex]:setEnable( false )
					self._tabsTable[self._tabIndex]:setLocalZOrder( 1 )
					self._tabsTable[index]:setSelected( false )
					self._tabsTable[index]:setEnable( true )
					self._tabsTable[index]:setLocalZOrder( 0 )
                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
                end,
                loadingType   = HTTP_LOADING_TYPE.CIRCLE,
                loadingParent = self,
            })
		end
	end
	-- tabs路径
	local tabsPathTable = {
		{
			"res/image/plugin/ranklist/duan_up.png",
			"res/image/plugin/ranklist/duan_down.png",
		},
		{
			"res/image/plugin/ranklist/power_up.png",
			"res/image/plugin/ranklist/power_down.png",
		},
		{
			"res/image/plugin/ranklist/level_up.png",
			"res/image/plugin/ranklist/level_down.png",
		},
		{
			"res/image/plugin/ranklist/star_up.png",
			"res/image/plugin/ranklist/star_down.png",
		},
	}
	
	local scorllRect = ccui.ListView:create()
    scorllRect:setContentSize(cc.size(162, 297))
    scorllRect:setDirection(ccui.ScrollViewDir.vertical)
    scorllRect:setBounceEnabled(true)
	scorllRect:setScrollBarEnabled(false)
	scorllRect:setSwallowTouches(true)
    self._bottomBg:addChild(scorllRect,10)
    scorllRect:setPosition(cc.p(80,122))
    self.scorllRect = scorllRect

	-- 循环创建tab
	for i = 1, 11 do
		local layout = ccui.Layout:create()
		layout:setContentSize(160,60)
	
		local tabBtn_normal = "res/image/ranklist/rankbtn_" .. i .. "_up.png"
		local tabBtn_selected = "res/image/ranklist/rankbtn_" .. i .. "_dwon.png"
		local tabBtn = XTHD.createButton({
			normalNode = tabBtn_normal,
			selectedNode = tabBtn_selected,
             isScrollView = true,
			anchor = cc.p( 0.5, 0.5 ),
			endCallback = function()
				tabCallback( i )
			end,
		})
		tabBtn:setPosition( layout:getContentSize().width / 2 + 8,layout:getContentSize().height/2 )
		tabBtn:setSwallowTouches(false)
		layout:addChild( tabBtn, 0 )
		self._tabsTable[i] = tabBtn
		self.scorllRect:pushBackCustomItem(layout)
	end
	self._tabsTable[self._tabIndex]:setSelected( true )
	self._tabsTable[self._tabIndex]:setEnable( false )
	self._tabsTable[self._tabIndex]:setLocalZOrder( 1 )
end
-- 换tab
function RankListLayer1:changeTab()
	-- 刷新顶部
	self:refreshTop()
	-- tableview
	self._selectedIndex = 0
	self._selectedCell = nil
		self:createTableView()
		for i, v in ipairs( self._campBtns ) do
			v:setVisible( true )
			v:setEnable( true )
		end
		self._duanData = self._dataTable
		self:chooseCamp( 1 )
	self._rankListTableView:reloadData()
end
-- 刷新顶部信息
function RankListLayer1:refreshTop()
	local topBgPath = {
		"res/image/plugin/ranklist/duanTop.png",
		"res/image/plugin/ranklist/powerTop.png",
		"res/image/plugin/ranklist/levelTop.png",
		"res/image/plugin/ranklist/starTop.png",
	}
	self._topBg:setTexture( topBgPath[self._tabIndex] )
	if self._myData.rank <= 50 then
		self._myRank:setString( self._myData.rank)
	else
		self._myRank:setString("未上榜")
	end
	local textPerTab = {
		{
			LANGUAGE_MAINCITY_RANKLIST[3],
			"[image=res/image/common/rank_icon/rankIcon_"..gameUser.getDuanId()..".png offsety=-11 w=33 h=33][/image][size=20][color=ffcc4002]"..gameUser.getDuanRank().."[/color][/size]",
			LANGUAGE_MAINCITY_RANKLIST[4],
		},
		{
			LANGUAGE_MAINCITY_RANKLIST[1],
			"[image=res/image/common/fightValue_Image.png w=26 h=25 offsety=-5][/image][size=20][color=ffcc4002]"..self._myData.power.."[/color][/size]",
			LANGUAGE_NAMES.fightVim,
		},
		{
			LANGUAGE_MAINCITY_RANKLIST[2],
			"[size=20][color=ffcc4002]"..gameUser.getLevel().."[/color][/size]",
			LANGUAGE_KEY_LEVEL,
		},
		{
			LANGUAGE_MAINCITY_RANKLIST[5],
			"[image=res/image/common/star_light.png offsety=-5][/image][size=20][color=ffcc4002]"..self._myData.star.."[/color][/size]",
			LANGUAGE_MAINCITY_RANKLIST[6],
		},
	}
	-- self._myInfoText:setString( textPerTab[self._tabIndex][1] )
	-- self._myInfo:setString( textPerTab[self._tabIndex][2] )
	self._myInfo:setPositionX( self._myInfoText:getPositionX() + self._myInfoText:getBoundingBox().width + 5 )
	-- self._otherTitle:setString( textPerTab[self._tabIndex][3] )
end
-- 创建排行榜
function RankListLayer1:initRankList()
	-- 顶部
	self._topBg = XTHD.createSprite()
	-- self._topBg = ccui.Scale9Sprite:create()
	self._topBg:setContentSize( cc.size( 830, 76 ) )
	self._topBg:setAnchorPoint( cc.p( 0.5, 0 ) )
	self._topBg:setPosition( self._bottomBgSize.width*0.5, self._bottomBgSize.height - self._topBg:getContentSize().height - 5 )
	self._topBg:setScaleY( 0.65 )
	self._topBg:setScaleX( 0.76 )
	self._topBg:setVisible(false)
	
    -- 边框
	self._bottomBg:addChild( self._topBg )
	-- 我的排名
	local myRankText = XTHD.createLabel({
		text = LANGUAGE_KEY_GUILDWAR_TEXT.myRankTextXc..":",
		fontSize = 18,
		color = XTHD.resource.color.gray_desc,
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( self._bottomBg:getContentSize().width *0.3, 65),
	})
	self._bottomBg:addChild( myRankText )
	self._myRank = XTHD.createLabel({
		fontSize = 24,
		color = cc.c3b( 204, 64, 2 ),
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( myRankText:getPositionX() + myRankText:getContentSize().width + 10, myRankText:getPositionY()),
	})
	self._bottomBg:addChild( self._myRank )
	-- 排行榜奖励
	local rankListRewardBtn = XTHD.createButton({
		normalFile = "res/image/ranklist/phjl_2_up.png",
        selectedFile = "res/image/ranklist/phjl_2_down.png",
        btnSize = cc.size( 150, 50 ),
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p(self._bottomBg:getContentSize().width *0.2 - 10, myRankText:getPositionY() + 10),
		endCallback = function()
			self:RankJiangli()
        end
	})
	-- rankListRewardBtn:setScaleY(0.8)
	-- rankListRewardBtn:getLabel():setPositionX(rankListRewardBtn:getLabel():getPositionX()-10)
	--排行榜奖励
	self._bottomBg:addChild( rankListRewardBtn )
	self._rankListRewardBtn = rankListRewardBtn
	-- 我的信息
	self._myInfoText = XTHD.createLabel({
		fontSize = 18,
		color = XTHD.resource.color.gray_desc,
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( myRankText:getPositionX(), myRankText:getPositionY() - self._topBg:getContentSize().height*0.5 ),
	})
	self._bottomBg:addChild( self._myInfoText )
	self._myInfo = XTHD.createRichLabel({
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( self._myInfoText:getPositionX() + self._myInfoText:getBoundingBox().width + 5, self._myInfoText:getPositionY() + 2 ),
	})
	self._bottomBg:addChild( self._myInfo )

	-- tableView背景
	local tableViewBg = ccui.Scale9Sprite:create()
	tableViewBg:setAnchorPoint(0.5, 0.5)
	tableViewBg:setContentSize(536,310)
	tableViewBg:setPosition( self._bottomBgSize.width*0.5+90, self._bottomBgSize.height/2+13 )
	self._bottomBg:addChild( tableViewBg )
	--表头
	local biaotou = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_25.png")
	biaotou:setContentSize(self._bottomBgSize.width - 21,38)
	biaotou:setAnchorPoint(0.5,0.5)
	biaotou:setPosition(tableViewBg:getContentSize().width/2+3,tableViewBg:getContentSize().height-19)
	tableViewBg:addChild(biaotou)
	self._tableViewBg = tableViewBg
	biaotou:setVisible(false)
	
	local topInfoHeight = 35
	local tableViewBgSize = tableViewBg:getContentSize()
	-- 分隔
	-- local splitX = ccui.Scale9Sprite:create("res/image/ranklistreward/splitcell.png" )
    -- splitX:setContentSize( tableViewBgSize.width - 16, 2 )
    -- splitX:setAnchorPoint( cc.p( 0.5, 0 ) )
	-- splitX:setPosition( tableViewBgSize.width*0.5, tableViewBgSize.height - topInfoHeight )
	-- -- splitY1:setScale(0.5)
    -- tableViewBg:addChild( splitX )

    -- 种族按钮
    local campText = {
    	LANGUAGE_BTN_KEY.campBoth,
    	LANGUAGE_BTN_KEY.camp1,
    	LANGUAGE_BTN_KEY.camp2,
	}
	local fileName = {"quanbubtn_","xianzubtn_","mozubtn_"}
    for i = 1, 3 do
    	-- normal
    	local campBtn_normal = XTHD.createSprite( "res/image/ranklist/" .. fileName[i] .."up.png" )
    	
		-- selected
    	local campBtn_selected = XTHD.createSprite( "res/image/ranklist/".. fileName[i] .."dwon.png" )
    	
		-- btn
    	local campBtn = XTHD.createButton({
    		normalNode = campBtn_normal,
    		selectedNode = campBtn_selected,
    		needSwallow = true,
	    	anchor = cc.p( 1,0 ),
	    	pos = cc.p( self._bottomBgSize.width - ( 3 - i )*100-86, 75 ),
	    	endCallback = function()
	    		if self._campIndex ~= i then
	    			self:chooseCamp( i )
	    		end
	    	end
		})
	
		local selectedbg = cc.Sprite:create("res/image/ranklist/".. fileName[i] .."dwon.png")
		campBtn:addChild(selectedbg)
		selectedbg:setPosition(campBtn:getContentSize().width*0.5,campBtn:getContentSize().height *0.5)
		selectedbg:setName("selectedbg")
		selectedbg:setVisible(false)
	
		campBtn:setScale(1)
	    self._bottomBg:addChild( campBtn, 1 )
	    if self._tabIndex == 1 then
	    	campBtn:setVisible( true )
	    	campBtn:setEnable( true )
	    else
	    	campBtn:setVisible( true )
	    	campBtn:setEnable( true )
	    end
    	self._campBtns[i] = campBtn
    end


	-- 预览tableView
	self._tableViewWidth = tableViewBgSize.width
	self._tableViewheight = tableViewBgSize.height
	self._tableViewBigHeight = tableViewBgSize.height - topInfoHeight
	self._tableViewSmallHeight = self._tableViewBigHeight - 40
end
-- 创建tableview
function RankListLayer1:createTableView()
	if self._rankListTableView then
		self._rankListTableView:removeFromParent()
		self._rankListTableView = nil
	end
	local rankListTableView = cc.TableView:create( cc.size( self._tableViewWidth, self._tableViewheight) )
	rankListTableView:setBounceable( true )
	rankListTableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	rankListTableView:setDelegate()
	rankListTableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	self._rankListTableView = rankListTableView
	self._tableViewBg:addChild( rankListTableView )
	local cellWidth = self._tableViewWidth
	local cellHeight = 87
	local function numberOfCellsInTableView( table )
		return #self._dataTable
	end
	local function cellSizeForTable( table, index )
		return cellWidth,cellHeight
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
        if cell == nil then
            cell = cc.TableViewCell:new()
			cell:setContentSize(cellWidth,cellHeight)
            self:buildCell( cell, index, cellWidth, cellHeight )
        end
        self:updateCell( cell, index )

    	return cell
	end
	rankListTableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    rankListTableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    rankListTableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
end
-- 创建cell
function RankListLayer1:buildCell( cell, index, cellWidth, cellHeight )
	
	local node = cc.Node:create()
	node:setContentSize(cc.size(cellWidth,cellHeight - 5))
	cell:addChild(node)
	node:setAnchorPoint(0.5,0.5)
	node:setPosition(cellWidth*0.5,cellHeight*0.5)
	cell._node = node

	local data = self._dataTable[index + 1]
	-- cell背景
    local cellBg0 = ccui.Scale9Sprite:create("res/image/ranklist/rankcellbg.png" )
    cellBg0:setContentSize( cellWidth - 20, cellHeight - 5 )
    cellBg0:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    cellBg0:setPosition( cellWidth*0.5, cellHeight*0.5 -5 )
    node:addChild( cellBg0 )
    cell._cellBg0 = cellBg0
    local cellBg1 = ccui.Scale9Sprite:create( "res/image/ranklist/rankcellbg.png" )
    cellBg1:setContentSize( cellWidth - 20, cellHeight - 5 )
    cellBg1:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    cellBg1:setPosition( cellWidth*0.5, cellHeight*0.5 -5 )
    node:addChild( cellBg1 )
    cell._cellBg1 = cellBg1
    local cellBg2 = ccui.Scale9Sprite:create("res/image/ranklist/rankcellbg.png" )
    cellBg2:setContentSize( cellWidth - 20, cellHeight - 5 )
    cellBg2:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    cellBg2:setPosition( cellWidth*0.5, cellHeight*0.5 - 5 )
    node:addChild( cellBg2 )
    cell._cellBg2 = cellBg2
	
	local playerNode =  HeroNode:createWithParams({
        heroid = data.templateId,
        star  = 0,
        level = 0,
        advance = 0,
		endCallback = function ()
		
		end
    })
	node:addChild(playerNode)
	playerNode:setPosition(cellWidth*0.2 + 20,cellHeight*0.5 - 7)
	playerNode:setScale(0.6)
	
	local look_btn = XTHDPushButton:createWithParams({
            --touchSize = cc.size( cellWidth - 20, cellHeight),
            musicFile = XTHD.resource.music.effect_btn_common,
			needEnableWhenMoving = true,
			isScrollView = true,
	})
	look_btn:setContentSize(cc.size( cellWidth - 20, cellHeight))
	look_btn:setSwallowTouches(false)
	node:addChild(look_btn)
	look_btn:setPosition(cellWidth*0.5, node:getContentSize().height*0.5)

--	look_btn:setTouchEndedCallback(function()
--		node:setScale(1)
--		if self._selectedCell then
--			self._selectedCell._selected:setVisible( false )
--		end
--		self._selectedCell = cell
--		self._selectedIndex = index + 1
--		cell._selected:setVisible( true )
--		local function showFirendInfo( ... )
--			HaoYouPublic.showFirendInfo( data.charId, self )
--		end
--		local pData = HaoYouPublic.getFriendData()
--		if not pData then
--		    HaoYouPublic.httpGetFriendData( self, showFirendInfo)
--		else
--		    showFirendInfo()
--		end
--	end)
	cell._look_btn = look_btn

    local rankIcon = XTHD.createSprite()
    rankIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    rankIcon:setPosition( cellWidth*0.1, cellHeight*0.5 - 6)
    node:addChild( rankIcon )
	cell._rankIcon = rankIcon
	
	local rankNum = cc.Label:createWithBMFont( "res/fonts/paihangbangword.fnt", 0 )
    rankNum:setPosition( cellWidth*0.1 , cellHeight*0.5 - 13 )
    node:addChild( rankNum )
    cell._rankNum = rankNum

    -- 玩家信息
    local playerInfo = XTHD.createLabel({
    	anchor = cc.p( 0, 0.5 ),
    	pos = cc.p( cellWidth*0.4 - 40, cellHeight*0.5 + 5 ),
    	fontSize = 18,
    	color = XTHD.resource.color.gray_desc,
	})
    node:addChild( playerInfo )
    cell._playerInfo = playerInfo
    -- 等级
    local levelBg = ccui.Scale9Sprite:create()
    levelBg:setContentSize( 70, 30 )
    levelBg:setAnchorPoint( cc.p( 0, 0.5 ) )
    levelBg:setPosition( cellWidth*0.55, cellHeight*0.5 )
    node:addChild( levelBg )
    local level = XTHD.createLabel({
		fontSize = 18,
		color = XTHD.resource.color.gray_desc,
		anchor = cc.p( 0.5, 0.5 ),
	})
	cell._level = level
	getCompositeNodeWithNode( levelBg, level )
	-- vip
	local vipImage = XTHD.createSprite( "res/image/vip/vip.png" )
	vipImage:setAnchorPoint( cc.p( 0, 0.5 ) )
	vipImage:setPosition( cellWidth*0.4 - 40, cellHeight*0.5 )
	vipImage:setScale( 0.7 )
	node:addChild( vipImage )
	cell._vipImage = vipImage
	cell._vipImage:setOpacity(0)
	local vipNum = XTHD.createSprite( "res/image/vip/vip.png" )
	vipNum:setAnchorPoint( cc.p( 0, 0.5 ) )
	vipNum:setPosition( vipImage:getPositionX(), cellHeight*0.5 - 20 )
	vipNum:setScale( 0.4 )
	node:addChild( vipNum )
	cell._vipNum = vipNum
    -- 排行信息
    local rankInfo = XTHD.createRichLabel({
    	anchor = cc.p( 1, 0.5 ),
    	pos = cc.p( cellWidth*0.8, cellHeight*0.5 ),
	})
    node:addChild( rankInfo )
    rankInfo:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    cell._rankInfo = rankInfo
    local rankInfoNum = XTHD.createLabel({
		fontSize = 18,
		color = cc.c3b( 204, 64, 2 ),
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( rankInfo:getPositionX() - 35, rankInfo:getPositionY() ),
	})
	rankInfoNum:setScale(0.9)
    node:addChild( rankInfoNum )
    cell._rankInfoNum = rankInfoNum
    -- 点击查看
    -- normal
    local lookup_normal = XTHD.createSprite()
    lookup_normal:setContentSize( cellWidth, cellHeight )
    local lookup_normal_sp = XTHD.createSprite( "res/image/plugin/ranklist/lookup_up.png" )
	lookup_normal_sp:setPosition( cellWidth - 40, cellHeight*0.5 )
	lookup_normal_sp:setScale(0.7)
    lookup_normal:addChild( lookup_normal_sp )
    -- selected
    local lookup_selected = XTHD.createSprite()
    lookup_selected:setContentSize( cellWidth, cellHeight )
	local lookup_selected_sp = XTHD.createSprite( "res/image/plugin/ranklist/lookup_down.png" )
	lookup_normal_sp:setScale(0.7)
    lookup_selected_sp:setPosition( cellWidth - 40, cellHeight*0.5 )
    lookup_selected:addChild( lookup_selected_sp )
    -- btn
    
	-- 选中框
	local selected = ccui.Scale9Sprite:create("res/image/ranklist/actTab_selected.png" )
	selected:setContentSize( cellWidth-5 , cellHeight+3 )
    selected:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    selected:setPosition( cellWidth*0.5, cellHeight*0.5 - 5 )
    node:addChild( selected )
    cell._selected = selected
end
-- 更新cell
function RankListLayer1:updateCell( cell, index )
	local data = self._dataTable[index + 1]
	
	cell._look_btn:setTouchBeganCallback(function()
		cell._node:setScale(0.98)
	end)

	cell._look_btn:setTouchMovedCallback(function()
		cell._node:setScale(1)
	end)

	cell._look_btn:setTouchEndedCallback(function()
		cell._node:setScale(1)
		if self._selectedCell then
			self._selectedCell._selected:setVisible( false )
		end
		self._selectedCell = cell
		self._selectedIndex = index + 1
		cell._selected:setVisible( true )
		local function showFirendInfo( ... )
			HaoYouPublic.showFirendInfo( data.charId, self )
		end
		local pData = HaoYouPublic.getFriendData()
		if not pData then
		    HaoYouPublic.httpGetFriendData( self, showFirendInfo)
		else
		    showFirendInfo()
		end
	end)

	local rivalRankList = {"青铜组","白银组","黄金组","白金组","钻石组","至尊组","王者组"}
	-- 数据
	local data = self._dataTable[index + 1]
	-- dump(data, "data")
	cell._charId = data.charId
	-- 背景
	if data.charId == gameUser.getUserId() then
		cell._cellBg0:setVisible( true )
		cell._cellBg1:setVisible( false )
		cell._cellBg2:setVisible( false )
	elseif data.campId == 2 then
		cell._cellBg0:setVisible( false )
		cell._cellBg1:setVisible( false )
		cell._cellBg2:setVisible( true )
	else
		cell._cellBg0:setVisible( false )
		cell._cellBg1:setVisible( true )
		cell._cellBg2:setVisible( false )
	end
	
	-- 排行
	cell._rankNum:setString( index + 1 )
	if index < 10 then
		local rankIconPath = ""
		if index < 3 then
			rankIconPath = "res/image/ranklist/".. "rank_" ..( index + 1 )..".png"
			cell._rankNum:setVisible(false)
		else
			rankIconPath = "res/image/ranklist/rank_4.png"
			cell._rankNum:setVisible(true)
		end
		cell._rankIcon:setTexture( rankIconPath )
		cell._rankIcon:setScale(0.8)
		cell._rankIcon:setVisible( true )
	else
		cell._rankIcon:setVisible( false )
	end
	-- 玩家信息
	-- cell._playerInfo:setString( "[image=res/image/common/camp_Icon_"..( data.campId == 2 and 2 or 1 )..".png w=28 h=28 offsety=-7][/image][size=18][color=ff462222] "..data.charName.."[/color][/size]" )
	cell._playerInfo:setString( data.charName )
	-- 等级
	cell._level:setString( "lv:"..data.level )
	-- vip
	if data.vipLevel and tonumber( data.vipLevel ) > 0 then
		cell._vipImage:setVisible( true )
		-- cell._vipNum:setString( tonumber( data.vipLevel ) )
		local vipPath = "res/image/vip/vipl_0" .. tonumber( data.vipLevel ) .. ".png"
		cell._vipNum:setTexture(vipPath)
		cell._vipNum:setVisible( true )
	else
		cell._vipImage:setVisible( false )
		cell._vipNum:setVisible( false )
	end
	-- 排行信息
	local text = nil
	if self._tabIndex == 1 then
		cell._rankInfoNum:setString( rivalRankList[data.duanId] or LANGUAGE_KEY_NA )--段位	
	elseif self._tabIndex == 2 then
		if data.power ~= nil and data.power > 0 then
			text = "战力："..data.power
		else
			text = LANGUAGE_KEY_NA
		end
		cell._rankInfoNum:setString(text)--战力
	elseif self._tabIndex == 3 then
		if data.level ~= nil and data.level > 0 then
			text = "等级："..data.level
		else
			text = LANGUAGE_KEY_NA
		end
		cell._rankInfoNum:setString( text ) --等级
	elseif self._tabIndex == 4 then
		if data.stars ~= nil and data.stars > 0 then
			text = "闯关："..data.stars
		else
			text = LANGUAGE_KEY_NA
		end
		cell._rankInfoNum:setString( text )--闯关
	elseif self._tabIndex == 5 then
		if data.flower ~= nil and data.flower > 0 then
			text = "鲜花："..data.flower
		else
			text = LANGUAGE_KEY_NA
		end
		cell._rankInfoNum:setString( text )--鲜花
	elseif self._tabIndex == 6 then
		if data.sendFlower ~= nil and data.sendFlower > 0 then
			text = "送花："..data.sendFlower
		else
			text = LANGUAGE_KEY_NA
		end
		cell._rankInfoNum:setString( text )--送花
	elseif  self._tabIndex == 7 then
		if data.totalStar ~= nil and data.totalStar > 0 then
			text = "英雄星级："..data.totalStar
		else
			text = LANGUAGE_KEY_NA
		end
		cell._rankInfoNum:setString( text )--英雄星级
	elseif  self._tabIndex == 8 then
		if data.veins ~= nil and data.veins > 0 then
			text = "英雄兵书："..data.veins
		else
			text = LANGUAGE_KEY_NA
		end
		cell._rankInfoNum:setString( text )--英雄兵书
	elseif  self._tabIndex == 9 then
		if data.baodian ~= nil and data.baodian > 0 then
			text = "修炼排行："..data.baodian
		else
			text = LANGUAGE_KEY_NA
		end
		cell._rankInfoNum:setString( text )--修炼排行
	elseif  self._tabIndex == 10 then
		if data.totalPhase ~= nil and data.totalPhase > 0 then
			text = "英雄进阶："..data.totalPhase
		else
			text = LANGUAGE_KEY_NA
		end
		cell._rankInfoNum:setString( text )--英雄进阶
	elseif  self._tabIndex == 11 then
		if data.godBeast ~= nil and data.godBeast > 0 then
			text = "神器进阶："..data.godBeast
		else
			text = LANGUAGE_KEY_NA
		end
		cell._rankInfoNum:setString( text )--神器进阶
	end
	if self._selectedIndex == index + 1 then
		cell._selected:setVisible( true )
		self._selectedCell = cell
	else
		cell._selected:setVisible( false )
	end
end
-- 选择种族
function RankListLayer1:chooseCamp( i )
	for  x = 1, #self._campBtns do
		if self._campBtns[x]:getChildByName("selectedbg") then
			self._campBtns[x]:getChildByName("selectedbg"):setVisible(false)
		end
	end

	if self._campBtns[i]:getChildByName("selectedbg") then
		self._campBtns[i]:getChildByName("selectedbg"):setVisible(true)
	end
	
	if self._tabIndex ~= 1 then
			local modules={"allDuanRank?","powerRank?","levelRank?","starRank?","flowerRank?","sendFlowerRank?","heroStarRank?","veinsRank?","baodianRank?","heroPhaseRank?","godBeastRank?"}
			ClientHttp:requestAsyncInGameWithParams({
				modules = modules[self._tabIndex],
				params = { campId  = i - 1 },
				successCallback = function(backData)
--	        		 dump( backData, "backData" )
	        		if tonumber(backData.result)==0 then
						self._campIndex = i
						self._dataTable = backData.list
						self._rankListTableView:reloadData()
						if backData.myRank and backData.myRank > 0 then
							if  backData.myRank <= 50 then
								self._myRank:setString( backData.myRank)
							else
								self._myRank:setString("未上榜")
							end
						else
							self._myRank:setString( "无" )
						end
	        		end
	    		end,
	    		failedCallback = function()
					XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
				end,--失败回调
				loadingType = HTTP_LOADING_TYPE.NONE,
				loadingParent = self,
			})
	else	
		if i == 1 then
			self._campIndex = i
			if  self._myData.rank <= 50 then
				self._myRank:setString(self._myData.rank)
			else
				self._myRank:setString("未上榜")
			end
			self._dataTable = self._duanData
			self._rankListTableView:reloadData()
		else
			local myCampId = gameUser.getCampID() or 1
			ClientHttp:requestAsyncInGameWithParams({
				modules = ( myCampId + 1 ) == i and "myCampDuanRank?" or "rivalCampDuanRank?",
				successCallback = function(backData)
--	        		 dump( backData, "backData" )
	        		if tonumber(backData.result)==0 then
						self._campIndex = i
						self._dataTable = backData.list
						self._rankListTableView:reloadData()
						if backData.myRank and backData.myRank > 0 then
							if  backData.myRank <= 50 then
								self._myRank:setString( backData.myRank)
							else
								self._myRank:setString("未上榜")
							end
						else
							self._myRank:setString( "无" )
						end
	        		end
	    		end,
	    		failedCallback = function()
					XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
				end,--失败回调
				loadingType = HTTP_LOADING_TYPE.NONE,
				loadingParent = self,
			})
		end
	end
end

function RankListLayer1:create( params )
	local layer = self.new( params )
	return layer
end

function RankListLayer1:RankJiangli()
	-- self._rankListRewardBtn:setSelected(true)
	ClientHttp:requestAsyncInGameWithParams({
		modules = "topRewardData?",
		params  = {rewardType = self._rewardId[self._tabIndex]},
        successCallback = function( backData )
			if tonumber( backData.result ) == 0 then
				local pop = requires( "src/fsgl/layer/ZhuCheng/RankListRewardPop1.lua" ):create( self._rewardId[self._tabIndex], backData.rank, backData.time )
			    self:addChild( pop, 3 )
			    pop:show()
            else
				-- self._rankListRewardBtn:setSelected(false)
                XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败"..backData.result)
            end 
        end,
        failedCallback = function()
        XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
		loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
		loadingParent = self,
    })
end

function RankListLayer1:onEnter( )
    --------引导 
    -- YinDaoMarg:getInstance():addGuide({parent = self,index = 3},14)----剧情
    -- YinDaoMarg:getInstance():doNextGuide()
end

return RankListLayer1