--[[
	宝典列表界面
	唐实聪
	2015.12.29
]]
local XiuLianListLayer = class( "XiuLianListLayer",function ()
	return XTHD.createBasePageLayer()
end)

function XiuLianListLayer:ctor( data )
	self._exist = true
	self._first = true
	self.currentIndex = 0
    self:initData( data )
    self:initUI()
    self:refreshUI()
    self:addGuide()
end

function XiuLianListLayer:onCleanup()
	self._exist = false
	if self._callFunc then
		self._callFunc()
	end
end

function XiuLianListLayer:onEnter()
	if not self._first then
		ClientHttp:requestAsyncInGameWithParams({
	        modules="baodianWindow?",
	        successCallback = function( backData )
	            -- dump(backData,"宝典初始化返回")
	            if tonumber( backData.result ) == 0 then
	            	self:refreshData( backData )
	            else
	                XTHDTOAST(backData.msg)
	            end
	        end,--成功回调
	        failedCallback = function()
	            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
	        end,--失败回调
	        targetNeedsToRetain = self,--需要保存引用的目标
	        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	    })
	    self._first = false
	end
end

function XiuLianListLayer:initData( data )
	self._addProperty = data.backData.addProperty
    self._configList = data.backData.configList


    self._redData = {}

	self._bibleId = data.bibleId or 1
	self._callFunc = data.callFunc

    self:buildRedDotData()

    
end
-- 判断红点条件
function XiuLianListLayer:buildRedDotData()
    -- 后端返回的配置等级
    local configList = {}
    for i, v in ipairs( self._configList ) do
        configList[tostring( v.configId )] = v.level
    end
    -- 静态表数据
    local staticList = gameData.getDataFromCSV( "Cultivation" )
    local bibleData = {}
    for i, v in ipairs( staticList ) do
        if v.show == 1 then
            bibleData[tostring( v.addtype )] = bibleData[tostring( v.addtype )] or {}
            v.level = configList[tostring( v.id )] or 0
            bibleData[tostring( v.addtype )][#bibleData[tostring( v.addtype )] + 1] = v
        end
    end
    -- dump( bibleData, "bibleData" )
    local ownObjectData = {}
    -- 玩家拥有的英雄
    ownObjectData[1] = {}
    local ownHeroList = DBTableHero.getData( gameUser.getUserId() )
    if table.nums( ownHeroList ) > 0 and not ownHeroList[1] then
        ownHeroList = { ownHeroList }
    end
    for i, v in ipairs( ownHeroList ) do
        ownObjectData[1][tostring( v.heroid )] = true
    end
    -- 玩家拥有的装备
    ownObjectData[2] = {}
    local ownItemList = DBTableItem.getData( gameUser.getUserId(), {item_type = 3} )
    if table.nums( ownItemList ) > 0 and not ownItemList[1] then
        ownItemList = { ownItemList }
    end
    for i, v in ipairs( ownItemList ) do
        ownObjectData[2][tostring( v.itemid )] = true
    end
    local ownEquipList = DBTableEquipment.getData( gameUser.getUserId() )
    if table.nums( ownEquipList ) > 0 and not ownEquipList[1] then
        ownEquipList = { ownEquipList }
    end
    for i, v in ipairs( ownEquipList ) do
        ownObjectData[2][tostring( v.itemid )] = true
    end
    -- 循环计算材料
    for k, v in pairs( bibleData ) do
        self._redData[k] = false
        for j, u in ipairs( v ) do
            if ownObjectData[tonumber( u.pos )][tostring( u.needID )] then
                -- 玩家拥有该英雄或装备
                if self:calculate( u ) then
                    -- dump( u, "redDotFlag" )
                    gameUser.setbaodianGettinState(1)
                    self._redData[k] = true
                    break
                else
                    gameUser.setbaodianGettinState(0)
                end
            end
        end
    end
  
    -- dump( self._redData, "self._redData" )
end
-- 计算每个对象激活升级所需材料
function XiuLianListLayer:calculate( data )
    -- 前缀
    local prefix = ""
    -- 倍数
    local times = 0
    if data.level == 0 then
        -- 未激活
        prefix = "unlockcost"
        times = 0
    elseif data.level < data.maxlevel then
        -- 已激活
        prefix = "upcost"
        times = data.level
    else
        -- 已满级
        return false
    end

    -- 玩家资源
    local myIngot = gameUser.getIngot()
    local myGold = gameUser.getGold()
    local myFeicui = gameUser.getFeicui()
    local mySmeltPoint = gameUser.getSmeltPoint()

    local enoughFlag = true
    local k = 1
    while data[prefix..k] and type( data[prefix..k] ) == "string" and enoughFlag do
        local tmpData = string.split( data[prefix..k], "#" )
        if tonumber( tmpData[1] ) ~= 0 then
            -- 数量
            local count = tonumber( tmpData[3] )
            if times ~= 0 and tmpData[4] then
                count = count + times*tonumber( tmpData[4] )
            end
            -- 类型
            local _type_ = tonumber( tmpData[1] )
            if _type_ == XTHD.resource.type.ingot then
                -- 元宝
                enoughFlag = myIngot >= count and true or false
            elseif _type_ == XTHD.resource.type.gold then
                -- 银两
                enoughFlag = myGold >= count and true or false
            elseif _type_ == XTHD.resource.type.feicui then
                -- 翡翠
                enoughFlag = myFeicui >= count and true or false
            elseif _type_ == XTHD.resource.type.item then
                -- 道具
                local ownData = DBTableItem.getData( gameUser.getUserId(), {itemid = tonumber( tmpData[2] )} )
                local ownNum = 0
                if #ownData ~= 0 and type(ownData[1]) == "table" then
                    for i=1,#ownData do
                        ownNum = ownNum + ownData[i].count
                    end
                else
                    ownNum = ownData.count or 0
                end
                enoughFlag = ownNum >= count and true or false
            elseif _type_ == XTHD.resource.type.smeltPoint then
                -- 回收点
                enoughFlag = mySmeltPoint >= count and true or false
            end
        end
        k = k + 1
    end

    return enoughFlag
end

function XiuLianListLayer:initUI()
	self._size = self:getContentSize()
	print("当前屏幕的尺寸为：")
	print_r(self._size)
	self._bottomSize = cc.size( self._size.width, 100 )
	self._attrLabel = {}
	self._attrValue = {}
    self._guideBtn = nil

    -- self._move = false

    local background = XTHD.createSprite( "res/image/plugin/bible_layer/background.png" )
	local _size = background:getContentSize()
	local size = cc.Director:getInstance():getWinSize()
	self.scaleX = size.width / _size.width
	self.scaleY = size.height / _size.height
    -- local background =ccui.Scale9Sprite:create( "res/image/plugin/bible_layer/background.png" )
	background:setPosition( self._size.width*0.5, ( self._size.height - self.topBarHeight )*0.5 )
    self:addChild( background )
	self._bg = background
    background:setContentSize(size)

    self:initBottom()
    self:initList()
end

function XiuLianListLayer:initList()
	-- 底座
	local bibleBottom = XTHD.createSprite( "res/image/plugin/bible_layer/bibleBottom.png" )
	bibleBottom:setAnchorPoint( cc.p( 0.5, 0 ) )
	bibleBottom:setPosition( self._size.width*0.5, ( self._size.height - self.topBarHeight )*0.5 - 137 )
    self:addChild( bibleBottom )
	self._bibleBottom = bibleBottom

	local tableView = cc.TableView:create( cc.size( self._size.width + 30, 427 ) )
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
--	tableView:setTouchEnabled(false)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
--    tableView:setBounceable(false)
--    tableView:setInertia(false)
--    tableView:setAutoAlign(true)
    tableView:setDelegate()
    tableView:setPosition(cc.p(0, ( self._size.height - self.topBarHeight )*0.5 - 157))
    self:addChild(tableView)
    self._tableView = tableView
	TableViewPlug.init(self._tableView)

	-- 两个箭头
    local _leftBtn = XTHDImage:create("res/image/plugin/stageChapter/btn_left_arrow.png")
    _leftBtn:setAnchorPoint(0, 0.5)
    _leftBtn:setPosition(30, self:getContentSize().height / 2)
    self:addChild(_leftBtn, 2)

    local _rightBtn = XTHDImage:create("res/image/plugin/stageChapter/btn_right_arrow.png")
    _rightBtn:setAnchorPoint(1, 0.5)

    _rightBtn:setPosition(self:getContentSize().width - 30, _leftBtn:getPositionY())
    self:addChild(_rightBtn, 2)

    local leftMove_1 = cc.MoveBy:create(0.5, cc.p(-10, 0))
    local leftMove_2 = cc.MoveBy:create(0.5, cc.p(10, 0))
    local rightMove_1 = cc.MoveBy:create(0.5, cc.p(10, 0))
    local rightMove_2 = cc.MoveBy:create(0.5, cc.p(-10, 0))

    _leftBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(leftMove_1, leftMove_2)))
    _rightBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(rightMove_1, rightMove_2)))
	_leftBtn:setVisible(false)
	_rightBtn:setVisible(true)

    _leftBtn:setTouchEndedCallback( function()
        self._tableView:scrollToLast()
    end )
    _rightBtn:setTouchEndedCallback( function()
        self._tableView:scrollToNext()
    end )

	local _cellSize = cc.size( ( self._size.width + 50 )/3, 427 )

    local _max = 1.0
    local _min = 0.68

    local function scorllviewScriptScroll( view )
		self.currentIndex = view:getCurrentPage() + 1
		local modI,modS = math.modf(self.currentIndex)
		if modS >= 0.5 then
			self.currentIndex = math.ceil(self.currentIndex)
		else
			self.currentIndex = math.floor(self.currentIndex)
		end
		print("当前页数为:"..self.currentIndex)
		
		if self.currentIndex <= 1 then
			_leftBtn:setVisible(false)
			_rightBtn:setVisible(true)
		elseif self.currentIndex >= 5 then
			_leftBtn:setVisible(true)
			_rightBtn:setVisible(false)
		else
			_leftBtn:setVisible(true)
			_rightBtn:setVisible(true)
		end
		self._progressDot:setPositionX((self._bibleBottom:getContentSize().width/4 + 97)*(self.currentIndex))
        if self.currentIndex ~= self._bibleId then
            local _tmpPage = self._bibleId
            self._bibleId = self.currentIndex
            tableView:updateCellAtIndex(_tmpPage)
            tableView:updateCellAtIndex(self._bibleId)
        end
        
        local _offSet = view:getContentOffset().x
        -- print(_offSet)
        for i = 1, 5 do
            local _cell = view:cellAtIndex(i)
            if _cell and _cell._sprite then
                local part = math.abs(_cell:getPositionX() - _cellSize.width - math.abs(_offSet))
                part = (_cellSize.width - part)/_cellSize.width
                part = part > 1 and 1 or part
                part = part < 0 and 0 or part
                local _scale = _max - (1-part)*(_max - _min)
                _cell._sprite:setScale(_scale)
            end
            if _cell and _cell._bibleLight then
                _cell._bibleLight:setVisible( false )
            end
        end
        -- bibleBottom:setOpacity( math.abs( math.abs( -_offSet%_cellSize.width ) - _cellSize.width*0.5 )/_cellSize.width*2*255 )
--        bibleBottom:setOpacity( 0 )
    end
    
    local function numberOfCellsInTableView( table )
    	local num = 7
        return num
    end
    local function cellSizeForTable( table, idx )
        return _cellSize.width ,  _cellSize.height
    end
	self._tableView.getCellNumbers = numberOfCellsInTableView
	self._tableView.getCellSize = cellSizeForTable
	
    local function tableCellAtIndex( table, idx )
        -- print("tableCellAtIndex")
        local _cell = table:dequeueCell()
        if _cell == nil then
            _cell = cc.TableViewCell:new()
        else
            _cell:removeAllChildren()
        end
        local _index = idx + 1
        if _index == 1 or _index == 7 then
        	_cell._sprite = nil
        	return _cell
    	end

        -- 背景
        bibleSpriteBg = XTHD.createSprite("res/image/plugin/bible_layer/bibleBg.png")
        -- 光
        local bibleLight = XTHD.createSprite()
        getCompositeNodeWithNode( bibleSpriteBg, bibleLight )
        _cell._bibleLight = bibleLight
        -- bibleSpriteBg:setScale(0.7)
        -- 按钮
        local bibleBtn_normal = XTHD.createSprite()
        bibleBtn_normal:setContentSize( bibleSpriteBg:getContentSize() )
        local bibleBtn_selected = XTHD.createSprite()
        bibleBtn_selected:setContentSize( bibleBtn_normal:getContentSize() )
        local bibleBtn = XTHD.createButton({
            normalNode = bibleBtn_normal,
            selectedNode = bibleBtn_selected,
            needEnableWhenOut = true,
            needEnableWhenMoving = true,
            needSwallow = false,
            beganCallback = function()
            	bibleLight:setVisible( false )
                self._isAutoScrolling = false
            end,
            -- moveCallback = function()
            --     self._move = true
            -- end,
            endCallback = function()
                YinDaoMarg:getInstance():guideTouchEnd()
                -- if self._move then
                --     self._move = false
                --     return
                -- end
            	if self._bibleId == idx then
            		bibleLight:setVisible( true )
            		local bibleLayer = requires("src/fsgl/layer/XiuLian/XiuLianInfoLayer.lua"):create({addProperty = self._addProperty, configList = self._configList, bibleId = self._bibleId, callFunc = function( bibleId )
	                    if self._exist then
                            ClientHttp:requestAsyncInGameWithParams({
                                modules="baodianWindow?",
                                successCallback = function( backData )
                                    -- dump(backData,"宝典初始化返回")
                                    if tonumber( backData.result ) == 0 then
                                        self:refreshData( backData )
                                        if self._bibleId == bibleId then
                                            -- print("bibleIdbibleIdbibleIdbibleId  ",bibleId)
                                            -- dump( self._redData, "self._redData" )
                                            self._tableView:updateCellAtIndex( bibleId )
                                            return
                                        end
                                        self._bibleId = bibleId
                                        self._isAutoScrolling = true
                                        self._tableView:scrollToCell( self._bibleId - 1, true )
										gameUser.setGuildPoint(backData.totalContribution)
			                        else
                                        XTHDTOAST(backData.msg)
                                    end
                                end,--成功回调
                                failedCallback = function()
                                    XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
                                end,--失败回调
                                targetNeedsToRetain = self,--需要保存引用的目标
                                loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
                            })
	                    end
	                end})
	                LayerManager.addLayout( bibleLayer )
        		else
                    self._bibleId = idx
                    self._isAutoScrolling = true
                    self:runAction(
                        cc.Sequence:create(
                            cc.CallFunc:create(
                                function()
                                    self._tableView:scrollToCell( self._bibleId - 1, true )
                                end
                            ),
                            cc.CallFunc:create(
                                function()
                                    local midCell = self._tableView:cellAtIndex( self._tableView:getCurrentPage() + 1 )
                                    if midCell._bibleLight then
                                        midCell._bibleLight:setVisible( true )
                                    end
                                end
                            )
                        )
                    )
    			end
            end
        })

        getCompositeNodeWithNode( bibleSpriteBg, bibleBtn )
        -- 宝典图
        local bibleSprite = XTHD.createSprite( "res/image/plugin/bible_layer/bible_"..idx..".png" )
        bibleSprite:setPosition( cc.p( bibleSpriteBg:getContentSize().width/2, bibleSpriteBg:getContentSize().height/2  ) )
        bibleSpriteBg:addChild( bibleSprite )
        -- 宝典名字背景
        local bibleNameBg = XTHD.createSprite("res/image/plugin/bible_layer/nameBg.png")
        bibleNameBg:setPosition( bibleSpriteBg:getContentSize().width*0.5, 20 )
        bibleSpriteBg:addChild( bibleNameBg )
        -- 宝典名字
        local bibleNameTable = {
			LANGUAGE_BIBLE_TEXT[1], LANGUAGE_BIBLE_TEXT[2], LANGUAGE_BIBLE_TEXT[3], LANGUAGE_BIBLE_TEXT[4], LANGUAGE_BIBLE_TEXT[5],
		}
        local bibleName = XTHD.createLabel({
        	text = bibleNameTable[idx],
            fontSize = 22,
            color = cc.c3b( 255, 255, 255 ),
            ttf = "res/fonts/def.ttf"
        })
        bibleName:enableOutline(cc.c4b(45,13,103,255),2)
        getCompositeNodeWithNode( bibleNameBg, bibleName )
        -- 红点
        if self._redData[tostring( idx )] then
            local redDot = cc.Sprite:create( "res/image/common/heroList_redPoint.png" )
            redDot:setAnchorPoint( 1, 1 )
            redDot:setPosition( bibleSprite:getBoundingBox().width - 50, bibleSprite:getBoundingBox().height - 50 )
            bibleSprite:addChild( redDot )
        end

        local _sprite = bibleSpriteBg
    	_sprite:setPosition(_cellSize.width*0.5, _cellSize.height*0.5)
        _cell:addChild(_sprite)
        if self._bibleId == idx then
        	_sprite:setOpacity(255)
        	bibleName:setColor( cc.c3b( 255, 255, 255 ) )
        	bibleName:setFontSize( 26 )
        	bibleName:enableOutline( cc.c3b( 0, 0, 0 ), 1 )
            self._guideBtn = bibleBtn
        else
        	_sprite:setOpacity(150)
        	bibleName:setColor( XTHD.resource.color.white_desc )
        	bibleName:enableOutline(cc.c3b(0,0,0), 2 )
        	bibleName:setFontSize( 18 )
        end
        _cell._sprite = _sprite
        return _cell
    end

    local function tablePageAfterSliding( table, cell )
        scorllviewScriptScroll(table)
        -- self._move = false
        local midCell = table:cellAtIndex( table:getCurrentPage() + 1 )
        if midCell._bibleLight then
            midCell._bibleLight:setVisible( true )
        end
        --print("self._bottomSize.width"..self._bottomSize.width)
        --print("self._bottomSize.width/5"..self._bottomSize.width/5)
        --print("self._bibleId"..self._bibleId)
        --self._progressDot:setPositionX(self._bottomSize.width/5*self._bibleId)
--        self._progressDot:setPositionX(self._bottomSize.width/5*self._bibleId + self._bibleId * 13 - 10)
    end

    tableView:registerScriptHandler(numberOfCellsInTableView,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)  
    tableView:registerScriptHandler(cellSizeForTable,cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex,cc.TABLECELL_SIZE_AT_INDEX)
    tableView:registerScriptHandler(scorllviewScriptScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
--    tableView:registerScriptHandler(tablePageAfterSliding,cc.SCROLLVIEW_SCRIPT_ZOOM)
	tableView:reloadData()
    tableView:cellAtIndex( tableView:getCurrentPage() + 1 )._bibleLight:setVisible( true )
end

function XiuLianListLayer:initBottom()
    local infoBg = ccui.Scale9Sprite:create("res/image/plugin/bible_layer/jindu.png")
    infoBg:setScaleX(self:getContentSize().width/infoBg:getContentSize().width)
    infoBg:setScaleY(0.8)
	-- infoBg:setContentSize( self._bottomSize )
	infoBg:setAnchorPoint( cc.p( 0.5, 1 ) )
	infoBg:setPosition( self._size.width*0.5, ( self._size.height - self.topBarHeight )*0.5 - 168 )
	self:addChild( infoBg )

	-- -- 进度条
	-- local progressList = XTHD.createSprite( "res/image/plugin/bible_layer/scale9Bg.png" )
    -- -- 背景
    -- local progressBg = ccui.Scale9Sprite:create("res/image/plugin/bible_layer/progress.png" )
    -- progressBg:setContentSize( self._bottomSize.width - 16, 22 )
    -- progressBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    -- progressBg:setPosition( cc.p( self._bottomSize.width*0.5, 84 ) )
    -- infoBg:addChild( progressBg )
	-- -- 固定点
	-- for i = 1, 6 do
	-- 	local smallPoint = XTHD.createSprite( "res/image/plugin/bible_layer/smallPoint.png" )
	-- 	smallPoint:setPosition( self._bottomSize.width/12*( 2*i - 1 ), 85 )
	-- 	infoBg:addChild( smallPoint )
	-- end
	-- for i = 1, 5 do
	-- 	local bigPoint = XTHD.createSprite( "res/image/plugin/bible_layer/bigPoint.png" )
	-- 	bigPoint:setPosition( self._bottomSize.width/6*i, 83 )
	-- 	infoBg:addChild( bigPoint )
	-- end
	-- 点
	
	local progressDot = XTHD.createSprite( "res/image/plugin/bible_layer/dot.png" )
	progressDot:setPosition( infoBg:getContentSize().width/4*self._bibleId, infoBg:getContentSize().height * 0.5 +progressDot:getContentSize().height )
    infoBg:addChild( progressDot )
    progressDot:setScale(0.7)
	self._progressDot = progressDot
	-- 分隔线
	-- local splitLine = ccui.Scale9Sprite:create( "res/image/ranklistreward/splitcell.png" )
    -- splitLine:setContentSize( infoBg:getContentSize().width - 10, 2 )
    -- splitLine:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    -- splitLine:setPosition( infoBg:getContentSize().width*0.5, 70 )
    -- infoBg:addChild( splitLine )

    -- 宝典属性总览
    local attrTitle = XTHD.createLabel({
    	text = LANGUAGE_BIBLE_TEXT[20],
    	fontSize = 26,
    	color = cc.c3b( 245, 103, 38),
    	anchor = cc.p( 0, 0.5 ),
        pos = cc.p( 20, 63 ),
        ttf = "res/fonts/def.ttf"
	})
	infoBg:addChild( attrTitle )
	-- 属性
	for i, v in ipairs( self._addProperty ) do
		local attrLabel = XTHD.createRichLabel({
			anchor = cc.p( 0, 0),
			fontSize  = 20,
            pos = cc.p( self._size.width*( 0.2*i - 0.2 ) + 20 , 13 ),
            color = cc.c3b( 0, 0, 0),
            ttf = "res/fonts/def.ttf"
		})
		infoBg:addChild( attrLabel )
		self._attrLabel[i] = attrLabel
		local attrValue = XTHD.createRichLabel({
			anchor = cc.p( 0, 0),
			fontSize  = 17,
            pos = cc.p( self._size.width*( 0.2*i - 0.09 ) - 5 , 15 ),
            color = cc.c3b( 244, 164, 96),
            ttf = "res/fonts/def.ttf"
		})
		infoBg:addChild( attrValue )
		self._attrValue[i] = attrValue
	end
end

function XiuLianListLayer:refreshData( backData )
	self._addProperty = backData.addProperty
	self._configList = backData.configList
    self:buildRedDotData()
    self:refreshUI()
end

function XiuLianListLayer:refreshUI()
    --宝典总属性：生命上限，物理伤害，物理防御，魔法伤害，魔法防御
	local bibleNameTable = {
		LANGUAGE_TIPS_WORDS106[1], LANGUAGE_TIPS_WORDS106[2], LANGUAGE_TIPS_WORDS106[3], LANGUAGE_TIPS_WORDS106[4], LANGUAGE_TIPS_WORDS106[5],
	}
	for i, v in ipairs( self._addProperty ) do
		self._attrLabel[i]:setString( bibleNameTable[i])
		self._attrValue[i]:setString("+"..v)
	end
end

function XiuLianListLayer:initGuide( bibleId )
    self._bibleId = bibleId or 1
    self._tableView:scrollToCell( self._bibleId - 1, false )
    return self._guideBtn
end

function XiuLianListLayer:create( data )
	return XiuLianListLayer.new( data )
end

function XiuLianListLayer:addGuide( )
    local _guideGroup,_guideIndex = YinDaoMarg:getInstance():getGuideSteps()
    if _guideGroup == 17 and _guideIndex == 3 then 
        YinDaoMarg:getInstance():addGuide({index = 3,parent = self},17) ----剧情
        local _target = self:initGuide(1)
        if _target then 
            YinDaoMarg:getInstance():addGuide({
                parent = self,
                target = _target,-----点击生命宝典
                index = 4,
                needNext = false,
            },17)
        end 
    end
    YinDaoMarg:getInstance():doNextGuide()
end

return XiuLianListLayer