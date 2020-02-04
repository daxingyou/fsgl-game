-- 毕业典礼界面

BiYeDianLiLayer = class("BiYeDianLiLayer",function(param)
	return XTHD.createPopLayer()
end)

function BiYeDianLiLayer:ctor()	
	self._canClick = false
	self._isReciveAll = 10	--是否全部领取完 目前0就全部领取完
	----背景
	local bg = cc.Sprite:create("res/image/activities/graduation/biyebg1.png" )
	bg:setAnchorPoint(cc.p(0.5, 0.5))
	local winSize = cc.Director:getInstance():getWinSize()	
	self:setContentSize(cc.size(winSize.width, winSize.height))

    bg:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
    
    -- 左边背景
    local leftBg = cc.Sprite:create("res/image/activities/graduation/biyebghaibao.png")
    leftBg:setPosition(182, bg:getContentSize().height / 2 - 18)
    bg:addChild(leftBg)

	-- 关闭按钮
	local normalFile = "res/image/ziyuanzhaohui/zyguan_up.png"
	local selectFile = "res/image/ziyuanzhaohui/zyguan_down.png"

	local _back = XTHDPushButton:createWithParams({
		normalFile = normalFile,
		selectedFile = selectFile,
		musicFile = XTHD.resource.music.effect_btn_commonclose,
		endCallback = function ()
			self:hide()
		end
	})
	_back:setPosition(cc.p(bg:getContentSize().width - 30, bg:getContentSize().height - 80))

	bg:addChild(_back)
	self:addContent(bg)
    self.bg = bg
    
    --毕业典礼数据
    self.arenaAwardData = gameData.getDataFromCSV("GraduatIonceremony")
end

function BiYeDianLiLayer:create(data)
    self.data = data
    -- print("毕业典礼的数据为：")
    -- print_r(self.data)
	local BiYeDianLiLayer = BiYeDianLiLayer.new()
	if BiYeDianLiLayer then 
		BiYeDianLiLayer:init()
		BiYeDianLiLayer:registerScriptHandler(function(event )
			if event == "enter" then 
				BiYeDianLiLayer:onEnter()
			elseif event == "exit" then 
				BiYeDianLiLayer:onExit()
			end 
		end)	
    end
	return BiYeDianLiLayer
end

function BiYeDianLiLayer:init( )
	self:initTabelView()   	
	self._canClick = true	
end

function BiYeDianLiLayer:initTabelView()
    local tableView = ccui.ListView:create()
	tableView:setScrollBarEnabled(false)
    tableView:setContentSize(cc.size(420, 330))
    tableView:setDirection(ccui.ScrollViewDir.vertical)
    tableView:setBounceEnabled(true)
    tableView:setPosition(295, 52)
    self.bg:addChild(tableView)
    self.__msgTableView = tableView
    self:reloadData()
end

-- 奖励创建个tableView
function BiYeDianLiLayer:createTabelView()
	local tableView = ccui.ListView:create()
    tableView:setContentSize(cc.size(300, 80))
    tableView:setDirection(ccui.ScrollViewDir.horizontal)
    tableView:setScrollBarEnabled(false)
    tableView:setBounceEnabled(true)
	tableView:setPosition(11, -3)
	return tableView
end

function BiYeDianLiLayer:onEnter( )
    local function TOUCH_EVENT_BEGAN( touch,event )
    	return true
    end

    local function TOUCH_EVENT_MOVED( touch,event )
    	-- body
    end

    local function TOUCH_EVENT_ENDED( touch,event )
    	if self._canClick == false then
    		return
    	end
    	local pos = touch:getLocation()
    	local rect = self.bg:getBoundingBox()
    	if cc.rectContainsPoint(rect,pos) == false then
    		self._canClick = false
    		self:removeFromParent()
    	end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(TOUCH_EVENT_BEGAN,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(TOUCH_EVENT_MOVED,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(TOUCH_EVENT_ENDED,cc.Handler.EVENT_TOUCH_ENDED)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
end

function BiYeDianLiLayer:onExit( ) 
end


function BiYeDianLiLayer:reloadData( )
	-- 如果发现当前已经领取了，就减去1
	local isHave = false
	for k,v in pairs(self.data.list) do
		if v.state == 0 then
			self._isReciveAll = self._isReciveAll - 1
		end
		
		if v.state == 1 then
			isHave = true
		end
	end
	--刷新小红点
    if isHave == true then
         XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "bydl",["visible"] = true}})
    else
         XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_FUNCIONS_REDDOT,data = {["name"] = "bydl",["visible"] = false}})
    end

	if self.__msgTableView then 
	 	self.__msgTableView:removeAllChildren()
        if tonumber(self.data.result) == 0 then
            if not self.arenaAwardData or #self.arenaAwardData then
                
            end
            for i = #self.arenaAwardData,1, -1 do
                local node = self:createVeiwCell(self.arenaAwardData[i])				
                self.__msgTableView:insertCustomItem(node,0)
            end
        end
	end 	
end

-- 领取一个奖励
function BiYeDianLiLayer:reciveRewardOne(data, cellBg)
	local _url = "getGragraduationReward?"
	XTHDHttp:requestAsyncInGameWithParams({
		modules = _url,
		params = {configId = data.configId},
		successCallback = function(data)
			if tonumber(data.result) == 0 then
				-- 总奖励会减去1 当奖励全部领完则不显示主城按钮
				self._isReciveAll = self._isReciveAll - 1
				-- if self._isReciveAll <= 0 then
				-- 	gameUser.setGragraduationState(0)
				-- end
				if data.isShow == 0 then  --代表领取完了，关闭
                    gameUser.setGragraduationState(0)
				end

				local show = {} --奖励展示
				--货币类型
				if data.property and #data.property > 0 then
					for i=1,#data.property do
						local pro_data = string.split( data.property[i],',')
						--如果奖励类型存在，而且不是vip升级(406)则加入奖励
						print(XTHD.resource.propertyToType[tonumber(pro_data[1])])
						if tonumber(pro_data[1]) ~= 406 and XTHD.resource.propertyToType[tonumber(pro_data[1])] then
							local getNum = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]))
							if getNum > 0 then
								local idx = #show + 1
								show[idx] = {}
								show[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
								show[idx].num = getNum
							end
						end
						DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
					end
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_TOP_INFO})
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) 		--刷新数据信息
				end
	
				--物品类型
				if data.bagItems and #data.bagItems ~= 0 then
					for i=1,#data.bagItems do
						local item_data = data.bagItems[i]
						local showCount = item_data.count
						if item_data.count and tonumber(item_data.count) ~= 0 then
							--print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
							showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId));
							DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
						else
							DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
						end
						--如果奖励类型
						local idx = #show + 1
						show[idx] = {}
						show[idx].rewardtype = 4 -- item_data.item_type
						show[idx].id = item_data.itemId
						show[idx].num = showCount
					end
				end

				cellBg:getChildByName("reciveBtn"):setVisible(false)
				cellBg:getChildByName("sucessLabel"):setVisible(true)
				cellBg:getChildByName("sucessLabel"):setString("已领取")

				--显示领取奖励成功界面
				ShowRewardNode:create(show)
				RedPointManage:reFreshDynamicItemData()
			else
			   XTHDTOAST(data.msg)
			end
		end,--成功回调
		failedCallback = function()
			XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
		end,--失败回调
		targetNeedsToRetain = self,--需要保存引用的目标
		loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
	})
end

-- -- 领取多个奖励
-- function BiYeDianLiLayer:reciveRewardAll(data)
-- 	local _url = "getAllRecovery?"
-- 	XTHDHttp:requestAsyncInGameWithParams({
-- 		modules = _url,
-- 		params = {type = data.type, configId = data.configId},
-- 		successCallback = function(data)
-- 			if tonumber(data.result) == 0 then
-- 				local show = {} --奖励展示
-- 				--货币类型
-- 				if data.property and #data.property > 0 then
-- 					for i=1,#data.property do
-- 						local pro_data = string.split( data.property[i],',')
-- 						--如果奖励类型存在，而且不是vip升级(406)则加入奖励
-- 						if tonumber(pro_data[1]) ~= 406 and XTHD.resource.propertyToType[tonumber(pro_data[1])] then
-- 							local getNum = tonumber(pro_data[2]) - tonumber(gameUser.getDataById(pro_data[1]))
-- 							if getNum > 0 then
-- 								local idx = #show + 1
-- 								show[idx] = {}
-- 								show[idx].rewardtype = XTHD.resource.propertyToType[tonumber(pro_data[1])]
-- 								show[idx].num = getNum
-- 							end
-- 						end
-- 						DBUpdateFunc:UpdateProperty( "userdata", pro_data[1], pro_data[2] )
-- 					end
-- 				end
	
-- 				--物品类型
-- 				if data.bagItems and #data.bagItems ~= 0 then
-- 					for i=1,#data.bagItems do
-- 						local item_data = data.bagItems[i]
-- 						local showCount = item_data.count
-- 						if item_data.count and tonumber(item_data.count) ~= 0 then
-- 							--print("itemCount: "..DBTableItem.getCountByID(item_data.dbId))
-- 							showCount = item_data.count - tonumber(DBTableItem.getCountByID(item_data.dbId));
-- 							DBTableItem.updateCount(gameUser.getUserId(),item_data,item_data.dbId)
-- 						else
-- 							DBTableItem.deleteData(gameUser.getUserId(),item_data.dbId)
-- 						end
-- 						--如果奖励类型
-- 						local idx = #show + 1
-- 						show[idx] = {}
-- 						show[idx].rewardtype = 4 -- item_data.item_type
-- 						show[idx].id = item_data.itemId
-- 						show[idx].num = showCount
-- 					end
-- 				end
-- 				--显示领取奖励成功界面
-- 				ShowRewardNode:create(show)
-- 				RedPointManage:reFreshDynamicItemData()
-- 				self:reloadData()
-- 			else
-- 			   XTHDTOAST(data.msg)
-- 			end
-- 		end,--成功回调
-- 		failedCallback = function()
-- 			XTHDTOAST(LANGUAGE_TIPS_WEBERROR)
-- 		end,--失败回调
-- 		targetNeedsToRetain = self,--需要保存引用的目标
-- 		loadingType = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
-- 	})
-- end

function BiYeDianLiLayer:createVeiwCell(data)
	local node = ccui.Layout:create()
	node:setContentSize(cc.size(418, 115))
	local cellBg = cc.Sprite:create("res/image/activities/graduation/jibanbg2.png")
	cellBg:setAnchorPoint(cc.p(0.5, 0.5))
	cellBg:setPosition(cc.p(node:getContentSize().width / 2, node:getContentSize().height / 2))
	node:addChild(cellBg)

	-- 标题
	local titleLabel = cc.Sprite:create("res/image/activities/graduation/winner"..(data.rank)..".png")
	titleLabel:setAnchorPoint(0,1)
	titleLabel:setPosition(15, cellBg:getContentSize().height - 5)
	cellBg:addChild(titleLabel)

    local rewardList = string.split(data.reward, "#")
	-- if #rewardList > 6 then
	-- 	_tabView = self:createTabelView() 
	-- 	cellBg:addChild(_tabView)
    -- end
    local item = ItemNode:createWithParams({
        _type_ = tonumber(rewardList[1]),
        itemId = tonumber(rewardList[2]),
        count = tonumber(rewardList[3]),
    })
    
    item:setScale(0.6)
    item:setPosition(40, 45)
    cellBg:addChild(item) 
    
    local descLabel = XTHDLabel:create(data.description, 16)
	descLabel:setAnchorPoint(0, 0.5)
	descLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	descLabel:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	descLabel:setDimensions(200, 60)
	descLabel:setColor(cc.c3b(120,50,9))
    --descLabel:enableShadow(cc.c4b(102,44,49,255),cc.size(1,-1), 1)      -----------------描述文字
    descLabel:setPosition(cc.p(cellBg:getContentSize().width/2 - 130, cellBg:getContentSize().height/2 - 10))
    cellBg:addChild(descLabel)
	

	-- local yActiveBtn = cc.Sprite:create("res/image/activities/graduation/biyelingqu_down.png")
	-- yActiveBtn:setName("yActiveBtn")
	-- yActiveBtn:setAnchorPoint(cc.p(1, 0))
	-- yActiveBtn:setPosition(cellBg:getContentSize().width - 6, 15)
	-- cellBg:addChild(yActiveBtn)

	-- 是否领取
	local sucessLabel = XTHDLabel:create("", 18)
	sucessLabel:setName("sucessLabel")
	sucessLabel:setAnchorPoint(1, 0.5)
	sucessLabel:setColor(cc.c3b(255, 14, 0))
	sucessLabel:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1), 1)
	sucessLabel:setPosition(cellBg:getContentSize().width - 15, cellBg:getContentSize().height * 0.5)
	cellBg:addChild(sucessLabel)
	
	local serverData = nil
	
	for k,v in pairs(self.data.list) do
		if v.configId == data.rank then
			serverData = v
		end
	end

	-- 未完成
	if serverData.state == -1 then
		--sucessLabel
		sucessLabel:setString("未完成")
		sucessLabel:setVisible(true)
	elseif serverData.state == 2 then	--已领取
		sucessLabel:setString("已领取")
		sucessLabel:setVisible(true)
	elseif serverData.state == 1 then	--未领取
		--羁绊是否激活
		sucessLabel:setVisible(false)
		local normalFile = "res/image/activities/graduation/biyelingqu_down.png"
		local selectFile = "res/image/activities/graduation/biyelingqu_up.png"

		local reciveBtn = XTHDPushButton:createWithParams({
			normalFile = normalFile,
			selectedFile = selectFile,
			isScrollView = true,
			endCallback = function ()
				self:reciveRewardOne(serverData, cellBg)
			end
		})
		reciveBtn:setName("reciveBtn")
		reciveBtn:setAnchorPoint(cc.p(1, 0.5))
		reciveBtn:setPosition(cellBg:getContentSize().width - 6, cellBg:getContentSize().height * 0.5)
		cellBg:addChild(reciveBtn)
	end

	return node
end

return BiYeDianLiLayer


