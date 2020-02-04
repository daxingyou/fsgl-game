--[[
	累计充值活动
]]
local NewLeiJiChongZhiLayer = class("NewLeiJiChongZhiLayer", function()
    local layer = XTHD.createSprite()
	layer:setContentSize( 539, 399 )
	return layer
end)

function NewLeiJiChongZhiLayer:ctor(parent,params)
	self._exist = true
--	print("累计充值服务器返回的数据为")
--	print_r(params)
	self._size = self:getContentSize()
	self._leftWidth = 250
	self._parent = parent

	-- 数据
	-- 状态
	self:initData( params )

	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG ,callback = function()
		if self._exist then
        	self:refreshData()
        end
    end})

	self:initUI()
	self:refreshUI()
	
end
-- 
function NewLeiJiChongZhiLayer:onCleanup()
	self._exist = false
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_RECHARGE_MSG)
    -- XTHD.dispatchEvent({ name = CUSTOM_EVENT.REFRESH_ACTIVITIESTAB_REDPOINT })
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey( "res/image/activities/totalrecharge/background.jpg" )
	textureCache:removeTextureForKey( "res/image/activities/totalrecharge/tableviewbg.png" )
	textureCache:removeTextureForKey( "res/image/activities/totalrecharge/cellbg.png" )
end
-- 创建界面
function NewLeiJiChongZhiLayer:initUI()
	-- 背景
	local background = ccui.Scale9Sprite:create( "res/image/activities/activityRec_bg.png" )
	background:setContentSize(640,483)
	background:setAnchorPoint( cc.p( 1, 0.5 ) )
	background:setPosition( self._size.width + 34, self._size.height*0.5 - 18 )
	self:addChild( background )
	-- 左边图
	local smallRaccoon = XTHD.createSprite( "res/image/activities/vipDailyReward/leijichongzhichatu.png" )
	smallRaccoon:setAnchorPoint(0.5,0.5)
	smallRaccoon:setPosition( 98, self:getContentSize().height/2 -18 )
	self:addChild( smallRaccoon )
	-- -- 活动时间
	-- local timeLabel = XTHD.createLabel({
	-- 	text      = LANGUAGE_TOTALRECHARGE_DAYS( self._openTime.beginMonth, self._openTime.beginDay, self._openTime.endMonth, self._openTime.endDay ),
	-- 	fontSize  = 18,
	-- 	color     = cc.c3b( 229, 183, 47 ),
	-- 	anchor    = cc.p( 0, 1 ),
	-- 	pos       = cc.p( timeTitleLabel:getPositionX(), timeTitleLabel:getPositionY() - 30 ),
	-- 	clickable = false,
	-- })
	-- timeLabel:setWidth( self._leftWidth - 15 )
	-- timeLabel:enableShadow( cc.c3b( 229, 183, 47 ), cc.size( 1, 0 ) )
	-- background:addChild( timeLabel )

	-- 屏蔽点击
	local swallow_normal = XTHD.createSprite()
	swallow_normal:setContentSize( self._size.width - self._leftWidth, 55 )
	local swallow = XTHD.createButton({
        normalNode = swallow_normal,
        anchor = cc.p(0, 0.5 ),
        pos = cc.p( 20, background:getContentSize().height - 43 ),
        needSwallow = true,
        beganCallback = function()
            return true
        end,
    })
    background:addChild( swallow, 1 )
    -- 前往充值
    local gotoRechargeBtn = XTHD.createButton({
		normalFile = "res/image/activities/hdbtn/btn_buy_up.png",
		selectedFile = "res/image/activities/hdbtn/btn_buy_down.png",
		btnSize = cc.size( 130, 41 ),
        anchor = cc.p( 0.5, 0.5 ),
		pos = cc.p( 70, swallow:getContentSize().height*0.5+5),
        endCallback = function()
        	XTHD.createRechargeVipLayer( self )
        end
	})

	gotoRechargeBtn:setScale(0.7)
	-- gotoRechargeBtn:getLabel():setPositionX(gotoRechargeBtn:getLabel():getPositionX()-15)
	-- gotoRechargeBtn:getLabel():setPositionY(gotoRechargeBtn:getLabel():getPositionY()-10)
	swallow:addChild( gotoRechargeBtn )
	-- 完成充值
	local rechargedLabel = XTHD.createLabel({
		fontSize  = 20,
		color     = cc.c3b(246,252,210),
		anchor    = cc.p( 1, 0.5 ),
		pos       = cc.p( swallow:getContentSize().width - 84, swallow:getContentSize().height*0.5 + 5 ),
		clickable = false,
	})
	swallow:addChild( rechargedLabel )
	self._rechargedLabel = rechargedLabel
	-- 箱子光
	local effectSp = cc.Sprite:create( "res/image/activities/onlinereward/onlinereward_lightBg.png" )
    effectSp:runAction( cc.RepeatForever:create( cc.RotateBy:create( 15, 360 ) ) )
    effectSp:setVisible( false )
    effectSp:setPosition( swallow:getContentSize().width - 45, swallow:getContentSize().height*0.5 )
	swallow:addChild( effectSp )
    self._effectSp = effectSp
    -- 箱子
	local rewardBox = XTHD.createButton({
        normalFile = "res/image/activities/logindaily/logindaily_box_3.png",
        pos = cc.p( swallow:getContentSize().width - 45, swallow:getContentSize().height*0.5 + 10 ),
        endCallback = function()
        	local layer = requires("src/fsgl/layer/HuoDong/TotalRechargePopLayer1.lua"):create(self._totalData,self._finishNum,function( data )
        		self._totalData = data
        		self:refreshUI()
        	end)
    		self._parent:addChild( layer )
    		layer:show()
        end
    })
	swallow:addChild( rewardBox )
	self._rewardBox = rewardBox

	--tableview背景
	local tableViewBg = ccui.Scale9Sprite:create( cc.rect( 32, 31, 2, 1 ), "res/image/activities/totalrecharge/tableviewbg.png" )
	tableViewBg:setContentSize( self._size.width - self._leftWidth  + 45, self._size.height - 5 - swallow:getContentSize().height + 60 )
	tableViewBg:setAnchorPoint( cc.p( 0, 0 ) )
	tableViewBg:setPosition( 5, 1 )
	background:addChild( tableViewBg )
	-- tableview
	local tableView = CCTableView:create( cc.size( tableViewBg:getContentSize().width - 6, tableViewBg:getContentSize().height - 8 ) )
	tableView:setPosition( 5, 5 )
	tableView:setBounceable( true )
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	tableView:setDelegate()
	tableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	tableViewBg:addChild( tableView )
	self._tableView = tableView
	local cellWidth = tableViewBg:getContentSize().width - 10
	local cellHeight = 103
	local function numberOfCellsInTableView( table )
		return #self._rechargeData
	end
	local function cellSizeForTable( table, index )
		return cellWidth,cellHeight
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
			cell:setContentSize(cc.size(cellWidth,cellHeight))
            self:buildCell( cell, index, cellWidth, cellHeight )
        end
        self:updateCell( cell, index )

    	return cell
    end
	tableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    tableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    tableView:reloadData()
end
-- 处理数据
function NewLeiJiChongZhiLayer:initData( httpData )
	-- 状态
	local rechargeStateData = {}
	for i, v in ipairs( httpData.list ) do
		rechargeStateData[tostring( v.configId )] = tonumber( v.state )
	end
	local totalStateData = {}
	for i, v in ipairs( httpData.totalList ) do
		totalStateData[tostring( v.configId )] = tonumber( v.state )
	end
	-- 静态表
	local rechargeList = gameData.getDataFromCSV( "CumulativeChongzhi", {huodongID = httpData.activityId} )
	-- dump( rechargeList, "rechargeList")
	local rechargeData = {}
	local totalData = {}
	for i, v in ipairs( rechargeList ) do
		if tonumber( v.typeR ) == 1 then
			v.state = rechargeStateData[tostring( v.id )] or 0
			rechargeData[#rechargeData + 1] = v
		else
			v.state = totalStateData[tostring( v.id )] or 0
			totalData[#totalData + 1] = v
		end
	end
	-- 排序
	self._rechargeData = self:sortData( rechargeData )
	self._totalData = totalData
	-- dump( self._rechargeData, "self._rechargeData")
	-- dump( self._totalData, "self._totalData")
	-- 累计充值
	self._totalRecharge = tonumber( httpData.totalPay )
	-- 开启时间
	self._openTime = {
		beginMonth = httpData.beginMonth or "",
		beginDay = httpData.beginDay or "",
		endMonth = httpData.endMonth or "",
		endDay = httpData.endDay or "",
	}
end
-- 创建cell
function NewLeiJiChongZhiLayer:buildCell( cell, index, cellWidth, cellHeight )
	-- cell背景
	local cellBg = ccui.Scale9Sprite:create( cc.rect( 26, 48, 1, 1 ), "res/image/activities/totalrecharge/cellbg.png" )
	cellBg:setContentSize( cellWidth, cellHeight )
	cellBg:setAnchorPoint( cc.p( 0, 0 ) )
	cellBg:setPosition( 0, 3 )
	cell:addChild( cellBg )
	-- 标题
	local titleBef = XTHD.createSprite( "res/image/activities/levelreward/levelreward_titlesp.png" )
	titleBef:setAnchorPoint( 1, 0.5 )
	cell:addChild( titleBef )
	cell._titleBef = titleBef
	local title = XTHD.createLabel({
		anchor = cc.p( 0.5, 0.5 ),
		pos = cc.p( cellBg:getContentSize().width*0.5 - 120, cellBg:getContentSize().height - 15 ),
		color = cc.c3b( 222, 130, 68 ),
		fontSize = 20,
	})
	cell:addChild( title )
	cell._title = title
	local titleAft = XTHD.createSprite( "res/image/activities/levelreward/levelreward_titlesp.png" )
	titleAft:setAnchorPoint( 0, 0.5 )
	cell:addChild( titleAft )
	cell._titleAft = titleAft
	-- 进度
	local progress = XTHD.createLabel({
		fontSize = 15,
		color    = XTHD.resource.color.gray_desc,
		anchor   = cc.p( 0.5, 0.5 ),
		pos      = cc.p( cellBg:getContentSize().width - 80, title:getPositionY() - 3 ),
	})
	cell:addChild( progress )
	cell._progress = progress
	-- 分界线
	local split = XTHD.createSprite( "res/image/activities/totalrecharge/split.png" )
	split:setPosition( cellBg:getContentSize().width*0.5, cellBg:getContentSize().height - 25 )
	cell:addChild( split )
	-- 奖励图片
	local taskReward = getCompositeNodeWithImg( "res/image/plugin/tasklayer/taskrewardbg.png", "res/image/plugin/tasklayer/taskrewardtext1.png" )
	taskReward:setPosition( 32, 42 )
	taskReward:setScale(0.8)
	cell:addChild( taskReward )
	-- 奖励容器
	local iconContainer = XTHD.createSprite()
	iconContainer:setContentSize( 360, 70 )
	iconContainer:setAnchorPoint( 0, 0 )
	iconContainer:setPosition( 60, 3 )
	cell:addChild( iconContainer )
	cell._iconContainer = iconContainer
	-- 领取按钮
	local fetchBtn = XTHD.createCommonButton({
		btnColor = "write_1",
		btnSize = cc.size(100,49),
		isScrollView = true,
        text = LANGUAGE_BTN_KEY.getReward,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( cellBg:getContentSize().width - 80, taskReward:getPositionY() - 3),
	})
	fetchBtn:setScale(0.7)
	cell:addChild( fetchBtn )
	local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
    fetchBtn:addChild( fetchSpine )
    fetchSpine:setScaleX( fetchBtn:getContentSize().width/150 )
    fetchSpine:setScaleY( fetchBtn:getContentSize().height/70 )
    fetchSpine:setPosition( fetchBtn:getBoundingBox().width * 0.75, fetchBtn:getContentSize().height/2 + 3 )
	fetchSpine:setAnimation( 0, "querenjinjie", true )
	cell._fetchBtn = fetchBtn
	-- 未完成按钮
	local notFinishBtn = XTHD.createCommonButton({
		btnColor = "write",
		btnSize = cc.size(100,49),
		isScrollView = true,
        text = LANGUAGE_KEY_NOTREACHABLE,
        anchor = cc.p( 0.5, 0.5 ),
        pos = cc.p( fetchBtn:getPosition() ),
	})
	notFinishBtn:setScale(0.75)
	cell:addChild( notFinishBtn )
	cell._notFinishBtn = notFinishBtn
	-- 已领取
	local fetchedImageView = XTHD.createSprite( "res/image/vip/yilingqu.png" )
	fetchedImageView:setScale(0.7)
    fetchedImageView:setPosition( fetchBtn:getPosition() )
    cell:addChild( fetchedImageView )
    cell._fetchedImageView = fetchedImageView
end
-- 更新cell
function NewLeiJiChongZhiLayer:updateCell( cell, index )
	index = index + 1
	-- 数据
	local data = self._rechargeData[index]
	-- 标题
	cell._title:setString( LANGUAGE_TOTALRECHARGE_MONEY( data.yuanbao ) )
	cell._titleBef:setPosition( cell._title:getPositionX() - cell._title:getContentSize().width/2 - 3, cell._title:getPositionY() )
	cell._titleAft:setPosition( cell._title:getPositionX() + cell._title:getContentSize().width/2 + 3, cell._title:getPositionY() )
	-- 进度
	if self._totalRecharge > tonumber( data.yuanbao ) then
		cell._progress:setString( (tonumber( data.yuanbao )*0.1).." / "..(tonumber( data.yuanbao )*0.1) )
	else
		cell._progress:setString( (self._totalRecharge*0.1).." / "..(tonumber( data.yuanbao )*0.1) )
	end
	-- 奖励
	cell._iconContainer:removeAllChildren()
	local iconData = {}
	local i = 1
	while data["rewardtype"..i] do
		local tmp = string.split( data["canshu"..i], "#" )
		if #tmp > 1 and tonumber( tmp[2] ) > 0 then
			local tmpData = {
				rewardtype = tonumber( data["rewardtype"..i] ),
	            id = tonumber( tmp[1] ),
	            num = tonumber( tmp[2] ),
                isLightAct = true,
			}
			local icon = ItemNode:createWithParams({
	            _type_ = tmpData.rewardtype,
	            itemId = tmpData.id,
	            count = tmpData.num,
                isLightAct = true,
	        })
	        icon:setScale( 60/icon:getContentSize().width )
	        icon:setPosition( 60*( i - 0.5 ) - 3, 36 )
	        cell._iconContainer:addChild( icon )
	        iconData[#iconData + 1] = tmpData
		end
		i = i + 1
	end
	-- 按钮
	if data.state == 1 then
		-- 可领取
		cell._fetchBtn:setVisible( true )
		cell._fetchBtn:setTouchEndedCallback(function()
			cell._fetchBtn:setEnable(false)
			self:fetchReward( data.yuanbao, iconData, index ,cell._fetchBtn)
		end)
		cell._notFinishBtn:setVisible( false )
		cell._fetchedImageView:setVisible( false)
	elseif data.state == 2 then
		-- 已领取
		cell._fetchBtn:setVisible( false )
		cell._notFinishBtn:setVisible( false )
		cell._fetchedImageView:setVisible( true)
	else
		-- 不可领取
		cell._fetchBtn:setVisible( false )
		cell._notFinishBtn:setVisible( true )
		cell._notFinishBtn:setTouchEndedCallback(function()
			XTHDTOAST(LANGUAGE_TOTALRECHARGE_TEXT[4])
		end)
		cell._fetchedImageView:setVisible( false)
	end
end
-- 领取奖励
function NewLeiJiChongZhiLayer:fetchReward( yuanbao, iconData, index , btn)
	ClientHttp:requestAsyncInGameWithParams({
        modules="receiveTotalPayReward?",
        params = {gold = yuanbao},
        successCallback = function( backData )
            -- dump(backData,"领取奖励返回")
            if tonumber( backData.result ) == 0 then
	            ShowRewardNode:create( iconData )
            	-- 更新属性
		    	if backData.property and #backData.property > 0 then
	                for i=1, #backData.property do
	                    local pro_data = string.split( backData.property[i], ',' )
	                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
	                end
	                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
	            end
	            -- 更新背包
	            if backData.bagItems and #backData.bagItems ~= 0 then
	                for i=1, #backData.bagItems do
	                    local item_data = backData.bagItems[i]
	                    if item_data.count and tonumber( item_data.count ) ~= 0 then
	                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
	                    else
	                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
	                    end
	                end
	            end
				btn:setEnable(true)
	            self:refreshData()
        	else
                XTHDTOAST(backData.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    })
end
-- 对数据进行排序
function NewLeiJiChongZhiLayer:sortData( dataTable )
	-- 分离数据
	local notFetchTable = {}
	local fetchedTable = {}
	for i, v in ipairs( dataTable ) do
		if v.state == 2 then
			fetchedTable[#fetchedTable + 1] = v
		else
			notFetchTable[#notFetchTable + 1] = v
		end
	end
	-- 排序
	table.sort( notFetchTable, function( a, b )
		return a.id < b.id
	end)
	table.sort( fetchedTable, function( a, b )
		return a.id < b.id
	end)
	-- 组合数据
	local sortedTable = {}
	for i, v in ipairs( notFetchTable ) do
		sortedTable[#sortedTable + 1] = v
	end
	for i, v in ipairs( fetchedTable ) do
		sortedTable[#sortedTable + 1] = v
	end
	return sortedTable
end
-- 重新请求数据
function NewLeiJiChongZhiLayer:refreshData()
	ClientHttp:requestAsyncInGameWithParams({
        modules="totalPayRewardList?",
        successCallback = function( backData )
            -- dump(backData,"初始化返回")
            if tonumber( backData.result ) == 0 then
            	self:initData( backData )
            	self:refreshUI()
        	else
                XTHDTOAST(backData.msg)
            end
        end,--成功回调
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        targetNeedsToRetain = self,--需要保存引用的目标
        loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = self,
    })
end
-- 刷新界面
function NewLeiJiChongZhiLayer:refreshUI()
	if not self._exist then
		return
	end
	-- 完成充值
	local count = 0
	for i, v in ipairs( self._rechargeData ) do
		if v.state == 2 then
			count = count + 1
		end
	end
	self._finishNum = count
	self._rechargedLabel:setString( LANGUAGE_TOTALRECHARGE_FINISH( count, #self._rechargeData ) )
	-- 弹窗
	local popFlag = false
	for i, v in ipairs( self._totalData ) do
		if v.state == 1 then
			popFlag = true
			break
		end
	end
	if popFlag then
		self._effectSp:setVisible( true )
		self._rewardBox:runAction( cc.RepeatForever:create( cc.Sequence:create( cc.ScaleTo:create( 0.5, 1 ), cc.ScaleTo:create( 0.8, 0.8 ) ) ) )
	else
		self._effectSp:setVisible( false )
		self._rewardBox:stopAllActions()
	end
	self._tableView:reloadData()
end

function NewLeiJiChongZhiLayer:create(parent,params)
    return self.new(parent,params)
end

return NewLeiJiChongZhiLayer
