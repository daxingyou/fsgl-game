--[[
	特权奖励活动
    2019.06.03
]]
local TeQuanJiangLiLayer = class("TeQuanJiangLiLayer", function(params)
    return XTHDSprite:createWithTexture(nil,cc.rect(0,0,839, 420))
end)

function TeQuanJiangLiLayer:ctor(params)
	-- dump( params, "TeQuanJiangLiLayer ctor" )
	-- ui
	self:setOpacity( 0 )
	self._giftIndex = params.index or 1
	self._stateData = params.httpData.list
	table.sort( self._stateData, function( a, b )
		return a.configId < b.configId
	end)
	self._size = self:getContentSize()
	self._leftWidth = 206
	self._redDot = {}
	self._priceIcon = {}
	self._priceLabel = {}
	self._limitLabel = {}
	self._buyBtn = {}
	self._fetchTimeLabel = {}
	local iconWidth = ( self._size.width - self._leftWidth - 10 ) / 4
	local iconHeight = ( self._size.height - 6 ) / 4
	self._selectedPos = {
		cc.p( iconWidth + 70, iconHeight*3 + 20 ),
		cc.p( iconWidth*3 + 70, iconHeight*3 + 20 ),
		cc.p( iconWidth + 70, iconHeight ),
		cc.p( iconWidth*3 + 70 , iconHeight),
	}


	-- 数据
	self._vip = gameUser.getVip()
	self._giftData = {}
	for i, v in ipairs( self._stateData ) do
		self._giftData[#self._giftData + 1] = gameData.getDataFromCSV( "TequanReward", {id = v.configId} )
	end

	self._rewardData = {}

	self:initUI()
	self:refreshUI()
end

-- 创建界面
function TeQuanJiangLiLayer:initUI()
	-- 背景
	local background = ccui.Scale9Sprite:create( "res/image/activities/activityRec_bg.png" )
	background:setContentSize(640,483)
	background:setAnchorPoint( cc.p( 1, 0.5 ) )
	background:setPosition( self._size.width + 34, self._size.height*0.5 - 18 )
	self:addChild( background )
	-- 左边背景
	local leftBg = XTHD.createSprite()
	leftBg:setContentSize(207, 447)
	leftBg:setAnchorPoint(cc.p( 0.5, 0.5 ) )
	leftBg:setPosition(93, self._size.height * 0.5)
	self:addChild( leftBg )
	-- 背景
	local iconsBg = XTHD.createSprite( "res/image/activities/privilegeaward/rulesbg.png" )
	iconsBg:setAnchorPoint(cc.p(0.5, 0.5))
	iconsBg:setPosition(leftBg:getContentSize().width/2 + 5, leftBg:getContentSize().height/2 - 18)
	leftBg:addChild( iconsBg )
	-- 活动规则标题
	-- local rulesTitleLabel = XTHD.createLabel({
	-- 	text      = LANGUAGE_ACTIVITY_PRIVILEGEAWARD[1],
	-- 	fontSize  = 20,
	-- 	anchor    = cc.p( 0, 1 ),
	-- 	pos       = cc.p( 7, leftBg:getContentSize().height - 8 ),
	-- 	clickable = false,
	-- })
	-- rulesTitleLabel:enableShadow( cc.c3b(255, 255, 255), cc.size( 1, 0 ) )
	-- leftBg:addChild( rulesTitleLabel )
	-- 活动规则
	-- self._rulesLabel = XTHD.createLabel({
	-- 	fontSize  = 18,
	-- 	color     = cc.c3b( 255, 204, 55 ),
	-- 	anchor    = cc.p( 0, 1 ),
	-- 	pos       = cc.p( rulesTitleLabel:getPositionX(), rulesTitleLabel:getPositionY() - 26 ),
	-- 	clickable = false,
	-- })
	-- self._rulesLabel:setWidth( self._leftWidth - 15 )
	-- self._rulesLabel:enableShadow( cc.c3b( 255, 204, 55 ), cc.size( 1, 0 ) )
	-- leftBg:addChild( self._rulesLabel )
	-- 礼包物品容器
	self._icons = XTHD.createSprite()
	self._icons:setContentSize( leftBg:getContentSize().width, 250 )
	self._icons:setAnchorPoint( cc.p( 0, 0 ) )
	self._icons:setPosition( 0, 68 )
	leftBg:addChild( self._icons )
	-- 左边领取按钮
	self._fetchBtn = XTHD.createCommonButton({
		btnColor = "write",
		isScrollView = false,
		btnSize = cc.size(leftBg:getContentSize().width*0.5, 46),
		text = LANGUAGE_BTN_KEY.getReward,
		fontColor = cc.c3b( 255, 255, 255 ),
		endCallback = function()
			ClientHttp:requestAsyncInGameWithParams({
				modules = "powerGiftReward?",
				params = {configId = self._giftData[self._giftIndex].id},
		        successCallback = function( backData )
		        	-- dump(backData,"特权奖励界面领取数据")
		            if tonumber(backData.result) == 0 then
		            	for i, v in ipairs( self._stateData ) do
		            		if v.configId == backData.configId then
		            			self._stateData[i].rewardState = backData.rewardState
		            			self._stateData[i].surplusCount = backData.surplusCount
		            			break
		            		end
		            	end
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
	self._fetchBtn:setPosition( leftBg:getContentSize().width*0.5, leftBg:getContentSize().height/2 - 110 )
	self._fetchBtn:getLabel():enableOutline(cc.c4b(150,79,39,255),2)
	leftBg:addChild( self._fetchBtn )
	self._fetchBtn:setScale(0.8)
	--可领取按钮特效
	local fetchSpine = sp.SkeletonAnimation:create( "res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
    self._fetchBtn:addChild( fetchSpine )
    -- fetchSpine:setScaleX( self._fetchBtn:getContentSize().width/102 )
    -- fetchSpine:setScaleY( self._fetchBtn:getContentSize().height/46 )
    fetchSpine:setPosition( self._fetchBtn:getBoundingBox().width*0.5+20, self._fetchBtn:getContentSize().height/2+20-15 )
	fetchSpine:setAnimation( 0, "querenjinjie", true )
	fetchSpine:setScaleY(0.8)
	-- 已领取
	self._fetchedImageView = XTHD.createSprite( "res/image/vip/yilingqu.png" )
	self._fetchedImageView:setPosition( self._fetchBtn:getPosition() )
	self._fetchedImageView:setScale(0.8)
    leftBg:addChild( self._fetchedImageView )
	-- 您尚未购买该礼包
	self._notBuyLabel = XTHD.createLabel({
		text = LANGUAGE_ACTIVITY_PRIVILEGEAWARD[2],
		fontSize = 22,
		color = cc.c3b( 255, 255, 255 ),
		pos = cc.p( self._fetchBtn:getPosition() ),
	})
	leftBg:addChild( self._notBuyLabel )
	-- 右边背景
	local rightBg = XTHD.createSprite()
	rightBg:setContentSize( self._size.width - self._leftWidth + 100, self._size.height + 20 )
	rightBg:setAnchorPoint( cc.p( 1, 0.5 ) )
	rightBg:setPosition(background:getContentSize().width + 30, background:getContentSize().height*0.5 )
	background:addChild( rightBg )
	-- 礼包们
	local resourceTable = {
		44100,
		47100,
		45100,
		46100,	
	}
	for i = 1, 4 do
		local data = self._giftData[i]
		-- 礼包
		local gift = XTHD.createButton({
			normalFile = "res/image/activities/privilegeaward/giftbg.png",
			selectedFile = "res/image/activities/privilegeaward/giftbg.png",
		})
		-- gift:setScale(0.8)
		gift:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		gift:setPosition( self._selectedPos[i] )
		rightBg:addChild( gift )
		gift:setTouchEndedCallback(function()
			if self._giftIndex ~= i then
				self._giftIndex = i
				self:refreshGift()
			end
		end)
		-- 礼包名字
		local giftName = XTHD.createLabel({
			text      = data.name,
			fontSize  = 22,
			color     = cc.c3b(246, 252, 210),
			anchor    = cc.p( 0.5, 1 ),
			pos       = cc.p( gift:getContentSize().width*0.5, gift:getContentSize().height - 7 ),
			clickable = false,
		})
		gift:addChild( giftName )
		-- 礼包图片
		local giftIcon = XTHD.createSprite( XTHD.resource.getItemImgById( resourceTable[i] ) )
		giftIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		giftIcon:setPosition( gift:getContentSize().width*0.5, 105 )
		gift:addChild( giftIcon )
		local giftIconBg = XTHD.createSprite( XTHD.resource.getQualityItemBgPath( 4 ) )
		giftIconBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		giftIconBg:setPosition( gift:getContentSize().width*0.5, 105 )
		gift:addChild( giftIconBg )
		XTHD.addEffectToEquipment(giftIconBg,4)
		-- 红点
		local redDot = cc.Sprite:create( "res/image/common/heroList_redPoint.png" )
        redDot:setAnchorPoint( 1, 1 )
        redDot:setPosition( giftIconBg:getBoundingBox().width + 5, giftIconBg:getBoundingBox().height + 5 )
        redDot:setName( "redDot" )
        giftIconBg:addChild( redDot )
        self._redDot[i] = redDot
		-- 购买价格
		self._priceIcon[i] = XTHD.createSprite( XTHD.getHeaderIconPath( XTHD.resource.type.ingot ) )
		self._priceIcon[i]:setAnchorPoint( cc.p( 0, 0.5 ) )
		self._priceIcon[i]:setPosition( 20, 30 )
		gift:addChild( self._priceIcon[i] )
		self._priceLabel[i] = XTHD.createLabel({
			text      = data.cost,
			fontSize  = 22,
			color     = cc.c3b( 254,254,139 ),
			anchor    = cc.p( 0, 0.5 ),
			pos       = cc.p( 65, 30 ),
			clickable = false,
		})
		gift:addChild( self._priceLabel[i] )
		-- 购买限制
		self._limitLabel[i] = XTHD.createLabel({
			text      = data.cost,
			fontSize  = 18,
			color     = cc.c3b( 254,254,139 ),
			anchor    = cc.p( 1, 0.5 ),
			pos       = cc.p( gift:getContentSize().width - 25, 32 ),
			clickable = false,
		})
		gift:addChild( self._limitLabel[i] )
		-- 购买按钮
		self._buyBtn[i] = XTHD.createCommonButton({
			btnColor = "write",
			btnSize = cc.size(100, 46),
			isScrollView = false,
			text = LANGUAGE_BTN_KEY.buy,
			fontSize  = 26,
			fontColor = cc.c3b( 255, 255, 255 ),
			needSwallow = false,
			endCallback = function()
				ClientHttp:requestAsyncInGameWithParams({
					modules = "buyPowerGift?",
					params = {configId = data.id},
			        successCallback = function( backData )
			        	-- dump(backData,"特权奖励界面购买数据")
			            if tonumber(backData.result) == 0 then
			            	for j, v in ipairs( self._stateData ) do
			            		if v.configId == backData.configId then
			            			self._stateData[j].buyState = backData.buyState
			            			self._stateData[j].rewardState = backData.rewardState
			            			self._stateData[j].surplusCount = backData.surplusCount
			            			break
			            		end
			            	end
			            	self._giftIndex = i
				            self:refreshUI()
				            gameUser.setIngot( backData.ingot )
				            XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO})
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
		self._buyBtn[i]:setScale(0.6)
		self._buyBtn[i]:setAnchorPoint( cc.p( 1, 0.5 ) )
		self._buyBtn[i]:setPosition( gift:getContentSize().width - 25, 28 )
		gift:addChild( self._buyBtn[i] )
		-- 领取次数
		self._fetchTimeLabel[i] = XTHD.createLabel({
			fontSize  = 22,
			color     = cc.c3b( 254,254,139 ),
			anchor    = cc.p( 0.5, 0.5 ),
			pos       = cc.p( gift:getContentSize().width*0.5, 30 ),
			clickable = false,
		})
		gift:addChild( self._fetchTimeLabel[i] )
	end
	-- 选中框
	self._selectedSprite = XTHD.createSprite( "res/image/activities/privilegeaward/selected.png" )
	rightBg:addChild( self._selectedSprite )
end
-- 创建礼包内的物品icons
function TeQuanJiangLiLayer:createIcons()
	local oriData = self._giftData[self._giftIndex]
	local dstData = {}
	self._rewardData = {}
	-- 翻倍
	local times = 0
	local stateData = self._stateData[self._giftIndex]
	if stateData.buyState == 1 then
		-- 未购买
		times = 1
	else
		-- 第几次领取
		local tmp = 1
		if stateData.rewardState == 1 then
			-- 可以领取
			tmp = oriData.times - stateData.surplusCount + 1
		else
			-- 已领取
			tmp = oriData.times - stateData.surplusCount
		end
		times = tmp%( oriData.fbei + 1 ) == 0 and 2 or 1--math.ceil( tmp/( oriData.fbei or tmp) )
	end
	for i = 1, 5 do
		if oriData["tpye"..i] then
			if oriData["tpye"..i] == 4 then
				local isLightAct = ( gameData.getDataFromCSV( "ArticleInfoSheet", {itemid = oriData["typeid"..i]} ).rank or 0 ) > 3
				self._rewardData[#self._rewardData + 1] = {
					rewardtype = oriData["tpye"..i],
	                id = oriData["typeid"..i],
	                num = oriData["num"..i]*times,
	                isLightAct = isLightAct,
				}
				dstData[#dstData + 1] = {
					_type_ = oriData["tpye"..i],
	                itemId = oriData["typeid"..i],
	                count = oriData["num"..i]*times,
	                isLightAct = isLightAct,
				}
			else
				self._rewardData[#self._rewardData + 1] = {
					rewardtype = oriData["tpye"..i],
	                num = oriData["num"..i]*times,
	                isLightAct = true,
				}
				dstData[#dstData + 1] = {
					_type_ = oriData["tpye"..i],
	                count = oriData["num"..i]*times,
	                isLightAct = true,
				}
			end
		end
	end
	local iconWidth = self._icons:getContentSize().width/2 - 5
	for i, v in ipairs( dstData ) do
		local icon = XTHD.createItemNode( v )
		icon:setPosition( iconWidth*( ( i - 1 )%2 + 0.5 ) + 5, 255 - 75*math.ceil( i/2 ) )
		icon:setScale( 0.9 )
		self._icons:addChild( icon )
	end
end
-- 重新请求数据，刷新界面
function TeQuanJiangLiLayer:refreshData()
 	ClientHttp:requestAsyncInGameWithParams({
		modules = "powerGiftList?",
        successCallback = function( backData )
        	-- dump(backData,"特权奖励界面刷新数据")
            if tonumber(backData.result) == 0 then
            	self._stateData = backData.list
            	table.sort( self._stateData, function( a, b )
					return a.configId < b.configId
				end)
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
-- 刷新右侧礼包状态和左侧礼包内容
function TeQuanJiangLiLayer:refreshUI()
	for i, v in ipairs( self._stateData ) do
		if v.buyState == 0 then
			-- 可领取
			self._priceIcon[i]:setVisible( false )
			self._priceLabel[i]:setVisible( false )
			self._limitLabel[i]:setVisible( false )
			self._buyBtn[i]:setVisible( false )
			-- self._buyBtn[i]:setEnable( false )
			self._fetchTimeLabel[i]:setString( LANGUAGE_ACTIVITY_FETCHTIMES( v.surplusCount or 0 ) )
			self._fetchTimeLabel[i]:setVisible( true )
		elseif v.buyState == 1 then
			-- 可购买
			self._priceIcon[i]:setVisible( true )
			self._priceLabel[i]:setVisible( true )
			if self._vip >= self._giftData[i].needVIP then
				self._limitLabel[i]:setVisible( false )
				self._buyBtn[i]:setVisible( true )
				-- self._buyBtn[i]:setEnable( true )
			else
				self._limitLabel[i]:setString( LANGUAGE_ACTIVITY_PRIVILEGE_LIMIT( VIPLABEL[self._giftData[i].needVIP+1] ) )
				self._limitLabel[i]:setVisible( true )
				self._buyBtn[i]:setVisible( false )
				-- self._buyBtn[i]:setEnable( false )
			end
			self._fetchTimeLabel[i]:setVisible( false )
		end
		if v.rewardState == 1 then
			self._redDot[i]:setVisible( true )
		else
			self._redDot[i]:setVisible( false )
		end
	end
	self:refreshGift()
end
-- 刷新左侧礼包内容
function TeQuanJiangLiLayer:refreshGift()
	self._selectedSprite:setPosition( cc.p( self._selectedPos[self._giftIndex].x - 1, self._selectedPos[self._giftIndex].y ) )
	-- self._rulesLabel:setString( LANGUAGE_ACTIVITY_PRIVILEGE_RULE( self._giftData[self._giftIndex].times ) )
	self._icons:removeAllChildren()
	self:createIcons()
	if self._stateData[self._giftIndex].buyState == 1 then
		-- 未购买
		self._fetchBtn:setVisible( false )
		-- self._fetchBtn:setEnable( false )
		self._fetchedImageView:setVisible( false )
		self._notBuyLabel:setVisible( true )
	elseif self._stateData[self._giftIndex].rewardState == 1 then
		-- 可以领取
		self._fetchBtn:setVisible( true )
		-- self._fetchBtn:setEnable( true )
		self._fetchedImageView:setVisible( false )
		self._notBuyLabel:setVisible( false )
	else
		-- 已领取
		self._fetchBtn:setVisible( false )
		-- self._fetchBtn:setEnable( false )
		self._fetchedImageView:setVisible( true )
		self._notBuyLabel:setVisible( false )
	end
end

function TeQuanJiangLiLayer:create(params)
    return self.new(params)
end

return TeQuanJiangLiLayer
