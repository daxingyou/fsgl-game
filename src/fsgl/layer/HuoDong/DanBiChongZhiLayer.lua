--[[
	单笔充值活动
]]
local DanBiChongZhiLayer = class("DanBiChongZhiLayer", function(params)
    return XTHDSprite:createWithTexture(nil,cc.rect(0,0,839,420))
end)

function DanBiChongZhiLayer:ctor(params)
	self._exist = true
	-- dump( params, "DanBiChongZhiLayer ctor" )
	-- ui
	self:setOpacity( 0 )
	self._index = params.index or 1
	self._indexCell = nil
	self._size = self:getContentSize()
	self._leftWidth = 250
	self._rewardList = params.httpData.list or {{}}
	table.sort(self._rewardList, function( a, b )
		return a.configId < b.configId
	end)

	-- 开启时间
	self._openTime = {
		beginMonth = params.httpData.beginMonth or "",
		beginDay = params.httpData.beginDay or "",
		endMonth = params.httpData.endMonth or "",
		endDay = params.httpData.endDay or "",
	}

	-- 数据
	self._taskData = gameData.getDataFromCSV( "SingleCharging" )
	self._rewardData = {}

	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG ,callback = function()
		if self._exist then
        	self:refreshData()
        end
    end})

	self:initUI()
	self:refreshUI()

	LayerManager.layerOpen(1, self)
end
-- 
function DanBiChongZhiLayer:onCleanup()
	LayerManager.layerClose(1)
	self._exist = false
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_RECHARGE_MSG)
end

-- 创建界面
function DanBiChongZhiLayer:initUI()
	-- 背景
	-- local background = XTHD.createSprite( "res/image/activities/singlerecharge/background.png" )
	-- background:setPosition( self._size.width*0.5, self._size.height*0.5 )
	-- self:addChild( background )
	local background = ccui.Scale9Sprite:create( "res/image/activities/activityRec_bg.png" )
	background:setContentSize(640,483)
	background:setAnchorPoint( cc.p( 1, 0.5 ) )
	background:setPosition( self._size.width + 34, self._size.height*0.5 - 18 )
	self:addChild( background )
	-- 左边背景
	local leftBg = XTHD.createSprite()
	leftBg:setContentSize( self._leftWidth, self._size.height )
	leftBg:setAnchorPoint( cc.p( 0, 0.5 ) )
	leftBg:setPosition( 0, self._size.height*0.5 )
	self:addChild( leftBg )
	-- 小浣熊
	local smallRaccoon = XTHD.createSprite( "res/image/activities/singlerecharge/danbichongzhichatu.png" )
	smallRaccoon:setAnchorPoint(0.5, 0.5)
	smallRaccoon:setPosition( 98, self:getContentSize().height/2 -18 )
	leftBg:addChild( smallRaccoon )
	-- 活动时间标题
	local timeTitleLabel = XTHD.createLabel({
		text      = LANGUAGE_TOTALRECHARGE_TEXT[1].."：",
		fontSize  = 20,
		anchor    = cc.p( 0, 1 ),
		pos       = cc.p( 7, leftBg:getContentSize().height - 10 ),
		clickable = false,
	})
	timeTitleLabel:setOpacity(0)
	timeTitleLabel:enableShadow( cc.c3b(255, 255, 255), cc.size( 1, 0 ) )
	leftBg:addChild( timeTitleLabel )
	-- 活动时间
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
	-- leftBg:addChild( timeLabel )
	-- -- 活动规则标题
	-- local rulesTitleLabel = XTHD.createLabel({
	-- 	text      = LANGUAGE_ACTIVITY_PRIVILEGEAWARD[1],
	-- 	fontSize  = 20,
	-- 	anchor    = cc.p( 0, 1 ),
	-- 	pos       = cc.p( 7, timeLabel:getPositionY() - 30 ),
	-- 	clickable = false,
	-- })
	-- rulesTitleLabel:enableShadow( cc.c3b(255, 255, 255), cc.size( 1, 0 ) )
	-- leftBg:addChild( rulesTitleLabel )
	-- -- 活动规则
	-- local rulesLabel = XTHD.createLabel({
	-- 	text      = LANGUAGE_ACTIVITY_PRIVILEGEAWARD[3],--LANGUAGE_ACTIVITY_SINGLERECHARGE_TIP( self._taskData[3].charge or 0, self._taskData[2].charge or 0 ),
	-- 	fontSize  = 18,
	-- 	color     = cc.c3b( 229, 183, 47 ),
	-- 	anchor    = cc.p( 0, 1 ),
	-- 	pos       = cc.p( rulesTitleLabel:getPositionX(), rulesTitleLabel:getPositionY() - 30 ),
	-- 	clickable = false,
	-- })
	-- rulesLabel:setWidth( self._leftWidth - 15 )
	-- rulesLabel:enableShadow( cc.c3b( 229, 183, 47 ), cc.size( 1, 0 ) )
	-- leftBg:addChild( rulesLabel )
	-- 右边背景
	local rightBg = XTHD.createSprite()
	rightBg:setContentSize( self._size.width - self._leftWidth + 50, self._size.height )
	rightBg:setAnchorPoint( cc.p( 1, 0.5 ) )
	rightBg:setPosition( self._size.width + 35, self._size.height*0.5 - 15)
	self:addChild( rightBg )

	-- 右边底部粉色
	local pink = ccui.Scale9Sprite:create( cc.rect( 25, 25, 2, 2 ), "res/image/activities/singlerecharge/pink.png" )
	pink:setContentSize( rightBg:getContentSize().width, 125 )
	pink:setAnchorPoint( cc.p( 0, 0 ) )
	rightBg:addChild( pink )
	pink:setOpacity(0)
	local pink1 = ccui.Scale9Sprite:create("res/image/activities/singlerecharge/pink1.png" )
	pink1:setContentSize(self._size.width - self._leftWidth + 30,441-125)
	pink1:setAnchorPoint(0.5,1)
	pink1:setPosition(rightBg:getContentSize().width/2,rightBg:getContentSize().height + 15)
	rightBg:addChild(pink1)
	
	-- tableview
	local tableView = cc.TableView:create( cc.size( self._size.width - self._leftWidth + 30, 330 ) )
	tableView:setPosition( 11, 105 )
	tableView:setBounceable( true )
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_HORIZONTAL )
	tableView:setDelegate()
	rightBg:addChild( tableView )

	cellWidth = ( self._size.width - self._leftWidth - 10 )/2.5
	cellHeight = 340
	local function numberOfCellsInTableView( table )
		return #self._rewardList
	end
	local function cellSizeForTable( table, index )
		return cellWidth, cellHeight
	end
	local function tableCellAtIndex( table, index )
		local cell = table:dequeueCell()
		index = index + 1
        if cell then
        	cell:removeAllChildren()
        else
            cell = cc.TableViewCell:new()
        end
        -- 宝匣
		local StoredValue = XTHD.createButton({
			normalFile = "res/image/activities/singlerecharge/diban.png",
			needEnableWhenMoving = false,
			needSwallow = false,
		})
		StoredValue:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		StoredValue:setPosition( cc.p( cellWidth/2, cellHeight/2 ) )
		cell:addChild( StoredValue )
		cell._recharge = StoredValue
		--名字 
		local name = XTHD.createSprite("res/image/activities/singlerecharge/label" ..  index .. ".png")
		name:setPosition(StoredValue:getContentSize().width/2,StoredValue:getContentSize().height-20)
		name:setAnchorPoint(0.5,1)
		name:setScale(0.8)
		StoredValue:addChild(name)
		--图标
		local logo = XTHD.createSprite("res/image/activities/singlerecharge/" ..  index .. ".png")
		logo:setPosition(StoredValue:getContentSize().width/2,StoredValue:getContentSize().height/2)
		logo:setScale(0.8)
		StoredValue:addChild(logo)
		-- 充值数量
		local singleRechargeLabel = XTHD.createLabel({
			text      = LANGUAGE_ACTIVITY_SINGLERECHARGE[1],
			fontSize  = 22,
			color     = cc.c3b( 254,254,139),
			anchor    = cc.p( 1, 0 ),
			pos = cc.p( 120, 25 ),
			clickable = false
		})
		local singleRechargeNum = XTHD.createLabel({
			text      = LANGUAGE_ACTIVITY_SINGLERECHARGE_PRICE( self._taskData[index].charge or 0 ),
			fontSize  = 22,
			color     = cc.c3b(  254,254,139 ),
			anchor    = cc.p( 0, 0 ),
			pos = cc.p( 120, 25 ),
			clickable = false
		})
		StoredValue:addChild( singleRechargeLabel )
		StoredValue:addChild( singleRechargeNum )
		cell._singleRechargeNum = singleRechargeNum
		-- 选中框
		local selected = XTHD.createSprite()
		selected:setPosition( StoredValue:getPositionX(), StoredValue:getPositionY() - 7 )
		cell:addChild( selected )
		cell._selected = selected
		if self._index == index then
			selected:setVisible( true )
			self._indexCell = cell
			local selectedAnimation = getAnimation( "res/image/activities/singlerecharge/xz/bk_0", 1, 4, 0.1 )
			selected:runAction( cc.RepeatForever:create( selectedAnimation ) )
		else
			selected:setVisible( false )
			selected:stopAllActions()
		end
		StoredValue:setTouchEndedCallback(function()
			if self._index ~= index then
				if self._indexCell then
					self._indexCell._selected:setVisible( false )
					self._indexCell._selected:stopAllActions()
				end
				selected:setVisible( true )
				local selectedAnimation = getAnimation( "res/image/activities/singlerecharge/xz/bk_0", 1, 4, 0.1 )
				selected:runAction( cc.RepeatForever:create( selectedAnimation ) )
				self._index = index
				self._indexCell = cell
				self:refreshUI()
			end
		end)

        return cell
	end
	tableView:registerScriptHandler( numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    tableView:registerScriptHandler( cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX )
    tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
    tableView:reloadData()

	-- 右边底部奖励icon
	self._icons = XTHD.createSprite()
	self._icons:setContentSize( rightBg:getContentSize().width - 130 - 10, 100 )
	self._icons:setAnchorPoint( cc.p( 0, 0 ) )
	self._icons:setPosition( 5, -10 )
	rightBg:addChild( self._icons )
	self:createIcons()
	-- 右边底部领取文字
	self._fetchLabel = XTHD.createLabel({
		fontSize  = 20,
		color     = cc.c3b( 70, 34, 34 ),
		anchor    = cc.p( 0.5, 0.5 ),
		pos       = cc.p( pink:getContentSize().width - 65, 85 ),
		clickable = false,
	})
	self._fetchLabel:setVisible(false)
	pink:addChild( self._fetchLabel )
	-- 右边底部领取按钮
	local fetchBtn_disable = ccui.Scale9Sprite:create( "res/image/common/btn/btn_gray_down.png" )
	fetchBtn_disable:setContentSize( cc.size( 125, 49 ) )
	self._fetchBtn = XTHD.createCommonButton({
		btnColor = "write",
		isScrollView = false,
		btnSize = cc.size( 108, 49 ),
		btnDisable = true,
		text = LANGUAGE_KEY_GET,
		fontSize = 26,
		disableNode = fetchBtn_disable,
		endCallback = function()
			ClientHttp:requestAsyncInGameWithParams({
				modules = "singlePayReward?",
				params = {configId = self._index},
		        successCallback = function( backData )
		        	-- dump(backData,"单笔充值界面领取数据")
		            if tonumber(backData.result) == 0 then
						self._rewardList[backData.configId].curCount = backData.curCount
						self._rewardList[backData.configId].isGet = self._rewardList[backData.configId].isGet - 1
			            self:refreshUI()
			            ShowRewardNode:create( self._rewardData )
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
		            else
		                XTHDTOAST(backData.msg)
		            end 
		        end,
		        failedCallback = function()
		            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
		        end,--失败回调
				loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
				loadingParent = self,
			})
		end,
	})
	self._fetchBtn:setScale(0.7)
	self._fetchBtn:setPosition( pink:getContentSize().width - 65, pink:getPositionY() + 35 )
	local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
	self._fetchBtn:addChild(fetchSpine)
	fetchSpine:setPosition(self._fetchBtn:getContentSize().width*0.5 + 2, self._fetchBtn:getContentSize().height*0.5+2)
	fetchSpine:setAnimation(0, "querenjinjie", true )
	rightBg:addChild( self._fetchBtn )
	--前往充值按钮
	local rechargeBtn_disable = ccui.Scale9Sprite:create( "res/image/common/btn/btn_gray_down.png" )
	rechargeBtn_disable:setContentSize( cc.size( leftBg:getContentSize().width - 20, 49 ) )
	self._rechargeBtn = XTHD.createButton({
        normalFile = "res/image/activities/hdbtn/btn_buy_up.png",
        selectedFile = "res/image/activities/hdbtn/btn_buy_down.png",
		btnSize = cc.size( leftBg:getContentSize().width - 20, 49 ),
		btnDisable = true,
		disableNode = rechargeBtn_disable,
		endCallback = function()
			XTHD.createRechargeVipLayer( self )
		end
	})
	self._rechargeBtn:setScale(0.7)
	-- self._rechargeBtn:getLabel():setPositionX(self._rechargeBtn:getLabel():getPositionX()-18)
	-- self._rechargeBtn:getLabel():setPositionY(self._rechargeBtn:getLabel():getPositionY()-10)
	rightBg:addChild(self._rechargeBtn)
	self._rechargeBtn:setPosition( pink:getContentSize().width - 65, pink:getPositionY() + 35)
end
-- 创建奖励icons
function DanBiChongZhiLayer:createIcons()
	local oriData = self._taskData[self._index]
	local dstData = {}
	self._rewardData = {}
	for i = 1, 5 do
		if oriData["item"..i.."type"] then
			if oriData["item"..i.."type"] == 4 then
				local isLightAct = ( gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = oriData["item"..i.."ID"]} ).rank or 0 ) > 3
				self._rewardData[#self._rewardData + 1] = {
					rewardtype = oriData["item"..i.."type"],
	                id = oriData["item"..i.."ID"],
	                num = oriData["item"..i.."num"],
	                isLightAct = true,
				}
				dstData[#dstData + 1] = {
					_type_ = oriData["item"..i.."type"],
	                itemId = oriData["item"..i.."ID"],
	                count = oriData["item"..i.."num"],
	                isLightAct = true,
				}
			else
				self._rewardData[#self._rewardData + 1] = {
					rewardtype = oriData["item"..i.."type"],
	                num = oriData["item"..i.."num"],
	                isLightAct = true,
				}
				dstData[#dstData + 1] = {
					_type_ = oriData["item"..i.."type"],
	                count = oriData["item"..i.."num"],
	                isLightAct = true,
				}
			end
		end
	end
	local iconWidth = self._icons:getContentSize().width/(#dstData)
	for i, v in ipairs( dstData ) do
		local iconBg = XTHD.createSprite( "res/image/activities/singlerecharge/iconbg.png" )
		iconBg:setPosition( iconWidth*i - iconWidth*0.5, self._icons:getContentSize().height*0.5 )
		self._icons:addChild( iconBg )
		local icon = XTHD.createItemNode( v )
		icon:setScale(0.6)
		icon:setPosition( iconBg:getPosition() )
		self._icons:addChild( icon )
	end
end
-- 重新请求数据，刷新界面
function DanBiChongZhiLayer:refreshData()
 	ClientHttp:requestAsyncInGameWithParams({
		modules = "singlePayRewardList?",
        successCallback = function( data )
        	-- dump(data,"单笔充值界面刷新数据")
            if tonumber(data.result) == 0 then
				if self._exist then
					self._rewardList = data.list
	            	self:refreshUI()
	            end
            else
                XTHDTOAST(data.msg)
            end 
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
		loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
		loadingParent = self,
	})
end

function DanBiChongZhiLayer:refreshUI()
	self._icons:removeAllChildren()
	self:createIcons()
	local data = self._rewardList[self._index] or {}
	self._fetchLabel:setString( ( data.curCount or 0 ).."/"..( data.maxCount or 0 ) )

	local fetchSpine = self._fetchBtn:getChildByName("fetchSpine")
	--print("data.curCount: "..data.curCount)
	-- for k,v in pairs(data) do
	-- 	print("k "..k.." v "..v)
	-- end
	if data.isGet >= 1 then 
		--首先检查是否已经存在动画 存在则不操作 否则新增
		self._fetchBtn:setVisible(true)
		self._rechargeBtn:setVisible(false)
		-- if fetchSpine == nil then
		-- 	fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
		-- 	fetchSpine:setName("fetchSpine")
		-- 	self._fetchBtn:addChild( fetchSpine )
		-- 	fetchSpine:setScaleX((self._fetchBtn:getContentSize().width + 5)/self._fetchBtn:getContentSize().width)
		-- 	fetchSpine:setScaleY((self._fetchBtn:getContentSize().height)/self._fetchBtn:getContentSize().height)
		-- 	fetchSpine:setPosition( self._fetchBtn:getBoundingBox().width*0.5+25, self._fetchBtn:getContentSize().height/2 +2)
		-- 	fetchSpine:setAnimation( 0, "querenjinjie", true )
		-- end
	elseif data.isGet <= 0  then
		self._fetchBtn:setVisible(false)
		self._rechargeBtn:setVisible(true)
		-- fetchSpine:removeAllChildren()
		-- fetchSpine:removeFromParent()
		-- fetchSpine = nil
	end
end

function DanBiChongZhiLayer:create(params)
    return self.new(params)
end

return DanBiChongZhiLayer
