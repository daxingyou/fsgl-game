--[[
	累计充值界面
    20190611
]]
local RedPacketLayer1 = class("RedPacketLayer1", function(params)
	local layer = XTHD.createSprite()
	layer:setContentSize( 640, 428 )
	return layer
end)

function RedPacketLayer1:ctor(params)
	self._exist = true
	-- dump( params, "RedPacketLayer1 ctor" )
	-- ui
	self._size = self:getContentSize()
    self.parentLayer = params.parentLayer
    self.httpData = params.httpData
	-- 状态
	self:initData( params.httpData )
	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG ,callback = function()
		if self._exist then
        	self:refreshData()
        end
    end})

	self:initUI()
end
-- 
function RedPacketLayer1:onCleanup()
	self._exist = false
end

--刷新小红点
function RedPacketLayer1:freshRedDot(data)
	-- print("累计充值：-----------------------------")
	-- print_r(data)
	local isHave = false
	for i = 1,#data.list do
        if data.list[i].state == 1 then
            isHave = true
            break
        end
	end
	if isHave then
        self.parentLayer.redDotTable[1]:setVisible(true)
    else
    	self.parentLayer.redDotTable[1]:setVisible(false)
	end
end

-- 处理数据
function RedPacketLayer1:initData( httpData )
	-- 状态
	self:freshRedDot(httpData)
	local rechargeStateData = {}
	for i, v in ipairs( httpData.list ) do
		rechargeStateData[tostring( v.configId )] = tonumber( v.state )
	end
	-- 静态表
	local rechargeList = gameData.getDataFromCSV( "CumulativeChongzhi", {huodongID = httpData.activityId} )
	-- dump( rechargeList, "rechargeList")
	local rechargeData = {}
	for i, v in ipairs( rechargeList ) do
		if tonumber( v.typeR ) == 1 then
			v.state = rechargeStateData[tostring( v.id )] or 0
			rechargeData[#rechargeData + 1] = v
		end
	end
	-- 排序
	self._rechargeData = self:sortData( rechargeData )
	-- dump( self._rechargeData, "self._rechargeData")
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
-- 创建界面
function RedPacketLayer1:initUI()
	-- 标题背景
	local titleBg = XTHD.createSprite( "res/image/activities/newyear/redpacket/title.png" )
	titleBg:setPosition( self._size.width*0.5+22, self._size.height - titleBg:getContentSize().height*0.5 + 4)
	titleBg:setScaleY(1.2)
	titleBg:setScaleX(1.07)
	self:addChild( titleBg )
	-- 活动时间
	local titleTime = XTHD.createLabel({
		text     = LANGUAGE_PRAYER_DAYS(self._openTime.beginMonth,self._openTime.beginDay,self._openTime.endMonth,self._openTime.endDay),
		fontSize = 18,
		color    = cc.c3b( 255, 252, 0 ),
		anchor   = cc.p( 0, 0 ),
		pos      = cc.p( 15, 7 ),
	})
	titleBg:addChild( titleTime )
	self._titleTime = titleTime

	-- tableview
	local tableView = CCTableView:create( cc.size( self._size.width, self._size.height - titleBg:getContentSize().height - 25 ) )
	tableView:setPosition( 23, 0 )
	tableView:setBounceable( true )
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	tableView:setDelegate()
	tableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	self:addChild( tableView )
	self._tableView = tableView

	local cellWidth = self._size.width + 10
	local cellHeight = 120

	local function numberOfCellsInTableView( table )
		return #self._rechargeData
	end
	local function cellSizeForTable( table, index )
		return  cellWidth,cellHeight - 10
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
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

function RedPacketLayer1:buildCell( cell, index, cellWidth, cellHeight )

    local bg2 = ccui.Scale9Sprite:create("res/image/activities/newyear/redpacket/cellbg_2.png" )
	bg2:setContentSize(cellWidth - 35,cellHeight - 20)
    bg2:setPosition( cellWidth*0.5 - 5, cellHeight*0.5 )
	cell:addChild( bg2 )

	local cellBg = XTHD.createSprite( "res/image/activities/newyear/redpacket/cellbg.png" )
	cellBg:setPosition( 0, 3 )
	cellBg:setOpacity(0)
    cellBg:setPosition( cellWidth*0.5, cellHeight*0.5 )
	cell:addChild( cellBg )
	-- 标题
	local title = XTHD.createLabel({
		anchor = cc.p( 0, 0.5 ),
		pos = cc.p( 38, cellBg:getContentSize().height - 45 ),
	})
	title:setColor(XTHD.resource.textColor.green_text)
	title:setFontSize(16)
	cell:addChild( title )
	cell._title = title
	-- 进度
	local progress = XTHD.createLabel({
		fontSize = 20,
		color    = cc.c3b( 103, 147, 18 ),
		anchor   = cc.p( 0.5, 0.5 ),
		pos      = cc.p( cellBg:getContentSize().width - 45, title:getPositionY() ),
	})
	cell:addChild( progress )
	cell._progress = progress

	-- 奖励容器
	local iconContainer = XTHD.createSprite()
	iconContainer:setContentSize( 450, 90 )
	iconContainer:setAnchorPoint( 0, 0 )
	iconContainer:setPosition( 10, 3 )
	cell:addChild( iconContainer )
	cell._iconContainer = iconContainer
	-- 领取按钮
	local fetchBtn = XTHD.createButton({
        normalFile = "res/image/activities/hdbtn/btn_gray_up.png",
        selectedFile = "res/image/activities/hdbtn/btn_gray_down.png",
        btnSize = cc.size(100,49),
		text = LANGUAGE_BTN_KEY.getTheRewards,
		fontSize = 26,
        anchor = cc.p( 0.5, 0.5 ),
	})
	fetchBtn:setPosition(cellBg:getContentSize().width - fetchBtn:getContentSize().width / 2 + 30,cellBg:getContentSize().height / 2 - 20)
	cell:addChild( fetchBtn )
	fetchBtn:setScale(0.7)
	local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
    fetchBtn:addChild( fetchSpine )
    fetchSpine:setScaleX( (fetchBtn:getContentSize().width + 5)/fetchBtn:getContentSize().width )
    fetchSpine:setScaleY( (fetchBtn:getContentSize().height- 5) /fetchBtn:getContentSize().height )
    fetchSpine:setPosition( fetchBtn:getBoundingBox().width*0.5 + 25, fetchBtn:getContentSize().height/2+2 )
	fetchSpine:setAnimation( 0, "querenjinjie", true )
	cell._fetchBtn = fetchBtn
	-- 未完成按钮
	-- local notFinishBtn = XTHD.createCommonButton({
	-- 	btnColor = "red",
 --        btnSize = cc.size(138,45),
 --        text = LANGUAGE_KEY_NOTREACHABLE,
 --        anchor = cc.p( 0.5, 0.5 ),
 --        pos = cc.p( fetchBtn:getPosition() ),
	-- })
	-- cell:addChild( notFinishBtn )
	-- cell._notFinishBtn = notFinishBtn
	-- 前往充值
	--ly3.26
	local gotoRechargeBtn = XTHD.createButton({
        normalFile = "res/image/activities/hdbtn/btn_gray_up.png",
        selectedFile = "res/image/activities/hdbtn/btn_gray_down.png",
		btnSize = cc.size( 100, 49 ),
        text = LANGUAGE_ACTIVITY_SINGLERECHARGE[2],
        anchor = cc.p( 0.5, 0.5 ),
		pos = cc.p( fetchBtn:getPosition() ),
		fontSize = 26,
        endCallback = function()
        	XTHD.createRechargeVipLayer( self )
        end
	})
	gotoRechargeBtn:setScale(0.7)
	cell:addChild( gotoRechargeBtn )
	cell._gotoRechargeBtn = gotoRechargeBtn
	-- 已领取奖励按钮
	local fetchedImageView = XTHD.createSprite( "res/image/vip/yilingqu.png" )
	fetchedImageView:setScale(0.7)
    fetchedImageView:setPosition( fetchBtn:getPosition() )
    cell:addChild( fetchedImageView )
    cell._fetchedImageView = fetchedImageView
end

function RedPacketLayer1:updateCell( cell, index )
    index = index + 1
	-- 数据
	local data = self._rechargeData[index]
	-- 标题
	cell._title:setString( LANGUAGE_TOTALRECHARGE_MONEY( data.yuanbao ) )
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
	        icon:setScale( 65/icon:getContentSize().width )
	        icon:setPosition( 75*( i - 0.5 ) + 20, cell._iconContainer:getContentSize().height*0.4 + 8 )
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
			self:fetchReward( data.yuanbao, iconData, index )
		end)
		-- cell._notFinishBtn:setVisible( false )
		cell._gotoRechargeBtn:setVisible( false )
		cell._fetchedImageView:setVisible( false)
	elseif data.state == 2 then
		-- 已领取
		cell._fetchBtn:setVisible( false )
		-- cell._notFinishBtn:setVisible( false )
		cell._gotoRechargeBtn:setVisible( false )
		cell._fetchedImageView:setVisible( true)
	else
		-- 不可领取
		cell._fetchBtn:setVisible( false )
		-- cell._notFinishBtn:setVisible( true )
		-- cell._notFinishBtn:setTouchEndedCallback(function()
		-- 	XTHDTOAST(LANGUAGE_TOTALRECHARGE_TEXT[4])
		-- end)
		cell._gotoRechargeBtn:setVisible( true )
		cell._fetchedImageView:setVisible( false)
	end
end
-- 领取奖励
function RedPacketLayer1:fetchReward( yuanbao, iconData, index )
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
function RedPacketLayer1:sortData( dataTable )
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
function RedPacketLayer1:refreshData()
	ClientHttp:requestAsyncInGameWithParams({
        modules="totalPayRewardList?",
        successCallback = function( backData )
            -- dump(backData,"初始化返回")
            if tonumber( backData.result ) == 0 then
            	if self._exist then
	            	self:initData( backData )
	            	self._tableView:reloadData()
	            end
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

function RedPacketLayer1:create(params)
    return self.new(params)
end

return RedPacketLayer1
