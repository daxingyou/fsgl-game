--[[
	首充活动
    唐实聪
    2015.12.28
]]
local ShouCiChongZhiLayer = class("ShouCiChongZhiLayer", function(params)
    return XTHDSprite:createWithTexture(nil,cc.rect(0,0,793,441))
end)

function ShouCiChongZhiLayer:ctor(params)
	self:setOpacity( 0 )
	self._exist = true
	-- dump( params, "ShouCiChongZhiLayer ctor" )
	-- ui
	self._size = self:getContentSize()
	self._leftWidth = 250
	-- 数据
	self._rewardList = {}
	local rewardList = gameData.getDataFromCSV( "FirstTime" )[1]
	-- dump( rewardList, "rewardList")
	local i = 1
	while rewardList["rewardtype"..i] do
		if rewardList["rewardnum"..i] > 0 then
			self._rewardList[#self._rewardList + 1] = {
				rewardtype = rewardList["rewardtype"..i],
	            id = rewardList["rewardID"..i],
	            num = rewardList["rewardnum"..i],
			}
		end
		i = i + 1
	end
	-- dump( self._rewardList, "self._rewardList")

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
function ShouCiChongZhiLayer:onCleanup()
	self._exist = false
	XTHD.removeEventListener(CUSTOM_EVENT.REFRESH_RECHARGE_MSG)
end

-- 创建界面
function ShouCiChongZhiLayer:initUI()
	-- 背景
	-- local background = XTHD.createSprite( "res/image/activities/activityRec_bg.png" )
	local background = ccui.Scale9Sprite:create( "res/image/activities/activityRec_bg.png" )
	background:setContentSize(534,441)
	background:setAnchorPoint( cc.p( 1, 0.5 ) )
	background:setPosition( self._size.width, self._size.height*0.5 )
	-- background:setOpacity(0)
	self:addChild( background )
	-- 小浣熊
	local smallRaccoon = XTHD.createSprite( "res/image/activities/shouchongjianglichatu.png" )
	smallRaccoon:setAnchorPoint(0,0.5)
	smallRaccoon:setPosition( 0, self:getContentSize().height/2 )
	self:addChild( smallRaccoon )
	smallRaccoon:setScaleX(0.71)
	smallRaccoon:setScaleY(0.75)
	-- -- 活动规则标题
	-- local rulesTitleLabel = XTHD.createLabel({
	-- 	text      = LANGUAGE_ACTIVITY_PRIVILEGEAWARD[1],
	-- 	fontSize  = 20,
	-- 	anchor    = cc.p( 0, 1 ),
	-- 	pos       = cc.p( 7, background:getContentSize().height - 10 ),
	-- 	clickable = false,
	-- })
	-- rulesTitleLabel:enableShadow( cc.c3b(255, 255, 255), cc.size( 1, 0 ) )
	-- background:addChild( rulesTitleLabel )
	-- -- 活动规则
	-- local rulesLabel = XTHD.createLabel({
	-- 	text      = LANGUAGE_ACTIVITIES_FIRSTRECHARGERULES,
	-- 	fontSize  = 18,
	-- 	color     = cc.c3b( 229, 183, 47 ),
	-- 	anchor    = cc.p( 0, 1 ),
	-- 	pos       = cc.p( rulesTitleLabel:getPositionX(), rulesTitleLabel:getPositionY() - 30 ),
	-- 	clickable = false,
	-- })
	-- rulesLabel:setWidth( self._leftWidth - 15 )
	-- rulesLabel:enableShadow( cc.c3b( 229, 183, 47 ), cc.size( 1, 0 ) )
	-- background:addChild( rulesLabel )
	-- 标题
	local title = XTHD.createSprite( "res/image/activities/firstrecharge/title.png" )
	-- title:setPosition( ( self._size.width + self._leftWidth )*0.5, ( self._size.height + 214 )*0.5 )
	title:setAnchorPoint(0.5,1)
	title:setPosition( background:getContentSize().width/2-20,background:getContentSize().height-20)
	title:setScale(0.65)
	background:addChild( title )
	--标题的两个空
	--程咬金
	local cyj = XTHD.createSprite( "res/image/activities/firstrecharge/cyj.png" )
	cyj:setAnchorPoint(1,0)
	-- cyj:setScale(0.8)
	cyj:setPosition(title:getContentSize().width+60,0)
	title:addChild(cyj)
	--VIP
	local gz = XTHD.createSprite( "res/image/activities/firstrecharge/gz.png" )
	gz:setAnchorPoint(0.5,0.5)
	gz:setPosition(title:getContentSize().width/2-120,title:getContentSize().height/2-10)
	title:addChild(gz)

	-- 奖励们
	-- icon间隔
	local dis = 13
	-- 奖励数量
	local rewardNum = #self._rewardList
	-- icon宽度
	local iconWidth = 90
	local iconsBg = ccui.Scale9Sprite:create("res/image/activities/firstrecharge/iconsBg.png" )
	iconsBg:setContentSize( ( iconWidth + dis )*5 + 10, 125 )
	-- icon左边间隔
	local leftDis = ( self._size.width - self._leftWidth - iconsBg:getContentSize().width )*0.5
	iconsBg:setPosition( background:getContentSize().width/2, 155 )
	background:addChild( iconsBg )
	for i, v in ipairs( self._rewardList ) do
		local posX = leftDis + ( iconWidth + dis )*( i - 0.5 ) + 5
		local rewardBg = XTHD.createSprite( "res/image/activities/firstrecharge/iconBg.png" )
		rewardBg:setPosition( posX, iconsBg:getContentSize().height/2 )
		iconsBg:addChild( rewardBg )
		-- 奖励
		local reward = ItemNode:createWithParams({
            _type_ = v.rewardtype,
            itemId = v.id,
            count = v.num,
		})
		reward:setScale(0.9)
        getCompositeNodeWithNode( rewardBg, reward )
        local sp = XTHD.createSprite("res/image/vip/effect/effect1.png")
        reward:addChild(sp)
        sp:setPosition(reward:getContentSize().width/2-1,reward:getContentSize().height/2 + 2)
        local xingxing_effect = getAnimation("res/image/vip/effect/effect",1,8,1/10) --点击
        sp:setScale(0.9)
        sp:runAction(cc.RepeatForever:create(xingxing_effect))
        rewardBg:setScale( 0.9 )
	end
	-- 前去充值按钮
	self._rechargeBtn = XTHD.createButton({
		normalFile = "res/image/activities/firstrecharge/recharge_up.png",
		selectedFile = "res/image/activities/firstrecharge/recharge_down.png",
		endCallback = function()
			XTHD.createRechargeVipLayer( self )
		end
	})
	self._rechargeBtn:setScale(0.8)
	self._rechargeBtn:setPosition( background:getContentSize().width*0.5, 45 )
	background:addChild( self._rechargeBtn )
	-- 领取奖励按钮
	self._fetchBtn = XTHD.createButton({
		normalFile = "res/image/activities/firstrecharge/fetch_up.png",
		selectedFile = "res/image/activities/firstrecharge/fetch_down.png",
		endCallback = function()
			ClientHttp:requestAsyncInGameWithParams({
				modules = "fristPayReward?",
		        successCallback = function( backData )
		        	-- dump(backData,"首充界面领取数据")
		            if tonumber(backData.result) == 0 then
			            ShowRewardNode:create( self._rewardList )
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
			            -- 更新英雄
			            if backData.addPets then
			            	gameData.saveDataToDB(backData.addPets,1)
			            end
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
	self._fetchBtn:setScale(0.8)
	self._fetchBtn:setPosition( background:getContentSize().width*0.5, 45 )
	background:addChild( self._fetchBtn )
	-- 已领取
	self._fetchedImageView = XTHD.createSprite( "res/image/vip/yilingqu.png" )
	self._fetchedImageView:setScale(0.8)
    self._fetchedImageView:setPosition( background:getContentSize().width*0.5, 45 )
	background:addChild( self._fetchedImageView )
end

function ShouCiChongZhiLayer:refreshUI()
	if not self._exist then
		return
	end
	self._state = gameUser.getFirstPayState()
	if self._state == 0 then
		self._fetchBtn:setVisible( false )
		self._rechargeBtn:setVisible( true )
		self._fetchedImageView:setVisible( false )
	elseif self._state == 1 then
		self._fetchBtn:setVisible( true )
		self._rechargeBtn:setVisible( false )
		self._fetchedImageView:setVisible( false )
	else
		self._fetchBtn:setVisible( false )
		self._rechargeBtn:setVisible( false )
		self._fetchedImageView:setVisible( true )
	end
end

function ShouCiChongZhiLayer:create(params)
    return self.new(params)
end

return ShouCiChongZhiLayer
