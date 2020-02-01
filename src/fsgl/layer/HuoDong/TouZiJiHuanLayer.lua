--[[
	投资计划
]]
local TouZiJiHuanLayer = class("TouZiJiHuanLayer", function(params)
    return XTHDSprite:createWithTexture(nil,cc.rect(0,0,839,420))
end)

function TouZiJiHuanLayer:ctor(params)
	self:setOpacity( 0 )
	self._exist = true
	-- ui
	self._size = self:getContentSize()
	self._leftWidth = 206

	self._investList = gameData.getDataFromCSV("InvestmentPlan")
	self._myRewardData = {}
	self._investIsBuy = params.httpData.isBuy   -- 是否购买
	self._rewardList = params.httpData.investReward or {} -- 领取等级列表

	for i = 1, #self._rewardList do
		for j = 1, #self._investList do
			local item = self._investList[j]
			if item["level"] == self._rewardList[i] then
				table.remove(self._investList, j)
				break
			end
		end
	end
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
function TouZiJiHuanLayer:onCleanup()
	self._exist = false
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_RECHARGE_MSG)
end

-- 创建界面
function TouZiJiHuanLayer:initUI()
	-- 背景
	local background = ccui.Scale9Sprite:create( "res/image/activities/activityRec_bg.png" )
	background:setContentSize(640,483)
	background:setAnchorPoint( cc.p( 1, 0.5 ) )
	background:setPosition( self._size.width + 34, self._size.height*0.5 - 18 )
	self:addChild( background )
	-- 小浣熊
	local smallRaccoon = XTHD.createSprite( "res/image/activities/InvestPlan/chatu.png" )
	smallRaccoon:setAnchorPoint(0.5,0.5)
	smallRaccoon:setPosition( 98, self:getContentSize().height/2 -18 )
	self:addChild( smallRaccoon )

	-- 活动标题
	local topBg = XTHD.createSprite( "res/image/activities/InvestPlan/chatu2.png" )
	topBg:setAnchorPoint(0, 0)
	topBg:setScaleX(1.2)
	topBg:setPosition( 1, background:getContentSize().height - 136 )
	background:addChild( topBg )

	-- 前去充值按钮
	self._rechargeBtn = XTHD.createButton({
		normalFile   = "res/image/activities/InvestPlan/buy_up.png",
		selectedFile = "res/image/activities/InvestPlan/buy_down.png",
		anchor       = cc.p(1,0),
		pos          = cc.p(topBg:getContentSize().width - 10,0)
	})

	self._rechargeBtn:setTouchEndedCallback(function()
		self._vip = gameUser.getVip()
		if self._vip < 3 then
			XTHDTOAST("VIP3以上才可以购买")
			return
		end
		
		local _dialog = XTHDConfirmDialog:createWithParams({
            msg = "确定购买投资计划？",
            rightCallback = function()
                ClientHttp:requestAsyncInGameWithParams({
				modules = "InvestPlanBuy?",
				successCallback = function( backData )
					-- dump(backData,"InvestPlanBuy net Data")
					if tonumber(backData.result) == 0 then
						-- 更新属性
						if backData.playerProperty then
							DBUpdateFunc:UpdateProperty( "userdata", backData.playerProperty[1], backData.playerProperty[2])
						end
						XTHDTOAST("购买成功")
						self._rechargeBtn:setClickable(false)
						self._investIsBuy = true
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
            end
        })
        self:addChild(_dialog)

	end)


	self._rechargeBtn:setPosition(topBg:getContentSize().width - 20, 20)
	topBg:addChild( self._rechargeBtn )

	-- 列表
	-- tableview
	local tableView = cc.TableView:create( cc.size( topBg:getContentSize().width + 120, self._size.height - topBg:getContentSize().height + 61 ) )
	tableView:setPosition( topBg:getPositionX() - 6, 1 )
	tableView:setBounceable( true )
	tableView:setDirection( cc.SCROLLVIEW_DIRECTION_VERTICAL )
	tableView:setDelegate()
	tableView:setVerticalFillOrder( cc.TABLEVIEW_FILL_TOPDOWN )
	background:addChild( tableView )
	self._tableView = tableView
	TableViewPlug.init(self._tableView)

	local cellWidth = topBg:getContentSize().width
	local cellHeight = 102

	self._tableView.getCellNumbers = function( table )
		return #self._investList
	end 
	
	self._tableView.getCellSize = function ( table, index )
		return  cellWidth,cellHeight
	end
	
	local function tableCellAtIndex( table, index )
        local cell = table:dequeueCell()
        if cell then
            cell:removeAllChildren()
        else
            cell = cc.TableViewCell:create()
			cell:setContentSize(cellWidth*1.22,cellHeight)
        end

		self:buildCell( cell, index, cellWidth, cellHeight )
    	return cell
    end
	tableView:registerScriptHandler( self._tableView.getCellNumbers, cc.NUMBER_OF_CELLS_IN_TABLEVIEW )
    tableView:registerScriptHandler( self._tableView.getCellSize, cc.TABLECELL_SIZE_FOR_INDEX )
    tableView:registerScriptHandler( tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX )
	
end

function TouZiJiHuanLayer:buildCell( cell, index, cellWidth, cellHeight )
	local data = self._investList[index + 1]
    -- cell背景
    local bg = XTHD.createSprite("res/image/activities/InvestPlan/cellBg.png")
    bg:setPosition( cellWidth*0.5+59, cellHeight*0.5 )
	bg:setScaleX(1.22)
	cell:addChild( bg )
	-- 等级图标
	local rewardIcon = XTHD.createSprite("res/image/activities/InvestPlan/"..data["level"]..".png")
	rewardIcon:setAnchorPoint( cc.p( 0, 1 ) )
	rewardIcon:setPosition( 0, bg:getContentSize().height - 5 )
	bg:addChild(rewardIcon )
	cell._rewardIcon = rewardIcon
	-- 奖励容器
	local container = XTHD.createSprite()
	container:setAnchorPoint( 0, 0 )
	container:setContentSize( 280, bg:getContentSize().height )
	container:setPosition( 150, 0 )
	container:setScaleX(0.8)
	bg:addChild( container )
	cell._container = container

	-- 领取奖励按钮
	--local btn_disable = ccui.Scale9Sprite:create( "res/image/vip/yilingqu.png" )
	--btn_disable:setContentSize( cc.size(105,47) )
	local lingquBtn = XTHD.createCommonButton({
		btnColor = "write",
		fontSize = 22,
		isScrollView = true,
		--btnSize = cc.size(200,47),
		--disableNode = btn_disable,
		text = LANGUAGE_BTN_KEY.getReward,
		anchor = cc.p( 1, 0.5 ),
		pos = cc.p( (bg:getContentSize().width - 25) *1.22, bg:getContentSize().height/2)
	})
	
	lingquBtn:setScaleX(0.7)
	lingquBtn:setScaleY(0.85)
	lingquBtn:setTouchEndedCallback(function()
		ClientHttp:requestAsyncInGameWithParams({
			modules = "InvestPlanReward?",
			params = {level = data["level"]},
			successCallback = function( backData )
				if tonumber(backData.result) == 0 then
					-- 更新属性
					local pro_data = nil
					if backData.property then
						pro_data = string.split( backData.property[1], ',' )
						DBUpdateFunc:UpdateProperty("userdata", pro_data[1], pro_data[2])
					end
					
					local showRewardData = {}
					local tmpData = {
						rewardtype = tonumber(data["type1"] ),
						id = tonumber(pro_data[1]),
						num = tonumber(data["num1"]),
						isLightAct = true,
					}
					showRewardData[#showRewardData + 1] = tmpData
					ShowRewardNode:create(showRewardData)
					self._rewardList = backData.investReward
					lingquBtn:setEnable(false)
					lingquBtn:setString(LANGUAGE_BTN_KEY.rewarded)
					lingquBtn:setVisible(true)
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
					
					table.remove(self._investList, index + 1)
					self._tableView:reloadDataAndScrollToCurrentCell()
					--self:refreshUI()
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
	end)

	cell:addChild(lingquBtn)
	cell._lingquBtn = lingquBtn

	local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
	lingquBtn:addChild(fetchSpine)
	fetchSpine:setScaleY(0.9)
	fetchSpine:setPosition(lingquBtn:getContentSize().width*0.5 + 2, lingquBtn:getContentSize().height*0.5+2)
	fetchSpine:setAnimation(0, "querenjinjie", true )	

	if tonumber( data["num1"] ) > 0 then
		local icon = ItemNode:createWithParams({
			_type_ = tonumber( data["type1"] ),
			itemId = tonumber( data["id1"] ),
			count = tonumber( data["num1"] ),
			isLightAct = true,
		})
		icon:setScale( 65/icon:getContentSize().width )
		icon:setPosition( 95*0.5, cell._container:getContentSize().height*0.5 )
		cell._container:addChild( icon )
	end

	-- 判断等级是否够领取
	self._level = gameUser.getLevel()
	if self._investIsBuy == true then
		if self._level < data["level"] then
			cell._lingquBtn:setEnable(false)
			cell._lingquBtn:setString("未达成")
			cell._lingquBtn:setLabelColor( XTHD.resource.btntextcolor["write"] )
			cell._lingquBtn:setVisible(true)
		else
			cell._lingquBtn:setEnable(true)
			cell._lingquBtn:setLabelColor( XTHD.resource.btntextcolor["write"] )
			cell._lingquBtn:setVisible(true)
		end
	end

	-- 判断是否已经领取
	local hasLingqu = false
	if self._level >= data["level"] then
		for i = 1, #self._rewardList do
			if data["level"] == self._rewardList[i] then
				hasLingqu = true
				break
			end
		end
	end

	if hasLingqu == true then
		cell._lingquBtn:setEnable(false)
		cell._lingquBtn:setString(LANGUAGE_BTN_KEY.rewarded)
		cell._lingquBtn:setVisible(true)
	end

end

function TouZiJiHuanLayer:createNonePromptLabel()
    if tonumber(#self._investList) < 1 then
        local _promptLabel = XTHDLabel:create(LANGUAGE_KEY_ACTIVITIES.levelRewardNoneTextXc,24)
        _promptLabel:setColor(cc.c4b(242,202,11,255))
        _promptLabel:setPosition(cc.p((self:getContentSize().width+305)/2,self:getContentSize().height/2 - 50))
        self:addChild(_promptLabel)
    end
end

function TouZiJiHuanLayer:refreshUI()
	-- 显示已经购买完了
	self:createNonePromptLabel()
	
	if not self._exist then
		return
	end

	-- 已经购买 则置为不可见
	if self._investIsBuy == true then
		self._rechargeBtn:setVisible(false)
	end
	
	-- gameUser.setActivityOpenStatusById(19, 0)
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
	XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息

	self._tableView:reloadData()
end

function TouZiJiHuanLayer:create(params)
    return self.new(params)
end

return TouZiJiHuanLayer
