--[[
	vip每日奖励活动
	LayerName: Vip工资
]]
local VipGongZiLayer = class("VipGongZiLayer", function(params)
    return XTHDSprite:createWithTexture(nil,cc.rect(0,0,839,420))
end)

function VipGongZiLayer:ctor(params)
	self:setOpacity( 0 )
	self._exist = true
	-- ui
	self._size = self:getContentSize()
	self._leftWidth = 250

	self._rewardList = gameData.getDataFromCSV( "VipSalary" )
	-- dump( self._rewardList, "self._rewardList")
	self._myRewardData = {}

	-- 添加监听事件
	XTHD.addEventListener({name = CUSTOM_EVENT.REFRESH_RECHARGE_MSG,callback = function()
		if self._exist then
        	self:refreshUI()
        end
    end})

	self:initUI()
	self:refreshUI()
end
-- 
function VipGongZiLayer:onCleanup()
	self._exist = false
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_RECHARGE_MSG)
end

-- 创建界面
function VipGongZiLayer:initUI()
	-- 背景
	local background = ccui.Scale9Sprite:create( "res/image/activities/activityRec_bg.png" )
	background:setContentSize(640,483)
	background:setAnchorPoint( cc.p( 1, 0.5 ) )
	background:setPosition( self._size.width + 34, self._size.height*0.5 - 18 )
	self:addChild( background )
	-- 小浣熊
	local smallRaccoon = XTHD.createSprite( "res/image/activities/vipDailyReward/chatu.png" )
	smallRaccoon:setAnchorPoint(0.5,0.5)
	smallRaccoon:setPosition( 98, self:getContentSize().height/2 -18 )
	self:addChild( smallRaccoon )
	-- -- 活动规则标题
	-- local rulesTitleLabel = XTHD.createLabel({
		-- text      = LANGUAGE_ACTIVITY_PRIVILEGEAWARD[1],
	-- 	fontSize  = 20,
	-- 	anchor    = cc.p( 0, 1 ),
	-- 	pos       = cc.p( 7, background:getContentSize().height - 10 ),
	-- 	clickable = false,
	-- })
	-- rulesTitleLabel:enableShadow( cc.c3b(255, 255, 255), cc.size( 1, 0 ) )
	-- background:addChild( rulesTitleLabel )
	-- -- 活动规则
	-- local rulesLabel = XTHD.createLabel({
	-- 	text      = LANGUAGE_ACTIVITIES_VIPDAILYREWARDRULES,
	-- 	fontSize  = 18,
	-- 	color     = cc.c3b( 229, 183, 47 ),
	-- 	anchor    = cc.p( 0, 1 ),
	-- 	pos       = cc.p( rulesTitleLabel:getPositionX(), rulesTitleLabel:getPositionY() - 30 ),
	-- 	clickable = false,
	-- })
	-- rulesLabel:setWidth( self._leftWidth - 15 )
	-- rulesLabel:enableShadow( cc.c3b( 229, 183, 47 ), cc.size( 1, 0 ) )
	-- background:addChild( rulesLabel )
	-- 活动规则图片
	-- local rulesImage = XTHD.createSprite( "res/image/activities/vipDailyReward/rules.png" )
	-- rulesImage:setPosition( self._leftWidth*0.5, self._size.height*0.5 + 30 )
	-- background:addChild( rulesImage )


	-- 顶部
	local topBg = ccui.Scale9Sprite:create("res/image/activities/vipDailyReward/topBg.png" )
	topBg:setAnchorPoint( 0, 0 )
	topBg:setContentSize( self._size.width - self._leftWidth +51, 132 )
	topBg:setPosition( 0, background:getContentSize().height - 134 )
	background:addChild( topBg )
	-- 你当前可领取奖励
	local myRewardText = XTHD.createLabel({
		fontSize  = 18,
		color     = cc.c3b( 147, 30, 3 ),
		anchor    = cc.p( 0, 1 ),
		pos       = cc.p( 10, topBg:getContentSize().height - 9 ),
		clickable = false,
	})
	topBg:addChild( myRewardText )
	self._myRewardText = myRewardText
	-- 奖励们
	myRewardContainer = XTHD.createSprite()
	myRewardContainer:setAnchorPoint( 0, 0 )
	myRewardContainer:setContentSize( 425, 100 )
	myRewardContainer:setPosition( 0, 5 )
	topBg:addChild( myRewardContainer )
	self._myRewardContainer = myRewardContainer
	-- 领取奖励按钮
	local btn_disable = ccui.Scale9Sprite:create( "res/image/common/btn/btn_write_1_disable.png" )
	btn_disable:setContentSize( cc.size( 163, 69 ) )
	self._fetchBtn = XTHD.createCommonButton({
		btnColor = "write",
		fontSize = 26,
        btnSize = cc.size(105,47),
		disableNode = btn_disable,
		isScrollView = false,
        text = LANGUAGE_BTN_KEY.getReward,
		anchor = cc.p( 1, 0.5 ),
        pos = cc.p( topBg:getContentSize().width - 10, 55 ),
		endCallback = function()
			ClientHttp:requestAsyncInGameWithParams({
				modules = "vipDayReward?",
		        successCallback = function( backData )
		        	-- dump(backData,"vip工资领取数据")
		            if tonumber(backData.result) == 0 then
			            ShowRewardNode:create( self._myRewardData )
			            -- 更新属性
				    	if backData.property and #backData.property > 0 then
			                for i=1, #backData.property do
			                    local pro_data = string.split( backData.property[i], ',' )
			                    DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
			                end
			                XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
			            end
			            -- 更新背包
			            if backData.items and #backData.items ~= 0 then
			                for i=1, #backData.items do
			                    local item_data = backData.items[i]
			                    if item_data.count and tonumber( item_data.count ) ~= 0 then
			                        DBTableItem.updateCount( gameUser.getUserId(), item_data, item_data.dbId )
			                    else
			                        DBTableItem.deleteData( gameUser.getUserId(), item_data.dbId )
			                    end
			                end
			            end
			            gameUser.setActivityStatusById( 8, 0 )
			            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_ACTIVITIESTAB_REDPOINT})
			            self:refreshUI()
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
	topBg:addChild( self._fetchBtn )
	-- 已领取
	self._fetchedImageView = XTHD.createSprite( "res/image/vip/yilingqu.png" )
	self._fetchedImageView:setScale(0.8)
    self._fetchedImageView:setPosition( topBg:getContentSize().width - 62, 55 )
	topBg:addChild( self._fetchedImageView )

	local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
	self._fetchBtn:addChild(fetchSpine)
	fetchSpine:setScaleY(0.8)
	fetchSpine:setPosition(self._fetchBtn:getBoundingBox().width*0.5 + 27, self._fetchBtn:getContentSize().height*0.5+2)
	fetchSpine:setAnimation(0, "querenjinjie", true )	
	self._fetchSpine = fetchSpine
	-- 列表
	-- tableview
	local tableView = CCTableView:create( cc.size( topBg:getContentSize().width, self._size.height - topBg:getContentSize().height + 60 ) )
	tableView:setPosition( topBg:getPositionX(), 1 )
	tableView:setBounceable( true )
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	tableView:setDelegate()
	tableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	background:addChild( tableView )
	self._tableView = tableView

	local cellWidth = topBg:getContentSize().width
	local cellHeight = 102

	local function numberOfCellsInTableView( table )
		local vipNum = 12
		if self._vip and self._vip > 11 then
			vipNum = self._vip + 1
		end
		vipNum = vipNum > #self._rewardList and #self._rewardList or vipNum
		return vipNum
	end
	local function cellSizeForTable( table, index )
		return cellWidth,cellHeight
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
end

function VipGongZiLayer:buildCell( cell, index, cellWidth, cellHeight )
    -- cell背景
    local bg = XTHD.createSprite( "res/image/activities/vipDailyReward/cellBg.png" )
	bg:setContentSize(cellWidth,bg:getContentSize().height)
    bg:setPosition( cellWidth*0.5, cellHeight*0.5 )
	cell:addChild( bg )
	-- 每日奖励
	local rewardIcon = XTHD.createSprite( "res/image/activities/vipDailyReward/rewardIcon.png" )
	rewardIcon:setAnchorPoint( cc.p( 0, 1 ) )
	rewardIcon:setPosition( 0, bg:getContentSize().height - 5 )
	bg:addChild( rewardIcon )
	-- vip
	local rewardText = XTHD.createLabel({
		fontSize  = 18,
		color     = cc.c3b( 85, 10, 10 ),
		anchor    = cc.p( 1, 0.5 ),
		pos       = cc.p( 41, rewardIcon:getContentSize().height*0.5 + 6 ),
		clickable = false,
	})
	rewardIcon:addChild( rewardText )
	cell._rewardText = rewardText
	-- 奖励容器
	local container = XTHD.createSprite()
	container:setAnchorPoint( 0, 0 )
	container:setContentSize( 280, bg:getContentSize().height )
	container:setPosition( 150, 0 )
--	container:setScaleX(0.8)
	bg:addChild( container )
	cell._container = container
	if gameUser.getVip() == index + 1 then
		local icon = cc.Sprite:create("res/image/vip/vipl_0" .. gameUser.getVip() .. ".png") 
		icon:setScale(0.5)
		container:addChild(icon)
		icon:setPosition(container:getContentSize().width + 130,container:getContentSize().height/2)
	end
	
end

function VipGongZiLayer:updateCell( cell, index )
	local data = self._rewardList[index + 1]
	cell._rewardText:setString( VIPLABEL[data.VIP+1] )
	cell._container:removeAllChildren()
	local i = 1
	while data["rewardtype"..i] do
		local tmp = string.split( data["canshu"..i], "#" )
		if #tmp > 1 and tonumber( tmp[2] ) > 0 then
			local icon = ItemNode:createWithParams({
	            _type_ = tonumber( data["rewardtype"..i] ),
	            itemId = tonumber( tmp[1] ),
	            count = tonumber( tmp[2] ),
                isLightAct = true,
	        })
	        icon:setScale( 65/icon:getContentSize().width )
	        icon:setPosition( 90*( i - 0.5 ), cell._container:getContentSize().height*0.5 )
	        cell._container:addChild( icon )
		end
		i = i + 1
	end
	if gameUser.getVip() == index + 1 then
		local icon = cc.Sprite:create("res/image/vip/vipl_0" .. gameUser.getVip() .. ".png") 
		icon:setScale(0.5)
		cell._container:addChild(icon)
		icon:setPosition(cell._container:getContentSize().width + 130,cell._container:getContentSize().height/2)
	end
end

function VipGongZiLayer:refreshUI()
	if not self._exist then
		return
	end
	self._fetchable = false
	if gameUser.getActivibyStatus()[8] and gameUser.getActivibyStatus()[8] == 1 then
		self._fetchable = true
	end
	self._vip = gameUser.getVip()
	-- print("@@@@@@@VIP" .. self._vip)
	if self._vip == 0 then
		self._myRewardText:setString( LANGUAGE_ACTIVITIES_VIPDAILYREWARDTEXT(self._vip))
	else
		self._myRewardText:setString( LANGUAGE_ACTIVITIES_VIPDAILYREWARDTEXT( VIPLABEL[self._vip+1]))
	end
	
	-- 奖励
	self._myRewardContainer:removeAllChildren()
	self._myRewardData = {}
	local myRewardList = {}
	local myVip = self._vip > 0 and self._vip or 1
	for i, v in ipairs( self._rewardList ) do
		if v.VIP == myVip then
			myRewardList = v
			break
		end
	end
	local i = 1
	while myRewardList["rewardtype"..i] do
		local tmp = string.split( myRewardList["canshu"..i], "#" )
		if #tmp > 1 and tonumber( tmp[2] ) > 0 then
			local tmpData = {
				rewardtype = tonumber( myRewardList["rewardtype"..i] ),
	            id = tonumber( tmp[1] ),
	            num = tonumber( tmp[2] ),
                isLightAct = true,
			}
	        self._myRewardData[#self._myRewardData + 1] = tmpData
		end
		i = i + 1
	end
	local rewardNum = #self._myRewardData
	local posX = self._myRewardContainer:getContentSize().width / ( rewardNum + 0.5 )
	local posY = self._myRewardContainer:getContentSize().height*0.5
	for i, v in ipairs( self._myRewardData ) do
		local rewardBg = XTHD.createSprite( "res/image/activities/firstrecharge/iconBg.png" )
		rewardBg:setPosition( posX*( i - 0.25 ), posY )
		self._myRewardContainer:addChild( rewardBg )
		-- 奖励
		local reward = ItemNode:createWithParams({
            _type_ = v.rewardtype,
            itemId = v.id,
            count = v.num,
		})
		reward:setScale(0.8)
        getCompositeNodeWithNode( rewardBg, reward )
        local sp = XTHD.createSprite("res/image/vip/effect/effect1.png")
        reward:addChild(sp)
        sp:setPosition(reward:getContentSize().width/2-1,reward:getContentSize().height/2 + 2)
        local xingxing_effect = getAnimation("res/image/vip/effect/effect",1,8,1/10) --点击
        sp:setScale(0.9)
        sp:runAction(cc.RepeatForever:create(xingxing_effect))
        rewardBg:setScale( 0.9 )
	end
	-- 领取按钮
	if self._vip == 0 then
		self._fetchBtn:setEnable( false )
		self._fetchBtn:setVisible( false )
		self._fetchedImageView:setVisible( false )
	elseif self._fetchable then
		self._fetchBtn:setEnable( true )
		self._fetchBtn:setVisible( true )
		self._fetchedImageView:setVisible( false )
	else
		self._fetchBtn:setVisible( false )
		self._fetchedImageView:setVisible( true )
	end

	self._tableView:reloadData()
end

function VipGongZiLayer:create(params)
    return self.new(params)
end

return VipGongZiLayer
