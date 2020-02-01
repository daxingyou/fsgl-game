--[=[
    FileName:JunXuWuZiLayer.lua
	Content:祈愿活动
	LayerName: 军需物资界面
]=]
local JunXuWuZiLayer = class("JunXuWuZiLayer", function(params)
    return XTHDSprite:createWithTexture(nil,cc.rect(0,0,856,415))
end)

function JunXuWuZiLayer:ctor(params)
	-- dump(params, "params")
	self:setOpacity(0)
	-- 初始化数据
	self._globalScheduler = GlobalScheduler:create(self)
	self._curWishPoint = params.httpData.curWishPoint
	self._canWishCount = params.httpData.canWishCount
	self._state = params.httpData.state
	-- 已经许愿的物品列表
	self._prayedIcons = params.httpData.list
	-- 已许愿的物品数量
	self._prayedNums = 0
	-- 获取许愿点剩余时间
	self._diffTime = params.httpData.diffTime
	-- 今天获取许愿点数量，上限10
	self._dayRevert = params.httpData.dayRevert
	-- 活动开启时间
	self._openTime = {
		beginMonth = params.httpData.beginMonth or "",
		beginDay = params.httpData.beginDay or "",
		endMonth = params.httpData.endMonth or "",
		endDay = params.httpData.endDay or "",
	}
	-- 已许愿的物品位置
	self._prayedPos = {}
	for i = 1, 10 do
		self._prayedPos[i] = cc.p( i*83 - 31, 110 )
	end
	-- 静态表数据
	self._staticData = clone( gameData.getDataFromCSV( "TransportGrain" ) )
	-- 当前活动可许愿物品日期,1~7
	local openDay = tonumber(params.httpData.openDay or 1)
	openDay = openDay < 1 and 1 or openDay
	openDay = openDay > 7 and 7 or openDay
	self._openDay = openDay
	-- 当前界面使用的可许愿物品数据
	self._prayData = {}
	local beginIndex = ( openDay - 1 )*10 + 1
	local endIndex = openDay*10
	for i = beginIndex, endIndex do
		self._prayData[#self._prayData + 1] = self._staticData[i]
	end

	self._size = self:getContentSize()

	self:initUI()
	self:refreshUI( false, true )
end
function JunXuWuZiLayer:onCleanup()
	self._globalScheduler:destroy(true)
	self._globalScheduler = nil
	local textureCache = cc.Director:getInstance():getTextureCache()
	textureCache:removeTextureForKey( "res/image/activities/prayer/bg.png" )
	textureCache:removeTextureForKey( "res/image/activities/prayer/curtimes.png" )
	textureCache:removeTextureForKey( "res/image/activities/prayer/todaytimes.png" )
	textureCache:removeTextureForKey( "res/image/activities/prayer/sameitem.png" )
	textureCache:removeTextureForKey( "res/image/activities/prayer/tipbg.png" )
	textureCache:removeTextureForKey( "res/image/activities/prayer/iconbg.png" )
	for i = 1, 12 do
		textureCache:removeTextureForKey( "res/image/activities/prayer/gx/gx"..i..".png" )
	end
	for i = 1, 7 do
		textureCache:removeTextureForKey( "res/image/activities/prayer/z/z"..i..".png" )
	end
end
-- 创建界面
function JunXuWuZiLayer:initUI()
	-- 背景
	self._bg = XTHD.createSprite( "res/image/activities/prayer/bg.png" )
	self._bg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	self._bg:setPosition( self._size.width*0.5, self._size.height*0.5 )
	self:addChild( self._bg )
	self._bg:setOpacity(0)
	self._bgSize = self._bg:getContentSize()

	--背景1
	local bg1 = ccui.Scale9Sprite:create("res/image/activities/prayer/bg_1.png")
	bg1:setAnchorPoint(0.5,1)
	bg1:setPosition(self._bg:getContentSize().width/2,self._bg:getContentSize().height-40)
	self._bg:addChild(bg1)
	--logo
	local logo = XTHD.createSprite("res/image/activities/prayer/logo.png")
	logo:setAnchorPoint(0,0.5)
	logo:setScale(0.7)
	logo:setPosition(50,bg1:getContentSize().height/2+15)
	bg1:addChild(logo)
	--背景2
	local bg2 = ccui.Scale9Sprite:create("res/image/activities/prayer/bg_2.png")
	bg2:setAnchorPoint(1,1)
	bg2:setPosition(self._bg:getContentSize().width+5,self._bg:getContentSize().height/2+10)
	self._bg:addChild(bg2)
	--背景3
	local bg3 = ccui.Scale9Sprite:create("res/image/activities/prayer/bg_3.png")
	bg3:setAnchorPoint(0.5,0)
	bg3:setPosition(self._bg:getContentSize().width/2,0)
	self._bg:addChild(bg3)

	-- 当前许愿点文字，下面两个按照这个控件位置摆放，只需调整这个控件位置
	-- local currentWishPointTip = XTHD.createSprite( "res/image/activities/prayer/curtimes.png" )
	local currentWishPointTip = XTHDLabel:create("当前物资:",24,"res/fonts/def.ttf")
	currentWishPointTip:setColor(cc.c3b(246, 252, 210))
	currentWishPointTip:setAnchorPoint( cc.p( 0, 1 ) )
	currentWishPointTip:setPosition( 10, self._bgSize.height - 10 )
	self._bg:addChild( currentWishPointTip )
	self._currentWishSize = currentWishPointTip:getContentSize()
	-- 当前许愿点数字
	self._currentWishPointNum = getCommonWhiteBMFontLabel()
	self._currentWishPointNum:setAnchorPoint( cc.p( 0, 0.5 ) )
	self._currentWishPointNum:setPosition( currentWishPointTip:getPositionX() + self._currentWishSize.width + 5, currentWishPointTip:getPositionY() - self._currentWishSize.height*0.5 - 7 )
	self._bg:addChild( self._currentWishPointNum )
	-- 许愿点获得方法提示
	self._getWishPointLabel = XTHD.createRichLabel({
		fontSize  = 20,
		anchor    = cc.p( 0, 1 ),
		pos       = cc.p( currentWishPointTip:getPositionX(), currentWishPointTip:getPositionY() - 30 ),
		clickable = false,
	})
	-- self._getWishPointLabel:enableShadow( cc.size(1,-1), 0xff0000ff, 1 )
	self._bg:addChild( self._getWishPointLabel )

	-- 今日可许愿次数文字
	-- local todayWishCountTip = XTHD.createSprite( "res/image/activities/prayer/todaytimes.png" )
	local todayWishCountTip = XTHDLabel:create("今日可补给次数:",24,"res/fonts/def.ttf")
	todayWishCountTip:setColor(cc.c3b(246, 252, 210))
	todayWishCountTip:setAnchorPoint( cc.p( 0, 1 ) )
	todayWishCountTip:setPosition( 370, self._bgSize.height - 10 )
	self._bg:addChild( todayWishCountTip )
	self._canWishSize = todayWishCountTip:getContentSize()
	-- 今日可许愿次数数字
	self._todayWishCountNum = getCommonWhiteBMFontLabel()
	self._todayWishCountNum:setAnchorPoint( cc.p( 0, 0.5 ) )
	self._todayWishCountNum:setPosition( todayWishCountTip:getPositionX() + self._canWishSize.width + 5, currentWishPointTip:getPositionY() - self._canWishSize.height*0.5 - 7 )
	self._bg:addChild( self._todayWishCountNum )

	-- 可选择相同物品
	local sameItemTip = XTHD.createSprite( "res/image/activities/prayer/sameitem.png" )
	sameItemTip:setAnchorPoint( cc.p( 1, 1 ) )
	sameItemTip:setPosition( self._bgSize.width - 10, self._bgSize.height - 10 )
	self._bg:addChild( sameItemTip )


	

	-- 消耗提示背景
	local consumeTipBg = XTHD.createSprite( "res/image/activities/prayer/tipbg.png" )
	consumeTipBg:setAnchorPoint( cc.p( 1, 1 ) )
	consumeTipBg:setPosition( self._bgSize.width, todayWishCountTip:getPositionY() - 30 )
	self._bg:addChild( consumeTipBg )
	-- 消耗提示
	local consumeTip = XTHD.createLabel({
		text = LANGUAGE_KEY_PRAYER[3],
		fontSize  = 20,
		anchor    = cc.p( 0.5, 0.5 ),
		pos       = cc.p( consumeTipBg:getContentSize().width*0.5, consumeTipBg:getContentSize().height*0.5 ),
		clickable = false,
		fontColor = cc.c3b(255,255,255),
	})
	consumeTipBg:addChild( consumeTip )

	local bg4 = ccui.Scale9Sprite:create("res/image/activities/prayer/tip2.png")
	bg4:setAnchorPoint(0,0.5)
	bg4:setPosition(0,177)
	self._bg:addChild(bg4)
	-- 活动时间
	self._prayerDays = XTHD.createLabel({
		text = LANGUAGE_PRAYER_DAYS(self._openTime.beginMonth,self._openTime.beginDay,self._openTime.endMonth,self._openTime.endDay),
		fontSize  = 20,
		anchor    = cc.p( 0, 0.5 ),
		pos       = cc.p( 10, 177 ),
		clickable = false,
	})
	self._prayerDays:enableShadow( cc.c3b( 255, 255, 255 ), cc.size( 0, 1 ) )
	self._bg:addChild( self._prayerDays )

	-- 已许愿物品
	for i = 1, 10 do
		local prayedIconBg = XTHD.createSprite( "res/image/activities/prayer/iconbg.png" )
		prayedIconBg:setScale( 0.95 )
		prayedIconBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		prayedIconBg:setPosition( self._prayedPos[i] )
		self._bg:addChild( prayedIconBg )
	end

	-- 领取按钮
	local btn_disable = ccui.Scale9Sprite:create( "res/image/common/btn/btn_gray_down.png" )
	btn_disable:setContentSize( cc.size( 250, 49 ) )
	self._fetchButton = XTHD.createButton({
		normalFile = "res/image/activities/prayer/btn_up.png",
		selectedFile = "res/image/activities/prayer/btn_down.png",
		btnSize = cc.size( 250, 49 ),
		btnDisable = true,
		disableNode = btn_disable,
	})
	self._fetchButton:setScale(0.9)
	self._fetchButton:setPosition( self._bgSize.width*0.5, 30 )
	self._bg:addChild( self._fetchButton )
	local fetchSpine = sp.SkeletonAnimation:create("res/image/plugin/tasklayer/querenjinjie.json", "res/image/plugin/tasklayer/querenjinjie.atlas", 1.0)   
	self._fetchButton:addChild(fetchSpine)
	fetchSpine:setPosition(self._fetchButton:getContentSize().width*0.5 + 2, self._fetchButton:getContentSize().height*0.5+2)
	fetchSpine:setAnimation(0, "querenjinjie", true )

	-- 明日领取按钮
	btn_disable = ccui.Scale9Sprite:create( "res/image/common/btn/btn_gray_down.png" )
	btn_disable:setContentSize( cc.size( 250, 49 ) )
	self._tofetchButton = XTHD.createButton({
		normalFile = "res/image/activities/prayer/btn.png",
		selectedFile = "res/image/activities/prayer/btn.png",
		btnSize = cc.size( 250, 49 ),
		btnDisable = true,
		disableNode = btn_disable,
	})
	self._tofetchButton:setScale(0.9)
	self._tofetchButton:setPosition( self._bgSize.width*0.5, 30 )
	self._bg:addChild( self._tofetchButton )

	self:createPrayIcons()
end
-- 创建可许愿物品图标
function JunXuWuZiLayer:createPrayIcons()
	-- 移除以前的icon
	for i = 1, 10 do
		self._bg:removeChildByTag( 10 + i )
	end
	-- 可许愿物品，只能放10个
	for i = 1, 10 do
		local prayIcon = XTHD.createItemNode({
			_type_ = self._prayData[i].typeA,
			itemId = self._prayData[i].itemID,
			count = self._prayData[i].itemnum,
			touchShowTip = false,
			isShowDrop = false,
			endCallback = function()
				if self._canWishCount <= 0 then
					XTHDTOAST( LANGUAGE_KEY_PRAYER[4] )
				elseif self._curWishPoint <= 0 then
					XTHDTOAST( LANGUAGE_KEY_PRAYER[5] )
				else
					local itemData = {
						_type_ = self._prayData[i].typeA,
						itemId = self._prayData[i].itemID,
						count = self._prayData[i].itemnum,
					}
					local layer = requires( "src/fsgl/layer/WanBaoGe/WanBaoGeDescPop.lua" ):create({ sData = itemData, sPrayId = i, sPrayDay = self._openDay, parentLayer = self, removeLayout = true})
			        LayerManager.addLayout( layer,{noHide = true } )
			        layer:show()
				end
			end,
		})
		prayIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		prayIcon:setPosition( self._bgSize.width - 448 + ( ( i - 1 )%5 )*95, self._bgSize.height - 118 - math.floor( ( i - 1 )/5 )*85 )
		prayIcon:setTag( 10 + i )
		prayIcon:setScale(0.7)
		self._bg:addChild( prayIcon )
	end
end
-- 创建动画图标
function JunXuWuZiLayer:createAnimationIcon( index )
	-- 黑色背景
	self._animationBg = cc.LayerColor:create(cc.c4b(0,0,0,150))
    self._animationBg:setTouchEnabled(true)
    self._animationBg:setContentSize( cc.size( 10000, 10000 ) )
    self._animationBg:setAnchorPoint( cc.p( 0.5, 0.5 ) )
    self._animationBg:setPosition( cc.p( -5000, -5000 ) )
    self._animationBg:registerScriptTouchHandler(function ( eventType, x, y )
        if (eventType == "began") then
            return true
        end
    end)
    self._bg:addChild( self._animationBg )
    -- 光
 	local data = self._prayData[index]
	local gxAnimation = getAnimation( "res/image/activities/prayer/gx/gx", 1, 12, 0.15 )
	self._gxAnimationSprite = XTHD.createSprite()
	self._gxAnimationSprite:setScale( 2.5 )
	self._gxAnimationSprite:setPosition( self._size.width*0.5, self._size.height*0.5 + 120 )
	self._bg:addChild( self._gxAnimationSprite )
	self._gxAnimationSprite:runAction( cc.RepeatForever:create( gxAnimation ) )
	-- icon
	self._moveIcon = XTHD.createItemNode({
		_type_ = data.typeA,
		itemId = data.itemID,
		count = data.itemnum,
		touchShowTip = false,
	})
	self._moveIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	self._moveIcon:setPosition( self._size.width*0.5, self._size.height*0.5 + 100 )
	self._moveIcon:setScale( 1.5 )
	self._bg:addChild( self._moveIcon )
end
-- 移除动画图标，暂时没用
function JunXuWuZiLayer:removeAnimationIcon()
	if self._moveIcon then
		self._moveIcon:removeFromParent()
	end
	if self._gxAnimationSprite then
		self._gxAnimationSprite:removeFromParent()
	end
	if self._animationBg then
		self._animationBg:removeFromParent()
	end
end
-- 跟后端交互，重新获取数据，刷新界面
function JunXuWuZiLayer:refreshData()
	ClientHttp:requestAsyncInGameWithParams({
		modules = "wishState?",
        successCallback = function( data )
        	-- dump(data,"许愿界面刷新数据")
            if tonumber(data.result) == 0 then
            	if not self._globalScheduler then
            		return
            	end
		    	self._curWishPoint = data.curWishPoint
				self._canWishCount = data.canWishCount
				self._state = data.state
				-- 已经许愿的物品列表
				self._prayedIcons = data.list
				-- 获取许愿点剩余时间
				self._diffTime = data.diffTime
				-- 今天获取许愿点数量，上限10
				self._dayRevert = data.dayRevert
				-- 活动开启时间
				self._openTime = {
					beginMonth = data.beginMonth or "",
					beginDay = data.beginDay or "",
					endMonth = data.endMonth or "",
					endDay = data.endDay or "",
				}
				-- 数据
				self._prayData = {}
				-- 当前活动可许愿物品日期,1~7
				local openDay = tonumber(data.openDay or 1)
				openDay = openDay < 1 and 1 or openDay
				openDay = openDay > 7 and 7 or openDay
				-- 当前界面使用的可许愿物品数据
				self._prayData = {}
				local beginIndex = ( openDay - 1 )*10 + 1
				local endIndex = openDay*10
				for i = beginIndex, endIndex do
					self._prayData[#self._prayData + 1] = self._staticData[i]
				end

				if openDay ~= self._openDay then
					-- 更新显示的许愿物品
					self:createPrayIcons()
				end
				self._openDay = openDay

	            self:refreshUI( false, true )
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
-- 刷新界面，判断界面显示，播放动画或者刷新列表
function JunXuWuZiLayer:refreshUI( animation, timer )
	if not self._globalScheduler then
		return
	end
	-- 刷新计时器
	if timer then
		if tonumber( gameUser.getLevel() ) >= 30 then
			if self._curWishPoint >= 10 then
				self._getWishPointLabel:setVisible( false )
				self._globalScheduler:removeCallback( "prayerCD" )
			elseif self._dayRevert == 10 then
				-- 今天许愿点全部获得
				self._getWishPointLabel:setVisible( true )
				self._getWishPointLabel:setString( LANGUAGE_KEY_PRAYER[2] )
				self._globalScheduler:removeCallback( "prayerCD" )
			else
				-- 倒计时
				self._getWishPointLabel:setVisible( true )
				local a= LANGUAGE_KEY_PRAYERTIMER( self._diffTime )
				self._getWishPointLabel:setString( LANGUAGE_KEY_PRAYERTIMER( self._diffTime ) )
				self._globalScheduler:addCallback( "prayerCD", {perCall = function( time )
					-- print(time)
					local _time = tonumber(time) or 0
			        if _time > 0 then
			            self._getWishPointLabel:setString( LANGUAGE_KEY_PRAYERTIMER( _time ) )
			        else
			            self:refreshData()
			        end
				end, cdTime = self._diffTime} )
			end
		else
			-- 不到三十级
			self._getWishPointLabel:setString( LANGUAGE_KEY_PRAYER[1] )
		end
	end

	self._currentWishPointNum:setString( self._curWishPoint )
	self._todayWishCountNum:setString( self._canWishCount )
	self._prayerDays:setString( LANGUAGE_PRAYER_DAYS(self._openTime.beginMonth,self._openTime.beginDay,self._openTime.endMonth,self._openTime.endDay) )
	
	-- 判断是否播放动画
	if animation then
		-- 许愿成功，播放动画
		-- icon
	    local iconDelay = cc.DelayTime:create(0.5)
	    local iconSpawn = cc.Spawn:create( cc.ScaleTo:create( 0.6, 0.65 ), cc.MoveTo:create( 0.7, self._prayedPos[#self._prayedIcons] ) )
	    local iconCallback = cc.CallFunc:create( function()
	    	-- 砸
	    	local zAnimationSprite = XTHD.createSprite()
			zAnimationSprite:setScale( 0.95 )
			zAnimationSprite:setPosition( self._moveIcon:getBoundingBox().width * 0.5 + 12, self._moveIcon:getBoundingBox().height * 0.5 + 13 )
			self._moveIcon:addChild( zAnimationSprite )
			local zAnimation = getAnimation( "res/image/activities/prayer/z/z", 1, 7, 0.15 )
	    	zAnimationSprite:runAction( cc.Sequence:create( zAnimation, cc.CallFunc:create(function()
	    		zAnimationSprite:removeFromParent()
	    	end) ) )
	    	self._moveIcon:setTag( #self._prayedIcons )
	    	self._prayedNums = self._prayedNums + 1
	    	self._moveIcon:setTouchShowTip( true )
	    	self._moveIcon = nil
    	end)
    	self._moveIcon:runAction( cc.Sequence:create( iconDelay, cc.EaseIn:create( iconSpawn, 2.2 ), iconCallback ) )
    	-- 光
    	local gxDelay = cc.DelayTime:create(0.5)
	    local gxSpawn = cc.Spawn:create( cc.ScaleTo:create( 0.7, 5/3 ), cc.MoveTo:create( 0.7, self._prayedPos[#self._prayedIcons] ), cc.FadeTo:create( 0.7, 0.3 ) )
	    local gxCallback = cc.CallFunc:create( function()
	    	self._gxAnimationSprite:removeFromParent()
	    	self._animationBg:removeFromParent()
    	end)
    	self._gxAnimationSprite:runAction( cc.Sequence:create( gxDelay, cc.EaseIn:create( gxSpawn, 2.2 ), gxCallback ) )
	else
		-- 直接刷新已许愿列表
		for i = 1, self._prayedNums do
			self._bg:removeChildByTag( i )
		end
		for i = 1, #self._prayedIcons do
			local data = self._staticData[self._prayedIcons[i]]
			local prayedIcon = XTHD.createItemNode({
				_type_ = data.typeA,
				itemId = data.itemID,
				count = data.itemnum,
				touchShowTip = true,
			})
			prayedIcon:setScale( 0.65)
			prayedIcon:setTag(i)
			prayedIcon:setAnchorPoint( cc.p( 0.5, 0.5 ) )
			prayedIcon:setPosition( self._prayedPos[i].x, self._prayedPos[i].y - 1)
			self._bg:addChild( prayedIcon )
		end
		self._prayedNums = #self._prayedIcons
	end

	-- 领取按钮
	if self._state == 1 then
		-- 领取
		self._fetchButton:setTouchEndedCallback(function()
			ClientHttp:requestAsyncInGameWithParams({
				modules = "wishReward?",
                successCallback = function( backData )
                	-- dump(backData,"领取返回")
                    if tonumber(backData.result) == 0 then
				    	-- 成功获取弹窗
				    	self._canWishCount = backData.canWishCount
				    	local _typeData = {}
				    	local _itemData = {}
				    	-- 合并相同物品
				    	for i, v in ipairs( self._prayedIcons ) do
				    		local data = self._staticData[v]
				    		if data.typeA == XTHD.resource.type.item then
				            	_itemData[tostring( data.itemID )] = _itemData[tostring( data.itemID )] or 0
				            	_itemData[tostring( data.itemID )] = _itemData[tostring( data.itemID )] + tonumber( data.itemnum )
					        else
					            _typeData[tostring( data.typeA )] = _typeData[tostring( data.typeA )] or 0
				            	_typeData[tostring( data.typeA )] = _typeData[tostring( data.typeA )] + tonumber( data.itemnum )
					        end
				    	end
				    	-- 转化成showreward格式
				    	local _resultData = {}
				    	for k, v in pairs(_typeData) do
				    		_resultData[#_resultData + 1] = {
				    			rewardtype = tonumber( k ),
				                num = tonumber( v ),
				    		}
				    	end
				    	for k, v in pairs(_itemData) do
				    		_resultData[#_resultData + 1] = {
				    			rewardtype = XTHD.resource.type.item,
				                id = tonumber( k ),
				                num = tonumber( v ),
				    		}
				    	end
				    	ShowRewardNode:create( _resultData )
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
			            self._prayedIcons = {}
			            self._state = 0
			            self:refreshUI( false, false )
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
		self._fetchButton:setVisible(true)
		self._tofetchButton:setVisible(false)
	else
		-- 不能领取
		self._fetchButton:setVisible(false)
		self._tofetchButton:setVisible(true)
	end
end

function JunXuWuZiLayer:create(params)
    return self.new(params)
end

return JunXuWuZiLayer
