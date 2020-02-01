--[[
	重构的装备界面
	唐实聪
	2015.11.28
]]
local ZhuangBeiLayer = class( "ZhuangBeiLayer",function ()
	return XTHD.createBasePageLayer()
end)

function ZhuangBeiLayer:ctor( heroId, dbid, type, callFunc )
	self._exist = true
	self._seletedList = {}
    self:initData( heroId, dbid, type, callFunc )
    self:initUI()
	self:refreshRedDot()
	XTHD.addEventListener({
        name = CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK,
        callback = function ()
	        if not self._exist then
				return
			end
            self:refreshEquip( false, true )
        end,
    })
end
function ZhuangBeiLayer:onCleanup()
	self._exist = false
	XTHD.removeEventListener( CUSTOM_EVENT.REFRESH_UIANDDATA_DROPTURNBACK )
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TASKLIST})
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "equip"}})
	if self._callFunc then
		self._callFunc()
	end
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey( "res/image/plugin/equip_smelt/noEquipBg.png" )
	textureCache:removeTextureForKey( "res/image/ranklistreward/splitcell.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/rightbg.png" )
	textureCache:removeTextureForKey( "res/image/common/common_cloud.png" )
	textureCache:removeTextureForKey( "res/image/common/common_figure.png" )
	textureCache:removeTextureForKey( "res/image/common/btn/tip_up.png" )
	textureCache:removeTextureForKey( "res/image/common/btn/tip_down.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/iconzz.png" )
	textureCache:removeTextureForKey( "res/image/illustration/selected.png" )
	textureCache:removeTextureForKey( "res/image/plugin/stageChapter/btn_left_arrow.png" )
	textureCache:removeTextureForKey( "res/image/plugin/stageChapter/btn_right_arrow.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/arrow.png" )
	textureCache:removeTextureForKey( "res/image/ranklistreward/splitX.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/iconbg_bef.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/iconbg_aft.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/lace.png" )
	textureCache:removeTextureForKey( "res/image/common/star_light.png" )
	textureCache:removeTextureForKey( "res/image/common/star_dark.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/arrow1.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/arrow2.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/checkbox_up.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/checkbox_down.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/strength_up.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/strength_down.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/starup_up.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/starup_down.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/reforge_up.png" )
	textureCache:removeTextureForKey( "res/image/plugin/equip_layer/reforge_down.png" )
end
-- 创建数据
function ZhuangBeiLayer:initData( heroId, dbid, _type, callFunc )
    self._callFunc = callFunc

	-- 显示大小
	self._size = self:getContentSize()
	-- tabs对象
	self._tabsTable = {}
	self._tabIndex = 1
	if _type then
		if _type == 2 and XTHD.getUnlockStatus( 50, true ) then
			self._tabIndex = 2
	    elseif _type == 3 and XTHD.getUnlockStatus( 54, true ) then
			self._tabIndex = 3
		end
    end
	-- 英雄列表下标
	self._heroIndex = 1
	self._heroId = heroId or 0
	self._heroCell = nil
	-- 装备列表下标
	self._equipIndex = 1
	self._equipDbid = dbid or 0
	self._equipCell = nil
	-- 洗练方式
	self._reforgeChoiceFlag = 1

	-- 合成cell显示索引
	self.curCount = 1

	-- 英雄列表数据
	self:buildHeroData()
	-- dump(self._heroData, "self._heroData")
	-- 合成数据
	self:buildComposeData()
	-- 装备列表数据
	self:buildEquipData()
	-- dump(self._equipData, "self._equipData")
end
-- 创建ui
function ZhuangBeiLayer:initUI()
	-- 背景
	local bottomBg = XTHD.createSprite( "res/image/common/layer_bottomBg.png" )
	bottomBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	bottomBg:setPosition( self._size.width * 0.5, ( self._size.height - self.topBarHeight ) * 0.5 )
	self:addChild( bottomBg )
    self._bottomBgSize = bottomBg:getContentSize()
    self._bottomBg=bottomBg

	local title = "res/image/public/zhaungbei_title.png"
	XTHD.createNodeDecoration(self._bottomBg,title)

	--阴影
	self.shadow = ccui.Scale9Sprite:create("res/image/common/common_black_shadow.png")
	self.shadow:setPosition(self._bottomBgSize.width,self._bottomBgSize.height/2)
	self.shadow:setAnchorPoint(1,0.5)
	bottomBg:addChild(self.shadow)

	self._leftSize = cc.size( 290, self._bottomBgSize.height - 120 )--self._size.width - 82 - 604
	self._rightSize = cc.size( self._bottomBgSize.width - 100 - self._leftSize.width, self._leftSize.height - 5 )--604

	self._bottomSize = cc.size( self._bottomBgSize.width, 111 )

	self:initTabs()
	self:initBottom()
	self:initLeft()
	self:initRight()

	-- 没有装备
	self._noEquip = XTHD.createSprite( "res/image/plugin/equip_smelt/noEquipBg.png" )
	self._noEquip:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	self._noEquip:setPosition( self._size.width*0.5, self._bottomSize.height + self._leftSize.height*0.5 + 15 )
	self:addChild( self._noEquip, 2 )
	-- 没有装备提示
	self._noEquipTip = XTHD.createLabel({
		fontSize = 22,
		color = cc.c3b( 169, 156, 137 ),
		anchor = cc.p( 0.5, 1 ),
		pos = cc.p( self._noEquip:getContentSize().width*0.5 - 30, 15 ),
	})
	self._noEquip:addChild( self._noEquipTip )

	self._touchLayer = XTHD.createButton({
        touchSize = cc.size( 1000, 1000 ),
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( self._size.width*0.5, self._size.height*0.5 ),
        needSwallow = true,
        beganCallback = function()
        	print("swallow")
            return true
        end,
    })
    self:addChild( self._touchLayer, 233 )
	self._touchLayer:setEnable( false )

	self:refreshInfo( true )
end
-- 创建标签tabs
function ZhuangBeiLayer:initTabs()
	-- tabs层左边背景
	-- local tabBg = XTHD.createSprite( "res/image/common/tab_contentBg.png" )
	-- tabBg:setAnchorPoint( cc.p( 1, 0.5 ) )
	-- tabBg:setPosition( self._size.width - 62, ( self._size.height - self.topBarHeight ) * 0.5 )
	-- self:addChild( tabBg, 1 )

	-- tab点击处理
	local function tabCallback( index )
		YinDaoMarg:getInstance():guideTouchEnd() 

		if self._tabIndex ~= index then
			if index == 2 and not XTHD.getUnlockStatus( 50, true ) then
				return
            elseif index == 3 and not XTHD.getUnlockStatus( 54, true ) then
             	return
            end
			-- 更改tabs状态
			self._tabsTable[self._tabIndex]:setSelected( false )
			self._tabsTable[self._tabIndex]:setEnable( true )
			self._tabsTable[self._tabIndex]:setLocalZOrder( 0 )
			self._tabsTable[index]:setSelected( true )
			self._tabsTable[index]:setEnable( false )
			self._tabsTable[index]:setLocalZOrder( 1 )
			if self._tabIndex == 1 or self._tabIndex == 2 or self._tabIndex == 3 then
				self._equipDbid = self._equipData[self._equipIndex] and self._equipData[self._equipIndex].dbid or 0
			end
			
			self._tabIndex = index
			
			if self._tabIndex == 1 or self._tabIndex == 2 or self._tabIndex == 3 then
				if self._heroCell and self._heroCell._heroIconBtn then
					self._heroCell._heroIconBtn:setSelected( true )
				end
				self._swallow:setEnable( false )
				self._tip:setVisible( true )
			elseif self._tabIndex == 4 then
				if self._heroCell and self._heroCell._heroIconBtn then
					self._heroCell._heroIconBtn:setSelected( false )
				end
				self._swallow:setEnable( false )
				self._tip:setVisible( false )
			end
			-- 刷新装备列表
			self:refreshEquip( true )
		end
	end
	-- tabs路径
	local tabsPathTable = {
		{
			"res/image/plugin/equip_layer/strength_up.png",
			"res/image/plugin/equip_layer/strength_down.png",
		},
		{
			"res/image/plugin/equip_layer/starup_up.png",
			"res/image/plugin/equip_layer/starup_down.png",
		},
		{
			"res/image/plugin/equip_layer/reforge_up.png",
			"res/image/plugin/equip_layer/reforge_down.png",
		},
		{
			"res/image/plugin/equip_layer/compose_up.png",
			"res/image/plugin/equip_layer/compose_down.png",
		},
	}
	-- 循环创建tab
	for i = 1, 4 do
		local tabBtn_normal = getCompositeNodeWithImg( "res/image/common/btn/btn_tabClassify_normal.png", tabsPathTable[i][1] )
		local tabBtn_selected = getCompositeNodeWithImg( "res/image/common/btn/btn_tabClassify_selected.png", tabsPathTable[i][2] )
		local tabBtn = XTHD.createButton({
			normalNode = tabBtn_normal,
			selectedNode = tabBtn_selected,
			anchor = cc.p( 0, 0 ),
			endCallback = function()
				tabCallback( i )
			end,
		})
		tabBtn:setScale(0.7)
		tabBtn:setPosition( 0, 460 - 85*i )
		self.shadow:addChild( tabBtn, 0 )
		self._tabsTable[i] = tabBtn
		-- 红点
		local redDot = cc.Sprite:create( "res/image/common/heroList_redPoint.png" )
        redDot:setAnchorPoint( 1, 1 )
        redDot:setPosition( tabBtn:getContentSize().width, tabBtn:getContentSize().height )
        redDot:setName( "redDot" )
        tabBtn:addChild( redDot )
	end
	self._tabsTable[self._tabIndex]:setSelected( true )
	self._tabsTable[self._tabIndex]:setEnable( false )
	self._tabsTable[self._tabIndex]:setLocalZOrder( 1 )
end
-- 创建左侧英雄所拥有的装备列表
function ZhuangBeiLayer:initLeft()
	-- 容器
	local leftContainer = XTHD.createSprite()
	leftContainer:setContentSize( self._leftSize )
	leftContainer:setAnchorPoint( cc.p( 0, 0 ) )
	leftContainer:setPosition( 35, self._bottomSize.height-10 )
	self._bottomBg:addChild( leftContainer, 2 )
	self._leftContainer = leftContainer
	-- 背景
	local leftBg = ccui.Scale9Sprite:create()
    leftBg:setContentSize( self._leftSize.width, self._leftSize.height )
    leftBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    leftBg:setPosition( self._leftSize.width*0.5, self._leftSize.height*0.5 )
    leftContainer:addChild( leftBg )
    -- tableview
    self._equipTableView = CCTableView:create( cc.size( leftBg:getContentSize().width - 6, leftBg:getContentSize().height-6 ) )
	TableViewPlug.init(self._equipTableView)
    self._equipTableView:setPosition( 3, 0 )
	self._equipTableView:setBounceable( true )
    self._equipTableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL ) --设置横向纵向
    self._equipTableView:setDelegate()
	self._equipTableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
    local cellSize = cc.size( leftBg:getContentSize().width, 100 )
    local function numberOfCellsInTableView( table )
		return #self._equipData
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
	    local data = self._equipData[index + 1]
	    -- cell背景
	    local cellBg = XTHD.createSprite()
		cellBg:setContentSize( cellSize.width - 6, cellSize.height )
		cellBg:setAnchorPoint( cc.p( 0, 0 ) )
		cellBg:setPosition( 3, 0)
		cell:addChild( cellBg )
		local cellBgSize = cellBg:getContentSize()
		-- 按钮
		-- normal
		local btn_normal = ccui.Scale9Sprite:create("res/image/common/scale9_bg1_26.png")
		btn_normal:setContentSize( cellBgSize )
		-- selected
		local btn_selected = ccui.Scale9Sprite:create("res/image/common/common_selected2.png")
		btn_selected:setContentSize( cellBgSize )
	    -- btn
	    local equipBtn = XTHD.createButton({
	    	normalNode = btn_normal,
	    	selectedNode = btn_selected,
	    	needSwallow = false,
			needEnableWhenMoving = true,
    	})
    	cell._equipBtn = equipBtn
    	if self._equipIndex == index + 1 then
    		self._equipCell = cell
    		equipBtn:setSelected( true )
    		equipBtn:setEnable( false )
    	end
    	equipBtn:setTouchEndedCallback( function()
    		if self._equipCell then
    			self._equipCell._equipBtn:setSelected( false )
    			self._equipCell._equipBtn:setEnable( true )
    		end
    		equipBtn:setSelected( true )
    		equipBtn:setEnable( false )
    		self._equipIndex = index + 1
    		if self._tabIndex == 1 or self._tabIndex == 2 or self._tabIndex == 3 then
    			self._equipDbid = data.dbid or 0
    		end
    		self._equipCell = cell
    		self:refreshInfo()
    	end)
    	equipBtn:setAnchorPoint( cc.p( 0, 0 ) )
    	cellBg:addChild( equipBtn )
		-- 装备icon
		local equipIcon = ItemNode:createWithParams({
			itemId = data.itemid,
            dbId = data.dbid,
            needSwallow = false,
            isShowDrop = false,
            _type_ = 4,
        })
		equipIcon:setAnchorPoint( cc.p( 0, 0.5 ) )
		equipIcon:setPosition( 10, cellBgSize.height*0.5 )
		equipIcon:setScale( 0.75 )
		cellBg:addChild( equipIcon )
    	data.name = equipIcon._Name
		-- 装备icon等级背景
		local equipIconLevelBg = cc.Sprite:createWithTexture( nil, cc.rect( 0, 0, 35, 22) )
	 	equipIconLevelBg:setColor( cc.c3b( 0, 0, 0 ) )
	 	equipIconLevelBg:setOpacity( 125.0 )
	 	equipIconLevelBg:setAnchorPoint( 0, 0 )
 		equipIconLevelBg:setPosition( 4, 20 )
 		equipIcon:addChild( equipIconLevelBg )
 		if data.strengLevel then
 			equipIconLevelBg:setVisible( true )
 		else
 			equipIconLevelBg:setVisible( false )
 		end
		-- 装备icon等级
	    local equipIconLevel = getCommonWhiteBMFontLabel( data.strengLevel or "" )
	    equipIconLevel:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	    equipIconLevel:setPosition( equipIconLevelBg:getContentSize().width*0.5, equipIconLevelBg:getContentSize().height*0.5 - 4 )
		equipIconLevelBg:addChild( equipIconLevel )
		-- 装备名称
		local equipName = XTHD.createLabel({
			text = equipIcon._Name,
			fontSize = 16,
			color = XTHD.resource.color.brown_desc,
		})
		cellBg:addChild( equipName )
		-- 可强化升星
		if self._tabIndex == 1 or self._tabIndex == 2 or self._tabIndex == 3 then
			-- 强化升星洗练
			equipName:setAnchorPoint( cc.p( 0.5, 0.5 ) )
			equipName:setPosition( ( cellBgSize.width + equipIcon:getPositionX() + equipIcon:getContentSize().width)*0.5 - 50, cellBgSize.height*0.5 )
			if self:judgeEquipRedDot( data ) then
				local equipRedDot = XTHD.createSprite( "res/image/plugin/equip_layer/equipRedDot"..self._tabIndex..".png" )
				equipRedDot:setAnchorPoint( cc.p( 1, 0.5 ) )
				equipRedDot:setPosition( cellSize.width - 10, cellSize.height*0.5 )
				cell:addChild( equipRedDot )
				equipRedDot:setScale(0.5)
			end
		else
			-- 合成
			equipName:setAnchorPoint( cc.p( 0, 0.5 ) )
			equipName:setPosition( cellBgSize.width - 180, cellBgSize.height - 30 )
			local tip = nil
			local fontColor = nil
			if data.prompt == 1 then
				-- 等级不足
				fontColor = cc.c4b(255,6,6,255)
				tip = LANGUAGE_KEY_LEVEL_LIMIT..data.needlv-------"需要等级" .. _needLv
			elseif data.prompt == 2 then
				-- 材料不足
				fontColor = cc.c4b(255,6,6,255)
				tip = LANGUAGE_KEY_HERO_TEXT.cannotMakeResonTextXc[3]------"材料不足"
			elseif data.prompt == 3 then
				-- 可以合成
				fontColor = cc.c4b(7,105,4,255)
				tip = LANGUAGE_KEY_HERO_TEXT.cannotMakeResonTextXc[5]------"材料充足" 
			end
			local tipLabel = XTHD.createLabel({
				text = tip,
				color = fontColor,
				fontSize = 18,
				anchor = cc.p( 0, 0 ),
				pos = cc.p( equipName:getPositionX() + 3, 10 ),
			})
			tipLabel:enableShadow(fontColor,cc.size(0.4,-0.4),0.4)
			cell:addChild( tipLabel )
		end
		-- cell分隔
		-- local splitCell = ccui.Scale9Sprite:create( cc.rect( 0, 0, 3, 2 ), "res/image/ranklistreward/splitcell.png" )
        -- splitCell:setContentSize( cellSize.width, 2 )
        -- splitCell:setAnchorPoint( cc.p( 0, 0 ) )
        -- splitCell:setPosition( 0, 0 )
        -- cell:addChild( splitCell )

	    return cell
	end
	self._equipTableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
	self._equipTableView.getCellNumbers=numberOfCellsInTableView
    self._equipTableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
	self._equipTableView.getCellSize=cellSizeForTable
    self._equipTableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
	leftBg:addChild( self._equipTableView )
	self._equipTableView:reloadData()
end
-- 创建右侧装备信息
function ZhuangBeiLayer:initRight()
	-- 容器
	local rightContainer = XTHD.createSprite()
	rightContainer:setContentSize( self._rightSize )
	rightContainer:setAnchorPoint( cc.p( 0, 0 ) )
	rightContainer:setPosition( self._leftSize.width+10, self._bottomSize.height-10 )
	self._bottomBg:addChild( rightContainer, 2 )
	self._rightContainer = rightContainer
	-- 背景
	-- local rightBg = XTHD.createSprite( "res/image/plugin/equip_layer/rightbg.png" )
	-- rightBg:setPosition( self._rightSize.width*0.5, self._rightSize.height*0.5 )
	-- rightBg:setScaleX( self._rightSize.width/604 )
	-- rightContainer:addChild( rightBg )
	-- 云
	-- local cloud01 = XTHD.createSprite( "res/image/common/common_cloud.png" )
	-- cloud01:setFlippedX( true )
	-- cloud01:setAnchorPoint( cc.p( 0, 1 ) )
	-- cloud01:setPosition( 0, self._rightSize.height )
	-- rightContainer:addChild( cloud01 )
	-- local cloud11 = XTHD.createSprite( "res/image/common/common_cloud.png" )
	-- cloud11:setAnchorPoint( cc.p( 1, 1 ) )
	-- cloud11:setPosition( self._rightSize.width, self._rightSize.height )
	-- rightContainer:addChild( cloud11 )
	-- local cloud00 = XTHD.createSprite( "res/image/common/common_cloud.png" )
	-- cloud00:setFlippedX( true )
	-- cloud00:setFlippedY( true )
	-- cloud00:setAnchorPoint( cc.p( 0, 0 ) )
	-- cloud00:setPosition( 0, 0 )
	-- rightContainer:addChild( cloud00 )
	-- local cloud10 = XTHD.createSprite( "res/image/common/common_cloud.png" )
	-- cloud10:setFlippedY( true )
	-- cloud10:setAnchorPoint( cc.p( 1, 0 ) )
	-- cloud10:setPosition( self._rightSize.width, 0 )
	-- rightContainer:addChild( cloud10 )
	-- 中间花纹
	-- local figure = XTHD.createSprite( "res/image/common/common_figure.png" )
	-- figure:setPosition( self._rightSize.width*0.5, self._rightSize.height*0.5 )
	-- rightContainer:addChild( figure )
	-- 问号
	local tip = XTHD.createButton({
		normalFile = "res/image/common/btn/tip_up.png",
		selectedFile = "res/image/common/btn/tip_down.png",
	})
	tip:setAnchorPoint( cc.p( 0, 1 ) )
	tip:setPosition( tip:getContentSize().width * 0.5, self._rightSize.height - 15 )
	rightContainer:addChild( tip )
	tip:setTouchEndedCallback( function()
		-- 转换成提示界面的index
		local tipIndex = {
			2,	-- 装备强化
			3,	-- 装备升星
			4,	-- 装备洗练
		}
		local tipLayer = requires("src/fsgl/layer/common/WanFaShuoMingLayer.lua"):create({type = tipIndex[self._tabIndex]}); --byhuangjunjian玩法说明                              
        self:addChild( tipLayer, 3 )
	end)
	self._tip = tip

	-- 装备
    -- local equipIconBg = XTHD.createSprite( "res/image/plugin/equip_layer/iconbg_aft.png" )
	-- equipIconBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	-- equipIconBg:setPosition( self._rightSize.width*0.5, self._rightSize.height - 50 )
	-- rightContainer:addChild( equipIconBg )
	-- -- 左边花纹
	-- local leftLace = XTHD.createSprite( "res/image/plugin/equip_layer/lace.png" )
	-- leftLace:setFlippedX( true )
	-- leftLace:setAnchorPoint( cc.p( 1, 0.5 ) )
	-- leftLace:setPosition( self._rightSize.width*0.5 - 80, equipIconBg:getPositionY() )
	-- rightContainer:addChild( leftLace )
	-- -- 右边花纹
	-- local rightLace = XTHD.createSprite( "res/image/plugin/equip_layer/lace.png" )
	-- rightLace:setAnchorPoint( cc.p( 0, 0.5 ) )
	-- rightLace:setPosition( self._rightSize.width*0.5 + 80, equipIconBg:getPositionY() )
	-- rightContainer:addChild( rightLace )

	-- 装备信息容器
	self._infoContainer = XTHD.createSprite()
	self._infoContainer:setContentSize( self._rightSize )
	self._infoContainer:setPosition( self._rightSize.width*0.5, self._rightSize.height*0.5)
	rightContainer:addChild( self._infoContainer )
end
-- 创建底部英雄头像列表
function ZhuangBeiLayer:initBottom()
	-- 背景
	local bottomBg = ccui.Scale9Sprite:create()
	bottomBg:setContentSize( self._bottomSize )
	bottomBg:setAnchorPoint( cc.p( 0.5, 0 ) )
	bottomBg:setPosition( self._bottomSize.width*0.5, -10 )
	self._bottomBg:addChild( bottomBg, 2 )

	local cellWidth = 85
	-- 中间头像
	self._heroIconTableView = CCTableView:create( cc.size( self._bottomSize.width - 160, self._bottomSize.height ) )
	TableViewPlug.init(self._heroIconTableView)
    self._heroIconTableView:setPosition( cc.p( 80, 0 ) )
    self._heroIconTableView:setDirection( cc.SCROLLVIEW_DIRECTION_HORIZONTAL ) --设置横向纵向
    self._heroIconTableView:setDelegate()
    local function numberOfCellsInTableView( table )
		return #self._heroData
	end
	local function cellSizeForTable( table, index )
		return  cellWidth,self._bottomSize.height
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
		if cell then
	        cell:removeAllChildren()
	    else
	        cell = cc.TableViewCell:new()
	    end
	    local heroIndex = index + 1
	    local heroData = self._heroData[heroIndex]
	    local heroIcon = nil
	    if tonumber( heroData.heroid ) == 0 then
	    	heroIcon = XTHD.createSprite( "res/image/plugin/equip_layer/other.png" )
	    else
		    heroIcon = HeroNode:createWithParams({
		    	heroid = heroData.heroid,
		    	level = heroData.level,
		    	advance = heroData.advance,
		    	star = heroData.star,
		    	isShowType = true
			})
		end
    	heroIcon:setScale( 76/heroIcon:getContentSize().width )
    	heroIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    	heroIcon:setPosition( cellWidth*0.5, self._bottomSize.height*0.5 )
		cell:addChild( heroIcon )

		-- normal
		local heroIconBtn_normal = ccui.Scale9Sprite:create()
		heroIconBtn_normal:setContentSize( heroIcon:getContentSize() )
		-- selected
		local heroIconBtn_selected = ccui.Scale9Sprite:create("res/image/illustration/selected.png")
		heroIconBtn_selected:setContentSize( heroIcon:getContentSize().width+32,heroIcon:getContentSize().height+32 )
		
		-- btn
		local heroIconBtn = XTHD.createButton({
			normalNode = heroIconBtn_normal,
			selectedNode = heroIconBtn_selected,
			needSwallow = false,
			needEnableWhenMoving = true,
			isTouchMoveselected = false
		})
		getCompositeNodeWithNode( heroIcon, heroIconBtn )
		cell._heroIconBtn = heroIconBtn
	
		local selectSp = heroIconBtn:getStateSelected()
		selectSp:setPosition(selectSp:getPositionX(),selectSp:getPositionY() - 3)		

		if self._tabIndex ~= 4 and self._heroIndex == heroIndex then
			self._heroCell = cell
			heroIconBtn:setSelected( true )
			heroIconBtn:setEnable( false )
		end
		heroIconBtn:setTouchEndedCallback(function()
	    	if self._heroCell then
    			self._heroCell._heroIconBtn:setSelected( false )
    			self._heroCell._heroIconBtn:setEnable( true )
    		end
    		heroIconBtn:setSelected( true )
    		heroIconBtn:setEnable( false )
			

    		self._heroIndex = heroIndex
			self._heroId = self._heroData[self._heroIndex].heroid
    		self._heroCell = cell
			self._equipDbid = 0
    		self:refreshEquip( true )
		end)

	    return cell
	end
	self._heroIconTableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
	self._heroIconTableView.getCellNumbers=numberOfCellsInTableView
    self._heroIconTableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
	self._heroIconTableView.getCellSize=cellSizeForTable
    self._heroIconTableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
	bottomBg:addChild( self._heroIconTableView )
	self._heroIconTableView:reloadData()

    -- 左边按钮
	local leftArrow = XTHD.createButton({
		normalFile = "res/image/plugin/stageChapter/btn_left_arrow.png",
		touchScale = 0.95,
		anchor = cc.p( 0.5, 0.5 ),
		pos = cc.p( 40 + 3, self._bottomSize.height*0.5 ),
		endCallback = function()
			self._heroIconTableView:scrollToLast()
		end,
	})
	bottomBg:addChild( leftArrow )
	-- 右边按钮
	local rightArrow = XTHD.createButton({
		normalFile = "res/image/plugin/stageChapter/btn_right_arrow.png",
		touchScale = 0.95,
		anchor = cc.p( 0.5, 0.5 ),
		pos = cc.p( self._bottomSize.width - 40 - 3, self._bottomSize.height*0.5 ),
		endCallback = function()
			self._heroIconTableView:scrollToNext()
		end,
	})
	bottomBg:addChild( rightArrow )
	
	-- 吞噬
	local swallow = XTHD.createButton({
        touchSize = self._bottomSize,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( self._bottomSize.width/2, self._bottomSize.height/2 ),
        needSwallow = true,
        beganCallback = function()
        	print("swallow")
            return true
        end,
    })
	bottomBg:addChild( swallow )
	self._swallow = swallow
	self._swallow:setEnable( false )
end
-- 强化
function ZhuangBeiLayer:createStrength( data )
	-- dump( data, "strength data" )

	-- 计算数据
	local property = self:buildStrengthData( data )
    
    -- 材料是否足够
    local moneyFlag = true
    local itemFlag = true
    local notEnoughItemId = 0
    -- 属性文字模块高度
	local propertyHeight = 148

	-- 强化装备
	local equipIcon = ItemNode:createWithParams({
        dbId = data.dbid,
        _type_ = 4,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( self._rightSize.width*0.5 - 1, self._rightSize.height - 50 ),
    })
    equipIcon:setScale( 0.8 )
    self._infoContainer:addChild( equipIcon )
    -- 等级
    -- 装备icon等级背景
	local equipIconLevelBg = cc.Sprite:createWithTexture( nil, cc.rect( 0, 0, 35, 22) )
 	equipIconLevelBg:setColor( cc.c3b( 0, 0, 0 ) )
 	equipIconLevelBg:setOpacity( 125.0 )
 	equipIconLevelBg:setAnchorPoint( 0, 0 )
	equipIconLevelBg:setPosition( 4, 20 )
	equipIcon:addChild( equipIconLevelBg )
	-- 装备icon等级
    local equipIconLevel = getCommonWhiteBMFontLabel( data.strengLevel )
    equipIconLevel:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    equipIconLevel:setPosition( equipIconLevelBg:getContentSize().width*0.5, equipIconLevelBg:getContentSize().height*0.5 - 4 )
	equipIconLevelBg:addChild( equipIconLevel )

	-- 中间
	-- 箭头
	local arrow = XTHD.createSprite( "res/image/plugin/equip_layer/arrow.png" )
	arrow:setPosition( self._rightSize.width*0.5, propertyHeight*0.5 + 120 )
	self._infoContainer:addChild( arrow )

	--背景
	local sx_bg = ccui.Scale9Sprite:create("res/image/plugin/equip_layer/sx_bg.png")
	sx_bg:setAnchorPoint(0.5,0.5)
	sx_bg:setContentSize(270,37)
	sx_bg:setPosition(self._rightSize.width*0.5 - 140, 120 + propertyHeight )
	self._infoContainer:addChild( sx_bg )
	-- 原属性
	local befProperty = XTHD.createLabel({
		text = LANGUAGE_KEY_PERPROPERTY,
		fontSize = 18,
		color = cc.c3b( 45,13,103 ),
		ttf = "res/fonts/def.ttf",
	})
	-- befProperty:enableOutline(cc.c4b(45,13,103,255),1)
	befProperty:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	befProperty:setPosition( sx_bg:getContentSize().width*0.5-10, sx_bg:getContentSize().height/2 )
	sx_bg:addChild( befProperty )
	--背景
	local sx_bg2 = ccui.Scale9Sprite:create("res/image/plugin/equip_layer/sx_bg.png")
	sx_bg2:setAnchorPoint(0.5,0.5)
	sx_bg2:setContentSize(270,37)
	sx_bg2:setPosition(self._rightSize.width*0.5 + 150, 120 + propertyHeight )
	self._infoContainer:addChild( sx_bg2 )
	-- 强化后属性
	local aftProperty = XTHD.createLabel({
		text = LANGUAGE_EQUIP_TEXT[11],
		fontSize = 18,
		color = cc.c3b( 45,13,103 ),
		ttf = "res/fonts/def.ttf",
	})
	-- aftProperty:enableOutline(cc.c4b(45,13,103,255),1)
	aftProperty:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	aftProperty:setPosition( sx_bg2:getContentSize().width*0.5, sx_bg2:getContentSize().height/2 )
	sx_bg2:addChild( aftProperty )

	-- 属性对比
	for i, v in ipairs( property ) do
		-- 原属性
		local befTextLabel = XTHD.createLabel({
			text = v.name..":",
			fontSize = 18,
			color = XTHD.resource.color.brown_desc,
		})
		befTextLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
--		befTextLabel:setPosition( befProperty:getPositionX() -befProperty:getContentSize().width*0.5 + 2 , 110 + propertyHeight - 25*i )
--		self._infoContainer:addChild( befTextLabel )
		local befNumLabel = XTHD.createLabel({
			text = " "..v.bef,
			fontSize = 20,
			color = XTHD.resource.color.brown_desc,
		})
		befNumLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
		befNumLabel:setPosition( befTextLabel:getPositionX() + befTextLabel:getContentSize().width, 110 + propertyHeight - 25*i )
		local node_1 = cc.Node:create()
		node_1:setContentSize(cc.size(befTextLabel:getContentSize().width + befNumLabel:getContentSize().width + 10,befNumLabel:getContentSize().height))
		node_1:setAnchorPoint(0.5,1)
		node_1:setPosition(sx_bg:getPositionX() - 5, 110 + propertyHeight -i*30)
		self._infoContainer:addChild( node_1 )
			
		node_1:addChild(befTextLabel)
		befTextLabel:setPosition(5,node_1:getContentSize().height - befTextLabel:getContentSize().height * 0.5)

		node_1:addChild(befNumLabel)
		befNumLabel:setPosition(befTextLabel:getContentSize().width + befTextLabel:getPositionX(),node_1:getContentSize().height - befTextLabel:getContentSize().height * 0.5 - 1)
		--self._infoContainer:addChild( befNumLabel )
		-- 强化后属性
		local aftTextLabel = XTHD.createLabel({
			text = v.name..":",
			fontSize = 18,
			color = XTHD.resource.color.brown_desc,
		})
		aftTextLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
--		aftTextLabel:setPosition( self._rightSize.width*0.5 + 150, 110 + propertyHeight - 25*i )
--		self._infoContainer:addChild( aftTextLabel )
		local aftNumLabel = XTHD.createLabel({
			text = " "..v.aft,
			fontSize = 20,
			color = cc.c3b( 104, 157, 0 ),
		})
		aftNumLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
		--aftNumLabel:setPosition( self._rightSize.width*0.5 + 150, 110 + propertyHeight - 25*i )
		local node_2 = cc.Node:create()
		node_2:setContentSize(cc.size(aftTextLabel:getContentSize().width + aftNumLabel:getContentSize().width + 10,aftNumLabel:getContentSize().height))
		node_2:setAnchorPoint(0.5,1)
		node_2:setPosition( sx_bg2:getPositionX()+5, 110 + propertyHeight -i*30)
		self._infoContainer:addChild( node_2 )
			
		node_2:addChild(aftTextLabel)
		aftTextLabel:setPosition(5,node_2:getContentSize().height - aftTextLabel:getContentSize().height * 0.5)
		node_2:addChild(aftNumLabel)
		aftNumLabel:setPosition(aftTextLabel:getContentSize().width + aftTextLabel:getPositionX(),node_2:getContentSize().height - aftNumLabel:getContentSize().height * 0.5 - 1)

--		self._infoContainer:addChild( aftNumLabel ) 
	end

	-- 所需材料
	-- 背景
	local needBg = ccui.Scale9Sprite:create("res/image/plugin/equip_layer/sxcl_bg.png")
	needBg:setContentSize( 663, 60 )
	needBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	needBg:setPosition( self._rightSize.width*0.5, 90 )
	self._infoContainer:addChild( needBg, 1 )
	-- 所需材料文字
	local needText = XTHD.createLabel({
		text = LANGUAGE_EQUIP_TEXT[2],
		fontSize = 18,
		color = cc.c3b(45,13,103),
		ttf = "res/fonts/def.ttf",
	})
	-- needText:enableOutline(cc.c4b(45,13,103,255),1)
	needText:setAnchorPoint( cc.p( 1, 0.5 ) )
	needText:setPosition( 290, needBg:getContentSize().height*0.5 )
	needBg:addChild( needText )
	-- 所需材料图标
	local needIconContainer = cc.Sprite:create()
	needIconContainer:setContentSize( needBg:getContentSize().width - needText:getPositionX(), needBg:getContentSize().height )
	needIconContainer:setAnchorPoint( cc.p( 0, 0 ) )
	needIconContainer:setPosition( needText:getPositionX(), 0 )
	needBg:addChild( needIconContainer )
	local strengthData = gameData.getDataFromCSV( "EquipUpList", {itemlevel = data.strengLevel + 1} )
	local rankData = gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = data.itemid} ).rank
	moneyFlag = gameUser.getGold() >= strengthData["consume"..rankData]
	local needIconData = {
		{
	        count = strengthData["consume"..rankData],
	        _type_ = 2,
	        fnt_type = moneyFlag and 1 or 2,
	    }
	}
	if strengthData.need and strengthData.need ~= 0 and strengthData["num"..rankData] ~= 0 then
		itemFlag = XTHD.resource.getItemNum( strengthData.need ) >= strengthData["num"..rankData]
		notEnoughItemId = strengthData.need 
		needIconData[#needIconData + 1] = {
			itemId = strengthData.need,
	        count = XTHD.resource.getItemNum( strengthData.need ).."/"..strengthData["num"..rankData],
	        _type_ = 4,
	        fnt_type = itemFlag and 1 or 2,
	    }
	end
	local needIcons = {}
	for i, v in ipairs(needIconData) do
		v.touchShowTip = false
		needIcons[i] = ItemNode:createWithParams( v )
		needIcons[i]:setScale( 0.6 )
		local needBtn = XTHD.createButton({
			normalNode = needIcons[i],
			touchSize = cc.size(needIcons[i]:getContentSize().width*0.6 - 15,needIcons[i]:getContentSize().height*0.6 - 15),
		})
		needBtn:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		needBtn:setPosition( needIconContainer:getContentSize().width/( #needIconData + 1 )*i-70, needIconContainer:getContentSize().height*0.5 )
		needIconContainer:addChild( needBtn )
		if v._type_ == 2 then
--			needBtn:setTouchEndedCallback( function()
--	            local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=1})
--			    self:addChild(StoredValue, 3)
--			end)
		elseif v._type_ == 4 then
--			needBtn:setTouchEndedCallback( function()
--				local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
--		        popLayer= popLayer:create( tonumber( v.itemId ) )
--		        self:addChild( popLayer, 3 )
--			end)
		end
	end

	-- 强化到最高
	local strengthMostBtn = XTHD.createCommonButton({
		text = LANGUAGE_EQUIP_TEXT[9],
		btnColor = "write_1",
		btnSize = cc.size(135,46),
		fontSize = 20,
		fontColor = cc.c3b( 255, 255, 255 ),
		anchor = cc.p( 0.5, 0.5 ),
		pos = cc.p( befProperty:getPositionX() + 40, 35 ),
	})
	strengthMostBtn:setScale(0.7)
	-- strengthMostBtn:getLabel():enableOutline(cc.c4b(150,79,39,255),1)
	self._infoContainer:addChild( strengthMostBtn )
	strengthMostBtn:setTouchEndedCallback( function()
		if tonumber( data.strengLevel ) >= tonumber( gameUser.getLevel() ) then
			-- 装备等级超过玩家等级
            XTHDTOAST( LANGUAGE_KEY_HERO_TEXT.noCanStrengthTextXc )
            return
        end
		if not moneyFlag then
			-- 缺钱
			local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=3})
		    self:addChild( layer, 3 )
			return
		end
		if not itemFlag then
			-- 缺强化石
			local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=5})
		    self:addChild( layer, 3 )
			return
		end
		-- 强化至最高提示弹窗
		local exitConfirm = XTHDConfirmDialog:createWithParams({
            rightCallback = function ()
                XTHDHttp:requestAsyncInGameWithParams({
                    modules="oneKeyStreng?",
                    params = {charType = data.heroid and "1" or "0", charId = data.heroid or "0", dbId = data.dbid},
                    successCallback = function( backData )
                        if tonumber( backData.result ) == 0 then
                        	self._touchLayer:setEnable( true )
                			self:createStrengthAnimation( equipIcon, needIcons )
                			performWithDelay( self, function()
						        self:allSuccessCallback( data, backData, equipIcon )
						    end, 0.44 )
							XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_RECHARGE_HUOYUEJIANGLI})
	                    else
	                        if backData.msg then
	                            XTHDTOAST( backData.msg )
	                        else
	                            XTHDTOAST( LANGUAGE_TIPS_WEBERROR )------"网络请求失败!")
	                        end
	                    end
                    end,--成功回调
                    failedCallback = function()
                        XTHDTOAST( LANGUAGE_TIPS_WEBERROR )-----"网络请求失败")
                    end,--失败回调
                    targetNeedsToRetain = self,--需要保存引用的目标
                    loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                })
            end
        })
        local exitContainer = exitConfirm:getContainer()
        local oneKeyStrengTip = XTHD.createLabel({
            fontSize = 20,
            color = cc.c3b( 70, 34, 34 ),
        })
        oneKeyStrengTip:setPosition( exitContainer:getBoundingBox().width/2, exitContainer:getBoundingBox().height - 50 )
        exitContainer:addChild( oneKeyStrengTip )
        -- icons
        local tmpData = {
            quality = data.quality,
            strengLevel = data.strengLevel,
        }
        local consumeIconData = XTHD.getEquipStrengthCostItems({equipmentsTable = {tmpData}})
        if table.nums(consumeIconData) == 0 then
            oneKeyStrengTip:setString(LANGUAGE_KEY_STRENGTHEN[1])
        else
            oneKeyStrengTip:setString(LANGUAGE_KEY_HERO_TEXT.oneKeyStrengthPopTextXc)
            local iconData = {}
            for i, v in pairs(consumeIconData)  do
                if i == "gold" then
                    iconData[#iconData + 1] = {
                        _type_ = v.itemType,
                        count = v.allNeedNum,
                    }
                else
                    iconData[#iconData + 1] = {
                        _type_ = v.itemType,
                        itemId = tonumber(i),
                        count = v.allNeedNum,
                    }
                end
            end
            iconPos = SortPos:sortFromMiddle(cc.p(exitContainer:getContentSize().width/2,exitContainer:getContentSize().height/2 + 13) ,#iconData, 60+9 )
            for i, v in ipairs(iconData) do
                local icon = XTHD.createItemNode(v)
                icon:setScale( 60/icon:getContentSize().width )
                icon:setPosition( iconPos[i] )
                exitContainer:addChild( icon )
            end
        end
        self:addChild( exitConfirm, 3 )
	end)
	-- 强化1次
	local strengthOnceBtn = XTHD.createCommonButton({
		btnColor = "write",
		btnSize = cc.size(135, 46),
		text = LANGUAGE_EQUIP_TEXT[10],
		isScrollView = false,
		fontSize = 20,
		fontColor = cc.c3b( 255, 255, 255 ),
		anchor = cc.p( 0.5, 0.5 ),
		pos = cc.p( sx_bg2:getPositionX(), 35 ),
	})
	strengthOnceBtn:setScale(0.7)
	-- strengthOnceBtn:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
	self._infoContainer:addChild( strengthOnceBtn )
	strengthOnceBtn:setTouchEndedCallback( function()
		if tonumber( data.strengLevel ) >= tonumber( gameUser.getLevel() ) then
			-- 装备等级超过玩家等级
            XTHDTOAST( LANGUAGE_KEY_HERO_TEXT.noCanStrengthTextXc )
            return
        end
		if not moneyFlag then
			-- 缺钱
			local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=3})
		    self:addChild( layer, 3 )
			return
		end
		if not itemFlag then
			-- 缺材料
			XTHDTOAST("道具不足，无法强化")
			local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=5})
		    self:addChild( layer, 3 )
			return
		end
		strengthOnceBtn:setEnable(false)
        XTHDHttp:requestAsyncInGameWithParams({
            modules = "itemStreng?",
            params = {charType = data.heroid and "1" or "0", charId = data.heroid or "0", dbId = data.dbid},
            successCallback = function( backData )
            	-- dump(backData, "backData")
                if tonumber( backData.result ) == 0 then
                	self._touchLayer:setEnable( true )
                	self:createStrengthAnimation( equipIcon, needIcons )
                	performWithDelay( self, function()
				        self:allSuccessCallback( data, backData, equipIcon )
				    end, 0.44 )
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_RECHARGE_HUOYUEJIANGLI})
					strengthOnceBtn:setEnable(true)
                elseif tonumber( backData.result ) == 2000 then
                    XTHD.createExchangePop(3)
                    strengthOnceBtn:setEnable(true)
                else
                    if backData.msg then
                        XTHDTOAST( backData.msg )
                    else
                        XTHDTOAST( LANGUAGE_TIPS_WEBERROR )-----"网络请求失败!")
                    end
                    strengthOnceBtn:setEnable(true)
                end
            end,--成功回调
            failedCallback = function()
                XTHDTOAST( LANGUAGE_TIPS_WEBERROR )-------"网络请求失败")
                strengthOnceBtn:setEnable(true)
            end,--失败回调
            targetNeedsToRetain = self,--需要保存引用的目标
            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        })
    end)
end
-- 强化数据
function ZhuangBeiLayer:buildStrengthData( data )
	-- dump( data, "strength data" )
	-- 属性数据
	local property = {}
	-- 原始属性，加上强化后的属性
	local baseProperty = {}
	if data.baseProperty and #data.baseProperty > 0 then
		if data.phaseLevel == 0 or not data.phaseProperty or #data.phaseProperty == 0 then
			-- 未升星装备，对基础属性四舍五入
			for i, v in ipairs( string.split( data.baseProperty, "#" ) ) do
				local base = string.split( v, "," )
				if tonumber( base[1] ) < 300 then
					base[2] = tonumber( base[2] )
					baseProperty[i] = base
				end
			end
		else
			-- 已升星装备，基础属性加上强化属性，四舍五入
			local phase = {}
			for i, v in ipairs( string.split( data.phaseProperty, "#" ) ) do
				local tmpPhase = string.split( v, "," )
				phase[tmpPhase[1]] = tmpPhase[2]
			end
			for i, v in ipairs( string.split( data.baseProperty, "#" ) ) do
				local tmpBase = string.split( v, "," )
				if tonumber( tmpBase[1] ) < 300 then
					local tmpData = {
						tmpBase[1],
						tonumber( tmpBase[2] ) + ( tonumber( phase[tmpBase[1]] ) or 0 ),
					}
					baseProperty[#baseProperty + 1] = tmpData
				end
			end
		end
	end
	-- dump( baseProperty, 'strength baseProperty' )
	-- 计算强化后装备的属性
	for i, v in ipairs( baseProperty ) do
		local maxNum = XTHD.resource.getAttributesMax( data.itemid, v[1], data.strengLevel )
	    local nextMax = XTHD.resource.getAttributesMax( data.itemid, v[1], data.strengLevel + 1 )
	    property[i] = {
	    	name = XTHD.resource.getAttributes(v[1]),
	    	bef = math.floor( v[2]*10 + 0.5 )*0.1,
	    	aft = math.floor( nextMax*( v[2]/maxNum )*10 + 0.5 )*0.1,
		}
	end
	-- dump( property, 'strength property' )
	return property
end
-- 升星
function ZhuangBeiLayer:createStarup( data )
	-- dump( data, "starup data" )

	-- 计算属性数据
	local property, phaseData, rankData = self:buildStarupData( data )
	-- dump( property, 'property' )

	-- 材料是否足够
    local moneyFlag = true
    local itemFlag = {}
    local notEnoughItemId = {}
    -- 属性文字模块高度
	local propertyHeight = 148

	-- 升星装备
	local equipIcon = ItemNode:createWithParams({
        dbId = data.dbid,
        _type_ = 4,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( self._rightSize.width*0.5 - 1, self._rightSize.height - 50 ),
    })
    equipIcon:setScale( 0.8 )
    self._infoContainer:addChild( equipIcon )
    -- 等级
    -- 装备icon等级背景
	local equipIconLevelBg = cc.Sprite:createWithTexture( nil, cc.rect( 0, 0, 35, 22) )
 	equipIconLevelBg:setColor( cc.c3b( 0, 0, 0 ) )
 	equipIconLevelBg:setOpacity( 125.0 )
 	equipIconLevelBg:setAnchorPoint( 0, 0 )
	equipIconLevelBg:setPosition( 4, 20 )
	equipIcon:addChild( equipIconLevelBg )
	-- 装备icon等级
    local equipIconLevel = getCommonWhiteBMFontLabel( data.strengLevel )
    equipIconLevel:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    equipIconLevel:setPosition( equipIconLevelBg:getContentSize().width*0.5, equipIconLevelBg:getContentSize().height*0.5 - 4 )
	equipIconLevelBg:addChild( equipIconLevel )

	local maxStars = gameData.getDataFromCSV( "EquipInfoList", {itemid = data.itemid}).advancetopvalue
	-- 星星
	for i = 1, data.phaseLevel do
		local star_light = XTHD.createSprite( "res/image/common/star_light.png" )
		star_light:setPosition( self._rightSize.width*0.5 - 120 + 40*i, self._rightSize.height - 110 )
		self._infoContainer:addChild( star_light )
	end
	for i = data.phaseLevel + 1, maxStars do
		local star_dark = XTHD.createSprite( "res/image/common/star_dark.png" )
		star_dark:setPosition( self._rightSize.width*0.5 - 120 + 40*i, self._rightSize.height - 110 )
		self._infoContainer:addChild( star_dark )
	end

	if maxStars > data.phaseLevel then
		--背景
		local sx_bg = ccui.Scale9Sprite:create("res/image/plugin/equip_layer/sx_bg.png")
		sx_bg:setAnchorPoint(0.5,0.5)
		sx_bg:setContentSize(270,37)
		sx_bg:setPosition(self._rightSize.width*0.5 - 140, 100 + propertyHeight )
		self._infoContainer:addChild( sx_bg )
		-- 原属性
		local befProperty = XTHD.createLabel({
			text = LANGUAGE_KEY_PERPROPERTY,
			fontSize = 18,
			color = cc.c3b( 45,13,103 ),
			ttf = "res/fonts/def.ttf",
		})
		-- befProperty:enableOutline(cc.c4b(45,13,103,255),1)
		befProperty:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		befProperty:setPosition( sx_bg:getContentSize().width*0.5-10, sx_bg:getContentSize().height/2 )
		sx_bg:addChild( befProperty )

		--背景
		local sx_bg2 = ccui.Scale9Sprite:create("res/image/plugin/equip_layer/sx_bg.png")
		sx_bg2:setAnchorPoint(0.5,0.5)
		sx_bg2:setContentSize(270,37)
		sx_bg2:setPosition(self._rightSize.width*0.5 + 150, 100 + propertyHeight )
		self._infoContainer:addChild( sx_bg2 )
		-- 升星后属性
		local aftProperty = XTHD.createLabel({
			text = LANGUAGE_EQUIP_TEXT[1],
			fontSize = 18,
			color = cc.c3b( 45,13,103 ),
			ttf = "res/fonts/def.ttf",
		})
		-- aftProperty:enableOutline(cc.c4b(45,13,103,255),1)
		aftProperty:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		aftProperty:setPosition( sx_bg2:getContentSize().width*0.5, sx_bg2:getContentSize().height/2 )
		sx_bg2:addChild( aftProperty )
		-- 箭头
		local arrow = XTHD.createSprite( "res/image/plugin/equip_layer/arrow.png" )
		arrow:setPosition( self._rightSize.width*0.5, propertyHeight*0.5 + 120 )
		self._infoContainer:addChild( arrow )
		-- 属性对比
		for i, v in ipairs(property) do
			-- 原属性
			local befTextLabel = XTHD.createLabel({
				text = v.name..":",
				fontSize = 18,
				color = XTHD.resource.color.brown_desc,
			})
			befTextLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
			befTextLabel:setPosition( sx_bg:getPositionX(), 110 + propertyHeight - 25*i-20 )
			--self._infoContainer:addChild( befTextLabel )
			local befNumLabel = XTHD.createLabel({
				text = " "..v.bef,
				fontSize = 20,
				color = XTHD.resource.color.brown_desc,
			})
			befNumLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
			befNumLabel:setPosition( sx_bg:getPositionX(), 110 + propertyHeight - 25*i - 20 )
			local node_1 = cc.Node:create()
			node_1:setContentSize(cc.size(befTextLabel:getContentSize().width + befNumLabel:getContentSize().width + 10,befNumLabel:getContentSize().height))
			node_1:setAnchorPoint(0.5,1)
			node_1:setPosition(sx_bg:getPositionX() - 5, 110 + propertyHeight -i*30)
			self._infoContainer:addChild( node_1 )
			
			node_1:addChild(befTextLabel)
			befTextLabel:setPosition(5,node_1:getContentSize().height - befTextLabel:getContentSize().height * 0.5)

			node_1:addChild(befNumLabel)
			befNumLabel:setPosition(befTextLabel:getContentSize().width + befTextLabel:getPositionX(),node_1:getContentSize().height - befTextLabel:getContentSize().height * 0.5 - 1)
			
			--self._infoContainer:addChild( befNumLabel )
			-- 升星后属性
			local aftTextLabel = XTHD.createLabel({
				text = v.name..":",
				fontSize = 18,
				color = XTHD.resource.color.brown_desc,
			})
			aftTextLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
			--aftTextLabel:setPosition( sx_bg2:getPositionX()-10, 110 + propertyHeight - 25*i -20)
			--self._infoContainer:addChild( aftTextLabel )
			local aftNumLabel = XTHD.createLabel({
				text = " "..v.aft.."(+"..v.pct.."%)",
				fontSize = 20,
				color = cc.c3b( 104, 157, 0 ),
			})
			aftNumLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
			--aftNumLabel:setPosition( sx_bg2:getPositionX()-10, 110 + propertyHeight - 25*i -20)

			local node_2 = cc.Node:create()
			node_2:setContentSize(cc.size(aftTextLabel:getContentSize().width + aftNumLabel:getContentSize().width + 10,aftNumLabel:getContentSize().height))
			node_2:setAnchorPoint(0.5,1)
			node_2:setPosition( sx_bg2:getPositionX()+5, 110 + propertyHeight -i*30)
			self._infoContainer:addChild( node_2 )
			
			node_2:addChild(aftTextLabel)
			aftTextLabel:setPosition(5,node_2:getContentSize().height - aftTextLabel:getContentSize().height * 0.5)

			node_2:addChild(aftNumLabel)
			aftNumLabel:setPosition(aftTextLabel:getContentSize().width + aftTextLabel:getPositionX(),node_2:getContentSize().height - aftNumLabel:getContentSize().height * 0.5 - 1)
			--self._infoContainer:addChild( aftNumLabel )
		end

		-- 所需材料
		-- 背景
		local needBg = ccui.Scale9Sprite:create("res/image/plugin/equip_layer/sxcl_bg.png" )
		needBg:setContentSize( 663, 60 )
		needBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		needBg:setPosition( self._rightSize.width*0.5, 90 )
		self._infoContainer:addChild( needBg )
		-- 所需材料文字
		local needText = XTHD.createLabel({
			text = LANGUAGE_EQUIP_TEXT[2],
			fontSize = 18,
			color = cc.c3b(45,13,103),
			ttf = "res/fonts/def.ttf",
		})
		-- needText:enableOutline(cc.c4b(45,13,103,255),1)
		needText:setAnchorPoint( cc.p( 1, 0.5 ) )
		needText:setPosition( 270, needBg:getContentSize().height*0.5 )
		needBg:addChild( needText )
		-- 所需材料图标
		local needIconContainer = cc.Sprite:create()
		needIconContainer:setContentSize( needBg:getContentSize().width - needText:getPositionX(), needBg:getContentSize().height )
		needIconContainer:setAnchorPoint( cc.p( 0, 0 ) )
		needIconContainer:setPosition( needText:getPositionX(), 0 )
		needBg:addChild( needIconContainer )
		moneyFlag = gameUser.getGold() >= phaseData.goldprice*XTHD.resource.advanceGoldCoefficient[rankData]
		local needIconData = {
			{
		        count = phaseData.goldprice*XTHD.resource.advanceGoldCoefficient[rankData],
		        _type_ = 2,
		        fnt_type = moneyFlag and 1 or 2,
		    }
		}
		if phaseData["num"..rankData] then
			local numTable = string.split( phaseData["num"..rankData], "#" )
			local csmTable = string.split( phaseData["consumables"..rankData], "#" )
			local i = 1
			while numTable[i] do
				itemFlag[#itemFlag + 1] = XTHD.resource.getItemNum( csmTable[i] ) >= tonumber( numTable[i] )
				notEnoughItemId[#notEnoughItemId + 1] = csmTable[i]
				needIconData[#needIconData + 1] = {
					itemId = csmTable[i],
			        count = XTHD.resource.getItemNum( csmTable[i] ).."/"..numTable[i],
			        _type_ = 4,
			        fnt_type = itemFlag[#itemFlag] and 1 or 2,
			    }
				i = i + 1
			end
		end
		local needIcons = {}
		for i, v in ipairs(needIconData) do
			v.touchShowTip = false
			needIcons[i] = ItemNode:createWithParams( v )
			needIcons[i]:setScale( 0.6 )
			local needBtn = XTHD.createButton({
				normalNode = needIcons[i],
				touchSize = needIcons[i]:getContentSize(),
			})
			needBtn:setAnchorPoint( cc.p( 0.5, 0.5 ) )
			needBtn:setPosition( needIconContainer:getContentSize().width/( #needIconData + 2 )*i-40, needIconContainer:getContentSize().height*0.5 )
			needIconContainer:addChild( needBtn )
			if v._type_ == 2 then
				needBtn:setTouchEndedCallback( function()
					-- replaceLayer({id = 14,fNode = self,zorder = 3})
		            local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=3})
				    self:addChild(StoredValue, 3)
				end)
			elseif v._type_ == 4 then
				-- needBtn:setTouchEndedCallback( function()
				-- 	local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
			 --        popLayer= popLayer:create( tonumber( v.itemId ) )
			 --        self:addChild( popLayer, 3 )
				-- end)
			end
		end

		-- 升星成功率
		local successText = XTHD.createLabel({
			text = LANGUAGE_EQUIP_TEXT[3],
			fontSize = 18,
			color = XTHD.resource.color.brown_desc,
		})
		successText:setAnchorPoint( cc.p( 1, 0.5 ) )
		successText:setPosition( 205, 30 )
		self._infoContainer:addChild( successText )
		local successNum = XTHD.createLabel({
			text = phaseData.success .. "%",
			fontSize = 18,
			color = cc.c3b( 205, 101, 8 ),
		})
		successNum:setAnchorPoint( cc.p( 0, 0.5 ) )
		successNum:setPosition( 205, 30 )
		self._infoContainer:addChild( successNum )
		
		-- 开始进阶
		local starupBtn = XTHD.createCommonButton({
			btnColor = "write",
			btnSize = cc.size(135, 46),
			isScrollView = false,
			text = LANGUAGE_KEY_HERO_TEXT.btnStarupTextXc,
			fontSize = 20,
			fontColor = cc.c3b( 255, 255, 255 ),
			anchor = cc.p( 0.5, 0.5 ),
			pos = cc.p( sx_bg2:getPositionX(), 30),
		})
		starupBtn:setScale(0.7)
		-- starupBtn:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
		self._infoContainer:addChild( starupBtn )
		
		starupBtn:setTouchEndedCallback( function()
			if not moneyFlag then
				-- 缺钱
				local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=3})
			    self:addChild( layer, 3 )
				return
			end
			for i, v in ipairs( itemFlag ) do
				if not v then
					-- 缺材料
			  		local rightCallback = function()
			  			-- local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
				    --     popLayer = popLayer:create( tonumber( notEnoughItemId[i] ) )
				    --     self:addChild( popLayer, 3 )
			  		end
					local layer = requires("src/fsgl/layer/ZhuangBei/ZhuangBeiLacePop.lua"):create({itemId = notEnoughItemId[i], rightCallback = rightCallback})
				    self:addChild( layer, 3 )
					return
				end
			end
			starupBtn:setEnable(false)
	        XTHDHttp:requestAsyncInGameWithParams({
	            modules= "itemPhase?",
	            params = {charType = data.heroid and "1" or "0", charId = data.heroid or "0", dbId = data.dbid},
	            successCallback = function( backData )
	            	-- dump( backData, "backData" )
		            if tonumber( backData.result ) == 0 then
		            	local resultData = {
		                    oldData = clone( data or {} ), 
		                    newData = backData.itemProperty or {},
		                    property = property or {},
		                }
		            	self:allSuccessCallback( data, backData, equipIcon, needIcons, true )
		            	backData.itemProperty.phaseLevel = backData.itemProperty.property.phaseLevel
		                local resultPop = requires( "src/fsgl/layer/ZhuangBei/ZhuangBeiPhaseResultPopLayer.lua" ):create( "success", resultData )
		                self:addChild( resultPop, 3 )
		                -- starupBtn:setEnable(true)
		            elseif tonumber( backData.result ) == 2000 then
		                XTHD.createExchangePop(3)
		                starupBtn:setEnable(true)
		            elseif tonumber( backData.result ) == 3012 then
		                local resultPop = requires( "src/fsgl/layer/ZhuangBei/ZhuangBeiPhaseResultPopLayer.lua" ):create()
		                self:addChild( resultPop, 3 )
		                --刷新背包
		    			XTHD.saveItem( {items = backData.items} )
		    			gameUser.setGold( backData.gold )
		    			XTHD.dispatchEvent( {name = CUSTOM_EVENT.REFRESH_TOP_INFO} )
						self._equipDbid = self._equipData[self._equipIndex].dbid
		                if self._heroId == 0 then
							self:refreshEquip( true )
						else
							self:refreshEquip()
						end
						-- starupBtn:setEnable(true)
		            else
		                if backData.msg then
		                    XTHDTOAST( backData.msg )
		                else
		                    XTHDTOAST( LANGUAGE_TIPS_WEBERROR )----"网络请求失败!")
		                end
		                starupBtn:setEnable(true)
		            end
	            end,--成功回调
	            failedCallback = function()
	                XTHDTOAST( LANGUAGE_TIPS_WEBERROR )-----"网络请求失败")
	                starupBtn:setEnable(true)
	            end,--失败回调
	            targetNeedsToRetain = self,--需要保存引用的目标
	            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	        })
		end)
	else
		-- 当前已进阶到最高等级
		local maxStarsText = XTHD.createLabel({
			text = LANGUAGE_EQUIP_TEXT[5],
			fontSize = 18,
			color = cc.c3b( 205, 101, 8 ),
		})
		maxStarsText:setAnchorPoint( cc.p( 0.5, 1 ) )
		maxStarsText:setPosition( self._rightSize.width*0.5, 110 + propertyHeight )
		self._infoContainer:addChild( maxStarsText )
		-- 原属性
		for i, v in ipairs(property) do
			local textLabel = XTHD.createLabel({
				text = v.name..":",
				fontSize = 18,
				color = XTHD.resource.color.brown_desc,
			})
			textLabel:setAnchorPoint( cc.p( 1, 0.5 ) )
			textLabel:setPosition( maxStarsText:getPositionX(), 100 + propertyHeight - 25*i )
			self._infoContainer:addChild( textLabel )
			local numLabel = XTHD.createLabel({
				text = " "..v.bef,
				fontSize = 20,
				color = XTHD.resource.color.brown_desc,
			})
			numLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
			numLabel:setPosition( maxStarsText:getPositionX(), 100 + propertyHeight - 25*i )
			self._infoContainer:addChild( numLabel )
		end
	end
end
-- 升星数据
function ZhuangBeiLayer:buildStarupData( data )
	-- dump( data, "starup data" )
	-- 属性数据
	local baseProperty = {}
	if data.baseProperty and #data.baseProperty > 0 then
		for i, v in ipairs( string.split( data.baseProperty, "#" ) ) do
			local base = string.split( v, "," )
			if tonumber( base[1] ) < 300 then
				base[2] = tonumber( base[2] )
				baseProperty[#baseProperty + 1] = base
			end
		end
	end
	-- dump( baseProperty, 'starup baseProperty' )
	-- 处理属性
	local property = {}
	local befPhaseData = gameData.getDataFromCSV( "EquipAscendingStar", {stage = data.phaseLevel} )
	local aftPhaseData = gameData.getDataFromCSV( "EquipAscendingStar", {stage = data.phaseLevel + 1} )
	local rankData = gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = data.itemid} ).rank
	for i, v in ipairs( baseProperty ) do
	    property[i] = {
	    	name = XTHD.resource.getAttributes(v[1]),
	    	bef = math.floor( tonumber( v[2] + v[2]*( befPhaseData and befPhaseData["percent"..rankData] or 0 )*0.01 )*10 + 0.5 )*0.1,
	    	aft = math.floor( tonumber( v[2] + v[2]*( aftPhaseData and aftPhaseData["percent"..rankData] or 0 )*0.01 )*10 + 0.5 )*0.1,
	    	pct = aftPhaseData and aftPhaseData["percent"..rankData] or 0,
		}
	end
	-- dump( property, 'starup property' )

	return property, aftPhaseData, rankData
end
-- 洗练
function ZhuangBeiLayer:createReforge( data )
	-- dump( data, "reforge data" )

	-- 计算属性
	local property, reforgedFlag, topProperty = self:buildReforgeData( data )

	-- 材料是否足够
    local moneyFlag = true
    local ingotFlag = true
    local itemFlag = true
    -- 属性文字模块高度
	local propertyHeight = 148

	-- 洗练
	local equipIcon = ItemNode:createWithParams({
        dbId = data.dbid,
        _type_ = 4,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( self._rightSize.width*0.5 - 1, self._rightSize.height - 50 ),
    })
    equipIcon:setScale( 0.8 )
    self._infoContainer:addChild( equipIcon )
    -- 装备icon等级背景
	local equipIconLevelBg = cc.Sprite:createWithTexture( nil, cc.rect( 0, 0, 35, 22) )
 	equipIconLevelBg:setColor( cc.c3b( 0, 0, 0 ) )
 	equipIconLevelBg:setOpacity( 125.0 )
 	equipIconLevelBg:setAnchorPoint( 0, 0 )
	equipIconLevelBg:setPosition( 4, 20 )
	equipIcon:addChild( equipIconLevelBg )
	-- 装备icon等级
    local equipIconLevel = getCommonWhiteBMFontLabel( data.strengLevel )
    equipIconLevel:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    equipIconLevel:setPosition( equipIconLevelBg:getContentSize().width*0.5, equipIconLevelBg:getContentSize().height*0.5 - 4 )
	equipIconLevelBg:addChild( equipIconLevel )

	--背景
	local sx_bg2 = ccui.Scale9Sprite:create("res/image/plugin/equip_layer/sx_bg.png")
	sx_bg2:setAnchorPoint(0.5,0.5)
	sx_bg2:setContentSize(520,37)
	sx_bg2:setPosition(self._rightSize.width*0.5, 126 + propertyHeight )
	self._infoContainer:addChild( sx_bg2 )
	-- 原属性提高后会提高强化和升星效果
	local reforgeProperty = XTHD.createLabel({
		text = LANGUAGE_EQUIP_TEXT[6],
		fontSize = 18,
		color = cc.c3b( 45,13,103 ),
		ttf = "res/fonts/def.ttf",
	})
	-- reforgeProperty:enableOutline(cc.c4b(45,13,103,255),1)
	reforgeProperty:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	reforgeProperty:setPosition( sx_bg2:getContentSize().width/2,sx_bg2:getContentSize().height/2 )
	sx_bg2:addChild( reforgeProperty )
	
	-- 属性对比
	for i, v in ipairs( property ) do
		-- 原属性
		local befTextLabel = XTHD.createLabel({
			text = v.name..":",
			fontSize = 18,
			color = XTHD.resource.color.brown_desc,
		})
		befTextLabel:setAnchorPoint( cc.p( 1, 0.5 ) )
		befTextLabel:setPosition( self._rightSize.width*0.5 - 68, 120 + propertyHeight - 25*i )
		self._infoContainer:addChild( befTextLabel )
		local befNumLabel = XTHD.createLabel({
			text = " "..v.bef,
			fontSize = 20,
			color = XTHD.resource.color.brown_desc,
		})
		befNumLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
		befNumLabel:setPosition( befTextLabel:getPositionX() + 10 , 120 + propertyHeight - 25*i )
		self._befNumLabel = befNumLabel
		self._infoContainer:addChild( befNumLabel )
		if reforgedFlag then	
			self._befNumLabel:setVisible(false)
		else
			self._befNumLabel:setVisible(true)
		end
		-- 洗练后变化
		if reforgedFlag and v.arrow and v.arrow ~= 0 then
			-- 洗练后属性
			local arrow = XTHD.createSprite( "res/image/plugin/equip_layer/arrow"..v.arrow..".png" )
			arrow:setAnchorPoint( cc.p( 0, 0.5 ) )
			arrow:setPosition( self._rightSize.width*0.5 - 60, 120 + propertyHeight - 25*i )
			arrow:setScale(0.8)
			self._infoContainer:addChild( arrow )
			local aftNumLabel = XTHD.createLabel({
				text = " "..v.aft,
				fontSize = 20,
				color = cc.c3b( 104, 157, 0 ),
			})
			aftNumLabel:setAnchorPoint( cc.p( 0, 0.5 ) )
			aftNumLabel:setPosition( self._rightSize.width*0.5 - 40, 120 + propertyHeight - 25*i )
			self._infoContainer:addChild( aftNumLabel )
		end
		-- 上限
		local limit = XTHD.createLabel({
			text = LANGUAGE_EQUIP_LIMIT(v.max),
			fontSize = 18,
			color = cc.c3b( 205, 101, 8 ),
		})
		limit:setAnchorPoint( cc.p( 1, 0.5 ) )
		limit:setPosition( self._rightSize.width*0.5 + limit:getContentSize().width*1.5 - 3, 120 + propertyHeight - 25*i )
		self._infoContainer:addChild( limit )
	end

	-- 所需材料
	-- 背景
	local needBg = ccui.Scale9Sprite:create("res/image/plugin/equip_layer/sxcl_bg.png" )
	needBg:setContentSize( 663, 80 )
	needBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	needBg:setPosition( self._rightSize.width*0.5+20, 80 )
	self._infoContainer:addChild( needBg )
	local needBgSize = needBg:getContentSize()
	-- 分隔线
	-- local splitLine = ccui.Scale9Sprite:create( cc.rect( 0, 0, 20, 2 ), "res/image/ranklistreward/splitX.png" )
	-- splitLine:setContentSize( needBgSize.height, 2 )
	-- splitLine:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	-- splitLine:setPosition( needBgSize.width*0.5, needBgSize.height*0.5 )
	-- splitLine:setRotation( 90 )
	-- needBg:addChild( splitLine )

	-- 洗练方式选择
	-- 随机改变属性
	local randomChoice_normal = XTHD.createSprite( "res/image/plugin/equip_layer/checkbox_up.png" )
	local randomChoice_selected = XTHD.createSprite( "res/image/plugin/equip_layer/checkbox_down.png" )
	local randomChoice = XTHDCheckBox.new({
        normalNode = randomChoice_normal,
        selectedNode = randomChoice_selected,
        check = self._reforgeChoiceFlag == 1,
        clickable = self._reforgeChoiceFlag == 2,
        anchor = cc.p( 1, 0.5 ),
        pos = cc.p( 130, needBgSize.height*0.75 ),
        endCallback = function()
			self._reforgeChoiceFlag = 1
			self:refreshInfo()
		end,
    })
    needBg:addChild( randomChoice )
    local randomText = XTHD.createLabel({
		text = LANGUAGE_TIPS_WORDS46,
		fontSize = 18,
		color = XTHD.resource.color.brown_desc,
		endCallback = function()
			self._reforgeChoiceFlag = 1
			self:refreshInfo()
		end,
	})
	randomText:setAnchorPoint( cc.p( 0, 0.5 ) )
	randomText:setPosition( randomChoice:getPositionX() + 10, randomChoice:getPositionY() )
	needBg:addChild( randomText )
	-- 必定提高属性
    local mustChoice_normal = XTHD.createSprite( "res/image/plugin/equip_layer/checkbox_up.png" )
	local mustChoice_selected = XTHD.createSprite( "res/image/plugin/equip_layer/checkbox_down.png" )
	local mustChoice = XTHDCheckBox.new({
        normalNode = mustChoice_normal,
        selectedNode = mustChoice_selected,
        check = self._reforgeChoiceFlag == 2,
        clickable = self._reforgeChoiceFlag == 1,
        anchor = cc.p( 1, 0.5 ),
        pos = cc.p( 130, needBgSize.height*0.25 ),
        endCallback = function()
			self._reforgeChoiceFlag = 2
			self:refreshInfo()
		end,
    })
    needBg:addChild( mustChoice )
    local mustText = XTHD.createLabel({
		text = LANGUAGE_TIPS_WORDS47,
		fontSize = 18,
		color = XTHD.resource.color.brown_desc,
		endCallback = function()
			self._reforgeChoiceFlag = 2
			self:refreshInfo()
		end,
	})
	mustText:setAnchorPoint( cc.p( 0, 0.5 ) )
	mustText:setPosition( mustChoice:getPositionX() + 10, mustChoice:getPositionY() )
	needBg:addChild( mustText )

	-- 所需材料文字
	local needText = XTHD.createLabel({
		text = LANGUAGE_EQUIP_TEXT[2],
		fontSize = 18,
		color = cc.c3b(45,13,103),
		ttf = "res/fonts/def.ttf",
	})
	-- needText:enableOutline(cc.c4b(45,13,103,255),1)
	needText:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	needText:setPosition( needBgSize.width*0.5+20, needBgSize.height*0.5 )
	needBg:addChild( needText )
	-- 所需材料图标
	local needIconContainer = cc.Sprite:create()
	needIconContainer:setContentSize( needBgSize.width*0.5, needBgSize.height - needText:getContentSize().height - 5 )
	needIconContainer:setAnchorPoint( cc.p( 0, 0 ) )
	needIconContainer:setPosition( needBgSize.width*0.5, 0 )
	needBg:addChild( needIconContainer )
	
	local rankData = gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = data.itemid} ).rank
	local reforgeData = gameData.getDataFromCSV( "EquipSmeltingList", {quality = rankData} )
	local needIconData = {}
	if self._reforgeChoiceFlag == 1 then
		-- 随机改变属性
		moneyFlag = gameUser.getGold() >= reforgeData.basegold*( topProperty + 1 )
		needIconData[#needIconData + 1] = {
	        count = reforgeData.basegold*( topProperty + 1 ),
	        _type_ = 2,
	        fnt_type = moneyFlag and 1 or 2,
	    }
	    itemFlag = XTHD.resource.getItemNum( reforgeData.needitem ) >= reforgeData.neednum*( topProperty + 1 )
	    notEnoughItemId = reforgeData.needitem
		needIconData[#needIconData + 1] = {
			itemId = reforgeData.needitem,
	        count = XTHD.resource.getItemNum( reforgeData.needitem ).."/"..reforgeData.neednum*( topProperty + 1 ),
	        _type_ = 4,
	        fnt_type = itemFlag and 1 or 2,
	    }
	elseif self._reforgeChoiceFlag == 2 then
		-- 必然提高属性
		ingotFlag = gameUser.getIngot() >= reforgeData.baseingot*( #property - topProperty )
		needIconData[#needIconData + 1] = {
	        count = reforgeData.baseingot*( #property - topProperty ),
	        _type_ = 3,
	        fnt_type = ingotFlag and 1 or 2,
	    }
	    itemFlag = XTHD.resource.getItemNum( reforgeData.needitem ) >= reforgeData.neednum*( #property - topProperty )
	    notEnoughItemId = reforgeData.needitem
		needIconData[#needIconData + 1] = {
			itemId = reforgeData.needitem,
	        count = XTHD.resource.getItemNum( reforgeData.needitem ).."/"..reforgeData.neednum*( #property - topProperty ),
	        _type_ = 4,
	        fnt_type = itemFlag and 1 or 2,
	    }
	end
	-- dump( needIconData, "needIconData" )
	local needIcons = {}
	for i, v in ipairs(needIconData) do
		v.touchShowTip = false
		needIcons[i] = ItemNode:createWithParams( v )
		needIcons[i]:setScale( 0.6 )
		local needBtn = XTHD.createButton({
			normalNode = needIcons[i],
			touchSize = needIcons[i]:getContentSize(),
		})
		needBtn:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		needBtn:setPosition( needIconContainer:getContentSize().width/( #needIconData + 3 )*i+50, needIconContainer:getContentSize().height*0.5+15 )
		needIconContainer:addChild( needBtn )
		if v._type_ == XTHD.resource.type.ingot then
			-- 元宝
			needBtn:setTouchEndedCallback( function()
				XTHD.createRechargeVipLayer( self, nil, 3 )
			end)
		elseif v._type_ == XTHD.resource.type.gold then
			-- 银两
			needBtn:setTouchEndedCallback( function()
				-- replaceLayer({id = 14,fNode = self,zorder = 3})
	            local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=3})
			    self:addChild(StoredValue, 3)
			end)
		elseif v._type_ == XTHD.resource.type.item then
			-- 道具
			needBtn:setTouchEndedCallback( function()
				-- local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
		  --       popLayer= popLayer:create( tonumber( v.itemId ) )
		  --       self:addChild( popLayer, 3 )
			end)
		end
	end

	-- 底部按钮
	if reforgedFlag then
		-- 再洗1次
		local reforgeMoreBtn = XTHD.createCommonButton({
			btnColor = "write_1",
			text = LANGUAGE_EQUIP_TEXT[7],
			isScrollView = false,
			btnSize = cc.size(135,46),
			fontSize = 26,
			fontColor = cc.c3b( 255, 255, 255 ),
			anchor = cc.p( 0.5, 0.5 ),
			pos = cc.p( self._rightSize.width*0.5 - 140, 15 ),
		})
		reforgeMoreBtn:setScale(0.7)
		-- reforgeMoreBtn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
		self._infoContainer:addChild( reforgeMoreBtn )
		reforgeMoreBtn:setTouchEndedCallback( function()
			if not moneyFlag then
				-- 缺钱
	   			local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=3})
			    self:addChild( layer, 3 )
				return
			end
			if not ingotFlag then
				-- 缺元宝
	   			local layer = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=1})
			    self:addChild( layer, 3 )
				return
			end
			if not itemFlag then
				-- 缺材料
	  			local rightCallback = function()
		  			-- local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
			    --     popLayer= popLayer:create( tonumber( notEnoughItemId ) )
			    --     self:addChild( popLayer, 3 )
		  		end
				local layer = requires("src/fsgl/layer/ZhuangBei/ZhuangBeiLacePop.lua"):create({itemId = notEnoughItemId, rightCallback = rightCallback})
			    self:addChild( layer, 3 )
				return
			end

			if topProperty >= #property then
				XTHDTOAST(LANGUAGE_EQUIP_TEXT[18])
				return
			end
	        XTHDHttp:requestAsyncInGameWithParams({
	            modules = "itemPlus?",
	            params = {charType = data.heroid and "1" or "0", charId = data.heroid or "0", dbId = data.dbid, plusType = self._reforgeChoiceFlag },
	            successCallback = function( backData )
	            	-- dump( backData, "backData" )
	            	if tonumber( backData.result ) == 0 then
						self._befNumLabel:setVisible(false)
	            		self:allSuccessCallback( data, backData, equipIcon, needIcons )
						XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_RECHARGE_HUOYUEJIANGLI})
	            	elseif tonumber( backData.result ) == 2000 then
		                XTHD.createExchangePop(3)
		            else
		                if backData.msg then
		                    XTHDTOAST( backData.msg )
		                else
		                    XTHDTOAST( LANGUAGE_TIPS_WEBERROR )----"网络请求失败!")
		                end
		            end
	            end,--成功回调
	            failedCallback = function()
	                XTHDTOAST( LANGUAGE_TIPS_WEBERROR )-----"网络请求失败")
	            end,--失败回调
	            targetNeedsToRetain = self,--需要保存引用的目标
	            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
		end)
		-- 替换属性
		local replaceBtn = XTHD.createCommonButton({
			btnColor = "write",
			btnSize = cc.size(135, 46),
			text = LANGUAGE_EQUIP_TEXT[8],
			isScrollView = false,
			fontSize = 26,
			fontColor = cc.c3b( 255, 255, 255 ),
			anchor = cc.p( 0.5, 0.5 ),
			pos = cc.p( self._rightSize.width*0.5 + 140, 15 ),
		})
		replaceBtn:setScale(0.7)
		-- replaceBtn:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
		self._infoContainer:addChild( replaceBtn )
		replaceBtn:setTouchEndedCallback( function()
	        XTHDHttp:requestAsyncInGameWithParams({
	            modules = "replacePlusProperty?",
	            params = {charType = data.heroid and "1" or "0", charId = data.heroid or "0", dbId = data.dbid },
	            successCallback = function( backData )
	            	-- dump( backData, "backData" )
	            	if tonumber( backData.result ) == 0 then
						self._befNumLabel:setVisible(true)
	            		self:allSuccessCallback( data, backData )
	            	elseif tonumber( backData.result ) == 2000 then
		                XTHD.createExchangePop(3)
		            else
		                if backData.msg then
		                    XTHDTOAST( backData.msg )
		                else
		                    XTHDTOAST( LANGUAGE_TIPS_WEBERROR )----"网络请求失败!")
		                end
		            end
	            end,--成功回调
	            failedCallback = function()
	                XTHDTOAST( LANGUAGE_TIPS_WEBERROR )-----"网络请求失败")
	            end,--失败回调
	            targetNeedsToRetain = self,--需要保存引用的目标
	            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
		end)
	else
		-- 洗练
		local reforgeBtn = XTHD.createCommonButton({
			btnColor = "write",
			isScrollView = false,
			btnSize = cc.size(135, 46),
			text = LANGUAGE_VERBS.wash,
			fontSize = 26,
			fontColor = cc.c3b( 255, 255, 255 ),
			anchor = cc.p( 0.5, 0.5 ),
			pos = cc.p( self._rightSize.width*0.5, 15 ),
		})
		reforgeBtn:setScale(0.7)
		-- reforgeBtn:getLabel():enableOutline(cc.c4b(103,34,13,255),2)
		self._infoContainer:addChild( reforgeBtn )
		reforgeBtn:setTouchEndedCallback( function()
			if not moneyFlag then
				-- 缺钱
				XTHDTOAST( LANGUAGE_ERROR_CODE["2000"] )
				-- replaceLayer({id = 14,fNode = self,zorder = 3})
	            local StoredValue = requires("src/fsgl/layer/common/SourceLackPop1.lua"):create({id=3})
			    self:addChild(StoredValue, 3)
				return
			end
			if not ingotFlag then
				-- 缺元宝
				XTHDTOAST( LANGUAGE_ERROR_CODE["2004"] )
				XTHD.createRechargeVipLayer( self:getParent(), nil, 3 )
				return
			end
			if not itemFlag then
				-- 缺材料
				local rightCallback = function()
		  			-- local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
			    --     popLayer= popLayer:create( tonumber( notEnoughItemId ) )
			    --     self:addChild( popLayer, 3 )
		  		end
				local layer = requires("src/fsgl/layer/ZhuangBei/ZhuangBeiLacePop.lua"):create({itemId = notEnoughItemId, rightCallback = rightCallback})
			    self:addChild( layer, 3 )
				return
			end

			if topProperty >= #property then
				XTHDTOAST(LANGUAGE_EQUIP_TEXT[18])
				return
			end
	        XTHDHttp:requestAsyncInGameWithParams({
	            modules = "itemPlus?",
	            params = {charType = data.heroid and "1" or "0", charId = data.heroid or "0", dbId = data.dbid, plusType = self._reforgeChoiceFlag },
	            successCallback = function( backData )
	            	-- dump( backData, "backData" )
	            	if tonumber( backData.result ) == 0 then
						self._befNumLabel:setVisible(false)
	            		self:allSuccessCallback( data, backData, equipIcon, needIcons )
						XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_RECHARGE_HUOYUEJIANGLI})
	            	elseif tonumber( backData.result ) == 2000 then
		                XTHD.createExchangePop(3)
		            else
		                if backData.msg then
		                    XTHDTOAST( backData.msg )
		                else
		                    XTHDTOAST( LANGUAGE_TIPS_WEBERROR )----"网络请求失败!")
		                end
		            end
	            end,--成功回调
	            failedCallback = function()
	                XTHDTOAST( LANGUAGE_TIPS_WEBERROR )-----"网络请求失败")
	            end,--失败回调
	            targetNeedsToRetain = self,--需要保存引用的目标
	            loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
            })
		end)
	end
end
-- 洗练数据
function ZhuangBeiLayer:buildReforgeData( data )
	-- dump( data, "reforge data" )
	-- 计算时使用精确数据，显示的时候进行四舍五入
	-- 基础属性数据，加上进阶的属性数据，显示为洗练前属性
	local baseProperty = {}
	if data.baseProperty and #data.baseProperty > 0 then
		if data.phaseLevel == 0 or not data.phaseProperty or #data.phaseProperty == 0 then
			-- 未升星装备，对基础属性四舍五入
			for i, v in ipairs( string.split( data.baseProperty, "#" ) ) do
				local base = string.split( v, "," )
				base[2] = tonumber( base[2] )
				baseProperty[#baseProperty + 1] = base
			end
		else
			-- 已升星装备，基础属性加上强化属性，四舍五入
			local phase = {}
			for i, v in ipairs( string.split( data.phaseProperty, "#" ) ) do
				local tmpPhase = string.split( v, "," )
				phase[tmpPhase[1]] = tmpPhase[2]
			end
			for i, v in ipairs( string.split( data.baseProperty, "#" ) ) do
				local tmpBase = string.split( v, "," )
				local tmpData = {
					tmpBase[1],
					tonumber( tmpBase[2] ) + tonumber( phase[tmpBase[1]] or 0 ),
				}
				baseProperty[#baseProperty + 1] = tmpData
			end
		end
	end
	-- dump( baseProperty, "baseProperty" )
	-- 转换属性数据为显示的数据类型
	local function round( property, num )
	    property = tonumber( property )

	    if property >= 300 and property < 315 then
	    	local integer, decimal = math.modf( num )
	        if decimal == 0 then
	            return num.."%"
	        else
	            return string.format( "%.1f", num ).."%"
	        end
	    else
	        return math.floor( num*10 + 0.5 )*0.1
	    end
	end
	-- 到上限属性数量
	local topProperty = 0
	-- 属性数据
	local property = {}
	-- 是否已经洗练
	local reforgedFlag = false
	if data.plusTempProperty and #data.plusTempProperty > 0 then
		-- 已洗练
		reforgedFlag = true

		-- 解析plus属性，洗练后的装备属性数据
		local plusProperty = {}
		local phaseData = gameData.getDataFromCSV( "EquipAscendingStar", {stage = data.phaseLevel} )
		local rankData = gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = data.itemid} ).rank
		for i, v in ipairs( string.split( data.plusTempProperty, "#" ) ) do
			local plus = string.split( v, "," )
			if tonumber( plus[1] ) < 300 then
				-- 普通属性
				plusProperty[plus[1]] = tonumber( plus[2] ) + tonumber( plus[2] )*( phaseData and phaseData["percent"..rankData] or 0 )*0.01
			else
				-- 隐藏属性
				plusProperty[plus[1]] = tonumber( plus[2] )
			end
		end
		-- dump( plusProperty, 'plusProperty' )

		for i, v in ipairs( baseProperty ) do
			local maxProperty = XTHD.resource.getAttributesMax( data.itemid, v[1], data.strengLevel )
			if tonumber( v[1] ) < 300 then
				if phaseData then
					maxProperty = tonumber( maxProperty ) + tonumber( maxProperty )*( phaseData and phaseData["percent"..rankData] or 0 )*0.01
				end
			end

			local befAttr = math.floor( v[2]*10 + 0.5 )*0.1
			local aftAttr = math.floor( ( plusProperty[v[1]] or 0 )*10 + 0.5 )*0.1
			local arrow = 0
			if befAttr > aftAttr then
				arrow = 2
			elseif befAttr < aftAttr then
				arrow = 1
			end

			property[i] = {
		    	name = XTHD.resource.getAttributes( v[1] ),
		    	bef = round( v[1], v[2] ),
		    	aft = round( v[1], math.abs( aftAttr - befAttr ) ),
		    	arrow = arrow,
		    	max = round( v[1], maxProperty ),
			}

			-- 判断属性是否达到最大值
			if math.floor(v[2]) >= math.floor(maxProperty) then
				topProperty = topProperty + 1
			end
		end
	else
		-- 未洗练
		for i, v in ipairs( baseProperty ) do
			local maxProperty = XTHD.resource.getAttributesMax( data.itemid, v[1], data.strengLevel )
			if tonumber( v[1] ) < 300 then
				local phaseData = gameData.getDataFromCSV( "EquipAscendingStar", {stage = data.phaseLevel} )
				local rankData = gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = data.itemid} ).rank
				if phaseData then
					maxProperty = tonumber( maxProperty + maxProperty*( phaseData["percent"..rankData] or 0 )*0.01 )
				end
			end
			property[i] = {
		    	name = XTHD.resource.getAttributes( v[1] ),
		    	bef = round( v[1], v[2] ),
		    	max = round( v[1], maxProperty ),
			}

			if math.floor(v[2]) >= math.floor(maxProperty) then
				topProperty = topProperty + 1
			end
		end
	end
	-- dump( property, "property" )

	return property, reforgedFlag, topProperty
end
-- 合成
function ZhuangBeiLayer:createCompose( data )
	-- dump( data, "compose data" )

	-- 材料是否足够
    local moneyFlag = true
    -- local feicuiFlag = true
    local itemFlag = {}
    local notEnoughItemId = {}
    -- return nil
    -- 数量
    local curNum = 1
    local maxNum = 0
	--合成
	local equipIconBg = XTHD.createSprite( "res/image/plugin/compose/compose_itemBg.png" )
	equipIconBg:setAnchorPoint(0.5,0.5)
	equipIconBg:setPosition(self._rightSize.width*0.5 - 5, self._rightSize.height - 53)
	self._infoContainer:addChild( equipIconBg )
	equipIconBg:setScale( 0.8 )

	local equipIcon = ItemNode:createWithParams({
        itemId = data.itemid,
        _type_ = 4,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( self._rightSize.width*0.5 - 5, self._rightSize.height - 50 ),
    })
    equipIcon:setScale( 0.8 )
    self._infoContainer:addChild( equipIcon )
	-- 材料
	-- 数据
	local needIconData = {}
	local i = 1
	maxNum = math.floor( gameUser:getGold()/data.needgold )
	while data["num"..i] do
		itemFlag[#itemFlag + 1] = XTHD.resource.getItemNum( data["need"..i] ) >= data["num"..i]*curNum
		notEnoughItemId[#notEnoughItemId + 1] = data["need"..i]
		local times = math.floor( XTHD.resource.getItemNum( data["need"..i] )/data["num"..i]*curNum )
		maxNum = maxNum > times and times or maxNum
		needIconData[#needIconData + 1] = {
			itemId = data["need"..i],
	        count = XTHD.resource.getItemNum( data["need"..i] ).."/"..data["num"..i]*curNum,
	        _type_ = 4,
	        fnt_type = itemFlag[#itemFlag] and 1 or 2,
		}
		i = i + 1
	end
	-- icon
	local needIconPos = SortPos:sortFromMiddle( cc.p( self._rightSize.width/2 -5, self._rightSize.height - 160) , #needIconData , 81+15 )
	local needIcons = {}
	for i, v in ipairs( needIconData ) do
		local needIconBg = XTHD.createSprite()
		needIconBg:setPosition( needIconPos[i] )
    	self._infoContainer:addChild( needIconBg )
    	v.touchShowTip = false
		needIcons[i] = ItemNode:createWithParams( v )
		local needBtn = XTHD.createButton({
			normalNode = needIcons[i],
			touchSize = needIcons[i]:getContentSize(),
		})
		needBtn:setScale( 0.8 )
		getCompositeNodeWithNode( needIconBg, needBtn )
		needBtn:setTouchEndedCallback( function()
			-- local popLayer = requires("src/fsgl/layer/common/ItemDropPopLayer1.lua")
	  --       popLayer= popLayer:create( tonumber( v.itemId ) )
	  --       self:addChild( popLayer, 3 )
		end)
	end
	-- 分隔线
	local split = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitX.png" )
	split:setContentSize(401,2)
    split:setPosition( self._rightSize.width/2, self._rightSize.height -210 )    
    self._infoContainer:addChild( split )
    -- 当前最多可制作
    local maxComposeText = XTHD.createLabel({
    	text = LANGUAGE_EQUIP_TEXT[19],
    	fontSize = 18,
    	color = cc.c3b(0,0,0),
    	anchor = cc.p( 1, 0.5 ),
    	pos = cc.p( self._rightSize.width/2 + 60, self._rightSize.height - 230 ),
	})
	-- maxComposeText:enableShadow(XTHD.resource.textColor.white_text,cc.size(0.4,-0.4),0.4)
	self._infoContainer:addChild( maxComposeText )
	-- 当前最多可制作数字
	local maxComposeNum = getCommonWhiteBMFontLabel( maxNum )
	maxComposeNum:setAnchorPoint( 0, 0.5 )
	maxComposeNum:setPosition( maxComposeText:getPositionX(), maxComposeText:getPositionY() - 7 )
	self._infoContainer:addChild( maxComposeNum )
	-- 数量:
	local numText = XTHD.createLabel({
		text = LANGUAGE_NAMES.number..":",
		fontSize = 18,
		color = cc.c3b(45,13,103),
		anchor = cc.p( 1, 0.5 ),
		pos = cc.p( self._rightSize.width/2 - 125, self._rightSize.height - 270 ),
		ttf = "res/fonts/def.ttf",
	})
	-- numText:enableOutline(cc.c4b(45,13,103,255),1)
	numText:enableShadow( XTHD.resource.textColor.gray_text, cc.size( 0.4, -0.4 ), 0.4 )
	self._infoContainer:addChild( numText )
	--减号
	local reduceBtn = XTHD.createButton({
		normalFile = "res/image/common/btn/btn_reduceDot_normal.png",
		selectedFile = "res/image/common/btn/btn_reduceDot_selected.png",
        touchSize = cc.size( 80, 80 ),
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( self._rightSize.width/2 - 95, numText:getPositionY() ),
	})
	reduceBtn:setScale( 0.8 )
	self._infoContainer:addChild( reduceBtn )
	-- 当前数量背景
	local curComposeNumBg = ccui.Scale9Sprite:create( "res/image/friends/input_bg.png" )
	curComposeNumBg:setContentSize(120,39)
	curComposeNumBg:setAnchorPoint(cc.p(0.5,0.5))
	curComposeNumBg:setPosition( self._rightSize.width/2 - 7, numText:getPositionY() )
	self._infoContainer:addChild( curComposeNumBg )
	-- 当前数量
	local curComposeNum = XTHD.createLabel({
		text = curNum,
		fontSize = 18,
		color = XTHD.resource.textColor.white_text,
		anchor = cc.p( 0.5, 0.5 ),
		pos = cc.p( self._rightSize.width/2 - 118, self._rightSize.height - 270 ),
	})
	curComposeNum:enableShadow( XTHD.resource.textColor.white_text, cc.size( 0.4, -0.4 ), 0.4 )
	getCompositeNodeWithNode( curComposeNumBg, curComposeNum )
	-- 加号
	local addBtn = XTHD.createButton({
		normalFile = "res/image/common/btn/btn_addDot_normal.png",
		selectedFile = "res/image/common/btn/btn_addDot_selected.png",
        touchSize = cc.size( 80, 80 ),
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( self._rightSize.width/2 + 80, numText:getPositionY() ),
	})
	addBtn:setScale( 0.8 )
	self._infoContainer:addChild( addBtn )
	-- max
	local maxBtn = XTHD.createMaxBtn()
	maxBtn:setPosition( self._rightSize.width/2 + 135, numText:getPositionY() )
	self._infoContainer:addChild( maxBtn )
	-- 消耗银两
	local consumeGoldText = XTHD.createLabel({
		text = LANGUAGE_KEY_ONLY_COST,
		fontSize = 16,
		color = XTHD.resource.textColor.gray_text,
		anchor = cc.p( 1, 0.5 ),
		pos = cc.p( self._rightSize.width/2 - 130, self._rightSize.height - 310 ),	
	})
	self._infoContainer:addChild( consumeGoldText )
	-- 银两图标
	local consumeGoldIcon = XTHD.createSprite( "res/image/common/header_gold.png" )
	consumeGoldIcon:setPosition( self._rightSize.width/2 - 105, consumeGoldText:getPositionY() )
	self._infoContainer:addChild( consumeGoldIcon )
	-- 消耗银两数量
	local consumeGoldNum = XTHD.createLabel({
		text = getHugeNumberWithLongNumber( data.needgold*curNum, 1000000 ),
		fontSize = 18,
		color = gameUser:getGold() >= data.needgold*curNum and XTHD.resource.color.gray_desc or XTHD.resource.color.red_desc,
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( self._rightSize.width/2 - 85, consumeGoldText:getPositionY() ),
	})
	self._infoContainer:addChild( consumeGoldNum )
	-- 成功率
	local successText = XTHD.createLabel({
		text = LANGUAGE_KEY_SUCCESSRATE..":",
		fontSize = 16,
		color = XTHD.resource.textColor.gray_text,
		anchor = cc.p( 1, 0.5 ),
		pos = cc.p( self._rightSize.width/2 + 110, consumeGoldText:getPositionY() ),	
	})
	self._infoContainer:addChild( successText )
	-- 成功率数字
	local successNum = XTHD.createLabel({
		text = data.probability.."%",
		fontSize = 16,
		color = XTHD.resource.textColor.green_text,
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( self._rightSize.width/2 + 110, consumeGoldText:getPositionY() ),	
	})
	self._infoContainer:addChild( successNum )
	-- 开始制作
	local composeBtn = XTHD.createCommonButton({
        btnColor = "write_1",
		btnSize = cc.size( 145, 46 ),
		isScrollView = false,
        text = LANGUAGE_BTN_KEY.startMake,
        fontSize = 20,
        pos = cc.p( self._rightSize.width/2-7, 40 ),
	})
	composeBtn:setScale(0.9)
	-- composeBtn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
	self._infoContainer:addChild( composeBtn )
	--回调
	--reduceBtn
	reduceBtn:setTouchEndedCallback(function()
    	if curNum <= 1 then
    		XTHDTOAST( LANGUAGE_TIPS_WORDS102 )
    	else
    		curNum = curNum - 1
    		curComposeNum:setString( curNum )
    		consumeGoldNum:setString( getHugeNumberWithLongNumber( data.needgold*curNum, 1000000 ) )
    		consumeGoldNum:setColor( gameUser:getGold() >= data.needgold*curNum and XTHD.resource.color.gray_desc or XTHD.resource.color.red_desc )
    	end
	end)
	-- addBtn
	addBtn:setTouchEndedCallback(function()
    	if curNum >= 999 then
    		XTHDTOAST( LANGUAGE_TIPS_WORDS101 )
    	elseif curNum >= maxNum then
    		XTHDTOAST( LANGUAGE_KEY_HERO_TEXT.cannotMakeResonTextXc[3] )
    	else
    		curNum = curNum + 1
    		curComposeNum:setString( curNum )
    		consumeGoldNum:setString( getHugeNumberWithLongNumber( data.needgold*curNum, 1000000 ) )
    		consumeGoldNum:setColor( gameUser:getGold() >= data.needgold*curNum and XTHD.resource.color.gray_desc or XTHD.resource.color.red_desc )
    	end
	end)
	-- maxBtn
	maxBtn:setTouchEndedCallback(function()
		curNum = maxNum
		curComposeNum:setString( curNum )
		consumeGoldNum:setString( getHugeNumberWithLongNumber( data.needgold*curNum, 1000000 ) )
		consumeGoldNum:setColor( gameUser:getGold() >= data.needgold*curNum and XTHD.resource.color.gray_desc or XTHD.resource.color.red_desc )
	end)
	-- composeBtn
	composeBtn:setTouchEndedCallback(function()
		YinDaoMarg:getInstance():guideTouchEnd()
		
		if curNum > maxNum then
			-- 材料不足
			XTHDTOAST( LANGUAGE_KEY_HERO_TEXT.cannotMakeResonTextXc[3] )
		elseif curNum > 0 then
			local _lightPosArr = {}
			for i, v in ipairs( needIcons ) do
				local _pos = v:convertToWorldSpace( cc.p( v:getBoundingBox().width/2, v:getBoundingBox().height/2 ) )
				_lightPosArr[#_lightPosArr + 1] = _pos
			end
			ClientHttp:requestAsyncInGameWithParams({
		    	modules = "composeItem?",
		        params = {configId = data.id,count = curNum},
		        successCallback = function(backData)
		            if tonumber(backData.result) == 0 or tonumber(backData.result) == 3009 then
		                backData.allCount = curNum
		            	gameUser.setFeicui( backData.feicui )
		            	gameUser.setGold( backData.gold )

		            	local _resultlayer = requires("src/fsgl/layer/TieJiangPu/TieJiangPuResultPopLayer.lua"):create(_lightPosArr)
    					self:addChild(_resultlayer,3)
		                _resultlayer:showItemResult(backData,function(resultData)
		                        XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})

		                        --数据库刷新
		                        --修改消耗品的数量，为0删除
		                        for i=1,#resultData["items"] do
		                            local _dbid = resultData.items[i].dbId
		                            if resultData.items[i].count and tonumber(resultData.items[i].count)>0 then
		                                DBTableItem.updateCount(gameUser.getUserId(),resultData.items[i],_dbid)
		                            else
		                                DBTableItem.deleteData(gameUser.getUserId(),_dbid)
		                            end
		                        end
		                        --插入数据
		                        -- local _newItemsTable = {}
		                        for i=1,#resultData["newItems"] do
		                            local _dbid = resultData["newItems"][i].dbId
		                            if resultData["newItems"][i].item_type and tonumber(resultData["newItems"][i].item_type)==3 then
		                                resultData.newItems[i].addCount = tonumber(resultData.newItems[i].count or 0)
		                            else
		                                local _itemData = self.dynamicItemData[tostring(resultData.newItems[i].itemId)] or {}
		                                local _oldNumber = _itemData.count and tonumber(_itemData.count) or 0
		                                local _addCount = tonumber(resultData.newItems[i].count) - tonumber(_oldNumber)
		                                _addCount = _addCount>=0 and _addCount or 0
		                                resultData.newItems[i].addCount = _addCount
		                            end
		                            if i>1 then
		                                local _itemData = resultData.newItems[1]
		                                if tonumber(_itemData.itemId) == tonumber(resultData.newItems[i].itemId) then
		                                    _itemData.addCount = _itemData.addCount + resultData.newItems[i].addCount
		                                end
		                            end
		                            gameData.getDataFromCSVWithPrimaryKey("EquipInfoList",{itemid=resultData["newItems"][i].itemId})
		                            DBTableItem.updateCount(gameUser.getUserId(),resultData["newItems"][i],_dbid)
		                        end
		                        -- self._createNumLabel:setString(1)
		                        performWithDelay(self,function()
		                                -- 刷新当前界面
		                                self:buildItemData()
									    self:refreshEquip( true, true )
		                            end, 0.2)
		                        return resultData
		                    end)
		            else
		            	XTHDTOAST(backData.msg or LANGUAGE_TIPS_WEBERROR)------ "网络请求失败") 
		            end
		        end,--成功回调
		        failedCallback = function()
		            _resultlayer:removeFromParent()
		            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
		        end,--失败回调
		        loadingType = HTTP_LOADING_TYPE.NONE,--加载图显示 circle 光圈加载 head 头像加载
		    })
		end
	end)
	-------添加开始制作引导 
	if composeBtn then
		YinDaoMarg:getInstance():addGuide({
	        parent = self,
	        target = composeBtn,----开始制作 
	        index = 5,
	    },6)
    	YinDaoMarg:getInstance():doNextGuide()
	end 
	
end
-- 返回处理
function ZhuangBeiLayer:allSuccessCallback( data, backData, equipIcon, needIcons, fullScreen )
	local oriBaseProperty = data.baseProperty
	local oriPhaseProperty = data.phaseProperty
	if not backData or not backData then
		return
	end
	-- 刷新装备属性
    if backData.itemProperty and backData.itemProperty.property and backData.itemProperty.property.baseProperty then
        local propertyData = {
            baseProperty = backData.itemProperty.property.baseProperty,
            phaseProperty = backData.itemProperty.property.phaseProperty,
            phaseLevel = backData.itemProperty.property.phaseLevel,
            strengLevel = backData.itemProperty.property.strengLevel,
            plusTempProperty = backData.itemProperty.property.plusTempProperty,
            power = backData.itemProperty.power,
        }
        if self._heroId == 0 then
        	-- 未穿戴，修改DBTableItem里的数据
            DBTableItem.updateMultiData( gameUser.getUserId(), data.dbid, propertyData )
        else
        	-- 已穿戴，修改DBTableItem里的数据
            DBTableEquipment.updateMultiData( gameUser.getUserId(), data.dbid, propertyData )
        end
        -- 修改当前界面的数据
        local index = 0
        for i, v in ipairs( self._allEquipData[tostring( self._heroId )] ) do
        	if self._equipDbid == v.dbid then
        		index = i
        	end
        end
        -- dump( self._allEquipData[tostring( self._heroId )][index], "allEquipData" )
        if self._allEquipData[tostring( self._heroId )][index] then
	        for k, v in pairs( propertyData ) do
	        	self._allEquipData[tostring( self._heroId )][index][k] = v
	        end
	    end
    end
    -- 刷新背包
    if backData.items then
    	XTHD.saveItem( {items = backData.items} )
    end
    if backData.bagItems then
    	XTHD.saveItem( {items = backData.bagItems} )
    end
    -- 刷新英雄属性
    if #backData.property ~= 0 then
        DBTableHero.multiUpdate( gameUser.getUserId(), self._heroId, backData.property )
    end
    -- 刷新银两
    if backData.gold then
    	gameUser.setGold( backData.gold )
    end
    -- 刷新元宝
    if backData.ingot then
		gameUser.setIngot( backData.ingot )
	end
    XTHD.dispatchEvent( {name = CUSTOM_EVENT.REFRESH_TOP_INFO} )
	-- 动画
    local propertyChange = {}
    if backData.itemProperty and backData.itemProperty.property and backData.itemProperty.property.baseProperty then
        propertyChange = {
            oriBaseProperty,
            oriPhaseProperty,
            backData.itemProperty.property.baseProperty,
            backData.itemProperty.property.phaseProperty,
        }
    end
    self:createSpine( equipIcon, needIcons, propertyChange, fullScreen )
    -- 刷新当前界面
	self._equipDbid = self._equipData[self._equipIndex].dbid
    if self._heroId == 0 then
		self:refreshEquip( true )
	else
		self:refreshEquip()
	end
	-- 刷新英雄界面
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_HERODATABYID, data = {heroid = self._heroId or 0}})

	self._touchLayer:setEnable( false )
end
-- 动画
function ZhuangBeiLayer:createSpine( equip, icons, propertys, fullScreen )
	if not self._exist then
		return
	end
	-- 装备icon动画
	if equip then
		local spineName = {
			"qianghua",
			"jinjie",
			"xilian",
		}
		local equip_spine = sp.SkeletonAnimation:create( "res/spine/effect/equip/zhuangbei.json", "res/spine/effect/equip/zhuangbei.atlas", 1.0 )
	    equip_spine:setPosition( equip:convertToWorldSpace( cc.p( equip:getContentSize().width*0.5, equip:getContentSize().height*0.5 ) ) )
	    equip_spine:setAnimation( 0, spineName[self._tabIndex], false )
	    self:addChild( equip_spine, 4 )
	    performWithDelay( equip_spine, function()
	        equip_spine:removeFromParent()
	    end, 1 )
	end
	-- 消耗icons动画
	if icons and #icons > 0 then
		for i, v in ipairs( icons ) do
			local icons_spine = sp.SkeletonAnimation:create( "res/spine/effect/equip/zhuangbei.json", "res/spine/effect/equip/zhuangbei.atlas", 1.0 )
		    icons_spine:setPosition( v:convertToWorldSpace( cc.p( v:getContentSize().width*0.5, v:getContentSize().height*0.5 ) ) )
		    icons_spine:setAnimation( 0, "xiaohao", false )
		    self:addChild( icons_spine, 4 )
		    performWithDelay( icons_spine, function()
		        icons_spine:removeFromParent()
		    end, 0.5333 )
		end
	end
	-- 属性变化动画
	-- dump( propertys, "property" )
	if propertys and #propertys == 4 then
		local oldBase = {}
		for i, v in ipairs( string.split( propertys[1], "#" ) ) do
			local tmp = string.split( v, "," )
			oldBase[tmp[1]] = tmp[2]
		end
		local oldPhase = {}
		for i, v in ipairs( string.split( propertys[2], "#" ) ) do
			local tmp = string.split( v, "," )
			oldPhase[tmp[1]] = tmp[2]
		end
		local newBase = {}
		for i, v in ipairs( string.split( propertys[3], "#" ) ) do
			local tmp = string.split( v, "," )
			newBase[tmp[1]] = tmp[2]
		end
		local newPhase = {}
		for i, v in ipairs( string.split( propertys[4], "#" ) ) do
			local tmp = string.split( v, "," )
			newPhase[tmp[1]] = tmp[2]
		end
	    
	    local toastList = {}
	    for k, v in pairs( newBase ) do
	    	local propertyName = XTHD.resource.getAttributes( k )
	    	local oldNum = tonumber( oldBase[k] or 0 ) + tonumber( oldPhase[k] or 0 )
	    	local newNum = tonumber( newBase[k] or 0 ) + tonumber( newPhase[k] or 0 )
	    	local changeNum = math.floor( newNum*10 + 0.5 )*0.1 - math.floor( oldNum*10 + 0.5 )*0.1
	    	-- print(newNum,oldNum,changeNum)
	    	toastList[#toastList + 1] = {
	    		weight = tonumber( k ),
	    		num = math.floor( changeNum*10 + 0.5 )*0.1,
	    		attr = propertyName,
	    		propertyKey = ( tonumber( k ) >= 300 and tonumber( k ) < 315 ) and k or nil,
	    	}
	    end
	    table.sort( toastList, function( a, b )
	    	return a.weight < b.weight
    	end)
    	-- dump( toastList, "toastList" )
    	local toastX = 0
    	local toastY = 0
    	if fullScreen then
    		toastX = self._size.width*0.5
    		toastY = self._size.height*0.5
    	else
    		toastX = self._infoContainer:getPositionX() + self._rightContainer:getPositionX()
    		toastY = self._infoContainer:getPositionY() + self._rightContainer:getPositionY()
    	end
	    XTHD.createAttrToastByTable( toastList, cc.p( toastX, toastY ) )
	end
end
-- 强化动画
function ZhuangBeiLayer:createStrengthAnimation( equipIcon, needIcons )
	local dstPos = self._infoContainer:convertToNodeSpace( cc.p( equipIcon:convertToWorldSpace( cc.p( equipIcon:getContentSize().width*0.5, equipIcon:getContentSize().height*0.5 ) ) ) )
	local dstX = dstPos.x
	local dstY = dstPos.y
	if needIcons and #needIcons > 0 then
		for i, v in ipairs( needIcons ) do
			v:removeChildByTag( 233 )
			local _data = {
		        file = "res/image/plugin/equip_layer/zbqh",
		        name = "zbqh",
		        startIndex = 1,
		        endIndex = 11,
		        perUnit = 0.04,
		        isCircle = false,
		    }
			local animation = XTHD.createSpriteFrameSp( _data )
			animation:setTag( 233 )
			-- 计算坐标角度
			local oriPos = self._infoContainer:convertToNodeSpace( cc.p( v:convertToWorldSpace( cc.p( 0, 0 ) ) ) )
			local oriX = oriPos.x
			local oriY = oriPos.y

			local radian = math.atan( ( dstY - oriY )/( dstX - oriX ) )
			local degree = math.deg( radian )
			if degree > 0 then
				degree = 90 - degree
			else
				degree = - 90 - degree
			end

			animation:setPosition( v:getContentSize().width*0.5, -v:getContentSize().height - 30 )
			animation:setScale( v:getContentSize().width/42/0.7 )
			v:addChild( animation )
			v:runAction(
				cc.Spawn:create(
					cc.RotateTo:create(
						0.1, degree
					),
					cc.MoveTo:create(
						0.44, v:getParent():convertToNodeSpace( cc.p( equipIcon:convertToWorldSpace( cc.p( equipIcon:getContentSize().width*0.5, equipIcon:getContentSize().height*0.5 + 10 ) ) ) )
					)
				)
			)
		end
	end
end

-- 判断装备是否显示可强化可升星
function ZhuangBeiLayer:judgeEquipRedDot( data )
	if self._tabIndex == 1 then
		-- 判断强化
		if data.strengLevel < gameUser.getLevel() then
			local strengthData = gameData.getDataFromCSV( "EquipUpList", {itemlevel = data.strengLevel + 1} )
			local rankData = gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = data.itemid} ).rank
			-- 钱
			if gameUser.getGold() >= strengthData["consume"..rankData] then
				-- 材料
				if strengthData.need and XTHD.resource.getItemNum( strengthData.need ) >= strengthData["num"..rankData] then
					return true
				end
			end
		end
	elseif self._tabIndex == 2 then
		-- 判断升星
		local maxStars = gameData.getDataFromCSV( "EquipInfoList", {itemid = data.itemid}).advancetopvalue
		if maxStars > data.phaseLevel then
			-- 没进阶到满星
			local starupData = gameData.getDataFromCSV( "EquipAscendingStar", {stage = data.phaseLevel + 1} )
			local rankData = gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = data.itemid} ).rank
			-- 钱
			if gameUser.getGold() >= starupData.goldprice*XTHD.resource.advanceGoldCoefficient[rankData] then
				-- 材料
				local i = 1
				local numTable = string.split( starupData["num"..rankData], "#" )
				local csmTable = string.split( starupData["consumables"..rankData], "#" )
				while numTable[i] do
					if XTHD.resource.getItemNum( csmTable[i] ) < tonumber( numTable[i] ) then
						return false
					end
					i = i + 1
				end
				return true
			end
		end
	elseif self._tabIndex == 3 then
		-- 判断是否可以洗练
	end
	return false
end
-- 判断装备显示可合成
function ZhuangBeiLayer:jedgeComposeRedDot( data )
	if gameUser:getLevel() < data.needlv then
		-- 等级不足
		return 1
	elseif tonumber( data.needgold or 0 ) > gameUser:getGold() and tonumber( data.needfc or 0 ) > gameUser.getFeicui() then
		-- 银两翡翠不足
		return 2
	else
		-- 材料不足
		local i = 1
		local itemFlag = true
		while data["num"..i] do
			if XTHD.resource.getItemNum( data["need"..i] ) < tonumber( data["num"..i] ) then
				itemFlag = false
				break
			end
			i = i + 1
		end
		if itemFlag then
			return 3
		else
			return 2
		end
	end
end
-- 刷新红点
function ZhuangBeiLayer:refreshRedDot()
	-- 强化升星洗练，洗练目前没有红点
	local myMoney = gameUser.getGold()
	local myLevel = gameUser.getLevel()
	local unlockStarup = XTHD.getUnlockStatus( 50, false )

	local strengthFlag = false		--强化标志
	local starupFlag = false		--升星标志
	local reforgeFlag = false		--洗练标志

	for i, v in ipairs( self._allEquipData[tostring( self._heroId )] ) do
		local rankData = gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = v.itemid} ).rank
		-- 强化
		if not strengthFlag then
			if v.strengLevel < myLevel then
				local strengthData = gameData.getDataFromCSV( "EquipUpList", {itemlevel = v.strengLevel + 1} )
				-- 钱
				if myMoney >= strengthData["consume"..rankData] then
					-- 材料
					if strengthData.need and XTHD.resource.getItemNum( strengthData.need ) >= strengthData["num"..rankData] then
						strengthFlag = true
						-- print("strength  ",v.itemid)
					end
				end
			end
		end
		-- 升星
		if unlockStarup and not starupFlag and v.quality > 2 then
			local maxStars = gameData.getDataFromCSV( "EquipInfoList", {itemid = v.itemid}).advancetopvalue
			if maxStars > v.phaseLevel then
				-- 没进阶到满星
				local starupData = gameData.getDataFromCSV( "EquipAscendingStar", {stage = v.phaseLevel + 1} )
				-- 钱
				if myMoney >= starupData.goldprice*XTHD.resource.advanceGoldCoefficient[rankData] then
					-- 材料
					local tmp = 1
					local numTable = string.split( starupData["num"..rankData], "#" )
					local csmTable = string.split( starupData["consumables"..rankData], "#" )
					local itemFlag = true
					while numTable[tmp] do
						if XTHD.resource.getItemNum( csmTable[tmp] ) < tonumber( numTable[tmp] ) then
							itemFlag = false
							break
						end
						tmp = tmp + 1
					end
					if itemFlag then
						starupFlag = true
						break
					end
				end
			end
		end

		if strengthFlag and ( ( unlockStarup and starupFlag ) or not unlockStarup ) then
			break
		end
	end
	
	--洗练红点
	for i, v in pairs(self._equipData) do
		print("----------------------------------------------")
		local rankData = gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = v.itemid} ).rank
		-- 如果当前没有可洗练则一直继续寻找直到结束
		if not reforgeFlag then
			-- 洗练
			local property, _reforgedFlag, topProperty = self:buildReforgeData(v)
			-- for k,value in pairs(v) do
			-- 	print("k: "..k.. " value:"..value)
			-- end

			local reforgeData = gameData.getDataFromCSV( "EquipSmeltingList", {quality = rankData} )
			local moneyFlag = gameUser.getGold() >= reforgeData.basegold * (topProperty + 1)
			local ingotFlag = gameUser.getIngot() >= reforgeData.baseingot * (#property - topProperty)
			--必然材料
			local itemFlag1 = XTHD.resource.getItemNum( reforgeData.needitem ) >= reforgeData.neednum * ( #property - topProperty )
			--随机材料
			local itemFlag2 = XTHD.resource.getItemNum( reforgeData.needitem ) >= reforgeData.neednum*( topProperty + 1 )
			
			--print("moneyFlag: "..tostring(moneyFlag).." ingotFlag: "..tostring(ingotFlag).." itemFlag1: "..tostring(itemFlag1).." itemFlag2: "..tostring(itemFlag2).."  topProperty: "..topProperty.. "#property: "..#property)
			if ingotFlag and itemFlag1 and topProperty < #property then
				reforgeFlag = true
			elseif moneyFlag and itemFlag2 and topProperty < #property then
				reforgeFlag = true
			end
		end
	end

	self._tabsTable[1]:getChildByName( "redDot" ):setVisible( strengthFlag )
	self._tabsTable[2]:getChildByName( "redDot" ):setVisible( starupFlag )
	self._tabsTable[3]:getChildByName( "redDot" ):setVisible( false )  --reforgeFlag

	-- 合成红点
	local composeFlag = RedPointManage:getEquipComposeRedPointState()
	self._tabsTable[4]:getChildByName( "redDot" ):setVisible( composeFlag )

	--刷新主城红点

end
-- 刷新装备信息
function ZhuangBeiLayer:refreshInfo()
	local data = self._equipData[self._equipIndex]
	if not data then
		-- 没有装备
		local tipText = {
			"",
			LANGUAGE_EQUIP_TEXT[16],
			LANGUAGE_EQUIP_TEXT[17],
		}
		self._leftContainer:setVisible( false )
		self._rightContainer:setVisible( false )
		self._noEquipTip:setString( tipText[self._tabIndex] )
		self._noEquip:setVisible( true )
	else
		-- 有装备
		self._leftContainer:setVisible( true )
		self._rightContainer:setVisible( true )
		self._noEquip:setVisible( false )
		-- 移除非公用组件
		self._infoContainer:removeAllChildren()
		-- 创建新组件
		if self._tabIndex == 1 then
			self:createStrength( data )
		elseif self._tabIndex == 2 then
			self:createStarup( data )
		elseif self._tabIndex == 3 then
			self:createReforge( data )
		elseif self._tabIndex == 4 then
			self:createCompose( data )
		end
	end
end
-- 刷新装备列表
-- scrollFlag表示是否需要滑动到当前位置，已穿戴装备在强化升星洗练返回时需要滑动到当前位置
function ZhuangBeiLayer:refreshEquip( scrollFlag, composeFlag )
	if not self._exist then
		return
	end
	-- 刷新装备列表数据
	self:buildEquipData( composeFlag )

	-- 是否需要滑动到当前位置
	if scrollFlag or composeFlag then
		-- 其他需要重新排序
		self._equipTableView:reloadData()
		self._equipTableView:scrollToCell( self._equipIndex - 1, false )
	else
		-- 已穿戴装备强化升星洗练回调不需要重新排序
		self._equipTableView:reloadDataAndScrollToCurrentCell()
	end
	-- 刷新红点
	self:refreshRedDot()
	self:refreshInfo()
end
-- 获取装备数据
function ZhuangBeiLayer:buildEquipData( composeFlag )
	if self._tabIndex == 1 or self._tabIndex == 2 or self._tabIndex == 3 then
		self._equipData = {}
		if #self._heroData > 0 then
			-- 有英雄穿装备
			local equipData = {}
			if tonumber( self._heroId ) == 0 then
				-- 未穿戴装备
				equipData = self._allEquipData["0"] or {}
				-- dump(equipData, "equipData")
				-- quality > 2的装备可以进阶，洗练
				if self._tabIndex == 2 or self._tabIndex == 3 then
					for i, v in ipairs( equipData ) do
						if v.quality > 2 then
							self._equipData[#self._equipData + 1] = v
						end
					end
				else
					self._equipData = equipData
				end
				-- 按品质、穿戴位置、战力排序
				table.sort( self._equipData, function( a, b )
					if a.quality ~= b.quality then
						return a.quality > b.quality
					elseif ( a.equipment and a.equipment.equippos or 1 ) ~= ( b.equipment and b.equipment.equippos or 1 ) then
						return ( a.equipment and a.equipment.equippos or 1 ) < ( b.equipment and b.equipment.equippos or 1 )
					else
						return a.power > b.power
					end
				end)
			else
				-- 已穿戴装备
				equipData = self._allEquipData[tostring( self._heroId )] or {}
				-- dump(equipData, "equipData")
				-- quality > 2的装备可以进阶，洗练
				if self._tabIndex == 2 or self._tabIndex == 3 then
					for i, v in ipairs( equipData ) do
						if v.quality > 2 then
							self._equipData[#self._equipData + 1] = v
						end
					end
				else
					self._equipData = equipData
				end
				-- 按穿戴位置排序
				table.sort( self._equipData, function( a, b )
					return a.bagindex < b.bagindex
				end)
			end
			-- dump( self._equipData, "self._equipData" )
			self._equipIndex = 1
			-- 查找之前的装备dbid
			if self._equipDbid and tonumber( self._equipDbid ) ~= 0 then
				-- 之前选中装备
				for i, v in ipairs( self._equipData ) do
					if v.dbid == self._equipDbid then
						self._equipIndex = i
						break
					end
				end
			else
				-- 之前没有选装备
				self._equipDbid = self._equipData[self._equipIndex] and self._equipData[self._equipIndex].dbid
			end
		end
	elseif self._tabIndex == 4 then
		local composeId = 0
		if composeFlag then
			if self._equipData[self._equipIndex] then
				composeId = self._equipData[self._equipIndex].id or 0
			end
		end
		self._equipData = self._equipComposeData
		local sortTable = {}
		sortTable[1] = {}
		sortTable[2] = {}
		sortTable[3] = {}
		for i, v in ipairs( self._equipData ) do
			v.prompt = self:jedgeComposeRedDot( v )
			sortTable[v.prompt][#sortTable[v.prompt] + 1] = v
		end
		-- 等级不足
		table.sort( sortTable[1], function( a, b )
			return a.id < b.id
		end)
		-- 材料不足
		table.sort( sortTable[2], function( a, b )
			if a.rank ~= b.rank then
				return a.rank > b.rank
			else
				return a.id < b.id
			end
		end)
		-- 可合成
		table.sort( sortTable[3], function( a, b )
			if a.rank ~= b.rank then
				return a.rank > b.rank
			else
				return a.id < b.id
			end
		end)
		-- 合并
		self._equipData = {}
		for i = 3, 1, -1 do
			for j, u in ipairs( sortTable[i] ) do
				self._equipData[#self._equipData + 1] = u
			end
		end
		self._equipIndex = 1
		if composeId ~= 0 then
			for i, v in ipairs( self._equipData ) do
				if composeId == v.id and 3 == v.prompt then
					self._equipIndex = i
					break
				end
			end
		end
	end
end
-- 刷新英雄列表
function ZhuangBeiLayer:refreshHero()
	if not self._exist then
		return
	end

	-- 英雄列表数据
	self:buildHeroData()
	-- dump( self._heroData, "self._heroData" )
	
	self._heroIconTableView:reloadData()
	self._heroIconTableView:scrollToCell( self._heroIndex - 1, true )

	self:refreshEquip( true )
end
-- 获取英雄数据，选中英雄id和下标
function ZhuangBeiLayer:buildHeroData()
	self._heroData = {}
	self._allEquipData = {}

	-- 装备数据
	local equipList = DBTableEquipment.getData( gameUser.getUserId() )
	if table.nums( equipList ) > 0 and not equipList[1] then
		equipList = { equipList }
	end
	-- 英雄数据
	local heroList = DBTableHero.getData(gameUser.getUserId())
	if table.nums( heroList ) > 0 and not heroList[1] then
		heroList = { heroList }
	end
	-- 未穿戴装备数据
	local itemList = DBTableItem.getData( gameUser.getUserId(), {item_type = 3} )
	if table.nums( itemList ) > 0 and not itemList[1] then
		itemList = { itemList }
	end

	-- 装备数据处理
	for i, v in ipairs( equipList ) do
		self._allEquipData[tostring(v.heroid)] = self._allEquipData[tostring(v.heroid)] or {}
		table.insert( self._allEquipData[tostring(v.heroid)], v )
	end
	-- 英雄数据处理
	for i, v in ipairs( heroList ) do
		if self._allEquipData[tostring( v.heroid )] then
			self._heroData[#self._heroData + 1] = {
				advance = v.advance,
				heroid = v.heroid,
				level = v.level,
				star = v.star,
				power = v.power,
			}
		end
	end
	table.sort( self._heroData, function( a, b )
		if a.power == b.power then
			return a.heroid < b.heroid
		else
			return a.power > b.power
		end
	end)
	-- 未穿戴装备数据处理
	-- dump(itemList, "itemList")
	if #itemList > 0 then
		self._allEquipData["0"] = itemList
		self._heroData[#self._heroData + 1] = {
			advance = 1,
			heroid = 0,
			level = -1,
			star = 0,
			power = 0,
		}
	end
	-- dump( self._heroData, "self._heroData" )
	-- dump( self._allEquipData, "self._allEquipData" )

	self._heroIndex = 1
	-- 查找之前的英雄id
	if self._heroId and tonumber( self._heroId ) ~= 0 then
		-- 之前选中英雄
		for i, v in ipairs( self._heroData ) do
			if v.heroid == self._heroId then
				self._heroIndex = i
				break
			end
		end
	else
		-- 之前没有选英雄
		self._heroId = self._heroData[self._heroIndex] and self._heroData[self._heroIndex].heroid
	end
end
-- 刷新未穿戴装备
function ZhuangBeiLayer:buildItemData()
	-- 未穿戴装备数据
	local itemList = DBTableItem.getData( gameUser.getUserId(), {item_type = 3} )
	if table.nums( itemList ) > 0 and not itemList[1] then
		itemList = { itemList }
	end
	self._allEquipData["0"] = itemList
end
-- 构造装备合成数据，单独提出来供刷新使用
function ZhuangBeiLayer:buildComposeData()
	local composeList = gameData.getDataFromCSV("SmithyMakingList",{itemtype = 0})
	local myLevel = gameUser:getLevel()
	local showLevel = myLevel
	local showFlag = true
	for i, v in ipairs( composeList ) do
		if v.needlv > myLevel then
			if showFlag then
				showLevel = v.needlv
				showFlag = false
			elseif v.needlv < showLevel then
				showLevel = v.needlv
			end
		end
	end
	self._equipComposeData = {}
	for i, v in ipairs( composeList ) do
		if v.needlv <= showLevel then
			v.rank = gameData.getDataFromCSV("ArticleInfoSheet",{itemid = v.itemid}).rank or 1
			self._equipComposeData[#self._equipComposeData + 1] = v
		end
	end
	-- dump( self._equipComposeData, "self._equipComposeData" )
	-- print("装备合成数据：")
	-- print_r(self._equipComposeData)
end

function ZhuangBeiLayer:create( heroId, dbid, type, callFunc )
	return ZhuangBeiLayer.new( heroId, dbid, type, callFunc )
end

function ZhuangBeiLayer:onEnter( )
	-----添加引导 
	if self._tabsTable and self._tabsTable[4] then ---合成
		YinDaoMarg:getInstance():addGuide({
	        parent = self,
	        target = self._tabsTable[4], 
	        index = 4,
	        needNext = false,
	    },6)
    	YinDaoMarg:getInstance():doNextGuide()
	end 
end

return ZhuangBeiLayer