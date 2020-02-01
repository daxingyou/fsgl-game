-- 资源找回界面

ZiYuanZhaoHuiLayer = class("ZiYuanZhaoHuiLayer",function(param)
	return cc.Layer:create()
end)

function ZiYuanZhaoHuiLayer:ctor()	
	self._canClick = false
	self.allSliver = 0
	self.allGold = 0

	local _color = cc.LayerColor:create(cc.c4b(0,0,0,100), self:getContentSize().width ,self:getContentSize().height)
	self:addChild(_color)
	----背景
	local bg = cc.Sprite:create("res/image/ziyuanzhaohui/zydt.png" )
	bg:setAnchorPoint(cc.p(0.5, 0.5))
	local winSize = cc.Director:getInstance():getWinSize()	
	self:setContentSize(cc.size(winSize.width, winSize.height))

	bg:setPosition(cc.p(winSize.width / 2, winSize.height / 2))

	-- 关闭按钮
	local normalFile = "res/image/ziyuanzhaohui/zyguan_up.png"
	local selectFile = "res/image/ziyuanzhaohui/zyguan_down.png"

	local _back = XTHDPushButton:createWithParams({
		normalFile = normalFile,
		selectedFile = selectFile,
		endCallback = function ()
			self:removeFromParent()
		end
	})
	_back:setPosition(cc.p(bg:getContentSize().width - 30, bg:getContentSize().height - 80))

	bg:addChild(_back)
	self:addChild(bg)
	self.bg = bg

	-- 银两找回
	normalFile = "res/image/ziyuanzhaohui/ylzh_up.png"
	selectFile = "res/image/ziyuanzhaohui/ylzh_down.png"

	local yinliangBtn = XTHDPushButton:createWithParams({
		normalFile = normalFile,
		selectedFile = selectFile,
		needSwallow = false,
		endCallback = function ()
		    if self.allSliver == 0 then
                XTHDTOAST("资源已经全部找回")
            else
                local confirmLayer = XTHDConfirmDialog:createWithParams({
		             rightCallback=function()
		                self:reciveRewardAll({type="silver"})
		            end,                 
		            msg = "确定使用"..self.allSliver.."银两进行资源找回嘛？"
		        })
		        self:addChild(confirmLayer)
		    end
		    
		end
	})
	yinliangBtn:setPosition(140, 50)
	self.bg:addChild(yinliangBtn)

	-- 完美找回
	normalFile = "res/image/ziyuanzhaohui/wmzh_up.png"
	selectFile = "res/image/ziyuanzhaohui/wmzh_down.png"

	local yuanbaoBtn = XTHDPushButton:createWithParams({
		normalFile = normalFile,
		selectedFile = selectFile,
		needSwallow = false,
		endCallback = function ()
		    if self.allGold == 0 then
                XTHDTOAST("资源已经全部找回")
            else
                local confirmLayer = XTHDConfirmDialog:createWithParams({
		             rightCallback=function()
		                self:reciveRewardAll({type="gold"})
		            end,                 
		            msg = "确定使用"..self.allGold.."元宝进行资源找回嘛？"
		        })
		        self:addChild(confirmLayer)	
		    end
		    
		end
	})
	yuanbaoBtn:setPosition(480, 50)
	self.bg:addChild(yuanbaoBtn)

	--我不找回
	normalFile = "res/image/ziyuanzhaohui/buzhaohui_down.png"
	selectFile = "res/image/ziyuanzhaohui/buzhaohui_up.png"
	local FangQibtn = XTHDPushButton:createWithParams({
		normalFile = normalFile,
		selectedFile = selectFile,
		needSwallow = false,
		endCallback = function ()
			if self.allGold == 0 then
				XTHDTOAST("已放弃找回资源")
			else
				local confirmLayer = XTHDConfirmDialog:createWithParams({
					rightCallback=function()
						self:FangQiZhaoHui()
					end,                 
					msg = "您确定不找回资源吗？"
				})
				self:addChild(confirmLayer)	
			end
		end
		})
	FangQibtn:setPosition(310,50)
	self.bg:addChild(FangQibtn)
	
end

function ZiYuanZhaoHuiLayer:create()
	local recoveryLayer = ZiYuanZhaoHuiLayer.new()
	if recoveryLayer then 
		recoveryLayer:init()
		recoveryLayer:registerScriptHandler(function(event )
			if event == "enter" then 
				recoveryLayer:onEnter()
			elseif event == "exit" then 
				recoveryLayer:onExit()
			end 
		end)	
    end
	return recoveryLayer
end

function ZiYuanZhaoHuiLayer:init( )
	self:initTabelView()   	
	self._canClick = true	
end

function ZiYuanZhaoHuiLayer:initTabelView()
    local tableView = ccui.ListView:create()
    tableView:setContentSize(cc.size(486, 198))
    tableView:setDirection(ccui.ScrollViewDir.vertical)
    tableView:setScrollBarEnabled(false)
    tableView:setBounceEnabled(true)
    tableView:setPosition(70, 90)
    self.bg:addChild(tableView)
    self.__msgTableView = tableView
    self:reloadData()
end

-- 奖励创建个tableView
function ZiYuanZhaoHuiLayer:createTabelView()
	local tableView = ccui.ListView:create()
    tableView:setContentSize(cc.size(300, 80))
    tableView:setDirection(ccui.ScrollViewDir.horizontal)
    tableView:setScrollBarEnabled(false)
    tableView:setBounceEnabled(true)
	tableView:setPosition(11, -3)
	return tableView
end

function ZiYuanZhaoHuiLayer:onEnter( )
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

function ZiYuanZhaoHuiLayer:onExit( ) 
end


function ZiYuanZhaoHuiLayer:reloadData( )
	if self.__msgTableView then 
		self.__msgTableView:removeAllChildren()
		local _url = "openRecoveryWindown?"
		XTHDHttp:requestAsyncInGameWithParams({
			modules = _url,
			successCallback = function(data)
				if tonumber(data.result) == 0 then
					-- print("资源找回服务器返回的数据为：")
					-- print_r(data)
					if not data.reciver or #data.reciver == 0 then
						gameUser.setRecoveryState(0)
					end
					self.allSliver = 0
					self.allGold = 0
					for i =1,#data.reciver do
						self.allSliver = self.allSliver + data.reciver[i].config.needSilver
						self.allGold = self.allGold + data.reciver[i].config.needGold
						local node = self:createVeiwCell(data.reciver[i])				
						self.__msgTableView:insertCustomItem(node,0)
					end
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
					if self.allGold == 0 or self.allSliver == 0 then
						self:removeFromParent()
					end
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
end

-- 领取一个奖励
function ZiYuanZhaoHuiLayer:reciveRewardOne(data)
	local _url = "getRecovery?"
	XTHDHttp:requestAsyncInGameWithParams({
		modules = _url,
		params = {type = data.type, configId = data.configId},
		successCallback = function(data)
			if tonumber(data.result) == 0 then
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
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
					XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
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
				--显示领取奖励成功界面
				ShowRewardNode:create(show)
				RedPointManage:reFreshDynamicItemData()
				self:reloadData()
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

function ZiYuanZhaoHuiLayer:FangQiZhaoHui()
	ClientHttp:requestAsyncInGameWithParams({
		modules = "noRecovery?",
        successCallback = function( data )
			-- dump(data,"不找回资源")
			XTHDTOAST("您已放弃找回资源")
			--self.__msgTableView:removeAllChildren()
			gameUser.setRecoveryState(0)
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_MAINCITY_INFO})
			XTHD.dispatchEvent({name = CUSTOM_EVENT.REFRESH_TOP_INFO}) --刷新数据信息
			self:removeFromParent()
        end,
        failedCallback = function()
            XTHDTOAST(LANGUAGE_TIPS_WEBERROR)------"网络请求失败")
        end,--失败回调
        loadingType   = HTTP_LOADING_TYPE.CIRCLE,--加载图显示 circle 光圈加载 head 头像加载
        loadingParent = node,
    })
end

-- 领取多个奖励
function ZiYuanZhaoHuiLayer:reciveRewardAll(data)
	local _url = "getAllRecovery?"
	XTHDHttp:requestAsyncInGameWithParams({
		modules = _url,
		params = {type = data.type},
		successCallback = function(data)
			if tonumber(data.result) == 0 then
				local show = {} --奖励展示
				--货币类型
				if data.property and #data.property > 0 then
					for i=1,#data.property do
						local pro_data = string.split( data.property[i],',')
						--如果奖励类型存在，而且不是vip升级(406)则加入奖励
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
						XTHD.FristChongZhiPopLayer(cc.Director:getInstance():getRunningScene())
					end
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
				--显示领取奖励成功界面
				ShowRewardNode:create(show)
				RedPointManage:reFreshDynamicItemData()
				self:reloadData()
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

function ZiYuanZhaoHuiLayer:createVeiwCell(data)
	local node = ccui.Layout:create()
	node:setContentSize(cc.size(480, 95))
	local cellBg = cc.Sprite:create("res/image/ziyuanzhaohui/zydk.png")
	cellBg:setAnchorPoint(cc.p(0.5, 0.5))
	cellBg:setPosition(cc.p(node:getContentSize().width / 2, node:getContentSize().height / 2))
	node:addChild(cellBg)

	local configData = data["config"]

	-- 标题
	local titleLabel = XTHDLabel:createWithParams({
		text = configData.title,
		fontSize = 16,
		color = cc.c3b(255, 255, 0)
	})
	titleLabel:setAnchorPoint(0,1)
	titleLabel:setPosition(23, cellBg:getContentSize().height)
	cellBg:addChild(titleLabel)

	local rewardList = configData.rewardList
	local _tabView = nil
	if #rewardList > 6 then
		_tabView = self:createTabelView() 
		cellBg:addChild(_tabView)
	end

	-- 奖励列表
	for i = 1, #rewardList do
		local itemData = rewardList[i]
        local item = ItemNode:createWithParams({
            _type_ = itemData.rewardType,
            itemId = itemData.rewardId,
			count = itemData.rewardSum,
		})
		
		item:setScale(0.6)
		if not _tabView then
			item:setPosition((i - 1) * 65 + 40, 37)
			cellBg:addChild(item)
		else
			local itemSize = cc.size(60, 60)
			local node = ccui.Layout:create()
			node:setContentSize(itemSize)
			node:addChild(item)
			item:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
			_tabView:insertCustomItem(node, 0)
		end   
	end

	-- 银两找回
	local normalFile = "res/image/ziyuanzhaohui/ylzh_up.png"
	local selectFile = "res/image/ziyuanzhaohui/ylzh_down.png"

	local yinliangBtn = XTHDPushButton:createWithParams({
		normalFile = normalFile,
		selectedFile = selectFile,
		endCallback = function ()
            --加入确认提示框
            local confirmLayer = XTHDConfirmDialog:createWithParams({
	             rightCallback=function()
	                self:reciveRewardOne({type = "silver", configId = data.configId})
	            end,                 
	            msg = "确定使用"..configData.needSilver.."银两进行资源找回嘛？"
	        })
	        self:addChild(confirmLayer)
		end
	})
	yinliangBtn:setAnchorPoint(cc.p(1, 0.5))
	yinliangBtn:setPosition(cellBg:getContentSize().width - 10, cellBg:getContentSize().height * 0.7)
	cellBg:addChild(yinliangBtn)

	if configData.needSilver == 0 then
		yinliangBtn:setVisible(false)
	end

	-- 完美找回
	normalFile = "res/image/ziyuanzhaohui/wmzh_up.png"
	selectFile = "res/image/ziyuanzhaohui/wmzh_down.png"

	local yuanbaoBtn = XTHDPushButton:createWithParams({
		normalFile = normalFile,
		selectedFile = selectFile,
		endCallback = function ()
            local confirmLayer = XTHDConfirmDialog:createWithParams({
	             rightCallback=function()
	                self:reciveRewardOne({type = "gold", configId = data.configId})
	            end,                 
	            msg = "确定使用"..configData.needGold.."元宝进行资源找回嘛？"
	        })
	        self:addChild(confirmLayer)
		end
	})
	yuanbaoBtn:setAnchorPoint(cc.p(1, 0.5))
	yuanbaoBtn:setPosition(cellBg:getContentSize().width - 10, cellBg:getContentSize().height * 0.3)
	cellBg:addChild(yuanbaoBtn)
	
	if configData.needGold == 0 then
		yuanbaoBtn:setVisible(false)
	end

	return node
end

function ZiYuanZhaoHuiLayer:showPanel(what)
end



